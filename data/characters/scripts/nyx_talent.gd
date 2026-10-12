extends TalentScript
## Đặc tính "Mạch Khuếch Đại": Đánh thường của Nyx lên quái đang chịu sát thương theo lượt
## kích nổ ngay mọi sát thương theo lượt trên quái đó với 50% giá trị (không trừ số lượt).
## E1: kích nổ 75%. E2: Đánh thường giảm 10% Tốc Độ quái 1 lượt. E4: Bão Từ gắn thêm Rò Điện lên mọi quái.
## (E3, E5 tăng hệ số, E6 +20% Chính Xác Hiệu Ứng: khai báo trong EidolonData.)

const SLOW: StatusEffectData = preload("res://data/status_effects/nyx_slow.tres")
const LEAK: StatusEffectData = preload("res://data/status_effects/nyx_leak.tres")
const DETONATE_RATIO: float = 0.5
const DETONATE_RATIO_E1: float = 0.75


func _on_after_damage(ctx: SkillContext, target: BattleUnit, _amount: float, _crit: bool) -> void:
	if ctx.user != owner or ctx.get_kind() != SkillData.Kind.BASIC or not target.is_alive():
		return
	ctx.events.append_array(StatusEffects.detonate_dots(target, DETONATE_RATIO_E1 if has_eidolon(1) else DETONATE_RATIO))
	if has_eidolon(2) and target.is_alive():
		ctx.events.append_array(give_status(SLOW, target))


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user == owner and ctx.get_kind() == SkillData.Kind.ULTIMATE and has_eidolon(4):
		var base := owner.stats.get_value(Stats.Type.ATK)
		for enemy in battle.get_foes(owner):
			ctx.events.append_array(give_status(LEAK, enemy, base))
