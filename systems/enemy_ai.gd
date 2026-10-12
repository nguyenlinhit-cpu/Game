class_name EnemyAI
extends RefCounted
## AI quái: chọn kỹ năng ngẫu nhiên theo trọng số; chọn mục tiêu theo trọng số bị nhắm của vận mệnh
## (Bảo Hộ 150, Hủy Diệt 125, Hòa Hợp/Hư Vô/Trù Phú 100, Săn Bắn/Tri Thức 75) × (1 + AGGRO).
## Có người đang Khiêu Khích thì đòn đơn/lan phải nhắm người đó.
## TODO Phase 8: chọn kỹ năng theo tình huống, báo trước đòn mạnh.


## Trả về { "skill": SkillData, "target": BattleUnit } hoặc rỗng nếu không làm gì được.
static func choose_action(enemy: BattleUnit, allies: Array[BattleUnit], enemies: Array[BattleUnit],
		rng: RandomNumberGenerator) -> Dictionary:
	if enemy.enemy == null or enemy.enemy.skills.is_empty():
		return {}
	var skills := enemy.enemy.skills
	var weights := PackedFloat32Array()
	for i in skills.size():
		weights.append(enemy.enemy.skill_weights[i] if i < enemy.enemy.skill_weights.size() else 1.0)
	var skill: SkillData = skills[rng.rand_weighted(weights)]
	var pool := SkillExecutor.get_target_pool(skill, enemy, allies, enemies)
	if pool.is_empty():
		return {}
	return {"skill": skill, "target": choose_target(skill, pool, rng)}


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
