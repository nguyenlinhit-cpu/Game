extends TalentScript
## Đặc tính "Thư Tịch Hồn": Chiến kỹ tự tiêu thêm tối đa 2 Điểm Chiến Kỹ nếu có, mỗi điểm thêm cộng 50 điểm % vào hệ số (56% → tối đa 156%).
## Tuyệt kỹ: sau 200% toàn bộ quái, đánh thêm 3 lần 40% lên quái ngẫu nhiên.
## E1: mỗi điểm tiêu thêm hoàn 10 năng lượng. E2: tiêu thêm tối đa 3 điểm. E4: Tuyệt kỹ hoàn 1 Điểm Chiến Kỹ.
## E6: Chiến kỹ tiêu đủ điểm thì giảm khiên gấp đôi.

const EXTRA_MULTIPLIER: float = 0.5
const BOUNCE_HITS: int = 3
const BOUNCE_MULTIPLIER: float = 0.4
const E1_ENERGY: float = 10.0
const SKILL_TOUGHNESS: float = 10.0


func get_max_extra() -> int:
	return 3 if has_eidolon(2) else 2


func _on_before_damage(ctx: SkillContext, _target: BattleUnit, params: DamageCalc.Params) -> void:
	if ctx.user != owner or ctx.get_kind() != SkillData.Kind.SKILL:
		return
	if not ctx.custom.has("orrin_extra"):
		# Chiến kỹ tự trừ 1 điểm ở cuối kỹ năng; phần dư trên 1 điểm mới tiêu thêm được.
		var extra := clampi(battle.skill_points - 1, 0, get_max_extra())
		battle.change_skill_points(-extra)
		ctx.custom["orrin_extra"] = extra
		if has_eidolon(1) and extra > 0:
			owner.add_energy(E1_ENERGY * extra)
	params.multiplier += EXTRA_MULTIPLIER * int(ctx.custom["orrin_extra"]) * ctx.get_multiplier_scale()


func _on_after_damage(ctx: SkillContext, target: BattleUnit, _amount: float, _crit: bool) -> void:
	if has_eidolon(6) and ctx.user == owner and ctx.get_kind() == SkillData.Kind.SKILL \
			and int(ctx.custom.get("orrin_extra", 0)) >= get_max_extra() and target.is_alive():
		ctx.events.append_array(BreakSystem.apply_toughness_damage(battle, owner, target, ctx.element, SKILL_TOUGHNESS))


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user != owner or ctx.get_kind() != SkillData.Kind.ULTIMATE:
		return
	for i in BOUNCE_HITS:
		var foes := battle.get_foes(owner)
		if foes.is_empty():
			break
		ctx.deal_damage(foes[battle.rng.randi_range(0, foes.size() - 1)], Stats.Type.ATK, BOUNCE_MULTIPLIER, 5.0)
	if has_eidolon(4):
		battle.change_skill_points(1)
		ctx.events.append({"type": "skill_point", "target": owner, "amount": 1.0, "crit": false})
