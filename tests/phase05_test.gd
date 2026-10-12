extends "res://tests/test_base.gd"
## Kiểm thử Phase 5: 7 nguyên tố, kháng 20% / điểm yếu 0%, Khiên Điểm Yếu (chỉ đúng nguyên tố mới giảm),
## Phá Vỡ (sát thương, trì hoãn 25%, hồi khiên đầu lượt sau, hệ số 0,9/1,0), đủ 7 hiệu ứng phá vỡ,
## hệ thống hiệu ứng (số lượt, cộng dồn, chỉ số), tỉ lệ trúng (giả lập 10.000 lần),
## Ưu Thế đúng điểm yếu trừ 25% khiên, phòng thử trận.
## Chạy: godot --headless --path . res://tests/phase05_test.tscn

const MIXED: String = "res://data/encounters/test_mixed_lv5.tres"
const DUMMIES: String = "res://data/encounters/sandbox_dummies.tres"
const ATK_UP: String = "res://data/status_effects/test_atk_up.tres"
const DEF_DOWN: String = "res://data/status_effects/test_def_down.tres"
const SIMULATIONS: int = 10000

var _heavy: SkillData


func _run() -> void:
	phase_name = "Phase 5"
	timeout_sec = 180.0
	_heavy = _make_skill(0.01, 200.0)
	_test_elements()
	_test_resistance_and_toughness()
	_test_break_factor_and_recovery()
	_test_break_effects()
	_test_status_system()
	_test_hit_chance()
	_test_advantage_toughness()
	await _test_sandbox_scene()
	_finish()


# --- Tiện ích ---

func _make_skill(multiplier: float, toughness: float, target := SkillData.Target.SINGLE_ENEMY) -> SkillData:
	return SkillData.simple_damage(multiplier, toughness, target)


func _team() -> Array[CharacterData]:
	var team: Array[CharacterData] = []
	for id in GameState.DEFAULT_TEAM:
		team.append(DataPaths.load_character(id))
	return team


func _battle(encounter_path: String, opening := BattleTypes.Opening.NORMAL,
		opener_element: int = Element.NONE) -> BattleController:
	var controller := BattleController.new()
	controller.instant = true
	controller.crit_mode = DamageCalc.CritMode.NEVER
	controller.rng.seed = 42
	add_child(controller)
	var err := controller.setup(_team(), 10, load(encounter_path), opening, {}, {}, opener_element)
	if err != OK:
		_fail("setup lỗi %d" % err)
	return controller


func _find_enemy(controller: BattleController, enemy_id: StringName) -> BattleUnit:
	for unit in controller.enemies:
		if unit.enemy.id == enemy_id:
			return unit
	return null


func _hit(controller: BattleController, element: int, target: BattleUnit, skill: SkillData = null) -> Array[Dictionary]:
	controller.debug_element_override = element
	return SkillExecutor.execute(controller, controller.allies[0], skill if skill else _heavy, target)


func _events_of(events: Array[Dictionary], type: String) -> Array[Dictionary]:
	return events.filter(func(e: Dictionary) -> bool: return e["type"] == type)


# --- Nguyên tố, kháng, khiên ---

func _test_elements() -> void:
	var expected := ["E8552B", "3A8DDE", "A65BF2", "4FD1B5", "9BC53D", "2E8B57", "F2D58A"]
	var colors_ok := Element.all().size() == 7
	for i in 7:
		colors_ok = colors_ok and Element.color(Element.all()[i]).to_html(false).to_upper() == expected[i]
	_check(colors_ok, "7 nguyên tố, màu đúng bảng mục 6")
	var knight := DataPaths.load_character(&"traveler")
	_check(knight.element == Element.Type.SOUL, "Nhân vật chính mang nguyên tố Hồn")
	for path in ["warp_sprout", "wandering_shade", "rusted_knight"]:
		var data := load("res://data/enemies/%s.tres" % path) as EnemyData
		_check(data.weaknesses.size() >= 1 and data.weaknesses.size() <= 3 and data.max_toughness > 0.0,
				"%s có 1–3 điểm yếu và thanh khiên" % path)


func _test_resistance_and_toughness() -> void:
	var controller := _battle(MIXED)
	var knight := _find_enemy(controller, &"rusted_knight")
	_check(is_equal_approx(knight.get_res(Element.Type.SOUL), 0.2) and is_equal_approx(knight.get_res(Element.Type.WATER), 0.0),
			"Kháng mặc định 20%, nguyên tố điểm yếu 0%")
	var base_skill := _make_skill(1.0, 0.0)
	var ally := controller.allies[0]
	var weak_damage := DamageCalc.compute(SkillExecutor.build_damage_params(ally, knight, Stats.Type.ATK, 1.0, Element.Type.WATER), false)
	var resisted := DamageCalc.compute(SkillExecutor.build_damage_params(ally, knight, Stats.Type.ATK, 1.0, Element.Type.SOUL), false)
	_check(absf(resisted / float(weak_damage) - 0.8) < 0.02, "Sai nguyên tố gây 80%% sát thương (%d vs %d)" % [resisted, weak_damage])

	var start := knight.toughness
	var soul_events := _hit(controller, Element.Type.SOUL, knight, _make_skill(0.01, 30.0))
	_check(knight.toughness == start and _events_of(soul_events, "toughness").is_empty(), "Đòn sai nguyên tố không làm giảm khiên")
	_hit(controller, Element.Type.WATER, knight, _make_skill(0.01, 30.0))
	_check(is_equal_approx(knight.toughness, start - 30.0) and not knight.is_broken, "Đòn đúng điểm yếu giảm khiên 30")
	var before_distance := knight.distance_left
	var break_events := _hit(controller, Element.Type.WATER, knight, _make_skill(0.01, 30.0))
	_check(knight.is_broken and not _events_of(break_events, "break").is_empty(), "Khiên về 0 → Phá Vỡ, có sát thương phá vỡ")
	_check(_events_of(break_events, "break")[0]["amount"] > 0, "Sát thương phá vỡ > 0")
	_check(is_equal_approx(knight.distance_left, before_distance + 2500.0), "Phá Vỡ trì hoãn 25% (+2500 quãng đường)")
	var again := _hit(controller, Element.Type.WATER, knight, _make_skill(0.01, 30.0))
	_check(_events_of(again, "toughness").is_empty(), "Đang Phá Vỡ thì không trừ khiên thêm")
	controller.queue_free()


func _test_break_factor_and_recovery() -> void:
	var controller := _battle(MIXED)
	var knight := _find_enemy(controller, &"rusted_knight")
	var skill := _make_skill(1.0, 0.0)
	var ally := controller.allies[0]
	var shielded := DamageCalc.compute_raw(SkillExecutor.build_damage_params(ally, knight, Stats.Type.ATK, 1.0, Element.Type.WATER), false)
	BreakSystem.trigger_break(controller, ally, knight, Element.Type.WATER)
	# Đặc tính nhân vật chính cộng Tấn Công khi Phá Vỡ (Phase 6); gỡ để so đúng hệ số.
	StatusEffects.remove_all(ally)
	var broken := DamageCalc.compute_raw(SkillExecutor.build_damage_params(ally, knight, Stats.Type.ATK, 1.0, Element.Type.WATER), false)
	_check(is_equal_approx(broken / shielded, 1.0 / 0.9), "Hệ số phá vỡ 0,9 khi còn khiên, 1,0 khi đã vỡ")
	StatusEffects.remove_all(knight)
	var result := controller.process_turn_start(knight)
	_check(not knight.is_broken and knight.toughness == knight.max_toughness, "Đầu lượt kế tiếp của quái: hồi đầy khiên")
	_check(not _events_of(result["events"], "recover").is_empty(), "Có sự kiện hồi khiên")
	controller.queue_free()


# --- 7 hiệu ứng phá vỡ ---

func _break_dummy(element: int) -> Dictionary:
	var controller := _battle(DUMMIES)
	var dummy := _find_enemy(controller, &"training_dummy")
	var before := dummy.distance_left
	var events := _hit(controller, element, dummy)
	return {"controller": controller, "dummy": dummy, "events": events, "before": before}


func _test_break_effects() -> void:
	var cfg := BreakSystem.config()
	_check(cfg.break_effects.size() == 7, "Cấu hình phá vỡ có đủ 7 hiệu ứng")
	var effect_ids := {
		Element.Type.FIRE: &"burn", Element.Type.WATER: &"freeze", Element.Type.LIGHTNING: &"shock",
		Element.Type.WIND: &"wind_shear", Element.Type.POISON: &"poisoned", Element.Type.WOOD: &"entangle",
		Element.Type.SOUL: &"imprison"}
	var dot_amounts: Dictionary = {}
	for element: int in effect_ids:
		var r := _break_dummy(element)
		var dummy: BattleUnit = r["dummy"]
		var controller: BattleController = r["controller"]
		var id: StringName = effect_ids[element]
		_check(dummy.is_broken and dummy.has_status(id), "Phá Vỡ bằng %s gắn %s" % [tr(Element.name_key(element)), id])
		var base := BreakSystem.break_base(controller.allies[0])
		match id:
			&"burn", &"shock":
				var start := controller.process_turn_start(dummy)
				var dots := _events_of(start["events"], "dot")
				dot_amounts[id] = dots[0]["amount"] if not dots.is_empty() else 0.0
				_check(dots.size() == 1 and dots[0]["element"] == element, "%s: sát thương %s đầu lượt" % [id, tr(Element.name_key(element))])
				controller.process_turn_end(dummy)
				controller.process_turn_start(dummy)
				controller.process_turn_end(dummy)
				_check(not dummy.has_status(id), "%s: hết sau 2 lượt" % id)
			&"freeze":
				var start := controller.process_turn_start(dummy)
				var dots := _events_of(start["events"], "dot")
				_check(bool(start["skip"]), "Đóng Băng: quái mất lượt")
				_check(dots.size() == 1 and dots[0]["element"] == Element.Type.WATER and dots[0]["amount"] > 0,
						"Đóng Băng: tan thì nhận thêm sát thương Nước")
				_check(not dummy.has_status(id) and not bool(controller.process_turn_start(dummy)["skip"]),
						"Đóng Băng: chỉ mất 1 lượt")
			&"wind_shear":
				for i in 6:
					dummy.recover_toughness()
					_hit(controller, element, dummy)
				var instance := dummy.get_status(id)
				_check(instance.stacks == 5, "Phong Cắt: cộng dồn tối đa 5 tầng (có %d)" % instance.stacks)
				var one := StatusEffects.effect_damage(base * instance.data.dot_multiplier, element, controller.allies[0].level, dummy)
				var dot := StatusEffects.compute_dot(instance, dummy)
				_check(absi(dot - one * 5) <= 5, "Phong Cắt: 5 tầng gây ≈5 lần sát thương 1 tầng (%d vs %d)" % [dot, one])
			&"poisoned":
				var instance := dummy.get_status(id)
				var capped := StatusEffects.effect_damage(base * instance.data.dot_cap_multiplier, element, controller.allies[0].level, dummy)
				_check(StatusEffects.compute_dot(instance, dummy) == capped, "Nhiễm Độc: % máu tối đa bị chặn trần (bù nhìn 50.000 máu)")
				_check(is_equal_approx(dummy.stats.get_value(Stats.Type.DEF_REDUCTION), 0.1), "Nhiễm Độc: giảm 10% Phòng Thủ")
				var low := _find_enemy(controller, &"training_dummy_fire")
				StatusEffects.apply(instance.data, controller.allies[0], low, base)
				low.hp = 100.0
				var low_dot := StatusEffects.compute_dot(low.get_status(id), low)
				_check(low_dot < capped, "Nhiễm Độc: mục tiêu ít máu nhận theo % máu (dưới trần)")
				controller.process_turn_end(dummy)
				controller.process_turn_end(dummy)
				_check(is_equal_approx(dummy.stats.get_value(Stats.Type.DEF_REDUCTION), 0.0), "Nhiễm Độc hết thì trả lại Phòng Thủ")
			&"entangle":
				_check(is_equal_approx(dummy.distance_left, float(r["before"]) + 2500.0 + 2000.0),
						"Trói Rễ: trì hoãn 25% + thêm 20%")
				var next := _hit(controller, Element.Type.SOUL, dummy, _make_skill(0.01, 0.0))
				var extra := _events_of(next, "dot")
				_check(extra.size() == 1 and extra[0]["element"] == Element.Type.WOOD and extra[0]["amount"] > 0,
						"Trói Rễ: đòn kế tiếp gây thêm sát thương Mộc")
				_check(not dummy.has_status(id), "Trói Rễ: dùng xong thì mất")
			&"imprison":
				_check(is_equal_approx(dummy.distance_left, float(r["before"]) + 2500.0 + 3000.0),
						"Giam Hồn: trì hoãn 25% + thêm 30%")
				var base_speed := dummy.stats.get_base(Stats.Type.SPD)
				_check(is_equal_approx(dummy.get_speed(), base_speed * 0.9), "Giam Hồn: giảm 10% Tốc Độ")
				controller.process_turn_start(dummy)
				controller.process_turn_end(dummy)
				_check(is_equal_approx(dummy.get_speed(), base_speed) and not dummy.has_status(id),
						"Giam Hồn: hết sau 1 lượt, trả lại Tốc Độ")
		controller.queue_free()
	_check(dot_amounts.has(&"burn") and dot_amounts.has(&"shock") and absf(dot_amounts[&"shock"] - dot_amounts[&"burn"] * 2.0) <= 2.0,
			"Điện Giật (hệ số 2) gấp đôi Thiêu Đốt (hệ số 1) trên cùng mục tiêu")


# --- Hệ thống hiệu ứng ---

func _test_status_system() -> void:
	var controller := _battle(MIXED)
	var ally := controller.allies[0]
	var atk_up := load(ATK_UP) as StatusEffectData
	var base_atk := ally.stats.get_value(Stats.Type.ATK)
	StatusEffects.apply(atk_up, ally, ally)
	_check(is_equal_approx(ally.stats.get_value(Stats.Type.ATK), base_atk * 1.2), "Buff +20% Tấn Công áp vào chỉ số")
	StatusEffects.apply(atk_up, ally, ally)
	_check(ally.get_status(atk_up.id).stacks == 1 and is_equal_approx(ally.stats.get_value(Stats.Type.ATK), base_atk * 1.2),
			"Gắn lại hiệu ứng REFRESH chỉ làm mới, không cộng dồn")
	controller.process_turn_end(ally)
	_check(ally.get_status(atk_up.id).turns_left == 1, "Cuối lượt trừ 1 lượt")
	controller.process_turn_end(ally)
	_check(not ally.has_status(atk_up.id) and is_equal_approx(ally.stats.get_value(Stats.Type.ATK), base_atk),
			"Hết lượt thì gỡ hiệu ứng, trả lại chỉ số")
	controller.queue_free()


func _test_hit_chance() -> void:
	var controller := _battle(MIXED)
	var source := controller.allies[0]
	var target := _find_enemy(controller, &"rusted_knight")
	var def_down := load(DEF_DOWN) as StatusEffectData
	source.stats.add_modifier(Stats.Type.EFFECT_HIT, 0.2, 0.0, &"test")
	target.stats.add_modifier(Stats.Type.EFFECT_RES, 0.3, 0.0, &"test")
	var expected := 0.6 * 1.2 * 0.7
	_check(is_equal_approx(StatusEffects.hit_chance(def_down, source, target), expected),
			"Tỉ lệ trúng = 60% × (1 + 20%) × (1 − 30%) = 50,4%")
	var rng := RandomNumberGenerator.new()
	rng.seed = 2024
	var hits := 0
	for i in SIMULATIONS:
		var instance := StatusEffects.try_apply(def_down, source, target, rng)
		if instance:
			hits += 1
			StatusEffects.remove(target, instance)
	var rate := hits / float(SIMULATIONS)
	_check(absf(rate - expected) < 0.02, "Giả lập %d lần: trúng %.1f%% (kỳ vọng %.1f%%)" % [SIMULATIONS, rate * 100.0, expected * 100.0])
	target.stats.add_modifier(Stats.Type.EFFECT_RES, 0.7, 0.0, &"test")
	hits = 0
	for i in 1000:
		if StatusEffects.try_apply(def_down, source, target, rng):
			hits += 1
	_check(hits == 0, "Kháng Hiệu Ứng 100% thì không bao giờ trúng")
	var atk_up := load(ATK_UP) as StatusEffectData
	_check(StatusEffects.hit_chance(atk_up, source, target) == 1.0, "Hiệu ứng bỏ qua kháng luôn trúng")
	controller.queue_free()


func _test_advantage_toughness() -> void:
	var water := _battle(MIXED, BattleTypes.Opening.ADVANTAGE, Element.Type.WATER)
	var knight := _find_enemy(water, &"rusted_knight")
	var shade := _find_enemy(water, &"wandering_shade")
	_check(is_equal_approx(knight.toughness, knight.max_toughness * 0.75), "Ưu Thế đúng điểm yếu (Nước): quái mất 25% khiên")
	_check(shade.toughness == shade.max_toughness, "Quái không yếu Nước giữ nguyên khiên")
	water.queue_free()
	var soul := _battle(MIXED, BattleTypes.Opening.ADVANTAGE, Element.Type.SOUL)
	_check(_find_enemy(soul, &"rusted_knight").toughness == 60.0 and is_equal_approx(_find_enemy(soul, &"wandering_shade").toughness, 30.0 * 0.75),
			"Ưu Thế bằng Hồn: chỉ quái yếu Hồn mất khiên")
	soul.queue_free()
	var normal := _battle(MIXED, BattleTypes.Opening.NORMAL, Element.Type.WATER)
	_check(_find_enemy(normal, &"rusted_knight").toughness == 60.0, "Không Ưu Thế thì không trừ khiên")
	normal.queue_free()


# --- Phòng thử trận ---

func _test_sandbox_scene() -> void:
	GameState.team_level = 10
	UserSettings.set_value("battle", "auto", false)
	SceneRouter.go_to(DataPaths.BATTLE_SANDBOX_SCENE, {"instant": true}, 0.01)
	await SceneRouter.transition_finished
	var sandbox := get_tree().current_scene
	var battle: Node = sandbox.battle
	var controller: BattleController = battle.controller
	_check(controller.enemies.size() == 3, "Phòng thử: 2 bù nhìn đủ điểm yếu + 1 bù nhìn chỉ yếu Lửa")
	while not controller.is_awaiting_input():
		await _frames(1)
	var fire_dummy := _find_enemy(controller, &"training_dummy_fire")
	sandbox.select_element(Element.Type.WATER)
	var start := fire_dummy.toughness
	var hp_before := fire_dummy.hp
	_check(controller.submit_action(SkillData.Kind.BASIC, fire_dummy), "Phòng thử: ra đòn qua lượt thật")
	for i in 20:
		await _frames(1)
	_check(fire_dummy.hp < hp_before and fire_dummy.toughness == start,
			"Phòng thử: đánh Nước trúng bù nhìn chỉ yếu Lửa (mất %d máu) nhưng không giảm khiên" % (hp_before - fire_dummy.hp))
	while not controller.is_awaiting_input():
		await _frames(1)
	sandbox.select_element(Element.Type.FIRE)
	controller.submit_action(SkillData.Kind.BASIC, fire_dummy)
	for i in 20:
		await _frames(1)
	_check(fire_dummy.toughness < start, "Phòng thử: đổi sang Lửa thì giảm khiên")

	var seen: Dictionary = {}
	for element in Element.all():
		sandbox.select_element(element)
		sandbox.reset_dummies()
		var dummy := _find_enemy(controller, &"training_dummy")
		var events := SkillExecutor.execute(controller, controller.allies[0], _heavy, dummy)
		for event in _events_of(events, "status_applied"):
			seen[event["status"]] = true
	_check(seen.size() == 7, "Phòng thử: chọn đủ 7 nguyên tố ra đủ 7 hiệu ứng phá vỡ (%d)" % seen.size())

	await _frames(2)
	var dummy := _find_enemy(controller, &"training_dummy")
	var view: UnitView = battle.get_view(dummy)
	var icon_center := view.to_global(view.get_status_icon_rect(0).get_center())
	var motion := InputEventMouseMotion.new()
	motion.position = get_viewport().get_final_transform() * icon_center
	Input.parse_input_event(motion)
	Input.flush_buffered_events()
	await _frames(2)
	_check(battle.is_tooltip_visible() and battle.get_status_tooltip_text().contains(tr(dummy.status_effects[0].data.name_key)),
			"Rê chuột vào biểu tượng hiệu ứng thì hiện mô tả")
	GameState.team_level = 1
