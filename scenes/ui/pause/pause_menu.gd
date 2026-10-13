class_name PauseMenu
extends Control
## Menu tạm dừng ngoài map (Esc): Tiếp tục, Nhân vật, Đội hình, Túi đồ, Nhiệm vụ, Ước Nguyện, Cài đặt, Về màn hình tiêu đề.
## Nhân vật / Đội hình / Túi đồ / Nhiệm vụ / Ước Nguyện mở GameMenu (Phase 9–11). Nút Nhiệm vụ có chấm đỏ khi còn thưởng chưa nhận.

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
	var at := _settings_button.get_index()
	for entry: Array in [["MENU_CHARACTERS", GameMenu.Page.CHARACTERS], ["MENU_TEAM", GameMenu.Page.TEAM],
			["MENU_INVENTORY", GameMenu.Page.INVENTORY], ["MENU_QUESTS", GameMenu.Page.QUESTS],
			["MENU_GACHA", GameMenu.Page.GACHA]]:
		var button := Button.new()
		button.text = tr(entry[0])
		button.custom_minimum_size = Vector2(0.0, 72.0)
		button.pressed.connect(open_game_menu.bind(entry[1]))
		_menu.add_child(button)
		_menu.move_child(button, at)
		at += 1
		if entry[1] == GameMenu.Page.QUESTS:
			quest_dot = UiKit.attach_red_dot(button)
	QuestManager.changed.connect(_refresh_quest_dot)
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
		var grant := Button.new()
		grant.text = tr("INV_DEBUG_GRANT")
		grant.custom_minimum_size = Vector2(0.0, 72.0)
		grant.pressed.connect(func() -> void:
			Progression.debug_grant_resources()
			EventBus.toast_requested.emit(tr("TOAST_DEBUG_GRANTED")))
		_menu.add_child(grant)
		_menu.move_child(grant, _title_button.get_index())
	if _menu.get_child_count() > 9:
		# Nhiều nút (bản debug): thu gọn cho vừa màn 1080.
		_menu.add_theme_constant_override("separation", 8)
		for child in _menu.get_children():
			if child is Button:
				(child as Button).custom_minimum_size.y = 62.0


## Chấm đỏ trên nút Nhiệm vụ.
var quest_dot: Control


func _refresh_quest_dot() -> void:
	if quest_dot:
		quest_dot.visible = QuestManager.has_any_claimable()


func open() -> void:
	if SceneRouter.is_busy():
		return
	_refresh_quest_dot()
	show()
	_menu.show()
	get_tree().paused = true
	_resume_button.grab_focus()


func close() -> void:
	hide()
	get_tree().paused = false


var _game_menu: GameMenu


## Mở menu Nhân vật / Đội hình / Túi đồ (game vẫn tạm dừng). `direct` = mở thẳng từ quầy trên map:
## đóng menu thì về luôn map thay vì về menu tạm dừng.
func open_game_menu(page: int = GameMenu.Page.CHARACTERS, direct: bool = false) -> GameMenu:
	if not visible:
		open()
	_menu.hide()
	_game_menu = GameMenu.new()
	add_child(_game_menu)
	_game_menu.show_page(page)
	_game_menu.closed.connect(func() -> void:
		var changed := _game_menu.is_team_changed()
		_game_menu = null
		if changed:
			_reload_map()
		elif direct:
			close()
		else:
			_menu.show())
	return _game_menu


func get_game_menu() -> GameMenu:
	return _game_menu


## Nạp lại map giữ nguyên vị trí (đổi đội hình xong).
func _reload_map() -> void:
	var map := get_tree().current_scene as OverworldMap
	if map:
		GameState.set_map_player(map.scene_file_path, map.player.global_position, map.player.facing)
	close()
	SceneRouter.go_to(GameState.current_map_scene if GameState.current_map_scene != "" else DataPaths.TEST_MAP_SCENE)


func _unhandled_input(event: InputEvent) -> void:
	if _game_menu:
		return
	# Bảng phủ của HUD (quầy hàng, dịch chuyển) đang mở: Esc đóng bảng đó.
	var hud := get_parent() as OverworldHud
	if hud and hud.panel_overlay and (event.is_action_pressed("menu") or event.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()
		hud.close_panel()
		return
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
	GameState.set_team(team)
	GameState.leader_index = 0
	_reload_map()


func _on_title_pressed() -> void:
	get_tree().paused = false
	SceneRouter.go_to(DataPaths.TITLE_SCENE)
