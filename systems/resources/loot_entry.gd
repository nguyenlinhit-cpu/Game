class_name LootEntry
extends Resource
## Một dòng trong bảng rơi đồ: vật phẩm (hoặc chọn ngẫu nhiên 1 trong `pool`), số lượng min–max, tỉ lệ rơi.
## Id đặc biệt (Loot đổi lúc lăn):
## - "crystal_enemy": Tinh Thể đúng nguyên tố của quái.
## - "crystal_team": Tinh Thể nguyên tố của 1 nhân vật ngẫu nhiên trong đội đang dùng (rương).
## - "sigil_team_1/2/3": Dấu Ấn bậc 1/2/3 theo vận mệnh của 1 nhân vật ngẫu nhiên trong đội (mỗi món chọn riêng).

const ENEMY_CRYSTAL: StringName = &"crystal_enemy"
const TEAM_CRYSTAL: StringName = &"crystal_team"
const TEAM_SIGIL_PREFIX: String = "sigil_team_"

@export var item_id: StringName = &""
## Không rỗng: mỗi món rơi ra chọn ngẫu nhiên 1 id trong danh sách (Dấu Ấn theo nhóm vận mệnh, Tinh Thể theo khu).
@export var pool: Array[StringName] = []
@export var min_count: int = 1
@export var max_count: int = 1
@export_range(0.0, 1.0) var chance: float = 1.0
## Mức Khó nhân số lượng dòng này (Ký Ức không nhân: mức Khó chỉ rơi thêm nguyên liệu).
@export var scales_with_difficulty: bool = true


## Số lượng kỳ vọng mỗi lần lăn.
func expected_count() -> float:
	return chance * (min_count + max_count) * 0.5
