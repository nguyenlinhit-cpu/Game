class_name TurnShiftEffect
extends SkillEffect
## Kéo lượt (amount > 0) hoặc trì hoãn (amount < 0), tính theo phần quãng đường (0,5 = 50%).

@export var amount: float = 0.0


func apply(ctx: SkillContext) -> void:
	for entry in ctx.entries(scope):
		var target: BattleUnit = entry["unit"]
		if not target.is_alive() or not ctx.battle.queue.has(target):
			continue
		if amount > 0.0:
			ctx.battle.queue.action_advance(target, amount)
			ctx.events.append({"type": "advance", "target": target, "amount": amount, "crit": false})
		elif amount < 0.0:
			ctx.battle.queue.delay(target, -amount)
			ctx.events.append({"type": "delay", "target": target, "amount": -amount, "crit": false})


func collect_turn_overrides(ctx: SkillContext, overrides: Dictionary) -> void:
	for entry in ctx.entries(scope):
		var target: BattleUnit = entry["unit"]
		if target == ctx.user or not ctx.battle.queue.has(target):
			continue
		var distance: float = overrides.get(target, target.distance_left)
		overrides[target] = maxf(distance - TurnQueue.BASE_DISTANCE * amount, 0.0)
