extends Control
## Màn hình tiêu đề: Bắt đầu, Tiếp tục (mờ khi chưa có save), Cài đặt, Thoát.

@onready var _menu: VBoxContainer = %Menu
@onready var _start_button: Button = %StartButton
@onready var _continue_button: Button = %ContinueButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _settings_panel: SettingsPanel = %SettingsPanel


func _ready() -> void:
	_continue_button.disabled = not SaveManager.has_any_save()
	_start_button.pressed.connect(_on_start_pressed)
	_continue_button.pressed.connect(_on_continue_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_settings_panel.closed.connect(_on_settings_closed)
	_settings_panel.hide()
	(_continue_button if not _continue_button.disabled else _start_button).grab_focus()


func _on_start_pressed() -> void:
	# TODO Phase 14: hỏi xác nhận nếu sắp ghi đè ô tự lưu đang có.
	GameState.reset_new_game()
	SceneRouter.go_to(DataPaths.INTRO_SCENE)


func _on_continue_pressed() -> void:
	if not SaveManager.load_latest():
		_continue_button.disabled = true
		_start_button.grab_focus()
		return
	var target := GameState.current_map_scene
	if target.is_empty() or not ResourceLoader.exists(target):
		target = DataPaths.HUB_SCENE
	SceneRouter.go_to(target)


func _on_settings_pressed() -> void:
	_menu.hide()
	_settings_panel.open()


func _on_settings_closed() -> void:
	_menu.show()
	_settings_button.grab_focus()


func _on_quit_pressed() -> void:
	get_tree().quit()
