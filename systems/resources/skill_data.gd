class_name SkillData
extends Resource
## Kỹ năng trong trận (TẠM cho Phase 4–5: sát thương, giảm khiên, hồi máu, kéo/đẩy lượt, Điểm Chiến Kỹ, năng lượng).
## Nguyên tố đòn đánh = nguyên tố của người dùng.
## Phase 6 đổi thành danh sách hiệu ứng ghép được (khiên, buff/debuff, khiêu khích...).

enum Kind { BASIC, SKILL, ULTIMATE }
## "ENEMY" = phe đối địch của người dùng, "ALLY" = phe mình (quái dùng thì ngược lại).
enum Target { SINGLE_ENEMY, BLAST_ENEMY, ALL_ENEMIES, SINGLE_ALLY, ALL_ALLIES, SELF }

@export var id: StringName
@export var name_key: String = ""
@export var desc_key: String = ""
@export var kind: Kind = Kind.BASIC
@export var target: Target = Target.SINGLE_ENEMY
## Được chọn chính mình làm mục tiêu (với kỹ năng nhắm đồng minh).
@export var can_target_self: bool = true

@export_group("Sát thương")
@export var scaling_stat: Stats.Type = Stats.Type.ATK
## Hệ số lên mục tiêu chính (hoặc mọi mục tiêu với ALL_ENEMIES).
@export var damage_multiplier: float = 0.0
## Hệ số lên 2 mục tiêu bên cạnh (BLAST_ENEMY).
@export var adjacent_multiplier: float = 0.0

## Lượng giảm Khiên Điểm Yếu lên mục tiêu chính (mọi mục tiêu với ALL_ENEMIES) và mục tiêu bên cạnh.
@export var toughness_damage: float = 0.0
@export var toughness_damage_adjacent: float = 0.0

@export_group("Hồi máu")
@export var heal_multiplier: float = 0.0
@export var heal_flat: float = 0.0

@export_group("Thứ tự lượt")
## Kéo lượt mục tiêu lên (0,5 = 50% quãng đường).
@export var action_advance: float = 0.0
## Đẩy lùi lượt mục tiêu chính.
@export var target_delay: float = 0.0

@export_group("Tài nguyên")
## Đánh thường +1, Chiến kỹ −1, Tuyệt kỹ 0.
@export var sp_change: int = 0
@export var energy_gain: float = 0.0


func is_ally_targeted() -> bool:
	return target in [Target.SINGLE_ALLY, Target.ALL_ALLIES, Target.SELF]


func needs_target_choice() -> bool:
	return target in [Target.SINGLE_ENEMY, Target.BLAST_ENEMY, Target.SINGLE_ALLY]


func deals_damage() -> bool:
	return damage_multiplier > 0.0 or adjacent_multiplier > 0.0


func heals() -> bool:
	return heal_multiplier > 0.0 or heal_flat > 0.0
