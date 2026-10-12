extends Control
## Màn trận theo lượt 2D: phe ta bên trái, quái bên phải, thanh thứ tự lượt bên trái,
## 4 thẻ nhân vật dưới cùng, nút Đánh thường / Chiến kỹ và ô Điểm Chiến Kỹ góc phải.
## Vào: SceneRouter.payload { "encounter", "opening" } (thêm "instant", "team_override" khi test).
## Ra: GameState.finish_battle() rồi quay về map với payload { "battle_result": "win"|"lose" }.
##
## Điều khiển: bấm quái/đồng minh = chọn và ra đòn; Q / E = Đánh thường / Chiến kỹ (bấm lại = ra đòn);
## ←/→ đổi mục tiêu, Space/Enter ra đòn; bấm thẻ hoặc phím 1–4 = Tuyệt kỹ; chuột phải/Esc = hủy Tuyệt kỹ.

const ALLY_POSITIONS: Array[Vector2] = [
	Vector2(700, 300), Vector2(570, 420), Vector2(700, 540), Vector2(570, 660)]
const ENEMY_CENTER := Vector2(1360, 440)
const ENEMY_SPACING: float = 230.0
const ENEMY_STAGGER: float = 70.0
const PREVIEW_COUNT: int = 8
const ULTIMATE_BANNER_SEC: float = 0.9

enum Mode { WATCH, CHOOSE, ULTIMATE }

var controller: BattleController

var _views: Dictionary = {}
var _cards: Array[CharacterCard] = []
var _mode: Mode = Mode.WATCH
var _acting: BattleUnit
var _selected_kind: SkillData.Kind = SkillData.Kind.BASIC
var _target: BattleUnit
var _ultimate_unit: BattleUnit
var _encounter: EncounterData
var _opening: BattleTypes.Opening = BattleTypes.Opening.NORMAL
var _setup_failed: bool = false

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


func _ready() -> void:
	_encounter = SceneRouter.payload.get("encounter") as EncounterData
	_opening = int(SceneRouter.payload.get("opening", BattleTypes.Opening.NORMAL)) as BattleTypes.Opening
	if _encounter == null:
		# Mở thẳng scene này để thử: dùng trận mẫu.
		_encounter = load(DataPaths.DEBUG_ENCOUNTER) as EncounterData
	_result_panel.hide()
	_banner.hide()

	controller = BattleController.new()
	controller.name = "Controller"
	controller.instant = bool(SceneRouter.payload.get("instant", false))
	controller.rng.randomize()
	add_child(controller)
	var team: Array[CharacterData] = GameState.get_team_data()
	var team_override: Variant = SceneRouter.payload.get("team_override")
	if team_override is Array:
		team.assign(team_override)
	var err := controller.setup(team, GameState.team_level, _encounter, _opening,
			{GameState.PLAYER_CHARACTER_ID: GameState.player_gender},
			{GameState.PLAYER_CHARACTER_ID: GameState.player_name})
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
	_on_wave_started(controller.wave_index, controller.enemies)
	_info_label.text = tr(BattleTypes.opening_key(_opening))
	_auto_button.button_pressed = bool(UserSettings.get_value("battle", "auto", false))
	_speed_button.button_pressed = bool(UserSettings.get_value("battle", "speed_x2", false))
	controller.set_auto(_auto_button.button_pressed)
	_apply_speed(_speed_button.button_pressed)
	controller.start()


func _exit_tree() -> void:
	Engine.time_scale = 1.0


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
		_skill_info.text = tr("BATTLE_NO_SKILL_POINTS")
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
			_ultimate_unit = null
			_set_watch()
			controller.request_ultimate(unit, _target)
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
	_mode = Mode.ULTIMATE
	_target = _default_target()
	_refresh_choice()
	return true


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
	controller.skill_points_changed.connect(_on_skill_points_changed)
	controller.queue_changed.connect(_refresh_turn_order)
	controller.wave_started.connect(_on_wave_started)
	controller.battle_ended.connect(_on_battle_ended)


func _on_wave_started(index: int, wave_enemies: Array[BattleUnit]) -> void:
	for unit: BattleUnit in _views.keys():
		if not unit.is_ally():
			_views[unit].queue_free()
			_views.erase(unit)
	var count := wave_enemies.size()
	for i in count:
		var offset := (i - (count - 1) * 0.5) * ENEMY_SPACING
		var stagger := ENEMY_STAGGER if i % 2 == 1 else -ENEMY_STAGGER * 0.3
		_add_view(wave_enemies[i], ENEMY_CENTER + Vector2(offset, stagger))
	_wave_label.text = tr("BATTLE_WAVE_PROGRESS") % [index + 1, controller.get_wave_count()]
	_refresh_turn_order()


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
		view.play_action()
	_info_label.text = "%s: %s" % [unit.display_name, tr(skill.name_key)]
	if skill.kind == SkillData.Kind.ULTIMATE:
		_show_banner(unit, skill)
	_refresh_cards()


func _on_action_resolved(_unit: BattleUnit, _skill: SkillData, events: Array[Dictionary]) -> void:
	for event in events:
		var target: BattleUnit = event["target"]
		var view := get_view(target)
		if view == null:
			continue
		var at := view.global_position + Vector2(0.0, -view.get_radius() - 20.0)
		match str(event["type"]):
			"damage":
				view.play_hit()
				if event["crit"]:
					_numbers.spawn("%d!" % event["amount"], at, Color("ffd34d"), 52)
				else:
					_numbers.spawn("%d" % event["amount"], at, Color.WHITE, 40)
				CameraShakeLite.shake(_field, 6.0 if event["crit"] else 3.0)
			"heal":
				_numbers.spawn("+%d" % event["amount"], at, Color("6fdc8c"), 38)
			"advance":
				_numbers.spawn(tr("BATTLE_ADVANCED") % roundi(event["amount"] * 100.0), at, Color("7fb6ff"), 28)
			"delay":
				_numbers.spawn(tr("BATTLE_DELAYED") % roundi(event["amount"] * 100.0), at, Color("c78bff"), 28)
	_refresh_cards()


func _on_skill_points_changed(value: int) -> void:
	_skill_points.value = value
	_refresh_buttons()


func _on_battle_ended(battle_won: bool) -> void:
	_set_watch()
	_info_label.text = ""
	_result_panel.show()
	_continue_button.visible = battle_won
	_retry_button.visible = not battle_won
	_retreat_button.visible = not battle_won
	if battle_won:
		_result_title.text = tr("BATTLE_VICTORY")
		_result_body.text = "%s\n%s" % [tr("BATTLE_EXP_GAINED") % PlaceholderRewards.exp_for_encounter(_encounter),
				tr("BATTLE_ITEMS_EMPTY")]
		_continue_button.grab_focus()
	else:
		_result_title.text = tr("BATTLE_DEFEAT")
		_result_body.text = tr("BATTLE_DEFEAT_BODY")
		_retry_button.grab_focus()


# --- Nhập liệu ---

func _unhandled_input(event: InputEvent) -> void:
	if _setup_failed or controller == null or controller.phase == BattleController.Phase.ENDED:
		return
	var mouse := event as InputEventMouseButton
	if mouse and mouse.pressed:
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			var point := get_viewport().get_canvas_transform().affine_inverse() * mouse.position
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
	return user.get_skill(SkillData.Kind.ULTIMATE if _mode == Mode.ULTIMATE else _selected_kind)


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
