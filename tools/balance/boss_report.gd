extends Node
## Mô phỏng boss Phase 8: đội miễn phí (nhân vật chính, Mira, Kiri, Garren, Nyx – chọn 4) ở cấp khuyến nghị,
## Tinh Mệnh 0, Tự Động, nhiều seed. Thử cả 5 cách chọn 4 người, lấy đội tốt nhất rồi chạy thêm seed.
## In tỉ lệ thắng, số lượt trung bình (lượt phe ta / mọi lượt), giai đoạn đã tới, số lần ngắt đòn tích tụ;
## thêm một dòng mức Khó với cùng đội. Ghi docs/BOSS_REPORT.md.
## Chạy: godot --headless --path . res://tools/balance/boss_report.tscn [-- --boss=library_boss_warden --seeds=40]

const BOSSES: Array[String] = [
	"res://data/encounters/library_boss_warden.tres",
	"res://data/encounters/vault_boss_behemoth.tres",
	"res://data/encounters/furnace_boss_core.tres",
	"res://data/encounters/tower_boss_devourer.tres",
]
const FREE_TEAM: Array[StringName] = [&"traveler", &"mira", &"kiri", &"garren", &"nyx"]
const SCOUT_SEEDS: int = 12
const FINAL_SEEDS: int = 40
const MAX_TURNS: int = 400
const REPORT_PATH: String = "res://docs/BOSS_REPORT.md"
const HARD_CONFIG: String = "res://data/config/boss_hard_mode.tres"
## Trận thường / tinh anh: cùng đội cố định, ít seed hơn (chỉ để thấy độ khó hợp lý theo khu).
const ZONE_TEAM: Array[StringName] = [&"traveler", &"mira", &"kiri", &"garren"]
const ZONE_SEEDS: int = 8


func _ready() -> void:
	if get_tree().current_scene == self:
		get_tree().root.add_child.call_deferred((get_script() as GDScript).new())
		return
	_run()


var _trace: bool = false
## Mô phỏng đội đã nâng kỹ năng + cây vận mệnh tối đa theo cấp (Phase 14).
var _invested: bool = false


func _run() -> void:
	# Không ngủ giữa các khung hình (headless mặc định tiết kiệm CPU làm mô phỏng chậm).
	OS.low_processor_usage_mode = false
	Engine.max_fps = 0
	OS.low_processor_usage_mode_sleep_usec = 0
	var only := ""
	var final_seeds := FINAL_SEEDS
	var trace_team := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--boss="):
			only = arg.trim_prefix("--boss=")
		elif arg.begins_with("--seeds="):
			final_seeds = int(arg.trim_prefix("--seeds="))
		elif arg.begins_with("--trace="):
			trace_team = arg.trim_prefix("--trace=")
	if trace_team != "":
		# In diễn biến 1 trận: --boss=<id> --trace=traveler,kiri,garren,nyx [--seeds=<seed>] [--hard]
		_trace = true
		var team: Array[StringName] = []
		for id in trace_team.split(","):
			team.append(StringName(id))
		for path in BOSSES:
			var encounter := load(path) as EncounterData
			if String(encounter.id) == only:
				var r: Dictionary = await simulate(encounter, team, encounter.recommended_level, final_seeds,
						OS.get_cmdline_user_args().has("--hard"))
				print(r)
		get_tree().quit()
		return
	var rows: Array[Dictionary] = []
	for path in BOSSES:
		var encounter := load(path) as EncounterData
		if only != "" and String(encounter.id) != only:
			continue
		var best: Dictionary = {}
		for team in _team_options():
			var scout: Dictionary = await _run_many(encounter, team, SCOUT_SEEDS, 1000, false)
			print("  %s  %s  thắng %3.0f%%  lượt ta %.1f" % [encounter.id, ",".join(team), scout["win_rate"] * 100.0,
					scout["ally_turns"]])
			if best.is_empty() or _better(scout, best):
				best = scout
		var final: Dictionary = await _run_many(encounter, best["team"], final_seeds, 5000, false)
		var hard: Dictionary = await _run_many(encounter, best["team"], final_seeds, 9000, true)
		final["hard"] = hard
		# Phase 14: đội đã nâng hết mức cho phép ở cấp đó (kỹ năng theo giới hạn đột phá, đủ cây vận mệnh).
		_invested = true
		final["invested"] = await _run_many(encounter, best["team"], final_seeds, 5000, false)
		final["invested_hard"] = await _run_many(encounter, best["team"], final_seeds, 9000, true)
		_invested = false
		rows.append(final)
		print("%s  đội %s  thắng %.0f%%  lượt ta %.1f  mọi lượt %.1f  máu còn %.0f%%  GĐ cuối %.0f%%  ngắt %.1f  | Khó: thắng %.0f%% lượt ta %.1f" % [
				encounter.id, ",".join(final["team"]), final["win_rate"] * 100.0, final["ally_turns"], final["all_turns"], final["hp_left"] * 100.0,
				final["final_phase_rate"] * 100.0, final["interrupts"], hard["win_rate"] * 100.0, hard["ally_turns"]])
	var zone_rows: Array[Dictionary] = []
	if only == "":
		for path in DataPaths.list_encounter_paths():
			var encounter := load(path) as EncounterData
			if encounter.zone == &"" or encounter.is_boss():
				continue
			var r: Dictionary = await _run_many(encounter, ZONE_TEAM, ZONE_SEEDS, 300, false)
			r["kind"] = encounter.kind
			r["zone"] = encounter.zone
			zone_rows.append(r)
			print("  %-26s thắng %3.0f%%  lượt ta %.1f  máu còn %.0f%%" % [encounter.id, r["win_rate"] * 100.0, r["ally_turns"],
					r["hp_left"] * 100.0])
		_write_report(rows, final_seeds, zone_rows)
	get_tree().quit()


func _team_options() -> Array[Array]:
	var result: Array[Array] = []
	for skip in FREE_TEAM:
		var team: Array[StringName] = []
		for id in FREE_TEAM:
			if id != skip:
				team.append(id)
		result.append(team)
	return result


func _better(a: Dictionary, b: Dictionary) -> bool:
	if not is_equal_approx(a["win_rate"], b["win_rate"]):
		return a["win_rate"] > b["win_rate"]
	return a["ally_turns"] < b["ally_turns"]


func _run_many(encounter: EncounterData, team: Array, seeds: int, seed_base: int, hard: bool) -> Dictionary:
	var total := {"wins": 0, "ally_turns": 0.0, "all_turns": 0.0, "final_phase": 0, "interrupts": 0.0, "charges_hit": 0.0,
			"hp_left": 0.0, "timeouts": 0}
	for i in seeds:
		var r: Dictionary = await simulate(encounter, team, encounter.recommended_level, seed_base + i * 7, hard)
		if r["won"]:
			total["wins"] += 1
			total["ally_turns"] += r["ally_turns"]
			total["all_turns"] += r["all_turns"]
			total["hp_left"] += r["hp_left"]
		if r["final_phase"]:
			total["final_phase"] += 1
		if r["timeout"]:
			total["timeouts"] += 1
		total["interrupts"] += r["interrupts"]
		total["charges_hit"] += r["charges_hit"]
	var wins := maxi(int(total["wins"]), 1)
	return {"encounter": encounter.id, "team": team, "level": encounter.recommended_level, "seeds": seeds,
			"win_rate": float(total["wins"]) / seeds, "ally_turns": total["ally_turns"] / wins,
			"all_turns": total["all_turns"] / wins, "hp_left": total["hp_left"] / wins,
			"final_phase_rate": float(total["final_phase"]) / seeds, "interrupts": total["interrupts"] / seeds,
			"charges_hit": total["charges_hit"] / seeds, "timeouts": total["timeouts"]}


## Một trận Tự Động. Trả về { won, ally_turns, all_turns, final_phase, interrupts, charges_hit, hp_left, timeout }.
func simulate(encounter: EncounterData, team_ids: Array, level: int, seed_value: int, hard: bool) -> Dictionary:
	var team: Array[CharacterData] = []
	for id: StringName in team_ids:
		team.append(DataPaths.load_character(id))
	var controller := BattleController.new()
	controller.instant = true
	controller.auto_mode = true
	controller.rng.seed = seed_value
	if hard:
		controller.difficulty = load(HARD_CONFIG) as DifficultyConfig
	if _invested:
		var ascension := clampi((level - 1) / 10, 0, 2)
		var cap := Progression.config().skill_cap(ascension)
		for data in team:
			var traces: Array[TraceNodeData] = []
			for node in Progression.get_trace_tree(data.path).nodes:
				if node.required_ascension <= ascension:
					traces.append(node)
			controller.ally_states[data.id] = {"skill_levels": {0: cap, 1: cap, 2: cap, -1: cap}, "traces": traces}
	add_child(controller)
	controller.setup(team, level, encounter, BattleTypes.Opening.NORMAL)
	var result := {"won": false, "ally_turns": 0, "all_turns": 0, "final_phase": false, "interrupts": 0, "charges_hit": 0,
			"hp_left": 0.0, "timeout": false}
	var boss_data := encounter.get_boss()
	controller.turn_started.connect(func(unit: BattleUnit) -> void:
		result["all_turns"] += 1
		if unit.is_ally():
			result["ally_turns"] += 1)
	controller.boss_phase_started.connect(func(unit: BattleUnit, index: int, _d: BossPhaseData) -> void:
		if unit.enemy == boss_data and index == boss_data.phases.size():
			result["final_phase"] = true)
	controller.charge_interrupted.connect(func(_u: BattleUnit, _a: EnemyAction) -> void: result["interrupts"] += 1)
	controller.action_resolved.connect(func(unit: BattleUnit, skill: SkillData, _e: Array[Dictionary]) -> void:
		if not unit.is_ally() and skill.kind == SkillData.Kind.ULTIMATE:
			result["charges_hit"] += 1)
	if _trace:
		_attach_trace(controller)
	controller.start()
	while controller.phase != BattleController.Phase.ENDED:
		if int(result["all_turns"]) > MAX_TURNS:
			result["timeout"] = true
			controller.force_end(false)
			break
		await get_tree().process_frame
	result["won"] = controller.won
	if boss_data and boss_data.phases.is_empty():
		result["final_phase"] = true
	var hp := 0.0
	for unit in controller.allies:
		hp += unit.get_hp_ratio()
	result["hp_left"] = hp / controller.allies.size()
	controller.queue_free()
	await get_tree().process_frame
	return result


func _attach_trace(controller: BattleController) -> void:
	var describe := func(events: Array[Dictionary]) -> String:
		var parts: Array[String] = []
		for e in events:
			var t: BattleUnit = e["target"]
			parts.append("%s→%s %s" % [e["type"], t.display_name, str(e.get("amount", "")) if e.has("amount") else ""])
		return "; ".join(parts)
	controller.turn_started.connect(func(unit: BattleUnit) -> void:
		var hp := ""
		for u in controller.allies + controller.enemies:
			if u.is_alive():
				hp += " %s:%d%s" % [u.display_name.left(8), roundi(u.get_hp_ratio() * 100), "%"]
		print("[%d] lượt %s | SP %d |%s" % [controller.turn_count, unit.display_name, controller.skill_points, hp]))
	controller.action_resolved.connect(func(unit: BattleUnit, skill: SkillData, events: Array[Dictionary]) -> void:
		print("    %s dùng %s: %s" % [unit.display_name, tr(skill.name_key), describe.call(events)]))
	controller.status_events.connect(func(unit: BattleUnit, events: Array[Dictionary]) -> void:
		print("    * %s" % describe.call(events)))
	controller.boss_phase_started.connect(func(unit: BattleUnit, index: int, d: BossPhaseData) -> void:
		print("=== %s sang giai đoạn %d: %s" % [unit.display_name, index + 1, tr(d.name_key)]))


func _write_report(rows: Array[Dictionary], seeds: int, zone_rows: Array[Dictionary]) -> void:
	var lines: Array[String] = ["# Báo cáo mô phỏng boss (Phase 8, cập nhật Phase 14)", "",
		"Sinh bởi `tools/balance/boss_report.tscn`. Đội miễn phí (chọn 4 trong Lữ khách, Mira, Kiri, Garren, Nyx),",
		"cấp khuyến nghị của trận, Tinh Mệnh 0, Tự Động, %d seed. Đội được chọn = cách chọn 4 người thắng nhiều nhất" % seeds,
		"(hòa thì ít lượt hơn) qua %d seed thử. \"Lượt ta\" = số lượt phe ta trong trận thắng; \"mọi lượt\" tính cả quái." % SCOUT_SEEDS,
		"\"Ngắt\" = số lần trung bình ngắt được đòn tích tụ; \"trúng\" = số đòn tích tụ/đòn mạnh của boss đã ra.", "",
		"| Boss | Cấp đội | Đội | Thắng | Lượt ta | Mọi lượt | Máu còn | Tới GĐ cuối | Ngắt | Trúng | Khó: thắng | Khó: lượt ta |",
		"| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"]
	for r in rows:
		var hard: Dictionary = r["hard"]
		lines.append("| %s | %d | %s | %.0f%% | %.1f | %.1f | %.0f%% | %.0f%% | %.1f | %.1f | %.0f%% | %.1f |" % [r["encounter"],
				r["level"], ", ".join(r["team"]), r["win_rate"] * 100.0, r["ally_turns"], r["all_turns"], r["hp_left"] * 100.0,
				r["final_phase_rate"] * 100.0, r["interrupts"], r["charges_hit"], hard["win_rate"] * 100.0, hard["ally_turns"]])
	lines += ["", "## Đội đã nâng cấp (Phase 14)", "",
		"Cùng đội, cùng cấp; kỹ năng ở giới hạn đột phá của cấp đó (cấp ≤10: 2, ≤20: 4, 30: 5) và mở đủ cây vận mệnh cho phép –",
		"mức người chơi đạt được khi dồn tài nguyên (báo cáo kinh tế: đủ nâng tối đa 4–5 nhân vật).", "",
		"| Boss | Cấp đội | Thường: thắng | Thường: lượt ta | Khó: thắng | Khó: lượt ta | Khó: máu còn |",
		"| --- | --- | --- | --- | --- | --- | --- |"]
	for r in rows:
		if not r.has("invested"):
			continue
		var inv: Dictionary = r["invested"]
		var inv_hard: Dictionary = r["invested_hard"]
		lines.append("| %s | %d | %.0f%% | %.1f | %.0f%% | %.1f | %.0f%% |" % [r["encounter"], r["level"], inv["win_rate"] * 100.0,
				inv["ally_turns"], inv_hard["win_rate"] * 100.0, inv_hard["ally_turns"], inv_hard["hp_left"] * 100.0])
	lines += ["", "## Trận thường và tinh anh", "",
		"Đội Lữ khách, Mira, Kiri, Garren; cấp khuyến nghị; Tự Động; %d seed. \"Máu còn\" = trung bình tỉ lệ máu cả đội cuối trận thắng." % ZONE_SEEDS, "",
		"| Trận | Khu | Loại | Cấp đội | Thắng | Lượt ta | Máu còn |", "| --- | --- | --- | --- | --- | --- | --- |"]
	for r in zone_rows:
		lines.append("| %s | %s | %s | %d | %.0f%% | %.1f | %.0f%% |" % [r["encounter"], r["zone"],
				"Tinh anh" if r["kind"] == EncounterData.Kind.ELITE else "Thường", r["level"], r["win_rate"] * 100.0,
				r["ally_turns"], r["hp_left"] * 100.0])
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()
	print("Đã ghi ", REPORT_PATH)
