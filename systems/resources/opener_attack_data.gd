class_name OpenerAttackData
extends Resource
## Đòn Mở Màn trên map (đòn chém hình quạt). Phase 6 gộp vào SkillData của từng nhân vật.

@export var name_key: String = ""
## Ưu Thế bằng đòn đúng điểm yếu thì quái mất 25% khiên khi vào trận.
@export var element: Element.Type = Element.Type.SOUL
@export var range_px: float = 120.0
@export_range(10.0, 360.0) var arc_degrees: float = 120.0
@export var cooldown_sec: float = 0.6
