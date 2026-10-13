class_name ApplyStatusEffect
extends SkillEffect
## Gắn buff/debuff (có tung tỉ lệ trúng theo StatusEffectData).
## Giá trị nền cho sát thương/hồi theo lượt = chỉ số người dùng × base_multiplier
## (0 = dùng mức phá vỡ của người dùng).

@export var status: StatusEffectData
@export var base_stat: Stats.Type = Stats.Type.ATK
@export var base_multiplier: float = 0.0
## Gắn lên chính người dùng trong lượt của mình: cộng 1 lượt để không hết ngay cuối lượt này (Thủ thế...).
@export var extend_if_self: bool = false


func apply(ctx: SkillContext) -> void:
	if status == null:
		return
	var base := ctx.user.stats.get_value(base_stat) * base_multiplier if base_multiplier > 0.0 \
			else BreakSystem.break_base(ctx.user)
	for entry in ctx.entries(scope):
		var target: BattleUnit = entry["unit"]
		if target.is_alive():
			ctx.events.append_array(ctx.battle.apply_status(status, ctx.user, target, base))
			if extend_if_self and target == ctx.user:
				var instance := target.get_status(status.id)
				if instance:
					instance.turns_left = status.duration_turns + 1
