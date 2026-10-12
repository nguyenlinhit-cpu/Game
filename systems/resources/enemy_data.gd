class_name EnemyData
extends Resource
## Dữ liệu một loại quái. Phase 3 chỉ cần phần nhận diện;
## chỉ số, điểm yếu, khiên, kỹ năng, AI bổ sung ở Phase 4, 5, 8.

enum Kind { NORMAL, ELITE, BOSS }

@export var id: StringName
@export var name_key: String = ""
@export var kind: Kind = Kind.NORMAL
## TODO Phase 5: đổi sang enum Element.
@export var element: StringName
@export var placeholder_color: Color = Color("8e2a3b")
