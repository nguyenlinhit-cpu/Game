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
## Nhân vật đang có. TODO Phase 9/11/12: nhận theo cốt truyện và gacha.
const DEFAULT_OWNED: Array[StringName] = [&"traveler", &"mira", &"kiri", &"garren", &"nyx"]
const MAX_TECHNIQUE_POINTS: int = 5
## Số đội hình lưu sẵn.
const TEAM_PRESET_COUNT: int = 5
const MAP_LIST_KEYS: Array[String] = ["defeated_enemies", "opened_chests", "broken_boxes", "visited_rooms",
		"resolved_obstacles"]

var player_gender: StringName = GENDER_MALE
var player_name: String = "Kael"
## Scene map người chơi đang đứng, dùng cho nút "Tiếp tục".
var current_map_scene: String = ""
var story_flags: Dictionary = {}
var play_time_sec: float = 0.0
## Ép cấp cả đội (phòng thử, phím debug F6/F7, test). 0 = dùng cấp thật của từng nhân vật (Phase 9).
var team_level: int = 0
## Đội hình đang dùng (tối đa 4, không trùng) = team_presets[active_preset].
var team: Array[StringName] = DEFAULT_TEAM.duplicate()
## Các đội hình lưu sẵn: [[id...], ...]. Ô trống = mảng rỗng.
var team_presets: Array = []
var active_preset: int = 0
var owned_characters: Array[StringName] = DEFAULT_OWNED.duplicate()
## Người dẫn đầu ngoài map (chỉ số trong team).
var leader_index: int = 0
## Điểm Bí Kỹ dùng chung cả đội (0–5).
var technique_points: int = MAX_TECHNIQUE_POINTS
## Bí Kỹ kiểu "trận kế tiếp" đang chờ: [character_id].
var pending_techniques: Array[StringName] = []
## Cấp Tinh Mệnh: { character_id: 0–6 }. Tăng khi nhận nhân vật trùng (grant_character, Phase 11);
## nhân vật chính: theo cờ cốt truyện soul_shard_1..6 (lấy giá trị lớn hơn).
var eidolon_levels: Dictionary = {}
## Túi đồ: { item_id: số lượng }.
var inventory: Dictionary = {}
## Tiến trình từng nhân vật: { id: { "level", "exp", "ascension", "skills": { basic, skill, ultimate, talent }, "traces": [id] } }.
var character_progress: Dictionary = {}
## Máu giữ giữa các trận (tỉ lệ máu tối đa): { id: 0–1 }. Thiếu = đầy. 0 = đang ngã (hồi ở phòng nghỉ).
var hp_ratios: Dictionary = {}

## Trạng thái từng map, khóa theo đường dẫn scene:
## { scene_path: { "player_position": [x, y], "player_facing": [x, y], "respawn_at_rest": bool,
##   "defeated_enemies": [id...], "opened_chests": [id...], "broken_boxes": [id...], "visited_rooms": [id...] } }
## Cửa phòng không cần lưu riêng: phòng còn quái thì tự khóa lại khi người chơi ở trong.
var map_states: Dictionary = {}
## Trận đang đánh: { "map_scene", "enemy_id", "encounter_path", "opening" }. Rỗng khi không trong trận.
var pending_battle: Dictionary = {}



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
	team_level = 0
	team = DEFAULT_TEAM.duplicate()
	team_presets = _default_presets()
	active_preset = 0
	owned_characters = DEFAULT_OWNED.duplicate()
	inventory.clear()
	character_progress.clear()
	hp_ratios.clear()
	leader_index = 0
	technique_points = MAX_TECHNIQUE_POINTS
	pending_techniques.clear()
	eidolon_levels.clear()
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
	leader_index = clampi(leader_index, 0, team.size() - 1)
	if team_presets.size() != TEAM_PRESET_COUNT:
		team_presets = _default_presets()
	team_presets[active_preset] = team.map(func(id: StringName) -> String: return String(id))
	return true


func _default_presets() -> Array:
	var presets: Array = []
	for i in TEAM_PRESET_COUNT:
		presets.append(team.map(func(id: StringName) -> String: return String(id)) if i == 0 else [])
	return presets


## Đội hình lưu sẵn thứ `index` (mảng rỗng nếu chưa đặt).
func get_preset(index: int) -> Array[StringName]:
	var result: Array[StringName] = []
	if index >= 0 and index < team_presets.size():
		for id: Variant in team_presets[index]:
			result.append(StringName(str(id)))
	return result


## Lưu đội hình vào ô `index` (không đổi đội đang dùng trừ khi là ô đang dùng). Trả về false nếu quá 4 / trùng.
func save_preset(index: int, character_ids: Array[StringName]) -> bool:
	if index < 0 or index >= TEAM_PRESET_COUNT or character_ids.size() > GameConfig.MAX_TEAM_SIZE:
		return false
	var seen: Dictionary = {}
	for id in character_ids:
		if seen.has(id):
			return false
		seen[id] = true
	if team_presets.size() != TEAM_PRESET_COUNT:
		team_presets = _default_presets()
	if index == active_preset:
		return set_team(character_ids)
	team_presets[index] = character_ids.map(func(id: StringName) -> String: return String(id))
	return true


## Dùng đội hình lưu sẵn `index` làm đội hiện tại. Ô trống thì từ chối.
func use_preset(index: int) -> bool:
	var ids := get_preset(index)
	if ids.is_empty():
		return false
	var previous := active_preset
	active_preset = index
	if not set_team(ids):
		active_preset = previous
		return false
	leader_index = 0
	EventBus.leader_changed.emit(leader_index)
	return true


## Cấp đội để so với cấp quái: cấp ép (team_level) hoặc trung bình cấp các nhân vật trong đội.
func get_team_level() -> int:
	if team_level > 0:
		return team_level
	if team.is_empty():
		return 1
	var total := 0
	for id in team:
		total += Progression.get_level(id)
	return roundi(float(total) / team.size())


# --- Nhân vật sở hữu ---

## Nhận nhân vật (gacha, cốt truyện). Đã có thì +1 Tinh Mệnh (tối đa 6; quá thì `overflow` để Phase 11 đổi Bụi Sao).
## Trả về { "new": bool, "eidolon": int, "overflow": bool }.
func grant_character(character_id: StringName) -> Dictionary:
	if not owned_characters.has(character_id):
		owned_characters.append(character_id)
		return {"new": true, "eidolon": get_eidolon_level(character_id), "overflow": false}
	var level := get_eidolon_level(character_id)
	if level >= 6:
		return {"new": false, "eidolon": 6, "overflow": true}
	set_eidolon_level(character_id, level + 1)
	EventBus.character_upgraded.emit(character_id)
	return {"new": false, "eidolon": level + 1, "overflow": false}


# --- Túi đồ ---

func get_item_count(item_id: StringName) -> int:
	return int(inventory.get(String(item_id), 0))


func add_item(item_id: StringName, amount: int) -> void:
	if amount == 0:
		return
	var value := maxi(get_item_count(item_id) + amount, 0)
	if value == 0:
		inventory.erase(String(item_id))
	else:
		inventory[String(item_id)] = value
	EventBus.inventory_changed.emit(item_id, value)


## Đủ mọi vật phẩm trong `cost` ({ item_id: số lượng }).
func has_items(cost: Dictionary) -> bool:
	for item_id: Variant in cost:
		if get_item_count(StringName(str(item_id))) < int(cost[item_id]):
			return false
	return true


## Trừ đủ `cost` nếu có, trả về false (không trừ gì) nếu thiếu.
func spend_items(cost: Dictionary) -> bool:
	if not has_items(cost):
		return false
	for item_id: Variant in cost:
		add_item(StringName(str(item_id)), -int(cost[item_id]))
	return true


# --- Máu giữ giữa các trận ---

func get_hp_ratio(character_id: StringName) -> float:
	return clampf(float(hp_ratios.get(String(character_id), 1.0)), 0.0, 1.0)


func set_hp_ratio(character_id: StringName, ratio: float) -> void:
	hp_ratios[String(character_id)] = clampf(ratio, 0.0, 1.0)
	EventBus.team_hp_changed.emit()


## Hồi máu cả đội `ratio` phần máu tối đa (nhân vật đã ngã cũng đứng dậy). ratio ≥ 1 = hồi đầy mọi nhân vật.
func heal_team(ratio: float) -> void:
	if ratio >= 1.0:
		hp_ratios.clear()
		EventBus.team_hp_changed.emit()
		return
	for id in team:
		set_hp_ratio(id, get_hp_ratio(id) + ratio)


func get_leader_id() -> StringName:
	return team[clampi(leader_index, 0, team.size() - 1)]


# --- Bí Kỹ và Tinh Mệnh ---

func change_technique_points(delta: int) -> void:
	technique_points = clampi(technique_points + delta, 0, MAX_TECHNIQUE_POINTS)
	EventBus.technique_points_changed.emit(technique_points)


## Thêm Bí Kỹ "trận kế tiếp" (dùng lại cùng nhân vật không cộng dồn).
func add_pending_technique(character_id: StringName) -> void:
	if not pending_techniques.has(character_id):
		pending_techniques.append(character_id)


## Lấy và xóa danh sách Bí Kỹ chờ trận kế tiếp.
func consume_pending_techniques() -> Array[StringName]:
	var result := pending_techniques.duplicate()
	pending_techniques.clear()
	return result


func get_eidolon_level(character_id: StringName) -> int:
	var level := int(eidolon_levels.get(String(character_id), 0))
	if character_id == PLAYER_CHARACTER_ID:
		level = maxi(level, get_soul_shard_count())
	return clampi(level, 0, 6)


## Nhân vật chính: số Mảnh Hồn đã thu hồi theo cốt truyện (cờ soul_shard_1..6) = số Tinh Mệnh mở.
func get_soul_shard_count() -> int:
	var count := 0
	for i in range(1, 7):
		if bool(get_story_flag(StringName("soul_shard_%d" % i), false)):
			count += 1
	return count


func set_eidolon_level(character_id: StringName, level: int) -> void:
	eidolon_levels[String(character_id)] = clampi(level, 0, 6)


## { StringName: cấp } cho BattleController.
func get_eidolon_levels_for_battle() -> Dictionary:
	var result: Dictionary = {}
	for key: String in eidolon_levels:
		result[StringName(key)] = get_eidolon_level(StringName(key))
	return result


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
		# Thua: về phòng nghỉ, cả đội được hồi đầy.
		heal_team(1.0)
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
		"owned_characters": owned_characters.map(func(id: StringName) -> String: return String(id)),
		"leader_index": leader_index,
		"technique_points": technique_points,
		"pending_techniques": pending_techniques.map(func(id: StringName) -> String: return String(id)),
		"eidolon_levels": eidolon_levels.duplicate(),
		"map_states": map_states.duplicate(true),
		"team_presets": team_presets.duplicate(true),
		"active_preset": active_preset,
		"inventory": inventory.duplicate(),
		"character_progress": character_progress.duplicate(true),
		"hp_ratios": hp_ratios.duplicate(),
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
	team_level = int(data.get("team_level", 0))
	team = DEFAULT_TEAM.duplicate()
	var saved_team: Variant = data.get("team", [])
	if saved_team is Array and not saved_team.is_empty():
		var ids: Array[StringName] = []
		for id: Variant in saved_team:
			ids.append(StringName(str(id)))
		if ids.size() <= GameConfig.MAX_TEAM_SIZE:
			team = ids
	owned_characters = DEFAULT_OWNED.duplicate()
	var saved_owned: Variant = data.get("owned_characters", [])
	if saved_owned is Array and not saved_owned.is_empty():
		owned_characters.clear()
		for id: Variant in saved_owned:
			owned_characters.append(StringName(str(id)))
	leader_index = clampi(int(data.get("leader_index", 0)), 0, team.size() - 1)
	technique_points = clampi(int(data.get("technique_points", MAX_TECHNIQUE_POINTS)), 0, MAX_TECHNIQUE_POINTS)
	pending_techniques.clear()
	var saved_pending: Variant = data.get("pending_techniques", [])
	if saved_pending is Array:
		for id: Variant in saved_pending:
			pending_techniques.append(StringName(str(id)))
	var saved_eidolons: Variant = data.get("eidolon_levels", {})
	eidolon_levels = saved_eidolons.duplicate() if saved_eidolons is Dictionary else {}
	var states: Variant = data.get("map_states", {})
	map_states = states.duplicate(true) if states is Dictionary else {}
	var presets: Variant = data.get("team_presets", [])
	team_presets = presets.duplicate(true) if presets is Array and presets.size() == TEAM_PRESET_COUNT else _default_presets()
	active_preset = clampi(int(data.get("active_preset", 0)), 0, TEAM_PRESET_COUNT - 1)
	var saved_inventory: Variant = data.get("inventory", {})
	inventory.clear()
	if saved_inventory is Dictionary:
		for key: Variant in saved_inventory:
			inventory[str(key)] = int(saved_inventory[key])
	var progress: Variant = data.get("character_progress", {})
	character_progress = progress.duplicate(true) if progress is Dictionary else {}
	var ratios: Variant = data.get("hp_ratios", {})
	hp_ratios = ratios.duplicate() if ratios is Dictionary else {}
	pending_battle.clear()
