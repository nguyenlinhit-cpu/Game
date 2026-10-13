class_name SkillExecutor
extends RefCounted
## Chạy danh sách hiệu ứng của SkillData lên mục tiêu (qua SkillContext), trả về sự kiện để giao diện hiển thị:
## { "type", "target": BattleUnit, "amount": float, "crit": bool, "element"?: Element.Type, "status"?: StringName }.
## type: damage, dot, break, toughness, heal, shield, advance, delay, energy, skill_point, cleanse,
## status_applied, status_resisted, recover, skip, expired, revive, death.


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
		main_target: BattleUnit, follow_up: bool = false) -> Array[Dictionary]:
	var ctx := SkillContext.new(battle, user, skill, main_target)
	ctx.is_follow_up = follow_up
	for effect in skill.effects:
		if effect:
			effect.apply(ctx)
	if user.is_ally():
		battle.change_skill_points(skill.sp_change)
		if skill.kind == SkillData.Kind.ULTIMATE:
			user.set_energy(0.0)
			EventBus.ultimate_used.emit(user)
		user.add_energy(skill.energy_gain)
	battle.skill_resolved.emit(ctx)
	return ctx.events


static func build_damage_params(user: BattleUnit, target: BattleUnit, scaling_stat: Stats.Type,
		multiplier: float, element: int) -> DamageCalc.Params:
	var p := DamageCalc.Params.new()
	p.base_stat = user.stats.get_value(scaling_stat)
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


## Còn sống, chọn làm mục tiêu được, sắp theo vị trí.
static func _alive_sorted(units: Array[BattleUnit]) -> Array[BattleUnit]:
	var result: Array[BattleUnit] = []
	for unit in units:
		if unit.is_targetable():
			result.append(unit)
	result.sort_custom(func(a: BattleUnit, b: BattleUnit) -> bool: return a.slot < b.slot)
	return result
