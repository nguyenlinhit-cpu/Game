class_name TraceNodeData
extends Resource
## Một nút trong cây vận mệnh: nút chỉ số nhỏ hoặc nút bị động lớn. Mở bằng Xu + Dấu Ấn Vận Mệnh,
## cần đủ số lần đột phá và đã mở nút `requires` (nếu có).

## Hiệu ứng bị động có điều kiện của nút lớn (ngoài stat_modifiers luôn có).
enum Passive {
	NONE,
	## Vào trận với thêm `passive_value` × năng lượng tối đa.
	START_ENERGY,
	## +passive_value Tăng sát thương khi máu bản thân dưới 50%.
	LOW_HP_DAMAGE,
	## +passive_value Tăng sát thương lên quái đang mang ít nhất 1 debuff.
	DEBUFFED_TARGET_DAMAGE,
	## Phá Vỡ khiên quái thì hồi `passive_value` năng lượng.
	BREAK_ENERGY,
	## +passive_value lượng hồi lên đồng minh dưới 50% máu.
	LOW_HP_HEAL,
	## Nhận khiên = passive_value × Phòng Thủ đầu trận.
	START_SHIELD,
}

@export var id: StringName
@export var name_key: String = ""
@export var desc_key: String = ""
@export var major: bool = false
@export var required_ascension: int = 0
@export var requires: StringName = &""
@export var coin: int = 0
@export var sigil_tier: int = 1
@export var sigil_count: int = 0
@export var stat_modifiers: Array[StatModifierData] = []
@export var passive: Passive = Passive.NONE
@export var passive_value: float = 0.0
