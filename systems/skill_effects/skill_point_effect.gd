class_name SkillPointEffect
extends SkillEffect
## Cộng/trừ Điểm Chiến Kỹ ngoài phần sp_change của kỹ năng. Quái dùng số âm để trộm điểm.

@export var amount: int = 1


func apply(ctx: SkillContext) -> void:
	var before := ctx.battle.skill_points
	ctx.battle.change_skill_points(amount)
	var delta := ctx.battle.skill_points - before
	if amount >= 0:
		ctx.events.append({"type": "skill_point", "target": ctx.user, "amount": float(amount), "crit": false})
	elif delta < 0:
		ctx.events.append({"type": "sp_lost", "target": ctx.main_target if ctx.main_target else ctx.user,
				"amount": float(-delta), "crit": false})
