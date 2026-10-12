class_name EidolonData
extends Resource
## Một Tinh Mệnh. Phần tăng số đơn giản khai báo ở đây (BattleController áp tự động khi cấp Tinh Mệnh đủ);
## phần cơ chế riêng nằm trong TalentScript của nhân vật (has_eidolon(n)) hoặc `script_class` riêng.

@export var name_key: String = ""
@export var desc_key: String = ""
## Cộng thêm vào hệ số các loại kỹ năng (0,15 = +15%), áp cho sát thương, hồi máu, khiên.
@export var multiplier_bonus: float = 0.0
@export var bonus_kinds: Array[SkillData.Kind] = []
@export var stat_modifiers: Array[StatModifierData] = []
## TalentScript riêng cho Tinh Mệnh này (không bắt buộc).
@export var script_class: Script
