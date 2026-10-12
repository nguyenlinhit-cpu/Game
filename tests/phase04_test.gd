extends "res://tests/test_base.gd"
## Kiểm thử Phase 4: công thức sát thương (ca tính tay), thứ tự lượt (đổi tốc độ, kéo/đẩy lượt),
## Điểm Chiến Kỹ luôn trong 0–5, từ chối đội 5 người, kiểu mở trận, chen lượt Tuyệt kỹ,
## đánh trọn trận 4 vs 3 bằng chuột (sự kiện chuột thật) và bằng Tự Động.
## Chạy: godot --headless --path . res://tests/phase04_test.tscn

const SPROUTS: String = "res://data/encounters/test_sprouts_lv3.tres"
const MIXED: String = "res://data/encounters/test_mixed_lv5.tres"
const SIMULATED_BATTLES: int = 40


func _run() -> void:
	phase_name = "Phase 4"
	timeout_sec = 240.0
	_test_damage_formula()
	_test_stats()
	_test_turn_order()
	_test_team_limit()
	await _test_openings()
	await _test_skill_points_and_auto_simulation()
	await _test_ultimate_interrupt()
	await _test_scene_mouse_battle()
	await _test_scene_auto_battle()
	await _test_scene_rejects_five()
	_finish()


# --- Công thức sát thương ---

func _params(base: float, multiplier: float = 1.0) -> DamageCalc.Params:
	var p := DamageCalc.Params.new()
	p.base_stat = base
	p.multiplier = multiplier
	return p


func _test_damage_formula() -> void:
	# Ca 1: 100 × 1 × phòng thủ (21/42 = 0,5) × phá vỡ 0,9 (còn khiên) = 45.
	var p := _params(100.0)
	p.defender_has_toughness = true
	_expect_damage(p, false, 45, "Ca 1: cấp 1 vs cấp 1, quái còn khiên")
	# Ca 2: không có khiên → hệ số phá vỡ 1,0 → 50.
	_expect_damage(_params(100.0), false, 50, "Ca 2: mục tiêu không có khiên")
	# Ca 3: bạo kích 50% → 50 × 1,5 = 75.
	p = _params(100.0)
	p.crit_dmg = 0.5
	_expect_damage(p, true, 75, "Ca 3: bạo kích +50%")
	# Ca 4: cấp 80 vs 80: 100/200 = 0,5 → 1000 × 2,5 × 0,5 = 1250.
	p = _params(1000.0, 2.5)
	p.attacker_level = 80
	p.defender_level = 80
	_expect_damage(p, false, 1250, "Ca 4: cấp 80 vs 80, hệ số 250%")
	# Ca 5: giảm phòng thủ 50%: 21 / (21×0,5 + 21) = 2/3 → 300 × 2/3 = 200.
	p = _params(300.0)
	p.def_reduction = 0.5
	_expect_damage(p, false, 200, "Ca 5: giảm 50% phòng thủ")
	# Ca 6: kháng 20% → 50 × 0,8 = 40.
	p = _params(100.0)
	p.res = 0.2
	_expect_damage(p, false, 40, "Ca 6: kháng 20%")
	# Ca 7: dễ tổn thương 25% → 50 × 1,25 = 62,5 → làm tròn xuống 62.
	p = _params(100.0)
	p.vulnerability = 0.25
	_expect_damage(p, false, 62, "Ca 7: dễ tổn thương 25% (làm tròn xuống)")
	# Ca 8: tăng sát thương 40% → 50 × 1,4 = 70.
	p = _params(100.0)
	p.damage_bonus = 0.4
	_expect_damage(p, false, 70, "Ca 8: tăng sát thương 40%")
	# Ca 9: cấp 30 đánh cấp 10: 50 / (30 + 50) = 0,625 → 200 × 1,5 × 0,625 = 187,5 → 187; khiên đã vỡ.
	p = _params(200.0, 1.5)
	p.attacker_level = 30
	p.defender_level = 10
	p.defender_has_toughness = true
	p.defender_broken = true
	_expect_damage(p, false, 187, "Ca 9: cấp 30 vs 10, khiên đã vỡ")
	# Ca 10 (tính tay đủ mọi hệ số): 1000 × 2 × 1,5 × 2,0 × 0,5 × 0,9 × 1,2 × 0,9 = 2916.
	p = _params(1000.0, 2.0)
	p.damage_bonus = 0.5
	p.crit_dmg = 1.0
	p.attacker_level = 20
	p.defender_level = 20
	p.res = 0.1
	p.vulnerability = 0.2
	p.defender_has_toughness = true
	_expect_damage(p, true, 2916, "Ca 10: đủ mọi hệ số (tính tay 2916)")
	# Ca 11: sát thương rất nhỏ vẫn tối thiểu 1.
	_expect_damage(_params(1.0, 0.1), false, 1, "Ca 11: tối thiểu 1 sát thương")
	# Ca 12: hệ số 0 → 0 sát thương.
	_expect_damage(_params(100.0, 0.0), false, 0, "Ca 12: hệ số 0 thì không gây sát thương")
	_check(is_equal_approx(DamageCalc.defense_factor(1, 3), 21.0 / 44.0), "Ca 13: hệ số phòng thủ cấp 1 vs cấp 3 = 21/44")

	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	p = _params(100.0)
	p.crit_rate = 1.0
	p.crit_dmg = 0.5
	_check(DamageCalc.roll(p, rng)["crit"] and DamageCalc.roll(p, rng, DamageCalc.CritMode.NEVER)["amount"] == 50,
			"Tỉ lệ bạo kích 100% luôn bạo; chế độ NEVER không bạo")
	p.crit_rate = 0.3
	var crits := 0
	for i in 10000:
		if DamageCalc.roll(p, rng)["crit"]:
			crits += 1
	_check(absf(crits / 10000.0 - 0.3) < 0.02, "Tỉ lệ bạo kích 30%% ra %.1f%% trên 10.000 lần" % (crits / 100.0))


func _expect_damage(p: DamageCalc.Params, crit: bool, expected: int, description: String) -> void:
	var actual := DamageCalc.compute(p, crit)
	_check(actual == expected, "%s → %d (mong đợi %d)" % [description, actual, expected])


func _test_stats() -> void:
	var stats := Stats.new()
	stats.set_base(Stats.Type.ATK, 100.0)
	var id := stats.add_modifier(Stats.Type.ATK, 20.0, 0.5, &"buff_a")
	stats.add_modifier(Stats.Type.ATK, 0.0, 0.1, &"buff_b")
	_check(is_equal_approx(stats.get_value(Stats.Type.ATK), 180.0), "Chỉ số: 100 × (1 + 60%) + 20 = 180")
	stats.remove_modifier(id)
	stats.remove_source(&"buff_b")
	_check(is_equal_approx(stats.get_value(Stats.Type.ATK), 100.0), "Gỡ buff trả chỉ số về gốc")
	var traveler := DataPaths.load_character(&"traveler")
	var lv1 := Stats.from_blocks(traveler.stats_lv1, traveler.stats_lv80, 1)
	var lv80 := Stats.from_blocks(traveler.stats_lv1, traveler.stats_lv80, 80)
	var lv30 := Stats.from_blocks(traveler.stats_lv1, traveler.stats_lv80, 30)
	_check(lv1.get_value(Stats.Type.HP) == 160.0 and lv80.get_value(Stats.Type.HP) == 1200.0,
			"Chỉ số theo cấp: Máu cấp 1 = 160, cấp 80 = 1200")
	var expected_lv30 := 160.0 + (1200.0 - 160.0) * 29.0 / 79.0
	_check(is_equal_approx(lv30.get_value(Stats.Type.HP), expected_lv30), "Máu cấp 30 nội suy = %.1f" % expected_lv30)
	_check(lv1.get_value(Stats.Type.CRIT_RATE) == 0.05 and lv1.get_value(Stats.Type.CRIT_DMG) == 0.5,
			"Bạo kích gốc 5%, sát thương bạo kích gốc 50%")


# --- Thứ tự lượt ---

func _make_unit(speed: float, side: BattleUnit.Faction = BattleUnit.Faction.ALLY) -> BattleUnit:
	var unit := BattleUnit.new()
	unit.stats = Stats.new()
	unit.stats.set_base(Stats.Type.SPD, speed)
	unit.stats.set_base(Stats.Type.HP, 100.0)
	unit.hp = 100.0
	unit.side = side
	unit.display_name = "SPD%d" % speed
	return unit


func _test_turn_order() -> void:
	var queue := TurnQueue.new()
	var a := _make_unit(100.0)
	var b := _make_unit(120.0)
	var c := _make_unit(80.0, BattleUnit.Faction.ENEMY)
	for unit in [a, b, c]:
		queue.add(unit)
	# GTHĐ: B 83,3 / A 100 / C 125 / B 166,7 / A 200 / B 250 = C 250 (hòa: B nhanh hơn trước) / A 300.
	var expected: Array[BattleUnit] = [b, a, c, b, a, b, c, a]
	var predicted := queue.predict(8)
	var predicted_units: Array = predicted.map(func(e: Dictionary) -> BattleUnit: return e["unit"])
	_check(predicted_units == expected, "Dự đoán thứ tự 8 lượt theo Tốc Độ 120/100/80")
	var actual: Array = []
	for i in 8:
		var unit := queue.advance_to_next()
		actual.append(unit)
		queue.end_turn(unit)
	_check(actual == expected, "Chạy thật khớp dự đoán")
	_check(is_equal_approx(queue.elapsed, 300.0), "Tổng GTHĐ sau 8 lượt = 300 (%.2f)" % queue.elapsed)

	# Đổi tốc độ giữa trận: B đi lượt đầu (t = 83,3); quãng còn lại của A = 10000 − 83,3 × 100 = 1666,7.
	queue = TurnQueue.new()
	a = _make_unit(100.0)
	b = _make_unit(120.0)
	c = _make_unit(80.0, BattleUnit.Faction.ENEMY)
	for unit in [a, b, c]:
		queue.add(unit)
	var first := queue.advance_to_next()
	queue.end_turn(first)
	_check(first == b, "Lượt đầu là đơn vị nhanh nhất")
	a.stats.add_modifier(Stats.Type.SPD, 100.0)
	_check(is_equal_approx(a.get_action_value(), 1666.6667 / 200.0), "Tăng Tốc Độ A lên 200 → GTHĐ = 1666,7/200 = 8,33")
	_check(queue.peek_next() == a, "A tăng tốc nên đi ngay sau")
	var second := queue.advance_to_next()
	queue.end_turn(second)
	_check(is_equal_approx(queue.elapsed, 10000.0 / 120.0 + 1666.6667 / 200.0), "Thời điểm A đi = 83,33 + 8,33")

	# Kéo lượt 50% và trì hoãn 25%.
	var before := c.distance_left
	queue.action_advance(c, 0.5)
	_check(is_equal_approx(c.distance_left, maxf(before - 5000.0, 0.0)), "Kéo lượt 50% trừ 5000 quãng đường")
	before = b.distance_left
	queue.delay(b, 0.25)
	_check(is_equal_approx(b.distance_left, before + 2500.0), "Trì hoãn 25% cộng 2500 quãng đường")
	_check(queue.predict(1, null, {b: 0.0})[0]["unit"] == b, "Xem trước: kéo B về 0 thì B đi kế tiếp")


func _test_team_limit() -> void:
	var original := GameState.team.duplicate()
	var five: Array[StringName] = [&"traveler", &"mira", &"kiri", &"garren", &"traveler"]
	_check(not GameState.set_team(five), "GameState từ chối đội 5 người")
	_check(GameState.team == original, "Đội cũ giữ nguyên khi bị từ chối")
	var duplicate_team: Array[StringName] = [&"mira", &"mira"]
	_check(not GameState.set_team(duplicate_team), "Từ chối nhân vật trùng trong đội")
	var controller := BattleController.new()
	var team := _team_data()
	team.append(team[0])
	_check(controller.setup(team, 1, load(SPROUTS), BattleTypes.Opening.NORMAL) == ERR_PARAMETER_RANGE_ERROR,
			"BattleController từ chối đội 5 người")
	controller.free()


# --- Trận chạy bằng BattleController (không giao diện) ---

func _team_data() -> Array[CharacterData]:
	var team: Array[CharacterData] = []
	for id in GameState.DEFAULT_TEAM:
		team.append(DataPaths.load_character(id))
	return team


func _new_battle(encounter_path: String, opening: BattleTypes.Opening, level: int = 5,
		seed_value: int = 1) -> BattleController:
	var controller := BattleController.new()
	controller.instant = true
	controller.auto_mode = true
	controller.rng.seed = seed_value
	add_child(controller)
	var err := controller.setup(_team_data(), level, load(encounter_path), opening)
	if err != OK:
		_fail("setup lỗi %d" % err)
	return controller


func _test_openings() -> void:
	var cases := {
		BattleTypes.Opening.ADVANTAGE: "Ưu Thế: 4 lượt đầu là phe ta",
		BattleTypes.Opening.AMBUSHED: "Phục Kích: 3 lượt đầu là quái",
	}
	for opening: BattleTypes.Opening in cases:
		var controller := _new_battle(SPROUTS, opening)
		var turns: Array[BattleUnit] = []
		controller.turn_started.connect(func(unit: BattleUnit) -> void: turns.append(unit))
		controller.start()
		while turns.size() < 4 and controller.phase != BattleController.Phase.ENDED:
			await _frames(1)
		var ok := false
		if opening == BattleTypes.Opening.ADVANTAGE:
			ok = turns.size() >= 4 and turns.slice(0, 4).all(func(u: BattleUnit) -> bool: return u.is_ally())
		else:
			ok = turns.size() >= 3 and turns.slice(0, 3).all(func(u: BattleUnit) -> bool: return not u.is_ally())
		_check(ok, cases[opening])
		controller.force_end(true)
		controller.queue_free()
	var normal := _new_battle(SPROUTS, BattleTypes.Opening.NORMAL)
	var first: Array[BattleUnit] = []
	normal.turn_started.connect(func(unit: BattleUnit) -> void: first.append(unit))
	normal.start()
	while first.is_empty():
		await _frames(1)
	_check(first[0].character != null and first[0].character.id == &"kiri", "Bình thường: người nhanh nhất (Kiri) đi trước")
	normal.force_end(true)
	normal.queue_free()


func _test_skill_points_and_auto_simulation() -> void:
	# Lambda chụp biến cục bộ theo giá trị, nên gom số liệu vào Dictionary (tham chiếu).
	var sp_range := {"min": 99, "max": -99}
	var wins := 0
	var finished := 0
	var waves_ok := true
	for i in SIMULATED_BATTLES:
		var encounter := MIXED if i % 2 == 0 else SPROUTS
		var controller := _new_battle(encounter, i % 3 as BattleTypes.Opening, 5, 1000 + i)
		var waves_seen: Array[int] = []
		controller.skill_points_changed.connect(func(value: int) -> void:
			sp_range["min"] = mini(sp_range["min"], value)
			sp_range["max"] = maxi(sp_range["max"], value))
		controller.wave_started.connect(func(index: int, _e: Array[BattleUnit]) -> void: waves_seen.append(index))
		if i % 2 == 1:
			# Nửa số trận: phe ta chọn ngẫu nhiên (thử bừa) để Điểm Chiến Kỹ chạm cả 2 biên.
			controller.auto_mode = false
			var fuzz_rng := RandomNumberGenerator.new()
			fuzz_rng.seed = 500 + i
			controller.input_requested.connect(func(unit: BattleUnit) -> void:
				_submit_random.call_deferred(controller, unit, fuzz_rng))
		controller.start()
		var frames := 0
		while controller.phase != BattleController.Phase.ENDED and frames < 5000:
			await _frames(1)
			frames += 1
		if controller.phase == BattleController.Phase.ENDED:
			finished += 1
			if controller.won:
				wins += 1
				if encounter == MIXED and not waves_seen.has(1):
					waves_ok = false
				if encounter == MIXED and controller.wave_index != 1:
					waves_ok = false
		controller.queue_free()
	_check(finished == SIMULATED_BATTLES, "%d trận Tự Động đều kết thúc" % SIMULATED_BATTLES)
	var min_sp: int = sp_range["min"]
	var max_sp: int = sp_range["max"]
	_check(min_sp >= 0 and max_sp <= 5, "Điểm Chiến Kỹ luôn trong 0–5 (thấy %d–%d)" % [min_sp, max_sp])
	print("    (Điểm Chiến Kỹ thấy trong mô phỏng: %d–%d)" % [min_sp, max_sp])
	_check(max_sp == 5 and min_sp == 0, "Điểm Chiến Kỹ chạm cả 0 và 5 trong mô phỏng")
	_check(wins > SIMULATED_BATTLES / 2, "Đội cấp 5 thắng phần lớn trận mẫu, kể cả khi chọn bừa (%d/%d)" % [wins, SIMULATED_BATTLES])
	_check(waves_ok, "Trận 2 đợt: thắng sau khi qua đủ 2 đợt")
	var sp_test := _new_battle(SPROUTS, BattleTypes.Opening.NORMAL)
	for i in 10:
		sp_test.change_skill_points(1)
	var high := sp_test.skill_points
	for i in 10:
		sp_test.change_skill_points(-1)
	_check(high == 5 and sp_test.skill_points == 0, "change_skill_points kẹp trong 0–5")
	sp_test.queue_free()


func _submit_random(controller: BattleController, unit: BattleUnit, fuzz_rng: RandomNumberGenerator) -> void:
	if not controller.is_awaiting_input() or controller.current_unit != unit:
		return
	# Thiên về đánh thường để tích Điểm Chiến Kỹ lên trần.
	var kind := SkillData.Kind.SKILL if fuzz_rng.randf() < 0.35 else SkillData.Kind.BASIC
	if not controller.can_use(unit, unit.get_skill(kind)):
		kind = SkillData.Kind.BASIC
	var pool := SkillExecutor.get_target_pool(unit.get_skill(kind), unit, controller.allies, controller.enemies)
	controller.submit_action(kind, pool[fuzz_rng.randi_range(0, pool.size() - 1)])
	for ally in controller.allies:
		if ally.is_ultimate_ready() and fuzz_rng.randf() < 0.5:
			controller.request_ultimate(ally, null)


func _test_ultimate_interrupt() -> void:
	var controller := _new_battle(MIXED, BattleTypes.Opening.NORMAL, 5, 7)
	controller.auto_mode = false
	var action_log: Array[String] = []
	controller.action_started.connect(func(unit: BattleUnit, skill: SkillData, _t: Array[BattleUnit]) -> void:
		action_log.append("%s:%s" % [unit.id, SkillData.Kind.keys()[skill.kind]]))
	var garren := controller.allies[3]
	var state := {"requested": false}
	controller.input_requested.connect(func(unit: BattleUnit) -> void:
		controller.submit_action.call_deferred(SkillData.Kind.BASIC, controller.enemies.filter(
				func(e: BattleUnit) -> bool: return e.is_alive())[0]))
	controller.turn_started.connect(func(unit: BattleUnit) -> void:
		# Ngay khi lượt quái bắt đầu, Garren đầy năng lượng và bấm Tuyệt kỹ.
		if not unit.is_ally() and not state["requested"]:
			state["requested"] = true
			garren.set_energy(garren.max_energy)
			controller.request_ultimate(garren, null))
	controller.start()
	var frames := 0
	while action_log.filter(func(e: String) -> bool: return e.ends_with("ULTIMATE")).is_empty() and frames < 2000:
		await _frames(1)
		frames += 1
	var ult_index := action_log.find("%s:ULTIMATE" % garren.id)
	_check(ult_index > 0 and not action_log[ult_index - 1].begins_with("ally"), "Tuyệt kỹ chen ngay sau hành động của quái")
	# action_started phát trước khi kỹ năng chạy xong; đợi kỹ năng xử lý.
	for i in 10:
		await _frames(1)
	_check(garren.energy < garren.max_energy, "Dùng Tuyệt kỹ thì trừ hết năng lượng (còn %.0f)" % garren.energy)
	controller.force_end(true)
	controller.queue_free()


# --- Màn trận có giao diện ---

func _open_battle_scene(encounter_path: String, extra: Dictionary = {}) -> Node:
	var payload := {"encounter": load(encounter_path), "opening": BattleTypes.Opening.NORMAL, "instant": true}
	payload.merge(extra, true)
	SceneRouter.go_to(DataPaths.BATTLE_SCENE, payload, 0.01)
	await SceneRouter.transition_finished
	return get_tree().current_scene


func _click_at(canvas_position: Vector2) -> void:
	var window_position := get_viewport().get_final_transform() * canvas_position
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = window_position
		event.global_position = window_position
		Input.parse_input_event(event)
	Input.flush_buffered_events()


func _test_scene_mouse_battle() -> void:
	GameState.team_level = 10
	UserSettings.set_value("battle", "auto", false)
	var scene := await _open_battle_scene(SPROUTS)
	var controller: BattleController = scene.controller
	_check(controller.allies.size() == 4 and controller.enemies.size() == 3, "Màn trận: 4 nhân vật vs 3 quái")
	var clicks := 0
	var skills_used := 0
	var ultimates_used := 0
	var preview_seen := false
	var frames := 0
	while controller.phase != BattleController.Phase.ENDED and frames < 20000:
		frames += 1
		await _frames(1)
		# Tuyệt kỹ khi đầy: bấm vào thẻ nhân vật bằng chuột thật.
		for card: CharacterCard in scene.get_node("%Cards").get_children():
			if card.unit.is_ultimate_ready() and not controller.is_ultimate_queued(card.unit) \
					and scene.get_mode() != scene.Mode.ULTIMATE:
				_click_at(card.get_global_rect().get_center())
				await _frames(1)
				if scene.get_mode() == scene.Mode.ULTIMATE:
					_click_at(scene.get_view(scene.get_target()).global_position)
				ultimates_used += 1
				await _frames(1)
		if not controller.is_awaiting_input() or scene.get_mode() != scene.Mode.CHOOSE:
			continue
		var acting: BattleUnit = controller.current_unit
		var skill := acting.get_skill(SkillData.Kind.SKILL)
		if controller.skill_points >= 2 and skill and skill.target == SkillData.Target.SINGLE_ALLY:
			# Chiến kỹ nhắm đồng minh: bấm nút Chiến kỹ rồi bấm đồng minh.
			scene.get_node("%SkillButton").pressed.emit()
			await _frames(1)
			if skill.get_action_advance() > 0.0 and scene.get_turn_order_bar().is_previewing():
				preview_seen = true
			_click_at(scene.get_view(scene.get_target()).global_position)
			skills_used += 1
		else:
			if controller.skill_points >= 3 and skill and skill.deals_damage():
				scene.get_node("%SkillButton").pressed.emit()
				await _frames(1)
				skills_used += 1
			var target: BattleUnit = controller.enemies.filter(func(e: BattleUnit) -> bool: return e.is_alive())[0]
			_click_at(scene.get_view(target).global_position)
		clicks += 1
	_check(controller.phase == BattleController.Phase.ENDED and controller.won,
			"Đánh trọn trận bằng chuột và thắng (%d lần bấm, %d chiến kỹ, %d tuyệt kỹ)" % [clicks, skills_used, ultimates_used])
	_check(skills_used > 0 and ultimates_used > 0, "Đã dùng cả Chiến kỹ và Tuyệt kỹ (bấm thẻ)")
	_check(preview_seen, "Chọn Chiến kỹ kéo lượt thì thanh thứ tự lượt hiện xem trước")
	_check(scene.get_node("%ResultPanel").visible and scene.get_node("%ContinueButton").visible, "Hiện màn thắng")
	scene.get_node("%ContinueButton").pressed.emit()
	await SceneRouter.transition_finished
	_check(get_tree().current_scene is OverworldMap, "Thắng xong quay về map")


func _test_scene_auto_battle() -> void:
	GameState.team_level = 10
	var scene := await _open_battle_scene(MIXED)
	scene.set_auto(true)
	var controller: BattleController = scene.controller
	var frames := 0
	while controller.phase != BattleController.Phase.ENDED and frames < 20000:
		await _frames(1)
		frames += 1
	_check(controller.won, "Đánh trọn trận 2 đợt bằng Tự Động và thắng")
	scene.set_auto(false)
	UserSettings.set_value("battle", "auto", false)

	# Màn thua: Đánh lại mở lại cùng trận, Rút lui về map.
	scene = await _open_battle_scene(SPROUTS)
	scene.debug_force_result(false)
	await _frames(2)
	_check(scene.get_node("%RetryButton").visible and scene.get_node("%RetreatButton").visible,
			"Màn thua có Đánh lại và Rút lui")
	scene.get_node("%RetryButton").pressed.emit()
	await SceneRouter.transition_finished
	_check(get_tree().current_scene.scene_file_path == DataPaths.BATTLE_SCENE, "Đánh lại mở lại trận")
	get_tree().current_scene.debug_force_result(false)
	await _frames(2)
	get_tree().current_scene.get_node("%RetreatButton").pressed.emit()
	await SceneRouter.transition_finished
	_check(get_tree().current_scene is OverworldMap, "Rút lui về map")


func _test_scene_rejects_five() -> void:
	var team := _team_data()
	team.append(DataPaths.load_character(&"traveler"))
	var scene := await _open_battle_scene(SPROUTS, {"team_override": team})
	_check(scene.is_setup_failed() and scene.get_node("%ResultPanel").visible, "Màn trận từ chối đội 5 người và báo lỗi")
	_check(scene.controller.allies.is_empty(), "Không có nhân vật nào vào trận khi đội quá 4")
	GameState.team_level = 1
