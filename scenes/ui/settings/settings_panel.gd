class_name SettingsPanel
extends PanelContainer
## Bảng cài đặt tạm: âm lượng và bật điều khiển cảm ứng. Độ phân giải, phím, ngôn ngữ... làm ở Phase 14.

signal closed

const VOLUME_ROWS: Array[Dictionary] = [
	{"bus": "Master", "label": "SETTINGS_VOLUME_MASTER"},
	{"bus": "Music", "label": "SETTINGS_VOLUME_MUSIC"},
	{"bus": "SFX", "label": "SETTINGS_VOLUME_SFX"},
	{"bus": "Voice", "label": "SETTINGS_VOLUME_VOICE"},
]

var _first_slider: HSlider

@onready var _volume_grid: GridContainer = %VolumeGrid
@onready var _touch_toggle: CheckButton = %TouchToggle
@onready var _close_button: Button = %CloseButton


func _ready() -> void:
	for row in VOLUME_ROWS:
		_add_volume_row(row["bus"], row["label"])
	_touch_toggle.button_pressed = UserSettings.is_touch_controls_forced()
	_touch_toggle.toggled.connect(_on_touch_toggled)
	_close_button.pressed.connect(close)


func open() -> void:
	show()
	if _first_slider:
		_first_slider.grab_focus()


func close() -> void:
	if not visible:
		return
	AudioManager.save_settings()
	hide()
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("menu") or event.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()
		close()


func _on_touch_toggled(enabled: bool) -> void:
	UserSettings.set_touch_controls_forced(enabled)
	EventBus.settings_changed.emit()


func _add_volume_row(bus_name: String, label_key: String) -> void:
	var label := Label.new()
	label.text = label_key
	label.custom_minimum_size.x = 260.0
	_volume_grid.add_child(label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.custom_minimum_size = Vector2(380.0, 48.0)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value = AudioManager.get_volume(bus_name)
	_volume_grid.add_child(slider)

	var value_label := Label.new()
	value_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	value_label.custom_minimum_size.x = 90.0
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.text = "%d%%" % roundi(slider.value * 100.0)
	_volume_grid.add_child(value_label)

	slider.value_changed.connect(func(value: float) -> void:
		AudioManager.set_volume(bus_name, value)
		value_label.text = "%d%%" % roundi(value * 100.0))
	if _first_slider == null:
		_first_slider = slider
