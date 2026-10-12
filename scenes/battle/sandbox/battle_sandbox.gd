extends Control
## Phòng thử trận: đánh bù nhìn (2 con yếu cả 7 nguyên tố, 1 con chỉ yếu Lửa, máu rất nhiều),
## chọn nguyên tố đòn đánh của phe ta để kiểm chứng đủ 7 hiệu ứng Phá Vỡ,
## và thấy đòn sai nguyên tố không làm giảm khiên.
## Mở: chạy thẳng scene này (F6), hoặc menu tạm dừng → "Phòng thử trận" (bản debug).

const SANDBOX_ENCOUNTER: String = "res://data/encounters/sandbox_dummies.tres"
const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/battle_scene.tscn")

var battle: Node

var _element_buttons: Dictionary = {}

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
