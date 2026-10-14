extends Control
## Màn trận theo lượt 2D: phe ta bên trái, quái bên phải, thanh thứ tự lượt bên trái,
## 4 thẻ nhân vật dưới cùng, nút Đánh thường / Chiến kỹ và ô Điểm Chiến Kỹ góc phải.
## Vào: SceneRouter.payload { "encounter", "opening", "opener_element", "hard_mode" } (thêm "instant", "team_override" khi test).
## Ra: GameState.finish_battle() rồi quay về map với payload { "battle_result": "win"|"lose" }.
## Thắng trận thật (đi từ map) thì nhận thưởng theo bảng rơi đồ (Loot.claim_encounter) và hiện trên bảng kết quả.
##
## Điều khiển: bấm quái/đồng minh = chọn và ra đòn; Q / E = Đánh thường / Chiến kỹ (bấm lại = ra đòn);
## ←/→ đổi mục tiêu, Space/Enter ra đòn; bấm thẻ hoặc phím 1–4 = Tuyệt kỹ; chuột phải/Esc = hủy Tuyệt kỹ.
## Tuyệt kỹ có 2 chế độ (SkillData.alternate): đang chọn mục tiêu Tuyệt kỹ thì Q để đổi chế độ.

const ALLY_POSITIONS: Array[Vector2] = [
	Vector2(700, 300), Vector2(570, 420), Vector2(700, 540), Vector2(570, 660)]
const ENEMY_CENTER := Vector2(1360, 440)
const SUMMON_POSITION := Vector2(420, 540)
const ENEMY_SPACING: float = 230.0
const ENEMY_STAGGER: float = 70.0
## Bề rộng tối đa khu quái (từ giữa sân sang mép phải).
const ENEMY_AREA_WIDTH: float = 1060.0
const PREVIEW_COUNT: int = 8
const ULTIMATE_BANNER_SEC: float = 0.9
const ULTIMATE_BG_SHADER: String = "res://assets/vfx/shaders/ultimate_bg.gdshader"
const SkillVfx_ACTIONS: Dictionary = {SkillData.Kind.BASIC: "attack", SkillData.Kind.SKILL: "skill",
		SkillData.Kind.ULTIMATE: "ultimate", SkillData.Kind.FOLLOW_UP: "attack"}
## Chạm vào biểu tượng hiệu ứng (màn cảm ứng) thì giữ mô tả chừng này giây.
const TOOLTIP_TAP_SEC: float = 3.0
const HARD_MODE_CONFIG: String = "res://data/config/boss_hard_mode.tres"
const DEFAULT_MUSIC: StringName = &"battle_normal"

enum Mode { WATCH, CHOOSE, ULTIMATE }

var controller: BattleController

var _views: Dictionary = {}
var _cards: Array[CharacterCard] = []
var _mode: Mode = Mode.WATCH
var _acting: BattleUnit
var _selected_kind: SkillData.Kind = SkillData.Kind.BASIC
var _target: BattleUnit
var _ultimate_unit: BattleUnit
var _ultimate_alt: bool = false
var _encounter: EncounterData
var _opening: BattleTypes.Opening = BattleTypes.Opening.NORMAL
var _setup_failed: bool = false
var _opener_element: int = Element.NONE
var _tooltip_hold: float = 0.0
var _phase_overlay: Control
## Ghi máu cả đội về GameState khi rời trận thắng (trận thật, không phải phòng thử/test).
var _persist_hp: bool = true
var _phase_title: Label
var _phase_subtitle: Label
var _phase_backdrop: ColorRect
## Phần thưởng trận vừa thắng (rỗng ở phòng thử / test): { "items", "first_clear", "coins_only", "hard" }.
var rewards: Dictionary = {}

## Nền Tuyệt kỹ (tạo khi dùng Tuyệt kỹ lần đầu).
var ultimate_backdrop: ColorRect
var _last_skill_kind: int = SkillData.Kind.BASIC
@onready var _field: Node2D = %Field
@onready var _numbers: DamageNumberPool = %Numbers
@onready var _turn_order: TurnOrderBar = %TurnOrder
@onready var _wave_label: Label = %WaveLabel
@onready var _info_label: Label = %InfoLabel
@onready var _skill_info: Label = %SkillInfo
@onready var _cards_box: HBoxContainer = %Cards
@onready var _skill_points: SkillPointsBar = %SkillPoints
@onready var _basic_button: Button = %BasicButton
@onready var _skill_button: Button = %SkillButton
@onready var _auto_button: Button = %AutoButton
@onready var _speed_button: Button = %SpeedButton
@onready var _banner: Button = %UltimateBanner
@onready var _result_panel: PanelContainer = %ResultPanel
@onready var _result_title: Label = %ResultTitle
@onready var _result_body: Label = %ResultBody
@onready var _continue_button: Button = %ContinueButton
@onready var _retry_button: Button = %RetryButton
@onready var _retreat_button: Button = %RetreatButton
@onready var _tooltip: PanelContainer = %Tooltip
@onready var _tooltip_label: Label = %TooltipLabel


func _ready() -> void:
	_encounter = SceneRouter.payload.get("encounter") as EncounterData
	_opening = int(SceneRouter.payload.get("opening", BattleTypes.Opening.NORMAL)) as BattleTypes.Opening
	if _encounter == null:
		# Mở thẳng scene này để thử: dùng trận mẫu.
		_encounter = load(DataPaths.DEBUG_ENCOUNTER) as EncounterData
	_opener_element = int(SceneRouter.payload.get("opener_element", Element.NONE))
	_result_panel.hide()
	_banner.hide()
	_tooltip.hide()

	controller = BattleController.new()
	controller.name = "Controller"
	controller.instant = bool(SceneRouter.payload.get("instant", false))
	controller.rng.randomize()
	if bool(SceneRouter.payload.get("hard_mode", false)) and _encounter.is_boss():
		controller.difficulty = load(HARD_MODE_CONFIG) as DifficultyConfig
	add_child(controller)
	var team: Array[CharacterData] = GameState.get_team_data()
	var team_override: Variant = SceneRouter.payload.get("team_override")
	if team_override is Array:
		team.assign(team_override)
	# Trận thật dùng tiến trình từng nhân vật và giữ máu; phòng thử / test dùng máu đầy.
	_persist_hp = not SceneRouter.payload.has("sandbox_encounter") and not team_override is Array
	for data in team:
		var state := Progression.battle_snapshot(data.id, _persist_hp)
		if GameState.team_level > 0:
			state.erase("level")
		controller.ally_states[data.id] = state
	var err := controller.setup(team, maxi(GameState.team_level, 1), _encounter, _opening,
			{GameState.PLAYER_CHARACTER_ID: GameState.player_gender},
			{GameState.PLAYER_CHARACTER_ID: GameState.player_name}, _opener_element,
			GameState.get_eidolon_levels_for_battle(), _get_payload_techniques())
	if err != OK:
		_show_setup_error(err, team.size())
		return
	_connect_buttons()
	_connect_controller()
	for unit in controller.allies:
		_add_view(unit, ALLY_POSITIONS[unit.slot])
		var card := CharacterCard.new()
		card.setup(unit, str(unit.slot + 1))
		card.pressed.connect(activate_ultimate)
		_cards_box.add_child(card)
		_cards.append(card)
	_build_phase_overlay()
	_on_wave_started(controller.wave_index, controller.enemies)
	_info_label.text = tr(BattleTypes.opening_key(_opening))
	if controller.difficulty:
		_wave_label.text += "  ·  " + tr(controller.difficulty.name_key)
	_play_music(_initial_music_id())
	_auto_button.button_pressed = bool(UserSettings.get_value("battle", "auto", false))
	_speed_button.button_pressed = bool(UserSettings.get_value("battle", "speed_x2", false))
	controller.set_auto(_auto_button.button_pressed)
	_apply_speed(_speed_button.button_pressed)
	controller.start()


func _get_payload_techniques() -> Array[StringName]:
	var result: Array[StringName] = []
	for id: Variant in SceneRouter.payload.get("techniques", []):
		result.append(StringName(str(id)))
	return result


func _process(delta: float) -> void:
	if _tooltip_hold > 0.0:
		_tooltip_hold -= delta
		if _tooltip_hold <= 0.0:
			_tooltip.hide()


func _exit_tree() -> void:
	Engine.time_scale = 1.0
	AudioManager.stop_music()


# --- Hàm công khai (chuột, bàn phím và test cùng gọi) ---

func get_view(unit: BattleUnit) -> UnitView:
	return _views.get(unit)


func get_opening() -> BattleTypes.Opening:
	return _opening


## Kết thúc trận ngay với kết quả cho trước (test, phím debug F9 ở bản debug).
func debug_force_result(battle_won: bool) -> void:
	if controller and not _setup_failed:
		controller.force_end(battle_won)


func get_mode() -> Mode:
	return _mode


func get_target() -> BattleUnit:
	return _target


func get_turn_order_bar() -> TurnOrderBar:
	return _turn_order


func is_setup_failed() -> bool:
	return _setup_failed


## Chọn Đánh thường / Chiến kỹ. Chọn lại đúng kỹ năng đang chọn = ra đòn.
func select_kind(kind: SkillData.Kind) -> void:
	if _mode != Mode.CHOOSE:
		return
	if kind == _selected_kind:
		confirm()
		return
	var skill := _acting.get_skill(kind)
	if not controller.can_use(_acting, skill):
		_skill_info.text = tr("BATTLE_SKILL_SEALED") if _acting.is_skill_sealed() else tr("BATTLE_NO_SKILL_POINTS")
		return
	_selected_kind = kind
	if not _current_pool().has(_target):
		_target = _default_target()
	_refresh_choice()


## Chọn mục tiêu (không ra đòn). Trả về false nếu không chọn được.
func select_target(unit: BattleUnit) -> bool:
	if _mode == Mode.WATCH or not _current_pool().has(unit):
		return false
	_target = unit
	_refresh_choice()
	return true


func confirm() -> void:
	match _mode:
		Mode.CHOOSE:
			if controller.submit_action(_selected_kind, _target):
				_set_watch()
		Mode.ULTIMATE:
			var unit := _ultimate_unit
			var skill := _current_skill()
			_ultimate_unit = null
			_set_watch()
			controller.request_ultimate(unit, _target, skill)
			_refresh_cards()
			if controller.is_awaiting_input() and _mode == Mode.WATCH:
				_enter_choose()


## Bấm thẻ nhân vật: Tuyệt kỹ chen lượt (cần chọn mục tiêu thì vào chế độ chọn).
func activate_ultimate(unit: BattleUnit) -> bool:
	if controller.auto_mode or not unit.is_ultimate_ready() or controller.is_ultimate_queued(unit):
		return false
	var ultimate := unit.get_skill(SkillData.Kind.ULTIMATE)
	if not ultimate.needs_target_choice():
		controller.request_ultimate(unit, null)
		_refresh_cards()
		return true
	_ultimate_unit = unit
	_ultimate_alt = false
	_mode = Mode.ULTIMATE
	_target = _default_target()
	_refresh_choice()
	return true


## Đổi chế độ Tuyệt kỹ (nếu có chế độ khác).
func toggle_ultimate_mode() -> void:
	if _mode != Mode.ULTIMATE or _ultimate_unit.get_skill(SkillData.Kind.ULTIMATE).alternate == null:
		return
	_ultimate_alt = not _ultimate_alt
	if not _current_pool().has(_target):
		_target = _default_target()
	_refresh_choice()


func cancel_ultimate() -> void:
	if _mode != Mode.ULTIMATE:
		return
	_ultimate_unit = null
	if controller.is_awaiting_input():
		_enter_choose()
	else:
		_set_watch()


func set_auto(enabled: bool) -> void:
	_auto_button.set_pressed_no_signal(enabled)
	_on_auto_toggled(enabled)


# --- Tín hiệu từ BattleController ---

func _connect_controller() -> void:
	controller.turn_started.connect(_on_turn_started)
	controller.input_requested.connect(_on_input_requested)
	controller.action_started.connect(_on_action_started)
	controller.action_resolved.connect(_on_action_resolved)
	controller.status_events.connect(func(_unit: BattleUnit, events: Array[Dictionary]) -> void:
		_show_events(events))
	controller.skill_points_changed.connect(_on_skill_points_changed)
	controller.queue_changed.connect(_refresh_turn_order)
	controller.wave_started.connect(_on_wave_started)
	controller.summon_added.connect(func(unit: BattleUnit) -> void:
		_add_view(unit, SUMMON_POSITION + Vector2(0.0, 120.0 * controller.summons.find(unit))))
	controller.summon_removed.connect(func(unit: BattleUnit) -> void:
		var view := get_view(unit)
		if view:
			view.queue_free()
			_views.erase(unit))
	controller.battle_ended.connect(_on_battle_ended)
	controller.enemy_spawned.connect(_on_enemy_spawned)
	controller.boss_phase_started.connect(_on_boss_phase_started)
	controller.queue_changed.connect(_refresh_threats)


func _on_wave_started(index: int, wave_enemies: Array[BattleUnit]) -> void:
	for unit: BattleUnit in _views.keys():
		if not unit.is_ally():
			_views[unit].queue_free()
			_views.erase(unit)
	for unit in wave_enemies:
		_add_view(unit, ENEMY_CENTER)
	_layout_enemies(false)
	_wave_label.text = tr("BATTLE_WAVE_PROGRESS") % [index + 1, controller.get_wave_count()]
	_refresh_turn_order()


## Xếp quái còn sống theo vị trí (slot); quái mới gọi ra thì cả hàng trượt về chỗ mới.
func _layout_enemies(animate: bool) -> void:
	var alive: Array[BattleUnit] = []
	for unit: BattleUnit in _views.keys():
		if not unit.is_ally() and unit.is_alive():
			alive.append(unit)
	alive.sort_custom(func(a: BattleUnit, b: BattleUnit) -> bool: return a.slot < b.slot)
	# Mỗi quái chiếm bề rộng theo cỡ hình (boss to hơn); quá rộng thì ép lại cho vừa khu bên phải.
	var widths: Array[float] = []
	var total := 0.0
	for unit in alive:
		var width := maxf((_views[unit] as UnitView).get_radius() * 2.0 + 90.0, ENEMY_SPACING * 0.9)
		widths.append(width)
		total += width
	var squeeze := minf(ENEMY_AREA_WIDTH / maxf(total, 1.0), 1.0)
	var x := ENEMY_CENTER.x - total * squeeze * 0.5
	for i in alive.size():
		var view: UnitView = _views[alive[i]]
		var stagger := ENEMY_STAGGER if i % 2 == 1 else -ENEMY_STAGGER * 0.3
		var target := Vector2(x + widths[i] * squeeze * 0.5, ENEMY_CENTER.y + stagger)
		x += widths[i] * squeeze
		view.home_position = target
		if animate:
			view.create_tween().tween_property(view, "position", target, 0.3).set_ease(Tween.EASE_OUT)
		else:
			view.position = target


func _on_enemy_spawned(unit: BattleUnit) -> void:
	_add_view(unit, ENEMY_CENTER + Vector2(0.0, -260.0))
	_layout_enemies(true)
	_refresh_turn_order()


## Đánh dấu nhân vật phe ta sắp trúng đòn tích tụ; dòng nhắc cách ngắt.
func _refresh_threats() -> void:
	if controller == null:
		return
	var threatened: Array[BattleUnit] = []
	for unit in controller.enemies:
		for target in controller.get_charge_targets(unit):
			threatened.append(target)
	for view: UnitView in _views.values():
		view.threatened = view.unit.is_ally() and threatened.has(view.unit)


func _charge_hint(unit: BattleUnit) -> String:
	var charge := unit.charge
	if charge == null:
		return ""
	var how := ""
	if charge.action.cancel_on_break:
		how = tr("BATTLE_HINT_BREAK")
	elif charge.action.cancel_damage_ratio > 0.0:
		var left := unit.get_max_hp() * charge.action.cancel_damage_ratio - charge.damage_taken
		how = tr("BATTLE_HINT_DAMAGE") % maxi(ceili(left), 0)
	return tr("BATTLE_THREAT_HINT") % [unit.display_name, tr(charge.action.skill.name_key), how]


func _on_turn_started(unit: BattleUnit) -> void:
	for view: UnitView in _views.values():
		view.is_acting = view.unit == unit
	for card in _cards:
		card.is_acting = card.unit == unit
	_info_label.text = tr("BATTLE_TURN_OF") % unit.display_name


func _on_input_requested(unit: BattleUnit) -> void:
	_acting = unit
	_selected_kind = SkillData.Kind.BASIC
	if _mode == Mode.ULTIMATE:
		return
	_enter_choose()


func _on_action_started(unit: BattleUnit, skill: SkillData, _targets: Array[BattleUnit]) -> void:
	if _mode == Mode.CHOOSE:
		_set_watch()
	var view := get_view(unit)
	if view:
		view.play_action(skill.kind, skill, _targets.is_empty())
	_last_skill_kind = skill.kind
	_info_label.text = "%s: %s" % [unit.display_name, tr(skill.name_key)]
	if skill.kind == SkillData.Kind.ULTIMATE:
		_show_banner(unit, skill)
		_show_ultimate_backdrop(unit)
		AudioManager.play_sfx(&"ultimate")
	_refresh_cards()


func _on_action_resolved(_unit: BattleUnit, _skill: SkillData, events: Array[Dictionary]) -> void:
	if _unit.enemy:
		var affected: Array[BattleUnit] = []
		for event: Dictionary in events:
			var target := event.get("target") as BattleUnit
			if target and not affected.has(target) and str(event.get("type", "")) in [
					"damage", "shield", "heal", "status_applied"]:
				affected.append(target)
		for target in affected:
			var view := get_view(target)
			if view:
				SkillVfx.spawn_enemy(_field, view.position, _unit.enemy, _skill.id,
						maxf(view.get_radius() / UnitView.ALLY_RADIUS, 1.0))
		SkillVfx.spawn_enemy_screen(_field, _unit.enemy, _skill.id, size)
	_show_events(events)


## Hiện số/chữ bay cho danh sách sự kiện (SkillExecutor, BreakSystem, StatusEffects).
func _show_events(events: Array[Dictionary]) -> void:
	# Chữ trên cùng một mục tiêu xếp chồng lên nhau để khỏi đè.
	var stack: Dictionary = {}
	for event in events:
		var target: BattleUnit = event["target"]
		var view := get_view(target)
		if view == null:
			continue
		var line := int(stack.get(target, 0))
		stack[target] = line + 1
		var at := view.global_position + Vector2(0.0, -view.get_radius() - 20.0 - line * 34.0)
		var element_color := Element.color(int(event.get("element", Element.NONE)))
		var outline := element_color if event.has("element") else Color.BLACK
		match str(event["type"]):
			"damage":
				view.play_hit()
				AudioManager.play_sfx(&"crit" if event["crit"] else &"hit", randf_range(0.9, 1.1))
				var source := event.get("source") as BattleUnit
				if source == null or source.enemy == null:
					SkillVfx.spawn(_field, view.position, int(event.get("element", Element.NONE)),
							source.character if source else null, SkillVfx_ACTIONS.get(_last_skill_kind, "attack"),
							maxf(view.get_radius() / UnitView.ALLY_RADIUS, 1.0))
				if float(event.get("absorbed", 0.0)) > 0.0:
					_numbers.spawn(tr("BATTLE_ABSORBED") % event["absorbed"], at + Vector2(0, -34), Color(0.85, 0.9, 1.0), 26)
				if event["crit"]:
					_numbers.spawn("%d!" % event["amount"], at, Color("ffd34d"), 52, outline)
				else:
					_numbers.spawn("%d" % event["amount"], at, Color.WHITE, 40, outline)
				CameraShakeLite.shake(_field, 6.0 if event["crit"] else 3.0)
			"dot":
				view.play_hit()
				_numbers.spawn("%d" % event["amount"], at, element_color.lightened(0.3), 32)
			"break":
				view.play_hit()
				AudioManager.play_sfx(&"break")
				_numbers.spawn("%s  %d" % [tr("BATTLE_BREAK"), event["amount"]], at, element_color.lightened(0.2), 46)
				CameraShakeLite.shake(_field, 10.0)
			"status_applied":
				_numbers.spawn(tr(str(event.get("name_key", ""))), at, Color("ffcf4d"), 28)
			"status_resisted":
				_numbers.spawn(tr("BATTLE_RESISTED"), at, Color(0.75, 0.75, 0.75), 28)
			"recover":
				_numbers.spawn(tr("BATTLE_TOUGHNESS_RECOVERED"), at, Color.WHITE, 26)
			"skip":
				_numbers.spawn(tr("BATTLE_TURN_SKIPPED"), at, Color("7fb6ff"), 28)
			"heal":
				AudioManager.play_sfx(&"heal")
				_numbers.spawn("+%d" % event["amount"], at, Color("6fdc8c"), 38)
			"shield":
				_numbers.spawn(tr("BATTLE_SHIELD_GAINED") % event["amount"], at, Color(0.85, 0.9, 1.0), 30)
			"energy":
				_numbers.spawn(tr("BATTLE_ENERGY_GAINED") % event["amount"], at, Color("7fb6ff"), 24)
			"skill_point":
				_numbers.spawn(tr("BATTLE_SKILL_POINT_GAINED") % event["amount"], at, Color("f2d58a"), 28)
			"cleanse":
				_numbers.spawn(tr("BATTLE_CLEANSED"), at, Color("6fdc8c"), 26)
			"hp_cost":
				_numbers.spawn("−%d" % event["amount"], at, Color("ff8a5c"), 30)
			"summon":
				_numbers.spawn(tr("BATTLE_SUMMONED"), at, Color("6fdc8c"), 30)
			"intercept":
				_numbers.spawn(tr("BATTLE_INTERCEPTED"), at, Color(0.85, 0.9, 1.0), 28)
			"blast":
				_numbers.spawn(tr("BATTLE_BLAST"), at, Color("ff8a5c"), 34)
			"revive":
				_numbers.spawn(tr("BATTLE_REVIVED"), at, Color("6fdc8c"), 34)
			"advance":
				_numbers.spawn(tr("BATTLE_ADVANCED") % roundi(event["amount"] * 100.0), at, Color("7fb6ff"), 28)
			"charge":
				# Hiện giữa thân để không đè bảng cảnh báo trên đầu.
				_numbers.spawn(tr("BATTLE_CHARGING") % tr(str(event.get("name_key", ""))), view.global_position,
						Color("ff6b4d"), 34)
				_info_label.text = _charge_hint(target)
			"countdown":
				_numbers.spawn(tr("BATTLE_COUNTDOWN") % [tr(str(event.get("name_key", ""))), int(event["amount"])], at,
						Color("ff6b4d"), 30)
				_info_label.text = _charge_hint(target)
			"interrupted":
				_numbers.spawn(tr("BATTLE_INTERRUPTED"), at, Color("ffd34d"), 44)
				CameraShakeLite.shake(_field, 8.0)
			"sp_lost":
				_numbers.spawn(tr("BATTLE_SP_LOST") % int(event["amount"]), at, Color("f2d58a"), 32)
			"buff_copied":
				_numbers.spawn(tr("BATTLE_BUFF_COPIED") % tr(str(event.get("name_key", ""))), at, Color("c7b8ff"), 28)
			"buff_stolen":
				_numbers.spawn(tr("BATTLE_BUFF_STOLEN") % tr(str(event.get("name_key", ""))), at, Color("c78bff"), 30)
			"heat":
				_numbers.spawn(tr("BATTLE_HEAT") % int(event["amount"]), at, Element.color(Element.Type.FIRE).lightened(0.3), 30)
			"delay":
				_numbers.spawn(tr("BATTLE_DELAYED") % roundi(event["amount"] * 100.0), at, Color("c78bff"), 28)
	_refresh_cards()


func _on_skill_points_changed(value: int) -> void:
	_skill_points.value = value
	_refresh_buttons()


func _on_battle_ended(battle_won: bool) -> void:
	_set_watch()
	AudioManager.play_sfx(&"victory" if battle_won else &"defeat")
	if battle_won:
		for view: UnitView in _views.values():
			if is_instance_valid(view) and view.unit.is_ally():
				view.play_victory()
	_info_label.text = ""
	_result_panel.show()
	_continue_button.visible = battle_won
	_retry_button.visible = not battle_won
	_retreat_button.visible = not battle_won
	if battle_won:
		_result_title.text = tr("BATTLE_VICTORY")
		_result_body.text = _describe_rewards()
		_continue_button.grab_focus()
	else:
		_result_title.text = tr("BATTLE_DEFEAT")
		_result_body.text = tr("BATTLE_DEFEAT_BODY")
		_retry_button.grab_focus()


## Nhận thưởng (chỉ trận thật) và trả về chữ cho bảng kết quả.
func _describe_rewards() -> String:
	if not _persist_hp:
		return tr("BATTLE_REWARDS_SANDBOX")
	rewards = Loot.claim_encounter(_encounter, controller.difficulty != null, controller.rng)
	var lines: Array[String] = []
	if bool(rewards["first_clear"]) and _encounter.kind != EncounterData.Kind.NORMAL:
		lines.append(tr("BATTLE_FIRST_CLEAR"))
	if bool(rewards["coins_only"]):
		lines.append(tr("BATTLE_BOSS_COINS_ONLY"))
	lines.append_array(Loot.describe(rewards["items"]))
	return "\n".join(lines)


# --- Nhập liệu ---

func _unhandled_input(event: InputEvent) -> void:
	if _setup_failed or controller == null or controller.phase == BattleController.Phase.ENDED:
		return
	var motion := event as InputEventMouseMotion
	if motion:
		_update_tooltip(get_viewport().get_canvas_transform().affine_inverse() * motion.position, false)
		return
	var mouse := event as InputEventMouseButton
	if mouse and mouse.pressed:
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			var point := get_viewport().get_canvas_transform().affine_inverse() * mouse.position
			# Chạm vào biểu tượng hiệu ứng = xem mô tả (không ra đòn).
			if _update_tooltip(point, true):
				get_viewport().set_input_as_handled()
				return
			for view: UnitView in _views.values():
				if view.contains_point(point) and select_target(view.unit):
					get_viewport().set_input_as_handled()
					confirm()
					return
		elif mouse.button_index == MOUSE_BUTTON_RIGHT:
			cancel_ultimate()
		return
	if OS.is_debug_build() and event.is_action_pressed("debug_win_battle"):
		debug_force_result(true)
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("menu"):
		cancel_ultimate()
	elif event.is_action_pressed("battle_basic"):
		if _mode == Mode.ULTIMATE:
			toggle_ultimate_mode()
		else:
			select_kind(SkillData.Kind.BASIC)
	elif event.is_action_pressed("battle_skill"):
		select_kind(SkillData.Kind.SKILL)
	elif event.is_action_pressed("ui_left"):
		_cycle_target(-1)
	elif event.is_action_pressed("ui_right"):
		_cycle_target(1)
	elif event.is_action_pressed("ui_accept"):
		confirm()
	else:
		for i in controller.allies.size():
			if event.is_action_pressed("switch_character_%d" % (i + 1)):
				activate_ultimate(controller.allies[i])
				break


## Hiện mô tả hiệu ứng dưới con trỏ / chỗ chạm. Trả về true nếu đang trỏ vào một hiệu ứng.
func _update_tooltip(point: Vector2, tapped: bool) -> bool:
	for view: UnitView in _views.values():
		var instance := view.get_status_at(point)
		if instance:
			show_status_tooltip(instance, point)
			if tapped:
				_tooltip_hold = TOOLTIP_TAP_SEC
			return true
	if _tooltip_hold <= 0.0:
		_tooltip.hide()
	return false


func show_status_tooltip(instance: StatusEffectInstance, at: Vector2) -> void:
	var lines: Array[String] = [tr(instance.data.name_key)]
	if instance.stacks > 1:
		lines[0] += "  ×%d" % instance.stacks
	lines.append(tr(instance.data.desc_key))
	lines.append(tr("BATTLE_TURNS_LEFT") % instance.turns_left)
	_tooltip_label.text = "\n".join(lines)
	_tooltip.reset_size()
	_tooltip.position = (at + Vector2(24.0, 24.0)).clamp(Vector2.ZERO, size - _tooltip.size)
	_tooltip.show()


func is_tooltip_visible() -> bool:
	return _tooltip.visible


func get_status_tooltip_text() -> String:
	return _tooltip_label.text


func _cycle_target(step: int) -> void:
	var pool := _current_pool()
	if _mode == Mode.WATCH or pool.is_empty():
		return
	var index := pool.find(_target)
	select_target(pool[wrapi(index + step, 0, pool.size())])


# --- Trạng thái chọn ---

func _enter_choose() -> void:
	_mode = Mode.CHOOSE
	if not _current_pool().has(_target):
		_target = _default_target()
	_refresh_choice()


func _set_watch() -> void:
	_mode = Mode.WATCH
	for view: UnitView in _views.values():
		view.marker = UnitView.Marker.NONE
	_skill_info.text = ""
	_refresh_buttons()
	_refresh_turn_order()


func _current_user() -> BattleUnit:
	return _ultimate_unit if _mode == Mode.ULTIMATE else _acting


func _current_skill() -> SkillData:
	var user := _current_user()
	if user == null:
		return null
	if _mode == Mode.ULTIMATE:
		var ultimate := user.get_skill(SkillData.Kind.ULTIMATE)
		return ultimate.alternate if _ultimate_alt and ultimate.alternate else ultimate
	return user.get_skill(_selected_kind)


func _current_pool() -> Array[BattleUnit]:
	var skill := _current_skill()
	if skill == null:
		return []
	return SkillExecutor.get_target_pool(skill, _current_user(), controller.allies, controller.enemies)


func _default_target() -> BattleUnit:
	var pool := _current_pool()
	if pool.is_empty():
		return null
	var skill := _current_skill()
	if skill.is_ally_targeted():
		var lowest := pool[0]
		for unit in pool:
			if unit.get_hp_ratio() < lowest.get_hp_ratio():
				lowest = unit
		return lowest
	if pool.has(_target):
		return _target
	return pool[pool.size() / 2]


func _refresh_choice() -> void:
	var skill := _current_skill()
	for view: UnitView in _views.values():
		view.marker = UnitView.Marker.NONE
	if skill == null:
		return
	for entry in SkillExecutor.resolve_targets(skill, _current_user(), _target, controller.allies, controller.enemies):
		var view := get_view(entry["unit"])
		if view:
			view.marker = UnitView.Marker.MAIN if entry["main"] else UnitView.Marker.ADJACENT
	_skill_info.text = "%s — %s" % [tr(skill.name_key), tr(skill.desc_key)]
	if _mode == Mode.ULTIMATE and _ultimate_unit.get_skill(SkillData.Kind.ULTIMATE).alternate:
		_skill_info.text += "\n" + tr("BATTLE_ULTIMATE_SWITCH_MODE")
	_refresh_buttons()
	if _mode == Mode.CHOOSE:
		_turn_order.show_preview(controller.preview_order(skill, _target, PREVIEW_COUNT))


func _refresh_buttons() -> void:
	var choosing := _mode == Mode.CHOOSE and _acting != null
	_basic_button.disabled = not choosing
	_skill_button.disabled = not choosing or not controller.can_use(_acting, _acting.get_skill(SkillData.Kind.SKILL))
	_basic_button.set_pressed_no_signal(choosing and _selected_kind == SkillData.Kind.BASIC)
	_skill_button.set_pressed_no_signal(choosing and _selected_kind == SkillData.Kind.SKILL)
	if _acting:
		_basic_button.text = "%s  [Q]\n+1 ◆" % tr(_acting.get_skill(SkillData.Kind.BASIC).name_key)
		_skill_button.text = "%s  [E]\n−1 ◆" % tr(_acting.get_skill(SkillData.Kind.SKILL).name_key)
		if _acting.is_skill_sealed():
			_skill_button.text = "%s  [E]\n%s" % [tr(_acting.get_skill(SkillData.Kind.SKILL).name_key), tr("BATTLE_SKILL_SEALED")]


func _refresh_cards() -> void:
	for card in _cards:
		card.is_queued = controller.is_ultimate_queued(card.unit)
		card.queue_redraw()


func _refresh_turn_order() -> void:
	if controller == null or (_mode == Mode.CHOOSE and _turn_order.is_previewing()):
		return
	_turn_order.show_order(controller.current_unit, controller.queue.predict(PREVIEW_COUNT, controller.current_unit))


func _add_view(unit: BattleUnit, at: Vector2) -> void:
	var view := UnitView.new()
	view.setup(unit, at)
	_field.add_child(view)
	_views[unit] = view


## Tuyệt kỹ: nền đổi màu theo nguyên tố (shader ultimate_bg) + tranh cắt cảnh (splash) trượt qua nếu có.
func _show_ultimate_backdrop(unit: BattleUnit) -> void:
	if ultimate_backdrop == null:
		ultimate_backdrop = ColorRect.new()
		ultimate_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		ultimate_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var mat := ShaderMaterial.new()
		mat.shader = load(ULTIMATE_BG_SHADER)
		ultimate_backdrop.material = mat
		# Nằm trên nền, dưới sân đấu.
		add_child(ultimate_backdrop)
		move_child(ultimate_backdrop, _field.get_index())
	var mat := ultimate_backdrop.material as ShaderMaterial
	mat.set_shader_parameter("tint", Element.color(unit.element))
	var tween := create_tween()
	tween.tween_method(func(v: float) -> void: mat.set_shader_parameter("strength", v), 0.0, 1.0, 0.15)
	tween.tween_interval(ULTIMATE_BANNER_SEC + 0.4)
	tween.tween_method(func(v: float) -> void: mat.set_shader_parameter("strength", v), 1.0, 0.0, 0.4)
	var splash := ArtLibrary.splash(unit.character) if unit.character else null
	if splash:
		var cut := TextureRect.new()
		cut.texture = splash
		cut.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cut.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		cut.size = Vector2(1920.0, 540.0)
		cut.position = Vector2(1920.0, 270.0)
		cut.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(cut)
		move_child(cut, _field.get_index() + 1)
		var slide := create_tween()
		slide.tween_property(cut, "position:x", 0.0, 0.2).set_ease(Tween.EASE_OUT)
		slide.tween_interval(ULTIMATE_BANNER_SEC - 0.2)
		slide.tween_property(cut, "modulate:a", 0.0, 0.25)
		slide.tween_callback(cut.queue_free)


func _show_banner(unit: BattleUnit, skill: SkillData) -> void:
	_banner.text = "%s — %s" % [unit.display_name, tr(skill.name_key)]
	_banner.modulate = Color(unit.color.lightened(0.5), 1.0)
	_banner.position.x = -_banner.size.x
	_banner.show()
	var tween := create_tween()
	tween.tween_property(_banner, "position:x", 0.0, 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_interval(ULTIMATE_BANNER_SEC - 0.3)
	tween.tween_property(_banner, "modulate:a", 0.0, 0.2)
	tween.tween_callback(_banner.hide)


# --- Giai đoạn boss, nhạc ---

func _initial_music_id() -> StringName:
	if _encounter.music_id != &"":
		return _encounter.music_id
	var boss := _encounter.get_boss()
	if boss and boss.music_id != &"":
		return boss.music_id
	return DEFAULT_MUSIC


func _play_music(id: StringName) -> void:
	if id != &"" and PlaceholderMusic.has_track(id):
		AudioManager.play_music_id(id, 0.6)


## Lớp phủ đoạn chuyển giai đoạn: nền màu giai đoạn chớp lên, tên giai đoạn trượt vào. Bấm để bỏ qua.
func _build_phase_overlay() -> void:
	_phase_overlay = Control.new()
	_phase_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_phase_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_phase_overlay.hide()
	add_child(_phase_overlay)
	_phase_backdrop = ColorRect.new()
	_phase_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_phase_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phase_overlay.add_child(_phase_backdrop)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phase_overlay.add_child(box)
	_phase_subtitle = Label.new()
	_phase_subtitle.add_theme_font_size_override("font_size", 34)
	_phase_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_phase_subtitle)
	_phase_title = Label.new()
	_phase_title.add_theme_font_size_override("font_size", 72)
	_phase_title.add_theme_color_override("font_outline_color", Color.BLACK)
	_phase_title.add_theme_constant_override("outline_size", 12)
	_phase_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_phase_title)
	_phase_overlay.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and controller:
			controller.skip_wait())


func _on_boss_phase_started(unit: BattleUnit, index: int, data: BossPhaseData) -> void:
	_set_watch()
	var view := get_view(unit)
	if view:
		view.play_phase(index)
	_phase_subtitle.text = "%s — %s" % [unit.display_name, tr("BATTLE_PHASE_TITLE") % (index + 1)]
	_phase_title.text = tr(data.name_key)
	_phase_title.add_theme_color_override("font_color", data.color.lightened(0.6))
	_phase_backdrop.color = Color(data.color, 0.0)
	_phase_overlay.modulate.a = 1.0
	_phase_overlay.show()
	var box := _phase_title.get_parent() as Control
	box.position.x = -size.x * 0.3
	var duration := BattleController.PHASE_TRANSITION_SEC
	var tween := create_tween()
	tween.tween_property(_phase_backdrop, "color:a", 0.8, 0.15)
	tween.parallel().tween_property(box, "position:x", 0.0, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(_phase_backdrop, "color:a", 0.55, duration * 0.4)
	tween.tween_property(_phase_overlay, "modulate:a", 0.0, duration * 0.35)
	tween.tween_callback(_phase_overlay.hide)
	CameraShakeLite.shake(_field, 14.0)
	_info_label.text = "%s: %s" % [unit.display_name, tr(data.name_key)]
	_play_music(data.music_id)
	_layout_enemies(true)


func is_phase_overlay_visible() -> bool:
	return _phase_overlay != null and _phase_overlay.visible


# --- Nút ---

func _connect_buttons() -> void:
	_basic_button.pressed.connect(select_kind.bind(SkillData.Kind.BASIC))
	_skill_button.pressed.connect(select_kind.bind(SkillData.Kind.SKILL))
	_auto_button.toggled.connect(_on_auto_toggled)
	_speed_button.toggled.connect(_apply_speed)
	_banner.pressed.connect(func() -> void:
		if controller:
			controller.skip_wait())
	_continue_button.pressed.connect(_leave.bind(true))
	_retreat_button.pressed.connect(_leave.bind(false))
	_retry_button.pressed.connect(_retry)


func _on_auto_toggled(enabled: bool) -> void:
	UserSettings.set_value("battle", "auto", enabled)
	UserSettings.save()
	if _mode == Mode.ULTIMATE:
		cancel_ultimate()
	if enabled:
		_set_watch()
	controller.set_auto(enabled)


func _apply_speed(fast: bool) -> void:
	UserSettings.set_value("battle", "speed_x2", fast)
	UserSettings.save()
	Engine.time_scale = 2.0 if fast else 1.0


func _leave(battle_won: bool) -> void:
	if SceneRouter.is_busy():
		return
	if battle_won and _persist_hp:
		for unit in controller.allies:
			GameState.set_hp_ratio(unit.character.id, unit.get_hp_ratio())
	Engine.time_scale = 1.0
	var map_scene := GameState.finish_battle(battle_won)
	SceneRouter.go_to(map_scene, {"battle_result": "win" if battle_won else "lose"})


## Đánh lại từ đầu cùng trận, cùng kiểu mở trận.
func _retry() -> void:
	if SceneRouter.is_busy():
		return
	Engine.time_scale = 1.0
	var payload := SceneRouter.payload.duplicate()
	payload["encounter"] = _encounter
	payload["opening"] = _opening
	SceneRouter.go_to(DataPaths.BATTLE_SCENE, payload)


func _show_setup_error(err: Error, team_size: int) -> void:
	_setup_failed = true
	var message := tr("TEAM_ERROR_TOO_MANY") % GameConfig.MAX_TEAM_SIZE \
			if err == ERR_PARAMETER_RANGE_ERROR else tr("BATTLE_SETUP_ERROR_BODY")
	push_warning("BattleScene: không vào được trận (đội %d người, lỗi %d)" % [team_size, err])
	_result_title.text = tr("BATTLE_SETUP_ERROR")
	_result_body.text = message
	_continue_button.hide()
	_retry_button.hide()
	_retreat_button.show()
	_retreat_button.text = tr("UI_BACK")
	_retreat_button.pressed.connect(func() -> void:
		var map_scene := str(GameState.pending_battle.get("map_scene", DataPaths.TEST_MAP_SCENE))
		GameState.pending_battle.clear()
		SceneRouter.go_to(map_scene))
	_result_panel.show()


## Rung nhẹ sân đấu khi trúng đòn (trận không có Camera2D).
class CameraShakeLite:
	static func shake(node: Node2D, strength: float) -> void:
		var tween := node.create_tween()
		for i in 3:
			tween.tween_property(node, "position", Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength, 0.03)
		tween.tween_property(node, "position", Vector2.ZERO, 0.04)
