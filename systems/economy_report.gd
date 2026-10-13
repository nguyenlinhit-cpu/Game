class_name EconomyReport
extends Node
## Báo cáo kinh tế (mục 11, 11b): đọc toàn bộ dữ liệu (bảng rơi đồ, kế hoạch khu, nhiệm vụ, chi phí tiến trình,
## giả định "chơi hết bản đồ" trong data/config/economy_model.tres) rồi:
##   A. Cộng mọi nguồn Lệ Tinh / vé một lần, quy ra lượt quay, so với bảng mục 11b (mục tiêu 78).
##   B. Nguồn lượt quay mỗi tháng (nhiệm vụ ngày, tuần, cửa hàng Bụi Sao), tách banner giới hạn / thường.
##   C. Cộng EXP, Xu, nguyên liệu toàn bản đồ, so với chi phí nâng 1 nhân vật tối đa → số nhân vật nâng được.
##   D. Nhịp cốt truyện: đội miễn phí có đủ EXP / Tinh Thể cho cấp khuyến nghị từng boss không.
##   E. Kiểm tra dữ liệu (thiếu bảng rơi đồ, vật phẩm không tồn tại, tổng nhiệm vụ).
##   F. Bản đồ thật (scenes/overworld/world/<khu>.tscn) khớp kế hoạch khu: số nhóm quái từng trận, rương từng bậc,
##      Hộp Bí Kỹ, số phòng; cốt truyện không cho thêm Lệ Tinh / vé ngoài thưởng chương.
## Chạy: godot --headless --path . res://systems/economy_report.tscn  (hoặc mở scene trong editor rồi F6)
## → in ra màn hình và ghi docs/ECONOMY_REPORT.md. Thoát mã 1 nếu lệch quá ngưỡng.

const MODEL_PATH: String = "res://data/config/economy_model.tres"
const OUTPUT_PATH: String = "res://docs/ECONOMY_REPORT.md"
const TRACE_TREE: String = "res://data/progression/traces/destruction.tres"
const STAR_TEAR: StringName = &"star_tear"
const TICKET_STANDARD: StringName = &"wish_ticket_standard"
const TICKET_LIMITED: StringName = &"wish_ticket_limited"
const GACHA_ITEMS: Array[StringName] = [&"star_tear", &"wish_ticket_standard", &"wish_ticket_limited", &"stardust"]
## Bảng mục 11b: lượt quay một lần theo nguồn.
const SPEC_ONETIME: Dictionary = {"story": 42.0, "newbie": 20.0, "achievements": 9.0, "firsts": 7.0}
const SPEC_DAILY_MONTHLY: float = 19.0
const SPEC_WEEKLY_MONTHLY: float = 13.0
## Celestine chắc chắn sau tối đa 180 lượt (mục 11b: trong 4–5 tháng).
const LIMITED_GUARANTEE_PULLS: float = 180.0
const RESOURCE_KEYS: Array[String] = ["exp", "coin", "crystal", "sigil_1", "sigil_2", "sigil_3", "core"]
const RESOURCE_NAMES: Dictionary = {
	"exp": "EXP (Ký Ức)", "coin": "Xu Aether", "crystal": "Tinh Thể (mọi nguyên tố)", "sigil_1": "Dấu Ấn bậc 1",
	"sigil_2": "Dấu Ấn bậc 2", "sigil_3": "Dấu Ấn bậc 3", "core": "Lõi Ma Biến",
}


func _ready() -> void:
	if get_tree().current_scene != self:
		return
	var report := EconomyReport.generate()
	print(report["text"])
	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file:
		file.store_string(report["text"])
		file.close()
		print("Đã ghi ", OUTPUT_PATH)
	get_tree().quit(0 if report["ok"] else 1)


## Trả về { "text": markdown, "ok": bool, "onetime_pulls", "monthly_pulls", "onetime": {nguồn: lượt},
## "coverage": { tài nguyên: số nhân vật }, "bottleneck", "pacing": [...], "errors": [...] }.
static func generate(model_path: String = MODEL_PATH) -> Dictionary:
	var model := load(model_path) as EconomyModel
	var quests := load(Loot.QUEST_CONFIG) as QuestConfig
	var out: Array[String] = []
	var result := {"errors": [], "warnings": []}
	out.append("# Báo cáo kinh tế")
	out.append("")
	out.append("Sinh tự động bởi `systems/economy_report.gd` từ dữ liệu trong `data/` – đừng sửa tay.")
	out.append("Chạy lại: `godot --headless --path . res://systems/economy_report.tscn`. Ngưỡng lệch cho phép: %d%%." % roundi(model.tolerance * 100))
	out.append("")
	var ok := true
	ok = _section_pulls(model, quests, out, result) and ok
	ok = _section_materials(model, quests, out, result) and ok
	_section_pacing(model, quests, out, result)
	ok = _section_checks(model, quests, out, result) and ok
	ok = _section_map(model, out, result) and ok
	out.append("")
	out.append("## Kết luận")
	out.append("")
	out.append("**%s**" % ("ĐẠT – mọi chỉ số trong ngưỡng." if ok else "CHƯA ĐẠT – xem các dòng ✗ và đề xuất ở trên."))
	result["ok"] = ok
	result["text"] = "\n".join(out) + "\n"
	return result


# --- A + B: lượt quay ---

static func _section_pulls(model: EconomyModel, quests: QuestConfig, out: Array[String], result: Dictionary) -> bool:
	var per_pull := float(model.star_tears_per_pull)
	# Một lần.
	var story := _scale(quests.chapter_reward, quests.chapter_count)
	var newbie: Dictionary = {}
	for quest in quests.get_quests(QuestData.Type.NEWBIE):
		_add(newbie, quest.rewards)
	_add(newbie, quests.gacha_open_gift)
	var achievements: Dictionary = {}
	var exploration: Dictionary = {}
	for quest in quests.get_quests(QuestData.Type.ACHIEVEMENT):
		_add(exploration if quest.trigger == &"zone_explored" else achievements, quest.rewards)
	var achievements_all := achievements.duplicate()
	_add(achievements_all, exploration)
	var boss_first: Dictionary = {}
	var elite_first: Dictionary = {}
	var chests: Dictionary = {}
	for zone in model.zones:
		for encounter in zone.encounters:
			var first := Loot.expected_encounter(encounter, {"first_clear_only": true})
			var target := boss_first if encounter.is_boss() else elite_first
			_add(target, _only(first, GACHA_ITEMS))
		for tier in zone.chest_counts.size():
			_add(chests, _only(Loot.expected_chest(zone.id, tier), GACHA_ITEMS), zone.chest_counts[tier])
	var firsts := boss_first.duplicate()
	_add(firsts, elite_first)
	_add(firsts, chests)
	var rows := [
		["story", "Cốt truyện %d chương (mỗi chương %s)" % [quests.chapter_count, _items_text(quests.chapter_reward)], story],
		["newbie", "Quà người mới (đăng nhập 7 ngày + quà mở Gacha – Phase 11 trao)", newbie],
		["achievements", "Thành tựu (%d Lệ Tinh) + khám phá 100%% (%d Lệ Tinh)" % [
				roundi(achievements.get("star_tear", 0)), roundi(exploration.get("star_tear", 0))], achievements_all],
		["firsts", "Boss lần đầu (%d), tinh anh lần đầu (%d), rương (%d Lệ Tinh)" % [roundi(boss_first.get("star_tear", 0)),
				roundi(elite_first.get("star_tear", 0)), roundi(chests.get("star_tear", 0))], firsts],
	]
	out.append("## A. Lượt quay từ nội dung một lần (mục 11b)")
	out.append("")
	out.append("| Nguồn | Lệ Tinh | Vé Thường | Vé Giới Hạn | Lượt quy đổi | Mục 11b | Lệch |")
	out.append("| --- | --- | --- | --- | --- | --- | --- |")
	var total: Dictionary = {}
	var ok := true
	var onetime: Dictionary = {}
	for row: Array in rows:
		var items: Dictionary = row[2]
		_add(total, items)
		var pulls := _pulls(items, per_pull)
		onetime[row[0]] = pulls
		var spec: float = SPEC_ONETIME[row[0]]
		out.append("| %s | %d | %d | %d | %.1f | %d | %s |" % [row[1], roundi(items.get("star_tear", 0)),
				roundi(items.get("wish_ticket_standard", 0)), roundi(items.get("wish_ticket_limited", 0)), pulls, spec,
				_dev_text(pulls, spec, model.tolerance)])
	var onetime_pulls := _pulls(total, per_pull)
	var onetime_ok := _within(onetime_pulls, model.target_onetime_pulls, model.tolerance)
	ok = ok and onetime_ok
	out.append("| **Tổng** | **%d** | **%d** | **%d** | **%.1f** | **%d** | **%s** |" % [roundi(total.get("star_tear", 0)),
			roundi(total.get("wish_ticket_standard", 0)), roundi(total.get("wish_ticket_limited", 0)), onetime_pulls,
			roundi(model.target_onetime_pulls), _dev_text(onetime_pulls, model.target_onetime_pulls, model.tolerance)])
	var lt_pulls := float(total.get("star_tear", 0)) / per_pull
	var limited_once := lt_pulls + float(total.get("wish_ticket_limited", 0))
	var standard_once := lt_pulls + float(total.get("wish_ticket_standard", 0))
	out.append("")
	out.append("Lệ Tinh dùng được cho cả hai banner; Vé Thường chỉ banner thường, Vé Giới Hạn chỉ banner giới hạn:")
	out.append("")
	out.append("- Dồn hết vào banner giới hạn: %.1f lượt (%.1f từ Lệ Tinh + %d Vé Giới Hạn); %d Vé Thường còn lại cho banner thường." % [
			limited_once, lt_pulls, roundi(total.get("wish_ticket_limited", 0)), roundi(total.get("wish_ticket_standard", 0))])
	out.append("- Dồn hết vào banner thường: %.1f lượt; %d Vé Giới Hạn còn lại cho banner giới hạn." % [
			standard_once, roundi(total.get("wish_ticket_limited", 0))])
	out.append("")

	# Mỗi tháng.
	var daily_day: Dictionary = {}
	for rewards in quests.daily_milestone_rewards:
		_add(daily_day, rewards)
	var daily_month := _scale(_only(daily_day, GACHA_ITEMS), model.days_per_month)
	var weekly_month := _scale(_only(quests.weekly_reward, GACHA_ITEMS), model.weeks_per_month)
	var daily_pulls := _pulls(daily_month, per_pull)
	var weekly_pulls := _pulls(weekly_month, per_pull)
	var monthly := daily_pulls + weekly_pulls
	var monthly_ok := _within(monthly, model.target_monthly_pulls, model.tolerance)
	ok = ok and monthly_ok
	out.append("## B. Lượt quay mỗi tháng (%d ngày, %.1f tuần)" % [roundi(model.days_per_month), model.weeks_per_month])
	out.append("")
	out.append("| Nguồn | Lệ Tinh | Vé Thường | Vé Giới Hạn | Lượt | Mục 11b | Lệch |")
	out.append("| --- | --- | --- | --- | --- | --- | --- |")
	out.append("| Nhiệm vụ ngày (%d Lệ Tinh/ngày) | %d | 0 | 0 | %.1f | %d | %s |" % [roundi(daily_day.get("star_tear", 0)),
			roundi(daily_month.get("star_tear", 0)), daily_pulls, roundi(SPEC_DAILY_MONTHLY),
			_dev_text(daily_pulls, SPEC_DAILY_MONTHLY, model.tolerance)])
	out.append("| Nhiệm vụ tuần (%s/tuần) | %d | %.1f | %.1f | %.1f | %d | %s |" % [_items_text(quests.weekly_reward),
			roundi(weekly_month.get("star_tear", 0)), weekly_month.get("wish_ticket_standard", 0.0),
			weekly_month.get("wish_ticket_limited", 0.0), weekly_pulls, roundi(SPEC_WEEKLY_MONTHLY),
			_dev_text(weekly_pulls, SPEC_WEEKLY_MONTHLY, model.tolerance)])
	out.append("| **Tổng nhiệm vụ** | | | | **%.1f** | **%d** | **%s** |" % [monthly, roundi(model.target_monthly_pulls),
			_dev_text(monthly, model.target_monthly_pulls, model.tolerance)])
	out.append("| Cửa hàng Bụi Sao (tối đa, cần nhân vật trùng – Phase 11) | | ≤ %d | ≤ %d | ≤ %d | ≤ 10 | |" % [
			roundi(model.stardust_monthly_max_pulls / 2), roundi(model.stardust_monthly_max_pulls / 2), roundi(model.stardust_monthly_max_pulls)])
	var lt_month := float(daily_month.get("star_tear", 0) + weekly_month.get("star_tear", 0)) / per_pull
	var limited_month := lt_month + float(weekly_month.get("wish_ticket_limited", 0))
	var standard_month := lt_month + float(weekly_month.get("wish_ticket_standard", 0))
	var stardust_half := model.stardust_monthly_max_pulls / 2.0
	var months_no_shop := maxf(LIMITED_GUARANTEE_PULLS - limited_once, 0.0) / limited_month
	var months_shop := maxf(LIMITED_GUARANTEE_PULLS - limited_once, 0.0) / (limited_month + stardust_half)
	out.append("")
	out.append("- Banner giới hạn mỗi tháng: %.1f lượt (Lệ Tinh %.1f + Vé Giới Hạn %.1f), thêm tối đa %d từ cửa hàng." % [
			limited_month, lt_month, weekly_month.get("wish_ticket_limited", 0.0), roundi(stardust_half)])
	out.append("- Banner thường mỗi tháng: %.1f lượt (nếu dồn Lệ Tinh vào đây), thêm tối đa %d từ cửa hàng." % [
			standard_month, roundi(stardust_half)])
	out.append("- Chắc chắn có Celestine (%d lượt) khi dồn mọi Lệ Tinh vào banner giới hạn: sau %.1f tháng (có cửa hàng: %.1f tháng). Mục 11b: 4–5 tháng." % [
			roundi(LIMITED_GUARANTEE_PULLS), months_no_shop, months_shop])
	out.append("")
	result["onetime_pulls"] = onetime_pulls
	result["onetime"] = onetime
	result["monthly_pulls"] = monthly
	result["limited_once"] = limited_once
	result["months_to_guarantee"] = months_no_shop
	return ok


# --- C: tài nguyên toàn bản đồ ---

static func _section_materials(model: EconomyModel, quests: QuestConfig, out: Array[String], result: Dictionary) -> bool:
	var sources := _material_sources(model, quests)
	var need := character_cost()
	out.append("## C. Tài nguyên toàn bản đồ so với chi phí nâng nhân vật (mục 11)")
	out.append("")
	out.append("Giả định \"chơi hết bản đồ\" (`data/config/economy_model.tres`): mỗi nhóm quái đặt trên map hạ 1 lần, mở hết rương, "
			+ "cày lại tối đa %d trận thường mỗi chương (~15 phút), đánh lại mỗi tinh anh %d ngày, mỗi boss %d lần thường + %d lần mức Khó, "
			% [model.grind_battles_per_chapter, model.elite_repeat_days, model.boss_repeat_runs, model.boss_hard_runs]
			+ "nhiệm vụ ngày/tuần và quà đăng nhập trong %d ngày chơi cốt truyện (nhiệm vụ mở từ ngày %d)." % [
			model.story_days, model.days_before_daily_unlock + 1])
	out.append("")
	var header := "| Nguồn |"
	var line := "| --- |"
	for key in RESOURCE_KEYS:
		header += " %s |" % RESOURCE_NAMES[key]
		line += " --- |"
	out.append(header)
	out.append(line)
	var total: Dictionary = {}
	for source: Array in sources:
		var summary := summarize(source[1])
		_add(total, summary)
		out.append(_resource_row(source[0], summary))
	out.append(_resource_row("**Tổng**", total, true))
	out.append(_resource_row("Chi phí 1 nhân vật tối đa", need))
	var coverage: Dictionary = {}
	var bottleneck := INF
	var bottleneck_key := ""
	for key in RESOURCE_KEYS:
		coverage[key] = float(total.get(key, 0.0)) / maxf(float(need.get(key, 1.0)), 0.001)
		if coverage[key] < bottleneck:
			bottleneck = coverage[key]
			bottleneck_key = key
	var cov_row := "| **Số nhân vật nâng tối đa được** |"
	for key in RESOURCE_KEYS:
		cov_row += " **%.2f** |" % coverage[key]
	out.append(cov_row)
	out.append("")
	var lo := model.target_characters_min * (1.0 - model.tolerance)
	var hi := model.target_characters_max * (1.0 + model.tolerance)
	var ok := bottleneck >= lo and bottleneck <= hi
	out.append("Mục tiêu: %.0f–%.0f nhân vật lên cấp %d, 4 kỹ năng cấp 5, đủ cây vận mệnh (chấp nhận %.1f–%.1f)." % [
			model.target_characters_min, model.target_characters_max, GameConfig.MAX_LEVEL, lo, hi])
	out.append("")
	out.append("- %s Nút thắt: **%s** → nâng tối đa được **%.2f** nhân vật." % ["✓" if ok else "✗", RESOURCE_NAMES[bottleneck_key], bottleneck])
	var suggestions: Array[String] = []
	for key in RESOURCE_KEYS:
		var value: float = coverage[key]
		if value > hi and key == "crystal":
			suggestions.append("- Dư %s (%.1f nhân vật): boss/tinh anh rơi đúng nguyên tố của chúng (mục 11) và đánh lại được, " % [RESOURCE_NAMES[key], value]
					+ "nên nguyên tố của boss dư còn nguyên tố khác chỉ có từ rương – xem bảng D. Không cần chỉnh.")
		elif value > hi:
			suggestions.append("- Dư %s (%.1f nhân vật, %.0f%% so với mức %.0f): phần thừa dùng cho nhân vật nhận thêm từ gacha. " % [
					RESOURCE_NAMES[key], value, (value / model.target_characters_max - 1.0) * 100.0, model.target_characters_max]
					+ _suggestion(key, value, model.target_characters_max))
		elif value < lo:
			suggestions.append("- ✗ Thiếu %s (%.1f nhân vật): %s" % [RESOURCE_NAMES[key], value, _suggestion(key, value, model.target_characters_min)])
	out.append_array(suggestions)
	out.append("")
	# Chi tiết theo nguyên tố / vận mệnh.
	var by_item: Dictionary = {}
	for source: Array in sources:
		_add(by_item, source[1])
	out.append("Tinh Thể (cần %d mỗi nhân vật cùng nguyên tố): %.0f theo nguyên tố đội đang dùng (rương) + rơi đúng nguyên tố quái:" % [
			need["crystal"], float(by_item.get(String(LootEntry.TEAM_CRYSTAL), 0.0))])
	out.append("")
	var parts: Array[String] = []
	for element in Element.all():
		parts.append("%s %.1f" % [TranslationServer.translate(Element.name_key(element)),
				float(by_item.get(String(Progression.crystal_id(element)), 0.0))])
	out.append("- " + " · ".join(parts))
	out.append("")
	out.append("Dấu Ấn luôn rơi theo vận mệnh của 1 nhân vật ngẫu nhiên trong đội đang dùng, nên tính chung theo bậc.")
	out.append("")
	result["coverage"] = coverage
	result["bottleneck"] = bottleneck
	result["bottleneck_key"] = bottleneck_key
	result["totals"] = total
	result["need"] = need
	return ok


## Danh sách [tên nguồn, { item_id: số lượng kỳ vọng }] cho mục C (bỏ tiền tệ gacha).
static func _material_sources(model: EconomyModel, quests: QuestConfig) -> Array:
	var placed: Dictionary = {}
	var firsts: Dictionary = {}
	var chests: Dictionary = {}
	var grind: Dictionary = {}
	var elites: Dictionary = {}
	var bosses: Dictionary = {}
	var hard: Dictionary = {}
	for zone in model.zones:
		for i in zone.encounters.size():
			var encounter := zone.encounters[i]
			_add(placed, Loot.expected_encounter(encounter), zone.get_placement_count(i))
			_add(firsts, Loot.expected_encounter(encounter, {"first_clear_only": true}))
			if encounter.kind == EncounterData.Kind.ELITE:
				_add(elites, Loot.expected_encounter(encounter), model.elite_repeat_days)
			elif encounter.is_boss():
				_add(bosses, Loot.expected_encounter(encounter), model.boss_repeat_runs)
				_add(hard, Loot.expected_encounter(encounter, {"hard": true}), model.boss_hard_runs)
		for tier in zone.chest_counts.size():
			_add(chests, Loot.expected_chest(zone.id, tier), zone.chest_counts[tier])
		_add(grind, zone_grind(zone, model))
	var timed := _story_days_rewards(model, quests, -1)
	return [
		["Quái đặt trên map (mỗi nhóm 1 lần)", _without(placed, GACHA_ITEMS)],
		["Thưởng hạ lần đầu (Lõi Ma Biến)", _without(firsts, GACHA_ITEMS)],
		["Rương", _without(chests, GACHA_ITEMS)],
		["Cày lại quái thường (≤ 15 phút/chương)", _without(grind, GACHA_ITEMS)],
		["Tinh anh hồi mỗi ngày (×%d ngày)" % model.elite_repeat_days, _without(elites, GACHA_ITEMS)],
		["Boss đánh lại mức thường (×%d)" % model.boss_repeat_runs, _without(bosses, GACHA_ITEMS)],
		["Boss mức Khó (×%d)" % model.boss_hard_runs, _without(hard, GACHA_ITEMS)],
		["Nhiệm vụ ngày/tuần + quà đăng nhập (%d ngày)" % model.story_days, _without(timed, GACHA_ITEMS)],
	]


## Thưởng trung bình của `grind_battles_per_chapter` trận thường trong khu (theo các trận thường của khu).
static func zone_grind(zone: ZoneData, model: EconomyModel) -> Dictionary:
	var sum: Dictionary = {}
	var enemies := 0
	for encounter in zone.encounters:
		if encounter.kind == EncounterData.Kind.NORMAL:
			_add(sum, Loot.expected_encounter(encounter))
			enemies += encounter.get_total_enemy_count()
	if enemies == 0:
		return {}
	return _scale(sum, model.grind_battles_per_chapter * model.grind_enemies_per_battle / enemies)


## Thưởng nhiệm vụ ngày (sau khi mở), tuần và quà đăng nhập theo ngày chơi cốt truyện.
## zone_index ≥ 0: chỉ những ngày rơi vào khu đó (chia đều số ngày cho 4 khu); −1 = mọi ngày.
static func _story_days_rewards(model: EconomyModel, quests: QuestConfig, zone_index: int) -> Dictionary:
	var result: Dictionary = {}
	var daily: Dictionary = {}
	for rewards in quests.daily_milestone_rewards:
		_add(daily, rewards)
	var logins := quests.get_quests(QuestData.Type.NEWBIE)
	var zone_count := maxi(model.zones.size(), 1)
	for day in model.story_days:
		if zone_index >= 0 and mini(day * zone_count / model.story_days, zone_count - 1) != zone_index:
			continue
		if day < logins.size():
			_add(result, logins[day].rewards)
		if day >= model.days_before_daily_unlock:
			_add(result, daily)
			if (day - model.days_before_daily_unlock) % 7 == 6:
				_add(result, quests.weekly_reward)
	return result


## Chi phí nâng 1 nhân vật tối đa theo dữ liệu tiến trình: { exp, coin, crystal, sigil_1..3, core }.
static func character_cost() -> Dictionary:
	var cfg := ProgressionConfig.get_config()
	var need := {"exp": 0.0, "coin": 0.0, "crystal": 0.0, "sigil_1": 0.0, "sigil_2": 0.0, "sigil_3": 0.0, "core": 0.0}
	for level in range(1, GameConfig.MAX_LEVEL):
		need["exp"] += cfg.exp_for_level(level)
	need["coin"] += need["exp"] * cfg.coin_per_exp
	for asc in cfg.ascensions:
		if asc.at_level < GameConfig.MAX_LEVEL and not asc.is_locked():
			need["coin"] += asc.coin
			need["crystal"] += asc.crystals
	for cost in cfg.skill_costs:
		if cost.level <= cfg.max_skill_level:
			need["coin"] += cost.coin * Progression.SKILL_KEYS.size()
			need["sigil_%d" % cost.sigil_tier] += cost.sigil_count * Progression.SKILL_KEYS.size()
			need["core"] += cost.warp_cores * Progression.SKILL_KEYS.size()
	var tree := load(TRACE_TREE) as TraceTreeData
	for node in tree.nodes:
		need["coin"] += node.coin
		need["sigil_%d" % node.sigil_tier] += node.sigil_count
	return need


## Gộp vật phẩm thành nhóm tài nguyên: { exp, coin, crystal, sigil_1..3, core }.
static func summarize(items: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for id: Variant in items:
		var text := str(id)
		if text == String(LootEntry.TEAM_CRYSTAL):
			_add(result, {"crystal": float(items[id])})
			continue
		if text.begins_with(LootEntry.TEAM_SIGIL_PREFIX):
			_add(result, {"sigil_" + text.trim_prefix(LootEntry.TEAM_SIGIL_PREFIX): float(items[id])})
			continue
		var item := UiKit.get_item(StringName(text))
		if item == null:
			continue
		var amount := float(items[id])
		var key := ""
		if item.exp_value > 0:
			_add(result, {"exp": amount * item.exp_value})
			continue
		if item.id == Progression.COIN:
			key = "coin"
		elif item.id == Progression.WARP_CORE:
			key = "core"
		elif item.category == ItemData.Category.ASCENSION:
			key = "crystal"
		elif item.category == ItemData.Category.SIGIL:
			key = "sigil_%d" % item.tier
		if not key.is_empty():
			_add(result, {key: amount})
	return result


# --- D: nhịp cốt truyện ---

static func _section_pacing(model: EconomyModel, quests: QuestConfig, out: Array[String], result: Dictionary) -> void:
	var cfg := ProgressionConfig.get_config()
	var team_size := mini(model.free_team.size(), GameConfig.MAX_TEAM_SIZE)
	out.append("## D. Nhịp cốt truyện: đội miễn phí có đủ cấp khuyến nghị boss không")
	out.append("")
	out.append("Cộng dồn tới trước mỗi boss: quái đặt trên map, tinh anh (cả %d ngày đánh lại), rương, %d trận cày lại, nhiệm vụ/quà theo ngày, boss các chương trước. " % [
			model.elite_repeat_days, model.grind_battles_per_chapter]
			+ "EXP cần = %d nhân vật lên cấp khuyến nghị; Tinh Thể cần = 1 nhân vật mỗi nguyên tố đội miễn phí đột phá đủ để tới cấp đó " % team_size
			+ "(Tinh Thể rương chia đều cho %d người trong đội)." % team_size)
	out.append("")
	var elements: Array[int] = []
	for id in model.free_team:
		var data := DataPaths.load_character(id)
		if data and not elements.has(data.element):
			elements.append(data.element)
	var header := "| Boss | Cấp khuyến nghị | EXP có | EXP cần | Tỉ lệ |"
	var line := "| --- | --- | --- | --- | --- |"
	for element in elements:
		header += " Tinh Thể %s |" % TranslationServer.translate(Element.name_key(element))
		line += " --- |"
	out.append(header)
	out.append(line)
	var running: Dictionary = {}
	var pacing: Array = []
	for zi in model.zones.size():
		var zone := model.zones[zi]
		var boss: EncounterData = null
		for i in zone.encounters.size():
			var encounter := zone.encounters[i]
			if encounter.is_boss():
				boss = encounter
				continue
			_add(running, Loot.expected_encounter(encounter, {"first_clear": true}))
			if zone.get_placement_count(i) > 1:
				_add(running, Loot.expected_encounter(encounter), zone.get_placement_count(i) - 1)
			# Tinh anh hồi mỗi ngày: đánh lại trong những ngày đi qua khu.
			if encounter.kind == EncounterData.Kind.ELITE:
				_add(running, Loot.expected_encounter(encounter), model.elite_repeat_days)
		for tier in zone.chest_counts.size():
			_add(running, Loot.expected_chest(zone.id, tier), zone.chest_counts[tier])
		_add(running, zone_grind(zone, model))
		_add(running, _story_days_rewards(model, quests, zi))
		if boss == null:
			continue
		var level := boss.recommended_level if boss.recommended_level > 0 else boss.get_max_level()
		var exp_need := 0.0
		for lv in range(1, mini(level, GameConfig.MAX_LEVEL)):
			exp_need += cfg.exp_for_level(lv)
		exp_need *= team_size
		var crystal_need := 0
		for asc in cfg.ascensions:
			if asc.at_level < level and not asc.is_locked():
				crystal_need += asc.crystals
		var exp_have: float = summarize(running).get("exp", 0.0)
		var ratio := exp_have / maxf(exp_need, 1.0)
		var row := "| %s | %d | %d | %d | %s %.2f |" % [boss.id, level, roundi(exp_have), roundi(exp_need),
				"✓" if ratio >= 1.0 - model.tolerance else "✗", ratio]
		var crystal_ok := true
		for element in elements:
			var have := float(running.get(String(Progression.crystal_id(element)), 0.0)) \
					+ float(running.get(String(LootEntry.TEAM_CRYSTAL), 0.0)) / maxi(team_size, 1)
			crystal_ok = crystal_ok and have >= crystal_need * (1.0 - model.tolerance)
			row += " %s %.1f/%d |" % ["✓" if have >= crystal_need * (1.0 - model.tolerance) else "✗", have, crystal_need]
		out.append(row)
		pacing.append({"boss": boss.id, "exp_ratio": ratio, "crystals_ok": crystal_ok})
		# Boss chương này thắng xong mới sang chương sau.
		_add(running, Loot.expected_encounter(boss, {"first_clear": true}))
	out.append("")
	out.append("Thiếu ít (✗ gần 1,0) bù bằng cày thêm quái thường hoặc đánh lại tinh anh/boss chương trước; thiếu Tinh Thể bù bằng đánh lại boss cùng nguyên tố hoặc đổi Bụi Sao (Phase 11).")
	out.append("")
	result["pacing"] = pacing


# --- E: kiểm tra dữ liệu ---

static func _section_checks(model: EconomyModel, quests: QuestConfig, out: Array[String], result: Dictionary) -> bool:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	for zone in model.zones:
		if zone.encounters.size() != zone.encounter_counts.size():
			errors.append("%s: số trận và encounter_counts không khớp" % zone.id)
		for encounter in zone.encounters:
			for wave in encounter.waves:
				for entry in wave.entries:
					var table := Loot.table_for_enemy(entry.enemy)
					if table == null:
						errors.append("%s: quái %s không có bảng rơi đồ" % [encounter.id, entry.enemy.id])
					else:
						_check_entries(table, entry.enemy, errors)
		for tier in zone.chest_counts.size():
			var table := zone.get_chest_table(tier)
			if table == null and zone.chest_counts[tier] > 0:
				errors.append("%s: thiếu bảng rơi đồ rương bậc %d" % [zone.id, tier])
			elif table:
				_check_entries(table, null, errors)
	if quests.get_daily_total_activity() != 500:
		errors.append("Tổng Hoạt Động ngày = %d (mục 11b: 500)" % quests.get_daily_total_activity())
	var daily_lt := 0
	for rewards in quests.daily_milestone_rewards:
		daily_lt += int(rewards.get("star_tear", 0))
	if daily_lt != 100:
		errors.append("Mốc Hoạt Động cho %d Lệ Tinh/ngày (mục 11b: 100)" % daily_lt)
	if quests.get_quests(QuestData.Type.DAILY).size() != 6:
		errors.append("Cần 6 nhiệm vụ ngày (mục 11b)")
	if quests.get_quests(QuestData.Type.WEEKLY).size() != 3:
		errors.append("Cần 3 nhiệm vụ tuần (mục 11b)")
	out.append("## E. Kiểm tra dữ liệu")
	out.append("")
	if errors.is_empty() and warnings.is_empty():
		out.append("- ✓ Mọi quái trên map có bảng rơi đồ, mọi vật phẩm tồn tại, tổng nhiệm vụ đúng mục 11b.")
	for message in errors:
		out.append("- ✗ " + message)
	for message in warnings:
		out.append("- ⚠ " + message)
	(result["errors"] as Array).append_array(errors)
	(result["warnings"] as Array).append_array(warnings)
	return errors.is_empty()


## Đếm nội dung đặt trên map của một khu: { "rooms", "encounters": { id: số nhóm }, "chests": [3 bậc], "boxes" }.
static func count_map(scene_path: String) -> Dictionary:
	var counts := {"rooms": 0, "encounters": {}, "chests": [0, 0, 0], "boxes": 0}
	if not ResourceLoader.exists(scene_path):
		return {}
	var root := (load(scene_path) as PackedScene).instantiate()
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		if node is Room:
			counts["rooms"] += 1
		elif node is OverworldEnemy and (node as OverworldEnemy).encounter:
			# Quái chỉ có mặt theo cờ (trận hướng dẫn) không tính vào kinh tế khu.
			var gated := node.get_children().any(func(c: Node) -> bool: return c is StoryGate)
			if not gated:
				var id := String((node as OverworldEnemy).encounter.id)
				counts["encounters"][id] = int(counts["encounters"].get(id, 0)) + 1
		elif node is Chest:
			counts["chests"][(node as Chest).tier] += 1
		elif node is TechniqueBox:
			counts["boxes"] += 1
	root.free()
	return counts


static func _section_map(model: EconomyModel, out: Array[String], result: Dictionary) -> bool:
	var errors: Array[String] = []
	out.append("")
	out.append("## F. Bản đồ khớp kế hoạch khu")
	out.append("")
	out.append("| Khu | Phòng | Nhóm quái (thường / tinh anh / boss) | Rương (thường / quý / giải đố) | Hộp Bí Kỹ | Khớp |")
	out.append("| --- | --- | --- | --- | --- | --- |")
	for zone in model.zones:
		var path := "res://scenes/overworld/world/%s.tscn" % zone.id
		var counts := count_map(path)
		if counts.is_empty():
			errors.append("%s: chưa có bản đồ %s" % [zone.id, path])
			continue
		var zone_errors: Array[String] = []
		var kinds := [0, 0, 0]
		for i in zone.encounters.size():
			var encounter := zone.encounters[i]
			var placed := int(counts["encounters"].get(String(encounter.id), 0))
			kinds[encounter.kind] += placed
			if placed != zone.get_placement_count(i):
				zone_errors.append("%s đặt %d nhóm (kế hoạch %d)" % [encounter.id, placed, zone.get_placement_count(i)])
		for id: String in counts["encounters"]:
			if not zone.encounters.any(func(e: EncounterData) -> bool: return String(e.id) == id):
				zone_errors.append("trận %s không có trong kế hoạch khu" % id)
		for tier in 3:
			if int(counts["chests"][tier]) != zone.chest_counts[tier]:
				zone_errors.append("rương bậc %d: %d (kế hoạch %d)" % [tier, counts["chests"][tier], zone.chest_counts[tier]])
		if int(counts["boxes"]) != zone.technique_boxes:
			zone_errors.append("Hộp Bí Kỹ: %d (kế hoạch %d)" % [counts["boxes"], zone.technique_boxes])
		if int(counts["rooms"]) != zone.room_count or zone.room_count < 8 or zone.room_count > 12:
			zone_errors.append("số phòng %d (kế hoạch %d, mục 4: 8–12)" % [counts["rooms"], zone.room_count])
		out.append("| %s | %d | %d / %d / %d | %d / %d / %d | %d | %s |" % [zone.id, counts["rooms"], kinds[0], kinds[1], kinds[2],
				counts["chests"][0], counts["chests"][1], counts["chests"][2], counts["boxes"],
				"✓" if zone_errors.is_empty() else "✗"])
		for message in zone_errors:
			errors.append("%s: %s" % [zone.id, message])
	# Cốt truyện: chỉ thưởng chương (QuestConfig) cho Lệ Tinh / vé – sự kiện hội thoại không được trao tiền tệ gacha.
	for file in DirAccess.get_files_at("res://data/dialogue"):
		if not file.ends_with(".json"):
			continue
		var dialogue: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/dialogue/" + file))
		if not dialogue is Dictionary:
			continue
		for line: Dictionary in dialogue.get("lines", []):
			var events: Array = line.get("events", []).duplicate()
			for choice: Dictionary in line.get("choices", []):
				events.append_array(choice.get("events", []))
			for event: Dictionary in events:
				if not str(event.get("type", "")) in ["set_flag", "give_character", "result"]:
					errors.append("%s: sự kiện %s ngoài kế hoạch kinh tế" % [file, event.get("type")])
	out.append("")
	if errors.is_empty():
		out.append("- ✓ Mọi khu đặt đúng số nhóm quái, rương, Hộp Bí Kỹ như kế hoạch; tổng thưởng trên map = số ở mục A–D.")
	for message in errors:
		out.append("- ✗ " + message)
	(result["errors"] as Array).append_array(errors)
	return errors.is_empty()


static func _check_entries(table: LootTable, enemy: EnemyData, errors: Array[String]) -> void:
	for list: Array[LootEntry] in [table.entries, table.first_clear, table.hard_extra]:
		for entry in list:
			if entry.min_count > entry.max_count:
				errors.append("%s: min > max" % table.id)
			var ids: Array[StringName] = []
			ids.assign(entry.pool if not entry.pool.is_empty() else [entry.item_id])
			for id in ids:
				if Loot.is_team_token(id):
					continue
				var resolved := Loot._resolve(id, enemy) if enemy else id
				if resolved == LootEntry.ENEMY_CRYSTAL or UiKit.get_item(resolved) == null:
					errors.append("%s: vật phẩm không tồn tại '%s'" % [table.id, id])


# --- Tiện ích ---

static func _add(into: Dictionary, items: Dictionary, times: float = 1.0) -> void:
	for id: Variant in items:
		into[id] = into.get(id, 0.0) + float(items[id]) * times


static func _scale(items: Dictionary, times: float) -> Dictionary:
	var result: Dictionary = {}
	_add(result, items, times)
	return result


static func _only(items: Dictionary, keep: Array[StringName]) -> Dictionary:
	var result: Dictionary = {}
	for id: Variant in items:
		if keep.has(StringName(str(id))):
			result[str(id)] = items[id]
	return result


static func _without(items: Dictionary, drop: Array[StringName]) -> Dictionary:
	var result: Dictionary = {}
	for id: Variant in items:
		if not drop.has(StringName(str(id))):
			result[str(id)] = items[id]
	return result


static func _pulls(items: Dictionary, per_pull: float) -> float:
	return float(items.get("star_tear", 0.0)) / per_pull + float(items.get("wish_ticket_standard", 0.0)) \
			+ float(items.get("wish_ticket_limited", 0.0))


static func _within(value: float, target: float, tolerance: float) -> bool:
	return absf(value - target) <= target * tolerance


static func _dev_text(value: float, target: float, tolerance: float) -> String:
	var dev := (value - target) / maxf(target, 0.001) * 100.0
	return "%s %+.0f%%" % ["✓" if _within(value, target, tolerance) else "✗", dev]


static func _items_text(items: Dictionary) -> String:
	return ", ".join(Loot.describe(items))


static func _resource_row(title: String, values: Dictionary, bold: bool = false) -> String:
	var row := "| %s |" % title
	for key in RESOURCE_KEYS:
		var value := float(values.get(key, 0.0))
		var text := ("%d" % roundi(value)) if value >= 10.0 or value == 0.0 else ("%.1f" % value)
		row += (" **%s** |" % text) if bold else (" %s |" % text)
	return row


static func _suggestion(key: String, coverage: float, target: float) -> String:
	var factor := target / maxf(coverage, 0.001)
	match key:
		"exp":
			return "Đề xuất: giảm Ký Ức trong rương/nhiệm vụ (build_economy.py: CHEST_CONTENT, MILESTONES) hoặc tăng EXP mỗi cấp (build_progression.py: exp_to_next) ×%.2f." % (1.0 / factor)
		"coin":
			return "Đề xuất: nhân xu trong rương/nhiệm vụ ×%.2f hoặc chi phí xu (build_progression.py) ×%.2f." % [factor, 1.0 / factor]
		"crystal":
			return "Đề xuất: Tinh Thể đột phá (ASCENSIONS) ×%.2f hoặc Tinh Thể trong rương ×%.2f." % [1.0 / factor, factor]
		"core":
			return "Đề xuất: Lõi Ma Biến mức Khó (BOSS_HARD_EXTRA) hoặc số Lõi mỗi kỹ năng cấp 5 ×%.2f." % (1.0 / factor)
	return "Đề xuất: số Dấu Ấn mỗi lần nâng (SKILL_COSTS, SMALL_COST, MAJOR_COST) ×%.2f hoặc tỉ lệ rơi ×%.2f." % [1.0 / factor, factor]
