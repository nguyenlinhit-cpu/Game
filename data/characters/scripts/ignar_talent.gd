extends TalentScript
## Đặc tính "Lửa Trong Máu": mỗi lần tự tiêu máu +1 tầng Nhiệt Huyết (tối đa 5, Tăng sát thương +8%/tầng).
## Đủ 5 tầng: Chiến kỹ kế tiếp đánh toàn bộ quái (160%) rồi xóa tầng. Tuyệt kỹ hồi máu bằng 10% sát thương gây ra.
## E1: Chiến kỹ tiêu 10% máu (thay 15%). E2: mỗi tầng thêm 3% Tỉ Lệ Bạo Kích. E4: dưới 30% máu Phòng Thủ +40%.
## E6: Tuyệt kỹ cho ngay 5 tầng.

const FERVOR: StatusEffectData = preload("res://data/status_effects/ignar_fervor.tres")
const FERVOR_E2: StatusEffectData = preload("res://data/status_effects/ignar_fervor_e2.tres")
const IRON_SKIN: StatusEffectData = preload("res://data/status_effects/ignar_iron_skin.tres")
const ENHANCED_SKILL: SkillData = preload("res://data/skills/ignar_skill_enhanced.tres")
const MAX_STACKS: int = 5
const LIFESTEAL: float = 0.1
const E4_THRESHOLD: float = 0.3


func _fervor() -> StatusEffectData:
	return FERVOR_E2 if has_eidolon(2) else FERVOR


func _on_attach() -> void:
	if has_eidolon(1):
		# 15% × (1 − 1/3) = 10%.
		owner.custom["hp_cost_reduction"] = 1.0 / 3.0
	if has_eidolon(4):
		_connect(owner.hp_changed, _on_owner_hp_changed)


func get_stacks() -> int:
	var instance := owner.get_status(_fervor().id)
	return instance.stacks if instance else 0


func _on_hp_consumed(unit: BattleUnit, _amount: float) -> void:
	if unit != owner:
		return
	# Chiến kỹ cường hóa vừa dùng: hp_consumed chạy trước khi xóa tầng nên bỏ qua tầng này.
	if owner.skill_overrides.get(SkillData.Kind.SKILL) == ENHANCED_SKILL:
		return
	_add_stacks(1)


func _add_stacks(count: int) -> void:
	for i in count:
		StatusEffects.apply(_fervor(), owner, owner)
	if get_stacks() >= MAX_STACKS:
		owner.skill_overrides[SkillData.Kind.SKILL] = ENHANCED_SKILL


func _on_after_damage(ctx: SkillContext, _target: BattleUnit, amount: float, _crit: bool) -> void:
	if ctx.user == owner and ctx.get_kind() == SkillData.Kind.ULTIMATE and amount > 0.0:
		ctx.events.append({"type": "heal", "target": owner, "amount": owner.heal(amount * LIFESTEAL), "crit": false})


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user != owner:
		return
	if ctx.skill == ENHANCED_SKILL:
		var instance := owner.get_status(_fervor().id)
		if instance:
			StatusEffects.remove(owner, instance)
		owner.skill_overrides.erase(SkillData.Kind.SKILL)
	elif ctx.get_kind() == SkillData.Kind.ULTIMATE and has_eidolon(6):
		_add_stacks(MAX_STACKS)


func _on_owner_hp_changed(_unit: BattleUnit) -> void:
	var low := owner.is_alive() and owner.get_hp_ratio() < E4_THRESHOLD
	var instance := owner.get_status(IRON_SKIN.id)
	if low and instance == null:
		StatusEffects.apply(IRON_SKIN, owner, owner)
	elif not low and instance:
		StatusEffects.remove(owner, instance)
