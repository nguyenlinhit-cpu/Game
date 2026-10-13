class_name ZoneData
extends Resource
## Kế hoạch nội dung một khu (mục 4): trận đặt trên map, số rương theo bậc, bảng rơi đồ rương.
## Phase 12 dựng map theo file này; báo cáo kinh tế cộng tài nguyên toàn bản đồ từ đây.

@export var id: StringName
@export var name_key: String = ""
## Chương mở khu (1–4).
@export var chapter: int = 1
@export var room_count: int = 10
## Mỗi trận đặt bao nhiêu nhóm quái trên map (cùng thứ tự với encounter_counts).
@export var encounters: Array[EncounterData] = []
@export var encounter_counts: PackedInt32Array = PackedInt32Array()
## Số rương thường / quý / giải đố (theo Chest.Tier).
@export var chest_counts: PackedInt32Array = PackedInt32Array([0, 0, 0])
## Bảng rơi đồ rương thường / quý / giải đố.
@export var chest_tables: Array[LootTable] = []
@export var technique_boxes: int = 0


func get_chest_table(tier: int) -> LootTable:
	return chest_tables[tier] if tier >= 0 and tier < chest_tables.size() else null


func get_placement_count(index: int) -> int:
	return encounter_counts[index] if index < encounter_counts.size() else 1


func get_boss_encounter() -> EncounterData:
	for encounter in encounters:
		if encounter.is_boss():
			return encounter
	return null
