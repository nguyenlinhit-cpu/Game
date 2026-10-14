extends Control
## Phòng thử mọi biến thể bằng màn trận thật, giữ save thử riêng.
## godot --path . res://tools/enemy_preview/enemy_preview.tscn

var _enemies: Array[EnemyData] = []
var _battle: Node
var _enemy_option: OptionButton
var _phase_option: OptionButton
var _selected: int = 0


func _ready() -> void:
	SaveManager.save_dir = "user://enemy_art_preview_saves"
	GameState.reset_new_game()
	GameState.owned_characters = DataPaths.list_character_ids()
	GameState.team_level = 30
	for file: String in DirAccess.get_files_at("res://data/enemies"):
		if file.ends_with(".tres"):
			var data := load("res://data/enemies/" + file) as EnemyData
			if data:
				_enemies.append(data)
	_enemies.sort_custom(func(a: EnemyData, b: EnemyData) -> bool: return String(a.id) < String(b.id))
	var layer := CanvasLayer.new()
	layer.layer = 15
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(22, 105)
	layer.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	row.add_child(UiKit.make_label("Thử toàn bộ %d quái" % _enemies.size(), 24))
	_enemy_option = OptionButton.new()
	_enemy_option.custom_minimum_size = Vector2(340, 48)
	for data in _enemies:
		_enemy_option.add_item(tr(data.name_key))
	row.add_child(_enemy_option)
	_enemy_option.item_selected.connect(_select_enemy)
	_phase_option = OptionButton.new()
	_phase_option.custom_minimum_size = Vector2(180, 48)
	row.add_child(_phase_option)
	_phase_option.item_selected.connect(_select_phase)
	row.add_child(UiKit.make_button("Đánh lại", func() -> void: _select_enemy(_selected), Vector2(150, 48)))
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--enemy="):
			for i in _enemies.size():
				if String(_enemies[i].id) == arg.trim_prefix("--enemy="):
					_selected = i
	_select_enemy(_selected)
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="):
			_select_phase(clampi(int(arg.trim_prefix("--phase=")) - 1, 0, _phase_option.item_count - 1))
	_capture_if_requested()


func _select_enemy(index: int) -> void:
	_selected = index
	_enemy_option.select(index)
	if is_instance_valid(_battle):
		remove_child(_battle)
		_battle.queue_free()
	ArtLibrary.clear_cache()
	var data := _enemies[index]
	var entry := EncounterEnemyEntry.new()
	entry.enemy = data
	entry.level = 20
	entry.count = 1
	var wave := EncounterWave.new()
	wave.entries.append(entry)
	var encounter := EncounterData.new()
	encounter.id = &"enemy_art_preview"
	encounter.kind = EncounterData.Kind.BOSS if data.is_boss() else (
			EncounterData.Kind.ELITE if data.kind == EnemyData.Kind.ELITE else EncounterData.Kind.NORMAL)
	encounter.waves.append(wave)
	SceneRouter.payload = {"encounter": encounter, "sandbox_encounter": "enemy_art_preview",
			"team_override": GameState.get_team_data()}
	_battle = load(DataPaths.BATTLE_SCENE).instantiate()
	add_child(_battle)
	move_child(_battle, 0)
	_phase_option.clear()
	for phase in range(data.phases.size() + 1):
		_phase_option.add_item("Giai đoạn %d" % (phase + 1))
	_phase_option.disabled = data.phases.is_empty()
	print("Enemy preview: ", data.id)


func _select_phase(index: int) -> void:
	if index == 0:
		_select_enemy(_selected)
		return
	var controller: BattleController = _battle.controller
	for unit in controller.enemies:
		if unit.enemy.id == _enemies[_selected].id:
			controller.enter_boss_phase(unit, index)
			break
	_phase_option.select(index)


func _capture_if_requested() -> void:
	var path := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			path = arg.trim_prefix("--capture=")
	if path.is_empty():
		return
	await get_tree().create_timer(2.5).timeout
	await RenderingServer.frame_post_draw
	var error := get_viewport().get_texture().get_image().save_png(path)
	print("Enemy preview screenshot: ", path, " (", error, ")")
	if OS.get_cmdline_user_args().has("--quit-after-capture"):
		get_tree().quit(error)
