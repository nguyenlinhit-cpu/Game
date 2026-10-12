class_name HpCostEffect
extends SkillEffect
## Tự tiêu máu người dùng theo phần máu hiện tại (không làm ngã: luôn còn ít nhất 1 máu).

@export var current_hp_ratio: float = 0.15


func apply(ctx: SkillContext) -> void:
	var user := ctx.user
	var ratio := current_hp_ratio * maxf(1.0 - float(user.custom.get("hp_cost_reduction", 0.0)), 0.0)
	var cost := minf(user.hp * ratio, user.hp - 1.0)
	if cost <= 0.0:
		return
	user.take_damage(cost)
	ctx.events.append({"type": "hp_cost", "target": user, "amount": cost, "crit": false})
	ctx.battle.hp_consumed.emit(user, cost)
