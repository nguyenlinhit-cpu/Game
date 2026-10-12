extends TalentScript
## Đặc tính "Gió Dây Chuyền": đồng minh được Thuận Buồm kết thúc lượt thì đồng minh đứng ngay sau trong thứ tự lượt
## được kéo lượt 25%.
## E1: vào trận Zephyra kéo lượt 30%. E2: dây chuyền kéo 35%. E4: Thuận Buồm cho đồng minh thêm 12 năng lượng.
## E6: Trời Lộng Gió hoàn 1 Điểm Chiến Kỹ.

const CHAIN: float = 0.25
const CHAIN_E2: float = 0.35
const E1_ADVANCE: float = 0.3
const E4_ENERGY: float = 12.0

var _tailwind_targets: Array[BattleUnit] = []


func _on_battle_start() -> void:
	if has_eidolon(1) and battle.queue.has(owner):
		battle.queue.action_advance(owner, E1_ADVANCE)
		report([{"type": "advance", "target": owner, "amount": E1_ADVANCE, "crit": false}])


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user != owner:
		return
	if ctx.get_kind() == SkillData.Kind.SKILL and ctx.main_target:
		if not _tailwind_targets.has(ctx.main_target):
			_tailwind_targets.append(ctx.main_target)
		if has_eidolon(4):
			ctx.main_target.add_energy(E4_ENERGY)
			ctx.events.append({"type": "energy", "target": ctx.main_target, "amount": E4_ENERGY, "crit": false})
	elif ctx.get_kind() == SkillData.Kind.ULTIMATE and has_eidolon(6):
		battle.change_skill_points(1)
		ctx.events.append({"type": "skill_point", "target": owner, "amount": 1.0, "crit": false})


func _on_turn_ended(unit: BattleUnit) -> void:
	if not _tailwind_targets.has(unit):
		return
	_tailwind_targets.erase(unit)
	for entry in battle.queue.predict(battle.queue.units.size()):
		var next: BattleUnit = entry["unit"]
		if next != unit and next.is_ally() and not next.is_summon:
			var amount := CHAIN_E2 if has_eidolon(2) else CHAIN
			battle.queue.action_advance(next, amount)
			report([{"type": "advance", "target": next, "amount": amount, "crit": false}])
			return
