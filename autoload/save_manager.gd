extends Node
## Lưu/tải game dạng JSON trong user://.
## Phase 1 chỉ dùng ô tự lưu (slot 0). 3 ô lưu tay, giao diện chọn ô và chuyển đổi save cũ làm ở Phase 14.

signal game_saved(slot: int)
signal game_loaded(slot: int)

const SAVE_VERSION: int = 3
const AUTOSAVE_SLOT: int = 0
const MANUAL_SLOTS: Array[int] = [1, 2, 3]

## Đổi được trong test để không đụng save thật.
var save_dir: String = "user://saves"


func get_all_slots() -> Array[int]:
	var slots: Array[int] = [AUTOSAVE_SLOT]
	slots.append_array(MANUAL_SLOTS)
	return slots


func get_slot_path(slot: int) -> String:
	return save_dir.path_join("slot_%d.json" % slot)


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(get_slot_path(slot))


func has_any_save() -> bool:
	return get_latest_slot() != -1


## Ô lưu được ghi gần nhất, -1 nếu chưa có.
func get_latest_slot() -> int:
	var best_slot := -1
	var best_time := -1
	for slot in get_all_slots():
		var path := get_slot_path(slot)
		if not FileAccess.file_exists(path):
			continue
		var modified := int(FileAccess.get_modified_time(path))
		if modified > best_time:
			best_time = modified
			best_slot = slot
	return best_slot


func save_game(slot: int = AUTOSAVE_SLOT) -> bool:
	var dir_err := DirAccess.make_dir_recursive_absolute(save_dir)
	if dir_err != OK:
		push_error("SaveManager: không tạo được thư mục %s (lỗi %d)" % [save_dir, dir_err])
		return false
	var data := {
		"version": SAVE_VERSION,
		"saved_at_unix": int(Time.get_unix_time_from_system()),
		"game_state": GameState.to_dict(),
		"gacha": GachaManager.to_dict(),
		"quests": QuestManager.to_dict(),
	}
	var file := FileAccess.open(get_slot_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: không ghi được ô %d (lỗi %d)" % [slot, FileAccess.get_open_error()])
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	game_saved.emit(slot)
	return true


func load_game(slot: int) -> bool:
	var path := get_slot_path(slot)
	if not FileAccess.file_exists(path):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		push_error("SaveManager: file save hỏng ở ô %d" % slot)
		return false
	var data := _migrate(parsed)
	GameState.from_dict(data.get("game_state", {}))
	GachaManager.from_dict(data.get("gacha", {}))
	QuestManager.from_dict(data.get("quests", {}))
	game_loaded.emit(slot)
	return true


func load_latest() -> bool:
	var slot := get_latest_slot()
	return slot != -1 and load_game(slot)


func delete_slot(slot: int) -> void:
	var path := get_slot_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


## Nâng file save đời cũ lên SAVE_VERSION hiện tại.
func _migrate(data: Dictionary) -> Dictionary:
	var version := int(data.get("version", 0))
	if version > SAVE_VERSION:
		push_warning("SaveManager: save đến từ bản mới hơn (v%d), có thể thiếu dữ liệu" % version)
	if version < 2 and data.get("game_state") is Dictionary:
		# v1 → v2 (Phase 9): team_level cũ là cấp chung của đội → thành cấp riêng từng nhân vật đang có.
		var state: Dictionary = data["game_state"]
		var old_level := int(state.get("team_level", 1))
		var progress := {}
		for id: Variant in state.get("owned_characters", []):
			progress[str(id)] = {"level": clampi(old_level, 1, GameConfig.MAX_LEVEL)}
		state["character_progress"] = progress
		state["team_level"] = 0
	data["version"] = SAVE_VERSION
	return data
