class_name HealEffect
extends SkillEffect
## Hồi máu = (chỉ số × hệ số + số cố định) × (1 + Tăng Trị Liệu người hồi).

enum Source { USER_STAT, TARGET_MAX_HP }

@export var source: Source = Source.USER_STAT
@export var scaling_stat: Stats.Type = Stats.Type.ATK
@export var multiplier: float = 0.0
@export var flat: float = 0.0


func apply(ctx: SkillContext) -> void:
	for entry in ctx.entries(scope):
		var target: BattleUnit = entry["unit"]
		var base := ctx.user.stats.get_value(scaling_stat) if source == Source.USER_STAT else target.get_max_hp()
		ctx.heal(target, (base * multiplier) * ctx.get_multiplier_scale() + flat)
