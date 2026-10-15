extends Node
## Interactive preview with a separate save directory and direct map/room selection.

const ZONES := [&"library", &"vault", &"furnace", &"tower", &"hub"]
const NAMES := ["Thư Viện", "Kho Băng", "Lò Năng Lượng", "Đỉnh Tháp", "Sảnh"]
var rooms_menu: OptionButton

func _ready() -> void:
	if get_tree().current_scene == self:
		get_tree().root.add_child.call_deferred((get_script() as GDScript).new())
		return
	SaveManager.save_dir = "user://map_preview_saves"
	GameState.reset_new_game()
	GameState.owned_characters = DataPaths.list_character_ids()
	GameState.set_team([&"traveler", &"mira", &"kiri", &"nyx"])
	for id in GameState.owned_characters:
		GameState.character_progress[String(id)] = {"level": 30, "ascension": 2}
	StoryManager.auto_play = true
	for zone in ZONES:
		GameState.set_story_flag(StringName("zone_%s_open" % zone))
	GameState.set_story_flag(&"prologue_done")
	var layer := CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(12, 12)
	layer.add_child(panel)
	var row := HBoxContainer.new()
	panel.add_child(row)
	for i in ZONES.size():
		var button := Button.new()
		button.text = NAMES[i]
		button.pressed.connect(_go.bind(ZONES[i]))
		row.add_child(button)
	rooms_menu = OptionButton.new()
	rooms_menu.item_selected.connect(_select_room)
	row.add_child(rooms_menu)
	var clear := Button.new()
	clear.text = "Dọn quái phòng"
	clear.pressed.connect(func() -> void:
		var map := get_tree().current_scene as OverworldMap
		if map and map.room_manager.current_room:
			map.room_manager.current_room.debug_clear_enemies())
	row.add_child(clear)
	var note := Label.new()
	note.text = "Map trong game • có hành lang"
	row.add_child(note)
	var initial_zone: StringName = &"library"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--zone="):
			var requested_zone := StringName(argument.trim_prefix("--zone="))
			if requested_zone in ZONES:
				initial_zone = requested_zone
	await _go(initial_zone)

func _go(zone: StringName) -> void:
	if SceneRouter.is_busy():
		return
	get_tree().paused = false
	SceneRouter.go_to(StoryManager.get_zone_scene(zone), {}, 0.05)
	await SceneRouter.transition_finished
	rooms_menu.clear()
	var map := get_tree().current_scene as OverworldMap
	if map:
		for room in map.room_manager.rooms:
			rooms_menu.add_item("%s · %s" % [room.room_id, room.area_name])
		if zone != &"hub" and map.room_manager.rooms.size() > 1:
			rooms_menu.select(1)
			_select_room(1)
		print("Map preview ready: ", zone)
		if OS.get_cmdline_user_args().has("--smoke"):
			get_tree().quit()

func _select_room(index: int) -> void:
	var map := get_tree().current_scene as OverworldMap
	if not map or SceneRouter.is_busy():
		return
	var room := map.room_manager.rooms[index]
	map.player.global_position = room.get_spawn_point()
	map.player.velocity = Vector2.ZERO
	map.player.grant_invincibility(3.0)
	map.camera.set_room_limits(room.get_world_rect())
	map.camera.snap_to_target()
	var view := get_viewport().get_visible_rect().size
	var framed_room := room.get_world_rect().grow(192.0)
	map.camera.zoom = Vector2.ONE * minf(view.x / framed_room.size.x, (view.y - 110.0) / framed_room.size.y) * 0.94
	map.camera.set_room_limits(framed_room)
