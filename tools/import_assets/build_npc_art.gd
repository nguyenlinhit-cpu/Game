extends SceneTree
## Non-destructive import: AtlasTexture resources reference the original generated PNGs.
## godot --headless --path . --script res://tools/import_assets/build_npc_art.gd

const NEW_NPCS := ["orwen", "lio", "bram"]
const COMPANIONS := ["kiri", "garren", "nyx"]
const STORY_PORTRAITS := ["devourer"]
const EXPRESSIONS := ["neutral", "happy", "serious", "speaking"]

func _initialize() -> void:
	for id in NEW_NPCS:
		if not _build(id, true):
			quit(1)
			return
	for id in COMPANIONS + STORY_PORTRAITS:
		if not _build(id, false):
			quit(1)
			return
	quit()

func _build(id: String, has_map: bool) -> bool:
	var root := "res://assets/characters/%s" % id
	var path := root.path_join("npc/%s_appearance_v1.png" % id) if has_map else root.path_join("portrait/%s_portraits_v1.png" % id)
	var source := load(path) as Texture2D
	if source == null:
		push_error("Missing NPC art: " + path)
		return false
	var size := source.get_size()
	var frame_size := Vector2(floorf(size.x / 4.0), floorf(size.y / 2.0) if has_map else size.y)
	if has_map:
		var frames := SpriteFrames.new()
		frames.remove_animation("default")
		frames.add_animation("idle_s")
		frames.set_animation_speed("idle_s", 4.0)
		frames.set_animation_loop("idle_s", true)
		var bottom := 0.0
		for i in 4:
			var region := Rect2(Vector2(i * frame_size.x, 0), frame_size)
			var frame := _region(source, region)
			var used := source.get_image().get_region(Rect2i(region)).get_used_rect()
			bottom = maxf(bottom, float(used.end.y) / frame_size.y)
			frames.add_frame("idle_s", frame, [6.0, 0.6, 4.0, 4.0][i])
		frames.set_meta("anchor", Vector2(0.5, bottom))
		frames.set_meta("source", path)
		DirAccess.make_dir_recursive_absolute(root.path_join("map"))
		if ResourceSaver.save(frames, root.path_join("map/%s_map_frames.tres" % id)) != OK:
			return false
	DirAccess.make_dir_recursive_absolute(root.path_join("portrait"))
	for i in EXPRESSIONS.size():
		var cell := Rect2(Vector2(i * frame_size.x, frame_size.y if has_map else 0.0), Vector2(frame_size.x, size.y - frame_size.y if has_map else size.y))
		var visible := source.get_image().get_region(Rect2i(cell)).get_used_rect()
		# Busts are framed as square portraits without squashing faces in the dialogue UI.
		var top := maxf(0.0, visible.position.y - 5.0)
		var side := minf(cell.size.x, cell.size.y - top)
		var square := Rect2(cell.position + Vector2((cell.size.x - side) * 0.5, top), Vector2.ONE * side)
		var portrait := _region(source, square)
		if ResourceSaver.save(portrait, root.path_join("portrait/portrait_%s_%s.tres" % [id, EXPRESSIONS[i]])) != OK:
			return false
	print("NPC art: ", id, " · ", "4 idle frames + " if has_map else "", "4 portraits")
	return true

func _region(source: Texture2D, region: Rect2) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = source
	texture.region = region
	texture.filter_clip = true
	return texture
