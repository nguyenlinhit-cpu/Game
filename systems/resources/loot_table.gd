class_name LootTable
extends Resource
## Bảng rơi đồ (mục 11) cho một loại quái hoặc một loại rương.
## Quái: `entries` lăn mỗi lần thắng (nhân theo số con trong trận); `first_clear` chỉ lần hạ đầu tiên;
## `hard_extra` thêm khi thắng boss mức Khó. Rương: `entries` + `first_clear` (Lệ Tinh, rương chỉ mở 1 lần).

@export var id: StringName
@export var entries: Array[LootEntry] = []
@export var first_clear: Array[LootEntry] = []
@export var hard_extra: Array[LootEntry] = []
## Boss: sau `full_claims_per_day` lần nhận đủ trong ngày thì chỉ còn dòng Xu Aether.
@export var full_claims_per_day: int = 0
