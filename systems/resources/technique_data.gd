class_name TechniqueData
extends Resource
## Bí Kỹ (kỹ năng ngoài map thứ 2), tốn Điểm Bí Kỹ dùng chung cả đội.
## 3 kiểu: lợi thế trận kế tiếp, tác động quái trên map, tiện ích khám phá.

enum Kind { NEXT_BATTLE, MAP_ENEMIES, EXPLORATION }
## Việc làm ngay trên map.
enum MapAction { NONE, PHASE_DASH, FIREWORK_DAZE, INVISIBILITY }

@export var id: StringName
@export var name_key: String = ""
@export var desc_key: String = ""
@export var kind: Kind = Kind.NEXT_BATTLE
@export var cost: int = 1
## Chạy đầu trận (người dùng = nhân vật sở hữu Bí Kỹ, phải có trong đội):
## NEXT_BATTLE/EXPLORATION: trận kế tiếp; MAP_ENEMIES: trận với nhóm quái đã bị Bí Kỹ đánh dấu.
@export var battle_start_effects: Array[SkillEffect] = []

@export_group("Trên map")
@export var map_action: MapAction = MapAction.NONE
@export var distance_tiles: float = 4.0
@export var radius_tiles: float = 2.0
@export var duration_sec: float = 8.0
@export var speed_bonus: float = 0.0
