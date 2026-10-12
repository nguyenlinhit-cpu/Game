class_name DamageCalc
extends RefCounted
## Công thức sát thương duy nhất của game (mục 5). Chỉnh số ở đây, không rải ở nơi khác.
##
## Sát thương = Chỉ số gốc × Hệ số kỹ năng × (1 + Tăng sát thương%) × Hệ số bạo kích
##              × Hệ số phòng thủ × (1 − Kháng%) × (1 + Dễ tổn thương%) × Hệ số phá vỡ
## Hệ số phòng thủ = (Cấp ta + 20) / ((Cấp địch + 20) × (1 − Giảm phòng thủ%) + Cấp ta + 20)
## Hệ số phá vỡ = 0,9 khi mục tiêu còn khiên, 1,0 khi khiên đã vỡ (mục tiêu không có khiên: 1,0).
## Kết quả làm tròn xuống, tối thiểu 1 nếu có gây sát thương.

enum CritMode { ROLL, ALWAYS, NEVER }

const LEVEL_OFFSET: float = 20.0
const BREAK_FACTOR_SHIELDED: float = 0.9
const BREAK_FACTOR_BROKEN: float = 1.0


## Toàn bộ đầu vào của một lần tính sát thương.
class Params:
	var base_stat: float = 0.0
	var multiplier: float = 1.0
	var damage_bonus: float = 0.0
	var crit_rate: float = 0.0
	var crit_dmg: float = 0.0
	var attacker_level: int = 1
	var defender_level: int = 1
	var def_reduction: float = 0.0
	var res: float = 0.0
	var vulnerability: float = 0.0
	## Mục tiêu có thanh khiên (quái). Phase 5 nối với Khiên Điểm Yếu thật.
	var defender_has_toughness: bool = false
	var defender_broken: bool = false


static func defense_factor(attacker_level: int, defender_level: int, def_reduction: float = 0.0) -> float:
	var attacker := attacker_level + LEVEL_OFFSET
	var defender := (defender_level + LEVEL_OFFSET) * (1.0 - clampf(def_reduction, 0.0, 1.0))
	return attacker / (defender + attacker)


static func break_factor(has_toughness: bool, broken: bool) -> float:
	return BREAK_FACTOR_SHIELDED if has_toughness and not broken else BREAK_FACTOR_BROKEN


## Sát thương thô (số thực) khi đã biết có bạo kích hay không.
static func compute_raw(p: Params, is_crit: bool) -> float:
	var crit_factor := 1.0 + p.crit_dmg if is_crit else 1.0
	return p.base_stat * p.multiplier \
			* (1.0 + p.damage_bonus) \
			* crit_factor \
			* defense_factor(p.attacker_level, p.defender_level, p.def_reduction) \
			* (1.0 - clampf(p.res, -1.0, 1.0)) \
			* (1.0 + p.vulnerability) \
			* break_factor(p.defender_has_toughness, p.defender_broken)


static func finalize(raw: float) -> int:
	if raw <= 0.0:
		return 0
	return maxi(floori(raw), 1)


static func compute(p: Params, is_crit: bool) -> int:
	return finalize(compute_raw(p, is_crit))


## Tung bạo kích rồi tính. Trả về { "amount": int, "crit": bool }.
static func roll(p: Params, rng: RandomNumberGenerator, mode: CritMode = CritMode.ROLL) -> Dictionary:
	var is_crit := false
	match mode:
		CritMode.ALWAYS: is_crit = true
		CritMode.NEVER: is_crit = false
		_: is_crit = rng.randf() < clampf(p.crit_rate, 0.0, 1.0)
	return {"amount": compute(p, is_crit), "crit": is_crit}


## Sát thương kỳ vọng (dùng cho báo cáo cân bằng).
static func expected(p: Params) -> float:
	var rate := clampf(p.crit_rate, 0.0, 1.0)
	return compute_raw(p, false) * (1.0 - rate) + compute_raw(p, true) * rate
