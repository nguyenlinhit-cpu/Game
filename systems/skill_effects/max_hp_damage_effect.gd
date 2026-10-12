class_name MaxHpDamageEffect
extends SkillEffect
## Mất máu theo % máu tối đa của mục tiêu (bỏ qua phòng thủ/kháng; dùng cho Bí Kỹ đầu trận).

@export var ratio: float = 0.1


func apply(ctx: SkillContext) -> void:
	for entry in ctx.entries(scope):
		var target: BattleUnit = entry["unit"]
		if target.is_alive():
			var lost := target.take_damage(floorf(target.get_max_hp() * ratio))
			ctx.events.append({"type": "damage", "target": target, "amount": lost, "crit": false, "source": ctx.user})
