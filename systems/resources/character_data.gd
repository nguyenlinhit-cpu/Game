class_name CharacterData
extends Resource
## Dữ liệu một nhân vật: nhận diện, skin, chỉ số theo cấp, 3 kỹ năng trong trận.
## Kỹ năng ngoài map, Đặc tính, Tinh Mệnh bổ sung ở Phase 6–7.

@export var id: StringName
@export var name_key: String = ""
@export_range(4, 5) var rarity: int = 4
@export var element: Element.Type = Element.Type.SOUL
## TODO Phase 6: đổi sang enum Path (destruction, hunt, erudition, harmony, nihility, preservation, abundance).
@export var path: StringName
## Nhân vật chính không có trong banner.
@export var in_gacha_pool: bool = true
@export var skins: Array[CharacterSkin] = []

@export_group("Chiến đấu")
@export var stats_lv1: StatBlock
@export var stats_lv80: StatBlock
@export var max_energy: float = 120.0
@export var basic_attack: SkillData
@export var skill: SkillData
@export var ultimate: SkillData


func get_skin(skin_id: StringName) -> CharacterSkin:
	for skin in skins:
		if skin.skin_id == skin_id:
			return skin
	return skins[0] if not skins.is_empty() else null
