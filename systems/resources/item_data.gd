class_name ItemData
extends Resource
## Một loại vật phẩm trong túi đồ (mục 11): tiền tệ, Ký Ức Mảnh Hồn, Tinh Thể Nguyên Tố, Dấu Ấn Vận Mệnh,
## Lõi Ma Biến, tài nguyên gacha, đồ tiêu hao.

## Tab trong túi đồ.
enum Category { CURRENCY, EXP, ASCENSION, SIGIL, UPGRADE, WISH, CONSUMABLE }

@export var id: StringName
@export var name_key: String = ""
@export var desc_key: String = ""
@export var category: Category = Category.CURRENCY
@export_range(1, 5) var rarity: int = 1
## Chữ và màu trên biểu tượng tạm.
@export var icon_text: String = "?"
@export var icon_color: Color = Color.WHITE
## Ký Ức Mảnh Hồn: EXP mỗi cái.
@export var exp_value: int = 0
## Tinh Thể Nguyên Tố: nguyên tố (−1 = không).
@export var element: int = -1
## Dấu Ấn Vận Mệnh: vận mệnh (−1 = không) và bậc 1–3.
@export var path: int = -1
@export var tier: int = 0
## Dùng được trong túi đồ (Hộp Bí Kỹ: +1 Điểm Bí Kỹ).
@export var usable: bool = false
