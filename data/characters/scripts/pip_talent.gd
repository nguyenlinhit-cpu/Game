extends TalentScript
## Đặc tính "Pin Dự Phòng": đầu mỗi lượt của Pip, đồng minh có tỉ lệ năng lượng thấp nhất (trừ Pip) nhận 8 năng lượng.
## E1: 12 năng lượng. E2: sạc 2 đồng minh. E4: Sạc Nhanh còn kéo lượt mục tiêu 15%. E6: Quá Áp hoàn 1 Điểm Chiến Kỹ.

const CHARGE: float = 8.0
const CHARGE_E1: float = 12.0
const E4_ADVANCE: float = 0.15


func _on_turn_started(unit: BattleUnit) -> void:
	if unit != owner:
		return
	var candidates := battle.get_friends(owner).filter(func(a: BattleUnit) -> bool:
		return a != owner and a.max_energy > 0.0)
	candidates.sort_custom(func(a: BattleUnit, b: BattleUnit) -> bool:
		return a.energy / a.max_energy < b.energy / b.max_energy)
	var events: Array[Dictionary] = []
	var amount := CHARGE_E1 if has_eidolon(1) else CHARGE
	for ally: BattleUnit in candidates.slice(0, 2 if has_eidolon(2) else 1):
		ally.add_energy(amount)
		events.append({"type": "energy", "target": ally, "amount": amount, "crit": false})
	report(events)


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user != owner:
		return
	if ctx.get_kind() == SkillData.Kind.SKILL and has_eidolon(4) and ctx.main_target and battle.queue.has(ctx.main_target):
		battle.queue.action_advance(ctx.main_target, E4_ADVANCE)
		ctx.events.append({"type": "advance", "target": ctx.main_target, "amount": E4_ADVANCE, "crit": false})
	elif ctx.get_kind() == SkillData.Kind.ULTIMATE and has_eidolon(6):
		battle.change_skill_points(1)
		ctx.events.append({"type": "skill_point", "target": owner, "amount": 1.0, "crit": false})
