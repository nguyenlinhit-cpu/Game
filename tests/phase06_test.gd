extends "res://tests/test_base.gd"
## Kiểm thử Phase 6: hệ kỹ năng dạng hiệu ứng ghép, TalentScript (Đặc tính + Tinh Mệnh), trọng số bị nhắm
## và Khiêu Khích, 5 nhân vật (đủ 2 kỹ năng map, 3 kỹ năng trận, Đặc tính), đội đúng 4 trong 5 người,
## đổi người dẫn đầu, 7 loại vật cản + rào Ma Biến, Bí Kỹ và Điểm Bí Kỹ.
## Chạy: godot --headless --path . res://tests/phase06_test.tscn

const DUMMIES: String = "res://data/encounters/sandbox_dummies.tres"
const MIXED: String = "res://data/encounters/test_mixed_lv5.tres"
const CHARACTER_IDS: Array[StringName] = [&"traveler", &"mira", &"kiri", &"garren", &"nyx"]
const DEF_DOWN: String = "res://data/status_effects/test_def_down.tres"


func _run() -> void:
	phase_name = "Phase 6"
	timeout_sec = 300.0
	GameState.reset_new_game()
	_test_character_data()
	await _test_effect_system()
	_test_aggro_and_taunt()
	await _test_traveler()
	await _test_mira()
	await _test_kiri()
	await _test_garren()
	await _test_nyx()
	_test_eidolon_data()
	_test_team_of_four()
	await _test_overworld()
	await _test_technique_battles()
	_finish()


# --- Tiện ích ---

func _team(ids: Array[StringName]) -> Array[CharacterData]:
	var team: Array[CharacterData] = []
	for id in ids:
		team.append(DataPaths.load_character(id))
	return team


func _battle(ids: Array[StringName], encounter_path: String = DUMMIES, eidolons: Dictionary = {},
		techniques: Array[StringName] = []) -> BattleController:
	var controller := BattleController.new()
	controller.instant = true
	controller.crit_mode = DamageCalc.CritMode.NEVER
	controller.rng.seed = 7
	add_child(controller)
	var err := controller.setup(_team(ids), 20, load(encounter_path), BattleTypes.Opening.NORMAL, {}, {},
			Element.NONE, eidolons, techniques)
	if err != OK:
		_fail("setup lỗi %d" % err)
	return controller


func _ally(controller: BattleController, id: StringName) -> BattleUnit:
	for unit in controller.allies:
		if unit.character.id == id:
			return unit
	return null


func _dummy(controller: BattleController, index: int = 0) -> BattleUnit:
	return controller.enemies[index]


func _use(controller: BattleController, unit: BattleUnit, kind: SkillData.Kind, target: BattleUnit) -> Array[Dictionary]:
	var events := SkillExecutor.execute(controller, unit, unit.get_skill(kind), target)
	controller._handle_deaths(events)
	return events


func _of(events: Array[Dictionary], type: String) -> Array[Dictionary]:
	return events.filter(func(e: Dictionary) -> bool: return e["type"] == type)


func _default_ids() -> Array[StringName]:
	return [&"traveler", &"mira", &"kiri", &"garren"]


# --- Dữ liệu nhân vật ---

func _test_character_data() -> void:
	var kinds: Dictionary = {}
	for id in CHARACTER_IDS:
		var data := DataPaths.load_character(id)
		var ok := data.opener != null and data.technique != null and data.basic_attack != null \
				and data.skill != null and data.ultimate != null and data.talent != null \
				and data.talent.script_class != null and data.eidolons.size() == 6
		_check(ok, "%s: đủ Đòn Mở Màn, Bí Kỹ, 3 kỹ năng trận, Đặc tính, 6 Tinh Mệnh" % id)
		_check(data.opener.element == data.element, "%s: Đòn Mở Màn mang nguyên tố nhân vật" % id)
		var lv1 := Stats.from_blocks(data.stats_lv1, data.stats_lv80, 1)
		var lv30 := Stats.from_blocks(data.stats_lv1, data.stats_lv80, 30)
		_check(lv30.get_value(Stats.Type.HP) > lv1.get_value(Stats.Type.HP), "%s: chỉ số cấp 30 > cấp 1" % id)
		kinds[data.technique.kind] = int(kinds.get(data.technique.kind, 0)) + 1
	_check(kinds.size() == 3, "Bí Kỹ của 5 người có đủ 3 kiểu (trận kế tiếp %d, quái trên map %d, khám phá %d)" % [
			kinds.get(TechniqueData.Kind.NEXT_BATTLE, 0), kinds.get(TechniqueData.Kind.MAP_ENEMIES, 0),
			kinds.get(TechniqueData.Kind.EXPLORATION, 0)])
	var traveler := DataPaths.load_character(&"traveler")
	_check(traveler.skins.size() == 2 and traveler.element == Element.Type.SOUL and traveler.path == CharacterPath.Type.DESTRUCTION,
			"Nhân vật chính: 2 skin, Hồn, Hủy Diệt")
	_check(traveler.ultimate.alternate != null, "Tuyệt kỹ nhân vật chính có 2 chế độ (lan / đơn)")


# --- Hệ hiệu ứng ghép ---

func _test_effect_system() -> void:
	var controller := _battle(_default_ids())
	var garren := _ally(controller, &"garren")
	var kiri := _ally(controller, &"kiri")
	var dummy := _dummy(controller)
	# Khiên chặn sát thương.
	var shield_events := _use(controller, garren, SkillData.Kind.SKILL, garren)
	_check(_of(shield_events, "shield").size() == 4 and kiri.shield_hp > 0.0, "Khiên cho cả đội (ShieldEffect, ALL_ALLIES)")
	var hp_before := kiri.hp
	var hit := SkillExecutor.execute(controller, dummy, SkillData.simple_damage(1.0), kiri)
	_check(float(hit[0].get("absorbed", 0.0)) > 0.0 and kiri.hp == hp_before, "Khiên đỡ sát thương trước khi mất máu")
	# Giải hiệu ứng xấu.
	var mira := _ally(controller, &"mira")
	StatusEffects.apply(load(DEF_DOWN), dummy, kiri)
	var cleanse := _use(controller, mira, SkillData.Kind.SKILL, kiri)
	_check(not kiri.has_status(&"test_def_down") and not _of(cleanse, "cleanse").is_empty(), "Giải 1 hiệu ứng xấu (CleanseEffect)")
	# Năng lượng / Điểm Chiến Kỹ / kéo-đẩy lượt / buff qua hiệu ứng ghép.
	var custom := SkillData.new()
	custom.target = SkillData.Target.SINGLE_ALLY
	var energy := EnergyEffect.new()
	energy.amount = 30.0
	energy.fixed = true
	var sp := SkillPointEffect.new()
	sp.amount = 2
	var advance := TurnShiftEffect.new()
	advance.amount = 0.4
	custom.effects = [energy, sp, advance]
	controller.skill_points = 1
	kiri.set_energy(0.0)
	var distance := kiri.distance_left
	SkillExecutor.execute(controller, mira, custom, kiri)
	_check(kiri.energy == 30.0 and controller.skill_points == 3 and is_equal_approx(kiri.distance_left, maxf(distance - 4000.0, 0.0)),
			"EnergyEffect +30, SkillPointEffect +2, TurnShiftEffect kéo lượt 40%")
	# Các kiểu mục tiêu.
	var blast := DataPaths.load_character(&"traveler").skill
	_check(SkillExecutor.resolve_targets(blast, controller.allies[0], controller.enemies[1], controller.allies, controller.enemies).size() == 3,
			"Kiểu mục tiêu lan 3 (giữa + 2 bên)")
	_check(SkillExecutor.resolve_targets(kiri.get_skill(SkillData.Kind.ULTIMATE), kiri, null, controller.allies, controller.enemies).size() == 3,
			"Kiểu mục tiêu toàn bộ quái")
	_check(not SkillExecutor.get_target_pool(kiri.get_skill(SkillData.Kind.SKILL), kiri, controller.allies, controller.enemies).has(kiri),
			"Thổi Bùng không chọn được chính Kiri")
	controller.queue_free()
	await _frames(1)


func _test_aggro_and_taunt() -> void:
	var controller := _battle(_default_ids())
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var poke := SkillData.simple_damage(1.0)
	var pool: Array[BattleUnit] = controller.allies.duplicate()
	var counts: Dictionary = {}
	var total := 10000
	for i in total:
		var target := EnemyAI.choose_target(poke, pool.duplicate(), rng)
		counts[target] = int(counts.get(target, 0)) + 1
	var garren := _ally(controller, &"garren")
	var traveler := _ally(controller, &"traveler")
	var sum_weights := 125.0 + 100.0 + 100.0 + 150.0
	var garren_rate := float(counts.get(garren, 0)) / total
	var traveler_rate := float(counts.get(traveler, 0)) / total
	_check(absf(garren_rate - 150.0 / sum_weights) < 0.02 and absf(traveler_rate - 125.0 / sum_weights) < 0.02,
			"Trọng số bị nhắm theo vận mệnh: Bảo Hộ %.1f%% (kỳ vọng 31,6%%), Hủy Diệt %.1f%% (26,3%%)" % [
			garren_rate * 100.0, traveler_rate * 100.0])
	StatusEffects.apply(load("res://data/status_effects/garren_taunt.tres"), garren, garren)
	var all_garren := true
	for i in 300:
		if EnemyAI.choose_target(poke, pool.duplicate(), rng) != garren:
			all_garren = false
	_check(all_garren, "Khiêu Khích: đòn đơn của quái luôn nhắm Garren")
	controller.queue_free()


# --- Từng nhân vật ---

func _test_traveler() -> void:
	var controller := _battle(_default_ids())
	var kael := _ally(controller, &"traveler")
	var dummy := _dummy(controller, 1)
	var basic := _of(_use(controller, kael, SkillData.Kind.BASIC, dummy), "damage")
	_check(basic.size() == 1 and basic[0]["amount"] > 0, "Kael Đánh thường: 1 mục tiêu")
	var skill := _of(_use(controller, kael, SkillData.Kind.SKILL, dummy), "damage")
	_check(skill.size() == 3, "Kael Chiến kỹ: lan 3 mục tiêu")
	kael.set_energy(kael.max_energy)
	var ult := _of(_use(controller, kael, SkillData.Kind.ULTIMATE, dummy), "damage")
	_check(ult.size() == 3 and ult[0]["amount"] > ult[1]["amount"], "Kael Tuyệt kỹ (lan): chính 270%, bên cạnh 160%")
	var single := SkillExecutor.execute(controller, kael, kael.get_skill(SkillData.Kind.ULTIMATE).alternate, controller.enemies[0])
	_check(_of(single, "damage").size() == 1 and _of(single, "damage")[0]["amount"] > ult[0]["amount"],
			"Kael Tuyệt kỹ (đơn 450%) mạnh hơn mục tiêu chính của chế độ lan")
	# Đặc tính: Phá Vỡ → +20% Tấn Công, tối đa 2 tầng (các đòn trên có thể đã Phá Vỡ, nên so với Tấn Công gốc).
	var base_atk := kael.stats.get_base(Stats.Type.ATK)
	for i in 3:
		for enemy in controller.enemies:
			enemy.recover_toughness()
			BreakSystem.trigger_break(controller, kael, enemy, Element.Type.SOUL)
	var resonance := kael.get_status(&"soul_resonance")
	_check(resonance != null and resonance.stacks == 2, "Đặc tính Kael: Phá Vỡ cộng tầng Cộng Hưởng, tối đa 2")
	_check(is_equal_approx(kael.stats.get_value(Stats.Type.ATK), base_atk * 1.4), "Cộng Hưởng 2 tầng: Tấn Công +40%")
	controller.queue_free()
	await _frames(1)


func _test_mira() -> void:
	var controller := _battle(_default_ids())
	var mira := _ally(controller, &"mira")
	var garren := _ally(controller, &"garren")
	_check(_of(_use(controller, mira, SkillData.Kind.BASIC, _dummy(controller)), "damage").size() == 1, "Mira Đánh thường")
	garren.hp = garren.get_max_hp() * 0.5
	var heal := _of(_use(controller, mira, SkillData.Kind.SKILL, garren), "heal")
	_check(heal.size() == 1 and heal[0]["amount"] > 0, "Mira Chiến kỹ: hồi 1 đồng minh")
	mira.set_energy(mira.max_energy)
	for ally in controller.allies:
		ally.hp = ally.get_max_hp() * 0.6
	_check(_of(_use(controller, mira, SkillData.Kind.ULTIMATE, mira), "heal").size() == 4, "Mira Tuyệt kỹ: hồi cả đội")
	# Đặc tính: đồng minh xuống dưới 30% → hồi ngay 15% máu (đòn phụ, 1 lần mỗi người).
	var kiri := _ally(controller, &"kiri")
	kiri.hp = kiri.get_max_hp()
	SkillExecutor.execute(controller, _dummy(controller), SkillData.simple_damage(0.0001), kiri)
	kiri.take_damage(kiri.get_max_hp() * 0.8)
	var turn_before := controller.turn_count
	await controller._process_interrupts()
	_check(kiri.get_hp_ratio() > 0.3 and controller.turn_count == turn_before, "Đặc tính Mira: hồi ngay đồng minh dưới 30% máu (không tốn lượt)")
	kiri.take_damage(kiri.hp - 1.0)
	await controller._process_interrupts()
	_check(kiri.get_hp_ratio() < 0.3, "Đặc tính Mira chỉ kích hoạt 1 lần mỗi đồng minh")
	controller.queue_free()
	await _frames(1)


func _test_kiri() -> void:
	var controller := _battle(_default_ids())
	var kiri := _ally(controller, &"kiri")
	var kael := _ally(controller, &"traveler")
	_check(_of(_use(controller, kiri, SkillData.Kind.BASIC, _dummy(controller)), "damage").size() == 1, "Kiri Đánh thường")
	var distance := kael.distance_left
	var base_atk := kael.stats.get_value(Stats.Type.ATK)
	_use(controller, kiri, SkillData.Kind.SKILL, kael)
	_check(is_equal_approx(kael.distance_left, maxf(distance - 5000.0, 0.0)) and kael.has_status(&"kiri_kindle")
			and is_equal_approx(kael.stats.get_value(Stats.Type.ATK), base_atk * 1.2), "Kiri Chiến kỹ: kéo lượt 50% + Tấn Công +20%")
	kiri.set_energy(kiri.max_energy)
	var ult := _use(controller, kiri, SkillData.Kind.ULTIMATE, null)
	_check(_of(ult, "damage").size() == 3 and controller.allies.all(func(u: BattleUnit) -> bool: return u.has_status(&"kiri_festival")),
			"Kiri Tuyệt kỹ: sát thương toàn bộ quái + cả đội Lễ Hội")
	# Đặc tính: đồng minh có Thổi Bùng dùng Chiến kỹ 3 lần → +1 Điểm Chiến Kỹ.
	controller.skill_points = 5
	for i in 3:
		_use(controller, kael, SkillData.Kind.SKILL, _dummy(controller))
	_check(controller.skill_points == 3, "Đặc tính Kiri: 3 lần Chiến kỹ dưới Thổi Bùng hoàn 1 Điểm Chiến Kỹ (5 − 3 + 1 = %d)" % controller.skill_points)
	controller.queue_free()
	await _frames(1)


func _test_garren() -> void:
	var controller := _battle(_default_ids(), MIXED)
	var garren := _ally(controller, &"garren")
	_check(_of(_use(controller, garren, SkillData.Kind.BASIC, controller.enemies[0]), "damage").size() == 1, "Garren Đánh thường")
	_use(controller, garren, SkillData.Kind.SKILL, garren)
	_check(garren.is_taunting() and controller.allies.all(func(u: BattleUnit) -> bool: return u.shield_hp > 0.0),
			"Garren Chiến kỹ: khiên cả đội + Khiêu Khích")
	garren.set_energy(garren.max_energy)
	var enemy := controller.enemies[0]
	var distance := enemy.distance_left
	var ult := _use(controller, garren, SkillData.Kind.ULTIMATE, null)
	_check(_of(ult, "damage").size() == controller.enemies.size() and enemy.distance_left > distance,
			"Garren Tuyệt kỹ: sát thương toàn bộ quái + trì hoãn")
	# Đặc tính: bị đánh → phản công kẻ tấn công.
	var hp_before := enemy.hp
	garren.shield_hp = 0.0
	SkillExecutor.execute(controller, enemy, SkillData.simple_damage(0.5), garren)
	var turn_before := controller.turn_count
	await controller._process_interrupts()
	_check(enemy.hp < hp_before and controller.turn_count == turn_before, "Đặc tính Garren: phản công kẻ vừa đánh (không tốn lượt)")
	controller.queue_free()
	await _frames(1)


func _test_nyx() -> void:
	var ids: Array[StringName] = [&"traveler", &"mira", &"kiri", &"nyx"]
	var controller := _battle(ids)
	var nyx := _ally(controller, &"nyx")
	var dummy := _dummy(controller)
	var skill := _use(controller, nyx, SkillData.Kind.SKILL, dummy)
	_check(dummy.has_status(&"nyx_leak") and dummy.has_status(&"nyx_short_circuit") and not _of(skill, "damage").is_empty(),
			"Nyx Chiến kỹ: sát thương + Rò Điện + Đoản Mạch")
	var basic := _use(controller, nyx, SkillData.Kind.BASIC, dummy)
	_check(not _of(basic, "dot").is_empty(), "Đặc tính Nyx: Đánh thường kích nổ sát thương theo lượt")
	var clean := _dummy(controller, 2)
	_check(_of(_use(controller, nyx, SkillData.Kind.BASIC, clean), "dot").is_empty(), "Không có sát thương theo lượt thì không kích nổ")
	nyx.set_energy(nyx.max_energy)
	_use(controller, nyx, SkillData.Kind.ULTIMATE, null)
	_check(controller.enemies.all(func(u: BattleUnit) -> bool: return u.has_status(&"nyx_static")), "Nyx Tuyệt kỹ: Tĩnh Điện lên toàn bộ quái")
	controller.queue_free()
	await _frames(1)


func _test_eidolon_data() -> void:
	var levels := {&"traveler": 6, &"mira": 6, &"kiri": 6, &"garren": 6}
	var controller := _battle(_default_ids(), DUMMIES, levels)
	var kael := _ally(controller, &"traveler")
	_check(is_equal_approx(kael.get_skill_multiplier_bonus(SkillData.Kind.BASIC), 0.15)
			and is_equal_approx(kael.get_skill_multiplier_bonus(SkillData.Kind.ULTIMATE), 0.15), "Tinh Mệnh 3/5: +15% hệ số")
	for i in 4:
		for enemy in controller.enemies:
			enemy.recover_toughness()
			BreakSystem.trigger_break(controller, kael, enemy, Element.Type.SOUL)
	_check(kael.get_status(&"soul_resonance_e1").stacks == 3, "Kael E1: Cộng Hưởng tối đa 3 tầng")
	var garren := _ally(controller, &"garren")
	_use(controller, garren, SkillData.Kind.SKILL, garren)
	_check(garren.get_status(&"garren_taunt").turns_left == 2, "Garren E4: Khiêu Khích thêm 1 lượt")
	var mira_level_0 := _battle(_default_ids())
	var plain_mira := _ally(mira_level_0, &"mira")
	_check(is_zero_approx(plain_mira.get_skill_multiplier_bonus(SkillData.Kind.SKILL)), "Tinh Mệnh 0 thì không có thưởng")
	var mira := _ally(controller, &"mira")
	_check(is_equal_approx(mira.get_skill_multiplier_bonus(SkillData.Kind.SKILL), 0.25), "Mira E1 + E3: Chiến kỹ +25% hệ số")
	# Mira E6: đồng minh ngã đầu tiên được hồi sinh.
	var kiri := _ally(controller, &"kiri")
	var events := SkillExecutor.execute(controller, _dummy(controller), SkillData.simple_damage(0.0001), kiri)
	kiri.take_damage(kiri.hp)
	controller._handle_deaths([{"type": "damage", "target": kiri, "amount": 0.0, "crit": false}])
	_check(kiri.is_alive() and controller.queue.has(kiri), "Mira E6: đồng minh ngã được hồi sinh và quay lại hàng lượt")
	controller.queue_free()
	mira_level_0.queue_free()
	var nyx_ids: Array[StringName] = [&"traveler", &"mira", &"kiri", &"nyx"]
	var nyx_battle := _battle(nyx_ids, DUMMIES, {&"nyx": 6})
	var nyx := _ally(nyx_battle, &"nyx")
	_check(is_equal_approx(nyx.stats.get_value(Stats.Type.EFFECT_HIT), 0.3), "Nyx E6: Chính Xác Hiệu Ứng 10% + 20% = 30%")
	nyx_battle.queue_free()


func _test_team_of_four() -> void:
	var ids: Array[StringName] = [&"traveler", &"kiri", &"garren", &"nyx"]
	_check(GameState.set_team(ids), "Chọn đội 4 người trong 5 (có Nyx, không có Mira)")
	var controller := _battle(GameState.team)
	_check(controller.allies.size() == 4 and _ally(controller, &"mira") == null and _ally(controller, &"nyx") != null,
			"Vào trận đúng 4 người đã chọn")
	controller.queue_free()
	GameState.set_team(_default_ids())


# --- Ngoài map ---

func _test_overworld() -> void:
	OverworldEnemy.debug_frozen = true
	SceneRouter.go_to(DataPaths.TEST_MAP_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
	var map := get_tree().current_scene as OverworldMap
	var player := map.player
	await _frames(3)
	# Đổi người dẫn đầu 1–4.
	var leaders_ok := true
	for i in 4:
		_send_action("switch_character_%d" % (i + 1))
		await _frames(1)
		leaders_ok = leaders_ok and GameState.leader_index == i and player.opener.element == GameState.get_team_data()[i].element
	_check(leaders_ok, "Phím 1–4 đổi người dẫn đầu, Đòn Mở Màn đổi theo nguyên tố")
	_send_action("switch_character_1")
	await _frames(1)

	# 7 vật cản: Đòn Mở Màn đúng nguyên tố mở được, sai thì không.
	var puzzle := map.room_manager.get_room(&"puzzle_01")
	var elements := {0: Element.Type.FIRE, 1: Element.Type.WATER, 2: Element.Type.LIGHTNING, 3: Element.Type.WIND,
			4: Element.Type.POISON, 5: Element.Type.WOOD, 6: Element.Type.SOUL}
	var opened := 0
	var wrong_blocked := true
	for i in 7:
		var obstacle := puzzle.find_child("Obstacle%d" % (i + 1), true, false) as ElementalObstacle
		player.global_position = obstacle.global_position + Vector2(0, -110)
		player.facing = Vector2.DOWN
		var wrong := OpenerAttackData.new()
		wrong.element = (int(elements[i]) + 1) % 7
		player.opener = wrong
		await _seconds(0.7)
		player.try_opener()
		wrong_blocked = wrong_blocked and not obstacle.is_resolved
		var right := OpenerAttackData.new()
		right.element = elements[i]
		player.opener = right
		await _seconds(0.7)
		player.try_opener()
		if obstacle.is_resolved and GameState.map_state_has(DataPaths.TEST_MAP_SCENE, "resolved_obstacles",
				puzzle.get_persistent_id(obstacle)):
			opened += 1
	_check(wrong_blocked, "Đòn Mở Màn sai nguyên tố không mở vật cản")
	_check(opened == 7, "Mở được cả 7 loại vật cản bằng Đòn Mở Màn đúng nguyên tố (%d/7)" % opened)
	player.set_leader(0)

	# Điểm Bí Kỹ: trừ khi dùng, thiếu thì từ chối, Hộp Bí Kỹ +1, phòng nghỉ hồi đầy.
	GameState.technique_points = 1
	var barrier := puzzle.find_child("Obstacle8", true, false) as ElementalObstacle
	player.global_position = barrier.global_position + Vector2(0, -90)
	player.facing = Vector2.DOWN
	player.try_opener()
	_check(not barrier.is_resolved, "Rào Ma Biến không mở bằng Đòn Mở Màn")
	await _frames(2)
	_check(map.use_technique() and GameState.technique_points == 0, "Bí Kỹ Bước Hư Ảnh trừ 1 Điểm Bí Kỹ")
	await _seconds(0.6)
	_check(player.global_position.y > barrier.global_position.y + 20.0, "Bước Hư Ảnh lướt xuyên rào Ma Biến vào hốc")
	_check(GameState.pending_techniques.has(&"traveler"), "Bước Hư Ảnh ghi hiệu ứng cho trận kế tiếp")
	_check(not map.use_technique() and GameState.technique_points == 0, "Hết Điểm Bí Kỹ thì không dùng được")
	var box := puzzle.find_child("NicheTechniqueBox", true, false) as TechniqueBox
	box.break_open()
	_check(GameState.technique_points == 1, "Phá Hộp Bí Kỹ +1 Điểm Bí Kỹ")
	var rest_point := map.find_child("RestPoint", true, false) as RestPoint
	rest_point.interact(player)
	_check(GameState.technique_points == GameState.MAX_TECHNIQUE_POINTS, "Phòng nghỉ hồi đầy Điểm Bí Kỹ (5)")

	# Kiri: pháo hoa làm choáng và đánh dấu quái trên map.
	var combat := map.room_manager.get_room(&"combat_01")
	var enemy := combat.find_child("EnemyGroup1", true, false) as OverworldEnemy
	player.set_leader(2)
	player.global_position = enemy.global_position + Vector2(-3 * Room.TILE_SIZE, 0)
	player.facing = Vector2.RIGHT
	OverworldEnemy.debug_frozen = false
	enemy.config.start_grace_sec = 0.0
	player.grant_invincibility(5.0)
	_check(map.use_technique() and enemy.state == OverworldEnemy.State.DAZED and enemy.marks.has(&"kiri"),
			"Pháo Hoa Mồi: quái trong vùng bị choáng và đánh dấu")
	_check(not enemy.can_see(player), "Quái đang choáng không nhìn thấy người chơi")
	OverworldEnemy.debug_frozen = true

	# Nyx: tàng hình.
	player.set_leader(3)
	var team_has_nyx := GameState.team[3] == &"nyx"
	if not team_has_nyx:
		var ids: Array[StringName] = [&"traveler", &"mira", &"kiri", &"nyx"]
		GameState.set_team(ids)
		player.set_leader(3)
	map.use_technique()
	var other := combat.find_child("EnemyGroup2", true, false) as OverworldEnemy
	player.global_position = other.global_position + Vector2(0, 60)
	_check(player.is_invisible() and not other.can_see(player), "Màn Tĩnh Điện: tàng hình, quái không thấy")
	GameState.set_team(_default_ids())
	player.set_leader(0)

	# Mira, Garren: ghi hiệu ứng trận kế tiếp.
	GameState.pending_techniques.clear()
	player.set_leader(1)
	map.use_technique()
	player.set_leader(3)
	map.use_technique()
	_check(GameState.pending_techniques.has(&"mira") and GameState.pending_techniques.has(&"garren"),
			"Mưa Sương Lành và Tường Rễ chờ trận kế tiếp")
	GameState.pending_techniques.clear()
	OverworldEnemy.debug_frozen = false


func _test_technique_battles() -> void:
	var ids: Array[StringName] = [&"traveler", &"mira", &"kiri", &"garren"]
	var techniques: Array[StringName] = [&"traveler", &"mira", &"kiri", &"garren"]
	var controller := _battle(ids, MIXED, {}, techniques)
	var kael := _ally(controller, &"traveler")
	controller.start()
	await _frames(4)
	_check(controller.allies.all(func(u: BattleUnit) -> bool: return u.has_status(&"mira_mist") and u.shield_hp > 0.0),
			"Đầu trận: Mưa Sương Lành (hồi theo lượt) + Tường Rễ (khiên) cho cả đội")
	_check(controller.enemies.all(func(u: BattleUnit) -> bool: return u.has_status(&"kiri_firework_burn")),
			"Đầu trận: quái bị đánh dấu dính Thiêu Đốt của Pháo Hoa Mồi")
	controller.force_end(true)
	controller.queue_free()
	# Bước Hư Ảnh: lượt đầu của nhân vật chính kéo lên 25% (so với trận không có Bí Kỹ).
	var with_tech := _battle(ids, MIXED, {}, [&"traveler"] as Array[StringName])
	var without := _battle(ids, MIXED)
	with_tech.battle_began.emit()
	var events := with_tech._apply_technique_effects()
	_check(not _of(events, "advance").is_empty() and _ally(with_tech, &"traveler").distance_left
			< _ally(without, &"traveler").distance_left, "Bước Hư Ảnh: lượt đầu của nhân vật chính kéo lên 25%")
	with_tech.queue_free()
	without.queue_free()


func _send_action(action: StringName) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
	Input.flush_buffered_events()
