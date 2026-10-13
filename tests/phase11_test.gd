extends "res://tests/test_base.gd"
## Kiểm thử Phase 11: dữ liệu 2 banner, đường tỉ lệ 5★, giả lập 1.000.000 lượt mỗi banner (tỉ lệ 5★, lượt trung
## bình mỗi 5★, tỉ lệ Celestine, không chuỗi > 90 lượt không 5★ / > 10 lượt không 4★), bảo hiểm cứng + bảo đảm
## 50/50, vé theo banner + đổi Lệ Tinh, nhân vật trùng → Tinh Mệnh / Bụi Sao, nhân vật mới vào đội hình, chọn 5★
## sau 300 lượt, kế thừa bộ đếm giữa banner giới hạn, lưu/tải giữa chừng (bộ đếm, 50/50, RNG), cửa hàng Bụi Sao
## theo tháng (+ chống chỉnh giờ), quà mở Gacha, màn Gacha (quay, sao băng, bỏ qua, đổi Lệ Tinh, cửa hàng).
## Chạy: godot --headless --path . res://tests/phase11_test.tscn
## Chỉ giả lập: godot --headless --path . res://tests/phase11_test.tscn -- --sim-only

const SAVE_DIR: String = "user://test_phase11_saves"
const SIM_PULLS: int = 1000000
const STANDARD: StringName = &"standard"
const LIMITED: StringName = &"limited_celestine"
const STANDARD_5: Array[StringName] = [&"ignar", &"marisol", &"raiko", &"zephyra", &"vesper", &"sylvaine", &"orrin"]
const ALL_4: Array[StringName] = [&"mira", &"kiri", &"garren", &"nyx", &"quill", &"aldric", &"rook", &"fenna",
		&"kestrel", &"vael", &"wisp", &"selka", &"ember", &"neris", &"pip", &"echo"]

## Thứ Tư 2026-10-14 10:00 (giờ địa phương = UTC trong test).
var _wed: int = 0


func _run() -> void:
	phase_name = "Phase 11"
	timeout_sec = 600.0
	SaveManager.save_dir = SAVE_DIR
	GachaManager.autosave = false
	QuestManager.autosave_on_claim = false
	QuestManager.utc_bias_minutes = 0
	_wed = _unix(2026, 10, 14, 10)
	_set_clock(_wed, true)
	GameState.reset_new_game()
	_test_data()
	_test_rate_curve()
	_test_simulation(STANDARD)
	_test_simulation(LIMITED)
	if not OS.get_cmdline_user_args().has("--sim-only"):
		_test_forced_pity()
		_test_unlock_and_gift()
		_test_tickets()
		_test_dupes_and_team()
		_test_selector()
		_test_inherit_limited_pity()
		_test_save_load_mid()
		_test_shop()
		await _test_screen()
	_cleanup()
	_finish()


# --- Tiện ích ---

func _unix(year: int, month: int, day: int, hour: int, minute: int = 0) -> int:
	return Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": day, "hour": hour,
			"minute": minute, "second": 0})


func _set_clock(unix: int, forget_last_seen: bool = false) -> void:
	QuestManager.now_override = unix
	if forget_last_seen:
		QuestManager.last_seen_unix = 0


func _new_game(unlocked: bool = true) -> void:
	_set_clock(_wed, true)
	GameState.reset_new_game()
	if unlocked:
		GameState.set_story_flag(GachaManager.config.unlock_flag)


func _banner(id: StringName) -> BannerData:
	return GachaManager.get_banner(id)


func _cleanup() -> void:
	QuestManager.now_override = -1
	QuestManager.last_seen_unix = 0
	GachaManager.autosave = true
	QuestManager.autosave_on_claim = true
	for slot in SaveManager.get_all_slots():
		SaveManager.delete_slot(slot)
	SaveManager.save_dir = "user://saves"
	GameState.reset_new_game()


# --- Dữ liệu ---

func _test_data() -> void:
	var config := GachaManager.config
	_check(config != null and config.banners.size() == 2, "GachaConfig có 2 banner")
	var standard := _banner(STANDARD)
	var limited := _banner(LIMITED)
	_check(standard != null and not standard.is_limited() and standard.featured_5.is_empty(),
			"Banner thường \"%s\": không có 5★ nổi bật" % tr(standard.name_key))
	_check(standard.pool_5 == STANDARD_5, "Banner thường: 5★ là đúng 7 nhân vật thường (mục 8)")
	_check(standard.pool_4.size() == 16 and _same_set(standard.pool_4, ALL_4), "Banner thường: 16 nhân vật 4★")
	_check(standard.selector_pulls == 300, "Banner thường: chọn 5★ sau 300 lượt")
	_check(limited.is_limited() and limited.featured_5 == ([&"celestine"] as Array[StringName]),
			"Banner giới hạn \"%s\": Celestine nổi bật" % tr(limited.name_key))
	_check(limited.featured_4.size() == 3 and _is_subset(limited.featured_4, limited.pool_4),
			"Banner giới hạn: 3 nhân vật 4★ nổi bật nằm trong 16 nhân vật 4★ (%s)" % [limited.featured_4])
	_check(limited.pool_5 == STANDARD_5 and _same_set(limited.pool_4, ALL_4),
			"Banner giới hạn: lệch 50/50 ra 1 trong 7 nhân vật 5★ thường / 13 nhân vật 4★ còn lại")
	_check(standard.ticket_item == &"wish_ticket_standard" and limited.ticket_item == &"wish_ticket_limited",
			"Vé Thường cho banner thường, Vé Giới Hạn cho banner giới hạn")
	_check(standard.pity_group != limited.pity_group, "Bộ đếm bảo hiểm tách riêng 2 banner")
	var rarity_ok := true
	for id in standard.pool_5 + limited.featured_5:
		var data := GachaManager.get_character(id)
		rarity_ok = rarity_ok and data != null and data.rarity == 5 and data.in_gacha_pool
	for id in standard.pool_4:
		var data := GachaManager.get_character(id)
		rarity_ok = rarity_ok and data != null and data.rarity == 4 and data.in_gacha_pool
	_check(rarity_ok, "Mọi nhân vật trong banner có dữ liệu, đúng hạng 5★/4★")
	for banner: BannerData in [standard, limited]:
		_check(is_equal_approx(banner.base_rate_5, 0.006) and banner.soft_pity_start == 74
				and is_equal_approx(banner.soft_pity_step, 0.06) and banner.hard_pity_5 == 90
				and is_equal_approx(banner.base_rate_4, 0.051) and banner.hard_pity_4 == 10,
				"%s: 5★ 0,6%% / +6%% từ lượt 74 / chắc chắn 90; 4★ 5,1%% / chắc chắn mỗi 10 lượt" % banner.id)
		var items_ok := not banner.three_star_rewards.is_empty()
		for entry in banner.three_star_rewards:
			items_ok = items_ok and str(entry["item"]) in ["soul_memory_1", "soul_memory_2", "soul_memory_3", "aether_coin"]
		_check(items_ok, "%s: vật phẩm 3★ là Ký Ức Mảnh Hồn hoặc Xu Aether" % banner.id)
	_check(config.currency_per_ticket == 160 and config.currency_item == &"star_tear", "160 Lệ Tinh đổi 1 vé")
	_check(int(config.dupe_stardust[5]) == 40 and int(config.dupe_stardust[4]) == 8, "Trùng: 5★ +40, 4★ +8 Bụi Sao")
	var shop_ok := config.shop_entries.size() == 2
	for entry in config.shop_entries:
		shop_ok = shop_ok and int(entry["price"]) == 20 and int(entry["monthly_limit"]) == 5
	_check(shop_ok, "Cửa hàng Bụi Sao: 20 Bụi Sao/vé, tối đa 5 Vé Thường + 5 Vé Giới Hạn mỗi tháng")
	_check(QuestManager.config.gacha_open_gift == {"wish_ticket_limited": 10}, "Quà mở Gacha: 10 Vé Giới Hạn")
	for key in ["MENU_GACHA", "GACHA_PULL_10", "GACHA_SHOP", "BANNER_STANDARD", "BANNER_LIMITED_CELESTINE"]:
		_check(tr(key) != key, "Có chữ dịch %s" % key)


func _same_set(a: Array[StringName], b: Array[StringName]) -> bool:
	return a.size() == b.size() and _is_subset(a, b)


func _is_subset(a: Array[StringName], b: Array[StringName]) -> bool:
	for id in a:
		if not b.has(id):
			return false
	return true


func _test_rate_curve() -> void:
	var banner := _banner(STANDARD)
	_check(is_equal_approx(banner.rate_5_at(1), 0.006) and is_equal_approx(banner.rate_5_at(73), 0.006),
			"Tỉ lệ 5★ lượt 1–73: 0,6%")
	_check(is_equal_approx(banner.rate_5_at(74), 0.066) and is_equal_approx(banner.rate_5_at(80), 0.426),
			"Tỉ lệ 5★ lượt 74: 6,6%, lượt 80: 42,6% (cộng 6%/lượt)")
	_check(is_equal_approx(banner.rate_5_at(90), 1.0), "Lượt 90: chắc chắn 5★")


# --- Giả lập 1.000.000 lượt ---

func _test_simulation(banner_id: StringName) -> void:
	var banner := _banner(banner_id)
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261013 + hash(banner_id)
	var state := GachaManager.new_pity_state()
	var start := Time.get_ticks_msec()
	var count_5 := 0
	var count_4 := 0
	var featured_5 := 0
	var featured_4 := 0
	var since_5 := 0
	var since_4 := 0
	var since_featured := 0
	var max_gap_5 := 0
	var max_gap_4 := 0
	var max_gap_featured := 0
	var lost_then_featured := true
	var pending_guarantee := false
	var per_char: Dictionary = {}
	var items: Dictionary = {}
	for i in SIM_PULLS:
		var result := GachaManager.roll(banner, state, rng)
		var rarity: int = result["rarity"]
		since_5 += 1
		since_4 += 1
		since_featured += 1
		if rarity == 3:
			for item_id: String in result["items"]:
				items[item_id] = int(items.get(item_id, 0)) + 1
			continue
		max_gap_4 = maxi(max_gap_4, since_4)
		since_4 = 0
		var id: StringName = result["character"]
		per_char[id] = int(per_char.get(id, 0)) + 1
		if rarity == 4:
			count_4 += 1
			if result["featured"]:
				featured_4 += 1
			continue
		count_5 += 1
		max_gap_5 = maxi(max_gap_5, since_5)
		since_5 = 0
		if pending_guarantee and not result["featured"]:
			lost_then_featured = false
		pending_guarantee = result["lost"]
		if result["featured"]:
			featured_5 += 1
			max_gap_featured = maxi(max_gap_featured, since_featured)
			since_featured = 0
	var elapsed := (Time.get_ticks_msec() - start) / 1000.0
	var rate_5 := float(count_5) / SIM_PULLS
	var rate_4 := float(count_4) / SIM_PULLS
	var avg_5 := float(SIM_PULLS) / maxf(count_5, 1.0)
	print("  --- Giả lập %s: %d lượt (%.1f giây) ---" % [banner_id, SIM_PULLS, elapsed])
	print("      5★: %d (%.3f%%), trung bình %.2f lượt / 5★, chuỗi không 5★ dài nhất %d" % [count_5, rate_5 * 100.0,
			avg_5, max_gap_5])
	print("      4★: %d (%.3f%%), chuỗi không 4★+ dài nhất %d" % [count_4, rate_4 * 100.0, max_gap_4])
	_check(rate_5 > 0.0155 and rate_5 < 0.0165, "%s: tỉ lệ 5★ tổng %.3f%% ≈ 1,6%% (có bảo hiểm)" % [banner_id, rate_5 * 100.0])
	_check(avg_5 > 60.0 and avg_5 < 64.5, "%s: trung bình %.2f lượt mỗi 5★" % [banner_id, avg_5])
	_check(max_gap_5 <= 90, "%s: không chuỗi nào quá 90 lượt không có 5★ (dài nhất %d)" % [banner_id, max_gap_5])
	_check(max_gap_4 <= 10, "%s: không chuỗi nào quá 10 lượt không có 4★ trở lên (dài nhất %d)" % [banner_id, max_gap_4])
	_check(rate_4 > 0.112 and rate_4 < 0.122, "%s: tỉ lệ 4★ tổng %.2f%% (5,1%% + bảo hiểm 10 lượt, lý thuyết ≈ 11,7%%)" % [banner_id, rate_4 * 100.0])
	_check(items.size() == banner.three_star_rewards.size(), "%s: ra đủ các loại vật phẩm 3★ %s" % [banner_id, items])
	if banner.is_limited():
		var share := float(featured_5) / count_5
		var featured_rate := float(featured_5) / SIM_PULLS
		print("      Celestine: %d (%.3f%% mỗi lượt, %.1f%% số 5★, trung bình %.1f lượt), cách nhau tối đa %d lượt" % [
				featured_5, featured_rate * 100.0, share * 100.0, 1.0 / featured_rate, max_gap_featured])
		print("      4★ nổi bật: %.1f%% số 4★" % [100.0 * featured_4 / count_4])
		_check(share > 0.655 and share < 0.678, "Celestine chiếm %.1f%% số 5★ (lý thuyết 2/3 nhờ bảo đảm)" % (share * 100.0))
		_check(featured_rate > 0.0103 and featured_rate < 0.011, "Tỉ lệ ra Celestine %.3f%% mỗi lượt" % (featured_rate * 100.0))
		_check(max_gap_featured <= 180, "Celestine chắc chắn trong 180 lượt (dài nhất %d)" % max_gap_featured)
		_check(lost_then_featured, "Lệch 50/50 thì lần 5★ kế tiếp luôn là Celestine")
		var share_4 := float(featured_4) / count_4
		_check(share_4 > 0.655 and share_4 < 0.678, "4★ nổi bật chiếm %.1f%% số 4★ (50/50 + bảo đảm)" % (share_4 * 100.0))
		var off_ok := true
		for id: StringName in per_char:
			var data := GachaManager.get_character(id)
			if data.rarity == 5 and id != &"celestine":
				off_ok = off_ok and banner.pool_5.has(id)
		_check(off_ok, "Lệch 50/50 chỉ ra nhân vật 5★ thường")
	else:
		var even := true
		for id in banner.pool_5:
			var expected := count_5 / 7.0
			even = even and absf(int(per_char.get(id, 0)) - expected) < expected * 0.06
		_check(even, "Banner thường: 7 nhân vật 5★ ra đều nhau (±6%)")
		_check(not per_char.has(&"celestine"), "Banner thường không bao giờ ra Celestine")
		var even_4 := true
		for id in banner.pool_4:
			var expected := count_4 / 16.0
			even_4 = even_4 and absf(int(per_char.get(id, 0)) - expected) < expected * 0.04
		_check(even_4, "Banner thường: 16 nhân vật 4★ ra đều nhau (±4%)")


# --- Bảo hiểm ép ---

func _test_forced_pity() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var limited := _banner(LIMITED)
	var state := GachaManager.new_pity_state()
	state["pity_5"] = 89
	var result := GachaManager.roll(limited, state, rng)
	_check(int(result["rarity"]) == 5 and int(result["pity"]) == 90 and int(state["pity_5"]) == 0,
			"Lượt 90 chắc chắn 5★, bộ đếm về 0")
	var all_guaranteed := true
	for i in 200:
		state = GachaManager.new_pity_state()
		state["pity_5"] = 89
		state["guaranteed_5"] = true
		result = GachaManager.roll(limited, state, rng)
		all_guaranteed = all_guaranteed and result["character"] == &"celestine" and not state["guaranteed_5"]
	_check(all_guaranteed, "Đang bảo đảm → 5★ luôn là Celestine, xong thì bỏ bảo đảm (200 lần)")
	var four_ok := true
	for i in 200:
		state = GachaManager.new_pity_state()
		state["pity_4"] = 9
		state["guaranteed_4"] = true
		result = GachaManager.roll(limited, state, rng)
		if int(result["rarity"]) == 4:
			four_ok = four_ok and limited.featured_4.has(result["character"]) and not state["guaranteed_4"]
		else:
			four_ok = four_ok and int(result["rarity"]) == 5
	_check(four_ok, "Lượt 10 chắc chắn 4★+, đang bảo đảm 4★ → nhân vật 4★ nổi bật")


# --- Mở khóa, vé ---

func _test_unlock_and_gift() -> void:
	_new_game(false)
	GameState.add_item(&"wish_ticket_limited", 5)
	_check(not GachaManager.is_unlocked() and GachaManager.pull(LIMITED, 1).is_empty()
			and GameState.get_item_count(&"wish_ticket_limited") == 5, "Trước Chương 1: chưa quay được, không mất vé")
	GameState.add_item(&"wish_ticket_limited", -5)
	GameState.set_story_flag(&"chapter_1_complete")
	# Hết Chương 1: quà mở Gacha 10 + thưởng chương 3 Vé Giới Hạn (Phase 10).
	_check(GachaManager.is_unlocked() and GachaManager.open_gift_granted
			and GameState.get_item_count(&"wish_ticket_limited") == 13, "Hết Chương 1: mở Gacha, nhận 10 Vé Giới Hạn (+3 thưởng chương)")
	GameState.set_story_flag(&"chapter_1_complete")
	_check(GameState.get_item_count(&"wish_ticket_limited") == 13, "Quà mở Gacha chỉ nhận một lần")
	SaveManager.save_game(1)
	SaveManager.load_game(1)
	_check(GameState.get_item_count(&"wish_ticket_limited") == 13, "Tải lại save không nhận quà lần nữa")
	# Save cũ (trước Phase 11) đã qua Chương 1 nhưng chưa có quà: tải lên thì nhận bù.
	GameState.add_item(&"wish_ticket_limited", -13)
	GachaManager.from_dict({})
	_check(GameState.get_item_count(&"wish_ticket_limited") == 10, "Save cũ đã qua Chương 1: nhận bù quà mở Gacha khi tải")


func _test_tickets() -> void:
	_new_game()
	GameState.inventory.clear()
	GameState.add_item(&"wish_ticket_standard", 20)
	_check(GachaManager.pull(LIMITED, 1).is_empty() and GameState.get_item_count(&"wish_ticket_standard") == 20,
			"Vé Thường không dùng được cho banner giới hạn")
	GameState.add_item(&"wish_ticket_limited", 9)
	_check(GachaManager.pull(LIMITED, 10).is_empty() and GameState.get_item_count(&"wish_ticket_limited") == 9,
			"Thiếu vé: không quay, không trừ vé")
	_check(GachaManager.tickets_missing(_banner(LIMITED), 10) == 1 and not GachaManager.can_afford(_banner(LIMITED), 10),
			"Thiếu 1 vé, không đủ Lệ Tinh để đổi")
	GameState.add_item(&"star_tear", 170)
	_check(GachaManager.can_afford(_banner(LIMITED), 10), "Đủ Lệ Tinh đổi phần vé thiếu")
	_check(GachaManager.exchange_tickets(&"wish_ticket_limited", 1) and GameState.get_item_count(&"star_tear") == 10
			and GameState.get_item_count(&"wish_ticket_limited") == 10, "Đổi 160 Lệ Tinh lấy 1 Vé Giới Hạn")
	_check(not GachaManager.exchange_tickets(&"wish_ticket_standard", 1), "Thiếu Lệ Tinh: không đổi được")
	GameState.add_item(&"star_tear", 160)
	_check(not GachaManager.exchange_tickets(&"stardust", 1), "Chỉ đổi Lệ Tinh lấy vé, không lấy vật phẩm khác")
	_check(GachaManager.exchange_tickets(&"wish_ticket_standard", 1) and GameState.get_item_count(&"wish_ticket_standard") == 21,
			"Đổi 160 Lệ Tinh lấy 1 Vé Thường")
	var results := GachaManager.pull(LIMITED, 10)
	var has_4 := false
	for result in results:
		has_4 = has_4 or int(result["rarity"]) >= 4
	_check(results.size() == 10 and GameState.get_item_count(&"wish_ticket_limited") == 0,
			"Quay 10 banner giới hạn: 10 kết quả, trừ 10 Vé Giới Hạn")
	_check(has_4, "Quay 10 lần đầu có ít nhất 1 nhân vật 4★+")
	_check(GachaManager.get_history(LIMITED).size() == 10 and GachaManager.get_pull_count(LIMITED) == 10,
			"Lịch sử và tổng lượt banner giới hạn = 10")
	_check(GachaManager.get_history(STANDARD).is_empty(), "Lịch sử tách riêng từng banner")
	results = GachaManager.pull(STANDARD, 1)
	_check(results.size() == 1 and GameState.get_item_count(&"wish_ticket_standard") == 20, "Quay 1 banner thường trừ 1 Vé Thường")
	GameState.add_item(&"wish_ticket_standard", 200)
	for i in 12:
		GachaManager.pull(STANDARD, 10)
	_check(GachaManager.get_history(STANDARD).size() == 100 and GachaManager.get_pull_count(STANDARD) == 121,
			"Lịch sử giữ 100 lượt gần nhất (đã quay 121)")
	var newest: Dictionary = GachaManager.get_history(STANDARD)[0]
	_check(newest.has("rarity") and (newest.has("character") or newest.has("items")), "Lịch sử ghi hạng + nhân vật/vật phẩm")


# --- Trùng nhân vật ---

func _apply(id: StringName, rarity: int) -> Dictionary:
	var result := {"rarity": rarity, "character": id, "items": {}, "featured": false, "lost": false, "pity": 1}
	GachaManager._apply(result)
	return result


func _test_dupes_and_team() -> void:
	_new_game()
	GameState.inventory.clear()
	var first := _apply(&"ignar", 5)
	_check(bool(first["new"]) and GameState.owned_characters.has(&"ignar") and int(first["stardust"]) == 0
			and GameState.get_eidolon_level(&"ignar") == 0, "Nhân vật mới: vào danh sách sở hữu, Tinh Mệnh 0, không Bụi Sao")
	var eidolons_ok := true
	for n in range(1, 7):
		var dupe := _apply(&"ignar", 5)
		eidolons_ok = eidolons_ok and not bool(dupe["new"]) and int(dupe["eidolon"]) == n and int(dupe["stardust"]) == 40 \
				and GameState.get_eidolon_level(&"ignar") == n and not bool(dupe["overflow"])
	_check(eidolons_ok, "Trùng 5★ lần 1–6: Tinh Mệnh 1–6, mỗi lần +40 Bụi Sao")
	_check(GameState.get_item_count(&"stardust") == 240, "Đã có 240 Bụi Sao sau 6 lần trùng 5★")
	var seventh := _apply(&"ignar", 5)
	_check(bool(seventh["overflow"]) and int(seventh["stardust"]) == 140 and GameState.get_eidolon_level(&"ignar") == 6,
			"Trùng 5★ lần 7: giữ Tinh Mệnh 6, đổi thành Bụi Sao (40 + 100)")
	var mira := _apply(&"mira", 4)
	_check(not bool(mira["new"]) and int(mira["eidolon"]) == 1 and int(mira["stardust"]) == 8,
			"Trùng 4★ (Mira có sẵn): Tinh Mệnh 1, +8 Bụi Sao")
	for n in 6:
		_apply(&"mira", 4)
	_check(GameState.get_eidolon_level(&"mira") == 6 and GameState.get_item_count(&"stardust") == 380 + 8 * 6 + 28,
			"Trùng 4★ lần 7: Bụi Sao 8 + 20")
	var team_screen := TeamScreen.new()
	add_child(team_screen)
	team_screen.select_preset(GameState.active_preset)
	_check(not team_screen.toggle_character(&"raiko"), "Màn đội hình: chưa có Raiko thì không thêm được")
	team_screen.remove_slot(3)
	_check(team_screen.toggle_character(&"ignar") and team_screen.apply() and GameState.team.has(&"ignar"),
			"Màn đội hình: thêm Ignar nhận từ gacha vào đội và áp dụng")
	team_screen.queue_free()
	_check(GameState.get_eidolon_levels_for_battle().get(&"ignar", 0) == 6, "Trận đánh đọc đúng Tinh Mệnh 6 của Ignar")


# --- Chọn 5★ sau 300 lượt ---

func _test_selector() -> void:
	_new_game()
	var standard := _banner(STANDARD)
	GachaManager.pull_counts[String(STANDARD)] = 299
	_check(not GachaManager.can_claim_selector(standard), "299 lượt: chưa được chọn 5★")
	_check(not GachaManager.can_claim_selector(_banner(LIMITED)), "Banner giới hạn không có quà chọn 5★")
	GachaManager.pull_counts[String(STANDARD)] = 300
	_check(GachaManager.can_claim_selector(standard), "300 lượt: được chọn 5★")
	_check(GachaManager.claim_selector(STANDARD, &"celestine").is_empty(), "Không chọn được Celestine (chỉ 5★ thường)")
	var result := GachaManager.claim_selector(STANDARD, &"orrin")
	_check(not result.is_empty() and GameState.owned_characters.has(&"orrin"), "Chọn Orrin → nhận Orrin")
	_check(not GachaManager.can_claim_selector(standard) and GachaManager.claim_selector(STANDARD, &"raiko").is_empty(),
			"Quà chọn 5★ chỉ nhận một lần")


# --- Kế thừa bộ đếm sang banner giới hạn sau ---

func _test_inherit_limited_pity() -> void:
	_new_game()
	GameState.add_item(&"wish_ticket_limited", 100)
	GachaManager.get_pity(_banner(LIMITED))["guaranteed_5"] = true
	GachaManager.pull(LIMITED, 10)
	var before: Dictionary = GachaManager.get_pity(_banner(LIMITED)).duplicate()
	var next_banner := _banner(LIMITED).duplicate() as BannerData
	next_banner.id = &"limited_next"
	next_banner.featured_5 = [&"vesper"] as Array[StringName]
	GachaManager.config.banners.append(next_banner)
	var inherited := GachaManager.get_pity(next_banner)
	_check(inherited == before, "Banner giới hạn mới dùng chung bộ đếm + trạng thái bảo đảm (%s)" % [inherited])
	GachaManager.pull(&"limited_next", 1)
	_check(int(GachaManager.get_pity(_banner(LIMITED))["pity_5"]) == int(before["pity_5"]) + 1
			or int(GachaManager.get_pity(_banner(LIMITED))["pity_5"]) == 0, "Quay banner mới làm chạy bộ đếm chung")
	_check(int(GachaManager.get_pity(_banner(STANDARD))["pity_5"]) == 0, "Bộ đếm banner thường không đổi")
	GachaManager.config.banners.erase(next_banner)


# --- Lưu / tải giữa chừng ---

func _test_save_load_mid() -> void:
	_new_game()
	GameState.add_item(&"wish_ticket_limited", 5000)
	GameState.add_item(&"wish_ticket_standard", 100)
	# Quay tới khi lệch 50/50 (đang bảo đảm Celestine) và đang giữa chừng bộ đếm.
	var lost := false
	for i in 4000:
		GachaManager.pull(LIMITED, 1)
		var state := GachaManager.get_pity(_banner(LIMITED))
		lost = bool(state["guaranteed_5"])
		if lost and int(state["pity_5"]) >= 30:
			break
	GachaManager.pull(STANDARD, 37)
	var limited_state: Dictionary = GachaManager.get_pity(_banner(LIMITED)).duplicate()
	_check(lost and bool(limited_state["guaranteed_5"]), "Đã lệch 50/50, đang bảo đảm Celestine, bộ đếm 5★ = %d" % int(limited_state["pity_5"]))
	var snapshot := GachaManager.to_dict()
	_check(SaveManager.save_game(1), "Lưu giữa chừng")
	var after_a: Array = []
	for result in GachaManager.pull(LIMITED, 10):
		after_a.append([result["rarity"], result["character"], result["items"]])
	GachaManager.reset()
	GameState.reset_new_game()
	_check(int(GachaManager.get_pity(_banner(LIMITED))["pity_5"]) == 0, "Game mới xóa bộ đếm")
	_check(SaveManager.load_game(1), "Tải lại")
	var loaded := GachaManager.to_dict()
	_check(loaded["pity_state"] == snapshot["pity_state"], "Bộ đếm bảo hiểm + 50/50 giữ nguyên sau khi tải (%s)" % [loaded["pity_state"]])
	_check(loaded["pull_counts"] == snapshot["pull_counts"] and loaded["history"] == snapshot["history"],
			"Tổng lượt và lịch sử giữ nguyên sau khi tải")
	_check(bool(GachaManager.get_pity(_banner(LIMITED))["guaranteed_5"]), "Vẫn đang bảo đảm Celestine sau khi tải")
	var after_b: Array = []
	for result in GachaManager.pull(LIMITED, 10):
		after_b.append([result["rarity"], result["character"], result["items"]])
	_check(after_a == after_b, "RNG có seed lưu lại: 10 lượt sau khi tải giống hệt 10 lượt trước khi tải")
	# Save cũ (v3, lịch sử dạng mảng) vẫn tải được.
	GachaManager.from_dict({"pity_state": {}, "history": []})
	_check(GachaManager.history.is_empty() and GachaManager.pity_state.is_empty(), "Save cũ dạng v3 tải không lỗi")


# --- Cửa hàng Bụi Sao ---

func _test_shop() -> void:
	_new_game()
	GameState.inventory.clear()
	GameState.add_item(&"stardust", 300)
	_check(GachaManager.get_shop_remaining(&"wish_ticket_standard") == 5
			and GachaManager.get_shop_remaining(&"wish_ticket_limited") == 5, "Đầu tháng: mỗi loại vé còn 5 lần")
	var bought := 0
	for i in 6:
		if GachaManager.buy(&"wish_ticket_standard"):
			bought += 1
	_check(bought == 5 and GameState.get_item_count(&"wish_ticket_standard") == 5, "Mua tối đa 5 Vé Thường mỗi tháng")
	_check(GachaManager.buy(&"wish_ticket_limited", 5) and not GachaManager.buy(&"wish_ticket_limited"),
			"Mua tối đa 5 Vé Giới Hạn mỗi tháng")
	_check(GameState.get_item_count(&"stardust") == 100, "20 Bụi Sao mỗi vé (300 − 10 × 20 = 100)")
	_check(not GachaManager.buy(&"star_tear"), "Không mua được món không có trong cửa hàng")
	var expected := _unix(2026, 11, 1, 4) - _wed
	_check(GachaManager.seconds_until_shop_reset() == expected, "Làm mới 4:00 ngày 1 tháng sau (còn %d giây)" % expected)
	SaveManager.save_game(1)
	GameState.inventory.clear()
	GachaManager.shop_bought.clear()
	SaveManager.load_game(1)
	_check(GachaManager.get_shop_remaining(&"wish_ticket_standard") == 0, "Số lần đã mua giữ sau khi tải")
	_set_clock(_unix(2026, 11, 1, 3, 59))
	_check(GachaManager.get_shop_remaining(&"wish_ticket_standard") == 0, "1/11 3:59: chưa làm mới")
	_set_clock(_unix(2026, 11, 1, 4, 1))
	_check(GachaManager.get_shop_remaining(&"wish_ticket_standard") == 5
			and GachaManager.get_shop_remaining(&"wish_ticket_limited") == 5, "1/11 4:01: làm mới, mỗi loại lại 5 lần")
	GameState.add_item(&"stardust", 20)
	GachaManager.buy(&"wish_ticket_limited")
	_set_clock(_unix(2026, 10, 20, 10))
	_check(GachaManager.get_shop_remaining(&"wish_ticket_limited") == 4, "Chỉnh giờ lùi về tháng trước: không làm mới")
	_set_clock(_unix(2026, 12, 1, 5))
	_check(GachaManager.get_shop_remaining(&"wish_ticket_limited") == 5, "Sang tháng 12: làm mới")
	_set_clock(_wed, true)


# --- Màn Gacha ---

func _test_screen() -> void:
	_new_game(false)
	GameState.inventory.clear()
	var menu := GameMenu.new()
	add_child(menu)
	await _frames(2)
	menu.show_page(GameMenu.Page.GACHA)
	var screen := menu.gacha_screen
	await _frames(2)
	_check(screen.visible and screen.banner_id == LIMITED, "Menu → Ước Nguyện mở màn Gacha, banner giới hạn đầu tiên")
	_check(screen.get_pull_button(1).disabled and screen.get_pull_button(10).disabled, "Chưa hết Chương 1: nút quay bị khóa")
	GameState.set_story_flag(&"chapter_1_complete")
	screen.refresh()
	_check(not screen.get_pull_button(10).disabled, "Hết Chương 1: nút quay mở")
	_check(GameState.get_item_count(&"wish_ticket_limited") == 13, "Màn Gacha: nhận quà mở Gacha khi hết Chương 1")
	# Chỉ giữ 10 Vé Giới Hạn để kiểm tra các nhánh thiếu vé phía sau.
	GameState.inventory.clear()
	GameState.add_item(&"wish_ticket_limited", 10)
	screen.get_pull_button(10).pressed.emit()
	await _frames(2)
	var overlay := screen.overlay
	_check(overlay != null and overlay.results.size() == 10 and overlay.stage == GachaPullOverlay.Stage.METEORS,
			"Bấm Quay 10: hiện sao băng cho 10 kết quả")
	_check(GameState.get_item_count(&"wish_ticket_limited") == 0, "Quay 10 trừ đủ 10 Vé Giới Hạn")
	var colors_ok := GachaPullOverlay.rarity_color(3).b > 0.9 and GachaPullOverlay.rarity_color(4).r > 0.6 \
			and GachaPullOverlay.rarity_color(5).r > 0.9 and GachaPullOverlay.rarity_color(5).b < 0.5
	_check(colors_ok, "Màu sao băng: xanh 3★, tím 4★, vàng 5★")
	overlay.advance()
	await _frames(2)
	_check(overlay.stage == GachaPullOverlay.Stage.REVEAL and overlay.reveal_queue.size() >= 1,
			"Bấm qua sao băng → màn nhận nhân vật (%d nhân vật 4★+)" % overlay.reveal_queue.size())
	overlay.skip()
	await _frames(2)
	_check(overlay.stage == GachaPullOverlay.Stage.SUMMARY, "Bỏ qua → tổng kết")
	overlay.close()
	await _frames(2)
	_check(screen.overlay == null, "Đóng tổng kết")
	screen.show_side(GachaScreen.Pane.HISTORY)
	_check(screen._side_list.get_child_count() == 1, "Thẻ lịch sử hiện các lượt đã quay")
	# Thiếu vé, đủ Lệ Tinh → hỏi đổi rồi quay.
	GameState.add_item(&"star_tear", 160)
	screen.get_pull_button(1).pressed.emit()
	await _frames(2)
	_check(screen.confirm_box != null and screen.overlay == null, "Thiếu vé, đủ Lệ Tinh: hỏi đổi trước khi quay")
	screen.confirm_exchange(1)
	await _frames(2)
	_check(screen.overlay != null and GameState.get_item_count(&"star_tear") == 0, "Đồng ý: đổi 160 Lệ Tinh rồi quay 1")
	# Sao băng tự hết rồi sang màn nhận / tổng kết.
	await _seconds(GachaPullOverlay.METEOR_TIME + 0.4)
	_check(screen.overlay.stage != GachaPullOverlay.Stage.METEORS, "Sao băng tự kết thúc sau %.1f giây" % GachaPullOverlay.METEOR_TIME)
	screen.close_popups()
	await _frames(2)
	screen.get_pull_button(1).pressed.emit()
	await _frames(2)
	_check(screen.confirm_box == null and screen.overlay == null, "Thiếu cả vé lẫn Lệ Tinh: không quay")
	# Cửa hàng (các lượt quay trước có thể ra nhân vật trùng → đã có Bụi Sao, nên đặt lại đúng 40).
	GameState.add_item(&"stardust", 40 - GameState.get_item_count(&"stardust"))
	screen.show_side(GachaScreen.Pane.SHOP)
	var buy := screen.get_shop_button(&"wish_ticket_standard")
	_check(buy != null and not buy.disabled, "Cửa hàng: nút mua Vé Thường")
	buy.pressed.emit()
	await _frames(1)
	_check(GameState.get_item_count(&"wish_ticket_standard") == 1 and GameState.get_item_count(&"stardust") == 20,
			"Bấm mua: −20 Bụi Sao, +1 Vé Thường")
	screen.select_banner(STANDARD)
	_check((screen._side_buttons[GachaScreen.Pane.SELECTOR] as Button).visible, "Banner thường có nút Chọn 5★")
	screen.show_side(GachaScreen.Pane.DETAILS)
	_check(screen._side_list.get_child_count() >= 5, "Thẻ tỉ lệ hiện tỉ lệ, nhóm nhân vật, luật trùng")
	# Màn nhận nhân vật mới có tranh gacha.
	var card_overlay := GachaPullOverlay.new()
	card_overlay.setup([{"rarity": 5, "character": &"celestine", "items": {}, "featured": true, "lost": false, "pity": 80,
			"new": true, "eidolon": 0, "overflow": false, "stardust": 0}] as Array[Dictionary])
	add_child(card_overlay)
	card_overlay.advance()
	await _frames(3)
	_check(card_overlay._card != null and card_overlay._card.data.id == &"celestine", "Màn nhận nhân vật mới hiện tranh gacha Celestine")
	card_overlay.close()
	menu.close()
	await _frames(2)
