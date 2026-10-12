class_name CharacterSkin
extends Resource
## Một bộ hình của nhân vật. Nhân vật chính có 2 skin (male/female) dùng chung 1 CharacterData.

@export var skin_id: StringName
## Khóa dịch tên skin hiển thị ở giao diện (vd. "Nam").
@export var label_key: String = ""
## Màu hình tạm khi chưa có sprite.
@export var placeholder_color: Color = Color.GRAY
@export var accent_color: Color = Color.WHITE

@export_group("Hình chính thức (Phase 13)")
@export var map_frames: SpriteFrames
@export var battle_frames: SpriteFrames
@export var portrait: Texture2D
