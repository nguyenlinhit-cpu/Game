class_name EnergyEffect
extends SkillEffect
## Hồi năng lượng cho mục tiêu (phe ta).

@export var amount: float = 0.0
## Không nhân Hiệu Suất Hồi Năng Lượng.
@export var fixed: bool = false


func apply(ctx: SkillContext) -> void:
	for entry in ctx.entries(scope):
		var target: BattleUnit = entry["unit"]
		if target.is_ally() and target.is_alive():
			target.add_energy(amount, not fixed)
			ctx.events.append({"type": "energy", "target": target, "amount": amount, "crit": false})
