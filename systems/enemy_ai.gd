class_name EnemyAI
extends RefCounted
## AI quái: lọc EnemyAction đủ điều kiện (máu, hồi chiêu, số lần dùng, số quái cùng họ, chỗ trống,
## hiệu ứng trên phe ta...), nhân trọng số theo tình huống (máu thấp, đồng minh bị hạ, vừa bị Phá Vỡ,
## đồng minh bị thương) rồi chọn ngẫu nhiên theo trọng số. Hành động `priority` đủ điều kiện thì dùng ngay.
## Mục tiêu: theo TargetRule; mặc định theo trọng số bị nhắm của vận mệnh
## (Bảo Hộ 150, Hủy Diệt 125, Hòa Hợp/Hư Vô/Trù Phú 100, Săn Bắn/Tri Thức 75) × (1 + AGGRO).
## Có người đang Khiêu Khích thì đòn đơn/lan phải nhắm người đó.

const LOW_HP_RATIO: float = 0.5
const INJURED_ALLY_RATIO: float = 0.6


## Trả về { "skill": SkillData, "target": BattleUnit, "action": EnemyAction } hoặc rỗng nếu không làm gì được.
## `allow_charged` = false: bỏ qua đòn tích tụ (đang đếm ngược một đòn khác).
static func choose_action(enemy: BattleUnit, battle: BattleController, allow_charged: bool = true) -> Dictionary:
	var candidates: Array[EnemyAction] = []
	var weights := PackedFloat32Array()
	for action in enemy.actions:
		if action == null or (action.is_charged() and not allow_charged):
			continue
		if not is_available(action, enemy, battle):
			continue
		if action.priority or (action.priority_on_phase_start and enemy.turns_in_phase <= 1):
			return _make(action, enemy, battle)
		var weight := situational_weight(action, enemy, battle)
		if weight > 0.0:
			candidates.append(action)
			weights.append(weight)
	if candidates.is_empty():
		return {}
	return _make(candidates[battle.rng.rand_weighted(weights)], enemy, battle)


static func is_available(action: EnemyAction, enemy: BattleUnit, battle: BattleController) -> bool:
	if action.skill == null or not enemy.is_action_ready(action):
		return false
	if maxi(enemy.turns_in_phase, 1) < action.first_turn:
		return false
	var ratio := enemy.get_hp_ratio()
	if ratio < action.min_hp_ratio or ratio > action.max_hp_ratio:
		return false
	if action.max_family_alive > 0 and battle.count_family_alive(enemy) > action.max_family_alive:
		return false
	if action.needs_free_slot and battle.get_free_enemy_slots() <= 0:
		return false
	if action.self_status != &"":
		var own := enemy.get_status(action.self_status)
		if own == null or own.stacks < action.self_status_min_stacks:
			return false
	var foes := battle.get_foes(enemy)
	if action.requires_foe_status != &"" and _marked(foes, enemy, action.requires_foe_status).is_empty():
		return false
	if action.requires_foe_buff and not foes.any(func(u: BattleUnit) -> bool: return has_transferable_buff(u)):
		return false
	return not SkillExecutor.get_target_pool(action.skill, enemy, battle.allies, battle.enemies).is_empty()


static func situational_weight(action: EnemyAction, enemy: BattleUnit, battle: BattleController) -> float:
	var weight := action.weight
	if enemy.get_hp_ratio() < LOW_HP_RATIO:
		weight *= action.low_hp_weight_mult
	if battle.enemy_deaths > 0:
		weight *= action.ally_fallen_weight_mult
	if enemy.broken_since_turn:
		weight *= action.after_break_weight_mult
	if battle.get_friends(enemy).any(func(u: BattleUnit) -> bool: return u.get_hp_ratio() < INJURED_ALLY_RATIO):
		weight *= action.injured_ally_weight_mult
	return weight


## Chọn lại mục tiêu cho đòn đã tích tụ khi mục tiêu cũ không còn.
static func choose_target_for(action: EnemyAction, enemy: BattleUnit, battle: BattleController) -> BattleUnit:
	var pool := SkillExecutor.get_target_pool(action.skill, enemy, battle.allies, battle.enemies)
	if pool.is_empty():
		return null
	var skill := action.skill
	if skill.is_ally_targeted():
		var lowest := pool[0]
		for unit in pool:
			if unit.get_hp_ratio() < lowest.get_hp_ratio():
				lowest = unit
		return lowest
	match action.target_rule:
		EnemyAction.TargetRule.MARKED:
			var marked := _marked(pool, enemy, action.requires_foe_status)
			if not marked.is_empty():
				return marked[0]
		EnemyAction.TargetRule.LOWEST_HP:
			return _best(pool, func(u: BattleUnit) -> float: return -u.get_hp_ratio())
		EnemyAction.TargetRule.HIGHEST_ATK:
			return _best(pool, func(u: BattleUnit) -> float: return u.stats.get_value(Stats.Type.ATK))
		EnemyAction.TargetRule.MOST_BUFFS:
			return _best(pool, func(u: BattleUnit) -> float: return float(u.count_buffs()))
		EnemyAction.TargetRule.RANDOM:
			return pool[battle.rng.randi_range(0, pool.size() - 1)]
	return choose_target(skill, pool, battle.rng)


static func choose_target(skill: SkillData, pool: Array[BattleUnit], rng: RandomNumberGenerator) -> BattleUnit:
	if skill.is_ally_targeted() or pool.is_empty():
		return pool[rng.randi_range(0, pool.size() - 1)] if not pool.is_empty() else null
	var candidates := pool
	if skill.target != SkillData.Target.ALL_ENEMIES:
		var taunting := pool.filter(func(unit: BattleUnit) -> bool: return unit.is_taunting())
		if not taunting.is_empty():
			candidates.assign(taunting)
	var weights := PackedFloat32Array()
	for unit in candidates:
		weights.append(unit.get_aggro_weight())
	return candidates[rng.rand_weighted(weights)]


## Buff hút / sao chép được: buff có chỉ số hoặc hồi máu theo lượt, không phải khiên/khiêu khích/bộ đếm dài hạn.
static func is_transferable(instance: StatusEffectInstance) -> bool:
	var data := instance.data
	return data.kind == StatusEffectData.Kind.BUFF and not data.shield and not data.taunt \
			and data.duration_turns < 10 and (not data.stat_modifiers.is_empty() or data.heal_per_turn_ratio > 0.0)


static func has_transferable_buff(unit: BattleUnit) -> bool:
	return unit.status_effects.any(func(i: StatusEffectInstance) -> bool: return is_transferable(i))


static func _make(action: EnemyAction, enemy: BattleUnit, battle: BattleController) -> Dictionary:
	var target := choose_target_for(action, enemy, battle)
	if target == null:
		return {}
	return {"skill": action.skill, "target": target, "action": action}


static func _marked(pool: Array[BattleUnit], enemy: BattleUnit, status_id: StringName) -> Array[BattleUnit]:
	var result: Array[BattleUnit] = []
	for unit in pool:
		var instance := unit.get_status(status_id)
		if instance and instance.source == enemy:
			result.append(unit)
	return result


static func _best(pool: Array[BattleUnit], score: Callable) -> BattleUnit:
	var best := pool[0]
	for unit in pool:
		if float(score.call(unit)) > float(score.call(best)):
			best = unit
	return best
