extends Control
## Phòng thử trận: đánh bù nhìn (2 con yếu cả 7 nguyên tố, 1 con chỉ yếu Lửa, máu rất nhiều),
## chọn nguyên tố đòn đánh của phe ta để kiểm chứng đủ 7 hiệu ứng Phá Vỡ,
## và thấy đòn sai nguyên tố không làm giảm khiên. Chọn đúng 4 nhân vật và cấp Tinh Mệnh (áp cho cả đội),
## bấm "Áp dụng" để đánh lại với đội mới. Phase 7 thêm chọn quái và cấp.
## Mở: chạy thẳng scene này (F6), hoặc menu tạm dừng → "Phòng thử trận" (bản debug).

const SANDBOX_ENCOUNTER: String = "res://data/encounters/sandbox_dummies.tres"
const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/battle_scene.tscn")

var battle: Node

var _element_buttons: Dictionary = {}
var _team_checks: Dictionary = {}
var _eidolon_spin: SpinBox

@onready var _panel: HBoxContainer = %SandboxPanel
@onready var _element_label: Label = %ElementLabel


func _ready() -> void:
	var payload := SceneRouter.payload.duplicate()
	payload["encounter"] = load(SANDBOX_ENCOUNTER)
	payload["opening"] = BattleTypes.Opening.NORMAL
	SceneRouter.payload = payload
	battle = BATTLE_SCENE.instantiate()
	add_child(battle)
	move_child(battle, 0)
	_build_panel()
	select_element(Element.NONE)


## Ép nguyên tố mọi đòn của phe ta (Element.NONE = theo nhân vật).
func select_element(element: int) -> void:
	battle.controller.debug_element_override = element
	_element_label.text = tr("SANDBOX_ELEMENT") % (tr(Element.name_key(element)) if element != Element.NONE \
			else tr("SANDBOX_ELEMENT_DEFAULT"))
	for key: int in _element_buttons:
		(_element_buttons[key] as Button).set_pressed_no_signal(key == element)


## Hồi khiên, gỡ hiệu ứng và hồi máu bù nhìn; hồi máu + đầy năng lượng cho đội.
func reset_dummies() -> void:
	var controller: BattleController = battle.controller
	for unit in controller.enemies:
		StatusEffects.remove_all(unit)
		unit.recover_toughness()
		unit.heal(unit.get_max_hp())
	for unit in controller.allies:
		unit.heal(unit.get_max_hp())
		unit.set_energy(unit.max_energy)
	controller.change_skill_points(BattleController.MAX_SKILL_POINTS)


func _build_panel() -> void:
	var group := ButtonGroup.new()
	group.allow_unpress = false
	_add_element_button(Element.NONE, tr("SANDBOX_ELEMENT_DEFAULT"), Color.WHITE, group)
	for element in Element.all():
		_add_element_button(element, tr(Element.name_key(element)), Element.color(element), group)
	var reset := Button.new()
	reset.text = tr("SANDBOX_RESET")
	reset.focus_mode = Control.FOCUS_NONE
	reset.custom_minimum_size = Vector2(0.0, 48.0)
	reset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset.pressed.connect(reset_dummies)
	_panel.add_child(reset)
	_build_team_row()


func _build_team_row() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	_panel.get_parent().add_child(row)
	var label := Label.new()
	label.text = tr("SANDBOX_TEAM")
	row.add_child(label)
	for id in GameState.owned_characters:
		var data := DataPaths.load_character(id)
		var check := CheckBox.new()
		check.text = GameState.player_name if id == GameState.PLAYER_CHARACTER_ID else tr(data.name_key)
		check.button_pressed = GameState.team.has(id)
		check.focus_mode = Control.FOCUS_NONE
		row.add_child(check)
		_team_checks[id] = check
	_eidolon_spin = SpinBox.new()
	_eidolon_spin.min_value = 0
	_eidolon_spin.max_value = 6
	_eidolon_spin.prefix = tr("SANDBOX_EIDOLON").replace("%d", "").strip_edges()
	_eidolon_spin.value = GameState.get_eidolon_level(GameState.team[0])
	row.add_child(_eidolon_spin)
	var apply := Button.new()
	apply.text = tr("SANDBOX_APPLY")
	apply.focus_mode = Control.FOCUS_NONE
	apply.pressed.connect(func() -> void:
		var ids: Array[StringName] = []
		for id: StringName in _team_checks:
			if (_team_checks[id] as CheckBox).button_pressed:
				ids.append(id)
		apply_team(ids, int(_eidolon_spin.value)))
	row.add_child(apply)


## Đặt đội (đúng 4 người) và cấp Tinh Mệnh cho cả đội rồi mở lại phòng thử. Trả về false nếu đội sai.
func apply_team(ids: Array[StringName], eidolon_level: int) -> bool:
	if ids.size() != GameConfig.MAX_TEAM_SIZE:
		EventBus.toast_requested.emit(tr("SANDBOX_TEAM_INVALID"))
		_element_label.text = tr("SANDBOX_TEAM_INVALID")
		return false
	if not GameState.set_team(ids):
		return false
	for id in ids:
		GameState.set_eidolon_level(id, eidolon_level)
	SceneRouter.go_to(DataPaths.BATTLE_SANDBOX_SCENE, SceneRouter.payload.duplicate())
	return true


func _add_element_button(element: int, label: String, color: Color, group: ButtonGroup) -> void:
	var button := Button.new()
	button.text = label
	button.toggle_mode = true
	button.button_group = group
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0.0, 48.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_pressed_color", color.lightened(0.4))
	button.pressed.connect(select_element.bind(element))
	_panel.add_child(button)
	_element_buttons[element] = button
