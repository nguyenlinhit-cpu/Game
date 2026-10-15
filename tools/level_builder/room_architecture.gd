class_name RoomArchitecture
extends RefCounted
## Distinct spatial plans, indexed by room number, expressed in courtyard coordinates.
## Courtyard exits remain connected, with a ring route around furnace cores. Bays change the route
## and usable floor, rather than merely changing props or stretching a shared picture.

const PLANS := [
	{"name": "entry_bay", "width": 19, "blocks": [Rect2(0, 0, 0.28, 0.25)]},
	{"name": "four_wings", "width": 29, "blocks": [Rect2(0, 0, 0.22, 0.22), Rect2(0.78, 0, 0.22, 0.22), Rect2(0, 0.78, 0.22, 0.22), Rect2(0.78, 0.78, 0.22, 0.22)]},
	{"name": "storage_wings", "width": 21, "blocks": [Rect2(0, 0.12, 0.22, 0.28), Rect2(0.78, 0.6, 0.22, 0.28)]},
	{"name": "diagonal_bays", "width": 27, "blocks": [Rect2(0, 0, 0.32, 0.3), Rect2(0.7, 0.66, 0.3, 0.34)]},
	{"name": "twin_partitions", "width": 29, "blocks": [Rect2(0.18, 0, 0.16, 0.34), Rect2(0.66, 0, 0.16, 0.34)]},
	{"name": "archive_gallery", "width": 31, "blocks": [Rect2(0, 0.06, 0.16, 0.32), Rect2(0.84, 0.62, 0.16, 0.32)]},
	{"name": "stepped_store", "width": 25, "blocks": [Rect2(0, 0.64, 0.32, 0.36), Rect2(0.8, 0, 0.2, 0.22)]},
	{"name": "staggered_wings", "width": 29, "blocks": [Rect2(0.08, 0, 0.26, 0.3), Rect2(0.68, 0.7, 0.24, 0.3)]},
	{"name": "octagonal_court", "width": 27, "clip": 0.28, "blocks": []},
	{"name": "double_nook", "width": 23, "blocks": [Rect2(0, 0, 0.3, 0.2), Rect2(0.7, 0, 0.3, 0.2)]},
	{"name": "terraced_hall", "width": 33, "blocks": [Rect2(0, 0.12, 0.18, 0.25), Rect2(0.82, 0.63, 0.18, 0.25)]},
	{"name": "summit_arena", "width": 35, "clip": 0.20, "blocks": [Rect2(0.1, 0, 0.2, 0.16), Rect2(0.7, 0, 0.2, 0.16)]},
]

static func configure(zone: StringName, def: Dictionary) -> void:
	var index := String(def["id"]).substr(1).to_int() - 1
	var plan: Dictionary = PLANS[index].duplicate(true)
	if (zone in [&"vault", &"furnace"] and index == 7) or (zone == &"tower" and index in [4, 9]):
		plan["clip"] = 0.28 if index != 9 else 0.32
		plan["blocks"] = []
		plan["name"] = "sentinel_octagon_%d" % index
	if zone in [&"vault", &"furnace"] and index == 8:
		plan["clip"] = 0.0
		plan["blocks"] = [Rect2(0, 0, 0.28, 0.24), Rect2(0.72, 0, 0.28, 0.24)]
		plan["name"] = "cooling_shelter"
	var atlas := load("res://assets/maps/%s/%s_rooms_v2.png" % [zone, zone]) as Texture2D
	assert(atlas != null, "Missing distinct room artwork for %s" % zone)
	var cell_size := atlas.get_size() / Vector2(4, 3)
	var art_index := 11 if zone == &"library" and index == 10 else index
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = Rect2(Vector2(art_index % 4, art_index / 4) * cell_size, cell_size)
	if zone == &"tower":
		var rows := [0.0, 296.0 / 941.0, 600.0 / 941.0, 1.0]
		var row := art_index / 4
		texture.region.position.y = rows[row] * atlas.get_height()
		texture.region.size.y = (rows[row + 1] - rows[row]) * atlas.get_height()
	elif zone == &"library":
		var rows := [0.0, 298.0 / 940.0, 595.0 / 940.0, 1.0]
		var row := art_index / 4
		texture.region.position.y = rows[row] * atlas.get_height()
		texture.region.size.y = (rows[row + 1] - rows[row]) * atlas.get_height()
	elif zone == &"furnace":
		var rows := [0.0, 304.0 / 941.0, 614.0 / 941.0, 1.0]
		var row := art_index / 4
		texture.region.position.y = rows[row] * atlas.get_height()
		texture.region.size.y = (rows[row + 1] - rows[row]) * atlas.get_height()
	elif zone == &"vault":
		var rows := [0.0, 292.0 / 941.0, 592.0 / 941.0, 1.0]
		var row := art_index / 4
		texture.region.position.y = rows[row] * atlas.get_height()
		texture.region.size.y = (rows[row + 1] - rows[row]) * atlas.get_height()
	texture.region = texture.region.grow(-2.0)
	cell_size = texture.get_size()
	texture.filter_clip = true
	var area := Rect2(cell_size * Vector2(0.12, 0.2), cell_size * Vector2(0.76, 0.6))
	def["backdrop"] = atlas.resource_path
	def["backdrop_texture"] = texture
	def["backdrop_play_area"] = area
	def["structure_id"] = StringName("%s_%s_%s" % [zone, def["id"], plan["name"]])
	def["clip_corners"] = plan.get("clip", 0.0)
	var width: int = plan["width"]
	if def["type"] == Room.RoomType.BOSS:
		width = 35
	elif def["type"] == Room.RoomType.REST:
		width = 19
	var height := roundi(width * area.size.y / area.size.x)
	height = height if height % 2 == 1 else height + 1
	if def["type"] == Room.RoomType.PUZZLE:
		width = 27
		height = 15
	def["size"] = Vector2i(width, height)
	var image_blocks: Array = []
	for block: Rect2 in plan["blocks"]:
		var start := area.position + block.position * area.size
		var end := start + block.size * area.size
		image_blocks.append([start.x, start.y, end.x, end.y])
	if index == 2:
		# Narrow stores have shelves/cages along both full side wings, with a real
		# five-tile aisle. These branches only connect north/south in the level graph.
		image_blocks.clear()
		for block in [Rect2(0, 0, 0.38, 1), Rect2(0.62, 0, 0.38, 1)]:
			var start: Vector2 = area.position + block.position * area.size
			var end: Vector2 = start + block.size * area.size
			image_blocks.append([start.x, start.y, end.x, end.y])
	if zone == &"furnace" and index in [7, 9]:
		# The authored engine/core is a real central obstacle with routes on both sides.
		var core := Rect2(0.39, 0.33, 0.24, 0.28) if index == 7 else Rect2(0.38, 0.28, 0.26, 0.34)
		var start := core.position * cell_size
		var end := core.end * cell_size
		image_blocks.append([start.x, start.y, end.x, end.y])
	def["image_blocks"] = image_blocks
