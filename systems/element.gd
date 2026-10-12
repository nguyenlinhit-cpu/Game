class_name Element
extends RefCounted
## 7 nguyên tố (mục 6) và màu chủ đạo dùng cho hình tạm, viền số sát thương, hiệu ứng.

enum Type { FIRE, WATER, LIGHTNING, WIND, POISON, WOOD, SOUL }

const COLORS: Dictionary = {
	Type.FIRE: Color("E8552B"),
	Type.WATER: Color("3A8DDE"),
	Type.LIGHTNING: Color("A65BF2"),
	Type.WIND: Color("4FD1B5"),
	Type.POISON: Color("9BC53D"),
	Type.WOOD: Color("2E8B57"),
	Type.SOUL: Color("F2D58A"),
}
const NAME_KEYS: Dictionary = {
	Type.FIRE: "ELEMENT_FIRE",
	Type.WATER: "ELEMENT_WATER",
	Type.LIGHTNING: "ELEMENT_LIGHTNING",
	Type.WIND: "ELEMENT_WIND",
	Type.POISON: "ELEMENT_POISON",
	Type.WOOD: "ELEMENT_WOOD",
	Type.SOUL: "ELEMENT_SOUL",
}
## Giá trị "không có nguyên tố" khi truyền dạng int (vd. không có Đòn Mở Màn).
const NONE: int = -1


static func all() -> Array[Type]:
	return [Type.FIRE, Type.WATER, Type.LIGHTNING, Type.WIND, Type.POISON, Type.WOOD, Type.SOUL]


static func color(type: int) -> Color:
	return COLORS.get(type, Color.WHITE)


static func name_key(type: int) -> String:
	return NAME_KEYS.get(type, "")


## Chữ cái đầu tên nguyên tố (theo ngôn ngữ hiện tại) cho biểu tượng tạm.
static func letter(type: int) -> String:
	return TranslationServer.translate(name_key(type)).left(1).to_upper()
