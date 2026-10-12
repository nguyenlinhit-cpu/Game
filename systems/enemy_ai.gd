class_name EnemyAI
extends RefCounted
## AI quái TẠM (Phase 4): chọn kỹ năng ngẫu nhiên theo trọng số, mục tiêu ngẫu nhiên.
## TODO Phase 6: chọn mục tiêu theo trọng số bị nhắm của vận mệnh (mục 6).
## TODO Phase 8: chọn theo tình huống, báo trước đòn mạnh.


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
	return {"skill": skill, "target": pool[rng.randi_range(0, pool.size() - 1)]}
