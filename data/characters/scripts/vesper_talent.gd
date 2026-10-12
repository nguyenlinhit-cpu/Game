extends TalentScript
## Đặc tính "Nọc Lan": quái mang Độc Vesper bị hạ thì Độc lan sang 2 quái bên cạnh với số lượt còn lại (tối thiểu 1).
## Tuyệt kỹ: mọi Độc Vesper lập tức gây thêm 25% sát thương một lượt.
## E1: Độc Vesper +20% sát thương. E2: quái mang Độc Vesper giảm 10% Kháng Hiệu Ứng. E4: Độc Vesper kéo dài 4 lượt.
## E6: Nọc Lan lan sang mọi quái còn lại.

const POISON: StatusEffectData = preload("res://data/status_effects/vesper_poison.tres")
const WEAKEN: StatusEffectData = preload("res://data/status_effects/vesper_weaken.tres")
const ULT_DETONATE: float = 0.25
const E1_BONUS: float = 1.2

var _spreading: bool = false


func _on_status_applied(source: BattleUnit, target: BattleUnit, instance: StatusEffectInstance) -> void:
	if source != owner or instance.data.id != POISON.id or _spreading:
		return
	# Gắn lại cùng hiệu ứng giữ nguyên instance, nên chỉ nhân 1 lần.
	if has_eidolon(1) and not instance.has_meta("e1"):
		instance.base_value *= E1_BONUS
		instance.set_meta("e1", true)
	if has_eidolon(4):
		instance.turns_left = POISON.duration_turns + 1
	if has_eidolon(2) and not target.has_status(WEAKEN.id):
		StatusEffects.apply(WEAKEN, owner, target)


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user == owner and ctx.get_kind() == SkillData.Kind.ULTIMATE:
		for enemy in battle.get_foes(owner):
			ctx.events.append_array(StatusEffects.detonate_dots(enemy, ULT_DETONATE, POISON.id))


func _on_unit_died(unit: BattleUnit) -> void:
	var instance := unit.get_status(POISON.id)
	if unit.is_ally() or instance == null:
		return
	var targets := _spread_targets(unit)
	var events: Array[Dictionary] = []
	_spreading = true
	for target in targets:
		var copy := StatusEffects.apply(POISON, owner, target, instance.base_value)
		copy.turns_left = maxi(instance.turns_left, 1)
		events.append({"type": "status_applied", "target": target, "amount": 1.0, "crit": false,
				"status": POISON.id, "name_key": POISON.name_key})
	_spreading = false
	report(events)


func _spread_targets(dead: BattleUnit) -> Array[BattleUnit]:
	var alive := battle.get_foes(owner)
	if has_eidolon(6):
		return alive
	var left: BattleUnit = null
	var right: BattleUnit = null
	for enemy in alive:
		if enemy.slot < dead.slot and (left == null or enemy.slot > left.slot):
			left = enemy
		elif enemy.slot > dead.slot and (right == null or enemy.slot < right.slot):
			right = enemy
	var result: Array[BattleUnit] = []
	for unit in [left, right]:
		if unit:
			result.append(unit)
	return result
