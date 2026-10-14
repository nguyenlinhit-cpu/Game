class_name ArtLibrary
extends RefCounted
## Tra hình thật cho nhân vật / quái / khu (Phase 13). Không có thì trả về null để chỗ gọi vẽ hình tạm.
##
## Quy ước thư mục (mục 12):
##   assets/characters/<asset_id>/{map,battle,portrait,splash,vfx}/   asset_id = id nhân vật; nhân vật chính:
##                                                                    traveler_male / traveler_female
##   assets/enemies/<id hoặc họ quái>/{map,battle}/
##   assets/tilesets/<khu>/tiles_<khu>.png
## SpriteFrames do tools/import_assets tạo: <thư mục>/<mode>/<asset_id>_<mode>_frames.tres.
## Trường trong CharacterSkin (map_frames, battle_frames, portrait, gacha_art) gán tay thì được ưu tiên.

const CHARACTER_DIR: String = "res://assets/characters"
const ENEMY_DIR: String = "res://assets/enemies"
const TILESET_DIR: String = "res://assets/tilesets"
const REQUIREMENTS_PATH: String = "res://data/config/art_requirements.json"
## Các trận hướng dẫn / thử cũ dùng id trước khi có biến thể nguyên tố.
const LEGACY_ENEMY_ASSETS: Dictionary = {
	"warp_sprout": "warp_sprout_poison",
	"wandering_shade": "wandering_shade_soul",
	"rusted_knight": "rusted_knight_lightning",
}
const LEGACY_ENEMY_SKILLS: Dictionary = {
	"warp_sprout_bite": "en_sprout_bite",
	"wandering_shade_touch": "en_shade_touch",
	"rusted_knight_slash": "en_knight_slash",
	"rusted_knight_sweep": "en_knight_sweep",
}

static var _cache: Dictionary = {}
static var _requirements: Dictionary = {}
static var _enemy_skill_metadata: Dictionary = {}


static func requirements() -> Dictionary:
	if _requirements.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(REQUIREMENTS_PATH))
		_requirements = parsed if parsed is Dictionary else {}
	return _requirements


## Xóa bộ nhớ đệm (sau khi chạy công cụ nhập asset).
static func clear_cache() -> void:
	_cache.clear()
	_enemy_skill_metadata.clear()


static func _load(path: String) -> Resource:
	if _cache.has(path):
		return _cache[path]
	var res: Resource = load(path) if ResourceLoader.exists(path) else null
	_cache[path] = res
	return res


# --- Nhân vật ---

## Thư mục asset của nhân vật theo skin (nhân vật chính có 2 skin).
static func character_asset_id(character_id: StringName, skin_id: StringName = &"default") -> String:
	if character_id == GameState.PLAYER_CHARACTER_ID:
		return "%s_%s" % [character_id, skin_id if skin_id != &"default" else GameState.player_gender]
	return String(character_id)


static func frames_path(kind_dir: String, asset_id: String, mode: String) -> String:
	return kind_dir.path_join(asset_id).path_join(mode).path_join("%s_%s_frames.tres" % [asset_id, mode])


static func skin_of(data: CharacterData) -> CharacterSkin:
	if data == null:
		return null
	return data.get_skin(GameState.player_gender if data.id == GameState.PLAYER_CHARACTER_ID else &"default")


## SpriteFrames "map" (8 hướng: <hành động>_<hướng>) hoặc "battle" (<hành động>) của nhân vật.
static func character_frames(data: CharacterData, mode: String) -> SpriteFrames:
	if data == null:
		return null
	var skin := skin_of(data)
	if skin:
		var manual: SpriteFrames = skin.map_frames if mode == "map" else skin.battle_frames
		if manual:
			return manual
	var asset_id := character_asset_id(data.id, skin.skin_id if skin else &"default")
	return _load(frames_path(CHARACTER_DIR, asset_id, mode)) as SpriteFrames


## Chân dung hội thoại: biểu cảm hội thoại quy về 3 biểu cảm vẽ (bình thường / vui / nghiêm), thiếu thì bình thường.
static func portrait(data: CharacterData, expression: String = "neutral") -> Texture2D:
	if data == null:
		return null
	var skin := skin_of(data)
	var tex := portrait_by_id(character_asset_id(data.id, skin.skin_id if skin else &"default"), expression)
	if tex:
		return tex
	return skin.portrait if skin else null


## Chân dung theo thư mục asset (dùng cho cả NPC không phải nhân vật đánh được: orwen, lio, bram...).
static func portrait_by_id(asset_id: String, expression: String = "neutral") -> Texture2D:
	var drawn := str(requirements().get("expression_map", {}).get(expression, "neutral"))
	for name: String in [drawn, "neutral"]:
		var tex := _load(CHARACTER_DIR.path_join(asset_id).path_join("portrait/portrait_%s_%s.png" % [asset_id, name])) as Texture2D
		if tex:
			return tex
	return null


## Tranh gacha / cắt cảnh Tuyệt kỹ (2048×1152).
static func splash(data: CharacterData) -> Texture2D:
	if data == null:
		return null
	var skin := skin_of(data)
	if skin and skin.gacha_art:
		return skin.gacha_art
	var asset_id := character_asset_id(data.id, skin.skin_id if skin else &"default")
	return _load(CHARACTER_DIR.path_join(asset_id).path_join("splash/splash_%s.png" % asset_id)) as Texture2D


## Hiệu ứng kỹ năng vẽ tay (hoạt ảnh attack / skill / ultimate), null = dùng particle tạm.
static func vfx_frames(data: CharacterData) -> SpriteFrames:
	if data == null:
		return null
	var skin := skin_of(data)
	var asset_id := character_asset_id(data.id, skin.skin_id if skin else &"default")
	return _load(frames_path(CHARACTER_DIR, asset_id, "vfx")) as SpriteFrames


# --- Quái ---

## Hình quái: thư mục theo id biến thể trước, không có thì theo họ quái (biến thể nguyên tố dùng chung hình).
static func enemy_frames(data: EnemyData, mode: String) -> SpriteFrames:
	if data == null:
		return null
	for asset_id: String in enemy_asset_ids(data):
		if asset_id.is_empty():
			continue
		var frames := _load(frames_path(ENEMY_DIR, asset_id, mode)) as SpriteFrames
		if frames:
			return frames
	return null


static func enemy_asset_ids(data: EnemyData) -> Array[String]:
	var ids: Array[String] = []
	if data == null:
		return ids
	if LEGACY_ENEMY_ASSETS.has(String(data.id)):
		ids.append(LEGACY_ENEMY_ASSETS[String(data.id)])
	for id: String in [String(data.id), String(data.family)]:
		if not id.is_empty() and not ids.has(id):
			ids.append(id)
	return ids


static func enemy_skill_asset_id(skill_id: StringName) -> String:
	return str(LEGACY_ENEMY_SKILLS.get(String(skill_id), String(skill_id)))


## Tư thế và khung trúng của từng chiêu quái, cùng thứ tự ưu tiên biến thể / họ quái.
static func enemy_skill_meta(data: EnemyData, skill_id: StringName) -> Dictionary:
	if data == null:
		return {}
	for asset_id: String in enemy_asset_ids(data):
		var path := ENEMY_DIR.path_join(asset_id).path_join("vfx/skills.json")
		if not _enemy_skill_metadata.has(path):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path)) \
					if FileAccess.file_exists(path) else {}
			_enemy_skill_metadata[path] = parsed if parsed is Dictionary else {}
		var entry: Dictionary = _enemy_skill_metadata[path].get(enemy_skill_asset_id(skill_id), {})
		if not entry.is_empty():
			return entry
	return {}


# --- Khu ---

static func zone_tileset(zone: StringName) -> TileSet:
	if zone == &"":
		return null
	return _load(TILESET_DIR.path_join(String(zone)).path_join("%s_tileset.tres" % zone)) as TileSet


# --- Phát hoạt ảnh ---

## Tạo AnimatedSprite2D cho `frames`, đặt điểm neo (chân) theo metadata "anchor" của SpriteFrames
## (mặc định giữa-dưới 0,5 / 0,85) và thu phóng để cao `height` px.
static func make_sprite(frames: SpriteFrames, height: float) -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	sprite.name = "Sprite"
	sprite.sprite_frames = frames
	sprite.centered = true
	var frame_size := frame_size_of(frames)
	if frame_size.y > 0.0:
		var scale_value := height / frame_size.y
		sprite.scale = Vector2.ONE * scale_value
		# Pixel art nhỏ (map 32×32) phóng to: giữ nét, không làm nhòe.
		if frame_size.y <= 64.0:
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var anchor: Vector2 = frames.get_meta("anchor", Vector2(0.5, 0.85))
		sprite.offset = Vector2((0.5 - anchor.x) * frame_size.x, (0.5 - anchor.y) * frame_size.y)
	return sprite


static func frame_size_of(frames: SpriteFrames) -> Vector2:
	if frames == null:
		return Vector2.ZERO
	for anim in frames.get_animation_names():
		if frames.get_frame_count(anim) > 0:
			var tex := frames.get_frame_texture(anim, 0)
			if tex:
				return tex.get_size()
	return Vector2.ZERO


## Phát `action` (map: thêm hướng; thiếu hướng thì thử hướng gần, thiếu hành động thì "idle"). Trả về tên đã phát.
static func play(sprite: AnimatedSprite2D, action: String, direction: String = "") -> String:
	if sprite == null or sprite.sprite_frames == null:
		return ""
	var frames := sprite.sprite_frames
	var candidates: Array[String] = []
	for act: String in [action, "idle"]:
		if direction.is_empty():
			candidates.append(act)
		else:
			candidates.append("%s_%s" % [act, direction])
			for fallback: String in ["s", "se", "e"]:
				candidates.append("%s_%s" % [act, fallback])
	for name in candidates:
		if frames.has_animation(name):
			# Chỉ có hình hướng phải (pixel map vẽ 1 hướng): lật ngang khi nhìn sang trái.
			if not direction.is_empty():
				sprite.flip_h = name.ends_with("_e") and direction.contains("w")
			if sprite.animation != name or not sprite.is_playing():
				sprite.play(name)
			return name
	return ""
