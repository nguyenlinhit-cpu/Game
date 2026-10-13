class_name RemoveStatusEffect
extends SkillEffect
## Gỡ một hiệu ứng theo id khỏi mục tiêu (vd. Xạ Thủ bắn xong thì gỡ Đánh Dấu, Lõi Lò nổ xong thì xả Nhiệt).

@export var status_id: StringName = &""
## Chỉ gỡ hiệu ứng do chính người dùng gắn.
@export var only_own: bool = true


func apply(ctx: SkillContext) -> void:
	for entry in ctx.entries(scope):
		var target: BattleUnit = entry["unit"]
		var instance := target.get_status(status_id)
		if instance and (not only_own or instance.source == ctx.user or target == ctx.user):
			StatusEffects.remove(target, instance)
