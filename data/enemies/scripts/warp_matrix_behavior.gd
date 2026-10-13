extends EnemyBehavior
## Mẫu Thể Ma Biến: mỗi Mầm Ma Biến còn sống cho thêm Khiên Điểm Yếu; càng ít Mầm, khiên càng yếu.
## behavior_params: base_toughness, toughness_per_sprout, sprout_family.


func _on_battle_start() -> void:
	_refresh()


func _on_enemy_spawned(_unit: BattleUnit) -> void:
	_refresh()


func _on_unit_died(_unit: BattleUnit) -> void:
	_refresh()


func _refresh() -> void:
	if not owner.is_alive():
		return
	var params := owner.enemy.behavior_params
	var family := StringName(params.get("sprout_family", &"warp_sprout"))
	var sprouts := battle.enemies.filter(func(u: BattleUnit) -> bool:
		return u.is_alive() and u.enemy and u.enemy.family == family).size()
	var scale := battle.difficulty.toughness_multiplier if battle.difficulty else 1.0
	var new_max := (float(params.get("base_toughness", 60.0)) + float(params.get("toughness_per_sprout", 30.0)) * sprouts) * scale
	if is_equal_approx(new_max, owner.max_toughness):
		return
	var delta := new_max - owner.max_toughness
	owner.max_toughness = new_max
	if not owner.is_broken:
		# Mất Mầm thì khiên hiện tại giảm theo nhưng không tự Phá Vỡ.
		owner.toughness = clampf(owner.toughness + delta, 1.0, new_max)
	owner.toughness_changed.emit(owner)
