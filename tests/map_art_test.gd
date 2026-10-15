extends "res://tests/test_base.gd"
## Visual integration + walkable tile graph for every dungeon, including side rooms.
const ZONES := {&"library": 11, &"vault": 10, &"furnace": 10, &"tower": 12}

func _run() -> void:
	phase_name = "Map art"
	SaveManager.save_dir = "user://test_map_art_saves"
	StoryManager.auto_play = true
	GameState.reset_new_game()
	for zone: StringName in ZONES:
		var selection := Array(OS.get_cmdline_user_args()).filter(func(arg: String) -> bool: return arg.begins_with("--zone="))
		if not selection.is_empty() and not selection.has("--zone=%s" % zone):
			continue
		var tiles := ArtLibrary.zone_tileset(zone)
		_check(tiles != null, "%s: tileset riêng" % zone)
		if tiles == null:
			continue
		var atlas := tiles.get_source(0) as TileSetAtlasSource
		var collision_ok := atlas.get_tiles_count() == 8
		for x in 8:
			var cell := Vector2i(x, 0)
			collision_ok = collision_ok and atlas.get_tile_data(cell, 0).get_collision_polygons_count(0) == (1 if cell in TileIds.SOLID else 0)
		_check(collision_ok, "%s: chỉ tường phòng / hành lang có va chạm" % zone)
		SceneRouter.go_to(StoryManager.get_zone_scene(zone), {}, 0.01)
		await SceneRouter.transition_finished
		await _frames(6)
		var map := get_tree().current_scene as OverworldMap
		_check(map.room_manager.rooms.size() == ZONES[zone], "%s: đủ %d phòng" % [zone, ZONES[zone]])
		_check(map.room_manager.connections.size() == ZONES[zone] - 1, "%s: đủ hành lang liên thông" % zone)
		var art_ok := map.corridor_layer.tile_set == tiles and not map.corridor_layer.visible
		for room in map.room_manager.rooms:
			art_ok = art_ok and room.floor_layer.tile_set == tiles and room.wall_layer.tile_set == tiles \
					and room.backdrop != null and room.backdrop_play_area.has_area() \
					and not room.floor_layer.visible and not room.wall_layer.visible \
					and room.get_node_or_null("Backdrop") != null and room.get_node_or_null("Scenery") == null
		_check(art_ok, "%s: mọi phòng dùng cảnh vẽ sẵn, hành lang dùng cầu cùng phong cách Sảnh" % zone)
		var names: Dictionary = {}
		var painting_proportions_ok := true
		for room in map.room_manager.rooms:
			names[room.area_name] = true
			var sprite := room.get_node_or_null("Backdrop") as Sprite2D
			painting_proportions_ok = painting_proportions_ok and sprite != null \
					and maxf(sprite.scale.x, sprite.scale.y) / minf(sprite.scale.x, sprite.scale.y) < 1.3 \
					and room.get_node_or_null("PaintedDetails") != null
		_check(names.size() == ZONES[zone] and not names.has(""), "%s: mỗi khu nhỏ có tên riêng" % zone)
		_check(painting_proportions_ok, "%s: tỉ lệ tranh phù hợp phòng và có tường/cửa theo bố cục thật" % zone)
		_check(map.get_node_or_null("CorridorScenery") != null, "%s: hành lang có trang trí kiến trúc" % zone)
		var pictures: Dictionary = {}
		var structures: Dictionary = {}
		var terrain := map.get_node("CorridorScenery") as Node2D
		var layers_ok := terrain.z_index < map.player.z_index
		for room in map.room_manager.rooms:
			var picture := room.backdrop as AtlasTexture
			if picture:
				pictures[picture.region] = true
			structures[hash([room.size_tiles, room.wall_layer.get_used_cells()])] = true
			layers_ok = layers_ok and room.get_node("Backdrop").z_index < terrain.z_index \
					and room.entities.z_index > terrain.z_index
		_check(pictures.size() == ZONES[zone] and structures.size() == ZONES[zone], "%s: từng phòng có tranh và cấu trúc va chạm riêng" % zone)
		_check(layers_ok, "%s: nhân vật và thực thể luôn nằm trên nền phòng/hành lang" % zone)
		_check_walkways(map)
		if OS.get_cmdline_user_args().has("--capture"):
			await _capture(map, zone)
	get_tree().current_scene.queue_free()
	await _frames(2)
	StoryManager.auto_play = false
	GameState.reset_new_game()
	SaveManager.save_dir = "user://saves"
	AudioManager.stop_music(0.0)
	await _seconds(0.1)
	_finish()

func _check_walkways(map: OverworldMap) -> void:
	var walkable: Dictionary = {}
	var blocked: Dictionary = {}
	for cell in map.corridor_layer.get_used_cells():
		if map.corridor_layer.get_cell_atlas_coords(cell) == TileIds.CORRIDOR_FLOOR:
			walkable[cell] = true
	for room in map.room_manager.rooms:
		for cell in room.floor_layer.get_used_cells():
			walkable[cell + room.get_center_world_tile()] = true
		for cell in room.wall_layer.get_used_cells():
			blocked[cell + room.get_center_world_tile()] = true
	for cell: Vector2i in blocked:
		walkable.erase(cell)
	var first := map.room_manager.get_room(map.start_room_id)
	var start := Vector2i((first.get_spawn_point() / Room.TILE_SIZE).floor())
	var reached: Dictionary = {start: true}
	var queue: Array[Vector2i] = [start]
	var index := 0
	while index < queue.size():
		var cell := queue[index]
		index += 1
		for step: Vector2i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
			var next := cell + step
			if walkable.has(next) and not reached.has(next):
				reached[next] = true
				queue.append(next)
	var rooms_ok := true
	var entities_ok := true
	for room in map.room_manager.rooms:
		rooms_ok = rooms_ok and reached.has(Vector2i((room.get_spawn_point() / Room.TILE_SIZE).floor()))
		for node in room.entities.get_children():
			if not (node is Chest or node is TechniqueBox or node is OverworldEnemy or node is RestPoint or node is Npc or node is StoryItem):
				continue
			var cell := Vector2i((node.global_position / Room.TILE_SIZE).floor())
			if not reached.has(cell):
				print("  Unreachable: ", room.room_id, "/", node.name, " at ", cell)
			entities_ok = entities_ok and reached.has(cell)
	_check(rooms_ok, "%s: đường đi bằng ô gạch tới mọi phòng, kể cả boss" % map.zone)
	_check(entities_ok, "%s: quái, rương, hộp, NPC, điểm nghỉ và vật nhiệm vụ nằm trên sàn tới được" % map.zone)

func _capture(map: OverworldMap, zone: StringName) -> void:
	map.player.input_enabled = false
	map.hud.visible = false
	map.camera.set_physics_process(false)
	map.camera.position_smoothing_enabled = false
	map.camera.clear_limits()
	var bounds := map.room_manager.rooms[0].get_world_rect()
	for room in map.room_manager.rooms:
		bounds = bounds.merge(room.get_world_rect())
	var scale_value := minf(get_viewport().get_visible_rect().size.x / bounds.size.x,
			get_viewport().get_visible_rect().size.y / bounds.size.y) * 0.94
	map.camera.zoom = Vector2.ONE * scale_value
	map.camera.global_position = bounds.get_center()
	await _frames(4)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/tmp/map_%s_overview.png" % zone)
	map.camera.zoom = Vector2.ONE * 0.8
	map.camera.global_position = map.room_manager.rooms[1].get_center_world()
	await _frames(4)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/tmp/map_%s_room.png" % zone)
	map.player.grant_invincibility(600.0)
	for room in map.room_manager.rooms:
		map.player.global_position = room.get_spawn_point()
		map.player.velocity = Vector2.ZERO
		var frame := room.get_world_rect().grow(192)
		var view := get_viewport().get_visible_rect().size
		map.camera.zoom = Vector2.ONE * minf(view.x / frame.size.x, view.y / frame.size.y) * 0.96
		map.camera.global_position = frame.get_center()
		await _frames(2)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/tmp/map_%s_%s.png" % [zone, room.room_id])
	var directions: Dictionary = {}
	for connection in map.room_manager.connections:
		var a: Room = connection[0]
		var b: Room = connection[1]
		var direction := "horizontal" if a.grid_cell.y == b.grid_cell.y else "vertical"
		if directions.has(direction):
			continue
		directions[direction] = true
		map.player.global_position = (a.get_center_world() + b.get_center_world()) * 0.5
		map.camera.zoom = Vector2.ONE
		map.camera.global_position = map.player.global_position
		await _frames(3)
		await RenderingServer.frame_post_draw
		var with_player := get_viewport().get_texture().get_image()
		with_player.save_png("/tmp/map_%s_corridor_%s.png" % [zone, direction])
		map.player.visible = false
		await _frames(2)
		await RenderingServer.frame_post_draw
		var without_player := get_viewport().get_texture().get_image()
		map.player.visible = true
		var changed := 0
		var middle := with_player.get_size() / 2
		for y in range(maxi(0, middle.y - 100), mini(with_player.get_height(), middle.y + 100)):
			for x in range(maxi(0, middle.x - 100), mini(with_player.get_width(), middle.x + 100)):
				if with_player.get_pixel(x, y) != without_player.get_pixel(x, y):
					changed += 1
		_check(changed > 50, "%s: nhân vật hiện thật trên hành lang %s (%d pixel)" % [zone, direction, changed])
