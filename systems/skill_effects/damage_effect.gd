class_name DamageEffect
extends SkillEffect
## Sát thương theo chỉ số người dùng, nguyên tố của người dùng; kèm giảm Khiên Điểm Yếu.

@export var scaling_stat: Stats.Type = Stats.Type.ATK
## Hệ số lên mục tiêu chính (mọi mục tiêu với scope không phải TARGETS).
@export var multiplier: float = 1.0
## Hệ số lên mục tiêu bên cạnh (kỹ năng lan).
@export var adjacent_multiplier: float = 0.0
@export var toughness: float = 0.0
@export var toughness_adjacent: float = 0.0


func apply(ctx: SkillContext) -> void:
	for entry in ctx.entries(scope):
		var main: bool = entry["main"]
		ctx.deal_damage(entry["unit"], scaling_stat, multiplier if main else adjacent_multiplier,
				toughness if main else toughness_adjacent)
