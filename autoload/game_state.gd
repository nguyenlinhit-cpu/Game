extends Node
## Trạng thái của lượt chơi hiện tại: nhân vật chính, cờ cốt truyện, scene map đang đứng...
## Mọi thứ cần lưu đi qua to_dict()/from_dict() để SaveManager ghi ra JSON.

const GENDER_MALE: StringName = &"male"
const GENDER_FEMALE: StringName = &"female"
const DEFAULT_PLAYER_NAMES: Dictionary = {GENDER_MALE: "Kael", GENDER_FEMALE: "Kaela"}
const MAX_PLAYER_NAME_LENGTH: int = 12
## Nam và Nữ dùng chung 1 CharacterData, chỉ khác skin.
const PLAYER_CHARACTER_ID: StringName = &"traveler"
## Đội mẫu Phase 4 (dữ liệu tạm; Phase 6 thay bằng nhân vật miễn phí thật).
const DEFAULT_TEAM: Array[StringName] = [&"traveler", &"mira", &"kiri", &"garren"]
const MAP_LIST_KEYS: Array[String] = ["defeated_enemies", "opened_chests", "broken_boxes", "visited_rooms"]

var player_gender: StringName = GENDER_MALE
var player_name: String = "Kael"
## Scene map người chơi đang đứng, dùng cho nút "Tiếp tục".
var current_map_scene: String = ""
var story_flags: Dictionary = {}
var play_time_sec: float = 0.0
## Cấp đội dùng để so với cấp quái (thắng ngay khi hơn ≥10 cấp).
## TODO Phase 9: tính từ cấp các nhân vật trong đội thay vì giá trị cố định.
var team_level: int = 1
## Đội hình hiện tại (tối đa 4, không trùng). TODO Phase 9: nhiều đội hình lưu sẵn, chỉ chọn nhân vật đã sở hữu.
var team: Array[StringName] = DEFAULT_TEAM.duplicate()

## Trạng thái từng map, khóa theo đường dẫn scene:
## { scene_path: { "player_position": [x, y], "player_facing": [x, y], "respawn_at_rest": bool,
##   "defeated_enemies": [id...], "opened_chests": [id...], "broken_boxes": [id...], "visited_rooms": [id...] } }
## Cửa phòng không cần lưu riêng: phòng còn quái thì tự khóa lại khi người chơi ở trong.
var map_states: Dictionary = {}
## Trận đang đánh: { "map_scene", "enemy_id", "encounter_path", "opening" }. Rỗng khi không trong trận.
var pending_battle: Dictionary = {}

# TODO Phase 9: danh sách nhân vật sở hữu, đội hình, kho đồ.


func _ready() -> void:
	TranslationServer.set_locale(UserSettings.get_locale())


func _process(delta: float) -> void:
	# TODO Phase 14: chỉ đếm khi đang ở trong map/trận, không đếm ở màn tiêu đề.
	play_time_sec += delta


func reset_new_game() -> void:
	player_gender = GENDER_MALE
	player_name = get_default_name(GENDER_MALE)
	current_map_scene = ""
	story_flags.clear()
	play_time_sec = 0.0
	team_level = 1
	team = DEFAULT_TEAM.duplicate()
	map_states.clear()
	pending_battle.clear()


static func get_default_name(gender: StringName) -> String:
	return DEFAULT_PLAYER_NAMES.get(gender, DEFAULT_PLAYER_NAMES[GENDER_MALE])


static func is_valid_gender(gender: StringName) -> bool:
	return gender == GENDER_MALE or gender == GENDER_FEMALE


## Bỏ khoảng trắng thừa, cắt còn tối đa 12 ký tự; tên rỗng thì lấy tên mặc định theo giới tính.
static func sanitize_player_name(raw_name: String, gender: StringName) -> String:
	var cleaned := raw_name.strip_edges().left(MAX_PLAYER_NAME_LENGTH).strip_edges()
	if cleaned.is_empty():
		return get_default_name(gender)
	return cleaned


func set_player_identity(gender: StringName, raw_name: String) -> void:
	if not is_valid_gender(gender):
		push_warning("GameState: giới tính không hợp lệ '%s', dùng Nam" % gender)
		gender = GENDER_MALE
	player_gender = gender
	player_name = sanitize_player_name(raw_name, gender)


func set_story_flag(flag: StringName, value: Variant = true) -> void:
	story_flags[String(flag)] = value
	EventBus.story_flag_set.emit(flag, value)


func get_story_flag(flag: StringName, default: Variant = false) -> Variant:
	return story_flags.get(String(flag), default)


# --- Đội hình ---

## Đặt đội hình. Từ chối (trả về false, giữ đội cũ) nếu rỗng, quá 4 người hoặc trùng nhân vật.
func set_team(character_ids: Array[StringName]) -> bool:
	var error := ""
	if character_ids.is_empty():
		error = tr("TEAM_ERROR_EMPTY")
	elif character_ids.size() > GameConfig.MAX_TEAM_SIZE:
		error = tr("TEAM_ERROR_TOO_MANY") % GameConfig.MAX_TEAM_SIZE
	else:
		var seen: Dictionary = {}
		for id in character_ids:
			if seen.has(id):
				error = tr("TEAM_ERROR_DUPLICATE")
			seen[id] = true
	if not error.is_empty():
		push_warning("GameState.set_team: " + error)
		EventBus.toast_requested.emit(error)
		return false
	team = character_ids.duplicate()
	return true


## CharacterData của đội hiện tại (bỏ qua id không tồn tại).
func get_team_data() -> Array[CharacterData]:
	var result: Array[CharacterData] = []
	for id in team:
		var data := DataPaths.load_character(id)
		if data:
			result.append(data)
	return result


# --- Trạng thái map ---

func get_map_state(scene_path: String) -> Dictionary:
	if not map_states.has(scene_path):
		var state := {}
		for key in MAP_LIST_KEYS:
			state[key] = []
		map_states[scene_path] = state
	return map_states[scene_path]


func map_state_has(scene_path: String, list_key: String, id: String) -> bool:
	return get_map_state(scene_path).get(list_key, []).has(id)


func map_state_add(scene_path: String, list_key: String, id: String) -> void:
	var list: Array = get_map_state(scene_path).get(list_key, [])
	if not list.has(id):
		list.append(id)
	get_map_state(scene_path)[list_key] = list


func set_map_player(scene_path: String, position: Vector2, facing: Vector2) -> void:
	var state := get_map_state(scene_path)
	state["player_position"] = [position.x, position.y]
	state["player_facing"] = [facing.x, facing.y]


## Vị trí người chơi đã lưu; trả về null nếu chưa có.
func get_map_player_position(scene_path: String) -> Variant:
	var value: Variant = get_map_state(scene_path).get("player_position")
	if value is Array and value.size() == 2:
		return Vector2(float(value[0]), float(value[1]))
	return null


func get_map_player_facing(scene_path: String) -> Vector2:
	var value: Variant = get_map_state(scene_path).get("player_facing")
	if value is Array and value.size() == 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.DOWN


# --- Vào/ra trận ---

func begin_battle(map_scene: String, enemy_id: String, encounter: EncounterData,
		opening: BattleTypes.Opening) -> void:
	pending_battle = {
		"map_scene": map_scene,
		"enemy_id": enemy_id,
		"encounter_path": encounter.resource_path if encounter else "",
		"opening": int(opening),
	}


## Kết thúc trận: thắng thì ghi nhóm quái đã hạ; thua thì đánh dấu hồi sinh ở phòng nghỉ gần nhất.
## Không mất đồ trong cả hai trường hợp. Trả về scene map để quay lại.
func finish_battle(won: bool) -> String:
	var map_scene := str(pending_battle.get("map_scene", current_map_scene))
	if map_scene.is_empty():
		map_scene = DataPaths.TEST_MAP_SCENE
	if won:
		map_state_add(map_scene, "defeated_enemies", str(pending_battle.get("enemy_id", "")))
	else:
		get_map_state(map_scene)["respawn_at_rest"] = true
	pending_battle.clear()
	return map_scene


func to_dict() -> Dictionary:
	return {
		"player_gender": String(player_gender),
		"player_name": player_name,
		"current_map_scene": current_map_scene,
		"story_flags": story_flags.duplicate(true),
		"play_time_sec": play_time_sec,
		"team_level": team_level,
		"team": team.map(func(id: StringName) -> String: return String(id)),
		"map_states": map_states.duplicate(true),
	}


func from_dict(data: Dictionary) -> void:
	var gender := StringName(str(data.get("player_gender", GENDER_MALE)))
	if not is_valid_gender(gender):
		gender = GENDER_MALE
	player_gender = gender
	player_name = sanitize_player_name(str(data.get("player_name", "")), gender)
	current_map_scene = str(data.get("current_map_scene", ""))
	var flags: Variant = data.get("story_flags", {})
	story_flags = flags if flags is Dictionary else {}
	play_time_sec = float(data.get("play_time_sec", 0.0))
	team_level = int(data.get("team_level", 1))
	team = DEFAULT_TEAM.duplicate()
	var saved_team: Variant = data.get("team", [])
	if saved_team is Array and not saved_team.is_empty():
		var ids: Array[StringName] = []
		for id: Variant in saved_team:
			ids.append(StringName(str(id)))
		if ids.size() <= GameConfig.MAX_TEAM_SIZE:
			team = ids
	var states: Variant = data.get("map_states", {})
	map_states = states.duplicate(true) if states is Dictionary else {}
	pending_battle.clear()
