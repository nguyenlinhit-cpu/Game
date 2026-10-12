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
		var cycle := Button.new()
		cycle.text = tr("PAUSE_NEXT_TEST_TEAM")
		cycle.custom_minimum_size = Vector2(0.0, 72.0)
		cycle.pressed.connect(_cycle_test_team)
		_menu.add_child(cycle)
		_menu.move_child(cycle, _title_button.get_index())


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


## Debug: lần lượt để 1 trong 5 nhân vật ngồi ngoài (nhân vật chính luôn có mặt).
func _cycle_test_team() -> void:
	var owned := GameState.owned_characters
	var outside := owned.filter(func(id: StringName) -> bool: return not GameState.team.has(id))
	var next_out_index := 1
	if not outside.is_empty():
		next_out_index = (owned.find(outside[0]) % (owned.size() - 1)) + 1
	var team: Array[StringName] = []
	for i in owned.size():
		if i != next_out_index and team.size() < GameConfig.MAX_TEAM_SIZE:
			team.append(owned[i])
	var map := get_tree().current_scene as OverworldMap
	if map:
		GameState.set_map_player(map.scene_file_path, map.player.global_position, map.player.facing)
	GameState.set_team(team)
	GameState.leader_index = 0
	close()
	SceneRouter.go_to(GameState.current_map_scene)


func _on_title_pressed() -> void:
	get_tree().paused = false
	SceneRouter.go_to(DataPaths.TITLE_SCENE)
