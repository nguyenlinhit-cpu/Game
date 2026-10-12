class_name SummonEffect
extends SkillEffect
## Triệu hồi vật đồng hành (không chiếm chỗ nhân vật). Chủ đã có vật triệu hồi thì làm mới số lượt,
## trừ khi only_if_absent (khi đó bỏ qua).

@export var name_key: String = ""
@export var letter: String = "?"
@export var color: Color = Color.WHITE
@export var speed: float = 80.0
@export var hp_ratio: float = 0.5
@export var skill: SkillData
@export var turns: int = 3
@export var only_if_absent: bool = false


func apply(ctx: SkillContext) -> void:
	if only_if_absent and ctx.battle.get_summon_of(ctx.user) != null:
		return
	var bonus := int(ctx.user.custom.get("summon_turns_bonus", 0))
	var unit := ctx.battle.add_summon(ctx.user, TranslationServer.translate(name_key), letter, color, speed,
			hp_ratio, skill, turns + bonus)
	ctx.events.append({"type": "summon", "target": unit, "amount": 0.0, "crit": false})
