extends Node
## Trạng thái của lượt chơi hiện tại: nhân vật chính, cờ cốt truyện, scene map đang đứng...
## Mọi thứ cần lưu đi qua to_dict()/from_dict() để SaveManager ghi ra JSON.

const GENDER_MALE: StringName = &"male"
const GENDER_FEMALE: StringName = &"female"
const DEFAULT_PLAYER_NAMES: Dictionary = {GENDER_MALE: "Kael", GENDER_FEMALE: "Kaela"}
const MAX_PLAYER_NAME_LENGTH: int = 12
## Nam và Nữ dùng chung 1 CharacterData, chỉ khác skin.
const PLAYER_CHARACTER_ID: StringName = &"traveler"

var player_gender: StringName = GENDER_MALE
var player_name: String = "Kael"
## Scene map người chơi đang đứng, dùng cho nút "Tiếp tục".
var current_map_scene: String = ""
var story_flags: Dictionary = {}
var play_time_sec: float = 0.0

# TODO Phase 3: vị trí người chơi, quái đã hạ, rương đã mở, trạng thái cửa.
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


func to_dict() -> Dictionary:
	return {
		"player_gender": String(player_gender),
		"player_name": player_name,
		"current_map_scene": current_map_scene,
		"story_flags": story_flags.duplicate(true),
		"play_time_sec": play_time_sec,
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
