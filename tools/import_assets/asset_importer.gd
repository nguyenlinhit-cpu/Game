class_name AssetImporter
extends RefCounted
## Quét assets/ theo quy tắc mục 12, tạo SpriteFrames / TileSet để game tự nhận (xem ArtLibrary), in và ghi
## danh sách asset còn thiếu vào docs/ASSET_STATUS.md.
##
## Nhận 2 dạng hình hoạt ảnh trong assets/<characters|enemies>/<asset_id>/<map|battle|vfx>/:
##   1. Sprite sheet từ Blender: <mode>_<asset_id>.png + <mode>_<asset_id>.json (tools/blender/render_sprites.py).
##   2. Từng khung: <mode>_<asset_id>_<hành động>[_<hướng>]_<khung>.png, vd. map_ignar_run_se_03.png,
##      battle_ignar_attack_02.png, vfx_ignar_ultimate_07.png (Krita xuất chuỗi PNG).
## Hành động trong trận của boss ở giai đoạn n ≥ 2 thêm "-p<n>", vd. battle_library_warden_idle-p2_00.png.
## Chân dung: portrait/portrait_<asset_id>_<neutral|happy|serious>.png · tranh: splash/splash_<asset_id>.png ·
## tileset: assets/tilesets/<khu>/tiles_<khu>.png (5 ô 64×64 theo hàng ngang như tileset tạm).
## PNG phải được Godot import trước (mở editor, hoặc `godot --headless --path . --import`).

const STATUS_PATH: String = "res://docs/ASSET_STATUS.md"

var report: Dictionary = {"built": [], "missing": [], "warnings": []}
var _req: Dictionary


static func run_all(write_status: bool = true) -> Dictionary:
	var importer := AssetImporter.new()
	return importer.run(write_status)


func run(write_status: bool = true) -> Dictionary:
	_req = ArtLibrary.requirements()
	ArtLibrary.clear_cache()
	for id in DataPaths.list_character_ids():
		var data := DataPaths.load_character(id)
		if data == null:
			continue
		var asset_ids: Array[String] = []
		if id == GameState.PLAYER_CHARACTER_ID:
			for skin in data.skins:
				asset_ids.append("%s_%s" % [id, skin.skin_id])
		else:
			asset_ids.append(String(id))
		for asset_id in asset_ids:
			_import_character(asset_id)
	# NPC chỉ nói chuyện (Orwen, Lio, Bram, Kẻ Nuốt Mảnh Hồn): chỉ cần chân dung.
	var story: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/story/story.json"))
	if story is Dictionary:
		var speakers: Dictionary = story.get("speakers", {})
		for speaker_id: String in speakers:
			if speaker_id == "narrator" or speakers[speaker_id].has("character"):
				continue
			for expression: String in _req["character"]["portrait"]["expressions"]:
				var path := ArtLibrary.CHARACTER_DIR.path_join(speaker_id).path_join(
						"portrait/portrait_%s_%s.png" % [speaker_id, expression])
				if not ResourceLoader.exists(path) and not ResourceLoader.exists(path.get_basename() + ".tres"):
					_missing("NPC %s" % speaker_id, "chân dung %s (1024px) – %s" % [expression, path.trim_prefix("res://")])
	for family in _enemy_families():
		_import_enemy(family["asset_id"], family["kind"], family["phases"])
	for zone: String in _req.get("tileset", {}).get("zones", []):
		_import_tileset(zone)
	ArtLibrary.clear_cache()
	if write_status:
		_write_status()
	return report


# --- Nhân vật ---

func _import_character(asset_id: String) -> void:
	var base := ArtLibrary.CHARACTER_DIR.path_join(asset_id)
	var spec: Dictionary = _req["character"]
	var label := "Nhân vật %s" % asset_id
	var directions: Array = _req["directions"]
	_import_mode(base, asset_id, "map", spec["map"], directions, label)
	_import_mode(base, asset_id, "battle", spec["battle"], [], label)
	var vfx_spec := {"actions": spec["vfx"]["skills"], "loop": [], "frame_size": spec["vfx"]["frame_size"],
			"fps": spec["vfx"].get("fps", _req.get("default_fps", 10))}
	_import_mode(base, asset_id, "vfx", vfx_spec, [], label, true)
	for expression: String in spec["portrait"]["expressions"]:
		var path := base.path_join("portrait/portrait_%s_%s.png" % [asset_id, expression])
		if not ResourceLoader.exists(path) and not ResourceLoader.exists(path.get_basename() + ".tres"):
			_missing(label, "chân dung %s (%dpx) – %s" % [expression, spec["portrait"]["size"], path.trim_prefix("res://")])
	var splash := base.path_join("splash/splash_%s.png" % asset_id)
	if not ResourceLoader.exists(splash):
		_missing(label, "tranh gacha 2048×1152 – %s" % splash.trim_prefix("res://"))


# --- Quái ---

## Một mục mỗi họ quái (biến thể nguyên tố dùng chung hình): { asset_id, kind, phases }.
func _enemy_families() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var seen: Dictionary = {}
	for file in DirAccess.get_files_at("res://data/enemies"):
		var clean := file.trim_suffix(".remap")
		if not clean.ends_with(".tres"):
			continue
		var enemy := load("res://data/enemies/" + clean) as EnemyData
		if enemy == null:
			continue
		var asset_id := String(enemy.id)
		for candidate: String in ArtLibrary.enemy_asset_ids(enemy):
			if DirAccess.dir_exists_absolute(ArtLibrary.ENEMY_DIR.path_join(candidate)):
				asset_id = candidate
				break
		if seen.has(asset_id):
			continue
		seen[asset_id] = true
		result.append({"asset_id": asset_id, "kind": enemy.kind, "phases": enemy.phases.size() + 1})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["asset_id"] < b["asset_id"])
	return result


func _import_enemy(asset_id: String, kind: int, phases: int) -> void:
	var base := ArtLibrary.ENEMY_DIR.path_join(asset_id)
	var spec: Dictionary = _req["enemy"]
	var label := "Quái %s" % asset_id
	var map_spec: Dictionary = spec["map"].duplicate(true)
	if map_spec["frame_size"] is Dictionary:
		map_spec["frame_size"] = int(map_spec["frame_size"][["normal", "elite", "boss"][kind]])
	_import_mode(base, asset_id, "map", map_spec, spec.get("directions", _req["directions"]), label)
	var battle: Dictionary = spec["battle"].duplicate(true)
	battle["frame_size"] = int(spec["battle"]["frame_size"][["normal", "elite", "boss"][kind]])
	if phases > 1:
		var actions: Dictionary = battle["actions"].duplicate()
		for phase in range(2, phases + 1):
			for action: String in spec["battle"]["actions"]:
				actions["%s-p%d" % [action, phase]] = spec["battle"]["actions"][action]
		battle["actions"] = actions
		battle["loop"] = ["idle"] + range(2, phases + 1).map(func(p: int) -> String: return "idle-p%d" % p)
	_import_mode(base, asset_id, "battle", battle, [], label)
	var skills_path := base.path_join("vfx/skills.json")
	if FileAccess.file_exists(skills_path):
		var skills: Variant = JSON.parse_string(FileAccess.get_file_as_string(skills_path))
		if skills is Dictionary:
			var effects: Dictionary = {}
			for skill: String in skills:
				for layer: String in ["", "-cast"]:
					effects[skill + layer] = int(skills[skill].get("effect_frames", 8))
				if skills[skill].get("screen", false):
					effects[skill + "-screen"] = int(skills[skill].get("effect_frames", 8))
			_import_mode(base, asset_id, "vfx", {"actions": effects, "loop": [], "frame_size": 512,
					"fps": 12}, [], label, true)


# --- Hoạt ảnh ---

## Gom khung của một chế độ thành SpriteFrames, lưu ở đường dẫn ArtLibrary.frames_path; ghi phần còn thiếu.
func _import_mode(base: String, asset_id: String, mode: String, spec: Dictionary, directions: Array, label: String,
		optional: bool = false) -> void:
	var dir := base.path_join(mode)
	var frames_by_anim: Dictionary = {}
	var meta := {"anchor": Vector2(0.5, 0.85), "fps": float(spec.get("fps", _req.get("default_fps", 10)))}
	if DirAccess.dir_exists_absolute(dir):
		_collect_sheet(dir, asset_id, mode, frames_by_anim, meta)
		_collect_loose(dir, asset_id, mode, frames_by_anim)
	var actions: Dictionary = spec["actions"]
	var size_text := _size_text(spec)
	if frames_by_anim.is_empty():
		var note := " – đang dùng hiệu ứng particle tạm" if optional else ""
		var parts: Array[String] = []
		for action: String in actions:
			parts.append("%s %d" % [action, int(actions[action])])
		_missing(label, "%s %s: %s khung%s%s – %s/" % [mode, size_text, ", ".join(parts),
				" × 8 hướng" if not directions.is_empty() else "", note, dir.trim_prefix("res://")])
		return
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var loops: Array = spec.get("loop", []).duplicate()
	loops.append_array(meta.get("loop", []))
	for anim: String in frames_by_anim:
		var list: Array = frames_by_anim[anim]
		list.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
		frames.add_animation(anim)
		frames.set_animation_speed(anim, float(meta["fps"]))
		var action := anim.split("_")[0] if not directions.is_empty() else anim
		frames.set_animation_loop(anim, loops.has(action))
		for entry: Array in list:
			frames.add_frame(anim, entry[1])
	frames.set_meta("anchor", meta["anchor"])
	frames.set_meta("hit_frame", meta.get("hit_frame", {}))
	# Đối chiếu yêu cầu: đủ hành động × hướng, đủ số khung.
	for action: String in actions:
		var wanted := int(actions[action])
		var names: Array[String] = []
		if directions.is_empty():
			names.append(action)
		else:
			for direction: String in directions:
				names.append("%s_%s" % [action, direction])
		for anim in names:
			if not frames.has_animation(anim):
				_missing(label, "%s: %s (%d khung)" % [mode, anim, wanted])
			elif frames.get_frame_count(anim) < wanted:
				report["warnings"].append("%s: %s %s có %d/%d khung" % [label, mode, anim, frames.get_frame_count(anim), wanted])
	var path := ArtLibrary.frames_path(base.get_base_dir(), asset_id, mode)
	var err := ResourceSaver.save(frames, path)
	if err == OK:
		report["built"].append("%s (%d hoạt ảnh)" % [path.trim_prefix("res://"), frames.get_animation_names().size()])
	else:
		report["warnings"].append("Không lưu được %s (lỗi %d)" % [path, err])


## Sprite sheet + JSON của Blender.
func _collect_sheet(dir: String, asset_id: String, mode: String, out: Dictionary, meta: Dictionary) -> void:
	var prefix := "%s_%s" % [mode, asset_id]
	for file: String in DirAccess.get_files_at(dir):
		if file == prefix + ".json" or (file.begins_with(prefix + "-") and file.ends_with(".json")):
			_collect_one_sheet(dir.path_join(file), out, meta)


func _collect_one_sheet(json_path: String, out: Dictionary, meta: Dictionary) -> void:
	var png_path := json_path.trim_suffix(".json") + ".png"
	if not FileAccess.file_exists(png_path):
		png_path = json_path.trim_suffix(".json") + ".svg"
	if not FileAccess.file_exists(json_path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	var texture := load(png_path) as Texture2D if ResourceLoader.exists(png_path) else null
	if not parsed is Dictionary or texture == null:
		report["warnings"].append("sheet chưa import hoặc JSON hỏng (%s)" % png_path)
		return
	var data: Dictionary = parsed
	var size: Array = data.get("frame_size", [128, 128])
	if data.has("anchor"):
		meta["anchor"] = Vector2(float(data["anchor"][0]), float(data["anchor"][1]))
	if data.has("fps"):
		meta["fps"] = float(data["fps"])
	var loops: Array = meta.get("loop", [])
	loops.append_array(data.get("loop", []))
	meta["loop"] = loops
	var hits: Dictionary = meta.get("hit_frame", {})
	hits.merge(data.get("hit_frame", {}), true)
	meta["hit_frame"] = hits
	for frame: Dictionary in data.get("frames", []):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(float(frame["x"]), float(frame["y"]), float(size[0]), float(size[1]))
		var direction := str(frame.get("dir", ""))
		var anim := str(frame["action"]) if direction.is_empty() else "%s_%s" % [frame["action"], direction]
		_add(out, anim, int(frame.get("index", 0)), atlas)


## Từng khung PNG theo tên.
func _collect_loose(dir: String, asset_id: String, mode: String, out: Dictionary) -> void:
	for file in DirAccess.get_files_at(dir):
		if not file.ends_with(".png"):
			continue
		var parsed := parse_frame_name(file, mode, asset_id, _req["directions"])
		if parsed.is_empty():
			continue
		var path := dir.path_join(file)
		var texture := load(path) as Texture2D if ResourceLoader.exists(path) else null
		if texture == null:
			report["warnings"].append("%s chưa được import – chạy godot --import" % path)
			continue
		var anim := str(parsed["action"]) if str(parsed["dir"]).is_empty() else "%s_%s" % [parsed["action"], parsed["dir"]]
		_add(out, anim, int(parsed["frame"]), texture)


func _add(out: Dictionary, anim: String, index: int, texture: Texture2D) -> void:
	var list: Array = out.get(anim, [])
	list.append([index, texture])
	out[anim] = list


## Tách "<mode>_<asset_id>_<hành động>[_<hướng>]_<khung>.png". Trả về {} nếu không khớp quy tắc.
static func parse_frame_name(file: String, mode: String, asset_id: String, directions: Array) -> Dictionary:
	var prefix := "%s_%s_" % [mode, asset_id]
	if not file.begins_with(prefix) or not file.ends_with(".png"):
		return {}
	var parts := file.trim_prefix(prefix).trim_suffix(".png").split("_")
	if parts.size() < 2 or not parts[-1].is_valid_int():
		return {}
	var frame := int(parts[-1])
	if parts.size() == 3 and directions.has(parts[1]):
		return {"action": parts[0], "dir": parts[1], "frame": frame}
	if parts.size() == 2:
		return {"action": parts[0], "dir": "", "frame": frame}
	return {}


func _size_text(spec: Dictionary) -> String:
	var size: Variant = spec.get("frame_size", 0)
	if size is Dictionary:
		var parts: Array[String] = []
		for key: String in size:
			parts.append("%s %dpx" % [key, size[key]])
		return "(%s)" % ", ".join(parts)
	return "(%dpx/khung)" % int(size)


# --- Tileset ---

func _import_tileset(zone: String) -> void:
	var dir := ArtLibrary.TILESET_DIR.path_join(zone)
	var png := dir.path_join("tiles_%s.png" % zone)
	if not ResourceLoader.exists(png):
		_missing("Tileset %s" % zone, "%s (5 ô %dpx hàng ngang: sàn A, sàn B, tường, sàn hành lang, tường hành lang)" % [
				png.trim_prefix("res://"), int(_req["tileset"]["tile_size"])])
		return
	var tile_set := build_tileset(load(png) as Texture2D)
	var path := dir.path_join("%s_tileset.tres" % zone)
	if ResourceSaver.save(tile_set, path) == OK:
		report["built"].append(path.trim_prefix("res://"))


## TileSet cùng bố cục ô và va chạm với tileset tạm (TileIds), để phòng mẫu dùng lại được.
static func build_tileset(texture: Texture2D) -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i.ONE * Room.TILE_SIZE
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, PhysicsLayers.WORLD)
	tile_set.set_physics_layer_collision_mask(0, 0)
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i.ONE * Room.TILE_SIZE
	tile_set.add_source(source, TileIds.SOURCE_ID)
	var half := Room.TILE_SIZE * 0.5
	var square := PackedVector2Array([Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)])
	for index in 5:
		var coords := Vector2i(index, 0)
		source.create_tile(coords)
		if coords in TileIds.SOLID:
			var data := source.get_tile_data(coords, 0)
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, square)
	return tile_set


# --- Báo cáo ---

func _missing(owner_label: String, what: String) -> void:
	report["missing"].append("%s: %s" % [owner_label, what])


func get_missing_text() -> String:
	var lines: Array[String] = []
	var current := ""
	for entry: String in report["missing"]:
		var owner_label := entry.get_slice(":", 0)
		if owner_label != current:
			current = owner_label
			lines.append("")
			lines.append("### " + owner_label)
		lines.append("- " + entry.substr(owner_label.length() + 2))
	return "\n".join(lines)


func _write_status() -> void:
	var out: Array[String] = []
	out.append("# Tình trạng asset đồ họa")
	out.append("")
	out.append("Sinh tự động bởi `tools/import_assets` – đừng sửa tay. Chạy lại: "
			+ "`godot --headless --path . --import && godot --headless --path . res://tools/import_assets/import_assets.tscn`.")
	out.append("")
	out.append("- Đã nhận: %d · Còn thiếu: %d mục · Cảnh báo: %d" % [report["built"].size(), report["missing"].size(),
			report["warnings"].size()])
	out.append("")
	out.append("## Đã nhận")
	out.append("")
	for entry: String in report["built"]:
		out.append("- " + entry)
	if report["built"].is_empty():
		out.append("- (chưa có)")
	if not report["warnings"].is_empty():
		out.append("")
		out.append("## Cảnh báo")
		out.append("")
		for entry: String in report["warnings"]:
			out.append("- " + entry)
	out.append("")
	out.append("## Còn thiếu (đang dùng hình tạm)")
	out.append(get_missing_text())
	var file := FileAccess.open(STATUS_PATH, FileAccess.WRITE)
	if file:
		file.store_string("\n".join(out) + "\n")
