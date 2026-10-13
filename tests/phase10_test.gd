extends "res://tests/test_base.gd"
## Kiểm thử Phase 10: vật phẩm mục 11, bảng rơi đồ (quái thường / tinh anh / boss / mức Khó / rương, giả lập
## nhiều lần so với kỳ vọng), thưởng lần hạ đầu, boss 3 lần/ngày rồi chỉ xu, hồi quái (rời khu, tinh anh mỗi ngày),
## bảng chi phí, nhiệm vụ ngày/tuần (khóa trước Chương 1, làm mới 4:00, thứ Hai, chống chỉnh giờ lùi), thành tựu,
## quà đăng nhập, thưởng chương, nhận thưởng vào túi đồ + lưu, màn nhiệm vụ + chấm đỏ, thưởng trận thật / thắng ngay /
## rương trên map, báo cáo kinh tế.
## Chạy: godot --headless --path . res://tests/phase10_test.tscn

const SAVE_DIR: String = "user://test_phase10_saves"
const NORMAL_ENC: String = "res://data/encounters/library_01_sprouts.tres"
const ELITE_ENC: String = "res://data/encounters/library_elite_librarian.tres"
const BOSS_ENC: String = "res://data/encounters/library_boss_warden.tres"
const SIMULATIONS: int = 4000
const HOUR: int = 3600
const DAY: int = 86400

## Thứ Tư 2026-10-14 10:00 (giờ địa phương = UTC trong test).
var _wed: int = 0


func _run() -> void:
	phase_name = "Phase 10"
	timeout_sec = 300.0
	SaveManager.save_dir = SAVE_DIR
	QuestManager.utc_bias_minutes = 0
	_wed = Time.get_unix_time_from_datetime_dict({"year": 2026, "month": 10, "day": 14, "hour": 10, "minute": 0, "second": 0})
	_set_clock(_wed, true)
	GameState.reset_new_game()
	_test_items_and_costs()
	_test_loot_rolls()
	_test_claim_rules()
	_test_respawn_state()
	_test_daily_quests()
	_test_reset_and_anti_cheat()
	_test_weekly()
	_test_one_time_rewards()
	_test_save_load()
	await _test_quest_screen()
	await _test_map_rewards()
	await _test_battle_rewards()
	_test_economy_report()
	_cleanup()
	_finish()


# --- Tiện ích ---

func _set_clock(unix: int, forget_last_seen: bool = false) -> void:
	QuestManager.now_override = unix
	if forget_last_seen:
		QuestManager.last_seen_unix = 0


func _new_game() -> void:
	_set_clock(_wed, true)
	GameState.reset_new_game()


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _avg(encounter: EncounterData, options: Dictionary, item_id: String) -> float:
	var total := 0.0
	var opts := options.duplicate()
	opts["rng"] = _rng(11)
	for i in SIMULATIONS:
		total += float(Loot.roll_encounter(encounter, opts).get(item_id, 0))
	return total / SIMULATIONS


func _near(value: float, expected: float, tolerance: float = 0.06) -> bool:
	return absf(value - expected) <= maxf(absf(expected) * tolerance, 0.02)


func _cleanup() -> void:
	QuestManager.now_override = -1
	QuestManager.last_seen_unix = 0
	QuestManager.autosave_on_claim = true
	for slot in SaveManager.get_all_slots():
		SaveManager.delete_slot(slot)
	SaveManager.save_dir = "user://saves"


# --- Vật phẩm, chi phí ---

func _test_items_and_costs() -> void:
	print("--- Vật phẩm mục 11 và bảng chi phí ---")
	var ids: Array[String] = ["aether_coin", "soul_memory_1", "soul_memory_2", "soul_memory_3", "warp_core", "star_tear",
			"wish_ticket_standard", "wish_ticket_limited", "stardust", "technique_box"]
	for element in Element.all():
		ids.append(String(Progression.crystal_id(element)))
	for path: int in CharacterPath.Type.values():
		for tier in [1, 2, 3]:
			ids.append(String(Progression.sigil_id(path, tier)))
	var missing := ids.filter(func(id: String) -> bool: return UiKit.get_item(StringName(id)) == null)
	_check(missing.is_empty() and ids.size() == 38, "Đủ 38 ItemData cho mọi tài nguyên mục 11 (thiếu: %s)" % [missing])
	var cfg := ProgressionConfig.get_config()
	_check(cfg.exp_to_next.size() >= GameConfig.MAX_LEVEL - 1 and cfg.max_skill_level == 5 and cfg.skill_costs.size() == 4,
			"Bảng chi phí: EXP cấp 1–30, kỹ năng tới cấp 5")
	var open_asc := cfg.ascensions.filter(func(a: AscensionData) -> bool: return not a.is_locked())
	_check(open_asc.size() == 2 and open_asc[0].at_level == 10 and open_asc[1].at_level == 20, "Đột phá ở cấp 10 và 20")
	var cost := EconomyReport.character_cost()
	_check(cost["exp"] == 50750.0 and cost["core"] == 4.0 and cost["crystal"] == 14.0,
			"Chi phí 1 nhân vật tối đa đọc từ dữ liệu: %d EXP, %d Xu, %d Lõi" % [cost["exp"], cost["coin"], cost["core"]])


# --- Bảng rơi đồ ---

func _test_loot_rolls() -> void:
	print("--- Bảng rơi đồ (giả lập %d lần) ---" % SIMULATIONS)
	var normal := load(NORMAL_ENC) as EncounterData
	var count := normal.get_total_enemy_count()
	_check(_near(_avg(normal, {}, "aether_coin"), 30.0 * count), "Quái thường: 20–40 Xu mỗi con (TB 30)")
	_check(_near(_avg(normal, {}, "soul_memory_1"), 0.6 * count), "Quái thường: 60% ra 1 Ký Ức bậc 1")
	var sigils := 0.0
	var team_paths: Array[StringName] = []
	for data in GameState.get_team_data():
		team_paths.append(Progression.sigil_id(data.path, 1))
	var wrong_path := false
	var rng := _rng(3)
	for i in SIMULATIONS:
		var items := Loot.roll_encounter(normal, {"rng": rng})
		for id: String in items:
			if id.begins_with("sigil_"):
				sigils += items[id]
				wrong_path = wrong_path or not team_paths.has(StringName(id))
	_check(_near(sigils / SIMULATIONS, 0.25 * count, 0.08) and not wrong_path,
			"Quái thường: 25% ra Dấu Ấn bậc 1, đúng vận mệnh của đội")
	var crystal := String(Progression.crystal_id(normal.get_leader().element))
	_check(_near(_avg(normal, {}, crystal), 0.03 * count, 0.25), "Quái thường: 3% ra Tinh Thể đúng nguyên tố quái")
	_check(Loot.roll_encounter(normal, {"rng": _rng(1), "first_clear": true}).get("star_tear", 0) == 0,
			"Quái thường không có thưởng lần đầu")

	var elite := load(ELITE_ENC) as EncounterData
	var elite_only := {"rng": _rng(5)}
	var coins_ok := true
	for i in 300:
		var items := Loot.roll_encounter(elite, elite_only)
		# 2 quái thường (20–40) + 1 tinh anh (200–300).
		coins_ok = coins_ok and items["aether_coin"] >= 240 and items["aether_coin"] <= 380 and items["soul_memory_2"] == 2
	_check(coins_ok, "Tinh anh: 200–300 Xu, 2 Ký Ức bậc 2 (cộng thêm quái thường đi kèm)")
	_check(_near(_avg(elite, {}, String(Progression.crystal_id(Element.Type.WIND))), 0.4 + 0.03 * 2, 0.15),
			"Tinh anh: 40% ra 1 Tinh Thể đúng nguyên tố")
	_check(Loot.roll_encounter(elite, {"rng": _rng(2), "first_clear": true}).get("star_tear", 0) == 20,
			"Tinh anh lần đầu: 20 Lệ Tinh")

	var boss := load(BOSS_ENC) as EncounterData
	var b := Loot.roll_encounter(boss, {"rng": _rng(7)})
	var boss_crystal := String(Progression.crystal_id(boss.get_boss().element))
	var t3 := 0
	for id: String in b:
		if id.begins_with("sigil_") and id.ends_with("_3"):
			t3 += b[id]
	_check(b["aether_coin"] == 1500 and b["soul_memory_3"] == 3 and t3 == 2 and b[boss_crystal] >= 3 and b[boss_crystal] <= 4,
			"Boss: 1500 Xu, 3 Ký Ức bậc 3, 2 Dấu Ấn bậc 3, 3–4 Tinh Thể nguyên tố boss")
	var first := Loot.roll_encounter(boss, {"rng": _rng(7), "first_clear": true})
	_check(first["star_tear"] == 100 and first["warp_core"] == 1, "Boss lần đầu: 100 Lệ Tinh + 1 Lõi Ma Biến")
	var hard := Loot.roll_encounter(boss, {"rng": _rng(7), "hard": true})
	_check(hard["aether_coin"] == 3000 and hard["soul_memory_3"] == 3 and hard["warp_core"] == 2,
			"Boss mức Khó: nguyên liệu ×2, thêm 2 Lõi Ma Biến, Ký Ức không đổi")
	var coins_only := Loot.roll_encounter(boss, {"rng": _rng(7), "coins_only": true})
	_check(coins_only.keys() == ["aether_coin"], "Boss hết lượt thưởng: chỉ còn Xu")

	var chest_lt := []
	for tier in 3:
		chest_lt.append(Loot.roll_chest(&"library", tier, _rng(4)).get("star_tear", 0))
	_check(chest_lt == [5, 10, 20], "Rương thường / quý / giải đố: 5 / 10 / 20 Lệ Tinh")
	var puzzle := Loot.roll_chest(&"tower", 2, _rng(4))
	_check(puzzle.get("aether_coin", 0) > 0 and puzzle.get("soul_memory_3", 0) > 0, "Rương kèm Xu và Ký Ức (khu sau nhiều hơn)")
	var team_crystals := 0
	for id: String in puzzle:
		if id.begins_with("crystal_"):
			team_crystals += puzzle[id]
	_check(team_crystals == 3, "Rương giải đố: 3 Tinh Thể theo nguyên tố đội")
	var unknown := Loot.roll_chest(&"no_such_zone", 0, _rng(4))
	_check(unknown.get("star_tear", 0) == 5, "Khu không có dữ liệu thì dùng bảng rương của khu đầu")


func _test_claim_rules() -> void:
	print("--- Lần đầu, giới hạn boss mỗi ngày ---")
	_new_game()
	var elite := load(ELITE_ENC) as EncounterData
	var lt := GameState.get_item_count(&"star_tear")
	var first := Loot.claim_encounter(elite, false, _rng(1))
	var second := Loot.claim_encounter(elite, false, _rng(1))
	_check(first["first_clear"] and not second["first_clear"] and GameState.get_item_count(&"star_tear") == lt + 20,
			"Lệ Tinh tinh anh chỉ ở lần hạ đầu tiên")
	var boss := load(BOSS_ENC) as EncounterData
	var cores := GameState.get_item_count(&"warp_core")
	var results: Array[bool] = []
	for i in 5:
		results.append(bool(Loot.claim_encounter(boss, false, _rng(i))["coins_only"]))
	_check(results == [false, false, false, true, true] and GameState.get_item_count(&"warp_core") == cores + 1,
			"Boss nhận đủ thưởng 3 lần mỗi ngày, sau đó chỉ cho Xu")
	_set_clock(_wed + DAY)
	_check(not bool(Loot.claim_encounter(boss, false, _rng(9))["coins_only"]), "Sang ngày mới (4:00) boss lại nhận đủ thưởng")
	var hard := Loot.claim_encounter(boss, true, _rng(9))
	_check(hard["hard"] and int(hard["items"].get("warp_core", 0)) == 2, "Thắng boss mức Khó nhận thêm Lõi Ma Biến")
	_set_clock(_wed, true)


func _test_respawn_state() -> void:
	print("--- Hồi quái ---")
	_new_game()
	var scene := "res://test_scene.tscn"
	var today := QuestManager.get_day_index()
	GameState.record_defeat(scene, "a/normal", EncounterData.Kind.NORMAL, &"library")
	GameState.record_defeat(scene, "a/boss", EncounterData.Kind.BOSS, &"library")
	GameState.record_defeat(scene, "a/elite", EncounterData.Kind.ELITE, &"library")
	GameState.record_defeat(scene, "b/normal", EncounterData.Kind.NORMAL, &"vault")
	_check(GameState.respawn_zone(scene, &"library") == 2 and not GameState.map_state_has(scene, "defeated_enemies", "a/normal")
			and GameState.map_state_has(scene, "defeated_enemies", "a/elite")
			and GameState.map_state_has(scene, "defeated_enemies", "b/normal"),
			"Rời khu: quái thường + boss của khu đó hồi lại, tinh anh và khu khác giữ nguyên")
	_check(GameState.respawn_daily(scene, today) == 0, "Tinh anh hạ hôm nay chưa hồi")
	_check(GameState.respawn_daily(scene, today + 1) == 1 and not GameState.map_state_has(scene, "defeated_enemies", "a/elite"),
			"Tinh anh hồi sang ngày hôm sau")


# --- Nhiệm vụ ---

func _quest(id: StringName) -> QuestData:
	return QuestManager.config.find(id)


func _clear_normal(times: int) -> void:
	var encounter := load(NORMAL_ENC) as EncounterData
	for i in times:
		Loot.claim_encounter(encounter, false, _rng(i))


func _do_all_daily() -> void:
	_clear_normal(3)
	Loot.claim_encounter(load(ELITE_ENC) as EncounterData, false, _rng(3))
	GameState.pending_battle = {"map_scene": "x"}
	for i in 5:
		EventBus.weakness_broken.emit(null, null)
	GameState.pending_battle.clear()
	EventBus.technique_used.emit(&"traveler")
	EventBus.technique_used.emit(&"traveler")
	EventBus.character_upgraded.emit(&"traveler")


func _test_daily_quests() -> void:
	print("--- Nhiệm vụ ngày ---")
	_new_game()
	QuestManager.autosave_on_claim = false
	_check(QuestManager.config.get_quests(QuestData.Type.DAILY).size() == 6 and QuestManager.get_daily_total() == 500,
			"6 nhiệm vụ ngày, tổng 500 Hoạt Động")
	_clear_normal(3)
	_check(not QuestManager.is_unlocked() and QuestManager.activity_points == 0
			and QuestManager.get_progress(_quest(&"daily_win_3")) == 0, "Trước Chương 1: nhiệm vụ ngày chưa mở, không tính tiến độ")
	_check(QuestManager.get_progress(_quest(&"ach_win_1")) == 1, "Thành tựu vẫn tính khi nhiệm vụ ngày chưa mở")
	GameState.set_story_flag(&"chapter_1_complete")
	_check(QuestManager.is_unlocked() and QuestManager.is_completed(_quest(&"daily_login")) and QuestManager.activity_points == 100,
			"Hết Chương 1 (cờ cốt truyện): mở nhiệm vụ ngày, Đăng nhập +100 Hoạt Động")
	var weakness_before := QuestManager.get_progress(_quest(&"daily_break_5"))
	EventBus.weakness_broken.emit(null, null)
	_check(QuestManager.get_progress(_quest(&"daily_break_5")) == weakness_before, "Phá khiên ở phòng thử / mô phỏng không tính")
	_do_all_daily()
	var all_done := true
	for quest in QuestManager.config.get_quests(QuestData.Type.DAILY):
		all_done = all_done and QuestManager.is_completed(quest)
	_check(all_done and QuestManager.activity_points == 500, "Làm đủ 6 nhiệm vụ → 500 Hoạt Động")
	_check(QuestManager.get_progress(_quest(&"weekly_full_days")) == 1, "Đủ 500 Hoạt Động tính 1 ngày cho nhiệm vụ tuần")
	_check(QuestManager.has_claimable(QuestData.Type.DAILY), "Có mốc chưa nhận → chấm đỏ thẻ Ngày")
	var lt := GameState.get_item_count(&"star_tear")
	var coins := GameState.get_item_count(&"aether_coin")
	var boxes := GameState.get_item_count(&"technique_box")
	for i in 5:
		QuestManager.claim_milestone(i)
	_check(GameState.get_item_count(&"star_tear") == lt + 100 and GameState.get_item_count(&"aether_coin") == coins + 10000
			and GameState.get_item_count(&"technique_box") == boxes + 1, "5 mốc: 10/15/20/25/30 = 100 Lệ Tinh + Xu + Ký Ức + 1 Hộp Bí Kỹ")
	_check(QuestManager.claim_milestone(0).is_empty() and not QuestManager.has_claimable(QuestData.Type.DAILY),
			"Không nhận mốc 2 lần, hết chấm đỏ")


func _test_reset_and_anti_cheat() -> void:
	print("--- Làm mới 4:00 và chống chỉnh giờ ---")
	# Đang ở thứ Tư 10:00, đã làm đủ nhiệm vụ.
	_set_clock(_wed + 17 * HOUR)  # Thứ Năm 3:00 – chưa tới 4:00.
	_check(not QuestManager.check_reset() and QuestManager.activity_points == 500, "Trước 4:00 sáng chưa làm mới")
	_set_clock(_wed + 18 * HOUR)  # Thứ Năm 4:00.
	_check(QuestManager.check_reset() and QuestManager.activity_points == 100 and QuestManager.claimed_milestones.is_empty()
			and QuestManager.get_progress(_quest(&"daily_win_3")) == 0, "Chỉnh giờ tiến qua 4:00: làm mới (chỉ còn Đăng nhập)")
	var day := QuestManager.day_index
	_clear_normal(2)
	_set_clock(_wed - 3 * DAY)  # Lùi giờ 3 ngày (qua nhiều mốc 4:00).
	_check(not QuestManager.check_reset() and QuestManager.day_index == day
			and QuestManager.get_progress(_quest(&"daily_win_3")) == 2, "Chỉnh giờ lùi: không làm mới, giữ tiến độ")
	_set_clock(_wed + 18 * HOUR + 5 * HOUR)  # Vẫn thứ Năm, sau mốc cũ.
	_check(not QuestManager.check_reset() and QuestManager.day_index == day, "Giờ quay lại cùng ngày: không làm mới")
	_set_clock(_wed + 18 * HOUR - 1)  # Vẫn trước mốc lớn nhất từng thấy.
	_check(not QuestManager.check_reset() and QuestManager.get_day_index() == day,
			"Chưa vượt mốc giờ cũ: kỳ ngày đứng yên (thưởng boss / tinh anh cũng không làm mới)")
	_set_clock(_wed + 2 * DAY)  # Thứ Sáu 10:00.
	_check(QuestManager.check_reset() and QuestManager.day_index == day + 1, "Giờ vượt mốc cũ sang ngày mới: làm mới bình thường")


func _test_weekly() -> void:
	print("--- Nhiệm vụ tuần ---")
	_new_game()
	QuestManager.autosave_on_claim = false
	GameState.set_story_flag(&"chapter_1_complete")
	# Thứ Tư → Chủ nhật: 5 ngày đủ 500 Hoạt Động.
	for d in 5:
		_set_clock(_wed + d * DAY)
		QuestManager.check_reset()
		_do_all_daily()
	var boss := load(BOSS_ENC) as EncounterData
	for i in 3:
		Loot.claim_encounter(boss, false, _rng(i))
	_clear_normal(30)
	_check(QuestManager.is_weekly_complete() and QuestManager.has_claimable(QuestData.Type.WEEKLY),
			"Đủ 5 ngày 500 Hoạt Động, hạ boss 3 lần, thắng 30 trận → thưởng tuần (chấm đỏ)")
	var before := [GameState.get_item_count(&"star_tear"), GameState.get_item_count(&"wish_ticket_limited"),
			GameState.get_item_count(&"wish_ticket_standard")]
	QuestManager.claim_weekly()
	_check(GameState.get_item_count(&"star_tear") == before[0] + 160 and GameState.get_item_count(&"wish_ticket_limited") == before[1] + 1
			and GameState.get_item_count(&"wish_ticket_standard") == before[2] + 1 and QuestManager.claim_weekly().is_empty(),
			"Thưởng tuần: 160 Lệ Tinh + 1 Vé Giới Hạn + 1 Vé Thường, nhận 1 lần")
	var sunday := _wed + 4 * DAY + 13 * HOUR  # Chủ nhật 23:00.
	_set_clock(sunday)
	QuestManager.check_reset()
	_set_clock(sunday + 4 * HOUR + 59 * 60)  # Thứ Hai 3:59.
	QuestManager.check_reset()
	_check(QuestManager.weekly_claimed, "Thứ Hai trước 4:00 chưa làm mới tuần")
	_set_clock(sunday + 5 * HOUR)  # Thứ Hai 4:00.
	QuestManager.check_reset()
	_check(not QuestManager.weekly_claimed and QuestManager.get_progress(_quest(&"weekly_win_30")) == 0,
			"Sáng thứ Hai 4:00 làm mới nhiệm vụ tuần")
	_set_clock(_wed, true)


func _test_one_time_rewards() -> void:
	print("--- Thành tựu, người mới, thưởng chương ---")
	_new_game()
	QuestManager.autosave_on_claim = false
	_clear_normal(1)
	var lt := GameState.get_item_count(&"star_tear")
	_check(QuestManager.has_claimable(QuestData.Type.ACHIEVEMENT) and not QuestManager.claim_quest(&"ach_win_1").is_empty()
			and GameState.get_item_count(&"star_tear") == lt + 20 and QuestManager.claim_quest(&"ach_win_1").is_empty(),
			"Thành tựu: nhận 20 Lệ Tinh một lần")
	var total := 0
	for quest in QuestManager.config.get_quests(QuestData.Type.ACHIEVEMENT):
		if quest.trigger != &"zone_explored":
			total += int(quest.rewards.get("star_tear", 0))
	_check(total == 800, "Thành tựu tổng 800 Lệ Tinh")
	QuestManager.report(&"zone_explored", 60, &"library")
	_check(not QuestManager.is_completed(_quest(&"explore_library")), "Khám phá 60% chưa xong")
	QuestManager.report(&"zone_explored", 100, &"library")
	_check(QuestManager.is_quest_claimable(_quest(&"explore_library")) and not QuestManager.is_completed(_quest(&"explore_vault")),
			"Khám phá 100% Thư Viện → 160 Lệ Tinh (khu khác chưa)")
	_check(QuestManager.login_days == 1 and QuestManager.is_quest_claimable(_quest(&"login_day_1"))
			and not QuestManager.is_quest_claimable(_quest(&"login_day_2")), "Người mới: ngày 1 nhận được, ngày 2 chưa")
	var tickets := 0
	for d in 7:
		_set_clock(_wed + d * DAY)
		QuestManager.check_reset()
	for quest in QuestManager.config.get_quests(QuestData.Type.NEWBIE):
		tickets += int(QuestManager.claim_quest(quest.id).get("wish_ticket_standard", 0))
	_check(QuestManager.login_days == 7 and tickets == 10, "Đăng nhập 7 ngày đầu: tổng 10 Vé Thường")
	var before := [GameState.get_item_count(&"star_tear"), GameState.get_item_count(&"wish_ticket_standard"),
			GameState.get_item_count(&"wish_ticket_limited")]
	GameState.set_story_flag(&"chapter_2_complete")
	GameState.set_story_flag(&"chapter_2_complete")
	_check(GameState.get_item_count(&"star_tear") == before[0] + 400 and GameState.get_item_count(&"wish_ticket_standard") == before[1] + 5
			and GameState.get_item_count(&"wish_ticket_limited") == before[2] + 3, "Hoàn thành chương: 400 Lệ Tinh + 5 Vé Thường + 3 Vé Giới Hạn, 1 lần")
	_set_clock(_wed, true)


func _test_save_load() -> void:
	print("--- Nhận thưởng được lưu ---")
	_new_game()
	QuestManager.autosave_on_claim = true
	GameState.set_story_flag(&"chapter_1_complete")
	QuestManager.claim_milestone(0)
	var lt := GameState.get_item_count(&"star_tear")
	_check(lt == 400 + 10 and SaveManager.has_save(SaveManager.AUTOSAVE_SLOT),
			"Hết Chương 1: 400 Lệ Tinh thưởng chương; nhận mốc 100 Hoạt Động: +10 Lệ Tinh và tự lưu")
	var points := QuestManager.activity_points
	var last_seen := QuestManager.last_seen_unix
	_new_game()
	_check(GameState.get_item_count(&"star_tear") == 0, "Game mới xóa túi đồ")
	_check(SaveManager.load_game(SaveManager.AUTOSAVE_SLOT), "Tải lại ô tự lưu")
	_check(GameState.get_item_count(&"star_tear") == lt and QuestManager.claimed_milestones.has(100)
			and QuestManager.activity_points == points and QuestManager.last_seen_unix >= last_seen
			and not QuestManager.is_milestone_claimable(0), "Tải lại: túi đồ, mốc đã nhận, Hoạt Động, mốc giờ được giữ")
	var saved := JSON.parse_string(FileAccess.get_file_as_string(SaveManager.get_slot_path(SaveManager.AUTOSAVE_SLOT))) as Dictionary
	_check(int(saved.get("version", 0)) >= 3 and (saved["game_state"] as Dictionary).has("loot_state"), "Save v3 có loot_state")
	QuestManager.autosave_on_claim = false


# --- Giao diện ---

func _test_quest_screen() -> void:
	print("--- Màn nhiệm vụ ---")
	_new_game()
	QuestManager.autosave_on_claim = false
	var menu := GameMenu.new()
	add_child(menu)
	await _frames(1)
	menu.show_page(GameMenu.Page.QUESTS)
	await _frames(1)
	var screen := menu.quest_screen
	_check(screen.visible and screen.get_claim_button("milestone_0") == null, "Trang Nhiệm vụ: thẻ Ngày khóa trước Chương 1")
	GameState.set_story_flag(&"chapter_1_complete")
	await _frames(1)
	var button := screen.get_claim_button("milestone_0")
	_check(button != null and not button.disabled and screen.has_tab_dot(QuestData.Type.DAILY),
			"Đủ 100 Hoạt Động: nút Nhận mốc 100 bật, chấm đỏ thẻ Ngày")
	var lt := GameState.get_item_count(&"star_tear")
	button.pressed.emit()
	await _frames(1)
	_check(GameState.get_item_count(&"star_tear") == lt + 10 and not screen.has_tab_dot(QuestData.Type.DAILY)
			and screen.get_claim_button("milestone_0").disabled, "Bấm Nhận: +10 Lệ Tinh, nút tắt, hết chấm đỏ")
	for type: int in [QuestData.Type.WEEKLY, QuestData.Type.ACHIEVEMENT, QuestData.Type.NEWBIE]:
		screen.show_tab(type)
		await _frames(1)
	_check(screen.get_claim_button("login_day_1") != null and not screen.get_claim_button("login_day_1").disabled
			and screen.has_tab_dot(QuestData.Type.NEWBIE), "Thẻ Người mới: quà ngày 1 nhận được, có chấm đỏ")
	var tickets := GameState.get_item_count(&"wish_ticket_standard")
	screen.get_claim_button("login_day_1").pressed.emit()
	await _frames(1)
	_check(GameState.get_item_count(&"wish_ticket_standard") == tickets + 2, "Bấm nhận quà ngày 1: +2 Vé Thường")
	menu.close()
	await _frames(1)


func _test_map_rewards() -> void:
	print("--- Rương, thắng ngay, hồi quái trên map ---")
	_new_game()
	QuestManager.autosave_on_claim = false
	SceneRouter.go_to(DataPaths.TEST_MAP_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
	var map := get_tree().current_scene as OverworldMap
	var chest: Chest = null
	for node in get_tree().get_nodes_in_group(Chest.GROUP):
		if (node as Chest).tier == Chest.Tier.PRECIOUS:
			chest = node
	var lt := GameState.get_item_count(&"star_tear")
	chest.open()
	await _frames(1)
	_check(chest.last_rewards.get("star_tear", 0) == 10 and GameState.get_item_count(&"star_tear") == lt + 10
			and map.hud.is_reward_popup_visible(), "Mở rương quý trên map: +10 Lệ Tinh, hiện bảng thưởng")
	_check(QuestManager.get_progress(_quest(&"ach_chests_30")) == 1, "Mở rương tính thành tựu")
	# Thắng ngay: quái yếu hơn đội ≥ 10 cấp.
	var enemy: OverworldEnemy = null
	for node in get_tree().get_nodes_in_group(OverworldEnemy.GROUP):
		var candidate := node as OverworldEnemy
		if candidate.encounter and candidate.encounter.get_max_level() <= 1:
			enemy = candidate
	var coins := GameState.get_item_count(&"aether_coin")
	GameState.team_level = 30
	map._instant_win(enemy)
	GameState.team_level = 0
	await _frames(1)
	_check(GameState.get_item_count(&"aether_coin") > coins and map.hud.is_reward_popup_visible(),
			"Thắng ngay: nhận Xu theo bảng rơi đồ")
	var enemy_id := map._persistent_id(enemy)
	_check(GameState.map_state_has(map.scene_file_path, "defeated_enemies", enemy_id), "Nhóm quái đã hạ được ghi lại")
	# Rời khu: đổi khu của phòng khác rồi đi vào → khu cũ hồi quái ở lần nạp map sau.
	var other := map.room_manager.get_room(&"chest_01")
	other.zone = &"vault"
	map.get_state()["current_zone"] = ""
	map._on_current_room_changed(other)
	SceneRouter.go_to(DataPaths.TEST_MAP_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
	_check(not GameState.map_state_has(DataPaths.TEST_MAP_SCENE, "defeated_enemies", enemy_id),
			"Rời khu rồi quay lại: quái thường hồi lại")


func _test_battle_rewards() -> void:
	print("--- Thưởng trận thật / phòng thử ---")
	var encounter := load(NORMAL_ENC) as EncounterData
	GameState.begin_battle(DataPaths.TEST_MAP_SCENE, "x/test", encounter, BattleTypes.Opening.NORMAL)
	SceneRouter.go_to(DataPaths.BATTLE_SCENE, {"encounter": encounter, "instant": true}, 0.01)
	await SceneRouter.transition_finished
	var scene := get_tree().current_scene
	var coins := GameState.get_item_count(&"aether_coin")
	scene.debug_force_result(true)
	await _frames(2)
	_check(not (scene.rewards as Dictionary).is_empty() and GameState.get_item_count(&"aether_coin") > coins,
			"Thắng trận thật: nhận thưởng theo bảng rơi đồ vào túi đồ")
	GameState.pending_battle.clear()
	var team: Array[CharacterData] = GameState.get_team_data()
	SceneRouter.go_to(DataPaths.BATTLE_SCENE, {"encounter": encounter, "instant": true, "team_override": team}, 0.01)
	await SceneRouter.transition_finished
	scene = get_tree().current_scene
	coins = GameState.get_item_count(&"aether_coin")
	scene.debug_force_result(true)
	await _frames(2)
	_check((scene.rewards as Dictionary).is_empty() and GameState.get_item_count(&"aether_coin") == coins,
			"Trận thử (đội ép sẵn): không có thưởng")
	SceneRouter.go_to(DataPaths.TITLE_SCENE, {}, 0.01)
	await SceneRouter.transition_finished


func _test_economy_report() -> void:
	print("--- Báo cáo kinh tế ---")
	var report := EconomyReport.generate()
	var model := load(EconomyReport.MODEL_PATH) as EconomyModel
	_check((report["errors"] as Array).is_empty(), "Dữ liệu kinh tế không có lỗi")
	_check(absf(report["onetime_pulls"] - 78.0) <= 7.8, "Nội dung một lần: %.1f lượt (mục tiêu 78 ±10%%)" % report["onetime_pulls"])
	_check(absf(report["monthly_pulls"] - 32.0) <= 3.2, "Nhiệm vụ mỗi tháng: %.1f lượt (mục tiêu 32 ±10%%)" % report["monthly_pulls"])
	var bottleneck: float = report["bottleneck"]
	_check(bottleneck >= model.target_characters_min * 0.9 and bottleneck <= model.target_characters_max * 1.1,
			"Toàn bản đồ nâng tối đa được %.2f nhân vật (mục tiêu 4–5)" % bottleneck)
	var pacing_ok := true
	for row: Dictionary in report["pacing"]:
		pacing_ok = pacing_ok and row["exp_ratio"] >= 0.9 and row["crystals_ok"]
	_check(pacing_ok and (report["pacing"] as Array).size() == 4, "Nhịp cốt truyện: đủ EXP và Tinh Thể cho cấp khuyến nghị cả 4 boss")
	_check(report["ok"], "Báo cáo kinh tế ĐẠT")
