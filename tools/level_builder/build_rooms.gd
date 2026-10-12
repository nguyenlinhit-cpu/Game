extends Node
## Dựng tileset tạm và 4 phòng mẫu (chiến đấu, rương, nghỉ, boss) thành file .tscn.
## Chạy 2 bước (bước 1 tạo ảnh PNG, Godot cần import xong mới dùng được làm texture):
##   godot --headless --path . res://tools/level_builder/build_rooms.tscn
##   godot --headless --path . --import
##   godot --headless --path . res://tools/level_builder/build_rooms.tscn
## Chạy lại sẽ GHI ĐÈ các phòng mẫu. Sau này dựng phòng thủ công: nhân bản 1 file phòng mẫu
## rồi vẽ thêm ô trong editor, giữ nguyên lỗ cửa 3 ô ở giữa mỗi cạnh.

const TILE_PNG: String = "res://assets/tilesets/placeholder_tiles.png"
const ROOM_SCRIPT: String = "res://scenes/overworld/rooms/room.gd"
const ROOMS_DIR: String = "res://scenes/overworld/rooms"
const CHEST_SCENE: String = "res://scenes/overworld/interactables/chest.tscn"
const BOX_SCENE: String = "res://scenes/overworld/interactables/technique_box.tscn"
const REST_SCENE: String = "res://scenes/overworld/interactables/rest_point.tscn"
const ENEMY_SCENE: String = "res://scenes/overworld/overworld_enemy/enemy_group_placeholder.tscn"

## Màu ô tạm, theo thứ tự cột trong ảnh: sàn A, sàn B, tường, sàn hành lang, tường hành lang.
const TILE_COLORS: Array[Color] = [
	Color("2a2d3e"), Color("30344a"), Color("4a3f5c"), Color("252838"), Color("3b3350"),
]

## Cấu hình phòng mẫu. Vị trí vật thể tính bằng ô, so với ô giữa phòng.
var templates: Array[Dictionary] = [
	{
		"file": "room_rest_01.tscn", "id": &"rest_01", "type": Room.RoomType.REST,
		"size": Vector2i(17, 13),
		"entities": [
			{"scene": REST_SCENE, "name": "RestPoint", "tile": Vector2i(0, -1), "props": {"rest_point_id": &"rest_01"}},
			{"scene": BOX_SCENE, "name": "TechniqueBox1", "tile": Vector2i(-5, -3), "props": {"box_id": &"rest_01_box_1"}},
		],
		"spawn": Vector2i(0, 3),
	},
	{
		"file": "room_combat_01.tscn", "id": &"combat_01", "type": Room.RoomType.COMBAT,
		"size": Vector2i(27, 19),
		"entities": [
			{"scene": ENEMY_SCENE, "name": "EnemyGroup1", "tile": Vector2i(-6, -4), "props": {"group_id": &"combat_01_g1", "enemy_count": 3}},
			{"scene": ENEMY_SCENE, "name": "EnemyGroup2", "tile": Vector2i(7, 4), "props": {"group_id": &"combat_01_g2", "enemy_count": 2}},
			{"scene": BOX_SCENE, "name": "TechniqueBox1", "tile": Vector2i(10, -6), "props": {"box_id": &"combat_01_box_1"}},
			{"scene": BOX_SCENE, "name": "TechniqueBox2", "tile": Vector2i(-10, 6), "props": {"box_id": &"combat_01_box_2"}},
		],
	},
	{
		"file": "room_chest_01.tscn", "id": &"chest_01", "type": Room.RoomType.CHEST,
		"size": Vector2i(17, 13),
		"entities": [
			{"scene": CHEST_SCENE, "name": "Chest1", "tile": Vector2i(0, 0), "props": {"chest_id": &"chest_01_a", "tier": Chest.Tier.PRECIOUS}},
		],
	},
	{
		"file": "room_boss_01.tscn", "id": &"boss_01", "type": Room.RoomType.BOSS,
		"size": Vector2i(31, 23),
		"entities": [],
		"markers": {"BossSpawn": Vector2i(0, -4)},
	},
]


func _ready() -> void:
	var exit_code := _run()
	get_tree().quit(exit_code)


func _run() -> int:
	if not FileAccess.file_exists(TILE_PNG):
		_build_tile_png()
		print("Đã tạo %s. Chạy 'godot --headless --path . --import' rồi chạy lại công cụ này." % TILE_PNG)
		return 0
	var texture := load(TILE_PNG) as Texture2D
	if texture == null:
		push_error("Chưa import %s, hãy chạy --import trước." % TILE_PNG)
		return 1
	var tile_set := _build_tile_set(texture)
	if tile_set == null:
		return 1
	for template in templates:
		if not _build_room(template, tile_set):
			return 1
	print("Xong: tileset + %d phòng mẫu." % templates.size())
	return 0


func _build_tile_png() -> void:
	var size := Room.TILE_SIZE
	var image := Image.create(size * TILE_COLORS.size(), size, false, Image.FORMAT_RGBA8)
	for index in TILE_COLORS.size():
		var base := TILE_COLORS[index]
		var is_wall := index == 2 or index == 4
		for y in size:
			for x in size:
				var color := base
				var edge := x < 2 or y < 2 or x >= size - 2 or y >= size - 2
				if is_wall:
					# Gạch: mạch vữa ngang mỗi 16 px, mạch dọc so le; viền trên sáng hơn.
					var row := y / 16
					var mortar := y % 16 == 0 or (x + (8 if row % 2 else 0)) % 32 == 0
					color = base.darkened(0.25) if mortar else base
					if y < 4:
						color = base.lightened(0.18)
				elif edge:
					color = base.lightened(0.06)
				image.set_pixel(index * size + x, y, color)
	DirAccess.make_dir_recursive_absolute(TILE_PNG.get_base_dir())
	image.save_png(TILE_PNG)


func _build_tile_set(texture: Texture2D) -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i.ONE * Room.TILE_SIZE
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, PhysicsLayers.WORLD)
	tile_set.set_physics_layer_collision_mask(0, 0)
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i.ONE * Room.TILE_SIZE
	# Thêm nguồn vào tileset trước để ô mới biết có lớp va chạm.
	tile_set.add_source(source, TileIds.SOURCE_ID)
	var half := Room.TILE_SIZE * 0.5
	var square := PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)])
	for index in TILE_COLORS.size():
		var coords := Vector2i(index, 0)
		source.create_tile(coords)
		if coords in TileIds.SOLID:
			var data := source.get_tile_data(coords, 0)
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, square)
	var err := ResourceSaver.save(tile_set, DataPaths.PLACEHOLDER_TILESET, ResourceSaver.FLAG_CHANGE_PATH)
	if err != OK:
		push_error("Không lưu được tileset (lỗi %d)" % err)
		return null
	return load(DataPaths.PLACEHOLDER_TILESET) as TileSet


func _build_room(template: Dictionary, tile_set: TileSet) -> bool:
	var root := Node2D.new()
	root.set_script(load(ROOM_SCRIPT))
	root.name = String(template["file"]).get_basename().to_pascal_case()
	root.set("room_id", template["id"])
	root.set("room_type", template["type"])
	var size: Vector2i = template["size"]
	root.set("size_tiles", size)

	var floor_layer := _add_layer(root, "Floor", tile_set)
	var wall_layer := _add_layer(root, "Walls", tile_set)
	var half := (size - Vector2i.ONE) / 2
	for y in range(-half.y, half.y + 1):
		for x in range(-half.x, half.x + 1):
			var cell := Vector2i(x, y)
			var on_edge := absi(x) == half.x or absi(y) == half.y
			var in_gap := on_edge and (absi(x) <= Room.DOOR_HALF_WIDTH or absi(y) <= Room.DOOR_HALF_WIDTH) \
					and not (absi(x) == half.x and absi(y) == half.y)
			if on_edge and not in_gap:
				wall_layer.set_cell(cell, TileIds.SOURCE_ID, TileIds.WALL)
			else:
				floor_layer.set_cell(cell, TileIds.SOURCE_ID,
						TileIds.FLOOR_A if (x + y) % 2 == 0 else TileIds.FLOOR_B)

	var entities := Node2D.new()
	entities.name = "Entities"
	root.add_child(entities)
	entities.owner = root
	for entry: Dictionary in template.get("entities", []):
		var node := (load(entry["scene"]) as PackedScene).instantiate() as Node2D
		node.name = entry["name"]
		node.position = _tile_to_local(entry["tile"])
		var props: Dictionary = entry.get("props", {})
		for key: String in props:
			node.set(key, props[key])
		entities.add_child(node)
		node.owner = root

	var markers: Dictionary = template.get("markers", {})
	if template.has("spawn"):
		markers["PlayerSpawn"] = template["spawn"]
	for marker_name: String in markers:
		var marker := Marker2D.new()
		marker.name = marker_name
		marker.position = _tile_to_local(markers[marker_name])
		root.add_child(marker)
		marker.owner = root

	var scene := PackedScene.new()
	var pack_err := scene.pack(root)
	var path := ROOMS_DIR.path_join(template["file"])
	var save_err := ResourceSaver.save(scene, path) if pack_err == OK else pack_err
	root.free()
	if save_err != OK:
		push_error("Không lưu được %s (lỗi %d)" % [path, save_err])
		return false
	print("  + %s (%dx%d)" % [path, size.x, size.y])
	return true


func _add_layer(root: Node2D, layer_name: String, tile_set: TileSet) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.name = layer_name
	layer.tile_set = tile_set
	root.add_child(layer)
	layer.owner = root
	return layer


func _tile_to_local(tile: Vector2i) -> Vector2:
	return Vector2(tile * Room.TILE_SIZE) + Vector2.ONE * Room.TILE_SIZE * 0.5
