class_name TracePassives
extends TalentScript
## Bị động của các nút lớn trong cây vận mệnh đã mở (TraceNodeData.Passive). Phần chỉ số của nút
## (stat_modifiers) BattleController cộng thẳng vào Stats khi vào trận; script này lo phần có điều kiện.

const SHIELD_STATUS: String = "res://data/status_effects/shield.tres"
const LOW_HP_RATIO: float = 0.5

## { TraceNodeData.Passive: tổng giá trị }
var passives: Dictionary = {}


func setup(nodes: Array[TraceNodeData]) -> void:
	for node in nodes:
		if node.passive != TraceNodeData.Passive.NONE:
			passives[node.passive] = float(passives.get(node.passive, 0.0)) + node.passive_value


func is_empty() -> bool:
	return passives.is_empty()


func _value(passive: TraceNodeData.Passive) -> float:
	return float(passives.get(passive, 0.0))


func _on_battle_start() -> void:
	if not owner.is_alive():
		return
	if _value(TraceNodeData.Passive.START_ENERGY) > 0.0:
		owner.set_energy(owner.energy + owner.max_energy * _value(TraceNodeData.Passive.START_ENERGY))
	if _value(TraceNodeData.Passive.START_SHIELD) > 0.0:
		var ctx := make_context()
		ctx.give_shield(owner, owner.stats.get_value(Stats.Type.DEF) * _value(TraceNodeData.Passive.START_SHIELD),
				load(SHIELD_STATUS) as StatusEffectData)
		report(ctx.events)


func _on_before_damage(ctx: SkillContext, target: BattleUnit, params: DamageCalc.Params) -> void:
	if ctx.user != owner:
		return
	if owner.get_hp_ratio() < LOW_HP_RATIO:
		params.damage_bonus += _value(TraceNodeData.Passive.LOW_HP_DAMAGE)
	if target.count_debuffs() > 0:
		params.damage_bonus += _value(TraceNodeData.Passive.DEBUFFED_TARGET_DAMAGE)


func _on_weakness_broken(attacker: BattleUnit, _target: BattleUnit) -> void:
	if attacker == owner and _value(TraceNodeData.Passive.BREAK_ENERGY) > 0.0:
		owner.add_energy(_value(TraceNodeData.Passive.BREAK_ENERGY), false)


func _on_before_heal(ctx: SkillContext, target: BattleUnit, box: Dictionary) -> void:
	if ctx.user == owner and target.get_hp_ratio() < LOW_HP_RATIO:
		box["amount"] = float(box["amount"]) * (1.0 + _value(TraceNodeData.Passive.LOW_HP_HEAL))
