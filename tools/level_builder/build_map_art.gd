extends SceneTree
## Build collision-aware modular tiles from the generated architecture kits.
## godot --headless --path . --script res://tools/level_builder/build_map_art.gd

const SAMPLES := {
	"library": [Rect2i(505, 365, 80, 80), Rect2i(505, 445, 80, 80), Rect2i(60, 275, 90, 35)],
	"vault": [Rect2i(470, 370, 80, 80), Rect2i(690, 480, 80, 80), Rect2i(450, 185, 100, 55)],
	"furnace": [Rect2i(715, 345, 80, 80), Rect2i(800, 425, 80, 80), Rect2i(400, 300, 100, 55)],
	"tower": [Rect2i(635, 335, 80, 80), Rect2i(635, 490, 80, 80), Rect2i(585, 155, 100, 55)],
}

func _initialize() -> void:
	var template := FileAccess.get_file_as_string("res://assets/tilesets/placeholder_tileset.tres")
	for zone: String in SAMPLES:
		var texture := load("res://map/remake/%s_kit_v3.png" % zone) as Texture2D
		var source := texture.get_image() if texture else null
		if source == null:
			quit(1)
			return
		var atlas := Image.create_empty(512, 64, false, Image.FORMAT_RGBA8)
		var cell_size := source.get_size() / 4
		for index in 8:
			var cell: int = [0, 1, 4, 6, 5, 2, 3, 7][index]
			var sample := Rect2i(Vector2i(cell % 4, cell / 4) * cell_size, cell_size)
			# Use plain material centers at gameplay scale, avoiding a tiny repeated border per tile.
			if index in [0, 1, 3, 5, 6]:
				if index in [0, 1, 3]:
					sample.position = Vector2i.ZERO
				var inset := cell_size / 4
				sample = Rect2i(sample.position + inset, cell_size / 2)
			var tile := source.get_region(sample)
			tile.convert(Image.FORMAT_RGBA8)
			tile.resize(64, 64, Image.INTERPOLATE_LANCZOS)
			atlas.blit_rect(tile, Rect2i(0, 0, 64, 64), Vector2i(index * 64, 0))
		var dir := "res://assets/tilesets/%s" % zone
		DirAccess.make_dir_recursive_absolute(dir)
		if atlas.save_png(dir.path_join("tiles_%s.png" % zone)) != OK:
			quit(1)
			return
		var file := FileAccess.open(dir.path_join("%s_tileset.tres" % zone), FileAccess.WRITE)
		var contents := template.replace("res://assets/tilesets/placeholder_tiles.png", dir.path_join("tiles_%s.png" % zone))
		contents = contents.replace("[resource]", "5:0/0 = 0\n6:0/0 = 0\n7:0/0 = 0\n\n[resource]")
		file.store_string(contents)
		print("Map art: ", zone)
	quit()
