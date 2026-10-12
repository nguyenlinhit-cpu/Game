extends TalentScript
## Đặc tính "Báo Thù": mỗi đồng minh ngã, Rook nhận 1 tầng Báo Thù vĩnh viễn trong trận (Tấn Công +25%, tối đa 3)
## và đầy năng lượng ngay. Tuyệt kỹ: mỗi tầng Báo Thù +40% hệ số.
## E1: vào trận có sẵn 1 tầng. E2: bị đánh trúng +8 năng lượng thêm. E4: mỗi tầng còn Phòng Thủ +10%.
## E6: một lần mỗi trận, khi ngã thì đứng dậy với 30% máu.

const REVENGE: StatusEffectData = preload("res://data/status_effects/rook_revenge.tres")
const REVENGE_E4: StatusEffectData = preload("res://data/status_effects/rook_revenge_e4.tres")
const ULT_BONUS: float = 0.4
const E2_ENERGY: float = 8.0
const E6_REVIVE: float = 0.3


func _revenge() -> StatusEffectData:
	return REVENGE_E4 if has_eidolon(4) else REVENGE


func get_stacks() -> int:
	var instance := owner.get_status(_revenge().id)
	return instance.stacks if instance else 0


func _on_battle_start() -> void:
	if has_eidolon(1):
		StatusEffects.apply(_revenge(), owner, owner)


func _on_unit_died(unit: BattleUnit) -> void:
	if not unit.is_ally() or unit.is_summon:
		return
	if unit == owner:
		if has_eidolon(6) and battle.try_use("rook_e6_%s" % owner.id, 1):
			report(battle.revive(owner, E6_REVIVE))
		return
	if not owner.is_alive():
		return
	StatusEffects.apply(_revenge(), owner, owner)
	owner.set_energy(owner.max_energy)
	report([{"type": "status_applied", "target": owner, "amount": float(get_stacks()), "crit": false,
			"status": _revenge().id, "name_key": _revenge().name_key}])


func _on_before_damage(ctx: SkillContext, _target: BattleUnit, params: DamageCalc.Params) -> void:
	if ctx.user == owner and ctx.get_kind() == SkillData.Kind.ULTIMATE:
		params.multiplier += ULT_BONUS * get_stacks() * ctx.get_multiplier_scale()


func _on_after_damage(ctx: SkillContext, target: BattleUnit, _amount: float, _crit: bool) -> void:
	if has_eidolon(2) and target == owner and not ctx.user.is_ally():
		owner.add_energy(E2_ENERGY)
