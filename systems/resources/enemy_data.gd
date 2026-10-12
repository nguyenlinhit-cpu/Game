class_name EnemyData
extends Resource
## Dữ liệu một loại quái: nhận diện, chỉ số theo cấp, kỹ năng + trọng số chọn.
## Điểm yếu, khiên ở Phase 5; AI theo tình huống ở Phase 8.

enum Kind { NORMAL, ELITE, BOSS }

@export var id: StringName
@export var name_key: String = ""
@export var kind: Kind = Kind.NORMAL
## TODO Phase 5: đổi sang enum Element.
@export var element: StringName
@export var placeholder_color: Color = Color("8e2a3b")

@export_group("Chiến đấu")
@export var stats_lv1: StatBlock
@export var stats_lv80: StatBlock
@export var skills: Array[SkillData] = []
## Trọng số chọn từng kỹ năng (cùng thứ tự với skills). Thiếu thì coi như 1.
@export var skill_weights: PackedFloat32Array = PackedFloat32Array()
