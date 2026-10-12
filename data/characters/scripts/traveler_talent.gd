extends TalentScript
## Đặc tính "Cộng Hưởng Mảnh Hồn": mỗi lần Phá Vỡ khiên một quái, Tấn Công +20% trong 2 lượt (tối đa 2 tầng).
## E1: tối đa 3 tầng. E2: Đánh thường lên quái đang Phá Vỡ hồi 1 Điểm Chiến Kỹ (1 lần mỗi lượt).
## E4: dưới 50% máu thì Tăng sát thương +20%. E6: dùng Tuyệt kỹ xong được kéo lượt 30%.
## (E3, E5 tăng hệ số: khai báo trong EidolonData.)

const RESONANCE: StatusEffectData = preload("res://data/status_effects/soul_resonance.tres")
const RESONANCE_E1: StatusEffectData = preload("res://data/status_effects/soul_resonance_e1.tres")
const E4_DAMAGE_BONUS: float = 0.2
const E4_HP_THRESHOLD: float = 0.5
const E6_ADVANCE: float = 0.3

var _e2_used_turn: int = -1


func _on_weakness_broken(attacker: BattleUnit, _target: BattleUnit) -> void:
	if attacker == owner:
		report(give_status(RESONANCE_E1 if has_eidolon(1) else RESONANCE, owner))


func _on_before_damage(ctx: SkillContext, _target: BattleUnit, params: DamageCalc.Params) -> void:
	if ctx.user == owner and has_eidolon(4) and owner.get_hp_ratio() < E4_HP_THRESHOLD:
		params.damage_bonus += E4_DAMAGE_BONUS


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user != owner:
		return
	if has_eidolon(2) and ctx.get_kind() == SkillData.Kind.BASIC and ctx.main_target \
			and ctx.main_target.is_broken and _e2_used_turn != battle.turn_count:
		_e2_used_turn = battle.turn_count
		battle.change_skill_points(1)
		ctx.events.append({"type": "skill_point", "target": owner, "amount": 1.0, "crit": false})
	if has_eidolon(6) and ctx.get_kind() == SkillData.Kind.ULTIMATE:
		battle.queue.action_advance(owner, E6_ADVANCE)
		ctx.events.append({"type": "advance", "target": owner, "amount": E6_ADVANCE, "crit": false})
