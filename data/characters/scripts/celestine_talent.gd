extends TalentScript
## Đặc tính "Hai Tư Thế": Canh Giữ (Tốc Độ +20%, Đánh thường thêm 10 năng lượng) và Phán Xử (Sát thương bạo kích +50%,
## Tỉ Lệ Bạo Kích +15%, Đánh thường 160%). Đầu trận ở Canh Giữ. Chiến kỹ đổi tư thế: sang Phán Xử thì 280% lên 1 quái;
## về Canh Giữ thì kéo lượt bản thân 30%. Tuyệt kỹ đưa vào Phán Xử.
## E1: đổi tư thế +15 năng lượng. E2: Phán Xử Tăng sát thương +20%. E4: Canh Giữ hồi 8% máu tối đa đầu lượt.
## E6: Tuyệt kỹ bỏ qua 30% Phòng Thủ.

const WATCH: StatusEffectData = preload("res://data/status_effects/celestine_watch.tres")
const JUDGMENT: StatusEffectData = preload("res://data/status_effects/celestine_judgment.tres")
const JUDGMENT_E2: StatusEffectData = preload("res://data/status_effects/celestine_judgment_e2.tres")
const BASIC_JUDGMENT: SkillData = preload("res://data/skills/celestine_basic_judgment.tres")
const SKILL_JUDGMENT: SkillData = preload("res://data/skills/celestine_skill_judgment.tres")
const E1_ENERGY: float = 15.0
const E4_HEAL: float = 0.08
const E6_DEF_IGNORE: float = 0.3


func is_judgment() -> bool:
	return owner.has_status(JUDGMENT.id) or owner.has_status(JUDGMENT_E2.id)


func _on_battle_start() -> void:
	# Bí Kỹ "Lời Tiên Tri" có thể đã đưa vào Phán Xử trước khi Đặc tính chạy.
	set_stance(is_judgment(), false)


## Đổi tư thế: gắn trạng thái tương ứng và thay Đánh thường / Chiến kỹ.
func set_stance(judgment: bool, by_switch: bool = true) -> void:
	for data in [WATCH, JUDGMENT, JUDGMENT_E2]:
		var instance := owner.get_status(data.id)
		if instance:
			StatusEffects.remove(owner, instance)
	StatusEffects.apply((JUDGMENT_E2 if has_eidolon(2) else JUDGMENT) if judgment else WATCH, owner, owner)
	if judgment:
		owner.skill_overrides[SkillData.Kind.BASIC] = BASIC_JUDGMENT
		owner.skill_overrides[SkillData.Kind.SKILL] = SKILL_JUDGMENT
	else:
		owner.skill_overrides.erase(SkillData.Kind.BASIC)
		owner.skill_overrides.erase(SkillData.Kind.SKILL)
	if by_switch and has_eidolon(1):
		owner.add_energy(E1_ENERGY)


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user != owner:
		return
	match ctx.get_kind():
		SkillData.Kind.SKILL:
			set_stance(not is_judgment())
		SkillData.Kind.ULTIMATE:
			if not is_judgment():
				set_stance(true)


func _on_before_damage(ctx: SkillContext, _target: BattleUnit, params: DamageCalc.Params) -> void:
	if has_eidolon(6) and ctx.user == owner and ctx.get_kind() == SkillData.Kind.ULTIMATE:
		params.def_reduction += E6_DEF_IGNORE


func _on_turn_started(unit: BattleUnit) -> void:
	if unit == owner and has_eidolon(4) and not is_judgment():
		var ctx := make_context()
		ctx.heal(owner, owner.get_max_hp() * E4_HEAL)
		report(ctx.events)
