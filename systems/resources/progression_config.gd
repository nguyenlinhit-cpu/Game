class_name ProgressionConfig
extends Resource
## Bảng tiến trình dùng chung: EXP từng cấp, đột phá, chi phí và hệ số cấp kỹ năng, giới hạn cấp kỹ năng
## theo số lần đột phá. Giới hạn cấp nằm ở GameConfig.MAX_LEVEL (một chỗ duy nhất).

const PATH: String = "res://data/config/progression.tres"

## exp_to_next[i] = EXP cần để lên từ cấp i+1 lên cấp i+2 (dài tới cấp 80).
@export var exp_to_next: PackedInt32Array = PackedInt32Array()
## Mỗi EXP nạp vào tốn chừng này Xu Aether.
@export var coin_per_exp: float = 0.1
@export var ascensions: Array[AscensionData] = []
## Cấp kỹ năng tối đa theo số lần đột phá: [0 lần, 1 lần, 2 lần, ...].
@export var skill_cap_by_ascension: PackedInt32Array = PackedInt32Array([2, 4, 5])
@export var max_skill_level: int = 5
## Chi phí cấp 2..5 (dùng chung cho Đánh thường, Chiến kỹ, Tuyệt kỹ, Đặc tính).
@export var skill_costs: Array[SkillLevelCost] = []
## Hệ số nhân sát thương/hồi máu/khiên theo cấp kỹ năng (phần tử 0 = cấp 1).
@export var skill_multiplier_scale: PackedFloat32Array = PackedFloat32Array([1.0, 1.1, 1.2, 1.3, 1.4])
## Hệ số độ mạnh buff/debuff do kỹ năng gắn theo cấp kỹ năng.
@export var skill_status_scale: PackedFloat32Array = PackedFloat32Array([1.0, 1.05, 1.1, 1.15, 1.2])

static var _cached: ProgressionConfig


static func get_config() -> ProgressionConfig:
	if _cached == null:
		_cached = load(PATH) as ProgressionConfig
	return _cached


## EXP cần để lên từ `level` lên `level + 1` (0 nếu không có dữ liệu).
func exp_for_level(level: int) -> int:
	var index := level - 1
	return exp_to_next[index] if index >= 0 and index < exp_to_next.size() else 0


## Mốc đột phá ở cấp `level` (null nếu không có).
func get_ascension_at(level: int) -> AscensionData:
	for ascension in ascensions:
		if ascension.at_level == level:
			return ascension
	return null


## Giới hạn cấp hiện tại sau `count` lần đột phá (không vượt MAX_LEVEL).
func level_cap(count: int) -> int:
	var cap := ascensions[0].at_level if not ascensions.is_empty() else GameConfig.MAX_LEVEL
	for i in mini(count, ascensions.size()):
		cap = ascensions[i].new_cap
	return mini(cap, GameConfig.MAX_LEVEL)


func skill_cap(ascension_count: int) -> int:
	if skill_cap_by_ascension.is_empty():
		return max_skill_level
	return mini(skill_cap_by_ascension[clampi(ascension_count, 0, skill_cap_by_ascension.size() - 1)], max_skill_level)


func get_skill_cost(level: int) -> SkillLevelCost:
	for cost in skill_costs:
		if cost.level == level:
			return cost
	return null


func multiplier_scale(skill_level: int) -> float:
	return _at(skill_multiplier_scale, skill_level)


func status_scale(skill_level: int) -> float:
	return _at(skill_status_scale, skill_level)


static func _at(table: PackedFloat32Array, skill_level: int) -> float:
	if table.is_empty():
		return 1.0
	return table[clampi(skill_level - 1, 0, table.size() - 1)]
