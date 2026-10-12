class_name DifficultyConfig
extends Resource
## Mức khó cao hơn cho trận boss (bật được ở phòng thử / bảng đánh lại boss). Phần thưởng thêm làm ở Phase 10.

@export var name_key: String = "DIFFICULTY_HARD"
@export var level_bonus: int = 0
@export var hp_percent: float = 0.6
@export var atk_percent: float = 0.25
@export var spd_percent: float = 0.08
@export var effect_hit_flat: float = 0.1
@export var toughness_multiplier: float = 1.25
## Hệ số nguyên liệu rơi thêm (Phase 10 đọc).
@export var reward_multiplier: float = 2.0
