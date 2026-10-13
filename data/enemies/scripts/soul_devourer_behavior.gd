extends EnemyBehavior
## Kẻ Nuốt Mảnh Hồn.
## GĐ2: tách phân thân (mỗi con một bộ điểm yếu), bản thể không bị nhắm được cho tới khi hạ hết phân thân;
## mỗi phân thân ngã làm bản thể mất một phần máu. Hạ hết → GĐ3.
## GĐ3: đầu mỗi lượt xóa 1 Điểm Chiến Kỹ của phe ta.
## behavior_params: clones (Array[EnemyData]), clone_phase, clone_backlash, drain_phase.

var _clones: Array[BattleUnit] = []


func _on_phase_changed(index: int, _data: BossPhaseData) -> void:
	var params := owner.enemy.behavior_params
	if index == int(params.get("clone_phase", 1)):
		var events: Array[Dictionary] = []
		for data: EnemyData in params.get("clones", []):
			var unit := battle.spawn_enemy(data, owner.level)
			if unit:
				_clones.append(unit)
				events.append({"type": "summon", "target": unit, "amount": 0.0, "crit": false})
		owner.untargetable = not _clones.is_empty()
		report(events)
	else:
		owner.untargetable = false


func _on_unit_died(unit: BattleUnit) -> void:
	if not _clones.has(unit) or not owner.is_alive():
		return
	var params := owner.enemy.behavior_params
	var amount := owner.take_damage(owner.get_max_hp() * float(params.get("clone_backlash", 0.08)))
	var events: Array[Dictionary] = [{"type": "dot", "target": owner, "amount": amount, "crit": false,
			"element": Element.Type.SOUL}]
	if not _clones.any(func(u: BattleUnit) -> bool: return u.is_alive()):
		_clones.clear()
		owner.untargetable = false
		owner.forced_phase = owner.phase_index + 1
	report(events)


func _on_turn_started(unit: BattleUnit) -> void:
	if unit != owner or owner.phase_index < int(owner.enemy.behavior_params.get("drain_phase", 2)):
		return
	if battle.skill_points <= 0:
		return
	battle.change_skill_points(-1)
	report([{"type": "sp_lost", "target": owner, "amount": 1.0, "crit": false}])
