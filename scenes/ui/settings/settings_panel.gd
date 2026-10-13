class_name SettingsPanel
extends PanelContainer
## Bảng cài đặt (theo máy, user://settings.cfg), 3 thẻ:
##   Âm thanh: âm lượng Tổng / Nhạc / Hiệu ứng / Giọng.
##   Hiển thị: toàn màn hình, độ phân giải cửa sổ, tốc độ chữ, ngôn ngữ.
##   Điều khiển: bật joystick ảo, gán lại phím (bấm ô rồi nhấn phím mới), khôi phục mặc định.

signal closed

const VOLUME_ROWS: Array[Dictionary] = [
	{"bus": "Master", "label": "SETTINGS_VOLUME_MASTER"},
	{"bus": "Music", "label": "SETTINGS_VOLUME_MUSIC"},
	{"bus": "SFX", "label": "SETTINGS_VOLUME_SFX"},
	{"bus": "Voice", "label": "SETTINGS_VOLUME_VOICE"},
]
const TEXT_SPEED_KEYS: Dictionary = {"slow": "SETTINGS_TEXT_SLOW", "normal": "SETTINGS_TEXT_NORMAL",
		"fast": "SETTINGS_TEXT_FAST", "instant": "SETTINGS_TEXT_INSTANT"}
const LOCALE_NAMES: Dictionary = {"vi": "Tiếng Việt", "en": "English"}

## Hành động đang chờ nhấn phím mới ("" = không).
var waiting_action: String = ""
var fullscreen_toggle: CheckButton
var resolution_option: OptionButton
var text_speed_option: OptionButton
var locale_option: OptionButton

var _first_slider: HSlider
var _tabs: TabContainer
var _key_buttons: Dictionary = {}

@onready var _volume_grid: GridContainer = %VolumeGrid
@onready var _touch_toggle: CheckButton = %TouchToggle
@onready var _close_button: Button = %CloseButton


func _ready() -> void:
	offset_left = -600.0
	offset_right = 600.0
	offset_top = -470.0
	offset_bottom = 470.0
	var vbox := _volume_grid.get_parent()
	_tabs = TabContainer.new()
	_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tabs.add_theme_font_size_override("font_size", 26)
	vbox.add_child(_tabs)
	vbox.move_child(_tabs, _volume_grid.get_index())
	# Thẻ Âm thanh.
	vbox.remove_child(_volume_grid)
	_volume_grid.name = tr("SETTINGS_TAB_AUDIO")
	_tabs.add_child(_volume_grid)
	for row in VOLUME_ROWS:
		_add_volume_row(row["bus"], row["label"])
	# Thẻ Hiển thị.
	var display := _tab_page("SETTINGS_TAB_DISPLAY")
	fullscreen_toggle = CheckButton.new()
	fullscreen_toggle.text = tr("SETTINGS_FULLSCREEN")
	fullscreen_toggle.button_pressed = UserSettings.is_fullscreen()
	fullscreen_toggle.toggled.connect(func(on: bool) -> void:
		UserSettings.set_value("display", "fullscreen", on)
		UserSettings.apply_display())
	display.add_child(fullscreen_toggle)
	resolution_option = _option_row(display, "SETTINGS_RESOLUTION")
	for res in UserSettings.RESOLUTIONS:
		resolution_option.add_item("%d × %d" % [res.x, res.y])
	resolution_option.selected = maxi(UserSettings.RESOLUTIONS.find(UserSettings.get_resolution()), 0)
	resolution_option.item_selected.connect(func(index: int) -> void:
		UserSettings.set_value("display", "resolution", UserSettings.RESOLUTIONS[index])
		UserSettings.apply_display())
	text_speed_option = _option_row(display, "SETTINGS_TEXT_SPEED")
	for id: String in UserSettings.TEXT_SPEEDS:
		text_speed_option.add_item(tr(TEXT_SPEED_KEYS[id]))
	text_speed_option.selected = UserSettings.TEXT_SPEEDS.keys().find(UserSettings.get_text_speed_id())
	text_speed_option.item_selected.connect(func(index: int) -> void:
		UserSettings.set_value("general", "text_speed", UserSettings.TEXT_SPEEDS.keys()[index]))
	locale_option = _option_row(display, "SETTINGS_LANGUAGE")
	for locale in UserSettings.LOCALES:
		locale_option.add_item(LOCALE_NAMES.get(locale, locale))
	locale_option.selected = maxi(UserSettings.LOCALES.find(UserSettings.get_locale()), 0)
	locale_option.item_selected.connect(func(index: int) -> void:
		UserSettings.set_locale(UserSettings.LOCALES[index])
		EventBus.settings_changed.emit())
	# Thẻ Điều khiển.
	var controls := _tab_page("SETTINGS_TAB_CONTROLS")
	vbox.remove_child(_touch_toggle)
	controls.add_child(_touch_toggle)
	_touch_toggle.button_pressed = UserSettings.is_touch_controls_forced()
	_touch_toggle.toggled.connect(_on_touch_toggled)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0.0, 420.0)
	controls.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)
	for action in UserSettings.REBINDABLE:
		var label := Label.new()
		label.text = tr("ACTION_" + action.to_upper())
		label.custom_minimum_size.x = 420.0
		grid.add_child(label)
		var button := UiKit.make_button(UserSettings.key_name(action), start_rebind.bind(action), Vector2(260.0, 48.0))
		grid.add_child(button)
		_key_buttons[action] = button
	controls.add_child(UiKit.make_button(tr("SETTINGS_RESET_KEYS"), func() -> void:
		UserSettings.reset_keys()
		_refresh_keys(), Vector2(320.0, 52.0)))
	_close_button.pressed.connect(close)


func _tab_page(title_key: String) -> VBoxContainer:
	var page := VBoxContainer.new()
	page.name = tr(title_key)
	page.add_theme_constant_override("separation", 18)
	_tabs.add_child(page)
	return page


func _option_row(parent: Node, label_key: String) -> OptionButton:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)
	var label := Label.new()
	label.text = tr(label_key)
	label.custom_minimum_size.x = 300.0
	row.add_child(label)
	var option := OptionButton.new()
	option.custom_minimum_size = Vector2(360.0, 52.0)
	row.add_child(option)
	return option


func open() -> void:
	show()
	if _first_slider:
		_first_slider.grab_focus()


func close() -> void:
	if not visible:
		return
	waiting_action = ""
	UserSettings.save()
	hide()
	closed.emit()


func get_key_button(action: String) -> Button:
	return _key_buttons.get(action)


## Bấm ô phím: chờ người chơi nhấn phím mới (Esc = hủy).
func start_rebind(action: String) -> void:
	waiting_action = action
	(_key_buttons[action] as Button).text = tr("SETTINGS_PRESS_KEY")


func _refresh_keys() -> void:
	for action: String in _key_buttons:
		(_key_buttons[action] as Button).text = UserSettings.key_name(action)


func _input(event: InputEvent) -> void:
	if waiting_action.is_empty() or not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		var key := event as InputEventKey
		if key.keycode != KEY_ESCAPE:
			UserSettings.set_key(waiting_action, key.physical_keycode if key.physical_keycode != 0 else key.keycode)
		waiting_action = ""
		_refresh_keys()


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
