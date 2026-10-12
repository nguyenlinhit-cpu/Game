extends "res://tests/test_base.gd"
## Kiểm thử Phase 7: 20 nhân vật mới (theo nhóm 5), dùng được trong trận và ngoài map, Đặc tính chạy đúng mô tả.
## Chạy: godot --headless --path . res://tests/phase07_test.tscn [-- --groups=1,2]
## Mặc định chạy mọi nhóm đã có dữ liệu.

const DUMMIES: String = "res://data/encounters/sandbox_dummies.tres"
const MIXED: String = "res://data/encounters/test_mixed_lv5.tres"
const GROUPS: Dictionary = {
	1: [&"ignar", &"marisol", &"raiko", &"zephyra", &"vesper"],
	2: [&"sylvaine", &"orrin", &"celestine", &"quill", &"aldric"],
	3: [&"rook", &"fenna", &"kestrel", &"vael", &"wisp"],
	4: [&"selka", &"ember", &"neris", &"pip", &"echo"],
}
const SUPPORTS: Array[StringName] = [&"traveler", &"mira", &"garren", &"kiri"]


func _run() -> void:
	phase_name = "Phase 7"
	timeout_sec = 600.0
	GameState.reset_new_game()
	for group: int in _groups_to_run():
		print("--- Nhóm %d ---" % group)
		for id: StringName in GROUPS[group]:
			await _test_common(id)
		await call("_test_group_%d" % group)
	_finish()


func _groups_to_run() -> Array[int]:
	var result: Array[int] = []
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--groups="):
			for part in arg.trim_prefix("--groups=").split(","):
				result.append(int(part))
	if result.is_empty():
		for group: int in GROUPS:
			if ResourceLoader.exists(DataPaths.character_path(GROUPS[group][0])):
				result.append(group)
	return result


# --- Tiện ích ---

func _team_with(id: StringName, others: Array[StringName] = []) -> Array[StringName]:
	var team: Array[StringName] = [id]
	for support in (others if not others.is_empty() else SUPPORTS):
		if team.size() < 4 and support != id:
			team.append(support)
	return team


func _battle(ids: Array[StringName], encounter_path: String = DUMMIES, eidolon: int = 0,
		techniques: Array[StringName] = [], crit := DamageCalc.CritMode.NEVER) -> BattleController:
	var controller := BattleController.new()
	controller.instant = true
	controller.crit_mode = crit
	controller.rng.seed = 11
	add_child(controller)
	var levels := {}
	for id in ids:
		levels[id] = eidolon
	var team: Array[CharacterData] = []
	for id in ids:
		team.append(DataPaths.load_character(id))
	var err := controller.setup(team, 20, load(encounter_path), BattleTypes.Opening.NORMAL, {}, {},
			Element.NONE, levels, techniques)
	if err != OK:
		_fail("setup lỗi %d" % err)
	return controller


func _ally(controller: BattleController, id: StringName) -> BattleUnit:
	for unit in controller.allies:
		if unit.character.id == id:
			return unit
	return null


func _use(controller: BattleController, unit: BattleUnit, kind: SkillData.Kind, target: BattleUnit = null) -> Array[Dictionary]:
	var skill := unit.get_skill(kind)
	if target == null:
		var pool := SkillExecutor.get_target_pool(skill, unit, controller.allies, controller.enemies)
		target = pool[0] if not pool.is_empty() else unit
	var events := SkillExecutor.execute(controller, unit, skill, target)
	controller._handle_deaths(events)
	return events


func _of(events: Array[Dictionary], type: String) -> Array[Dictionary]:
	return events.filter(func(e: Dictionary) -> bool: return e["type"] == type)


func _free(controller: BattleController) -> void:
	controller.force_end(true)
	controller.queue_free()
	await _frames(1)


# --- Kiểm tra chung cho mọi nhân vật ---

func _test_common(id: StringName) -> void:
	var data := DataPaths.load_character(id)
	var ok := data != null and data.opener != null and data.technique != null and data.basic_attack != null \
			and data.skill != null and data.ultimate != null and data.talent != null and data.eidolons.size() == 6
	_check(ok, "%s: đủ 2 kỹ năng map, 3 kỹ năng trận, Đặc tính, 6 Tinh Mệnh" % id)
	if not ok:
		return
	_check(data.opener.element == data.element, "%s: Đòn Mở Màn mang nguyên tố nhân vật" % id)
	_check(tr(data.name_key) != data.name_key and tr(data.talent.desc_key) != data.talent.desc_key,
			"%s: có chữ trong file dịch" % id)
	# 3 kỹ năng trận đều chạy và tạo hiệu ứng.
	var controller := _battle(_team_with(id))
	var unit := _ally(controller, id)
	unit.set_energy(unit.max_energy)
	var skills_ok := true
	for kind: SkillData.Kind in [SkillData.Kind.BASIC, SkillData.Kind.SKILL, SkillData.Kind.ULTIMATE]:
		controller.skill_points = 5
		unit.set_energy(unit.max_energy)
		var events := _use(controller, unit, kind)
		if events.is_empty():
			skills_ok = false
			_fail("%s: kỹ năng %s không tạo sự kiện nào" % [id, SkillData.Kind.keys()[kind]])
	_check(skills_ok, "%s: Đánh thường, Chiến kỹ, Tuyệt kỹ đều có tác dụng" % id)
	await _free(controller)
	# Trận Tự Động trọn vẹn (Tinh Mệnh 6 để chạy cả nhánh Tinh Mệnh) không lỗi.
	var auto := _battle(_team_with(id), MIXED, 6, [id], DamageCalc.CritMode.ROLL)
	auto.auto_mode = true
	auto.start()
	var frames := 0
	while auto.phase != BattleController.Phase.ENDED and frames < 6000:
		await _frames(1)
		frames += 1
	_check(auto.phase == BattleController.Phase.ENDED, "%s: trận Tự Động (Tinh Mệnh 6 + Bí Kỹ) kết thúc (%s)" % [
			id, "thắng" if auto.won else "thua"])
	auto.queue_free()
	await _frames(1)
	# Ngoài map: làm người dẫn đầu, dùng Bí Kỹ, Đòn Mở Màn.
	await _test_overworld(id)


func _test_overworld(id: StringName) -> void:
	GameState.set_team(_team_with(id))
	GameState.leader_index = 0
	GameState.technique_points = GameState.MAX_TECHNIQUE_POINTS
	GameState.pending_techniques.clear()
	OverworldEnemy.debug_frozen = true
	SceneRouter.go_to(DataPaths.TEST_MAP_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
	var map := get_tree().current_scene as OverworldMap
	var player := map.player
	await _frames(2)
	player.set_leader(0)
	var data := DataPaths.load_character(id)
	_check(player.get_leader() == data and player.opener == data.opener, "%s: làm người dẫn đầu ngoài map" % id)
	# Đứng trước nhóm quái đầu của phòng chiến đấu để Bí Kỹ có mục tiêu.
	var combat := map.room_manager.get_room(&"combat_01")
	var enemy := combat.find_child("EnemyGroup1", true, false) as OverworldEnemy
	player.global_position = enemy.global_position + Vector2(-2 * Room.TILE_SIZE, 0)
	player.facing = Vector2.RIGHT
	player.grant_invincibility(30.0)
	await _frames(2)
	var before := GameState.technique_points
	var used := map.use_technique()
	_check(used and GameState.technique_points == before - data.technique.cost, "%s: dùng Bí Kỹ, trừ %d Điểm Bí Kỹ" % [
			id, data.technique.cost])
	await _frames(3)
	_check(_technique_effect_visible(map, data, enemy), "%s: Bí Kỹ %s có tác dụng trên map" % [id, data.technique.id])
	GameState.pending_techniques.clear()
	OverworldEnemy.debug_frozen = false


## Kiểm tra tác dụng thấy được của Bí Kỹ theo kiểu việc trên map.
func _technique_effect_visible(map: OverworldMap, data: CharacterData, enemy: OverworldEnemy) -> bool:
	var technique := data.technique
	match technique.map_action:
		TechniqueData.MapAction.NONE:
			return GameState.pending_techniques.has(data.id)
		TechniqueData.MapAction.FIREWORK_DAZE, TechniqueData.MapAction.ARROW, TechniqueData.MapAction.DASH_TRAIL:
			return enemy.marks.has(data.id)
		TechniqueData.MapAction.TRAP:
			return not get_tree().get_nodes_in_group(OverworldMap.TechniqueTrap.GROUP).is_empty()
		TechniqueData.MapAction.SPEED_BOOST:
			return map.player.is_boosted()
		TechniqueData.MapAction.INVISIBILITY:
			return map.player.is_invisible()
		TechniqueData.MapAction.REVEAL_SECRETS:
			return map.hud.get_node("%Minimap").is_revealing(Minimap.Reveal.SECRETS)
		TechniqueData.MapAction.REVEAL_ENEMIES:
			return map.hud.get_node("%Minimap").is_revealing(Minimap.Reveal.ENEMIES)
		TechniqueData.MapAction.PHASE_DASH, TechniqueData.MapAction.LONG_DASH:
			return map.player.is_phase_dashing()
		TechniqueData.MapAction.MAGNET:
			return map._magnet_left > 0.0
		TechniqueData.MapAction.HEAL_TEAM:
			return map.hud.get_toast_text() == tr("TOAST_TEAM_HEALED")
		TechniqueData.MapAction.RETURN_TO_REST:
			var rest := map.room_manager.get_room(&"rest_01")
			return map.player.global_position.distance_to(rest.get_spawn_point()) < 2.0
	return false


# --- Nhóm 1: Ignar, Marisol, Raiko, Zephyra, Vesper ---

func _test_group_1() -> void:
	# Ignar: tự tiêu 15% máu → +1 Nhiệt Huyết; 5 tầng → Chiến kỹ toàn bộ quái rồi xóa tầng; Tuyệt kỹ hút máu.
	var c := _battle(_team_with(&"ignar"))
	var ignar := _ally(c, &"ignar")
	var hp := ignar.hp
	var events := _use(c, ignar, SkillData.Kind.SKILL, c.enemies[1])
	_check(is_equal_approx(ignar.hp, hp - hp * 0.15) and ignar.get_status(&"ignar_fervor").stacks == 1,
			"Ignar: Chiến kỹ tiêu 15% máu hiện tại, +1 Nhiệt Huyết")
	_check(_of(events, "damage").size() == 3, "Ignar: Chiến kỹ thường đánh lan 3")
	for i in 4:
		_use(c, ignar, SkillData.Kind.SKILL, c.enemies[1])
	_check(ignar.get_skill(SkillData.Kind.SKILL).id == &"ignar_skill_enhanced", "Ignar: đủ 5 tầng thì Chiến kỹ cường hóa")
	events = _use(c, ignar, SkillData.Kind.SKILL, c.enemies[1])
	_check(_of(events, "damage").size() == 3 and not ignar.has_status(&"ignar_fervor")
			and ignar.get_skill(SkillData.Kind.SKILL).id == &"ignar_skill", "Ignar: Chiến kỹ cường hóa đánh toàn bộ rồi xóa tầng")
	ignar.hp = ignar.get_max_hp() * 0.5
	ignar.set_energy(ignar.max_energy)
	hp = ignar.hp
	_use(c, ignar, SkillData.Kind.ULTIMATE)
	_check(ignar.hp > hp, "Ignar: Tuyệt kỹ hồi máu theo sát thương gây ra")
	await _free(c)

	# Marisol: 25% sát thương quái gây cho đồng minh khác chuyển sang Marisol.
	c = _battle(_team_with(&"marisol"))
	var marisol := _ally(c, &"marisol")
	var mira := _ally(c, &"mira")
	var hit := SkillData.simple_damage(40.0)
	c.crit_mode = DamageCalc.CritMode.NEVER
	var solo := _battle(_team_with(&"traveler", [&"mira", &"garren", &"kiri"]))
	var mira_solo := _ally(solo, &"mira")
	var alone: float = _of(SkillExecutor.execute(solo, solo.enemies[0], hit, mira_solo), "damage")[0]["amount"]
	var shared_events := SkillExecutor.execute(c, c.enemies[0], hit, mira)
	var mira_lost: float = _of(shared_events, "damage").filter(func(e: Dictionary) -> bool: return e["target"] == mira)[0]["amount"]
	var marisol_lost: float = _of(shared_events, "damage").filter(func(e: Dictionary) -> bool: return e["target"] == marisol)[0]["amount"]
	_check(absf(mira_lost - alone * 0.75) <= 1.0 and absf(marisol_lost - alone * 0.25) <= 1.0,
			"Marisol: đồng minh nhận 75%%, Marisol gánh 25%% (%.0f / %.0f của %.0f)" % [mira_lost, marisol_lost, alone])
	marisol.hp = marisol.get_max_hp() * 0.3
	var no_share := SkillExecutor.execute(c, c.enemies[0], hit, mira)
	_check(_of(no_share, "damage").size() == 1, "Marisol dưới 40% máu thì không gánh thay")
	await _free(solo)
	await _free(c)

	# Raiko: Dấu Sấm; quái mang dấu bị hạ → dấu chuyển sang quái máu cao nhất, Raiko kéo lượt 50%.
	c = _battle(_team_with(&"raiko"), MIXED)
	var raiko := _ally(c, &"raiko")
	var first := c.enemies[0]
	_use(c, raiko, SkillData.Kind.SKILL, first)
	_check(first.has_status(&"raiko_mark"), "Raiko: Chiến kỹ gắn Dấu Sấm")
	var distance := raiko.distance_left
	first.take_damage(first.hp)
	c._handle_deaths([{"type": "damage", "target": first, "amount": 0.0, "crit": false}])
	var marked := c.enemies.filter(func(e: BattleUnit) -> bool: return e.is_alive() and e.has_status(&"raiko_mark"))
	_check(marked.size() == 1 and is_equal_approx(raiko.distance_left, maxf(distance - 5000.0, 0.0)),
			"Raiko: quái mang dấu bị hạ → dấu chuyển, Raiko kéo lượt 50%")
	await _free(c)

	# Zephyra: Thuận Buồm kéo lượt 100%; đồng minh đó hết lượt → người đứng sau kéo lượt 25%.
	c = _battle(_team_with(&"zephyra"))
	var zephyra := _ally(c, &"zephyra")
	var kael := _ally(c, &"traveler")
	_use(c, zephyra, SkillData.Kind.SKILL, kael)
	_check(kael.distance_left == 0.0 and kael.has_status(&"zephyra_tailwind"), "Zephyra: Thuận Buồm cho đồng minh đi ngay")
	var order := c.queue.predict(6, kael)
	var next_ally: BattleUnit = null
	for entry in order:
		if entry["unit"] != kael and entry["unit"].is_ally():
			next_ally = entry["unit"]
			break
	var next_distance := next_ally.distance_left
	c.queue.end_turn(kael)
	EventBus.turn_ended.emit(kael)
	_check(is_equal_approx(next_ally.distance_left, maxf(next_distance - 2500.0, 0.0)),
			"Zephyra: Gió Dây Chuyền kéo lượt người đứng sau 25%% (%s)" % next_ally.display_name)
	await _free(c)

	# Vesper: Độc lan khi quái chết; Tuyệt kỹ kích nổ độc.
	c = _battle(_team_with(&"vesper"))
	var vesper := _ally(c, &"vesper")
	_use(c, vesper, SkillData.Kind.SKILL, c.enemies[1])
	_check(c.enemies.all(func(e: BattleUnit) -> bool: return e.has_status(&"vesper_poison")), "Vesper: Chén Độc gắn độc lên 3 quái")
	StatusEffects.remove(c.enemies[0], c.enemies[0].get_status(&"vesper_poison"))
	StatusEffects.remove(c.enemies[2], c.enemies[2].get_status(&"vesper_poison"))
	var middle := c.enemies[1]
	middle.take_damage(middle.hp)
	c._handle_deaths([{"type": "damage", "target": middle, "amount": 0.0, "crit": false}])
	_check(c.enemies[0].has_status(&"vesper_poison") and c.enemies[2].has_status(&"vesper_poison"),
			"Vesper: quái mang độc bị hạ → độc lan sang 2 bên")
	vesper.set_energy(vesper.max_energy)
	var ult := _use(c, vesper, SkillData.Kind.ULTIMATE)
	_check(_of(ult, "dot").size() == 2, "Vesper: Tuyệt kỹ kích nổ Độc Vesper đang có")
	await _free(c)


# --- Nhóm 2: Sylvaine, Orrin, Celestine, Quill, Aldric ---

func _test_group_2() -> void:
	# Sylvaine: Chiến kỹ gieo Cây Sự Sống (vật triệu hồi, không thuộc đội), cây hồi người ít máu nhất; Tuyệt kỹ hồi sinh.
	var c := _battle(_team_with(&"sylvaine"))
	var sylvaine := _ally(c, &"sylvaine")
	_use(c, sylvaine, SkillData.Kind.SKILL, sylvaine)
	var tree := c.get_summon_of(sylvaine)
	_check(tree != null and c.queue.has(tree) and not c.allies.has(tree) and c.allies.size() == 4,
			"Sylvaine: Cây Sự Sống là vật triệu hồi (không chiếm chỗ nhân vật)")
	var pool := SkillExecutor.get_target_pool(SkillData.simple_damage(1.0), c.enemies[0], c.allies, c.enemies)
	_check(not pool.has(tree), "Quái không nhắm được vật triệu hồi")
	var kael := _ally(c, &"traveler")
	kael.hp = kael.get_max_hp() * 0.3
	var action := c._summon_action(tree)
	var heal := SkillExecutor.execute(c, tree, action["skill"], action["target"])
	_check(action["target"] == kael and _of(heal, "heal")[0]["amount"] > 0, "Cây Sự Sống hồi đồng minh ít máu nhất")
	kael.take_damage(kael.hp)
	c._handle_deaths([{"type": "damage", "target": kael, "amount": 0.0, "crit": false}])
	sylvaine.set_energy(sylvaine.max_energy)
	var ult := _use(c, sylvaine, SkillData.Kind.ULTIMATE, sylvaine)
	_check(kael.is_alive() and not _of(ult, "revive").is_empty(), "Sylvaine: Tuyệt kỹ hồi sinh đồng minh đã ngã")
	kael.take_damage(kael.hp)
	c._handle_deaths([{"type": "damage", "target": kael, "amount": 0.0, "crit": false}])
	sylvaine.set_energy(sylvaine.max_energy)
	_use(c, sylvaine, SkillData.Kind.ULTIMATE, sylvaine)
	_check(not kael.is_alive(), "Sylvaine: hồi sinh chỉ 1 lần mỗi trận (Tinh Mệnh 0)")
	await _free(c)

	# Orrin: Chiến kỹ tiêu thêm tối đa 2 Điểm Chiến Kỹ, mỗi điểm +50% hệ số.
	c = _battle(_team_with(&"orrin"))
	var orrin := _ally(c, &"orrin")
	c.skill_points = 1
	var plain: float = _of(_use(c, orrin, SkillData.Kind.SKILL), "damage")[0]["amount"]
	_check(c.skill_points == 0, "Orrin: còn 1 điểm thì chỉ tiêu 1")
	for enemy in c.enemies:
		enemy.recover_toughness()
	c.skill_points = 5
	var boosted: float = _of(_use(c, orrin, SkillData.Kind.SKILL), "damage")[0]["amount"]
	var base_mult := (orrin.get_skill(SkillData.Kind.SKILL).effects[0] as DamageEffect).multiplier
	_check(c.skill_points == 2 and absf(boosted / plain - (base_mult + 1.0) / base_mult) < 0.05,
			"Orrin: tiêu 3 điểm (1 + 2 thêm) → hệ số %d%% + 100 điểm %% (×%.2f)" % [roundi(base_mult * 100), boosted / plain])
	orrin.set_energy(orrin.max_energy)
	_check(_of(_use(c, orrin, SkillData.Kind.ULTIMATE), "damage").size() == 3 + 3, "Orrin: Tuyệt kỹ 3 quái + 3 đòn nảy")
	await _free(c)

	# Celestine: đổi tư thế bằng Chiến kỹ, Tuyệt kỹ đưa vào Phán Xử.
	c = _battle(_team_with(&"celestine"))
	var celestine := _ally(c, &"celestine")
	c.battle_began.emit()
	_check(celestine.has_status(&"celestine_watch"), "Celestine: đầu trận ở Canh Giữ")
	var speed := celestine.get_speed()
	_use(c, celestine, SkillData.Kind.SKILL)
	_check(celestine.has_status(&"celestine_judgment") and celestine.get_skill(SkillData.Kind.SKILL).id == &"celestine_skill_judgment"
			and celestine.get_speed() < speed, "Celestine: Chiến kỹ sang Phán Xử, đổi bộ kỹ năng, mất +20% Tốc Độ")
	_check(is_equal_approx(celestine.stats.get_value(Stats.Type.CRIT_DMG), 0.6 + 0.5), "Phán Xử: Sát thương bạo kích +50%")
	var distance := celestine.distance_left
	_use(c, celestine, SkillData.Kind.SKILL)
	_check(celestine.has_status(&"celestine_watch") and celestine.distance_left < distance, "Celestine: về Canh Giữ, kéo lượt 30%")
	celestine.set_energy(celestine.max_energy)
	_use(c, celestine, SkillData.Kind.ULTIMATE)
	_check(celestine.has_status(&"celestine_judgment"), "Celestine: Tuyệt kỹ đưa vào Phán Xử")
	await _free(c)
	var tech: Array[StringName] = [&"celestine"]
	c = _battle(_team_with(&"celestine"), DUMMIES, 0, tech)
	celestine = _ally(c, &"celestine")
	var sp_before := c.skill_points
	c._apply_technique_effects()
	c.battle_began.emit()
	_check(c.skill_points == sp_before + 2 and celestine.has_status(&"celestine_judgment") and not celestine.has_status(&"celestine_watch"),
			"Lời Tiên Tri: +2 Điểm Chiến Kỹ và vào trận ở Phán Xử")
	await _free(c)

	# Quill: quái chịu sát thương theo lượt → đồng minh ít máu nhất hồi 15% lượng đó.
	c = _battle(_team_with(&"quill"))
	var quill := _ally(c, &"quill")
	kael = _ally(c, &"traveler")
	kael.hp = kael.get_max_hp() * 0.5
	_use(c, quill, SkillData.Kind.SKILL, quill)
	var poisoned := c.enemies.filter(func(e: BattleUnit) -> bool: return e.has_status(&"quill_poison"))
	_check(poisoned.size() == 1, "Quill: Liều Đôi gắn Độc Quill lên 1 quái ngẫu nhiên")
	var hp := kael.hp
	var start := c.process_turn_start(poisoned[0])
	c.report_events(poisoned[0], start["events"])
	var dot: float = _of(start["events"], "dot")[0]["amount"]
	_check(absf((kael.hp - hp) - dot * 0.15) <= 1.0, "Quill: hồi 15%% sát thương theo lượt (%.0f từ %.0f)" % [kael.hp - hp, dot])
	await _free(c)

	# Aldric: đỡ thay đòn nặng (≥25% máu tối đa) cho đồng minh khác, giảm 20%, 1 lần mỗi lượt quái.
	c = _battle(_team_with(&"aldric"))
	var aldric := _ally(c, &"aldric")
	var mira := _ally(c, &"mira")
	c.turn_count = 5
	var heavy := SkillData.simple_damage(400.0)
	var mira_hp := mira.hp
	var events := SkillExecutor.execute(c, c.enemies[0], heavy, mira)
	_check(mira.hp == mira_hp and aldric.hp < aldric.get_max_hp() and not _of(events, "intercept").is_empty(),
			"Aldric: đỡ thay đòn nặng cho đồng minh")
	SkillExecutor.execute(c, c.enemies[0], heavy, mira)
	_check(mira.hp < mira_hp, "Aldric: chỉ đỡ thay 1 lần mỗi lượt quái")
	c.turn_count = 6
	mira.hp = mira.get_max_hp()
	SkillExecutor.execute(c, c.enemies[0], SkillData.simple_damage(1.0), mira)
	_check(mira.hp < mira.get_max_hp(), "Aldric: đòn nhẹ thì không đỡ thay")
	await _free(c)


# --- Nhóm 3: Rook, Fenna, Kestrel, Vael, Wisp ---

func _test_group_3() -> void:
	# Rook: đồng minh ngã → +1 tầng Báo Thù (Tấn Công +25%) và đầy năng lượng; Tuyệt kỹ +40%/tầng.
	var c := _battle(_team_with(&"rook"))
	var rook := _ally(c, &"rook")
	rook.set_energy(0.0)
	var base_atk := rook.stats.get_value(Stats.Type.ATK)
	var mira := _ally(c, &"mira")
	mira.take_damage(mira.hp)
	c._handle_deaths([{"type": "damage", "target": mira, "amount": 0.0, "crit": false}])
	_check(rook.get_status(&"rook_revenge").stacks == 1 and rook.is_ultimate_ready()
			and is_equal_approx(rook.stats.get_value(Stats.Type.ATK), base_atk * 1.25),
			"Rook: đồng minh ngã → Báo Thù (Tấn Công +25%) và đầy năng lượng")
	await _free(c)

	# Fenna: Đánh thường lên quái đang Phá Vỡ → đòn phụ 60%.
	c = _battle(_team_with(&"fenna"))
	var fenna := _ally(c, &"fenna")
	var dummy := c.enemies[0]
	_use(c, fenna, SkillData.Kind.BASIC, dummy)
	await c._process_interrupts()
	var hp_before := dummy.hp
	_use(c, fenna, SkillData.Kind.BASIC, c.enemies[1])
	await c._process_interrupts()
	_check(dummy.hp == hp_before, "Fenna: quái chưa Phá Vỡ thì không có đòn phụ")
	BreakSystem.trigger_break(c, fenna, dummy, Element.Type.WOOD)
	_use(c, fenna, SkillData.Kind.BASIC, dummy)
	hp_before = dummy.hp
	var turn := c.turn_count
	await c._process_interrupts()
	_check(dummy.hp < hp_before and c.turn_count == turn, "Fenna: Đánh thường lên quái Phá Vỡ → Mũi Tên Thứ Hai (không tốn lượt)")
	await _free(c)

	# Kestrel: Chiến kỹ liên tiếp +20%/tầng (tối đa 3), Đánh thường mất hết tầng.
	c = _battle(_team_with(&"kestrel"))
	var kestrel := _ally(c, &"kestrel")
	var damages: Array[float] = []
	for i in 4:
		c.skill_points = 5
		for enemy in c.enemies:
			enemy.recover_toughness()
		damages.append(_of(_use(c, kestrel, SkillData.Kind.SKILL, c.enemies[1]), "damage")[0]["amount"])
	_check(kestrel.get_status(&"kestrel_gale").stacks == 3 and damages[3] > damages[2] and damages[2] > damages[0]
			and absf(damages[3] / damages[0] - 1.9 / 1.3) < 0.03,
			"Kestrel: 3 tầng cộng 60 điểm %% vào hệ số 130%% → 190%% (×%.2f)" % (damages[3] / damages[0]))
	_use(c, kestrel, SkillData.Kind.BASIC)
	_check(not kestrel.has_status(&"kestrel_gale"), "Kestrel: Đánh thường mất hết tầng")
	await _free(c)

	# Vael: +12% sát thương mỗi hiệu ứng xấu trên quái.
	c = _battle(_team_with(&"vael"))
	var vael := _ally(c, &"vael")
	var clean: float = _of(_use(c, vael, SkillData.Kind.BASIC, c.enemies[0]), "damage")[0]["amount"]
	for status_path in ["res://data/status_effects/test_def_down.tres", "res://data/status_effects/nyx_slow.tres",
			"res://data/status_effects/wisp_weaken.tres"]:
		StatusEffects.apply(load(status_path), vael, c.enemies[1])
	var debuffed: float = _of(_use(c, vael, SkillData.Kind.BASIC, c.enemies[1]), "damage")[0]["amount"]
	# test_def_down còn giảm 20% phòng thủ: so với cùng hệ số phòng thủ.
	var expected := clean * 1.36 * DamageCalc.defense_factor(20, 10, 0.2) / DamageCalc.defense_factor(20, 10, 0.0)
	_check(absf(debuffed - expected) <= 2.0, "Vael: 3 hiệu ứng xấu → +36%% sát thương (%.0f / kỳ vọng %.0f)" % [debuffed, expected])
	await _free(c)

	# Wisp: cuối lượt quái mang ≥2 hiệu ứng xấu → trì hoãn 15%.
	c = _battle(_team_with(&"wisp"))
	var wisp := _ally(c, &"wisp")
	var enemy := c.enemies[0]
	_use(c, wisp, SkillData.Kind.SKILL, enemy)
	_check(enemy.count_debuffs() >= 2, "Wisp: Lời Quên Lãng gắn 2 hiệu ứng xấu")
	c.queue.end_turn(enemy)
	var distance := enemy.distance_left
	EventBus.turn_ended.emit(enemy)
	_check(is_equal_approx(enemy.distance_left, distance + 1500.0), "Wisp: Lời Thì Thầm trì hoãn quái 15%")
	var other := c.enemies[1]
	c.queue.end_turn(other)
	distance = other.distance_left
	EventBus.turn_ended.emit(other)
	_check(other.distance_left == distance, "Wisp: quái không đủ hiệu ứng xấu thì không bị trì hoãn")
	await _free(c)



# --- Nhóm 4: Selka, Ember, Neris, Pip, Echo ---

func _test_group_4() -> void:
	# Selka: đội có cặp cùng nguyên tố → cả đội Tăng sát thương +8%/cặp; người cùng nguyên tố với mục tiêu Hương Dũng Khí +10% Tấn Công.
	var same: Array[StringName] = [&"selka", &"vesper", &"quill", &"traveler"]
	var c := _battle(same)
	c.battle_began.emit()
	var selka := _ally(c, &"selka")
	var harmony := selka.get_status(&"selka_harmony")
	_check(harmony != null and harmony.stacks == 2 and is_equal_approx(_ally(c, &"traveler").stats.get_value(Stats.Type.DAMAGE_BONUS), 0.16),
			"Selka: 3 người hệ Độc = 2 cặp → cả đội Tăng sát thương +16%")
	_use(c, selka, SkillData.Kind.SKILL, _ally(c, &"vesper"))
	_check(_ally(c, &"vesper").has_status(&"selka_courage") and _ally(c, &"quill").has_status(&"selka_resonance")
			and not _ally(c, &"traveler").has_status(&"selka_resonance"), "Selka: người cùng nguyên tố với mục tiêu được +10% Tấn Công")
	await _free(c)

	# Ember: hạ quái → nổ 50% lên mọi quái còn lại (1 lần mỗi hành động).
	c = _battle(_team_with(&"ember"))
	var ember := _ally(c, &"ember")
	var victim := c.enemies[0]
	victim.hp = 1.0
	var hp1 := c.enemies[1].hp
	var events := _use(c, ember, SkillData.Kind.BASIC, victim)
	_check(not victim.is_alive() and c.enemies[1].hp < hp1 and c.enemies[2].hp < c.enemies[2].get_max_hp()
			and _of(events, "blast").size() == 1, "Ember: hạ quái → Tro Tàn Lan nổ lên mọi quái còn lại")
	await _free(c)

	# Neris: đòn không bạo kích +12% Tỉ Lệ Bạo Kích (cộng dồn), bạo kích thì mất hết; Tuyệt kỹ chắc chắn bạo kích.
	c = _battle(_team_with(&"neris"))
	var neris := _ally(c, &"neris")
	var crit_base := neris.stats.get_value(Stats.Type.CRIT_RATE)
	for i in 3:
		_use(c, neris, SkillData.Kind.BASIC, c.enemies[0])
	_check(neris.get_status(&"neris_patience").stacks == 3 and is_equal_approx(neris.stats.get_value(Stats.Type.CRIT_RATE), crit_base + 0.36),
			"Neris: 3 đòn không bạo kích → +36% Tỉ Lệ Bạo Kích")
	c.crit_mode = DamageCalc.CritMode.ROLL
	neris.set_energy(neris.max_energy)
	var ult := _of(_use(c, neris, SkillData.Kind.ULTIMATE, c.enemies[0]), "damage")
	_check(ult[0]["crit"] and not neris.has_status(&"neris_patience"), "Neris: Tuyệt kỹ chắc chắn bạo kích, bạo kích thì mất tầng")
	await _free(c)

	# Pip: đầu lượt của Pip, đồng minh ít năng lượng nhất +8.
	c = _battle(_team_with(&"pip"))
	var pip := _ally(c, &"pip")
	var kael := _ally(c, &"traveler")
	for ally in c.allies:
		ally.set_energy(ally.max_energy * 0.9)
	kael.set_energy(0.0)
	EventBus.turn_started.emit(pip)
	_check(is_equal_approx(kael.energy, 8.0), "Pip: Pin Dự Phòng sạc 8 năng lượng cho người ít năng lượng nhất")
	var mira := _ally(c, &"mira")
	mira.set_energy(0.0)
	_use(c, pip, SkillData.Kind.SKILL, mira)
	_check(is_equal_approx(mira.energy, 25.0) and mira.has_status(&"pip_charge"), "Pip: Sạc Nhanh +25 năng lượng và +15% Tấn Công")
	await _free(c)

	# Echo: đồng minh khác gắn hiệu ứng xấu → bản sao lên 1 quái khác.
	var with_nyx: Array[StringName] = [&"echo", &"nyx", &"mira", &"traveler"]
	c = _battle(with_nyx)
	var nyx := _ally(c, &"nyx")
	_use(c, nyx, SkillData.Kind.SKILL, c.enemies[0])
	var copied := c.enemies.filter(func(e: BattleUnit) -> bool: return e != c.enemies[0] and e.count_debuffs() > 0)
	_check(copied.size() == 1, "Echo: Vang Vọng sao chép hiệu ứng xấu của Nyx sang 1 quái khác (1 lần mỗi lượt)")
	var echo := _ally(c, &"echo")
	echo.set_energy(echo.max_energy)
	_use(c, echo, SkillData.Kind.ULTIMATE)
	_check(c.enemies.all(func(e: BattleUnit) -> bool: return e.count_debuffs() > 0), "Echo: Tuyệt kỹ chia hiệu ứng xấu cho mọi quái")
	await _free(c)
