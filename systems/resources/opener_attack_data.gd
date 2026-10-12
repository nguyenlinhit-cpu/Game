class_name OpenerAttackData
extends Resource
## Đòn Mở Màn trên map (đòn chém hình quạt). Phase 6 gộp vào SkillData của từng nhân vật.

@export var name_key: String = ""
## TODO Phase 5: đổi sang enum Element. Phase 5 dùng để trừ 25% khiên khi Ưu Thế.
@export var element: StringName
@export var range_px: float = 120.0
@export_range(10.0, 360.0) var arc_degrees: float = 120.0
@export var cooldown_sec: float = 0.6
