class_name ShieldEffect
extends SkillEffect
## Tạo khiên chặn sát thương = chỉ số người dùng × hệ số + số cố định, kéo dài theo hiệu ứng `status`.
## Mỗi đơn vị giữ khiên lớn nhất (không cộng dồn các khiên).

@export var scaling_stat: Stats.Type = Stats.Type.DEF
@export var multiplier: float = 0.0
@export var flat: float = 0.0
## Hiệu ứng khiên (StatusEffectData có shield = true) quyết định số lượt và biểu tượng.
@export var status: StatusEffectData


func apply(ctx: SkillContext) -> void:
	var amount := ctx.user.stats.get_value(scaling_stat) * multiplier * ctx.get_multiplier_scale() + flat
	for entry in ctx.entries(scope):
		ctx.give_shield(entry["unit"], amount, status)
