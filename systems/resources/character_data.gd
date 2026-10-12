class_name CharacterData
extends Resource
## Dữ liệu một nhân vật. Phase 1 chỉ có phần nhận diện và skin;
## chỉ số, kỹ năng, Đặc tính, Tinh Mệnh bổ sung ở Phase 4–7.

@export var id: StringName
@export var name_key: String = ""
@export_range(4, 5) var rarity: int = 4
## TODO Phase 5: đổi sang enum Element (fire, water, lightning, wind, poison, wood, soul).
@export var element: StringName
## TODO Phase 6: đổi sang enum Path (destruction, hunt, erudition, harmony, nihility, preservation, abundance).
@export var path: StringName
## Nhân vật chính không có trong banner.
@export var in_gacha_pool: bool = true
@export var skins: Array[CharacterSkin] = []


func get_skin(skin_id: StringName) -> CharacterSkin:
	for skin in skins:
		if skin.skin_id == skin_id:
			return skin
	return skins[0] if not skins.is_empty() else null
