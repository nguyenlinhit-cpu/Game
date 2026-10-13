extends EnemyBehavior
## Lõi Lò Biến Dạng: đầu mỗi lượt tích 1 tầng Nhiệt (tay máy "Nạp Nhiệt" thêm 1 tầng). Đủ tầng thì AI dùng
## đòn Quá Nhiệt (báo trước, nổ cả đội, xả hết Nhiệt). Bị Phá Vỡ: mất 3 tầng.
## Sang giai đoạn 2: dựng lại tay máy đã hỏng.
## behavior_params: heat_status, heat_per_turn, break_heat_loss, stoke_skill_id, arm_enemy, arm_count.


func _on_turn_started(unit: BattleUnit) -> void:
	if unit == owner and owner.is_alive():
		_add_heat(int(owner.enemy.behavior_params.get("heat_per_turn", 1)))


func _on_weakness_broken(_attacker: BattleUnit, target: BattleUnit) -> void:
	if target == owner:
		_add_heat(-int(owner.enemy.behavior_params.get("break_heat_loss", 3)))


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.skill and ctx.skill.id == StringName(owner.enemy.behavior_params.get("stoke_skill_id", &"")) \
			and ctx.user != owner and not ctx.user.is_ally() and owner.is_alive():
		_add_heat(1)


func _on_phase_changed(_index: int, _data: BossPhaseData) -> void:
	var params := owner.enemy.behavior_params
	var arm := params.get("arm_enemy") as EnemyData
	if arm == null:
		return
	var alive := battle.enemies.filter(func(u: BattleUnit) -> bool: return u.is_alive() and u.enemy == arm).size()
	var events: Array[Dictionary] = []
	for i in maxi(int(params.get("arm_count", 2)) - alive, 0):
		var unit := battle.spawn_enemy(arm, owner.level)
		if unit:
			events.append({"type": "summon", "target": unit, "amount": 0.0, "crit": false})
	report(events)


func _add_heat(amount: int) -> void:
	var heat := owner.enemy.behavior_params.get("heat_status") as StatusEffectData
	if heat == null or amount == 0:
		return
	var before := get_stacks(heat.id)
	var after := add_stacks(heat, amount)
	if after != before:
		report([{"type": "heat", "target": owner, "amount": float(after), "crit": false, "name_key": heat.name_key}])
