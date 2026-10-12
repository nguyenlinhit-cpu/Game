class_name Stats
extends RefCounted
## Chỉ số của một đơn vị trong trận: giá trị gốc theo cấp + các bộ điều chỉnh (buff/debuff).
## Giá trị cuối = gốc × (1 + tổng % cộng thêm) + tổng cộng thẳng.
## Các chỉ số dạng tỉ lệ (bạo kích, hồi năng lượng...) lưu dạng số thập phân (0,05 = 5%)
## và nên dùng bộ điều chỉnh cộng thẳng.

## 11 chỉ số ở mục 5, sau đó là các hệ số chiến đấu dùng trong công thức sát thương.
enum Type {
	HP, ATK, DEF, SPD,
	CRIT_RATE, CRIT_DMG, BREAK_EFFECT, ENERGY_REGEN, EFFECT_HIT, EFFECT_RES, OUTGOING_HEALING,
	DAMAGE_BONUS, VULNERABILITY, DEF_REDUCTION, RES,
}

const CORE_STAT_COUNT: int = 11
const NAME_KEYS: Dictionary = {
	Type.HP: "STAT_HP", Type.ATK: "STAT_ATK", Type.DEF: "STAT_DEF", Type.SPD: "STAT_SPD",
	Type.CRIT_RATE: "STAT_CRIT_RATE", Type.CRIT_DMG: "STAT_CRIT_DMG", Type.BREAK_EFFECT: "STAT_BREAK_EFFECT",
	Type.ENERGY_REGEN: "STAT_ENERGY_REGEN", Type.EFFECT_HIT: "STAT_EFFECT_HIT", Type.EFFECT_RES: "STAT_EFFECT_RES",
	Type.OUTGOING_HEALING: "STAT_OUTGOING_HEALING",
}

var level: int = 1

var _base: Dictionary = {}
## Mỗi phần tử: { "id": int, "source": StringName, "stat": Type, "flat": float, "percent": float }
var _modifiers: Array[Dictionary] = []
var _next_id: int = 1


## Tạo chỉ số theo cấp từ bảng cấp 1 và cấp 80 (xem StatBlock.value_at_level).
static func from_blocks(lv1: StatBlock, lv80: StatBlock, at_level: int) -> Stats:
	var stats := Stats.new()
	stats.level = at_level
	for type in CORE_STAT_COUNT:
		stats.set_base(type, StatBlock.value_at_level(lv1, lv80, type, at_level))
	return stats


func get_base(type: Type) -> float:
	return float(_base.get(type, 0.0))


func set_base(type: Type, value: float) -> void:
	_base[type] = value


func get_value(type: Type) -> float:
	var flat := 0.0
	var percent := 0.0
	for modifier in _modifiers:
		if modifier["stat"] == type:
			flat += modifier["flat"]
			percent += modifier["percent"]
	return get_base(type) * (1.0 + percent) + flat


## Thêm bộ điều chỉnh, trả về id để gỡ sau. `source` dùng để gỡ hết theo nguồn (vd. id hiệu ứng).
func add_modifier(type: Type, flat: float = 0.0, percent: float = 0.0, source: StringName = &"") -> int:
	var id := _next_id
	_next_id += 1
	_modifiers.append({"id": id, "source": source, "stat": type, "flat": flat, "percent": percent})
	return id


func remove_modifier(id: int) -> void:
	for i in range(_modifiers.size() - 1, -1, -1):
		if _modifiers[i]["id"] == id:
			_modifiers.remove_at(i)


func remove_source(source: StringName) -> void:
	for i in range(_modifiers.size() - 1, -1, -1):
		if _modifiers[i]["source"] == source:
			_modifiers.remove_at(i)


func get_modifier_count() -> int:
	return _modifiers.size()
