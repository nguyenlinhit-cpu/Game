class_name DataPaths
extends RefCounted
## Đường dẫn scene và dữ liệu dùng chung, tránh gõ chuỗi rải rác trong code.

const TITLE_SCENE: String = "res://scenes/ui/title/title_screen.tscn"
const INTRO_SCENE: String = "res://scenes/ui/intro/intro.tscn"
const CHARACTER_SELECT_SCENE: String = "res://scenes/ui/character_select/character_select.tscn"
const TEST_MAP_SCENE: String = "res://scenes/overworld/map/test_map.tscn"
## Trận tạm của Phase 3 (Phase 4 thay bằng trận thật, giữ đường dẫn).
const BATTLE_SCENE: String = "res://scenes/battle/battle_scene.tscn"

const INTRO_SCRIPT: String = "res://data/dialogue/intro.json"
const CHARACTERS_DIR: String = "res://data/characters"
const PLAYER_MOVEMENT_CONFIG: String = "res://data/config/player_movement.tres"
const OVERWORLD_ENEMY_CONFIG: String = "res://data/config/overworld_enemy_default.tres"
const TRAVELER_OPENER: String = "res://data/skills/traveler_opener.tres"
## Dùng khi mở thẳng scene trận để thử (không đi từ map vào).
const DEBUG_ENCOUNTER: String = "res://data/encounters/test_mixed_lv5.tres"
const PLACEHOLDER_TILESET: String = "res://assets/tilesets/placeholder_tileset.tres"


static func character_path(character_id: StringName) -> String:
	return CHARACTERS_DIR.path_join("%s.tres" % character_id)


static func load_character(character_id: StringName) -> CharacterData:
	var data := load(character_path(character_id)) as CharacterData
	if data == null:
		push_error("DataPaths: không tìm thấy CharacterData '%s'" % character_id)
	return data
