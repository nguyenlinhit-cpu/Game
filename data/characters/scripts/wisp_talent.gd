extends TalentScript
## Đặc tính "Lời Thì Thầm": cuối lượt của quái mang từ 2 hiệu ứng xấu trở lên, Wisp trì hoãn lượt kế tiếp của quái đó 15%.
## E1: Chính Xác Hiệu Ứng +20% (EidolonData). E2: trì hoãn 20%. E4: Lãng Quên kéo dài 3 lượt.
## E6: chỉ cần 1 hiệu ứng xấu.

const FORGET: StatusEffectData = preload("res://data/status_effects/wisp_forget.tres")
const DELAY: float = 0.15
const DELAY_E2: float = 0.2


func _on_turn_ended(unit: BattleUnit) -> void:
	if unit.is_ally() or not unit.is_alive() or not owner.is_alive() or not battle.queue.has(unit):
		return
	if unit.count_debuffs() < (1 if has_eidolon(6) else 2):
		return
	var amount := DELAY_E2 if has_eidolon(2) else DELAY
	battle.queue.delay(unit, amount)
	report([{"type": "delay", "target": unit, "amount": amount, "crit": false}])


func _on_status_applied(source: BattleUnit, _target: BattleUnit, instance: StatusEffectInstance) -> void:
	if has_eidolon(4) and source == owner and instance.data.id == FORGET.id:
		instance.turns_left = FORGET.duration_turns + 1
