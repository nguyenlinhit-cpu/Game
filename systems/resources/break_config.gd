class_name BreakConfig
extends Resource
## Số liệu Phá Vỡ (chỉnh trong data/config/break_config.tres).
## Sát thương phá vỡ = Mức phá vỡ theo cấp × (1 + Hiệu Ứng Phá Vỡ) × Hệ số nguyên tố × Hệ số khiên
##                     × Hệ số phòng thủ × (1 − Kháng) × (1 + Dễ tổn thương).
## Mức phá vỡ theo cấp = level_base + level_growth × (cấp − 1).
## Hệ số khiên = toughness_factor_base + khiên tối đa / toughness_factor_divisor.

@export var level_base: float = 50.0
@export var level_growth: float = 8.0
## Theo thứ tự Element.Type: Lửa, Nước, Sét, Phong, Độc, Mộc, Hồn.
@export var element_multipliers: PackedFloat32Array = PackedFloat32Array([2.0, 1.0, 1.0, 1.5, 1.0, 0.5, 0.5])
@export var toughness_factor_base: float = 0.5
@export var toughness_factor_divisor: float = 120.0
## Phá Vỡ trì hoãn lượt quái (0,25 = 25%).
@export var break_delay: float = 0.25
## Ưu Thế bằng Đòn Mở Màn đúng điểm yếu: quái mất chừng này phần khiên khi vào trận.
@export var advantage_toughness_loss: float = 0.25
## Hiệu ứng gắn khi Phá Vỡ, theo thứ tự Element.Type.
@export var break_effects: Array[StatusEffectData] = []


func level_value(level: int) -> float:
	return level_base + level_growth * (level - 1)


func toughness_factor(max_toughness: float) -> float:
	return toughness_factor_base + max_toughness / toughness_factor_divisor


func element_multiplier(element: int) -> float:
	return element_multipliers[element] if element >= 0 and element < element_multipliers.size() else 1.0


func get_break_effect(element: int) -> StatusEffectData:
	return break_effects[element] if element >= 0 and element < break_effects.size() else null
