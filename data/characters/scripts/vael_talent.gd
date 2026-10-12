extends TalentScript
## Đặc tính "Khán Giả Bị Bỏ Bùa": sát thương của Vael lên mỗi quái +12% cho mỗi hiệu ứng xấu quái đó đang mang (tối đa 5).
## E1: Màn Sương Tím có 50% gắn Giảm Phòng Thủ 10% (2 lượt). E2: tính tối đa 6 hiệu ứng. E4: Đêm Diễn Cuối hoàn 15 năng lượng.
## E6: mỗi hiệu ứng xấu +16%.

const DEF_DOWN: StatusEffectData = preload("res://data/status_effects/vael_def_down.tres")
const PER_DEBUFF: float = 0.12
const PER_DEBUFF_E6: float = 0.16
const E4_ENERGY: float = 15.0


func _on_before_damage(ctx: SkillContext, target: BattleUnit, params: DamageCalc.Params) -> void:
	if ctx.user != owner:
		return
	var count := mini(target.count_debuffs(), 6 if has_eidolon(2) else 5)
	params.damage_bonus += count * (PER_DEBUFF_E6 if has_eidolon(6) else PER_DEBUFF)


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user != owner:
		return
	if ctx.get_kind() == SkillData.Kind.SKILL and has_eidolon(1):
		for enemy in battle.get_foes(owner):
			ctx.events.append_array(battle.apply_status(DEF_DOWN, owner, enemy))
	elif ctx.get_kind() == SkillData.Kind.ULTIMATE and has_eidolon(4):
		owner.add_energy(E4_ENERGY)
