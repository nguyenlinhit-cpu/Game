class_name BreakSystem
extends RefCounted
## Khiên Điểm Yếu và Phá Vỡ (mục 5, 6). Chỉ đòn đúng nguyên tố điểm yếu mới giảm khiên.
## Khiên về 0 → Phá Vỡ: sát thương phá vỡ, trì hoãn 25% (+ trì hoãn thêm của hiệu ứng),
## gắn hiệu ứng theo nguyên tố. Khiên hồi đầy ở đầu lượt kế tiếp của quái.

const CONFIG_PATH: String = "res://data/config/break_config.tres"

static var _config: BreakConfig


static func config() -> BreakConfig:
	if _config == null:
		_config = load(CONFIG_PATH) as BreakConfig
	return _config


## Giá trị nền cho sát thương phá vỡ và hiệu ứng phá vỡ của người tấn công.
static func break_base(attacker: BattleUnit) -> float:
	return config().level_value(attacker.level) * (1.0 + attacker.stats.get_value(Stats.Type.BREAK_EFFECT))


## Giảm khiên nếu đúng điểm yếu; về 0 thì Phá Vỡ. Trả về sự kiện.
static func apply_toughness_damage(battle: BattleController, attacker: BattleUnit, target: BattleUnit,
		element: int, amount: float) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if amount <= 0.0 or not target.is_alive() or not target.has_toughness() or target.is_broken \
			or not target.is_weak_to(element):
		return events
	var reduced := target.reduce_toughness(amount)
	events.append({"type": "toughness", "target": target, "amount": reduced, "crit": false, "element": element})
	if target.toughness <= 0.0:
		events.append_array(trigger_break(battle, attacker, target, element))
	return events


static func trigger_break(battle: BattleController, attacker: BattleUnit, target: BattleUnit,
		element: int) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var cfg := config()
	target.is_broken = true
	target.broken_since_turn = true
	if target.charge:
		target.charge.broken = true
	target.toughness_changed.emit(target)
	var base := break_base(attacker)
	var raw := base * cfg.element_multiplier(element) * cfg.toughness_factor(target.max_toughness)
	var amount := target.take_damage(StatusEffects.effect_damage(raw, element, attacker.level, target))
	events.append({"type": "break", "target": target, "amount": amount, "crit": false, "element": element})
	EventBus.weakness_broken.emit(attacker, target)
	if battle.queue.has(target):
		battle.queue.delay(target, cfg.break_delay)
	var effect := cfg.get_break_effect(element)
	if effect and target.is_alive():
		events.append_array(battle.apply_status(effect, attacker, target, base))
	return events
