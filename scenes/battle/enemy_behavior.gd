class_name EnemyBehavior
extends TalentScript
## Cơ chế riêng của quái/boss (tích Nhiệt, khiên theo số Mầm, phân thân...). Gắn khi quái xuất hiện
## (EnemyData.behavior_script), dùng chung móc với TalentScript; `owner` là quái.
## Thêm móc: _on_phase_changed (boss sang giai đoạn mới), _on_charge_interrupted (đòn tích tụ bị ngắt).


func attach(p_battle: BattleController, p_owner: BattleUnit, p_eidolon_level: int) -> void:
	_connect(p_battle.boss_phase_started, func(unit: BattleUnit, index: int, data: BossPhaseData) -> void:
		if unit == p_owner:
			_on_phase_changed(index, data))
	_connect(p_battle.charge_interrupted, func(unit: BattleUnit, action: EnemyAction) -> void:
		if unit == p_owner:
			_on_charge_interrupted(action))
	_connect(p_battle.enemy_spawned, _on_enemy_spawned)
	super.attach(p_battle, p_owner, p_eidolon_level)


## Gắn/cộng tầng hiệu ứng lên quái này (chắc chắn trúng). Trả về số tầng sau khi gắn.
func add_stacks(data: StatusEffectData, amount: int) -> int:
	var instance := owner.get_status(data.id)
	if instance == null:
		instance = StatusEffects.apply(data, owner, owner)
		amount -= 1
	instance.stacks = clampi(instance.stacks + amount, 0, data.max_stacks)
	if instance.stacks <= 0:
		StatusEffects.remove(owner, instance)
		return 0
	StatusEffects.refresh_modifiers(owner, instance)
	return instance.stacks


func get_stacks(status_id: StringName) -> int:
	var instance := owner.get_status(status_id)
	return instance.stacks if instance else 0


func _on_phase_changed(_index: int, _data: BossPhaseData) -> void:
	pass


func _on_charge_interrupted(_action: EnemyAction) -> void:
	pass


func _on_enemy_spawned(_unit: BattleUnit) -> void:
	pass
