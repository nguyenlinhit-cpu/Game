extends Node
## Báo cáo cân bằng Phase 7: mỗi nhân vật đánh 10 lượt của mình ở cấp 30, Tinh Mệnh 0, cùng đội hỗ trợ
## (Lữ khách, Mira, Garren; nhân vật là một trong ba thì thay bằng Nyx). Đội hỗ trợ CHỈ đánh thường, không dùng
## Tuyệt kỹ: không tranh Điểm Chiến Kỹ với nhân vật đang đo, nên mọi người được đo trong cùng điều kiện., cùng 3 "Quái Thử Sức"
## (máu 200.000, yếu mọi nguyên tố, đánh đủ đau để có việc cho hồi máu/khiên). Trung bình 3 seed, Tự Động.
## In sát thương / hồi máu / khiên, rồi so 5★ với trung bình 4★ cùng vận mệnh (mục tiêu +15–25%).
## Chỉ số cả đội quy về cùng 1000 Giá trị Hành Động (≈10 lượt của người Tốc Độ 100) để nhân vật nhanh
## không bị thiệt vì 10 lượt của họ trôi qua nhanh hơn.
## Chạy: godot --headless --path . res://tools/balance/balance_report.tscn  (ghi docs/BALANCE_REPORT.md)

const ENCOUNTER: String = "res://data/encounters/balance_brutes.tres"
const SUPPORTS: Array[StringName] = [&"traveler", &"mira", &"garren"]
const SUBSTITUTE: StringName = &"nyx"
const TURNS: int = 10
const SEEDS: Array[int] = [101, 202, 303, 404, 505, 606, 707, 808]
const LEVEL: int = 30
const TEAM_WINDOW_AV: float = 1000.0
const REPORT_PATH: String = "res://docs/BALANCE_REPORT.md"
const PATH_NAMES: Dictionary = {
	CharacterPath.Type.DESTRUCTION: "Hủy Diệt", CharacterPath.Type.HUNT: "Săn Bắn", CharacterPath.Type.ERUDITION: "Tri Thức",
	CharacterPath.Type.HARMONY: "Hòa Hợp", CharacterPath.Type.NIHILITY: "Hư Vô",
	CharacterPath.Type.PRESERVATION: "Bảo Hộ", CharacterPath.Type.ABUNDANCE: "Trù Phú",
}


func _ready() -> void:
	if get_tree().current_scene == self:
		get_tree().root.add_child.call_deferred((get_script() as GDScript).new())
		return
	_run()


func _run() -> void:
	var rows: Array[Dictionary] = []
	for id in DataPaths.list_character_ids():
		var total := {"damage": 0.0, "heal": 0.0, "shield": 0.0, "protect": 0.0, "team": 0.0, "turns": 0}
		for seed_value in SEEDS:
			var result: Dictionary = await _simulate(id, seed_value)
			for key: String in total:
				total[key] += result[key]
		for key: String in total:
			total[key] = float(total[key]) / SEEDS.size()
		var data := DataPaths.load_character(id)
		total["id"] = id
		total["rarity"] = data.rarity
		total["path"] = data.path
		total["score"] = _score(data.path, total)
		rows.append(total)
		print("%-10s %d★ %-9s sát thương %8.0f  hồi %7.0f  khiên %7.0f  che chắn %7.0f  đội %8.0f  → điểm %8.0f" % [
				id, data.rarity, PATH_NAMES[data.path], total["damage"], total["heal"], total["shield"], total["protect"],
				total["team"], total["score"]])
	_write_report(rows)
	get_tree().quit()


## Điểm so sánh theo vai trò.
func _score(path: int, r: Dictionary) -> float:
	match path:
		CharacterPath.Type.HARMONY, CharacterPath.Type.NIHILITY:
			return r["team"]
		CharacterPath.Type.ABUNDANCE:
			return r["heal"]
		CharacterPath.Type.PRESERVATION:
			return r["shield"] + r["protect"] + 0.5 * r["damage"]
	return r["damage"]


func _simulate(id: StringName, seed_value: int) -> Dictionary:
	var ids: Array[StringName] = [id]
	for support in SUPPORTS:
		ids.append(SUBSTITUTE if support == id else support)
	var team: Array[CharacterData] = []
	for member in ids:
		team.append(DataPaths.load_character(member))
	var controller := BattleController.new()
	controller.instant = true
	controller.auto_mode = true
	controller.rng.seed = seed_value
	add_child(controller)
	controller.setup(team, LEVEL, load(ENCOUNTER), BattleTypes.Opening.NORMAL)
	var subject: BattleUnit = controller.allies[0]
	for support in controller.allies.slice(1):
		controller.auto_ultimate_blocklist.append(support)
		controller.auto_overrides[support] = func(unit: BattleUnit) -> Dictionary:
			var basic := unit.get_skill(SkillData.Kind.BASIC)
			return {"skill": basic, "target": AutoBattle.best_enemy_target(controller, unit, basic)}
	var stats := {"damage": 0.0, "heal": 0.0, "shield": 0.0, "protect": 0.0, "team": 0.0, "turns": 0}
	var collect := func(events: Array[Dictionary]) -> void:
		for e in events:
			var source: Variant = e.get("source")
			var t := str(e["type"])
			if t in ["damage", "dot", "break"] and e["target"] is BattleUnit and not (e["target"] as BattleUnit).is_ally():
				stats["team"] += float(e["amount"])
				if source == subject or (t == "break" and false):
					stats["damage"] += float(e["amount"])
			if source == subject:
				if t == "heal":
					stats["heal"] += float(e.get("raw", e["amount"]))
				elif t == "shield":
					stats["shield"] += float(e["amount"])
				elif t == "intercept":
					stats["protect"] += float(e["amount"])
			if e.get("protector") == subject:
				stats["protect"] += float(e.get("protected", 0.0))
	controller.action_resolved.connect(func(_u: BattleUnit, _s: SkillData, events: Array[Dictionary]) -> void: collect.call(events))
	controller.status_events.connect(func(_u: BattleUnit, events: Array[Dictionary]) -> void: collect.call(events))
	controller.turn_started.connect(func(unit: BattleUnit) -> void:
		if unit == subject:
			stats["turns"] += 1)
	controller.start()
	var frames := 0
	while controller.phase != BattleController.Phase.ENDED and frames < 20000:
		if stats["turns"] > TURNS:
			break
		await get_tree().process_frame
		frames += 1
	stats["team"] = stats["team"] * TEAM_WINDOW_AV / maxf(controller.queue.elapsed, 1.0)
	controller.force_end(true)
	controller.queue_free()
	await get_tree().process_frame
	return stats


func _write_report(rows: Array[Dictionary]) -> void:
	var lines: Array[String] = ["# Báo cáo cân bằng (Phase 7)", "",
		"Sinh bởi `tools/balance/balance_report.tscn`. Cấp %d, Tinh Mệnh 0, %d lượt của nhân vật, trung bình %d seed, Tự Động." % [
			LEVEL, TURNS, SEEDS.size()],
		"Sát thương cả đội quy về %d Giá trị Hành Động. Đội hỗ trợ: Lữ khách, Mira, Garren (nhân vật là một trong ba thì thay bằng Nyx), chỉ đánh thường, không dùng Tuyệt kỹ. Quái: 3 Quái Thử Sức (cấp 30, máu 200.000, yếu mọi nguyên tố)." % TEAM_WINDOW_AV,
		"Điểm: sát thương của nhân vật (Hủy Diệt, Săn Bắn, Tri Thức); tổng sát thương cả đội (Hòa Hợp, Hư Vô);",
		"lượng hồi (Trù Phú, tính cả phần tràn); khiên + sát thương gánh thay + 50% sát thương (Bảo Hộ).", "",
		"| Nhân vật | Hạng | Vận mệnh | Sát thương | Hồi máu | Khiên | Gánh thay | Sát thương cả đội | Điểm |",
		"| --- | --- | --- | --- | --- | --- | --- | --- | --- |"]
	for r in rows:
		lines.append("| %s | %d★ | %s | %.0f | %.0f | %.0f | %.0f | %.0f | %.0f |" % [r["id"], r["rarity"], PATH_NAMES[r["path"]],
				r["damage"], r["heal"], r["shield"], r["protect"], r["team"], r["score"]])
	lines += ["", "## 5★ so với 4★ cùng vận mệnh", "", "| Vận mệnh | 5★ | Trung bình 4★ | Tỉ lệ | Đạt (1,15–1,25)? |",
		"| --- | --- | --- | --- | --- |"]
	print("\n5★ so với trung bình 4★ cùng vận mệnh:")
	for path: int in PATH_NAMES:
		var four := rows.filter(func(r: Dictionary) -> bool: return r["path"] == path and r["rarity"] == 4)
		if four.is_empty():
			continue
		var avg := 0.0
		for r in four:
			avg += r["score"]
		avg /= four.size()
		for r in rows.filter(func(x: Dictionary) -> bool: return x["path"] == path and x["rarity"] == 5 and x["id"] != &"traveler"):
			var ratio: float = r["score"] / maxf(avg, 1.0)
			var ok := ratio >= 1.15 and ratio <= 1.25
			lines.append("| %s | %s | %.0f | %.2f | %s |" % [PATH_NAMES[path], r["id"], avg, ratio, "Đạt" if ok else "Chưa"])
			print("  %-9s %-10s %.2f %s" % [PATH_NAMES[path], r["id"], ratio, "ĐẠT" if ok else "CHƯA"])
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()
