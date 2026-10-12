extends TalentScript
## Đặc tính "Nhẫn Nại": mỗi đòn không bạo kích, Neris +12% Tỉ Lệ Bạo Kích (cộng dồn); bạo kích thì mất hết.
## Tuyệt kỹ "Sóng Ngầm" chắc chắn bạo kích.
## E1: mỗi tầng +15%. E2: bạo kích khi đang có từ 3 tầng: +30% Sát thương bạo kích. E4: bạo kích hồi 8 năng lượng.
## E6: Sóng Ngầm bỏ qua 20% Phòng Thủ.

const PATIENCE: StatusEffectData = preload("res://data/status_effects/neris_patience.tres")
const PATIENCE_E1: StatusEffectData = preload("res://data/status_effects/neris_patience_e1.tres")
const E2_CRIT_DMG: float = 0.3
const E2_STACKS: int = 3
const E4_ENERGY: float = 8.0
const E6_DEF_IGNORE: float = 0.2


func _patience() -> StatusEffectData:
	return PATIENCE_E1 if has_eidolon(1) else PATIENCE


func get_stacks() -> int:
	var instance := owner.get_status(_patience().id)
	return instance.stacks if instance else 0


func _on_before_damage(ctx: SkillContext, _target: BattleUnit, params: DamageCalc.Params) -> void:
	if ctx.user != owner:
		return
	if ctx.get_kind() == SkillData.Kind.ULTIMATE:
		params.crit_rate = 1.0
		if has_eidolon(6):
			params.def_reduction += E6_DEF_IGNORE
	if has_eidolon(2) and get_stacks() >= E2_STACKS:
		params.crit_dmg += E2_CRIT_DMG


func _on_after_damage(ctx: SkillContext, _target: BattleUnit, _amount: float, crit: bool) -> void:
	if ctx.user != owner:
		return
	if crit:
		var instance := owner.get_status(_patience().id)
		if instance:
			StatusEffects.remove(owner, instance)
		if has_eidolon(4):
			owner.add_energy(E4_ENERGY)
	else:
		StatusEffects.apply(_patience(), owner, owner)
