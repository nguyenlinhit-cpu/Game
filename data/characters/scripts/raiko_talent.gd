extends TalentScript
## Đặc tính "Mắt Thợ Săn": quái mang Dấu Sấm nhận thêm 25% Sát thương bạo kích từ Raiko; Tuyệt kỹ lên quái mang dấu
## +60% hệ số. Quái mang dấu bị hạ thì dấu chuyển sang quái máu cao nhất và Raiko được kéo lượt 50%.
## E1: dấu kéo dài thêm 1 lượt. E2: +15% Tỉ Lệ Bạo Kích lên quái mang dấu. E4: kéo lượt 75%.
## E6: Tuyệt kỹ lên quái mang dấu đánh thêm 60% Tấn Công.

const MARK: StatusEffectData = preload("res://data/status_effects/raiko_mark.tres")
const CRIT_DMG_BONUS: float = 0.25
const E2_CRIT_RATE: float = 0.15
const ULT_MARK_BONUS: float = 0.6
const ADVANCE: float = 0.5
const ADVANCE_E4: float = 0.75
const E6_EXTRA: float = 0.6


func _on_before_damage(ctx: SkillContext, target: BattleUnit, params: DamageCalc.Params) -> void:
	if ctx.user != owner or not target.has_status(MARK.id):
		return
	params.crit_dmg += CRIT_DMG_BONUS
	if has_eidolon(2):
		params.crit_rate += E2_CRIT_RATE
	if ctx.get_kind() == SkillData.Kind.ULTIMATE:
		params.multiplier += ULT_MARK_BONUS * ctx.get_multiplier_scale()


func _on_status_applied(source: BattleUnit, _target: BattleUnit, instance: StatusEffectInstance) -> void:
	if has_eidolon(1) and source == owner and instance.data.id == MARK.id:
		instance.turns_left = MARK.duration_turns + 1


func _on_skill_resolved(ctx: SkillContext) -> void:
	if has_eidolon(6) and ctx.user == owner and ctx.get_kind() == SkillData.Kind.ULTIMATE \
			and ctx.main_target and ctx.main_target.is_alive() and ctx.main_target.has_status(MARK.id):
		ctx.deal_damage(ctx.main_target, Stats.Type.ATK, E6_EXTRA)


func _on_unit_died(unit: BattleUnit) -> void:
	if unit.is_ally() or not unit.has_status(MARK.id):
		return
	var next: BattleUnit = null
	for enemy in battle.get_foes(owner):
		if enemy != unit and (next == null or enemy.hp > next.hp):
			next = enemy
	var events: Array[Dictionary] = []
	if next:
		events.append_array(give_status(MARK, next))
	if owner.is_alive() and battle.queue.has(owner):
		var amount := ADVANCE_E4 if has_eidolon(4) else ADVANCE
		battle.queue.action_advance(owner, amount)
		events.append({"type": "advance", "target": owner, "amount": amount, "crit": false})
	report(events)
