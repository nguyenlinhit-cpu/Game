class_name CleanseEffect
extends SkillEffect
## Giải hiệu ứng xấu: gỡ `count` debuff (mới gắn nhất trước) khỏi mỗi mục tiêu.

@export var count: int = 1


func apply(ctx: SkillContext) -> void:
	for entry in ctx.entries(scope):
		var target: BattleUnit = entry["unit"]
		var removed := 0
		for i in range(target.status_effects.size() - 1, -1, -1):
			if removed >= count:
				break
			var instance := target.status_effects[i]
			if instance.data.kind == StatusEffectData.Kind.DEBUFF:
				StatusEffects.remove(target, instance)
				removed += 1
		if removed > 0:
			ctx.events.append({"type": "cleanse", "target": target, "amount": float(removed), "crit": false})
