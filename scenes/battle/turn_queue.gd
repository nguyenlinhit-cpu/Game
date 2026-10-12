class_name TurnQueue
extends RefCounted
## Thứ tự lượt theo Giá trị Hành Động (GTHĐ) = Quãng đường còn lại / Tốc Độ, ai thấp nhất đi trước.
## Mỗi đơn vị chạy quãng đường 10000; tới đích là tới lượt, xong lượt quay về 10000.
## Lưu quãng đường (không lưu GTHĐ) nên đổi Tốc Độ giữa trận tự đúng: GTHĐ mới = quãng còn lại / tốc mới.
## Hòa GTHĐ: ai nhanh hơn đi trước, rồi phe ta trước quái, rồi theo thứ tự vào trận.

const BASE_DISTANCE: float = 10000.0
const EPSILON: float = 0.0001

var units: Array[BattleUnit] = []
## Tổng GTHĐ đã trôi qua từ đầu trận.
var elapsed: float = 0.0

var _order: Dictionary = {}
var _next_order: int = 0


func add(unit: BattleUnit, start_distance: float = BASE_DISTANCE) -> void:
	if units.has(unit):
		return
	unit.distance_left = start_distance
	units.append(unit)
	_order[unit] = _next_order
	_next_order += 1


func remove(unit: BattleUnit) -> void:
	units.erase(unit)
	_order.erase(unit)


func has(unit: BattleUnit) -> bool:
	return units.has(unit)


func peek_next() -> BattleUnit:
	var best: BattleUnit = null
	for unit in units:
		if best == null or _comes_before(unit, unit.distance_left, best, best.distance_left):
			best = unit
	return best


## Cho thời gian trôi tới lượt kế tiếp, trả về đơn vị tới lượt.
func advance_to_next() -> BattleUnit:
	var next := peek_next()
	if next == null:
		return null
	var time := next.get_action_value()
	for unit in units:
		unit.distance_left = maxf(unit.distance_left - time * unit.get_speed(), 0.0)
	next.distance_left = 0.0
	elapsed += time
	return next


func end_turn(unit: BattleUnit) -> void:
	unit.distance_left = BASE_DISTANCE


## Kéo lượt lên `fraction` (0,5 = 50% quãng đường), không âm.
func action_advance(unit: BattleUnit, fraction: float) -> void:
	unit.distance_left = maxf(unit.distance_left - BASE_DISTANCE * fraction, 0.0)


## Trì hoãn lượt thêm `fraction` quãng đường.
func delay(unit: BattleUnit, fraction: float) -> void:
	unit.distance_left += BASE_DISTANCE * fraction


## Dự đoán `count` lượt tới. `acting`: đơn vị đang trong lượt (coi như đã xong lượt).
## `distance_overrides`: { BattleUnit: quãng đường } để xem trước hiệu ứng kéo/đẩy lượt.
## Trả về [{ "unit": BattleUnit, "time": GTHĐ tính từ bây giờ }].
func predict(count: int, acting: BattleUnit = null, distance_overrides: Dictionary = {}) -> Array[Dictionary]:
	var distances: Dictionary = {}
	for unit in units:
		distances[unit] = unit.distance_left
	if acting and distances.has(acting):
		distances[acting] = BASE_DISTANCE
	for unit: BattleUnit in distance_overrides:
		if distances.has(unit):
			distances[unit] = distance_overrides[unit]
	var result: Array[Dictionary] = []
	var time := 0.0
	while result.size() < count and not units.is_empty():
		var best: BattleUnit = null
		for unit in units:
			if best == null or _comes_before(unit, distances[unit], best, distances[best]):
				best = unit
		var step: float = distances[best] / best.get_speed()
		for unit in units:
			distances[unit] = maxf(distances[unit] - step * unit.get_speed(), 0.0)
		time += step
		result.append({"unit": best, "time": time})
		distances[best] = BASE_DISTANCE
	return result


func _comes_before(a: BattleUnit, a_distance: float, b: BattleUnit, b_distance: float) -> bool:
	var av_a := a_distance / a.get_speed()
	var av_b := b_distance / b.get_speed()
	if absf(av_a - av_b) > EPSILON:
		return av_a < av_b
	if absf(a.get_speed() - b.get_speed()) > EPSILON:
		return a.get_speed() > b.get_speed()
	if a.side != b.side:
		return a.side == BattleUnit.Faction.ALLY
	return int(_order.get(a, 0)) < int(_order.get(b, 0))
