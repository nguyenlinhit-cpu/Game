extends "res://tests/test_base.gd"
## Kiểm thử Phase 8: dữ liệu quái/tinh anh/boss/trận theo khu, AI theo trọng số và tình huống, đòn báo trước,
## các cơ chế đặc biệt (nổ khi chết, triệu hồi + giới hạn 5, trộm Điểm Chiến Kỹ, sao chép/hút buff, Phong Ấn,
## đếm ngược ngắt bằng phá khiên / đủ sát thương, tích Nhiệt, phân thân), giai đoạn boss, mức Khó,
## giao diện (cảnh báo, chuyển giai đoạn, nhạc), phòng thử, và mỗi boss đánh Tự Động qua đủ giai đoạn.
## Chạy: godot --headless --path . res://tests/phase08_test.tscn

const FREE_ELEMENTS: Array[int] = [Element.Type.SOUL, Element.Type.WATER, Element.Type.FIRE, Element.Type.WOOD,
		Element.Type.LIGHTNING]
const NORMAL_FAMILIES: Array[StringName] = [&"warp_sprout", &"wandering_shade", &"rusted_knight", &"void_archer",
		&"warped_mage", &"ink_rat", &"venom_bee", &"mirror_shade"]
const ELITES: Array[StringName] = [&"shattered_knight", &"warp_matrix", &"mute_librarian"]
const BOSSES: Dictionary = {
	&"library_warden": "res://data/encounters/library_boss_warden.tres",
	&"vault_behemoth": "res://data/encounters/vault_boss_behemoth.tres",
	&"warped_core": "res://data/encounters/furnace_boss_core.tres",
	&"soul_devourer": "res://data/encounters/tower_boss_devourer.tres",
}
const ZONE_LEVELS: Dictionary = {&"library": [1, 8], &"vault": [8, 16], &"furnace": [16, 24], &"tower": [24, 30]}
const TEAM: Array[StringName] = [&"traveler", &"mira", &"kiri", &"garren"]
const BOSS_TEAMS: Dictionary = {
	&"library_warden": [&"traveler", &"kiri", &"garren", &"nyx"],
	&"vault_behemoth": [&"traveler", &"kiri", &"garren", &"nyx"],
	&"warped_core": [&"traveler", &"mira", &"kiri", &"garren"],
	&"soul_devourer": [&"traveler", &"mira", &"kiri", &"garren"],
}


func _run() -> void:
	phase_name = "Phase 8"
	timeout_sec = 900.0
	GameState.reset_new_game()
	_test_data()
	await _test_ai()
	await _test_normal_mechanics()
	await _test_elites()
	await _test_warden()
	await _test_behemoth()
	await _test_core()
	await _test_devourer()
	await _test_hard_mode()
	await _test_scene()
	await _test_sandbox()
	await _test_auto_bosses()
	_finish()


# --- Tiện ích ---

func _enemy(id: StringName) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id) as EnemyData


func _skill(id: StringName) -> SkillData:
	return load("res://data/skills/%s.tres" % id) as SkillData


## entries: [[enemy_id, level, count], ...] (một đợt).
func _encounter(entries: Array) -> EncounterData:
	var encounter := EncounterData.new()
	encounter.id = &"test_phase08"
	var wave := EncounterWave.new()
	for row: Array in entries:
		var entry := EncounterEnemyEntry.new()
		entry.enemy = _enemy(row[0])
		entry.level = row[1]
		entry.count = row[2] if row.size() > 2 else 1
		wave.entries.append(entry)
	encounter.waves.append(wave)
	return encounter


func _battle(encounter: EncounterData, level: int = 20, ids: Array = TEAM,
		difficulty: DifficultyConfig = null) -> BattleController:
	var controller := BattleController.new()
	controller.instant = true
	controller.crit_mode = DamageCalc.CritMode.NEVER
	controller.rng.seed = 8
	controller.difficulty = difficulty
	add_child(controller)
	var team: Array[CharacterData] = []
	for id: StringName in ids:
		team.append(DataPaths.load_character(id))
	var err := controller.setup(team, level, encounter, BattleTypes.Opening.NORMAL)
	if err != OK:
		_fail("setup lỗi %d" % err)
	controller.phase = BattleController.Phase.RUNNING
	controller.battle_began.emit()
	return controller


func _free(controller: BattleController) -> void:
	controller.force_end(true)
	controller.queue_free()
	await _frames(1)


func _find(controller: BattleController, id: StringName) -> BattleUnit:
	for unit in controller.enemies:
		if unit.enemy and unit.enemy.id == id and unit.is_alive():
			return unit
	return null


func _ally(controller: BattleController, id: StringName) -> BattleUnit:
	for unit in controller.allies:
		if unit.character.id == id:
			return unit
	return null


func _action(unit: BattleUnit, skill_id: StringName) -> EnemyAction:
	for action in unit.actions:
		if action.skill.id == skill_id:
			return action
	return null


## Chỉ để lại một hành động cho quái (ép AI chọn).
func _force(unit: BattleUnit, skill_id: StringName) -> EnemyAction:
	var action := _action(unit, skill_id)
	unit.actions.assign([action] if action else [])
	return action


## Quái dùng kỹ năng ngay (không qua AI), trả về sự kiện.
func _exec(controller: BattleController, unit: BattleUnit, skill_id: StringName, target: BattleUnit) -> Array[Dictionary]:
	var events := SkillExecutor.execute(controller, unit, _skill(skill_id), target)
	controller._handle_deaths(events)
	return events


func _kill(controller: BattleController, unit: BattleUnit) -> void:
	unit.hp_floor = 0.0
	var events: Array[Dictionary] = [{"type": "damage", "target": unit, "amount": unit.take_damage(unit.hp), "crit": false}]
	controller._handle_deaths(events)


## Phá khiên quái bằng nguyên tố điểm yếu đầu tiên của nó.
func _break(controller: BattleController, attacker: BattleUnit, target: BattleUnit) -> void:
	var element := int(target.weaknesses[0])
	var events := BreakSystem.apply_toughness_damage(controller, attacker, target, element, target.toughness + 1.0)
	controller._handle_deaths(events)


func _of(events: Array[Dictionary], type: String) -> Array[Dictionary]:
	return events.filter(func(e: Dictionary) -> bool: return e["type"] == type)


func _total_hp(units: Array[BattleUnit]) -> float:
	var total := 0.0
	for unit in units:
		total += unit.hp
	return total


func _enemy_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for file in DirAccess.get_files_at("res://data/enemies"):
		var clean := file.trim_suffix(".remap")
		if clean.ends_with(".tres"):
			ids.append(StringName(clean.get_basename()))
	return ids


# --- Dữ liệu ---

func _test_data() -> void:
	print("--- Dữ liệu ---")
	var families: Dictionary = {}
	var all_ok := true
	for id in _enemy_ids():
		var data := _enemy(id)
		if data.actions.is_empty() and data.skills.is_empty():
			all_ok = false
			_fail("%s: không có hành động" % id)
		for action in data.get_actions():
			if action.skill == null:
				all_ok = false
				_fail("%s: hành động thiếu kỹ năng" % id)
			# Đòn mạnh (Tuyệt kỹ của quái) phải báo trước: tích tụ, hoặc nhắm người đã bị đánh dấu.
			elif action.skill.kind == SkillData.Kind.ULTIMATE and not action.is_charged() and action.requires_foe_status == &"":
				all_ok = false
				_fail("%s: đòn mạnh %s không báo trước" % [id, action.skill.id])
		if tr(data.name_key) == data.name_key:
			all_ok = false
			_fail("%s: thiếu tên trong file dịch" % id)
		if data.kind == EnemyData.Kind.NORMAL and data.family in NORMAL_FAMILIES:
			var elements: Dictionary = families.get(data.family, {})
			elements[data.element] = true
			families[data.family] = elements
	_check(all_ok, "Mọi quái có hành động, đòn mạnh có báo trước, có tên dịch")
	var variants_ok := true
	for family in NORMAL_FAMILIES:
		if (families.get(family, {}) as Dictionary).size() < 2:
			variants_ok = false
			_fail("%s: chưa đủ 2 biến thể nguyên tố" % family)
	_check(variants_ok, "8 quái thường, mỗi loại ≥ 2 biến thể nguyên tố")
	_check(ELITES.all(func(id: StringName) -> bool: return _enemy(id).kind == EnemyData.Kind.ELITE), "3 quái tinh anh")
	for boss_id: StringName in BOSSES:
		var boss := _enemy(boss_id)
		var phase_count := boss.phases.size() + 1
		var weakness_sets: Array[Array] = [boss.weaknesses]
		for phase in boss.phases:
			if not phase.weaknesses.is_empty():
				weakness_sets.append(phase.weaknesses)
		var free_ok := weakness_sets.all(func(w: Array) -> bool:
			return w.any(func(e: int) -> bool: return FREE_ELEMENTS.has(e)))
		var changes := weakness_sets.size() > 1 and weakness_sets.any(func(w: Array) -> bool: return w != weakness_sets[0])
		var music_ok := PlaceholderMusic.has_track(boss.music_id) and boss.phases.all(func(p: BossPhaseData) -> bool:
			return PlaceholderMusic.has_track(p.music_id))
		_check(boss.is_boss() and phase_count >= 2 and phase_count <= 3 and free_ok and changes and music_ok,
				"%s: %d giai đoạn, đổi điểm yếu, luôn có điểm yếu thuộc đội miễn phí, có nhạc riêng" % [boss_id, phase_count])
	# Trận theo khu: cấp đúng chương, đủ thường/tinh anh/boss.
	var zones: Dictionary = {}
	var levels_ok := true
	for path in DataPaths.list_encounter_paths():
		var encounter := load(path) as EncounterData
		if not ZONE_LEVELS.has(encounter.zone):
			continue
		if not encounter.validate().is_empty():
			levels_ok = false
			_fail("%s: %s" % [encounter.id, encounter.validate()])
		var range_: Array = ZONE_LEVELS[encounter.zone]
		for wave in encounter.waves:
			for entry in wave.entries:
				if entry.level < range_[0] or entry.level > range_[1]:
					levels_ok = false
					_fail("%s: %s cấp %d ngoài khoảng %s" % [encounter.id, entry.enemy.id, entry.level, range_])
		var counts: Dictionary = zones.get(encounter.zone, {})
		counts[encounter.kind] = int(counts.get(encounter.kind, 0)) + 1
		zones[encounter.zone] = counts
	_check(levels_ok, "Cấp quái theo chương: 1–8, 8–16, 16–24, 24–30")
	var zones_ok := ZONE_LEVELS.keys().all(func(zone: StringName) -> bool:
		var c: Dictionary = zones.get(zone, {})
		return int(c.get(EncounterData.Kind.NORMAL, 0)) >= 6 and int(c.get(EncounterData.Kind.ELITE, 0)) >= 1 \
				and int(c.get(EncounterData.Kind.BOSS, 0)) == 1)
	_check(zones_ok, "Mỗi khu có ≥ 6 trận thường, ≥ 1 tinh anh, 1 boss (%s)" % zones)
	var final_boss := load(BOSSES[&"soul_devourer"]) as EncounterData
	_check(final_boss.get_max_level() == 30, "Trùm cuối cấp 30")


# --- AI ---

func _test_ai() -> void:
	print("--- AI ---")
	var controller := _battle(_encounter([[&"rusted_knight_water", 20], [&"void_archer_wind", 20],
			[&"venom_bee_poison", 20, 3]]))
	var knight := _find(controller, &"rusted_knight_water")
	var guard := _action(knight, &"en_knight_guard")
	var normal_weight := EnemyAI.situational_weight(guard, knight, controller)
	knight.broken_since_turn = true
	var broken_weight := EnemyAI.situational_weight(guard, knight, controller)
	_check(is_equal_approx(broken_weight, normal_weight * guard.after_break_weight_mult) and broken_weight > normal_weight,
			"Trọng số theo tình huống: vừa bị Phá Vỡ thì Thủ Thế ×%.0f" % guard.after_break_weight_mult)
	knight.broken_since_turn = false
	knight.hp = knight.get_max_hp() * 0.3
	_check(EnemyAI.situational_weight(guard, knight, controller) > normal_weight, "Máu thấp: tăng trọng số Thủ Thế")
	# Hồi chiêu.
	knight.turns_taken = 1
	knight.note_action_used(guard)
	knight.turns_taken = 2
	var blocked := not knight.is_action_ready(guard)
	knight.turns_taken = 4
	_check(blocked and knight.is_action_ready(guard), "Hồi chiêu %d lượt" % guard.cooldown_turns)
	# Xạ Thủ: có người bị ngắm thì bắn xuyên người đó (ưu tiên).
	var archer := _find(controller, &"void_archer_wind")
	var nyx_target := controller.allies[2]
	_exec(controller, archer, &"en_archer_mark", nyx_target)
	var choice := EnemyAI.choose_action(archer, controller)
	_check(choice.get("skill") == _skill(&"en_archer_snipe") and choice.get("target") == nyx_target,
			"Xạ Thủ: lượt sau bắn gấp đôi vào người Bị Ngắm")
	# Bầy Ong: còn 3 con thì không gọi; còn 1 thì gọi thêm (ưu tiên).
	var bees := controller.enemies.filter(func(u: BattleUnit) -> bool: return u.enemy.family == &"venom_bee")
	var call := _action(bees[0], &"en_bee_call_poison")
	var early := EnemyAI.is_available(call, bees[0], controller)
	_kill(controller, bees[1])
	_kill(controller, bees[2])
	choice = EnemyAI.choose_action(bees[0], controller)
	_check(not early and choice.get("action") == call, "Bầy Ong: chỉ gọi thêm khi còn 1 con")
	# Mục tiêu theo trọng số bị nhắm có Khiêu Khích.
	var garren := _ally(controller, &"garren")
	var taunt := load("res://data/status_effects/garren_taunt.tres") as StatusEffectData
	StatusEffects.apply(taunt, garren, garren)
	var slash := _action(knight, &"en_knight_slash")
	var all_taunt := true
	for i in 10:
		if EnemyAI.choose_target_for(slash, knight, controller) != garren:
			all_taunt = false
	_check(all_taunt, "Khiêu Khích: đòn đơn phải nhắm người khiêu khích")
	await _free(controller)


# --- Cơ chế quái thường ---

func _test_normal_mechanics() -> void:
	print("--- Quái thường ---")
	# Mầm nổ khi chết.
	var controller := _battle(_encounter([[&"warp_sprout_poison", 20, 2]]))
	var sprout := controller.enemies[0]
	var before := _total_hp(controller.allies)
	var resolved: Array[SkillData] = []
	controller.action_resolved.connect(func(_u: BattleUnit, skill: SkillData, _e: Array[Dictionary]) -> void:
		resolved.append(skill))
	_kill(controller, sprout)
	await controller._process_interrupts()
	_check(resolved.has(_skill(&"en_sprout_burst")) and _total_hp(controller.allies) < before,
			"Mầm Ma Biến: nổ khi chết, gây sát thương cả đội")
	await _free(controller)
	# Hồn Ảnh: khiên cho quái đồng minh.
	controller = _battle(_encounter([[&"wandering_shade_wind", 20], [&"warp_sprout_poison", 20]]))
	var shade := controller.enemies[0]
	_exec(controller, shade, &"en_shade_veil", shade)
	_check(controller.enemies.all(func(u: BattleUnit) -> bool: return u.shield_hp > 0.0), "Hồn Ảnh: tạo khiên cho quái đồng minh")
	await _free(controller)
	# Giáp Sĩ: Thủ Thế giảm sát thương, kéo dài tới hết lượt sau.
	controller = _battle(_encounter([[&"rusted_knight_water", 20]]))
	var knight := controller.enemies[0]
	var traveler := _ally(controller, &"traveler")
	var params := SkillExecutor.build_damage_params(traveler, knight, Stats.Type.ATK, 1.0, Element.Type.SOUL)
	var plain := DamageCalc.compute(params, false)
	_exec(controller, knight, &"en_knight_guard", knight)
	params = SkillExecutor.build_damage_params(traveler, knight, Stats.Type.ATK, 1.0, Element.Type.SOUL)
	var guarded := DamageCalc.compute(params, false)
	var instance := knight.get_status(&"en_guard")
	_check(instance != null and instance.turns_left == 2 and guarded < plain * 0.7,
			"Giáp Sĩ: Thủ Thế giảm sát thương (%d → %d), giữ tới hết lượt sau" % [plain, guarded])
	await _free(controller)
	# Xạ Thủ: đòn bắn xuyên gấp đôi và gỡ dấu.
	controller = _battle(_encounter([[&"void_archer_wind", 20]]))
	var archer := controller.enemies[0]
	var mira := _ally(controller, &"mira")
	var hp0 := mira.hp
	_exec(controller, archer, &"en_archer_shot", mira)
	var shot := hp0 - mira.hp
	mira.hp = mira.get_max_hp()
	_exec(controller, archer, &"en_archer_mark", mira)
	mira.hp = mira.get_max_hp()
	_exec(controller, archer, &"en_archer_snipe", mira)
	var snipe := mira.get_max_hp() - mira.hp
	_check(absf(snipe - shot * 2.0) <= 2.0 and not mira.has_status(&"en_void_mark"),
			"Xạ Thủ: bắn xuyên gấp đôi (%d → %d) và gỡ Bị Ngắm" % [shot, snipe])
	await _free(controller)
	# Pháp Sư Méo: gắn sát thương theo lượt theo nguyên tố.
	var hex_ok := true
	for element: String in ["fire", "poison", "wind"]:
		controller = _battle(_encounter([[StringName("warped_mage_" + element), 20]]))
		controller.rng.seed = 1
		var mage := controller.enemies[0]
		var kiri := _ally(controller, &"kiri")
		for i in 5:
			_exec(controller, mage, StringName("en_mage_hex_" + element), kiri)
		var hex := kiri.get_status(StringName("en_hex_" + element))
		kiri.hp = kiri.get_max_hp()
		var start := controller.process_turn_start(kiri)
		if hex == null or _of(start["events"], "dot").is_empty() or kiri.hp >= kiri.get_max_hp():
			hex_ok = false
			_fail("Pháp Sư Méo %s: không gây sát thương theo lượt" % element)
		await _free(controller)
	_check(hex_ok, "Pháp Sư Méo: 3 biến thể gắn Bỏng/Độc/Gió Cắt, mất máu đầu lượt")
	# Chuột Mực Sách: trộm Điểm Chiến Kỹ.
	controller = _battle(_encounter([[&"ink_rat_wind", 20]]))
	controller.skill_points = 3
	var steal := _exec(controller, controller.enemies[0], &"en_rat_steal", traveler if false else controller.allies[0])
	_check(controller.skill_points == 2 and not _of(steal, "sp_lost").is_empty(), "Chuột Mực Sách: trộm 1 Điểm Chiến Kỹ")
	controller.skill_points = 0
	_exec(controller, controller.enemies[0], &"en_rat_steal", controller.allies[0])
	_check(controller.skill_points == 0, "Chuột Mực Sách: hết điểm thì không trộm được thêm")
	await _free(controller)
	# Bầy Ong: gọi thêm, quái gọi ra tính vào giới hạn 5.
	controller = _battle(_encounter([[&"venom_bee_poison", 20, 3]]))
	var bee := controller.enemies[0]
	_kill(controller, controller.enemies[1])
	_kill(controller, controller.enemies[2])
	var call := _exec(controller, bee, &"en_bee_call_poison", bee)
	_check(_of(call, "summon").size() == 2 and controller.count_enemies_alive() == 3 and controller.count_family_alive(bee) == 3,
			"Bầy Ong: còn 1 con thì gọi thêm 2 Ong Thợ")
	_exec(controller, bee, &"en_bee_call_poison", bee)
	var extra := controller.spawn_enemy(_enemy(&"venom_bee_poison_drone"), 20)
	_check(controller.count_enemies_alive() == 5 and extra == null, "Giới hạn 5 quái: quái gọi ra vẫn tính, hết chỗ thì không gọi")
	await _free(controller)
	# Bóng Gương: sao chép buff.
	controller = _battle(_encounter([[&"mirror_shade_soul", 20]]))
	var mirror := controller.enemies[0]
	var kindle := load("res://data/status_effects/kiri_kindle.tres") as StatusEffectData
	var target := _ally(controller, &"traveler")
	var copy := _action(mirror, &"en_mirror_copy")
	var unavailable := not EnemyAI.is_available(copy, mirror, controller)
	StatusEffects.apply(kindle, _ally(controller, &"kiri"), target)
	var picked := EnemyAI.choose_target_for(copy, mirror, controller)
	var atk_before := mirror.stats.get_value(Stats.Type.ATK)
	_exec(controller, mirror, &"en_mirror_copy", picked)
	_check(unavailable and picked == target and mirror.has_status(kindle.id) and target.has_status(kindle.id)
			and mirror.stats.get_value(Stats.Type.ATK) > atk_before, "Bóng Gương: sao chép buff của người nhiều buff nhất")
	await _free(controller)


# --- Tinh anh ---

func _test_elites() -> void:
	print("--- Tinh anh ---")
	# Kỵ Sĩ Vỡ Vụn: tích tụ 1 lượt rồi lao; phá khiên lúc tích tụ thì hủy.
	var controller := _battle(_encounter([[&"shattered_knight", 20]]))
	var knight := controller.enemies[0]
	var charge := _force(knight, &"en_sk_charge")
	knight.turns_in_phase = 1
	var target_hp := _total_hp(controller.allies)
	await controller._run_enemy_turn(knight)
	_check(knight.charge != null and knight.charge.action == charge and is_equal_approx(_total_hp(controller.allies), target_hp)
			and controller.get_charge_targets(knight).size() == 1, "Kỵ Sĩ: lượt đầu chỉ tích tụ (báo trước, có mục tiêu)")
	var interrupted := []
	controller.charge_interrupted.connect(func(_u: BattleUnit, _a: EnemyAction) -> void: interrupted.append(true))
	_break(controller, controller.allies[0], knight)
	await controller._after_action()
	_check(knight.charge == null and interrupted.size() == 1, "Kỵ Sĩ: phá khiên lúc tích tụ thì hủy đòn")
	knight.recover_toughness()
	knight.action_ready_turn.clear()
	await controller._run_enemy_turn(knight)
	var victim := knight.charge.target
	var hp_before := victim.hp
	await controller._run_enemy_turn(knight)
	_check(knight.charge == null and victim.hp < hp_before - victim.get_max_hp() * 0.25,
			"Kỵ Sĩ: không ngắt thì lượt sau lao trúng (%d sát thương)" % (hp_before - victim.hp))
	await _free(controller)
	# Mẫu Thể Ma Biến: khiên theo số Mầm, gọi Mầm.
	controller = _battle(_encounter([[&"warp_sprout_poison", 20], [&"warp_matrix", 20], [&"warp_sprout_poison", 20]]))
	var matrix := _find(controller, &"warp_matrix")
	var full := matrix.max_toughness
	_kill(controller, controller.enemies[0])
	var fewer := matrix.max_toughness
	_check(is_equal_approx(full, 120.0) and is_equal_approx(fewer, 90.0) and matrix.toughness <= fewer,
			"Mẫu Thể: khiên %d với 2 Mầm, %d với 1 Mầm" % [full, fewer])
	var spawn := _exec(controller, matrix, &"en_matrix_spawn", matrix)
	_check(_of(spawn, "summon").size() == 2 and is_equal_approx(matrix.max_toughness, 150.0), "Mẫu Thể: gọi 2 Mầm, khiên dày lại")
	var spawn_action := _action(matrix, &"en_matrix_spawn")
	matrix.turns_in_phase = 1
	matrix.turns_taken = 0
	matrix.action_ready_turn.clear()
	_kill(controller, controller.enemies[2])
	var picks: Array[bool] = []
	for turn in 4:
		matrix.turns_taken = turn
		var choice := EnemyAI.choose_action(matrix, controller)
		picks.append(choice.get("action") == spawn_action)
		if choice.get("action") == spawn_action:
			matrix.note_action_used(spawn_action)
	_check(picks == [true, false, true, false], "Mẫu Thể: cứ 2 lượt triệu hồi một lần (%s)" % [picks])
	await _free(controller)
	# Thủ Thư Câm: Phong Ấn Chiến kỹ 2 lượt.
	controller = _battle(_encounter([[&"mute_librarian", 20]]))
	var librarian := controller.enemies[0]
	var seal := _action(librarian, &"en_ml_seal")
	var victim2 := EnemyAI.choose_target_for(seal, librarian, controller)
	_exec(controller, librarian, &"en_ml_seal", victim2)
	controller.skill_points = 5
	var auto_choice := AutoBattle.choose_action(victim2, controller)
	_check(victim2.is_skill_sealed() and not controller.can_use(victim2, victim2.get_skill(SkillData.Kind.SKILL))
			and auto_choice["skill"] == victim2.get_skill(SkillData.Kind.BASIC),
			"Thủ Thư Câm: Phong Ấn Chiến kỹ người Tấn Công cao nhất (%s)" % victim2.display_name)
	controller.process_turn_end(victim2)
	var still := victim2.is_skill_sealed()
	controller.process_turn_end(victim2)
	_check(still and not victim2.is_skill_sealed(), "Phong Ấn kéo dài 2 lượt của người bị ấn")
	await _free(controller)


# --- Boss ---

## Đẩy boss tới ngưỡng giai đoạn kế tiếp rồi chuyển giai đoạn.
func _to_next_phase(controller: BattleController, boss: BattleUnit) -> void:
	boss.take_damage(boss.get_max_hp())
	await controller._after_action()


func _test_warden() -> void:
	print("--- Người Gác Thư Viện ---")
	var controller := _battle(load(BOSSES[&"library_warden"]), 10)
	var boss := _find(controller, &"library_warden")
	_check(boss.weaknesses == [Element.Type.FIRE, Element.Type.SOUL], "GĐ1 yếu Lửa, Hồn")
	await controller._run_enemy_turn(boss)
	_check(controller.enemies.filter(func(u: BattleUnit) -> bool: return u.enemy.id == &"flying_book").size() == 2,
			"Lượt đầu triệu hồi 2 Sách Bay")
	# Máu không vượt qua ngưỡng 50% cho tới khi chuyển giai đoạn.
	var phases: Array[int] = []
	controller.boss_phase_started.connect(func(_u: BattleUnit, index: int, _d: BossPhaseData) -> void: phases.append(index))
	boss.take_damage(boss.get_max_hp())
	_check(is_equal_approx(boss.get_hp_ratio(), 0.5) and boss.has_pending_phase(), "Sát thương dừng ở ngưỡng 50%")
	await controller._after_action()
	_check(phases == [1] and boss.phase_index == 1 and boss.weaknesses == [Element.Type.WIND, Element.Type.SOUL]
			and boss.toughness == boss.max_toughness, "Sang GĐ2: đổi điểm yếu (Phong, Hồn), hồi khiên")
	# Lời nguyền đếm ngược 3 lượt, vẫn hành động; phá khiên thì ngắt.
	await controller._run_enemy_turn(boss)
	var curse := boss.charge
	_check(curse != null and curse.action.skill.id == &"en_warden_curse" and curse.turns_left == 3,
			"GĐ2: đọc Lời Nguyền Câm Lặng, đếm ngược 3 lượt")
	var acted: Array[SkillData] = []
	controller.action_resolved.connect(func(u: BattleUnit, skill: SkillData, _e: Array[Dictionary]) -> void:
		if u == boss:
			acted.append(skill))
	await controller._run_enemy_turn(boss)
	_check(boss.charge != null and boss.charge.turns_left == 2 and not acted.is_empty(),
			"Đang đếm ngược vẫn hành động (%s)" % [acted.map(func(s: SkillData) -> String: return s.id)])
	_break(controller, controller.allies[0], boss)
	await controller._after_action()
	_check(boss.charge == null, "Phá khiên ngắt lời nguyền")
	# Không ngắt: cả đội bị Phong Ấn.
	boss.recover_toughness()
	boss.turns_in_phase = 0
	boss.action_ready_turn.clear()
	_force(boss, &"en_warden_curse")
	for i in 4:
		await controller._run_enemy_turn(boss)
	_check(controller.allies.all(func(u: BattleUnit) -> bool: return u.is_skill_sealed()),
			"Không ngắt: hết đếm ngược thì cả đội bị Phong Ấn")
	await _free(controller)


func _test_behemoth() -> void:
	print("--- Cự Thú Kho Chứa ---")
	var controller := _battle(load(BOSSES[&"vault_behemoth"]), 18)
	controller.rng.seed = 3
	var boss := _find(controller, &"vault_behemoth")
	var nyx := controller.allies[0]
	var frozen := false
	for i in 6:
		_exec(controller, boss, &"en_beh_freeze", nyx)
		if nyx.has_status(&"en_frozen"):
			frozen = true
			break
	var start := controller.process_turn_start(nyx)
	_check(frozen and bool(start["skip"]), "Đóng băng 1 nhân vật: mất lượt kế tiếp")
	var speed := boss.get_speed()
	await _to_next_phase(controller, boss)
	_check(boss.phase_index == 1 and boss.weaknesses == [Element.Type.LIGHTNING, Element.Type.SOUL]
			and boss.get_speed() > speed * 1.15, "GĐ2 Băng Vỡ: tăng tốc, đổi điểm yếu (Sét, Hồn)")
	await controller._run_enemy_turn(boss)
	_check(boss.charge != null and boss.charge.action.skill.target == SkillData.Target.ALL_ENEMIES
			and controller.get_charge_targets(boss).size() == controller.allies.size(),
			"GĐ2: Lở Băng báo trước, cảnh báo cả đội")
	await controller._run_enemy_turn(boss)
	var rampage := _exec(controller, boss, &"en_beh_rampage", controller.allies[1])
	_check(_of(rampage, "damage").size() >= 2, "GĐ2: đánh lan")
	await _free(controller)


func _test_core() -> void:
	print("--- Lõi Lò Biến Dạng ---")
	var controller := _battle(load(BOSSES[&"warped_core"]), 26)
	var core := _find(controller, &"warped_core")
	var arms := controller.enemies.filter(func(u: BattleUnit) -> bool: return u.enemy.id == &"furnace_arm")
	_check(arms.size() == 2, "Có 2 tay máy là mục tiêu phụ")
	var heat := func() -> int:
		var instance := core.get_status(&"en_heat")
		return instance.stacks if instance else 0
	EventBus.turn_started.emit(core)
	var after_turn: int = heat.call()
	_exec(controller, arms[0], &"en_arm_stoke", arms[0])
	_check(after_turn == 1 and heat.call() == 2, "Mỗi lượt tích 1 tầng Nhiệt, tay máy Nạp Nhiệt thêm 1")
	EventBus.turn_started.emit(core)
	EventBus.turn_started.emit(core)
	var choice := EnemyAI.choose_action(core, controller)
	_check(heat.call() == 4 and choice.get("skill") == _skill(&"en_core_meltdown"), "Đủ 4 tầng: chọn Quá Nhiệt")
	core.turns_taken = 0
	core.action_ready_turn.clear()
	await controller._run_enemy_turn(core)
	_check(core.charge != null and core.charge.action.skill.id == &"en_core_meltdown", "Quá Nhiệt báo trước 1 lượt")
	_break(controller, controller.allies[0], core)
	await controller._after_action()
	_check(core.charge == null and heat.call() == 1, "Phá khiên: hủy Quá Nhiệt, giảm 3 tầng Nhiệt")
	core.recover_toughness()
	for i in 3:
		EventBus.turn_started.emit(core)
	core.action_ready_turn.clear()
	await controller._run_enemy_turn(core)
	var team_hp := _total_hp(controller.allies)
	EventBus.turn_started.emit(core)
	await controller._run_enemy_turn(core)
	_check(_total_hp(controller.allies) < team_hp and heat.call() == 0, "Không ngắt: nổ cả đội và xả hết Nhiệt")
	_kill(controller, arms[0])
	await _to_next_phase(controller, core)
	var arms_alive := controller.enemies.filter(func(u: BattleUnit) -> bool:
		return u.is_alive() and u.enemy.id == &"furnace_arm").size()
	_check(core.phase_index == 1 and arms_alive == 2 and core.weaknesses == [Element.Type.WOOD, Element.Type.SOUL],
			"GĐ2 Lò Quá Tải: dựng lại tay máy, đổi điểm yếu (Mộc, Hồn)")
	await _free(controller)


func _test_devourer() -> void:
	print("--- Kẻ Nuốt Mảnh Hồn ---")
	var controller := _battle(load(BOSSES[&"soul_devourer"]), 30)
	var boss := _find(controller, &"soul_devourer")
	var kindle := load("res://data/status_effects/kiri_kindle.tres") as StatusEffectData
	for ally in controller.allies:
		StatusEffects.apply(kindle, controller.allies[2], ally)
	var atk := boss.stats.get_value(Stats.Type.ATK)
	_exec(controller, boss, &"en_dev_devour", controller.allies[0])
	_check(controller.allies.all(func(u: BattleUnit) -> bool: return not u.has_status(kindle.id))
			and boss.has_status(kindle.id) and boss.stats.get_value(Stats.Type.ATK) > atk, "GĐ1: hút buff của cả đội")
	await _to_next_phase(controller, boss)
	var clones := controller.enemies.filter(func(u: BattleUnit) -> bool: return u.enemy.family == &"devourer_clone")
	var weakness_sets: Dictionary = {}
	for clone: BattleUnit in clones:
		weakness_sets[str(clone.weaknesses)] = true
	_check(boss.phase_index == 1 and clones.size() == 3 and weakness_sets.size() == 3 and boss.untargetable
			and not controller.get_foes(controller.allies[0]).has(boss),
			"GĐ2: tách 3 phân thân khác điểm yếu, bản thể không bị nhắm được")
	var hp_before := boss.hp
	for clone: BattleUnit in clones:
		_kill(controller, clone)
	await controller._after_action()
	_check(boss.phase_index == 2 and not boss.untargetable and boss.hp < hp_before - boss.get_max_hp() * 0.2
			and boss.weaknesses == [Element.Type.SOUL, Element.Type.FIRE, Element.Type.LIGHTNING],
			"Hạ hết phân thân: bản thể mất máu, sang GĐ3 (yếu Hồn, Lửa, Sét)")
	controller.skill_points = 3
	EventBus.turn_started.emit(boss)
	_check(controller.skill_points == 2, "GĐ3: mỗi lượt xóa 1 Điểm Chiến Kỹ")
	await controller._run_enemy_turn(boss)
	_check(boss.charge != null and boss.charge.action.skill.id == &"en_dev_swallow" and boss.charge.turns_left == 2,
			"GĐ3: Nuốt Hồn đếm ngược")
	var ctx := SkillContext.new(controller, controller.allies[0], null, null)
	boss.take_damage(boss.get_max_hp() * 0.05)
	await controller._after_action()
	var not_yet := boss.charge != null
	boss.take_damage(boss.get_max_hp() * 0.06)
	await controller._after_action()
	_check(not_yet and boss.charge == null and ctx != null, "Gây đủ 10% máu tối đa trong lúc đếm ngược thì ngắt Nuốt Hồn")
	await _free(controller)


func _test_hard_mode() -> void:
	print("--- Mức Khó ---")
	var hard := load("res://data/config/boss_hard_mode.tres") as DifficultyConfig
	var normal_battle := _battle(load(BOSSES[&"library_warden"]), 10)
	var hard_battle := _battle(load(BOSSES[&"library_warden"]), 10, TEAM, hard)
	var a := normal_battle.enemies[0]
	var b := hard_battle.enemies[0]
	_check(is_equal_approx(b.get_max_hp(), a.get_max_hp() * (1.0 + hard.hp_percent))
			and b.stats.get_value(Stats.Type.ATK) > a.stats.get_value(Stats.Type.ATK)
			and b.max_toughness > a.max_toughness and is_equal_approx(b.hp_floor, b.get_max_hp() * 0.5),
			"Boss khó: máu ×%.1f, Tấn Công, khiên cao hơn" % (1.0 + hard.hp_percent))
	await _free(normal_battle)
	await _free(hard_battle)


# --- Giao diện ---

func _test_scene() -> void:
	print("--- Màn trận ---")
	var team: Array[CharacterData] = []
	for id in TEAM:
		team.append(DataPaths.load_character(id))
	SceneRouter.go_to(DataPaths.BATTLE_SCENE, {"encounter": load(BOSSES[&"library_warden"]), "instant": true,
			"team_override": team}, 0.01)
	await SceneRouter.transition_finished
	await _frames(3)
	var scene := get_tree().current_scene
	var controller: BattleController = scene.controller
	controller.set_auto(false)
	var boss := _find(controller, &"library_warden")
	var view: UnitView = scene.get_view(boss)
	_check(view.get_radius() > UnitView.ENEMY_RADIUS * 1.4, "Boss vẽ to hơn quái thường")
	_check(AudioManager.get_music_stream() == PlaceholderMusic.get_stream(&"boss_library"), "Nhạc riêng của boss")
	var book := controller.spawn_enemy(_enemy(&"flying_book"), 8)
	await _frames(1)
	_check(scene.get_view(book) != null, "Quái gọi ra giữa trận có hình trên sân")
	var warn_action := _action(boss, &"en_warden_strike")
	boss.charge = BattleUnit.Charge.new(warn_action, controller.allies[0])
	controller.queue_changed.emit()
	await _frames(1)
	_check((scene.get_view(controller.allies[0]) as UnitView).threatened
			and not (scene.get_view(controller.allies[1]) as UnitView).threatened,
			"Cảnh báo: đánh dấu đúng người sắp trúng đòn tích tụ")
	boss.charge = null
	boss.take_damage(boss.get_max_hp())
	controller.enter_boss_phase(boss, 1)
	_check(scene.is_phase_overlay_visible(), "Chuyển giai đoạn: hiện đoạn chuyển cảnh")
	await _seconds(0.6)
	_check(AudioManager.get_music_stream() == PlaceholderMusic.get_stream(&"boss_library_2"), "Đổi nhạc theo giai đoạn")
	controller.force_end(true)
	await _frames(2)


func _test_sandbox() -> void:
	print("--- Phòng thử ---")
	GameState.set_team(TEAM)
	SceneRouter.go_to(DataPaths.BATTLE_SANDBOX_SCENE, {"instant": true}, 0.01)
	await SceneRouter.transition_finished
	await _frames(2)
	var sandbox := get_tree().current_scene
	var ids: Array[StringName] = [&"traveler", &"kiri", &"garren", &"nyx"]
	var ok: bool = sandbox.apply_setup(ids, BOSSES[&"vault_behemoth"], 18, 0, true)
	await SceneRouter.transition_finished
	await _frames(3)
	sandbox = get_tree().current_scene
	var controller: BattleController = sandbox.battle.controller
	_check(ok and controller.encounter.id == &"vault_boss_behemoth" and controller.difficulty != null
			and controller.allies[3].character.id == &"nyx" and controller.allies[0].level == 18,
			"Phòng thử: chọn đội 4 người + boss + cấp + mức Khó")
	controller.force_end(true)
	await _frames(2)
	SceneRouter.payload = {}


# --- Tự Động ---

func _test_auto_bosses() -> void:
	print("--- Đánh Tự Động từng boss ---")
	# Headless mặc định ngủ ~7 ms mỗi khung hình; tắt để trận Tự Động chạy nhanh.
	OS.low_processor_usage_mode_sleep_usec = 0
	for boss_id: StringName in BOSSES:
		var encounter := load(BOSSES[boss_id]) as EncounterData
		var controller := BattleController.new()
		controller.instant = true
		controller.auto_mode = true
		controller.rng.seed = 2024
		add_child(controller)
		var team: Array[CharacterData] = []
		for id: StringName in BOSS_TEAMS[boss_id]:
			team.append(DataPaths.load_character(id))
		controller.setup(team, encounter.recommended_level, encounter, BattleTypes.Opening.NORMAL)
		var reached: Array[int] = [0]
		controller.boss_phase_started.connect(func(u: BattleUnit, index: int, _d: BossPhaseData) -> void:
			if u.enemy.id == boss_id:
				reached.append(index))
		controller.start()
		var frames := 0
		while controller.phase != BattleController.Phase.ENDED and frames < 20000:
			await _frames(1)
			frames += 1
		var boss := encounter.get_boss()
		_check(controller.phase == BattleController.Phase.ENDED and controller.won and reached.size() == boss.phases.size() + 1,
				"%s: đội miễn phí cấp %d thắng Tự Động qua đủ %d giai đoạn (%d lượt)" % [boss_id,
				encounter.recommended_level, boss.phases.size() + 1, controller.turn_count])
		controller.queue_free()
		await _frames(1)
