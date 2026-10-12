extends TalentScript
## Đặc tính "Cây Sự Sống": vật triệu hồi (không chiếm chỗ nhân vật, quái không nhắm), Tốc Độ 80, tồn tại 3 lượt của cây,
## mỗi lượt hồi đồng minh ít máu nhất 6% máu tối đa. Chiến kỹ gieo cây nếu chưa có; Tuyệt kỹ hồi sinh 1 lần mỗi trận.
## E1: cây tồn tại 4 lượt. E2: cây hồi thêm đồng minh ít máu thứ hai. E4: Vườn Hồi Sinh dùng được 2 lần.
## E6: đầu lượt cây giải 1 hiệu ứng xấu cho cả đội.

const TREE_HEAL_RATIO: float = 0.06


func _on_attach() -> void:
	if has_eidolon(1):
		owner.custom["summon_turns_bonus"] = 1
	if has_eidolon(4):
		owner.custom["revive_uses_bonus"] = 1


func _is_my_tree(unit: BattleUnit) -> bool:
	return unit != null and unit.is_summon and unit.summon_owner == owner


func _on_skill_resolved(ctx: SkillContext) -> void:
	if not has_eidolon(2) or not _is_my_tree(ctx.user):
		return
	var healed: BattleUnit = ctx.main_target
	var second: BattleUnit = null
	for ally in battle.get_friends(owner):
		if ally != healed and (second == null or ally.get_hp_ratio() < second.get_hp_ratio()):
			second = ally
	if second:
		ctx.heal(second, second.get_max_hp() * TREE_HEAL_RATIO)


func _on_turn_started(unit: BattleUnit) -> void:
	if not has_eidolon(6) or not _is_my_tree(unit):
		return
	var events: Array[Dictionary] = []
	for ally in battle.get_friends(owner):
		for i in range(ally.status_effects.size() - 1, -1, -1):
			if ally.status_effects[i].data.kind == StatusEffectData.Kind.DEBUFF:
				StatusEffects.remove(ally, ally.status_effects[i])
				events.append({"type": "cleanse", "target": ally, "amount": 1.0, "crit": false})
				break
	report(events)


func _is_mine(unit: Object) -> bool:
	return super(unit) or (unit is BattleUnit and battle.summons.has(unit))
