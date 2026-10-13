class_name BuildCheck
extends RefCounted
## Tự kiểm tra trên bản đã xuất (không cần thư mục tests/):
##   Aethelgard.exe --headless -- --self-check
## Kiểm tra giới hạn cấp 30, đội tối đa 4, dữ liệu cốt truyện / bản đồ / banner nạp được, lưu → tải giữ nguyên trạng
## thái (ô lưu tạm riêng). In từng dòng ĐẠT/LỖI và thoát mã 0 (đạt hết) hoặc 1.

const SAVE_DIR: String = "user://self_check_saves"


static func is_requested() -> bool:
	return OS.get_cmdline_user_args().has("--self-check")


static func run(tree: SceneTree) -> void:
	var results: Array[Array] = []
	var check := func(ok: bool, text: String) -> void: results.append([ok, text])
	GameState.reset_new_game()
	check.call(GameConfig.MAX_LEVEL == 30, "Giới hạn cấp = 30")
	check.call(GameConfig.MAX_TEAM_SIZE == 4, "Đội tối đa 4 nhân vật")
	var five: Array[StringName] = [&"traveler", &"mira", &"kiri", &"garren", &"nyx"]
	check.call(not GameState.set_team(five) and GameState.team.size() <= 4, "Từ chối đội 5 người")
	GameState.character_progress["mira"] = {"level": 80, "ascension": 9}
	check.call(Progression.get_level(&"mira") == 30, "Cấp lưu vượt giới hạn bị kẹp về 30")
	check.call(not StoryManager.data.is_empty() and StoryManager.load_dialogue("p0_wake").has("lines"), "Cốt truyện + hội thoại nạp được")
	var maps_ok := true
	for zone: String in ["hub", "library", "vault", "furnace", "tower"]:
		maps_ok = maps_ok and ResourceLoader.exists(StoryManager.get_zone_scene(StringName(zone)))
	check.call(maps_ok, "5 bản đồ có trong bản build")
	check.call(GachaManager.get_banners().size() == 2, "2 banner gacha")
	check.call(DataPaths.list_character_ids().size() == 25, "Đủ 25 nhân vật (%d)" % DataPaths.list_character_ids().size())
	check.call(DataPaths.list_encounter_paths().size() >= 36, "Đủ dữ liệu trận (%d)" % DataPaths.list_encounter_paths().size())
	var scenes_ok := true
	for zone: String in ["hub", "library", "vault", "furnace", "tower"]:
		var root := (load(StoryManager.get_zone_scene(StringName(zone))) as PackedScene).instantiate()
		scenes_ok = scenes_ok and root.find_children("*", "Room", true, false).size() >= 4
		root.free()
	check.call(scenes_ok, "5 bản đồ dựng được (đủ phòng)")
	# Một trận Tự Động thật với đội miễn phí cấp 10 vs boss Thư Viện.
	var team: Array[CharacterData] = []
	for id: StringName in [&"traveler", &"kiri", &"garren", &"nyx"]:
		team.append(DataPaths.load_character(id))
	var controller := BattleController.new()
	controller.instant = true
	controller.auto_mode = true
	controller.rng.seed = 5
	tree.root.add_child(controller)
	var encounter := load("res://data/encounters/library_boss_warden.tres") as EncounterData
	var setup_ok := controller.setup(team, 10, encounter, BattleTypes.Opening.NORMAL) == OK
	controller.start()
	var frames := 0
	while controller.phase != BattleController.Phase.ENDED and frames < 20000:
		frames += 1
		await tree.process_frame
	check.call(setup_ok and controller.phase == BattleController.Phase.ENDED and controller.won,
			"Trận Tự Động: đội miễn phí cấp 10 thắng Người Gác Thư Viện")
	controller.queue_free()
	check.call(TranslationServer.translate("MENU_GACHA") != "MENU_GACHA", "File dịch có trong bản build")
	check.call(_story_run(), "Cốt truyện Mở đầu → hết Chương 4 (logic): đủ 4 nhân vật miễn phí, Tinh Mệnh 6, thưởng 4 chương")
	# Lưu → tải.
	var old_dir := SaveManager.save_dir
	SaveManager.save_dir = SAVE_DIR
	GameState.reset_new_game()
	GameState.player_name = "Check"
	GameState.add_item(&"star_tear", 1234)
	GameState.set_story_flag(&"chapter_1_complete")
	var saved := SaveManager.save_game(1)
	GameState.reset_new_game()
	var loaded := SaveManager.load_game(1)
	check.call(saved and loaded and GameState.player_name == "Check" and GameState.get_item_count(&"star_tear") >= 1234
			and bool(GameState.get_story_flag(&"chapter_1_complete")), "Lưu rồi tải giữ nguyên tên, túi đồ, cờ cốt truyện")
	SaveManager.delete_slot(1)
	SaveManager.save_dir = old_dir
	GameState.reset_new_game()
	var failed := 0
	for r in results:
		print("%s  %s" % ["ĐẠT" if r[0] else "LỖI", r[1]])
		if not r[0]:
			failed += 1
	print("Tự kiểm tra bản build (%s): %d/%d đạt" % [OS.get_name(), results.size() - failed, results.size()])
	tree.quit(0 if failed == 0 else 1)


## Chạy cờ cốt truyện từ đầu tới hết Chương 4 không cần giao diện (như tests/phase12_test.gd).
static func _story_run() -> bool:
	GameState.reset_new_game()
	GameState.story_flags.clear()
	StoryManager.auto_play = true
	StoryManager.begin_new_story()
	var sm := StoryManager
	sm.map_ready(&"hub")
	sm.fire(&"hub_training")
	_claim("prologue_tutorial")
	sm.map_ready(&"hub")
	sm.talk(&"orwen")
	sm.map_ready(&"library")
	sm.talk(&"kiri")
	sm.fire(&"library_map")
	_claim("library_boss_warden")
	sm.map_ready(&"library")
	var ch1 := GachaManager.is_unlocked() and GameState.owned_characters.size() == 3
	sm.talk(&"orwen")
	sm.map_ready(&"vault")
	sm.talk(&"garren")
	var team4 := GameState.team.size() == 4
	_claim("vault_boss_behemoth")
	sm.map_ready(&"vault")
	sm.talk(&"lio")
	sm.fire(&"sq1_diary")
	sm.talk(&"lio")
	sm.talk(&"orwen")
	sm.map_ready(&"furnace")
	sm.talk(&"nyx")
	_claim("furnace_boss_core")
	sm.map_ready(&"furnace")
	sm.talk(&"bram")
	sm.fire(&"sq2_core")
	sm.talk(&"bram")
	sm.talk(&"orwen")
	sm.map_ready(&"tower")
	sm.fire(&"tower_summit")
	_claim("tower_boss_devourer")
	sm.map_ready(&"tower")
	var ok := ch1 and team4 and GameState.owned_characters.size() == 5 and sm.has_flag("story_complete") \
			and sm.get_main_step().is_empty() and GameState.get_eidolon_level(&"traveler") == 6 \
			and QuestManager.granted_chapters.size() == 4
	StoryManager.auto_play = false
	GameState.reset_new_game()
	return ok


static func _claim(encounter_id: String) -> void:
	Loot.claim_encounter(load("res://data/encounters/%s.tres" % encounter_id) as EncounterData)

