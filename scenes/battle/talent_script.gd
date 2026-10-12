class_name TalentScript
extends RefCounted
## Lớp cơ sở cho Đặc tính (và Tinh Mệnh cần logic riêng). Mỗi nhân vật có một lớp con
## (data/characters/scripts/<id>_talent.gd) ghi đè các hàm _on_*.
## Gắn vào tín hiệu của EventBus (lọc theo trận của mình) và các móc của BattleController
## (before_damage/after_damage/before_heal/skill_resolved cho phép sửa số liệu tại chỗ).
## Tinh Mệnh dùng cùng cơ chế: kiểm tra has_eidolon(n) trong lớp con; Tinh Mệnh chỉ tăng số
## thì khai báo dữ liệu trong EidolonData (BattleController áp tự động).

var owner: BattleUnit
var battle: BattleController
var eidolon_level: int = 0

var _connections: Array[Array] = []


func attach(p_battle: BattleController, p_owner: BattleUnit, p_eidolon_level: int) -> void:
	battle = p_battle
	owner = p_owner
	eidolon_level = p_eidolon_level
	_connect(EventBus.turn_started, func(unit: Object) -> void:
		if _is_mine(unit):
			_on_turn_started(unit))
	_connect(EventBus.turn_ended, func(unit: Object) -> void:
		if _is_mine(unit):
			_on_turn_ended(unit))
	_connect(EventBus.weakness_broken, func(attacker: Object, target: Object) -> void:
		if _is_mine(attacker):
			_on_weakness_broken(attacker, target))
	_connect(EventBus.unit_died, func(unit: Object) -> void:
		if _is_mine(unit):
			_on_unit_died(unit))
	_connect(battle.battle_began, _on_battle_start)
	_connect(battle.before_damage, _on_before_damage)
	_connect(battle.after_damage, _on_after_damage)
	_connect(battle.before_heal, _on_before_heal)
	_connect(battle.skill_resolved, _on_skill_resolved)
	_on_attach()


func detach() -> void:
	for pair in _connections:
		var sig: Signal = pair[0]
		if sig.is_connected(pair[1]):
			sig.disconnect(pair[1])
	_connections.clear()


func has_eidolon(level: int) -> bool:
	return eidolon_level >= level


## Đơn vị thuộc trận này (EventBus là toàn cục).
func _is_mine(unit: Object) -> bool:
	return unit is BattleUnit and (battle.allies.has(unit) or battle.enemies.has(unit))


func _connect(sig: Signal, callable: Callable) -> void:
	sig.connect(callable)
	_connections.append([sig, callable])


## Báo sự kiện do Đặc tính tạo (giao diện hiện số, xử lý đơn vị ngã).
func report(events: Array[Dictionary]) -> void:
	if not events.is_empty():
		battle.report_events(owner, events)


## Gắn hiệu ứng chắc chắn (buff của Đặc tính), trả về sự kiện.
func give_status(data: StatusEffectData, target: BattleUnit, base_value: float = 0.0) -> Array[Dictionary]:
	return battle.apply_status(data, owner, target, base_value)


# --- Hàm để lớp con ghi đè ---

func _on_attach() -> void:
	pass


func _on_battle_start() -> void:
	pass


func _on_turn_started(_unit: BattleUnit) -> void:
	pass


func _on_turn_ended(_unit: BattleUnit) -> void:
	pass


func _on_weakness_broken(_attacker: BattleUnit, _target: BattleUnit) -> void:
	pass


func _on_unit_died(_unit: BattleUnit) -> void:
	pass


func _on_before_damage(_ctx: SkillContext, _target: BattleUnit, _params: DamageCalc.Params) -> void:
	pass


func _on_after_damage(_ctx: SkillContext, _target: BattleUnit, _amount: float, _crit: bool) -> void:
	pass


## `box["amount"]` sửa được.
func _on_before_heal(_ctx: SkillContext, _target: BattleUnit, _box: Dictionary) -> void:
	pass


func _on_skill_resolved(_ctx: SkillContext) -> void:
	pass
