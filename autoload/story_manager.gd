extends Node
## Cốt truyện (mục 3, Phase 12): đọc data/story/story.json (sinh bằng tools/data_builder/build_story.py),
## chạy hội thoại JSON trong data/dialogue/, xử lý sự kiện của câu thoại (bật cờ, nhận nhân vật, Mảnh Hồn),
## điểm kích hoạt trên map, NPC, móc sau trận (boss → cảnh kết chương), nhiệm vụ chính / phụ, cổng dịch chuyển.
##
## Mọi tiến trình là cờ trong GameState.story_flags, nên lưu/tải không cần gì thêm. Cảnh xếp hàng chờ map
## (sau trận boss) cũng nằm trong cờ "pending_dialogues".

signal dialogue_started(dialogue_id: String)
signal dialogue_finished(dialogue_id: String, result: String)
## Cờ cốt truyện đổi → nhiệm vụ / mũi tên / NPC vẽ lại.
signal story_changed

const STORY_PATH: String = "res://data/story/story.json"
const DIALOGUE_DIR: String = "res://data/dialogue"
const HUB_ZONE: StringName = &"hub"
const PENDING_FLAG: String = "pending_dialogues"
const NEW_GAME_ROOM: StringName = &"H04"

var data: Dictionary = {}
var box: DialogueBox
## Test tắt để hội thoại không chờ người bấm: mọi cảnh chạy hết ngay, chọn lựa chọn theo `auto_choices`.
var auto_play: bool = false
## Lựa chọn tự động: { dialogue_id: chỉ số lựa chọn }, mặc định 0.
var auto_choices: Dictionary = {}
## Cảnh đã chạy trong phiên (test đọc).
var played: Array[String] = []

var _dialogues: Dictionary = {}
var _queue: Array[String] = []
var _current: String = ""
var _result: String = ""


func _ready() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(STORY_PATH))
	data = parsed if parsed is Dictionary else {}
	if data.is_empty():
		push_error("StoryManager: không đọc được %s" % STORY_PATH)
	box = DialogueBox.new()
	add_child(box)
	box.finished.connect(_on_box_finished)
	EventBus.encounter_cleared.connect(_on_encounter_cleared)
	EventBus.story_flag_set.connect(func(_flag: StringName, _value: Variant) -> void: story_changed.emit())


# --- Game mới ---

## Game mới theo cốt truyện: chỉ có nhân vật chính, bắt đầu ở phòng y tế của Sảnh Trung Tâm.
func begin_new_story() -> void:
	var team: Array[StringName] = [GameState.PLAYER_CHARACTER_ID]
	GameState.owned_characters = team.duplicate()
	GameState.team_presets.clear()
	GameState.set_team(team)
	GameState.active_preset = 0
	GameState.leader_index = 0
	GameState.current_map_scene = get_zone_scene(HUB_ZONE)
	GameState.fast_travel.clear()


# --- Cờ ---

func has_flag(flag: String) -> bool:
	return bool(GameState.get_story_flag(StringName(flag), false))


## Mọi cờ trong `required` đều bật và mọi cờ trong `blocked` đều tắt.
func check(required: Array, blocked: Array) -> bool:
	for flag: Variant in required:
		if not has_flag(str(flag)):
			return false
	for flag: Variant in blocked:
		if has_flag(str(flag)):
			return false
	return true


# --- Khu ---

func get_zone_scene(zone: StringName) -> String:
	return str(data.get("zones", {}).get(String(zone), ""))


func get_scene_zone(scene_path: String) -> StringName:
	var zones: Dictionary = data.get("zones", {})
	for zone: String in zones:
		if zones[zone] == scene_path:
			return StringName(zone)
	return &""


func zone_name(zone: StringName) -> String:
	return tr("ZONE_" + String(zone).to_upper())


## Tên phòng nghỉ trong bảng dịch chuyển: "Lối vào" (phòng xuất hiện qua cổng) hoặc "Phòng nghỉ trước boss".
func rest_room_name(zone: StringName, room_id: StringName) -> String:
	for entry: Dictionary in data.get("gate_zones", []):
		if StringName(str(entry["zone"])) == zone and StringName(str(entry["room"])) == room_id:
			return tr("TRAVEL_ENTRANCE")
	return tr("TRAVEL_BOSS_REST")


## Khu đã mở ở Cổng Dịch Chuyển: [{ "zone", "scene", "room" }].
func get_gate_destinations() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in data.get("gate_zones", []):
		if has_flag(str(entry["flag"])):
			result.append({"zone": StringName(str(entry["zone"])), "scene": get_zone_scene(StringName(str(entry["zone"]))),
					"room": StringName(str(entry["room"]))})
	return result


# --- Hội thoại ---

func load_dialogue(dialogue_id: String) -> Dictionary:
	if not _dialogues.has(dialogue_id):
		var path := DIALOGUE_DIR.path_join(dialogue_id + ".json")
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
		_dialogues[dialogue_id] = parsed if parsed is Dictionary else {}
		if not parsed is Dictionary:
			push_error("StoryManager: không đọc được hội thoại %s" % path)
	return _dialogues[dialogue_id]


func is_playing() -> bool:
	return _current != ""


## Chạy cảnh hội thoại (đang có cảnh khác thì xếp hàng). Trả về kết quả của sự kiện "result" (nếu có).
func play(dialogue_id: String) -> String:
	if _current != "":
		_queue.append(dialogue_id)
		return ""
	var dialogue := load_dialogue(dialogue_id)
	if dialogue.is_empty():
		return ""
	_current = dialogue_id
	_result = ""
	played.append(dialogue_id)
	dialogue_started.emit(dialogue_id)
	if auto_play:
		_run_instantly(dialogue)
		_on_box_finished()
		return _result
	box.open(dialogue)
	var finished: Array = await dialogue_finished
	return str(finished[1])


## Chạy hết cảnh không cần giao diện (test): áp mọi sự kiện, chọn theo auto_choices.
func _run_instantly(dialogue: Dictionary) -> void:
	var lines: Array = dialogue.get("lines", [])
	var index := 0
	var guard := 0
	while index >= 0 and index < lines.size() and guard < 1000:
		guard += 1
		var line: Dictionary = lines[index]
		apply_events(line.get("events", []))
		if line.has("choices"):
			var choices: Array = line["choices"]
			var pick := clampi(int(auto_choices.get(dialogue["id"], 0)), 0, choices.size() - 1)
			var choice: Dictionary = choices[pick]
			apply_events(choice.get("events", []))
			index = -1 if bool(choice.get("end", false)) else find_label(lines, str(choice.get("goto", "")), index + 1)
			continue
		if bool(line.get("end", false)):
			break
		index = find_label(lines, str(line.get("goto", "")), index + 1)


## Chỉ số câu có nhãn `label`; rỗng thì trả về `fallback`.
static func find_label(lines: Array, label: String, fallback: int) -> int:
	if label.is_empty():
		return fallback
	for i in lines.size():
		if str(lines[i].get("label", "")) == label:
			return i
	return fallback


func _on_box_finished() -> void:
	var finished_id := _current
	_current = ""
	dialogue_finished.emit(finished_id, _result)
	story_changed.emit()
	if not _queue.is_empty():
		play(_queue.pop_front())


## Sự kiện của câu thoại / lựa chọn.
func apply_events(events: Array) -> void:
	for event: Variant in events:
		if not event is Dictionary:
			continue
		match str(event.get("type", "")):
			"set_flag":
				GameState.set_story_flag(StringName(str(event["flag"])))
			"give_character":
				give_character(StringName(str(event["id"])))
			"result":
				_result = str(event.get("value", ""))
			_:
				push_warning("StoryManager: sự kiện lạ %s" % event)


## Nhận nhân vật theo cốt truyện: vào danh sách sở hữu ở cấp trung bình của đội (đột phá tương ứng, để không
## phải cày lại từ cấp 1), còn chỗ thì vào đội luôn.
func give_character(character_id: StringName) -> void:
	if GameState.owned_characters.has(character_id):
		return
	var level := GameState.get_team_level()
	GameState.grant_character(character_id)
	if level > 1 and not GameState.character_progress.has(String(character_id)):
		# Lv 1–10: chưa đột phá, 11–20: 1 lần, 21–30: 2 lần (đúng mốc 10 / 20).
		GameState.character_progress[String(character_id)] = {"level": level, "ascension": (level - 1) / 10}
	if GameState.team.size() < GameConfig.MAX_TEAM_SIZE and not GameState.team.has(character_id):
		var team := GameState.team.duplicate()
		team.append(character_id)
		GameState.set_team(team)
	EventBus.team_hp_changed.emit()


# --- Người nói ---

func get_speaker(speaker_id: String) -> Dictionary:
	return data.get("speakers", {}).get(speaker_id, {})


func speaker_name(speaker_id: String) -> String:
	var speaker := get_speaker(speaker_id)
	if speaker.has("character"):
		var character := DataPaths.load_character(StringName(str(speaker["character"])))
		if character:
			return UiKit.character_name(character)
	return format_text(tr(str(speaker.get("name", ""))))


func speaker_color(speaker_id: String) -> Color:
	var speaker := get_speaker(speaker_id)
	if speaker.has("character"):
		var character := DataPaths.load_character(StringName(str(speaker["character"])))
		if character:
			return UiKit.character_color(character)
	return Color(str(speaker.get("color", "#888888")))


func format_text(value: String) -> String:
	return value.replace("{player}", GameState.player_name)


# --- NPC, điểm kích hoạt, vật cốt truyện ---

## Cảnh của NPC theo cờ hiện tại ("" nếu không có).
func npc_dialogue(npc_id: StringName) -> String:
	var npc: Dictionary = data.get("npcs", {}).get(String(npc_id), {})
	for option: Dictionary in npc.get("options", []):
		if check(option.get("if", []), option.get("unless", [])):
			return str(option["dialogue"])
	return ""


func npc_speaker(npc_id: StringName) -> String:
	return str(data.get("npcs", {}).get(String(npc_id), {}).get("speaker", String(npc_id)))


func talk(npc_id: StringName) -> void:
	var dialogue := npc_dialogue(npc_id)
	if not dialogue.is_empty():
		play(dialogue)


## Điểm kích hoạt có id (vùng / vật cốt truyện) còn chạy được không.
func can_fire(trigger_id: StringName) -> bool:
	var trigger: Dictionary = data.get("triggers", {}).get(String(trigger_id), {})
	return not trigger.is_empty() and check(trigger.get("if", []), trigger.get("unless", []))


## Chạy điểm kích hoạt (một lần nhờ cờ "unless"). Trả về true nếu đã chạy.
func fire(trigger_id: StringName) -> bool:
	if not can_fire(trigger_id):
		return false
	var trigger: Dictionary = data["triggers"][String(trigger_id)]
	if trigger.has("set"):
		GameState.set_story_flag(StringName(str(trigger["set"])))
	play(str(trigger["dialogue"]))
	return true


## Map vừa nạp xong: chạy cảnh đang chờ (sau trận boss) rồi điểm kích hoạt "map" của khu.
func map_ready(zone: StringName) -> void:
	if SceneRouter.is_busy():
		await SceneRouter.transition_finished
	for dialogue_id: Variant in pop_pending():
		play(str(dialogue_id))
	var triggers: Dictionary = data.get("triggers", {})
	for trigger_id: String in triggers:
		var trigger: Dictionary = triggers[trigger_id]
		if str(trigger.get("kind", "")) == "map" and StringName(str(trigger.get("zone", ""))) == zone:
			fire(StringName(trigger_id))


func get_pending() -> Array:
	var pending: Variant = GameState.get_story_flag(StringName(PENDING_FLAG), [])
	return pending if pending is Array else []


func pop_pending() -> Array:
	var pending := get_pending().duplicate()
	GameState.story_flags.erase(PENDING_FLAG)
	return pending


## Thắng trận có móc cốt truyện (boss, trận hướng dẫn): bật cờ, xếp cảnh chờ về map.
func _on_encounter_cleared(encounter: Resource, _info: Dictionary) -> void:
	var data_res := encounter as EncounterData
	if data_res == null:
		return
	var hook: Dictionary = data.get("battle_hooks", {}).get(String(data_res.id), {})
	if hook.is_empty() or not check([], hook.get("unless", [])):
		return
	if has_flag(str(hook["flag"])) and get_pending().has(hook["dialogue"]):
		return
	GameState.set_story_flag(StringName(str(hook["flag"])))
	var pending := get_pending().duplicate()
	if not pending.has(hook["dialogue"]):
		pending.append(hook["dialogue"])
	GameState.story_flags[PENDING_FLAG] = pending


# --- Nhiệm vụ ---

## Bước nhiệm vụ chính hiện tại ({} nếu đã xong hết).
func get_main_step() -> Dictionary:
	for step: Dictionary in data.get("main_quest", []):
		if not has_flag(str(step["done"])):
			return step
	return {}


## Bước hiện tại của các nhiệm vụ phụ đang mở (đã qua cờ "unlock", chưa xong): [{ "quest", "step" }].
func get_side_steps() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for quest: Dictionary in data.get("side_quests", []):
		if not has_flag(str(quest["unlock"])):
			continue
		for step: Dictionary in quest.get("steps", []):
			if not has_flag(str(step["done"])):
				result.append({"quest": quest, "step": step})
				break
	return result


func is_side_quest_done(quest_id: String) -> bool:
	for quest: Dictionary in data.get("side_quests", []):
		if quest["id"] == quest_id:
			var steps: Array = quest.get("steps", [])
			return not steps.is_empty() and has_flag(str(steps[-1]["done"]))
	return false
