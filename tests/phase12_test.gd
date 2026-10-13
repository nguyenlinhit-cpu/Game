extends "res://tests/test_base.gd"
## Kiểm thử Phase 12: dữ liệu cốt truyện (hội thoại, người nói, chữ dịch, NPC, điểm kích hoạt, nhiệm vụ), bản đồ 5 khu
## (8–12 phòng, khớp kế hoạch khu, không kẹt đường: đường chính chỉ cần nguyên tố đội miễn phí có ở thời điểm đó,
## rương ẩn cần nhân vật gacha), chơi cốt truyện Mở đầu → hết Chương 4 (nhận đủ 4 nhân vật miễn phí đúng chương,
## đội 4 người đủ vị trí từ Chương 2, mở Gacha + nhiệm vụ ngày sau Chương 1, thưởng chương, Tinh Mệnh nhân vật chính
## 1–6 kể cả 2 nhiệm vụ phụ), hộp thoại (chữ chạy, lựa chọn, lịch sử, bỏ qua, tạm dừng game), chạy trên map thật
## (cảnh tỉnh dậy, cổng theo cờ, mũi tên nhiệm vụ, Cổng Dịch Chuyển, NPC gia nhập, cổng nguyên tố, dịch chuyển nhanh,
## hồi quái khi vào lại khu, chọn mức Khó khi đánh lại boss), quầy hàng, lưu/tải, báo cáo kinh tế.
## Chạy: godot --headless --path . res://tests/phase12_test.tscn

const SAVE_DIR: String = "user://test_phase12_saves"
const ZONES: Array[StringName] = [&"library", &"vault", &"furnace", &"tower"]
const ZONE_CHAPTER: Dictionary = {&"library": 1, &"vault": 2, &"furnace": 3, &"tower": 4}
const ZONE_LEVELS: Dictionary = {&"library": [1, 8], &"vault": [8, 16], &"furnace": [16, 24], &"tower": [24, 30]}
## Nhân vật miễn phí gia nhập trong khu nào (phòng có NPC) → nguyên tố mở thêm.
const JOIN_ROOMS: Dictionary = {&"library": [&"L04", &"kiri"], &"vault": [&"V04", &"garren"], &"furnace": [&"F04", &"nyx"]}
const GACHA_ONLY: Array[int] = [ElementalObstacle.Kind.FOG, ElementalObstacle.Kind.RUSTED_GATE, ElementalObstacle.Kind.WARP_BARRIER]


func _run() -> void:
	phase_name = "Phase 12"
	timeout_sec = 400.0
	SaveManager.save_dir = SAVE_DIR
	GachaManager.autosave = false
	QuestManager.autosave_on_claim = false
	_test_story_data()
	_test_maps()
	_test_story_playthrough()
	await _test_dialogue_box()
	await _test_world()
	_test_shop()
	_test_economy_report()
	_cleanup()
	_finish()


func _cleanup() -> void:
	StoryManager.auto_play = false
	StoryManager.auto_choices.clear()
	GachaManager.autosave = true
	QuestManager.autosave_on_claim = true
	get_tree().paused = false
	for slot in SaveManager.get_all_slots():
		SaveManager.delete_slot(slot)
	SaveManager.save_dir = "user://saves"
	GameState.reset_new_game()


func _new_story() -> void:
	get_tree().paused = false
	GameState.reset_new_game()
	GameState.story_flags.clear()
	StoryManager.begin_new_story()
	StoryManager.played.clear()


func _flag(name: String) -> bool:
	return StoryManager.has_flag(name)


# --- Dữ liệu cốt truyện ---

func _test_story_data() -> void:
	var data := StoryManager.data
	_check(not data.is_empty() and data.has("main_quest") and data.has("npcs"), "Đọc được data/story/story.json")
	var ids: Array[String] = []
	for file in DirAccess.get_files_at(StoryManager.DIALOGUE_DIR):
		if file.ends_with(".json") and file != "intro.json":
			ids.append(file.get_basename())
	var lines_ok := true
	var missing: Array[String] = []
	var line_count := 0
	for id in ids:
		var dialogue := StoryManager.load_dialogue(id)
		for line: Dictionary in dialogue.get("lines", []):
			line_count += 1
			if StoryManager.get_speaker(str(line.get("speaker", ""))).is_empty():
				lines_ok = false
			var key := str(line.get("text", ""))
			if tr(key) == key:
				missing.append(key)
			for choice: Dictionary in line.get("choices", []):
				if tr(str(choice["text"])) == str(choice["text"]):
					missing.append(str(choice["text"]))
	_check(ids.size() >= 30 and line_count >= 150, "%d cảnh hội thoại JSON, %d câu" % [ids.size(), line_count])
	_check(lines_ok, "Mọi câu có người nói hợp lệ (chân dung, biểu cảm)")
	_check(missing.is_empty(), "Mọi câu thoại / lựa chọn có chữ dịch %s" % [missing.slice(0, 3)])
	# Mỗi chương 3–5 cảnh chính.
	var chapters := {"p0": 0, "c1": 0, "c2": 0, "c3": 0, "c4": 0}
	for id in ids:
		var prefix := id.left(2)
		if chapters.has(prefix) and not id.ends_with("_idle"):
			chapters[prefix] += 1
	var counts_ok := true
	for prefix: String in chapters:
		counts_ok = counts_ok and chapters[prefix] >= 3 and chapters[prefix] <= 6
	_check(counts_ok, "Mở đầu + mỗi chương 3–5 cảnh chính %s" % [chapters])
	for join_scene in ["c1_kiri_join", "c2_garren_join", "c3_nyx_join"]:
		_check(ids.has(join_scene), "Cảnh gia nhập riêng: %s" % join_scene)
	var celestine: bool = StoryManager.load_dialogue("c1_boss_post").get("lines", []).any(
			func(l: Dictionary) -> bool: return l["speaker"] == "celestine")
	_check(celestine, "Ảo ảnh Celestine ở cuối Chương 1")
	var rift := tr("DLG_C4_ENDING_06").contains("vết nứt")
	_check(rift, "Kết Chương 4: vết nứt mở ra vùng đất mới")
	var refs_ok := true
	for npc: Dictionary in data["npcs"].values():
		for option: Dictionary in npc["options"]:
			refs_ok = refs_ok and ids.has(str(option["dialogue"]))
	for trigger: Dictionary in data["triggers"].values():
		refs_ok = refs_ok and ids.has(str(trigger["dialogue"]))
	_check(refs_ok, "NPC và điểm kích hoạt trỏ tới cảnh có thật")
	var quest_keys_ok := true
	for step: Dictionary in data["main_quest"]:
		quest_keys_ok = quest_keys_ok and tr(str(step["title"])) != str(step["title"])
	_check(quest_keys_ok and (data["main_quest"] as Array).size() >= 15, "%d bước nhiệm vụ chính có chữ dịch" % (data["main_quest"] as Array).size())
	_check((data["side_quests"] as Array).size() == 2, "2 nhiệm vụ phụ")


# --- Bản đồ ---

func _test_maps() -> void:
	var hub := StoryManager.get_zone_scene(&"hub")
	_check(ResourceLoader.exists(hub), "Có Sảnh Trung Tâm %s" % hub)
	var hub_root := (load(hub) as PackedScene).instantiate()
	var stations: Array[int] = []
	for node in hub_root.find_children("*", "Station", true, false):
		stations.append((node as Station).kind)
	stations.sort()
	_check(stations == [0, 1, 2, 3, 4, 5], "Sảnh có bàn Ước Nguyện, bảng nhiệm vụ, bàn nâng cấp, đội hình, quầy hàng, Cổng Dịch Chuyển")
	_check(hub_root.find_children("*", "Npc", true, false).size() >= 3 and hub_root.find_child("RestPoint", true, false) != null,
			"Sảnh có NPC và điểm nghỉ")
	var hub_enemies := hub_root.find_children("*", "OverworldEnemy", true, false)
	_check(hub_enemies.size() == 1 and hub_enemies[0].get_children().any(func(c: Node) -> bool: return c is StoryGate),
			"Sảnh chỉ có 1 quái hướng dẫn (hiện theo cờ cốt truyện)")
	hub_root.free()
	for zone in ZONES:
		var path := StoryManager.get_zone_scene(zone)
		var data := load("res://data/zones/%s.tres" % zone) as ZoneData
		var counts := EconomyReport.count_map(path)
		_check(not counts.is_empty() and counts["rooms"] >= 8 and counts["rooms"] <= 12,
				"%s: %d phòng (8–12)" % [zone, counts.get("rooms", 0)])
		var enc_ok := true
		for i in data.encounters.size():
			enc_ok = enc_ok and int(counts["encounters"].get(String(data.encounters[i].id), 0)) == data.get_placement_count(i)
		_check(enc_ok and counts["chests"] == [6, 4, 4] and counts["boxes"] == 8,
				"%s: quái, rương 6/4/4, 8 Hộp Bí Kỹ đúng kế hoạch khu" % zone)
		var levels_ok := true
		for encounter in data.encounters:
			levels_ok = levels_ok and encounter.zone == zone and encounter.get_max_level() >= ZONE_LEVELS[zone][0] \
					and encounter.get_max_level() <= ZONE_LEVELS[zone][1]
		_check(levels_ok, "%s: trận theo cấp chương %s" % [zone, ZONE_LEVELS[zone]])
		_test_reachability(zone, path)


## Đồ thị phòng + cổng nguyên tố: đi từ phòng đầu, mở thêm nguyên tố khi tới phòng có nhân vật gia nhập.
func _test_reachability(zone: StringName, path: String) -> void:
	var root := (load(path) as PackedScene).instantiate()
	var rooms: Dictionary = {}
	for node in root.find_children("*", "Room", true, false):
		var room := node as Room
		rooms[room.room_id] = room
	# Nguyên tố có lúc vào khu: nhân vật miễn phí đã gia nhập ở chương trước.
	var elements: Array[int] = [Element.Type.SOUL, Element.Type.WATER]
	var free: Dictionary = StoryManager.data["free_characters"]
	for id: String in free:
		if int(free[id]) < int(ZONE_CHAPTER[zone]):
			elements.append(DataPaths.load_character(StringName(id)).element)
	var start: StringName = root.get("start_room_id")
	var reached: Dictionary = {start: true}
	var changed := true
	while changed:
		changed = false
		if JOIN_ROOMS.has(zone) and reached.has(JOIN_ROOMS[zone][0]):
			var element: int = DataPaths.load_character(JOIN_ROOMS[zone][1]).element
			if not elements.has(element):
				elements.append(element)
				changed = true
		for id: StringName in reached.keys():
			var room: Room = rooms[id]
			for side: int in Room.ALL_SIDES:
				if not (room.door_sides & side):
					continue
				var neighbor: Room = null
				for other: Room in rooms.values():
					if other.grid_cell == room.grid_cell + Room.side_offset(side) and other.door_sides & Room.opposite(side):
						neighbor = other
				if neighbor == null or reached.has(neighbor.room_id):
					continue
				var gate := _door_gate(room, side)
				if gate == null:
					gate = _door_gate(neighbor, Room.opposite(side))
				if gate and not elements.has(gate.get_required_element()):
					continue
				reached[neighbor.room_id] = true
				changed = true
	var targets: Array[StringName] = []
	for step: Dictionary in StoryManager.data["main_quest"]:
		if StringName(str(step["target"]["zone"])) == zone:
			targets.append(StringName(str(step["target"]["room"])))
	var boss_room: StringName = &""
	for room: Room in rooms.values():
		if room.room_type == Room.RoomType.BOSS:
			boss_room = room.room_id
	var all_targets := targets.all(func(t: StringName) -> bool: return reached.has(t))
	_check(reached.has(boss_room) and all_targets,
			"%s: không kẹt – tới được boss và mọi mục tiêu nhiệm vụ chính chỉ với đội miễn phí (%d/%d phòng)" % [
				zone, reached.size(), rooms.size()])
	var door_gates_free := true
	var gacha_chests := 0
	for node in root.find_children("*", "ElementalObstacle", true, false):
		var obstacle := node as ElementalObstacle
		if String(obstacle.name).begins_with("DoorGate") and GACHA_ONLY.has(obstacle.kind):
			door_gates_free = false
		if String(obstacle.name).begins_with("NicheGate") and GACHA_ONLY.has(obstacle.kind):
			gacha_chests += 1
	_check(door_gates_free and gacha_chests >= 2, "%s: cổng ở cửa không cần nhân vật gacha; %d rương ẩn cần nhân vật gacha" % [
			zone, gacha_chests])
	root.free()


func _door_gate(room: Room, side: int) -> ElementalObstacle:
	return room.find_child("DoorGate%d" % side, true, false) as ElementalObstacle


# --- Chơi cốt truyện (logic) ---

func _claim(encounter_id: String) -> void:
	var encounter := load("res://data/encounters/%s.tres" % encounter_id) as EncounterData
	Loot.claim_encounter(encounter)


func _step_id() -> String:
	return str(StoryManager.get_main_step().get("id", "done"))


func _test_story_playthrough() -> void:
	StoryManager.auto_play = true
	_new_story()
	_check(GameState.owned_characters == ([&"traveler"] as Array[StringName]) and GameState.team.size() == 1,
			"Game mới: chỉ có nhân vật chính")
	_check(GameState.current_map_scene == StoryManager.get_zone_scene(&"hub"), "Game mới bắt đầu ở Sảnh Trung Tâm")
	_check(not GachaManager.is_unlocked() and not QuestManager.is_unlocked(), "Gacha + nhiệm vụ ngày còn khóa")
	StoryManager.map_ready(&"hub")
	_check(StoryManager.played.has("p0_wake") and GameState.owned_characters.has(&"mira") and GameState.team.has(&"mira"),
			"Mở đầu: tỉnh dậy, Mira gia nhập đội")
	_check(_step_id() == "tutorial", "Nhiệm vụ chính: dẹp quái ở Sân Tập")
	_check(StoryManager.fire(&"hub_training") and not StoryManager.fire(&"hub_training"), "Cảnh Sân Tập chạy đúng một lần")
	_claim("prologue_tutorial")
	_check(_flag("prologue_battle_won") and StoryManager.get_pending() == ["p0_after_battle"], "Thắng trận hướng dẫn: cảnh sau trận chờ về map")
	StoryManager.map_ready(&"hub")
	_check(_flag("prologue_done") and _step_id() == "orwen1", "Sau trận: hướng dẫn xong, đi gặp ông Orwen")
	_check(StoryManager.get_gate_destinations().is_empty(), "Chưa gặp Orwen: Cổng chưa có khu nào")
	StoryManager.talk(&"orwen")
	var gate := StoryManager.get_gate_destinations()
	_check(gate.size() == 1 and gate[0]["zone"] == &"library", "Gặp Orwen: Cổng mở Thư Viện")
	# Chương 1.
	StoryManager.map_ready(&"library")
	_check(_flag("library_entered") and _step_id() == "kiri", "Vào Thư Viện: tìm nguồn tiếng nổ")
	StoryManager.talk(&"kiri")
	_check(GameState.owned_characters.has(&"kiri") and GameState.team.has(&"kiri") and not _flag("chapter_1_complete"),
			"Chương 1: Kiri gia nhập (trước khi hết chương)")
	_check(StoryManager.npc_dialogue(&"kiri").is_empty(), "Kiri gia nhập rồi thì không nói lại cảnh gia nhập")
	StoryManager.fire(&"library_map")
	StoryManager.fire(&"library_boss")
	_check(_step_id() == "boss1", "Tìm sơ đồ xong: hạ boss Thư Viện")
	var tickets := GameState.get_item_count(&"wish_ticket_limited")
	var tears := GameState.get_item_count(&"star_tear")
	_claim("library_boss_warden")
	StoryManager.map_ready(&"library")
	_check(_flag("chapter_1_complete") and StoryManager.played.has("c1_boss_post"), "Hạ boss: cảnh kết Chương 1 (ảo ảnh Celestine)")
	_check(GachaManager.is_unlocked() and QuestManager.is_unlocked(), "Hết Chương 1: mở Gacha + nhiệm vụ ngày")
	_check(GameState.get_item_count(&"wish_ticket_limited") - tickets == 13
			and GameState.get_item_count(&"star_tear") - tears == 400 + 100,
			"Thưởng chương 400 Lệ Tinh + 3 Vé Giới Hạn, quà mở Gacha 10 Vé Giới Hạn (+100 Lệ Tinh boss lần đầu)")
	_check(GameState.get_eidolon_level(&"traveler") == 1, "Mảnh Hồn 1 → Tinh Mệnh 1 của nhân vật chính")
	_check(_step_id() == "orwen2" and StoryManager.get_side_steps().is_empty(), "Về gặp Orwen; chưa có nhiệm vụ phụ")
	# Chương 2.
	StoryManager.talk(&"orwen")
	_check(StoryManager.get_gate_destinations().size() == 2, "Cổng mở Kho Chứa")
	StoryManager.map_ready(&"vault")
	for id in GameState.team:
		GameState.character_progress[String(id)] = {"level": 15, "ascension": 1}
	StoryManager.talk(&"garren")
	_check(GameState.team.size() == 4 and GameState.team.has(&"garren"), "Chương 2: Garren gia nhập, đội đủ 4 người")
	var paths: Array[int] = []
	for data in GameState.get_team_data():
		paths.append(data.path)
	_check(paths.has(CharacterPath.Type.ABUNDANCE) and paths.has(CharacterPath.Type.PRESERVATION)
			and paths.has(CharacterPath.Type.HARMONY) and paths.has(CharacterPath.Type.DESTRUCTION),
			"Đội từ Chương 2 đủ vị trí: sát thương, hồi máu, buff, đỡ đòn")
	_check(Progression.get_level(&"garren") == 15 and Progression.get_ascension(&"garren") == 1,
			"Nhân vật gia nhập ở cấp trung bình của đội (Garren cấp 15, đã đột phá 1 lần)")
	StoryManager.fire(&"vault_boss")
	_claim("vault_boss_behemoth")
	StoryManager.map_ready(&"vault")
	_check(_flag("chapter_2_complete") and GameState.get_eidolon_level(&"traveler") == 2, "Hết Chương 2: Tinh Mệnh 2")
	# Nhiệm vụ phụ 1 → Tinh Mệnh 5.
	var sides := StoryManager.get_side_steps()
	_check(sides.size() == 1 and sides[0]["step"]["id"] == "sq1_talk", "Nhiệm vụ phụ 1 mở sau Chương 2")
	StoryManager.talk(&"lio")
	_check(StoryManager.fire(&"sq1_diary"), "Nhặt nhật ký sau tường nứt")
	StoryManager.talk(&"lio")
	_check(_flag("sq1_done") and _flag("soul_shard_5") and StoryManager.is_side_quest_done("sq1"),
			"Nhiệm vụ phụ 1 xong: Mảnh Hồn 5")
	# Chương 3.
	StoryManager.talk(&"orwen")
	StoryManager.map_ready(&"furnace")
	StoryManager.talk(&"nyx")
	_check(GameState.owned_characters.has(&"nyx") and not _flag("chapter_3_complete"), "Chương 3: Nyx gia nhập")
	_check(GameState.owned_characters.size() == 5, "Đủ 4 nhân vật miễn phí + nhân vật chính")
	StoryManager.fire(&"furnace_boss")
	_claim("furnace_boss_core")
	StoryManager.map_ready(&"furnace")
	_check(_flag("chapter_3_complete") and _flag("soul_shard_3"), "Hết Chương 3: Mảnh Hồn 3")
	StoryManager.talk(&"bram")
	StoryManager.fire(&"sq2_core")
	StoryManager.talk(&"bram")
	_check(_flag("sq2_done") and _flag("soul_shard_6"), "Nhiệm vụ phụ 2 xong: Mảnh Hồn 6")
	# Chương 4.
	StoryManager.talk(&"orwen")
	_check(StoryManager.get_gate_destinations().size() == 4, "Cổng mở đủ 4 khu")
	StoryManager.map_ready(&"tower")
	StoryManager.fire(&"tower_summit")
	StoryManager.fire(&"tower_boss")
	_check(_step_id() == "boss4", "Đỉnh Tháp: đối đầu Kẻ Nuốt Mảnh Hồn")
	_claim("tower_boss_devourer")
	StoryManager.map_ready(&"tower")
	_check(_flag("chapter_4_complete") and _flag("story_complete") and _step_id() == "done",
			"Hết Chương 4: vết nứt mở, nhiệm vụ chính hoàn thành")
	_check(GameState.get_eidolon_level(&"traveler") == 6, "Nhân vật chính đủ Tinh Mệnh 6 (4 chương + 2 nhiệm vụ phụ)")
	_check(QuestManager.granted_chapters == ([1, 2, 3, 4] as Array[int]), "Nhận đủ thưởng 4 chương")
	# Đánh lại boss sau khi hạ không chạy lại cảnh.
	StoryManager.played.clear()
	_claim("tower_boss_devourer")
	_check(StoryManager.get_pending().is_empty(), "Đánh lại boss không chạy lại cảnh kết chương")
	StoryManager.auto_choices["boss_difficulty"] = 1
	_check(await StoryManager.play("boss_difficulty") == "hard", "Hộp chọn mức Khó trả về 'hard'")
	StoryManager.auto_choices.clear()


# --- Hộp thoại ---

func _test_dialogue_box() -> void:
	StoryManager.auto_play = false
	get_tree().paused = false
	var box := StoryManager.box
	var result: Array = []
	var run := func() -> void: result.append(await StoryManager.play("p0_orwen"))
	run.call()
	await _frames(2)
	_check(box.is_open() and get_tree().paused and box.is_typing(), "Mở hộp thoại: chữ chạy, game tạm dừng")
	box.advance()
	_check(not box.is_typing(), "Bấm khi đang chạy chữ: hiện hết câu")
	box.advance()
	_check(box.index == 1, "Bấm lần nữa: sang câu sau")
	box.skip()
	_check(box.has_choices(), "Bỏ qua: dừng ở lựa chọn")
	box.choose(1)
	_check(box.history.any(func(e: Dictionary) -> bool: return str(e["text"]).contains(tr("DLG_P0_ORWEN_C4_2"))),
			"Lịch sử ghi lại lựa chọn")
	box.toggle_history()
	_check(box._history_panel.visible, "Mở bảng lịch sử")
	box.toggle_history()
	box.skip()
	await _frames(2)
	_check(not box.is_open() and not get_tree().paused and result.size() == 1, "Hết cảnh: đóng hộp thoại, game chạy lại")
	# Phím cũng tiến được.
	run.call()
	await _frames(1)
	var key := InputEventKey.new()
	key.keycode = KEY_SPACE
	key.pressed = true
	Input.parse_input_event(key)
	await _frames(2)
	_check(not box.is_typing(), "Phím Space hiện hết câu")
	box.skip()
	box.choose(0)
	box.skip()
	await _frames(1)
	_check(not box.is_open(), "Đóng sau khi bỏ qua hết")


# --- Chạy trên map thật ---

func _go(scene: String, payload: Dictionary = {}) -> OverworldMap:
	SceneRouter.go_to(scene, payload, 0.01)
	await SceneRouter.transition_finished
	await _frames(6)
	return get_tree().current_scene as OverworldMap


func _test_world() -> void:
	StoryManager.auto_play = true
	_new_story()
	var map := await _go(DataPaths.HUB_SCENE)
	_check(map != null and map.room_manager.get_room(&"H04").get_world_rect().has_point(map.player.global_position),
			"Game mới: xuất hiện ở phòng y tế (H04)")
	_check(_flag("prologue_awake") and GameState.team.has(&"mira"), "Cảnh tỉnh dậy tự chạy khi vào Sảnh, Mira gia nhập")
	var tutorial := map.find_child("TutorialEnemy", true, false) as OverworldEnemy
	_check(tutorial and tutorial.visible and tutorial.is_in_group(Room.ENEMY_GROUP), "Quái hướng dẫn hiện ra sau khi tỉnh dậy")
	var target: Variant = map.get_quest_target_position()
	var training := map.room_manager.get_room(&"H02")
	_check(target is Vector2 and training.get_world_rect().has_point(target), "Mũi tên chỉ về Sân Tập")
	await _frames(2)
	_check(map.hud.quest_tracker.text.contains(tr("QUEST_MAIN_TUTORIAL")), "Góc màn hình hiện nhiệm vụ chính")
	GameState.set_story_flag(&"prologue_done")
	await _frames(1)
	_check(not tutorial.visible and not tutorial.is_in_group(Room.ENEMY_GROUP), "Xong hướng dẫn: quái hướng dẫn ẩn")
	# Cổng Dịch Chuyển.
	map.open_station(Station.Kind.GATE)
	_check(map.hud.panel_overlay != null and get_tree().paused, "Cổng Dịch Chuyển mở bảng (tạm dừng game)")
	map.hud.close_panel()
	StoryManager.talk(&"orwen")
	target = map.get_quest_target_position()
	var gate_node := map.find_child("StationGate", true, false) as Node2D
	_check(target is Vector2 and (target as Vector2).distance_to(gate_node.global_position) < 1.0,
			"Mục tiêu ở khu khác: mũi tên chỉ về Cổng Dịch Chuyển")
	map.open_station(Station.Kind.GATE)
	var menu := map.hud.panel_overlay.find_children("*", "TravelMenu", true, false)[0] as TravelMenu
	_check(menu.destinations.size() == 1, "Cổng có Thư Viện")
	menu.get_buttons()[0].pressed.emit()
	await SceneRouter.transition_finished
	await _frames(8)
	map = get_tree().current_scene as OverworldMap
	_check(map.scene_file_path == StoryManager.get_zone_scene(&"library") and map.room_manager.current_room
			and map.room_manager.current_room.room_id == &"L01", "Tới Thư Viện ở phòng L01")
	_check(_flag("library_entered") and GameState.fast_travel.has("library/L01"), "Cảnh vào Thư Viện chạy; mở dịch chuyển nhanh L01")
	# Cổng nguyên tố: tường lửa cần Nước (Mira).
	var fire_wall := map.room_manager.get_room(&"L04").find_child("DoorGate8", true, false) as ElementalObstacle
	_check(fire_wall and fire_wall.kind == ElementalObstacle.Kind.FIRE_WALL and not fire_wall.receive_opener(Element.Type.FIRE)
			and fire_wall.receive_opener(Element.Type.WATER), "Tường lửa chắn đường chỉ mở bằng Nước (Mira)")
	# Kiri.
	var kiri := map.find_child("NpcKiri", true, false) as Npc
	_check(kiri and kiri.visible and kiri.can_interact(), "Kiri chờ ở L04")
	kiri.interact(map.player)
	await _frames(1)
	_check(GameState.team.has(&"kiri") and not kiri.visible, "Nói chuyện: Kiri gia nhập, NPC biến mất")
	# Hồi quái khi vào lại khu.
	var enemy := map.room_manager.get_room(&"L02").find_child("Enemy1", true, false) as OverworldEnemy
	var enemy_id := map._persistent_id(enemy)
	GameState.record_defeat(map.scene_file_path, enemy_id, EncounterData.Kind.NORMAL, &"library")
	GameState.map_state_add(map.scene_file_path, "defeated_enemies", enemy_id)
	# Phòng nghỉ: hồi + lưu + bảng dịch chuyển nhanh về Sảnh.
	var rest := map.room_manager.get_room(&"L01").find_child("RestPoint", true, false) as RestPoint
	rest.interact(map.player)
	_check(map.hud.panel_overlay != null and SaveManager.has_save(SaveManager.AUTOSAVE_SLOT), "Điểm nghỉ: tự lưu, mở dịch chuyển nhanh")
	menu = map.hud.panel_overlay.find_children("*", "TravelMenu", true, false)[0] as TravelMenu
	_check(menu.destinations[0]["room"] == &"H01", "Dịch chuyển nhanh có Sảnh Trung Tâm")
	menu.get_buttons()[0].pressed.emit()
	await SceneRouter.transition_finished
	await _frames(6)
	map = get_tree().current_scene as OverworldMap
	_check(map.scene_file_path == DataPaths.HUB_SCENE and not get_tree().paused, "Về Sảnh, game chạy lại")
	map = await _go(StoryManager.get_zone_scene(&"library"), {"spawn_room": &"L01"})
	_check(not GameState.map_state_has(map.scene_file_path, "defeated_enemies", enemy_id), "Vào lại khu: quái thường hồi lại")
	# Đánh lại boss: hỏi mức Khó.
	GameState.mark_first_clear("library_boss_warden")
	var boss := map.room_manager.get_room(&"L11").find_child("Enemy1", true, false) as OverworldEnemy
	StoryManager.auto_choices["boss_difficulty"] = 1
	map._on_encounter_triggered(boss, BattleTypes.Opening.NORMAL)
	_check(bool(SceneRouter.payload.get("hard_mode", false)), "Đánh lại boss: chọn Khó → vào trận mức Khó")
	StoryManager.auto_choices.clear()
	await SceneRouter.transition_finished
	var battle := get_tree().current_scene
	battle.debug_force_result(true)
	await _frames(2)
	GameState.pending_battle.clear()
	map = await _go(DataPaths.HUB_SCENE, {"spawn_room": &"H01"})
	# Lưu / tải giữ cờ và dịch chuyển nhanh.
	SaveManager.save_game(1)
	var flags := GameState.story_flags.duplicate(true)
	GameState.reset_new_game()
	SaveManager.load_game(1)
	_check(GameState.story_flags == flags and GameState.fast_travel.has("library/L01") and GameState.team.has(&"kiri"),
			"Lưu/tải giữ cờ cốt truyện, dịch chuyển nhanh, đội")
	StoryManager.auto_play = false


func _test_shop() -> void:
	GameState.inventory.clear()
	GameState.add_item(&"aether_coin", 100000)
	var shop := ShopScreen.load_shop()
	var bought := 0
	for i in 10:
		if ShopScreen.buy(shop, &"technique_box"):
			bought += 1
	_check(bought == 3 and GameState.get_item_count(&"technique_box") == 3 and GameState.get_item_count(&"aether_coin") == 100000 - 1800,
			"Quầy hàng: Hộp Bí Kỹ 600 Xu, tối đa 3 lần/ngày")
	_check(ShopScreen.remaining(shop, &"soul_memory_2") == 5, "Ký Ức bậc 2: 5 lần/ngày")


func _test_economy_report() -> void:
	var report := EconomyReport.generate()
	_check(report["ok"], "Báo cáo kinh tế ĐẠT, kể cả mục F (bản đồ khớp kế hoạch khu)")
	_check(str(report["text"]).contains("## F. Bản đồ khớp kế hoạch khu"), "Báo cáo có mục F")
