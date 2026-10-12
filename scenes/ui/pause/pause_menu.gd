class_name PauseMenu
extends Control
## Menu tạm dừng ngoài map (Esc): Tiếp tục, Cài đặt, Về màn hình tiêu đề.
## TODO Phase 9: thêm Đội hình, Nhân vật, Túi đồ.

@onready var _menu: VBoxContainer = %Menu
@onready var _resume_button: Button = %ResumeButton
@onready var _settings_button: Button = %SettingsButton
@onready var _title_button: Button = %TitleButton
@onready var _settings_panel: SettingsPanel = %SettingsPanel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_settings_panel.hide()
	_resume_button.pressed.connect(close)
	_settings_button.pressed.connect(_on_settings_pressed)
	_title_button.pressed.connect(_on_title_pressed)
	_settings_panel.closed.connect(_on_settings_closed)
	if OS.is_debug_build():
		# Bản debug: lối vào phòng thử trận (Phase 5).
		var sandbox := Button.new()
		sandbox.text = tr("PAUSE_BATTLE_SANDBOX")
		sandbox.custom_minimum_size = Vector2(0.0, 72.0)
		sandbox.pressed.connect(func() -> void:
			get_tree().paused = false
			SceneRouter.go_to(DataPaths.BATTLE_SANDBOX_SCENE))
		_menu.add_child(sandbox)
		_menu.move_child(sandbox, _title_button.get_index())


func open() -> void:
	if SceneRouter.is_busy():
		return
	show()
	_menu.show()
	get_tree().paused = true
	_resume_button.grab_focus()


func close() -> void:
	hide()
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("menu"):
		return
	get_viewport().set_input_as_handled()
	if not visible:
		open()
	elif not _settings_panel.visible:
		close()


func _on_settings_pressed() -> void:
	_menu.hide()
	_settings_panel.open()


func _on_settings_closed() -> void:
	_menu.show()
	_settings_button.grab_focus()


func _on_title_pressed() -> void:
	get_tree().paused = false
	SceneRouter.go_to(DataPaths.TITLE_SCENE)
