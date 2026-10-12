class_name SkillPointEffect
extends SkillEffect
## Cộng/trừ Điểm Chiến Kỹ ngoài phần sp_change của kỹ năng.

@export var amount: int = 1


func apply(ctx: SkillContext) -> void:
	ctx.battle.change_skill_points(amount)
	ctx.events.append({"type": "skill_point", "target": ctx.user, "amount": float(amount), "crit": false})
