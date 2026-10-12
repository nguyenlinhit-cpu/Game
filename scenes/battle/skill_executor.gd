class_name SkillExecutor
extends RefCounted
## Áp một SkillData lên mục tiêu, trả về danh sách sự kiện để giao diện hiển thị:
## { "type", "target": BattleUnit, "amount": float, "crit": bool, "element"?: Element.Type, "status"?: StringName }.
## type: damage, dot, break, toughness, heal, advance, delay, status_applied, status_resisted, recover, skip, expired.


## Đơn vị chọn được làm mục tiêu chính cho kỹ năng này (đã sắp theo vị trí).
static func get_target_pool(skill: SkillData, user: BattleUnit,
		allies: Array[BattleUnit], enemies: Array[BattleUnit]) -> Array[BattleUnit]:
	var friends := _alive_sorted(allies if user.is_ally() else enemies)
	var foes := _alive_sorted(enemies if user.is_ally() else allies)
	match skill.target:
		SkillData.Target.SINGLE_ENEMY, SkillData.Target.BLAST_ENEMY, SkillData.Target.ALL_ENEMIES:
			return foes
		SkillData.Target.SELF:
			return [user]
		_:
			if not skill.can_target_self and friends.size() > 1:
				friends.erase(user)
			return friends


## Mục tiêu thật sự trúng đòn: [{ "unit": BattleUnit, "main": bool }].
static func resolve_targets(skill: SkillData, user: BattleUnit, main_target: BattleUnit,
		allies: Array[BattleUnit], enemies: Array[BattleUnit]) -> Array[Dictionary]:
	var pool := get_target_pool(skill, user, allies, enemies)
	if pool.is_empty():
		return []
	if main_target == null or not pool.has(main_target):
		main_target = pool[0]
	var result: Array[Dictionary] = []
	match skill.target:
		SkillData.Target.ALL_ENEMIES, SkillData.Target.ALL_ALLIES:
			for unit in pool:
				result.append({"unit": unit, "main": true})
		SkillData.Target.BLAST_ENEMY:
			var index := pool.find(main_target)
			result.append({"unit": main_target, "main": true})
			for neighbor_index: int in [index - 1, index + 1]:
				if neighbor_index >= 0 and neighbor_index < pool.size():
					result.append({"unit": pool[neighbor_index], "main": false})
		_:
			result.append({"unit": main_target, "main": true})
	return result


static func execute(battle: BattleController, user: BattleUnit, skill: SkillData,
		main_target: BattleUnit) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var targets := resolve_targets(skill, user, main_target, battle.allies, battle.enemies)

	if skill.deals_damage():
		var element := battle.get_attack_element(user)
		for entry in targets:
			var target: BattleUnit = entry["unit"]
			var multiplier := skill.damage_multiplier if entry["main"] else skill.adjacent_multiplier
			if multiplier <= 0.0 or not target.is_alive():
				continue
			# Sát thương tính theo trạng thái khiên TRƯỚC đòn này (đòn phá vỡ vẫn chịu hệ số 0,9).
			var result := DamageCalc.roll(build_damage_params(user, target, skill, multiplier, element),
					battle.rng, battle.crit_mode)
			var dealt := target.take_damage(result["amount"])
			events.append({"type": "damage", "target": target, "amount": dealt, "crit": result["crit"], "element": element})
			EventBus.damage_dealt.emit(user, target, int(dealt), result["crit"])
			target.add_energy(BattleUnit.ENERGY_ON_HIT)
			events.append_array(StatusEffects.on_hit(target))
			var toughness := skill.toughness_damage if entry["main"] else skill.toughness_damage_adjacent
			events.append_array(BreakSystem.apply_toughness_damage(battle, user, target, element, toughness))

	if skill.heals():
		var amount := (user.stats.get_value(skill.scaling_stat) * skill.heal_multiplier + skill.heal_flat) \
				* (1.0 + user.stats.get_value(Stats.Type.OUTGOING_HEALING))
		for entry in targets:
			var target: BattleUnit = entry["unit"]
			events.append({"type": "heal", "target": target, "amount": target.heal(amount), "crit": false})

	if skill.action_advance > 0.0:
		for entry in targets:
			battle.queue.action_advance(entry["unit"], skill.action_advance)
			events.append({"type": "advance", "target": entry["unit"], "amount": skill.action_advance, "crit": false})

	if skill.target_delay > 0.0:
		for entry in targets:
			var target: BattleUnit = entry["unit"]
			if entry["main"] and target.is_alive():
				battle.queue.delay(target, skill.target_delay)
				events.append({"type": "delay", "target": target, "amount": skill.target_delay, "crit": false})

	if user.is_ally():
		battle.change_skill_points(skill.sp_change)
		if skill.kind == SkillData.Kind.ULTIMATE:
			user.set_energy(0.0)
			EventBus.ultimate_used.emit(user)
		user.add_energy(skill.energy_gain)
	return events


static func build_damage_params(user: BattleUnit, target: BattleUnit, skill: SkillData,
		multiplier: float, element: int) -> DamageCalc.Params:
	var p := DamageCalc.Params.new()
	p.base_stat = user.stats.get_value(skill.scaling_stat)
	p.multiplier = multiplier
	p.damage_bonus = user.stats.get_value(Stats.Type.DAMAGE_BONUS)
	p.crit_rate = user.stats.get_value(Stats.Type.CRIT_RATE)
	p.crit_dmg = user.stats.get_value(Stats.Type.CRIT_DMG)
	p.attacker_level = user.level
	p.defender_level = target.level
	p.def_reduction = target.stats.get_value(Stats.Type.DEF_REDUCTION)
	p.res = target.get_res(element)
	p.vulnerability = target.stats.get_value(Stats.Type.VULNERABILITY)
	p.defender_has_toughness = target.has_toughness()
	p.defender_broken = target.is_broken
	return p


static func _alive_sorted(units: Array[BattleUnit]) -> Array[BattleUnit]:
	var result: Array[BattleUnit] = []
	for unit in units:
		if unit.is_alive():
			result.append(unit)
	result.sort_custom(func(a: BattleUnit, b: BattleUnit) -> bool: return a.slot < b.slot)
	return result
