extends Node
## Dựng bản đồ Pháo Đài Vọng Tinh (Phase 12): Sảnh Trung Tâm + 4 khu, mỗi khu một scene OverworldMap trong
## scenes/overworld/world/<khu>.tscn. Bố cục phòng khai báo trong LAYOUTS bên dưới (ô lưới, loại phòng, nối,
## cổng nguyên tố trên cửa, nội dung); số trận / rương / Hộp Bí Kỹ lấy đúng theo data/zones/<khu>.tres.
## Chạy:  godot --headless --path . res://tools/level_builder/build_world.tscn
## Ghi đè các scene cũ. Sau khi dựng có thể mở scene trong editor để chỉnh tay.

const WORLD_DIR: String = "res://scenes/overworld/world"
const ROOM_SCRIPT: String = "res://scenes/overworld/rooms/room.gd"
const MAP_SCRIPT: String = "res://scenes/overworld/map/overworld_map.gd"
const MANAGER_SCRIPT: String = "res://scenes/overworld/map/room_manager.gd"
const CAMERA_SCRIPT: String = "res://scenes/overworld/map/camera_rig.gd"
const PLAYER_SCENE: String = "res://scenes/overworld/player/player.tscn"
const HUD_SCENE: String = "res://scenes/ui/hud/overworld_hud.tscn"
const CHEST_SCENE: String = "res://scenes/overworld/interactables/chest.tscn"
const BOX_SCENE: String = "res://scenes/overworld/interactables/technique_box.tscn"
const REST_SCENE: String = "res://scenes/overworld/interactables/rest_point.tscn"
const OBSTACLE_SCENE: String = "res://scenes/overworld/interactables/elemental_obstacle.tscn"
const ENEMY_SCENE: String = "res://scenes/overworld/overworld_enemy/overworld_enemy.tscn"
const NPC_SCRIPT: String = "res://scenes/overworld/interactables/npc.gd"
const STATION_SCRIPT: String = "res://scenes/overworld/interactables/station.gd"
const TRIGGER_SCRIPT: String = "res://scenes/overworld/interactables/story_trigger.gd"
const ITEM_SCRIPT: String = "res://scenes/overworld/interactables/story_item.gd"
const GATE_SCRIPT: String = "res://scenes/overworld/interactables/story_gate.gd"
const TUTORIAL_ENCOUNTER: String = "res://data/encounters/prologue_tutorial.tres"

const T := Room.RoomType
const K := ElementalObstacle.Kind
const N := Room.Side.NORTH
const E := Room.Side.EAST
const S := Room.Side.SOUTH
const W := Room.Side.WEST

## Kích thước phòng theo loại (luôn lẻ).
const SIZES: Dictionary = {
	T.REST: Vector2i(17, 13), T.COMBAT: Vector2i(27, 19), T.CHEST: Vector2i(17, 13), T.PUZZLE: Vector2i(27, 15),
	T.ELITE: Vector2i(23, 17), T.BOSS: Vector2i(31, 23), T.HALL: Vector2i(17, 13),
}
## Chỗ đặt nội dung tự động theo loại phòng (ô, so với ô giữa).
const ENEMY_SLOTS: Dictionary = {
	T.COMBAT: [Vector2i(-6, -4), Vector2i(6, -4), Vector2i(0, 4), Vector2i(-8, 4), Vector2i(8, 4)],
	T.ELITE: [Vector2i(0, -2), Vector2i(-6, 4), Vector2i(6, 4)],
	T.BOSS: [Vector2i(0, -4)],
	T.REST: [], T.CHEST: [], T.PUZZLE: [], T.HALL: [Vector2i(3, 0)],
}
const CHEST_SLOTS: Dictionary = {
	T.COMBAT: [Vector2i(11, -7), Vector2i(-11, -7)], T.ELITE: [Vector2i(8, -6), Vector2i(-8, -6), Vector2i(0, -6)],
	T.CHEST: [Vector2i(-3, 0), Vector2i(3, 0), Vector2i(0, -3)], T.REST: [Vector2i(5, -3)], T.BOSS: [Vector2i(10, -8)],
	T.PUZZLE: [], T.HALL: [],
}
const BOX_SLOTS: Dictionary = {
	T.COMBAT: Vector2i(-11, 7), T.ELITE: Vector2i(-9, 6), T.CHEST: Vector2i(-5, 3), T.REST: Vector2i(-5, -3),
	T.PUZZLE: Vector2i(0, 0), T.BOSS: Vector2i(-12, 8), T.HALL: Vector2i(-5, 3),
}
## Cột của 4 hốc giải đố (mỗi hốc rộng 2 ô) trong phòng giải đố 27×15.
const NICHE_XS: Array[int] = [-9, -4, 2, 7]
const ZONE_TINTS: Dictionary = {
	&"hub": Color(1.0, 0.96, 0.88), &"library": Color(0.85, 0.85, 1.1), &"vault": Color(0.8, 1.0, 1.15),
	&"furnace": Color(1.15, 0.88, 0.8), &"tower": Color(1.08, 1.02, 0.85),
}

## Bố cục. Mỗi phòng: id, ô lưới, loại, và nội dung:
##   "enc": [chỉ số trận trong ZoneData...] · "chests": [bậc...] · "box": true · "niches": [Kind × 4] (phòng giải đố)
##   "npc"/"item"/"trigger"/"station": xem _add_story_entities · "spawn": true (điểm xuất hiện) · "rest": true
## edges: [phòng A, phòng B, (cổng nguyên tố đặt ở cửa phía phòng B, tùy chọn)]
var LAYOUTS: Dictionary = {
	&"library": {
		"start": &"L01",
		"rooms": [
			{"id": &"L01", "cell": Vector2i(0, 0), "type": T.REST, "box": true, "spawn": true},
			{"id": &"L02", "cell": Vector2i(1, 0), "type": T.COMBAT, "enc": [0, 0, 1], "chests": [0], "box": true},
			{"id": &"L03", "cell": Vector2i(1, -1), "type": T.CHEST, "chests": [1, 1], "box": true},
			{"id": &"L04", "cell": Vector2i(2, 0), "type": T.COMBAT, "enc": [1, 2, 2], "chests": [0], "box": true,
				"npc": {"id": &"kiri", "name": "NpcKiri", "tile": Vector2i(0, 6), "hide_if": ["kiri_joined"]}},
			{"id": &"L05", "cell": Vector2i(2, 1), "type": T.PUZZLE, "niches": [K.FIRE_WALL, K.VINES, K.FOG, K.RUSTED_GATE], "box": true},
			{"id": &"L06", "cell": Vector2i(3, 0), "type": T.COMBAT, "enc": [3, 3, 4], "chests": [0], "box": true},
			{"id": &"L07", "cell": Vector2i(3, -1), "type": T.CHEST, "chests": [1, 1, 0],
				"item": {"id": &"sq1_diary", "name": "StoryItemDiary", "tile": Vector2i(0, 3), "show_if": ["sq1_started"], "hide_if": ["sq1_item"]}},
			{"id": &"L08", "cell": Vector2i(4, 0), "type": T.COMBAT, "enc": [4, 5, 5], "chests": [0], "box": true},
			{"id": &"L09", "cell": Vector2i(4, 1), "type": T.ELITE, "enc": [7, 6, 6], "chests": [0]},
			{"id": &"L10", "cell": Vector2i(5, 0), "type": T.REST, "box": true, "trigger": &"library_map"},
			{"id": &"L11", "cell": Vector2i(6, 0), "type": T.BOSS, "enc": [8], "trigger": &"library_boss"},
		],
		"edges": [[&"L01", &"L02"], [&"L02", &"L03"], [&"L02", &"L04", K.FIRE_WALL], [&"L04", &"L05"],
			[&"L04", &"L06", K.VINES], [&"L06", &"L07", K.HIDDEN_WALL], [&"L06", &"L08"], [&"L08", &"L09"],
			[&"L08", &"L10"], [&"L10", &"L11"]],
	},
	&"vault": {
		"start": &"V01",
		"rooms": [
			{"id": &"V01", "cell": Vector2i(0, 0), "type": T.REST, "box": true, "spawn": true},
			{"id": &"V02", "cell": Vector2i(1, 0), "type": T.COMBAT, "enc": [0, 0, 1], "chests": [0], "box": true},
			{"id": &"V03", "cell": Vector2i(1, 1), "type": T.CHEST, "chests": [1, 1, 0], "box": true},
			{"id": &"V04", "cell": Vector2i(2, 0), "type": T.COMBAT, "enc": [1, 2, 2], "chests": [0], "box": true,
				"npc": {"id": &"garren", "name": "NpcGarren", "tile": Vector2i(0, 6), "frozen": true, "hide_if": ["garren_joined"]}},
			{"id": &"V05", "cell": Vector2i(3, 0), "type": T.COMBAT, "enc": [3, 3, 4], "chests": [0], "box": true},
			{"id": &"V06", "cell": Vector2i(3, -1), "type": T.PUZZLE, "niches": [K.CHASM, K.FIRE_WALL, K.FOG, K.RUSTED_GATE], "box": true},
			{"id": &"V07", "cell": Vector2i(4, 0), "type": T.COMBAT, "enc": [4, 5, 5], "chests": [0], "box": true},
			{"id": &"V08", "cell": Vector2i(4, 1), "type": T.ELITE, "enc": [6], "chests": [1, 1]},
			{"id": &"V09", "cell": Vector2i(5, 0), "type": T.REST, "chests": [0], "box": true},
			{"id": &"V10", "cell": Vector2i(6, 0), "type": T.BOSS, "enc": [7], "trigger": &"vault_boss"},
		],
		"edges": [[&"V01", &"V02"], [&"V02", &"V03", K.VINES], [&"V02", &"V04"], [&"V04", &"V05", K.CHASM],
			[&"V05", &"V06"], [&"V05", &"V07"], [&"V07", &"V08"], [&"V07", &"V09"], [&"V09", &"V10"]],
	},
	&"furnace": {
		"start": &"F01",
		"rooms": [
			{"id": &"F01", "cell": Vector2i(0, 0), "type": T.REST, "box": true, "spawn": true},
			{"id": &"F02", "cell": Vector2i(1, 0), "type": T.COMBAT, "enc": [0, 0, 1], "chests": [0], "box": true},
			{"id": &"F03", "cell": Vector2i(1, -1), "type": T.CHEST, "chests": [1, 1, 0], "box": true},
			{"id": &"F04", "cell": Vector2i(2, 0), "type": T.COMBAT, "enc": [1, 2, 2], "chests": [0], "box": true,
				"npc": {"id": &"nyx", "name": "NpcNyx", "tile": Vector2i(0, 6), "hide_if": ["nyx_joined"]}},
			{"id": &"F05", "cell": Vector2i(3, 0), "type": T.COMBAT, "enc": [3, 3, 4], "chests": [0], "box": true},
			{"id": &"F06", "cell": Vector2i(3, -1), "type": T.PUZZLE, "niches": [K.MACHINE_DOOR, K.CHASM, K.FOG, K.RUSTED_GATE], "box": true},
			{"id": &"F07", "cell": Vector2i(4, 0), "type": T.COMBAT, "enc": [4, 5, 5], "chests": [0], "box": true},
			{"id": &"F08", "cell": Vector2i(4, 1), "type": T.ELITE, "enc": [6], "chests": [1, 1],
				"item": {"id": &"sq2_core", "name": "StoryItemCore", "tile": Vector2i(0, 5), "show_if": ["sq2_started"], "hide_if": ["sq2_item"]}},
			{"id": &"F09", "cell": Vector2i(5, 0), "type": T.REST, "chests": [0], "box": true},
			{"id": &"F10", "cell": Vector2i(6, 0), "type": T.BOSS, "enc": [7], "trigger": &"furnace_boss"},
		],
		"edges": [[&"F01", &"F02"], [&"F02", &"F03", K.CHASM], [&"F02", &"F04"], [&"F04", &"F05", K.MACHINE_DOOR],
			[&"F05", &"F06"], [&"F05", &"F07"], [&"F07", &"F08"], [&"F07", &"F09"], [&"F09", &"F10"]],
	},
	&"tower": {
		"start": &"T01",
		"rooms": [
			{"id": &"T01", "cell": Vector2i(0, 0), "type": T.REST, "box": true, "spawn": true},
			{"id": &"T02", "cell": Vector2i(1, 0), "type": T.COMBAT, "enc": [0, 0, 1], "chests": [0], "box": true},
			{"id": &"T03", "cell": Vector2i(1, -1), "type": T.CHEST, "chests": [1, 1, 0], "box": true},
			{"id": &"T04", "cell": Vector2i(2, 0), "type": T.COMBAT, "enc": [1, 2, 2], "chests": [0], "box": true},
			{"id": &"T05", "cell": Vector2i(2, 1), "type": T.ELITE, "enc": [6], "chests": [0]},
			{"id": &"T06", "cell": Vector2i(3, 1), "type": T.PUZZLE, "niches": [K.VINES, K.HIDDEN_WALL, K.FOG, K.RUSTED_GATE], "box": true},
			{"id": &"T07", "cell": Vector2i(3, 0), "type": T.COMBAT, "enc": [3, 3, 4], "chests": [0], "box": true},
			{"id": &"T08", "cell": Vector2i(3, -1), "type": T.ELITE, "enc": [7], "chests": [1, 1]},
			{"id": &"T09", "cell": Vector2i(4, 0), "type": T.COMBAT, "enc": [4, 5, 5], "chests": [0], "box": true},
			{"id": &"T10", "cell": Vector2i(4, 1), "type": T.ELITE, "enc": [8]},
			{"id": &"T11", "cell": Vector2i(5, 0), "type": T.REST, "box": true, "trigger": &"tower_summit"},
			{"id": &"T12", "cell": Vector2i(6, 0), "type": T.BOSS, "enc": [9], "trigger": &"tower_boss"},
		],
		"edges": [[&"T01", &"T02"], [&"T02", &"T03", K.FIRE_WALL], [&"T02", &"T04", K.MACHINE_DOOR], [&"T04", &"T05"],
			[&"T05", &"T06"], [&"T04", &"T07", K.CHASM], [&"T07", &"T08"], [&"T07", &"T09"], [&"T09", &"T10"],
			[&"T09", &"T11"], [&"T11", &"T12"]],
	},
	&"hub": {
		"start": &"H04",
		"rooms": [
			{"id": &"H01", "cell": Vector2i(0, 0), "type": T.HALL, "size": Vector2i(31, 23), "rest_tile": Vector2i(0, 1),
				"npcs": [
					{"id": &"orwen", "name": "NpcOrwen", "tile": Vector2i(0, -6)},
					{"id": &"lio", "name": "NpcLio", "tile": Vector2i(-6, -7)},
					{"id": &"bram", "name": "NpcBram", "tile": Vector2i(9, 6)},
				],
				"stations": [
					{"kind": Station.Kind.GACHA, "name": "StationGacha", "tile": Vector2i(-10, -2)},
					{"kind": Station.Kind.QUESTS, "name": "StationQuests", "tile": Vector2i(-10, 4)},
					{"kind": Station.Kind.UPGRADE, "name": "StationUpgrade", "tile": Vector2i(10, -2)},
					{"kind": Station.Kind.TEAM, "name": "StationTeam", "tile": Vector2i(6, -6)},
					{"kind": Station.Kind.SHOP, "name": "StationShop", "tile": Vector2i(12, 6)},
				]},
			{"id": &"H02", "cell": Vector2i(1, 0), "type": T.COMBAT, "size": Vector2i(23, 17), "tutorial": true,
				"trigger": &"hub_training", "trigger_tile": Vector2i(-7, 0), "trigger_size": Vector2i(3, 9)},
			{"id": &"H03", "cell": Vector2i(-1, 0), "type": T.HALL,
				"stations": [{"kind": Station.Kind.GATE, "name": "StationGate", "tile": Vector2i(0, -1)}]},
			{"id": &"H04", "cell": Vector2i(0, 1), "type": T.HALL, "spawn": true},
		],
		"edges": [[&"H01", &"H02"], [&"H01", &"H03"], [&"H01", &"H04"]],
	},
}

var _tile_set: TileSet


func _ready() -> void:
	get_tree().quit(_run())


func _run() -> int:
	_tile_set = load(DataPaths.PLACEHOLDER_TILESET) as TileSet
	DirAccess.make_dir_recursive_absolute(WORLD_DIR)
	for zone: StringName in LAYOUTS:
		if not _build_map(zone, LAYOUTS[zone]):
			return 1
	print("Xong: %d bản đồ." % LAYOUTS.size())
	return 0


func _zone_data(zone: StringName) -> ZoneData:
	var path := "res://data/zones/%s.tres" % zone
	return load(path) as ZoneData if ResourceLoader.exists(path) else null


func _build_map(zone: StringName, layout: Dictionary) -> bool:
	var data := _zone_data(zone)
	var root := Node2D.new()
	root.set_script(load(MAP_SCRIPT))
	root.name = String(zone).to_pascal_case() + "Map"
	root.set("start_room_id", layout["start"])
	root.set("zone", zone)
	var corridors := TileMapLayer.new()
	corridors.name = "Corridors"
	corridors.tile_set = _tile_set
	corridors.modulate = ZONE_TINTS.get(zone, Color.WHITE)
	_own(root, root, corridors, true)
	var rooms_root := Node2D.new()
	rooms_root.name = "Rooms"
	_own(root, root, rooms_root, true)

	# Cửa: mỗi phòng chỉ mở phía có cạnh nối; cổng nguyên tố đặt ở cửa phía phòng B.
	var by_id: Dictionary = {}
	for room_def: Dictionary in layout["rooms"]:
		by_id[room_def["id"]] = room_def
		room_def["doors"] = 0
		room_def["gates"] = []
	for edge: Array in layout["edges"]:
		var a: Dictionary = by_id[edge[0]]
		var b: Dictionary = by_id[edge[1]]
		var side := _side_between(a["cell"], b["cell"])
		if side == 0:
			push_error("%s: %s và %s không kề nhau" % [zone, edge[0], edge[1]])
			return false
		a["doors"] = int(a["doors"]) | side
		b["doors"] = int(b["doors"]) | Room.opposite(side)
		if edge.size() > 2:
			(b["gates"] as Array).append([Room.opposite(side), edge[2]])

	var counters := {"chest": 0, "box": 0}
	for room_def: Dictionary in layout["rooms"]:
		var room := _build_room(root, rooms_root, zone, room_def, data, counters)
		if room == null:
			return false

	for path: String in [PLAYER_SCENE]:
		var player := (load(path) as PackedScene).instantiate()
		player.name = "Player"
		_own(root, root, player, true)
	var manager := Node.new()
	manager.set_script(load(MANAGER_SCRIPT))
	manager.name = "RoomManager"
	_own(root, root, manager, true)
	root.move_child(manager, 2)
	var camera := Camera2D.new()
	camera.set_script(load(CAMERA_SCRIPT))
	camera.name = "CameraRig"
	_own(root, root, camera, true)
	camera.set("target_path", NodePath("../Player"))
	var hud := (load(HUD_SCENE) as PackedScene).instantiate()
	hud.name = "Hud"
	_own(root, root, hud, true)

	var scene := PackedScene.new()
	var err := scene.pack(root)
	var path := WORLD_DIR.path_join("%s.tscn" % zone)
	if err == OK:
		err = ResourceSaver.save(scene, path)
	root.free()
	if err != OK:
		push_error("Không lưu được %s (lỗi %d)" % [path, err])
		return false
	print("  + %s (%d phòng, %d rương, %d Hộp Bí Kỹ)" % [path, (layout["rooms"] as Array).size(), counters["chest"], counters["box"]])
	return true


func _side_between(a: Vector2i, b: Vector2i) -> int:
	match b - a:
		Vector2i.UP: return N
		Vector2i.DOWN: return S
		Vector2i.RIGHT: return E
		Vector2i.LEFT: return W
	return 0


func _build_room(map_root: Node, rooms_root: Node, zone: StringName, def: Dictionary, data: ZoneData,
		counters: Dictionary) -> Room:
	var type: int = def["type"]
	var size: Vector2i = def.get("size", SIZES[type])
	var root := Node2D.new()
	root.set_script(load(ROOM_SCRIPT))
	root.name = "Room" + String(def["id"])
	root.set("room_id", def["id"])
	root.set("room_type", type)
	root.set("size_tiles", size)
	root.set("grid_cell", def["cell"])
	root.set("door_sides", def["doors"])
	root.position = Vector2(Vector2i(def["cell"]) * Room.CELL_TILES * Room.TILE_SIZE)
	_own(map_root, rooms_root, root)

	var half := (size - Vector2i.ONE) / 2
	var extra_walls: Array[Vector2i] = []
	var niche_south := not (int(def["doors"]) & S)
	if type == T.PUZZLE:
		extra_walls = _niche_walls(half, niche_south)
	var floor_layer := _layer(map_root, root, "Floor", zone)
	var wall_layer := _layer(map_root, root, "Walls", zone)
	for y in range(-half.y, half.y + 1):
		for x in range(-half.x, half.x + 1):
			var cell := Vector2i(x, y)
			var on_edge := absi(x) == half.x or absi(y) == half.y
			var in_gap := on_edge and (absi(x) <= Room.DOOR_HALF_WIDTH or absi(y) <= Room.DOOR_HALF_WIDTH) \
					and not (absi(x) == half.x and absi(y) == half.y)
			if (on_edge and not in_gap) or extra_walls.has(cell):
				wall_layer.set_cell(cell, TileIds.SOURCE_ID, TileIds.WALL)
			else:
				floor_layer.set_cell(cell, TileIds.SOURCE_ID, TileIds.FLOOR_A if (x + y) % 2 == 0 else TileIds.FLOOR_B)

	var entities := Node2D.new()
	entities.name = "Entities"
	_own(map_root, root, entities)

	# Quái theo chỉ số trận trong ZoneData.
	var slots: Array = ENEMY_SLOTS[type]
	var enc_list: Array = def.get("enc", [])
	for i in enc_list.size():
		var encounter: EncounterData = data.encounters[enc_list[i]]
		var tile: Vector2i = slots[i]
		var enemy := _instance(map_root, entities, ENEMY_SCENE, "Enemy%d" % (i + 1), tile)
		enemy.set("encounter", encounter)
		if encounter.kind == EncounterData.Kind.NORMAL:
			enemy.set("patrol_points", PackedVector2Array([Vector2(-160, 0), Vector2(160, 0)]))
	if def.get("tutorial", false):
		var enemy := _instance(map_root, entities, ENEMY_SCENE, "TutorialEnemy", slots[0])
		enemy.set("encounter", load(TUTORIAL_ENCOUNTER))
		_gate(map_root, enemy, ["prologue_awake"], ["prologue_done"])

	# Rương.
	var chest_slots: Array = CHEST_SLOTS[type]
	var chest_list: Array = def.get("chests", [])
	for i in chest_list.size():
		var chest := _instance(map_root, entities, CHEST_SCENE, "Chest%d" % (i + 1), chest_slots[i])
		chest.set("tier", chest_list[i])
		chest.set("chest_id", StringName("%s_%s_chest_%d" % [zone, def["id"], i + 1]))
		counters["chest"] += 1
	if type == T.PUZZLE:
		_add_niches(map_root, entities, zone, def, half, niche_south, counters)

	if def.get("box", false):
		var box := _instance(map_root, entities, BOX_SCENE, "TechniqueBox", BOX_SLOTS[type])
		box.set("box_id", StringName("%s_%s_box" % [zone, def["id"]]))
		counters["box"] += 1
	if type == T.REST or def.has("rest_tile"):
		var rest := _instance(map_root, entities, REST_SCENE, "RestPoint", def.get("rest_tile", Vector2i(0, -1)))
		rest.set("rest_point_id", StringName("%s_%s" % [zone, def["id"]]))
	if type == T.REST or def.get("spawn", false):
		var marker := Marker2D.new()
		marker.name = "PlayerSpawn"
		marker.position = _tile(Vector2i(0, 3) if type != T.HALL else Vector2i(0, 2))
		_own(map_root, root, marker)

	# Cổng nguyên tố ở cửa.
	for gate: Array in def["gates"]:
		_add_door_gate(map_root, entities, half, gate[0], gate[1])

	_add_story_entities(map_root, entities, def, size)
	return root as Room


## Tường hốc giải đố dọc cạnh Nam (hoặc Bắc nếu cửa ở phía Nam): mỗi hốc rộng 2 ô, sâu 2 ô.
func _niche_walls(half: Vector2i, south: bool) -> Array[Vector2i]:
	var walls: Array[Vector2i] = []
	for x in range(-half.x + 1, half.x):
		if NICHE_XS.has(x) or NICHE_XS.has(x - 1):
			continue
		for depth in range(1, 4):
			walls.append(Vector2i(x, (half.y - depth) if south else (-half.y + depth)))
	return walls


func _add_niches(map_root: Node, entities: Node, zone: StringName, def: Dictionary, half: Vector2i, south: bool,
		counters: Dictionary) -> void:
	var kinds: Array = def["niches"]
	var sign := 1 if south else -1
	for i in NICHE_XS.size():
		var x: int = NICHE_XS[i]
		var obstacle := _instance(map_root, entities, OBSTACLE_SCENE, "NicheGate%d" % (i + 1),
				Vector2i(x, sign * (half.y - 3)), Vector2(Room.TILE_SIZE * 0.5, 0.0))
		obstacle.set("kind", kinds[i])
		obstacle.set("size_tiles", Vector2i(2, 1))
		var chest := _instance(map_root, entities, CHEST_SCENE, "NicheChest%d" % (i + 1),
				Vector2i(x, sign * (half.y - 1)), Vector2(Room.TILE_SIZE * 0.5, 0.0))
		chest.set("tier", Chest.Tier.PUZZLE)
		chest.set("chest_id", StringName("%s_%s_niche_%d" % [zone, def["id"], i + 1]))
		counters["chest"] += 1


## Vật cản nguyên tố chắn kín lỗ cửa phía `side` (3 ô).
func _add_door_gate(map_root: Node, entities: Node, half: Vector2i, side: int, kind: int) -> void:
	var tile := Vector2i.ZERO
	var size := Vector2i(3, 1)
	match side:
		N: tile = Vector2i(0, -half.y)
		S: tile = Vector2i(0, half.y)
		E:
			tile = Vector2i(half.x, 0)
			size = Vector2i(1, 3)
		W:
			tile = Vector2i(-half.x, 0)
			size = Vector2i(1, 3)
	var obstacle := _instance(map_root, entities, OBSTACLE_SCENE, "DoorGate%d" % side, tile)
	obstacle.set("kind", kind)
	obstacle.set("size_tiles", size)


func _add_story_entities(map_root: Node, entities: Node, def: Dictionary, size: Vector2i) -> void:
	var npcs: Array = def.get("npcs", [])
	if def.has("npc"):
		npcs.append(def["npc"])
	for npc_def: Dictionary in npcs:
		var npc := _script_node(map_root, entities, Area2D.new(), NPC_SCRIPT, npc_def["name"], npc_def["tile"])
		npc.set("npc_id", npc_def["id"])
		npc.set("frozen", npc_def.get("frozen", false))
		if npc_def.has("hide_if") or npc_def.has("show_if"):
			_gate(map_root, npc, npc_def.get("show_if", []), npc_def.get("hide_if", []))
	for station_def: Dictionary in def.get("stations", []):
		var station := _script_node(map_root, entities, Area2D.new(), STATION_SCRIPT, station_def["name"], station_def["tile"])
		station.set("kind", station_def["kind"])
	if def.has("item"):
		var item_def: Dictionary = def["item"]
		var item := _script_node(map_root, entities, Area2D.new(), ITEM_SCRIPT, item_def["name"], item_def["tile"])
		item.set("trigger_id", item_def["id"])
		_gate(map_root, item, item_def.get("show_if", []), item_def.get("hide_if", []))
	if def.has("trigger"):
		var tile: Vector2i = def.get("trigger_tile", Vector2i.ZERO)
		var trigger := _script_node(map_root, entities, Area2D.new(), TRIGGER_SCRIPT, "StoryTrigger", tile)
		trigger.set("trigger_id", def["trigger"])
		trigger.set("size_tiles", def.get("trigger_size", size - Vector2i(6, 6)))


func _gate(map_root: Node, parent: Node, show_if: Array, hide_if: Array) -> void:
	var gate := Node.new()
	gate.set_script(load(GATE_SCRIPT))
	gate.name = "StoryGate"
	gate.set("show_if", PackedStringArray(show_if))
	gate.set("hide_if", PackedStringArray(hide_if))
	_own(map_root, parent, gate)


func _layer(map_root: Node, room: Node, layer_name: String, zone: StringName) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.name = layer_name
	layer.tile_set = _tile_set
	layer.modulate = ZONE_TINTS.get(zone, Color.WHITE)
	_own(map_root, room, layer)
	return layer


func _instance(map_root: Node, parent: Node, scene_path: String, node_name: String, tile: Vector2i,
		offset := Vector2.ZERO) -> Node2D:
	var node := (load(scene_path) as PackedScene).instantiate() as Node2D
	node.name = node_name
	node.position = _tile(tile) + offset
	_own(map_root, parent, node)
	return node


func _script_node(map_root: Node, parent: Node, node: Node2D, script_path: String, node_name: String,
		tile: Vector2i) -> Node2D:
	node.set_script(load(script_path))
	node.name = node_name
	node.position = _tile(tile)
	_own(map_root, parent, node)
	return node


func _own(map_root: Node, parent: Node, node: Node, unique: bool = false) -> void:
	parent.add_child(node)
	node.owner = map_root
	if unique:
		node.unique_name_in_owner = true


func _tile(tile: Vector2i) -> Vector2:
	return Vector2(tile * Room.TILE_SIZE) + Vector2.ONE * Room.TILE_SIZE * 0.5
