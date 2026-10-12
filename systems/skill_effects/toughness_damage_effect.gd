class_name ToughnessDamageEffect
extends SkillEffect
## Trừ một phần Khiên Điểm Yếu tối đa, bất kể nguyên tố (Bí Kỹ đầu trận). Không làm Phá Vỡ: còn tối thiểu 1.

@export var ratio: float = 0.2


func apply(ctx: SkillContext) -> void:
	for entry in ctx.entries(scope):
		var target: BattleUnit = entry["unit"]
		if target.has_toughness() and not target.is_broken:
			var amount := minf(target.max_toughness * ratio, target.toughness - 1.0)
			if amount > 0.0:
				target.reduce_toughness(amount)
				ctx.events.append({"type": "toughness", "target": target, "amount": amount, "crit": false})
