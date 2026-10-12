extends TalentScript
## Đặc tính "Lốc Tích Tụ": mỗi lượt liên tiếp dùng Chiến kỹ, Xoáy Liềm +20% hệ số (tối đa 3 tầng); Đánh thường thì mất hết tầng.
## E1: đủ 3 tầng thì Xoáy Liềm hoàn 1 Điểm Chiến Kỹ. E2: Đánh thường chỉ mất 1 tầng. E4: mỗi tầng còn Tốc Độ +4%.
## E6: Cuồng Phong tính như 1 lần Chiến kỹ cho Lốc Tích Tụ.

const GALE: StatusEffectData = preload("res://data/status_effects/kestrel_gale.tres")
const GALE_E4: StatusEffectData = preload("res://data/status_effects/kestrel_gale_e4.tres")
const PER_STACK: float = 0.2
const MAX_STACKS: int = 3


func _gale() -> StatusEffectData:
	return GALE_E4 if has_eidolon(4) else GALE


func get_stacks() -> int:
	var instance := owner.get_status(_gale().id)
	return instance.stacks if instance else 0


func _on_before_damage(ctx: SkillContext, _target: BattleUnit, params: DamageCalc.Params) -> void:
	if ctx.user == owner and ctx.get_kind() == SkillData.Kind.SKILL:
		params.multiplier += PER_STACK * get_stacks() * ctx.get_multiplier_scale()


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user != owner:
		return
	var kind := ctx.get_kind()
	if kind == SkillData.Kind.SKILL or (has_eidolon(6) and kind == SkillData.Kind.ULTIMATE):
		if kind == SkillData.Kind.SKILL and has_eidolon(1) and get_stacks() >= MAX_STACKS:
			battle.change_skill_points(1)
			ctx.events.append({"type": "skill_point", "target": owner, "amount": 1.0, "crit": false})
		StatusEffects.apply(_gale(), owner, owner)
	elif kind == SkillData.Kind.BASIC:
		var instance := owner.get_status(_gale().id)
		if instance == null:
			return
		if has_eidolon(2) and instance.stacks > 1:
			instance.stacks -= 1
			StatusEffects.refresh_modifiers(owner, instance)
		else:
			StatusEffects.remove(owner, instance)
