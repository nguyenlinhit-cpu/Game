class_name AutoBattle
extends RefCounted
## Chế độ Tự Động cho phe ta (và cho người chơi bấm nút Tự Động).
## Luật đơn giản: hồi máu khi đồng đội dưới 60%; kéo lượt khi dư Điểm Chiến Kỹ;
## chiến kỹ gây sát thương khi còn ≥2 điểm (chừa 1 cho người hồi máu); còn lại đánh thường.

const HEAL_THRESHOLD: float = 0.6
const ULTIMATE_HEAL_THRESHOLD: float = 0.75


## Trả về { "skill": SkillData, "target": BattleUnit }.
static func choose_action(unit: BattleUnit, battle: BattleController) -> Dictionary:
	var skill := unit.get_skill(SkillData.Kind.SKILL)
	var basic := unit.get_skill(SkillData.Kind.BASIC)
	if skill and battle.skill_points >= 1:
		if skill.heals() and _lowest_ally(battle, unit, skill).get_hp_ratio() < HEAL_THRESHOLD:
			return {"skill": skill, "target": _lowest_ally(battle, unit, skill)}
		if skill.action_advance > 0.0 and battle.skill_points >= 3:
			return {"skill": skill, "target": _strongest_ally(battle, unit, skill)}
		if skill.deals_damage() and battle.skill_points >= 2:
			return {"skill": skill, "target": best_enemy_target(battle, unit, skill)}
	return {"skill": basic, "target": best_enemy_target(battle, unit, basic)}


## Tuyệt kỹ hồi máu chỉ dùng khi có người bị thương; còn lại dùng ngay khi đầy.
static func should_use_ultimate(unit: BattleUnit, battle: BattleController) -> bool:
	var ultimate := unit.get_skill(SkillData.Kind.ULTIMATE)
	if ultimate == null or not unit.is_ultimate_ready():
		return false
	if ultimate.heals() and not ultimate.deals_damage():
		return _lowest_ally(battle, unit, ultimate).get_hp_ratio() < ULTIMATE_HEAL_THRESHOLD
	return true


static func choose_ultimate_target(unit: BattleUnit, battle: BattleController) -> BattleUnit:
	var ultimate := unit.get_skill(SkillData.Kind.ULTIMATE)
	if ultimate.is_ally_targeted():
		return _lowest_ally(battle, unit, ultimate)
	return best_enemy_target(battle, unit, ultimate)


## Đơn: quái ít máu nhất. Lan: quái ở giữa (trúng nhiều nhất).
static func best_enemy_target(battle: BattleController, unit: BattleUnit, skill: SkillData) -> BattleUnit:
	var pool := SkillExecutor.get_target_pool(skill, unit, battle.allies, battle.enemies)
	if pool.is_empty():
		return null
	if skill.target == SkillData.Target.BLAST_ENEMY:
		return pool[pool.size() / 2]
	var best := pool[0]
	for candidate in pool:
		if candidate.hp < best.hp:
			best = candidate
	return best


static func _lowest_ally(battle: BattleController, unit: BattleUnit, skill: SkillData) -> BattleUnit:
	var pool := SkillExecutor.get_target_pool(skill, unit, battle.allies, battle.enemies)
	var best := pool[0] if not pool.is_empty() else unit
	for candidate in pool:
		if candidate.get_hp_ratio() < best.get_hp_ratio():
			best = candidate
	return best


static func _strongest_ally(battle: BattleController, unit: BattleUnit, skill: SkillData) -> BattleUnit:
	var pool := SkillExecutor.get_target_pool(skill, unit, battle.allies, battle.enemies)
	var best := pool[0] if not pool.is_empty() else unit
	for candidate in pool:
		if candidate.stats.get_value(Stats.Type.ATK) > best.stats.get_value(Stats.Type.ATK):
			best = candidate
	return best
