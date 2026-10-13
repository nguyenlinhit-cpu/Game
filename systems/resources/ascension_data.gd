class_name AscensionData
extends Resource
## Một mốc đột phá: ở cấp `at_level` (đang là giới hạn) đột phá để nâng giới hạn lên `new_cap`.
## Mốc có new_cap vượt GameConfig.MAX_LEVEL bị khóa (chừa sẵn dữ liệu cho mốc 30–70).

@export var at_level: int = 10
@export var new_cap: int = 20
@export var coin: int = 0
## Số Tinh Thể Nguyên Tố đúng nguyên tố nhân vật.
@export var crystals: int = 0


func is_locked() -> bool:
	return new_cap > GameConfig.MAX_LEVEL
