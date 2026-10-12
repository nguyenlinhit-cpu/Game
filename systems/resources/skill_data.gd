class_name SkillData
extends Resource
## Kỹ năng trong trận (Đánh thường, Chiến kỹ, Tuyệt kỹ, đòn phụ của Đặc tính đều là SkillData).
## Nội dung là danh sách hiệu ứng ghép (`effects`, chạy lần lượt): sát thương, hồi máu, khiên,
## buff/debuff, kéo/đẩy lượt, năng lượng, Điểm Chiến Kỹ, khiêu khích (buff có taunt), giải hiệu ứng.
## Nguyên tố đòn đánh = nguyên tố người dùng.

enum Kind { BASIC, SKILL, ULTIMATE, FOLLOW_UP }
## "ENEMY" = phe đối địch của người dùng, "ALLY" = phe mình (quái dùng thì ngược lại).
enum Target { SINGLE_ENEMY, BLAST_ENEMY, ALL_ENEMIES, SINGLE_ALLY, ALL_ALLIES, SELF }

@export var id: StringName
@export var name_key: String = ""
@export var desc_key: String = ""
@export var kind: Kind = Kind.BASIC
@export var target: Target = Target.SINGLE_ENEMY
## Được chọn chính mình làm mục tiêu (với kỹ năng nhắm đồng minh).
@export var can_target_self: bool = true
@export var effects: Array[SkillEffect] = []

@export_group("Tài nguyên")
## Đánh thường +1, Chiến kỹ −1, Tuyệt kỹ 0.
@export var sp_change: int = 0
@export var energy_gain: float = 0.0

@export_group("Chế độ khác")
## Kiểu thay thế của cùng kỹ năng (vd. Tuyệt kỹ nhân vật chính: đơn mục tiêu / lan).
@export var alternate: SkillData


func is_ally_targeted() -> bool:
	return target in [Target.SINGLE_ALLY, Target.ALL_ALLIES, Target.SELF]


func needs_target_choice() -> bool:
	return target in [Target.SINGLE_ENEMY, Target.BLAST_ENEMY, Target.SINGLE_ALLY]


func get_effects_of(script: Script) -> Array[SkillEffect]:
	var result: Array[SkillEffect] = []
	for effect in effects:
		if effect and effect.get_script() == script:
			result.append(effect)
	return result


func deals_damage() -> bool:
	return not get_effects_of(DamageEffect).is_empty()


func heals() -> bool:
	return not get_effects_of(HealEffect).is_empty()


func gives_shield() -> bool:
	return not get_effects_of(ShieldEffect).is_empty()


## Tổng phần kéo lượt lên mục tiêu đồng minh (cho Tự Động và xem trước).
func get_action_advance() -> float:
	var total := 0.0
	for effect in get_effects_of(TurnShiftEffect):
		var shift := effect as TurnShiftEffect
		if shift.amount > 0.0:
			total += shift.amount
	return total


## Kỹ năng chỉ gây sát thương đơn giản (dùng trong test và dữ liệu nhanh).
static func simple_damage(multiplier: float, toughness: float = 0.0,
		skill_target: Target = Target.SINGLE_ENEMY, skill_kind: Kind = Kind.BASIC) -> SkillData:
	var skill := SkillData.new()
	skill.id = &"simple_damage"
	skill.name_key = "SKILL_TRAVELER_BASIC"
	skill.kind = skill_kind
	skill.target = skill_target
	var damage := DamageEffect.new()
	damage.multiplier = multiplier
	damage.toughness = toughness
	skill.effects = [damage]
	return skill
