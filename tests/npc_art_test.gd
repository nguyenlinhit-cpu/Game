extends "res://tests/test_base.gd"

const CAST := {&"hub": [&"orwen", &"lio", &"bram"], &"library": [&"kiri"], &"vault": [&"garren"], &"furnace": [&"nyx"]}
const NEW_NPCS := [&"orwen", &"lio", &"bram"]
const EXPRESSIONS := ["neutral", "happy", "serious", "speaking"]

func _run() -> void:
	phase_name = "NPC art"
	SaveManager.save_dir = "user://test_npc_art_saves"
	GameState.reset_new_game()
	StoryManager.auto_play = true
	ArtLibrary.clear_cache()
	# The final boss also speaks in story scenes, outside the recruitable NPC cast.
	var story_regions: Dictionary = {}
	for expression in EXPRESSIONS:
		var portrait := StoryManager.speaker_portrait("devourer", expression) as AtlasTexture
		_check(portrait != null and portrait.get_width() == portrait.get_height(), "devourer: chân dung %s tồn tại, đúng tỉ lệ" % expression)
		if portrait:
			story_regions[portrait.region] = true
	_check(story_regions.size() == 4, "devourer: bốn biểu cảm dùng bốn vùng tranh riêng")
	for expression in ["smug", "angry", "sad"]:
		_check(StoryManager.speaker_portrait("devourer", expression) != null, "devourer: biểu cảm cốt truyện %s có hình" % expression)
	for zone: StringName in CAST:
		SceneRouter.go_to(StoryManager.get_zone_scene(zone), {}, 0.01)
		await SceneRouter.transition_finished
		await _frames(3)
		var map := get_tree().current_scene as OverworldMap
		map.player.input_enabled = false
		map.player.grant_invincibility(600.0)
		for id: StringName in CAST[zone]:
			var npc: Npc
			for candidate in map.find_children("*", "Npc", true, false):
				if candidate.npc_id == id:
					npc = candidate
			_check(npc != null and npc.visible and npc.sprite != null and npc.sprite.is_playing(), "%s: NPC thật trong map dùng hoạt ảnh thay hình tròn" % id)
			if npc == null or npc.sprite == null:
				continue
			var frames := npc.sprite.sprite_frames
			if id in NEW_NPCS:
				_check(frames.get_frame_count("idle_s") == 4 and frames.get_animation_loop("idle_s"), "%s: bốn khung idle có chớp mắt, lặp liên tục" % id)
			else:
				_check(frames == ArtLibrary.overworld_character_frames(DataPaths.load_character(id)), "%s: dùng hình trong trận ngoài bản đồ" % id)
			var frame := frames.get_frame_texture(npc.sprite.animation, 0)
			_check(frame.get_image().get_pixel(0, 0).a < 0.05, "%s: nền sprite trong suốt" % id)
			_check(npc.get_prompt().contains(npc.get_display_name()) and npc.get_node_or_null("IceShell") != null, "%s: tên, lời nhắc và lớp trạng thái tồn tại" % id)
			var regions: Dictionary = {}
			for expression in EXPRESSIONS:
				var portrait := StoryManager.speaker_portrait(String(id), expression) as AtlasTexture
				_check(portrait != null and portrait.get_width() == portrait.get_height(), "%s: chân dung %s không méo tỉ lệ" % [id, expression])
				if portrait:
					regions[portrait.region] = true
			_check(regions.size() == 4, "%s: bốn biểu cảm là bốn vùng tranh riêng" % id)
			_check(ArtLibrary.portrait_by_id(String(id), "smile") == ArtLibrary.portrait_by_id(String(id), "happy") \
					and ArtLibrary.portrait_by_id(String(id), "worried") == ArtLibrary.portrait_by_id(String(id), "serious"), "%s: ánh xạ biểu cảm hội thoại vẫn đúng" % id)
			if id == &"garren":
				_check(npc.frozen and npc.ice_shell.visible and npc.ice_shell.z_index > npc.sprite.z_index, "Garren: vỏ băng phủ phía trước hình nhân vật")
				npc.frozen = false
				await _frames(2)
				_check(not npc.ice_shell.visible, "Garren: hết đóng băng thì vỏ băng biến mất")
				npc.frozen = true
				await _frames(2)
			if OS.get_cmdline_user_args().has("--capture"):
				await _capture(map, npc)
	StoryManager.auto_play = false
	GameState.reset_new_game()
	SaveManager.save_dir = "user://saves"
	_finish()

func _capture(map: OverworldMap, npc: Npc) -> void:
	map.hud.hide()
	map.player.global_position = npc.global_position + Vector2(130, 55)
	map.camera.set_physics_process(false)
	map.camera.position_smoothing_enabled = false
	map.camera.clear_limits()
	map.camera.zoom = Vector2.ONE * 1.4
	map.camera.global_position = npc.global_position + Vector2(0, -65)
	await _frames(3)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/tmp/npc_%s_map.png" % npc.npc_id)
	for expression in EXPRESSIONS:
		StoryManager.box.open({"id": "npc_art_preview", "lines": [{"speaker": String(npc.npc_id), "expression": expression, "text": npc.get_display_name()}]})
		StoryManager.box.advance()
		await _frames(2)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/tmp/npc_%s_portrait_%s.png" % [npc.npc_id, expression])
		StoryManager.box.close()
		await _frames(1)
