extends Control
## Màn hình tiêu đề: Bắt đầu (hỏi trước khi ghi đè ô tự lưu), Tiếp tục (ô lưu mới nhất), Tải game (chọn ô),
## Cài đặt, Thoát. Phát nhạc tiêu đề.

@onready var _menu: VBoxContainer = %Menu
@onready var _start_button: Button = %StartButton
@onready var _continue_button: Button = %ContinueButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _settings_panel: SettingsPanel = %SettingsPanel


## Nút Tải game và bảng chọn ô (test đọc).
var load_button: Button
var slots_panel: SaveSlotsPanel


func _ready() -> void:
	if BuildCheck.is_requested():
		BuildCheck.run.call_deferred(get_tree())
		return
	_continue_button.disabled = not SaveManager.has_any_save()
	load_button = Button.new()
	load_button.text = tr("TITLE_LOAD")
	load_button.custom_minimum_size = _continue_button.custom_minimum_size
	load_button.disabled = _continue_button.disabled
	load_button.pressed.connect(open_load)
	_menu.add_child(load_button)
	_menu.move_child(load_button, _continue_button.get_index() + 1)
	AudioManager.play_music_id(&"title")
	_start_button.pressed.connect(_on_start_pressed)
	_continue_button.pressed.connect(_on_continue_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_settings_panel.closed.connect(_on_settings_closed)
	_settings_panel.hide()
	(_continue_button if not _continue_button.disabled else _start_button).grab_focus()


func _on_start_pressed() -> void:
	# Game mới ghi vào ô tự lưu khi tạo nhân vật: có save cũ ở ô đó thì hỏi trước (3 ô lưu tay không bị đụng).
	if SaveManager.has_save(SaveManager.AUTOSAVE_SLOT):
		UiKit.confirm(self, tr("TITLE_CONFIRM_NEW_GAME"), start_new_game)
	else:
		start_new_game()


func start_new_game() -> void:
	GameState.reset_new_game()
	SceneRouter.go_to(DataPaths.INTRO_SCENE)


func open_load() -> void:
	slots_panel = SaveSlotsPanel.new()
	slots_panel.setup(SaveSlotsPanel.Mode.LOAD, false)
	slots_panel.loaded.connect(func(_slot: int) -> void: SaveSlotsPanel.go_to_loaded_map(get_tree()))
	add_child(slots_panel)


func _on_continue_pressed() -> void:
	if not SaveManager.load_latest():
		_continue_button.disabled = true
		_start_button.grab_focus()
		return
	SaveSlotsPanel.go_to_loaded_map(get_tree())


func _on_settings_pressed() -> void:
	_menu.hide()
	_settings_panel.open()


func _on_settings_closed() -> void:
	_menu.show()
	_settings_button.grab_focus()


func _on_quit_pressed() -> void:
	get_tree().quit()
