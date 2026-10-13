class_name BannerData
extends Resource
## Một banner gacha (mục 10). Đổi nhân vật giới hạn = tạo file banner mới, không sửa code.
##
## Bộ đếm bảo hiểm gắn với `pity_group` chứ không gắn với banner: mọi banner giới hạn dùng chung nhóm
## "limited" nên bộ đếm (và trạng thái bảo đảm 50/50) kế thừa sang banner giới hạn sau.

enum Type { STANDARD, LIMITED }

@export var id: StringName
@export var name_key: String = ""
@export var desc_key: String = ""
@export var type: Type = Type.STANDARD
@export var pity_group: StringName = &"standard"
## Vé dùng cho banner này (1 vé / lượt).
@export var ticket_item: StringName = &"wish_ticket_standard"

@export_group("Nhân vật")
## 5★ nổi bật (banner giới hạn). Trống = banner thường.
@export var featured_5: Array[StringName] = []
## 4★ nổi bật (banner giới hạn).
@export var featured_4: Array[StringName] = []
## 5★ thường: banner thường ra đều 1 trong số này; banner giới hạn ra khi lệch 50/50.
@export var pool_5: Array[StringName] = []
## Mọi 4★ có thể ra (kể cả 4★ nổi bật).
@export var pool_4: Array[StringName] = []
## Vật phẩm 3★: mỗi dòng { "item": id, "count": số lượng, "weight": trọng số }.
@export var three_star_rewards: Array[Dictionary] = []

@export_group("Tỉ lệ")
@export var base_rate_5: float = 0.006
## Từ lượt này (tính từ lần 5★ trước) cộng thêm `soft_pity_step` mỗi lượt.
@export var soft_pity_start: int = 74
@export var soft_pity_step: float = 0.06
@export var hard_pity_5: int = 90
@export var base_rate_4: float = 0.051
## Cứ chừng này lượt chắc chắn có ít nhất 1 nhân vật 4★ trở lên.
@export var hard_pity_4: int = 10
## Tỉ lệ ra nhân vật nổi bật khi ra 5★ / 4★ (lệch thì lần sau chắc chắn).
@export var featured_5_chance: float = 0.5
@export var featured_4_chance: float = 0.5
## Đủ chừng này lượt ở banner thì được chọn miễn phí 1 nhân vật trong pool_5 (một lần). 0 = không có.
@export var selector_pulls: int = 0

@export_group("Tranh banner tạm")
@export var art_color_top: Color = Color(0.2, 0.25, 0.5)
@export var art_color_bottom: Color = Color(0.05, 0.05, 0.12)
## Tranh chính thức (Phase 13); trống thì vẽ tạm.
@export var art: Texture2D


func is_limited() -> bool:
	return type == Type.LIMITED


## Tỉ lệ ra 5★ ở lượt thứ `n` kể từ lần 5★ trước (n bắt đầu từ 1).
func rate_5_at(n: int) -> float:
	if n >= hard_pity_5:
		return 1.0
	if n >= soft_pity_start:
		return minf(base_rate_5 + soft_pity_step * (n - soft_pity_start + 1), 1.0)
	return base_rate_5


## 4★ không nổi bật (ra khi lệch 50/50 ở banner giới hạn).
func get_off_featured_4() -> Array[StringName]:
	var result: Array[StringName] = []
	for id in pool_4:
		if not featured_4.has(id):
			result.append(id)
	return result


func get_all_characters() -> Array[StringName]:
	var result: Array[StringName] = []
	for list: Array[StringName] in [featured_5, pool_5, pool_4]:
		for id in list:
			if not result.has(id):
				result.append(id)
	return result
