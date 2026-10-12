class_name ReviveEffect
extends SkillEffect
## Hồi sinh đồng minh đã ngã đầu tiên (theo vị trí) với `hp_ratio` máu, tối đa `max_uses` lần mỗi trận
## cho mỗi người dùng (Talent có thể tăng qua user.custom["revive_uses_bonus"]).

@export var hp_ratio: float = 0.4
@export var max_uses: int = 1


func apply(ctx: SkillContext) -> void:
	for unit in ctx.battle.allies:
		if unit.is_alive():
			continue
		var limit := max_uses + int(ctx.user.custom.get("revive_uses_bonus", 0))
		if ctx.battle.try_use("revive_%s" % ctx.user.id, limit):
			ctx.events.append_array(ctx.battle.revive(unit, hp_ratio))
		return
