extends "res://tests/test_base.gd"
## Kiểm thử Phase 13: bảng thông số hình (art_specs) đủ cho mọi nhân vật / quái, file yêu cầu hình, công cụ nhập asset
## (đọc sprite sheet Blender + từng khung theo tên, tạo SpriteFrames, liệt kê đủ asset còn thiếu, tileset), hình mẫu
## render từ Blender (gắn cho Mira) hiện đúng hoạt ảnh ngoài map (8 hướng, đứng / chạy) và trong trận (đánh, bị đánh),
## shader dùng chung (viền chọn mục tiêu, nháy trắng, tan biến, nền Tuyệt kỹ), hiệu ứng kỹ năng particle màu nguyên tố.
## Chạy (sau khi import): godot --headless --path . res://tests/phase13_test.tscn

const DIRECTIONS: Array[String] = ["e", "se", "s", "sw", "w", "nw", "n", "ne"]


func _run() -> void:
	phase_name = "Phase 13"
	timeout_sec = 200.0
	SaveManager.save_dir = "user://test_phase13_saves"
	GameState.reset_new_game()
	_test_specs()
	_test_parse_names()
	_test_importer()
	_test_tileset()
	await _test_map_sprite()
	await _test_battle_sprite()
	_cleanup()
	_finish()


func _cleanup() -> void:
	get_tree().paused = false
	for slot in SaveManager.get_all_slots():
		SaveManager.delete_slot(slot)
	SaveManager.save_dir = "user://saves"
	GameState.reset_new_game()
	ArtLibrary.clear_cache()


func _test_specs() -> void:
	var req := ArtLibrary.requirements()
	_check(req.has("character") and req.has("enemy") and (req["directions"] as Array).size() == 8,
			"data/config/art_requirements.json: hành động, số khung, 8 hướng")
	_check(int(req["character"]["map"]["frame_size"]) == 128 and int(req["character"]["battle"]["frame_size"]) == 512
			and req["enemy"]["battle"]["frame_size"]["boss"] == 768.0 and req["character"]["splash"]["size"] == [2048.0, 1152.0],
			"Kích thước đúng bảng mục 12 (128 / 512 / quái 256-384-768 / tranh 2048×1152)")
	var missing_specs: Array[String] = []
	for id in DataPaths.list_character_ids():
		var ids: Array = ["traveler_male", "traveler_female"] if id == &"traveler" else [String(id)]
		for asset_id: String in ids:
			if not FileAccess.file_exists("res://art_specs/%s.md" % asset_id):
				missing_specs.append(asset_id)
	var families: Dictionary = {}
	for file in DirAccess.get_files_at("res://data/enemies"):
		if file.ends_with(".tres") and not file.begins_with("training_dummy") and not file.begins_with("balance_"):
			var enemy := load("res://data/enemies/" + file) as EnemyData
			families[String(enemy.family) if enemy.family != &"" else String(enemy.id)] = true
	for family: String in families:
		if not FileAccess.file_exists("res://art_specs/%s.md" % family):
			missing_specs.append(family)
	_check(missing_specs.is_empty(), "art_specs có đủ nhân vật chính 2 skin, 24 nhân vật, %d họ quái/boss %s" % [
			families.size(), missing_specs])
	var ignar := FileAccess.get_file_as_string("res://art_specs/ignar.md")
	_check(ignar.contains("#E8552B") and ignar.contains("`run` | 8") and ignar.contains("splash_ignar.png"),
			"art_specs/ignar.md: mã màu, hoạt ảnh + số khung, tên file")
	_check(FileAccess.get_file_as_string("res://art_specs/library_warden.md").contains("idle-p2"),
			"Boss có hình riêng mỗi giai đoạn (hậu tố -p2)")
	_check(FileAccess.file_exists("res://docs/KRITA_PIPELINE.md") and FileAccess.file_exists("res://tools/blender/render_sprites.py")
			and FileAccess.file_exists("res://tools/blender/make_sample_blend.py"), "Có hướng dẫn Krita + script Blender")


func _test_parse_names() -> void:
	var dirs: Array = DIRECTIONS
	_check(AssetImporter.parse_frame_name("map_ignar_run_se_03.png", "map", "ignar", dirs) == {"action": "run", "dir": "se", "frame": 3},
			"Đọc tên khung map_ignar_run_se_03.png")
	_check(AssetImporter.parse_frame_name("battle_library_warden_idle-p2_00.png", "battle", "library_warden", dirs)
			== {"action": "idle-p2", "dir": "", "frame": 0}, "Đọc tên khung boss giai đoạn 2 (id có dấu gạch dưới)")
	_check(AssetImporter.parse_frame_name("vfx_ignar_skill_0011.png", "vfx", "ignar", dirs)["frame"] == 11,
			"Đọc chuỗi PNG Krita (số khung 4 chữ số)")
	_check(AssetImporter.parse_frame_name("map_ignar_run.png", "map", "ignar", dirs).is_empty()
			and AssetImporter.parse_frame_name("map_kiri_run_se_03.png", "map", "ignar", dirs).is_empty(),
			"Bỏ qua file sai quy tắc / của nhân vật khác")


func _test_importer() -> void:
	var importer := AssetImporter.new()
	var report := importer.run(false)
	var built: Array = report["built"]
	_check(built.any(func(e: String) -> bool: return e.contains("mira_map_frames")) and built.any(
			func(e: String) -> bool: return e.contains("mira_battle_frames")), "Nhận sprite sheet Blender của Mira (map + trận)")
	var missing: Array = report["missing"]
	var text := importer.get_missing_text()
	_check(missing.size() > 200 and text.contains("traveler_male") and not text.contains("Quái library_warden")
			and not text.contains("NPC orwen"),
			"Liệt kê asset còn thiếu, boss và chân dung Orwen đã đủ hình (%d mục)" % missing.size())
	_check(text.contains("map: idle_n") and not text.contains("map: run_e") and not text.contains("map: idle_e"),
			"Mira: chỉ báo thiếu hướng chưa vẽ (idle_n...), không báo hướng phải")
	var frames := ArtLibrary.character_frames(DataPaths.load_character(&"mira"), "map")
	_check(frames != null and frames.get_frame_count("run_e") == 6 and frames.get_frame_count("idle_e") == 4
			and frames.get_animation_loop("run_e") and ArtLibrary.frame_size_of(frames) == Vector2(32, 32),
			"SpriteFrames map pixel: idle 4 + run 6 khung hướng phải, khung 32 px, lặp")
	var battle := ArtLibrary.character_frames(DataPaths.load_character(&"mira"), "battle")
	_check(battle and battle.get_frame_count("attack") == 8 and not battle.get_animation_loop("attack")
			and ArtLibrary.frame_size_of(battle) == Vector2(512, 512), "SpriteFrames trận: attack 8 khung 512 px, không lặp")
	_check(ArtLibrary.portrait_by_id("missing_test_character") == null and ArtLibrary.zone_tileset(&"missing_test_zone") == null,
			"Thiếu chân dung / tileset → trả về null (giữ hình tạm)")
	for id in DataPaths.list_character_ids():
		var data := DataPaths.load_character(id)
		var genders: Array = [&"male", &"female"] if id == &"traveler" else [&"male"]
		for gender in genders:
			GameState.player_gender = gender
			var map_frames := ArtLibrary.character_frames(data, "map")
			var battle_frames := ArtLibrary.character_frames(data, "battle")
			var overworld := ArtLibrary.overworld_character_frames(data)
			_check(overworld != null and overworld.get_frame_texture("idle_e", 0) == battle_frames.get_frame_texture("idle", 0)
					and overworld.get_frame_texture("opener_e", 0) == battle_frames.get_frame_texture("attack", 0)
					and overworld.get_animation_loop("run_e") and not overworld.get_animation_loop("opener_e"),
					"%s (%s): ngoài map dùng hình idle và đánh từ bộ trong trận" % [id, gender])
			var vfx := ArtLibrary.vfx_frames(data)
			_check(map_frames != null and map_frames.has_animation("run_e")
					and battle_frames != null and battle_frames.has_animation("ultimate")
					and vfx != null and vfx.has_animation("attack") and vfx.has_animation("skill-cast")
					and vfx.has_animation("ultimate"), "%s (%s): tải sprite map, trận và VFX từ design" % [id, gender])
	GameState.player_gender = &"male"


func _test_tileset() -> void:
	var tile_set := AssetImporter.build_tileset(load("res://assets/tilesets/placeholder_tiles.png") as Texture2D)
	var source := tile_set.get_source(TileIds.SOURCE_ID) as TileSetAtlasSource
	_check(source.get_tiles_count() == 5 and source.get_tile_data(TileIds.WALL, 0).get_collision_polygons_count(0) == 1
			and source.get_tile_data(TileIds.FLOOR_A, 0).get_collision_polygons_count(0) == 0,
			"Tileset khu tạo cùng bố cục ô, tường có va chạm")


func _test_map_sprite() -> void:
	GameState.reset_new_game()
	SceneRouter.go_to(DataPaths.TEST_MAP_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
	await _frames(3)
	var map := get_tree().current_scene as OverworldMap
	var player := map.player
	player.set_leader(0)
	_check(player.sprite != null and player.sprite.sprite_frames.has_animation("idle_e"), "Lữ khách dùng hình trong trận ngoài map")
	player.set_leader(1)
	await _frames(2)
	_check(player.sprite != null and player.sprite.sprite_frames.has_animation("idle_e"), "Mira dẫn đầu: dùng hình trong trận")
	Input.action_press("move_right")
	await _seconds(0.4)
	_check(player.sprite.animation == &"run_e" and player.sprite.is_playing() and not player.sprite.flip_h,
			"Chạy sang phải: phát run_e")
	Input.action_release("move_right")
	Input.action_press("move_left")
	await _seconds(0.4)
	_check(player.sprite.animation == &"run_e" and player.sprite.flip_h, "Chạy sang trái: run_e lật ngang")
	Input.action_release("move_left")
	Input.action_press("move_up")
	await _seconds(0.3)
	Input.action_release("move_up")
	await _seconds(0.6)
	_check(player.sprite.animation == &"idle_e" and not player.sprite.flip_h, "Dừng lại nhìn lên: chưa có idle_n, dùng idle_e")
	player.set_leader(0)
	_check(player.sprite != null and player.sprite.sprite_frames == ArtLibrary.overworld_character_frames(
			DataPaths.load_character(&"traveler")), "Đổi về Lữ khách: dùng đúng sprite Lữ khách")


func _test_battle_sprite() -> void:
	GameState.reset_new_game()
	var enc := load("res://data/encounters/library_01_sprouts.tres")
	SceneRouter.go_to(DataPaths.BATTLE_SCENE, {"encounter": enc}, 0.01)
	await SceneRouter.transition_finished
	await _frames(3)
	var scene := get_tree().current_scene
	var mira: UnitView = null
	var enemy: UnitView = null
	for view: UnitView in scene._views.values():
		if view.unit.character and view.unit.character.id == &"mira":
			mira = view
		elif not view.unit.is_ally() and enemy == null:
			enemy = view
	_check(mira and mira.sprite and mira.sprite.material is ShaderMaterial, "Mira trong trận: sprite + shader unit_fx")
	_check(enemy and enemy.fx_material is ShaderMaterial
			and ((enemy.sprite != null and enemy.sprite.material == enemy.fx_material)
			or (enemy.sprite == null and enemy.body.material == enemy.fx_material)), "Quái: thân dùng shader unit_fx")
	mira.play_action(SkillData.Kind.BASIC)
	_check(mira.sprite.animation == &"attack", "Đánh thường: phát attack")
	await _seconds(1.2)
	_check(mira.sprite.animation == &"idle", "Đánh xong quay về idle")
	mira.play_hit()
	await _frames(2)
	_check(float(mira.fx_material.get_shader_parameter("flash")) > 0.3, "Bị đánh: nháy trắng (shader flash)")
	enemy.marker = UnitView.Marker.MAIN
	await _frames(2)
	_check(float(enemy.fx_material.get_shader_parameter("outline_width")) > 0.0, "Chọn mục tiêu: bật viền (shader outline)")
	enemy.unit.hp = 0.0
	enemy.unit.died.emit(enemy.unit)
	await _seconds(0.7)
	_check(float(enemy.fx_material.get_shader_parameter("dissolve")) > 0.9, "Quái ngã: tan biến (shader dissolve)")
	var vfx := SkillVfx.spawn(scene._field, Vector2(900, 500), Element.Type.FIRE, null, "skill")
	_check(vfx.particles != null and vfx.particles.emitting and vfx.particles.amount == 48, "Hiệu ứng kỹ năng: particle Lửa (chưa có hình Krita)")
	await _seconds(1.2)
	_check(not is_instance_valid(vfx), "Hiệu ứng tự hủy")
	var rendered_vfx := SkillVfx.spawn(scene._field, Vector2(900, 500), Element.Type.WIND,
			DataPaths.load_character(&"fenna"), "skill")
	_check(rendered_vfx.sprite != null and rendered_vfx.sprite.animation == &"skill"
			and rendered_vfx.particles == null, "Fenna: phát VFX vẽ từ design thay cho particle")
	await _seconds(2.0)
	_check(not is_instance_valid(rendered_vfx), "VFX từ design tự hủy sau hoạt ảnh")
	scene._show_ultimate_backdrop(mira.unit)
	await _seconds(0.3)
	var mat := scene.ultimate_backdrop.material as ShaderMaterial
	_check(float(mat.get_shader_parameter("strength")) > 0.5 and mat.get_shader_parameter("tint") == Element.color(Element.Type.WATER),
			"Tuyệt kỹ: nền đổi màu theo nguyên tố (shader ultimate_bg)")
	scene.debug_force_result(true)
	await _frames(3)
	_check(mira.sprite.animation == &"victory", "Thắng trận: phát victory")
	SceneRouter.go_to(DataPaths.TITLE_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
