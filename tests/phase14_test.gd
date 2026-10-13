extends "res://tests/test_base.gd"
## Kiểm thử Phase 14: lưu/tải ở mọi trạng thái (giữa khu, sau gacha, sau nhận thưởng nhiệm vụ, giữa ngày làm mới),
## 3 ô lưu + ô tự lưu, tóm tắt ô lưu, chuyển đổi save đời cũ (v1, v3), màn Lưu / Tải (lưu đè, tải, xóa có xác nhận),
## màn tiêu đề (hỏi trước khi ghi đè, nút Tải), cài đặt (tốc độ chữ, ngôn ngữ, gán lại phím, độ phân giải), âm thanh
## (nhạc theo khu, chuyển chéo, pool hiệu ứng), nút Menu cảm ứng, giới hạn cấp 30 / đội 4 người.
## Chạy: godot --headless --path . res://tests/phase14_test.tscn

const SAVE_DIR: String = "user://test_phase14_saves"
const DAY: int = 86400


func _run() -> void:
	phase_name = "Phase 14"
	timeout_sec = 300.0
	SaveManager.save_dir = SAVE_DIR
	for slot in SaveManager.get_all_slots():
		SaveManager.delete_slot(slot)
	QuestManager.utc_bias_minutes = 0
	QuestManager.autosave_on_claim = false
	GachaManager.autosave = false
	StoryManager.auto_play = true
	await _test_save_mid_zone()
	_test_save_after_gacha()
	_test_save_after_quest()
	_test_save_across_reset()
	_test_migration()
	await _test_slots_panel()
	await _test_title()
	_test_settings()
	await _test_audio_and_touch()
	_test_limits()
	_cleanup()
	_finish()


func _cleanup() -> void:
	StoryManager.auto_play = false
	QuestManager.now_override = -1
	QuestManager.last_seen_unix = 0
	QuestManager.autosave_on_claim = true
	GachaManager.autosave = true
	get_tree().paused = false
	for slot in SaveManager.get_all_slots():
		SaveManager.delete_slot(slot)
	SaveManager.save_dir = "user://saves"
	GameState.reset_new_game()


func _unix(y: int, m: int, d: int, h: int, mi: int = 0) -> int:
	return Time.get_unix_time_from_datetime_dict({"year": y, "month": m, "day": d, "hour": h, "minute": mi, "second": 0})


func _clock(unix: int, forget: bool = false) -> void:
	QuestManager.now_override = unix
	if forget:
		QuestManager.last_seen_unix = 0


func _go(scene: String, payload: Dictionary = {}) -> OverworldMap:
	SceneRouter.go_to(scene, payload, 0.01)
	await SceneRouter.transition_finished
	await _frames(6)
	return get_tree().current_scene as OverworldMap


# --- Lưu ở mọi trạng thái ---

func _test_save_mid_zone() -> void:
	_clock(_unix(2026, 10, 14, 10), true)
	GameState.reset_new_game()
	StoryManager.begin_new_story()
	for flag in ["prologue_awake", "prologue_done", "ch1_briefed", "zone_library_open", "library_entered"]:
		GameState.set_story_flag(StringName(flag))
	StoryManager.give_character(&"mira")
	var map := await _go(StoryManager.get_zone_scene(&"library"), {"spawn_room": &"L01"})
	var enemy := map.room_manager.get_room(&"L02").find_child("Enemy1", true, false) as OverworldEnemy
	var enemy_id := map._persistent_id(enemy)
	GameState.map_state_add(map.scene_file_path, "defeated_enemies", enemy_id)
	var chest := map.room_manager.get_room(&"L02").find_child("Chest1", true, false) as Chest
	chest.open()
	map.player.global_position = map.room_manager.get_room(&"L02").get_center_world() + Vector2(64, 32)
	_check(SaveManager.can_save_now(), "Đang ở map: lưu được")
	GameState.set_map_player(map.scene_file_path, map.player.global_position, Vector2.RIGHT)
	_check(SaveManager.save_game(2), "Lưu giữa khu vào ô 2")
	var position := map.player.global_position
	var coins := GameState.get_item_count(&"aether_coin")
	var info := SaveManager.get_slot_info(2)
	_check(info["zone"] == "library" and info["player_name"] == GameState.player_name and info["version"] == SaveManager.SAVE_VERSION,
			"Tóm tắt ô lưu: khu, tên, phiên bản %d" % SaveManager.SAVE_VERSION)
	GameState.reset_new_game()
	_check(SaveManager.load_game(2), "Tải ô 2")
	SaveSlotsPanel.go_to_loaded_map(get_tree())
	await SceneRouter.transition_finished
	await _frames(6)
	map = get_tree().current_scene as OverworldMap
	_check(map.scene_file_path == StoryManager.get_zone_scene(&"library") and map.player.global_position.distance_to(position) < 1.0,
			"Tải giữa khu: về đúng khu, đúng chỗ đứng")
	_check(GameState.map_state_has(map.scene_file_path, "defeated_enemies", enemy_id)
			and (map.room_manager.get_room(&"L02").find_child("Chest1", true, false) as Chest).is_opened
			and GameState.get_item_count(&"aether_coin") == coins, "Tải giữa khu: quái đã hạ, rương đã mở, túi đồ giữ nguyên")
	_check(GameState.team.has(&"mira") and StoryManager.has_flag("library_entered"), "Tải giữa khu: đội và cờ cốt truyện giữ nguyên")


func _test_save_after_gacha() -> void:
	GameState.set_story_flag(&"chapter_1_complete")
	GameState.add_item(&"wish_ticket_limited", 10)
	GachaManager.pull(&"limited_celestine", 10)
	var gacha := GachaManager.to_dict()
	var owned := GameState.owned_characters.duplicate()
	SaveManager.save_game(3)
	GachaManager.reset()
	GameState.reset_new_game()
	SaveManager.load_game(3)
	var after := GachaManager.to_dict()
	_check(after["pity_state"] == gacha["pity_state"] and after["history"] == gacha["history"] and after["rng_state"] == gacha["rng_state"]
			and GameState.owned_characters == owned, "Lưu sau gacha: bộ đếm, lịch sử, RNG, nhân vật nhận được giữ nguyên")


func _test_save_after_quest() -> void:
	_clock(_unix(2026, 10, 14, 10))
	QuestManager.check_reset()
	QuestManager.report(&"battle_won", 3)
	QuestManager.report(&"login")
	var claimable := QuestManager.is_milestone_claimable(0)
	QuestManager.claim_milestone(0)
	var tears := GameState.get_item_count(&"star_tear")
	SaveManager.save_game(1)
	GameState.reset_new_game()
	SaveManager.load_game(1)
	_check(claimable and QuestManager.claimed_milestones.has(100) and not QuestManager.is_milestone_claimable(0)
			and GameState.get_item_count(&"star_tear") == tears, "Lưu sau nhận thưởng nhiệm vụ: không nhận lại được, Lệ Tinh giữ nguyên")


func _test_save_across_reset() -> void:
	_clock(_unix(2026, 10, 14, 3, 50))
	var points := QuestManager.activity_points
	SaveManager.save_game(1)
	_clock(_unix(2026, 10, 15, 4, 10))
	GameState.reset_new_game()
	SaveManager.load_game(1)
	_check(QuestManager.day_index == QuestManager.day_of(_unix(2026, 10, 15, 4, 10)) and QuestManager.activity_points == 100
			and QuestManager.claimed_milestones.is_empty(),
			"Lưu trước 4:00, tải sau 4:00 hôm sau: nhiệm vụ ngày làm mới, chỉ còn 100 Hoạt Động đăng nhập (trước đó %d)" % points)
	var day := QuestManager.day_index
	SaveManager.save_game(1)
	_clock(_unix(2026, 10, 13, 12))
	SaveManager.load_game(1)
	_check(QuestManager.day_index == day and QuestManager.last_seen_unix >= _unix(2026, 10, 15, 4, 10),
			"Tải khi giờ máy bị lùi: không làm mới, giữ mốc giờ chống chỉnh giờ")
	_clock(_unix(2026, 10, 15, 4, 10))


func _test_migration() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var v1 := {"version": 1, "game_state": {"player_name": "Cu", "player_gender": "female", "team_level": 12,
			"owned_characters": ["traveler", "mira"], "team": ["traveler", "mira"]}}
	var file := FileAccess.open(SaveManager.get_slot_path(3), FileAccess.WRITE)
	file.store_string(JSON.stringify(v1))
	file.close()
	var info := SaveManager.get_slot_info(3)
	_check(info["player_name"] == "Cu" and info["version"] == 1, "Ô lưu đời cũ (v1, chưa có tóm tắt) vẫn hiện tên")
	_check(SaveManager.load_game(3) and GameState.player_name == "Cu" and Progression.get_level(&"mira") == 12
			and GameState.team_level == 0, "Tải save v1: chuyển cấp đội cũ thành cấp từng nhân vật")
	var v3 := {"version": 3, "game_state": GameState.to_dict(), "gacha": {"pity_state": {}, "history": []}, "quests": {}}
	file = FileAccess.open(SaveManager.get_slot_path(3), FileAccess.WRITE)
	file.store_string(JSON.stringify(v3))
	file.close()
	_check(SaveManager.load_game(3) and GachaManager.history.is_empty(), "Tải save v3 (trước gacha) không lỗi")
	file = FileAccess.open(SaveManager.get_slot_path(3), FileAccess.WRITE)
	file.store_string("{hỏng")
	file.close()
	_check(not SaveManager.load_game(3) and SaveManager.get_slot_info(3).get("corrupt", false), "File hỏng: báo hỏng, không tải")
	SaveManager.delete_slot(3)


# --- Màn Lưu / Tải ---

func _test_slots_panel() -> void:
	var map := get_tree().current_scene as OverworldMap
	var pause := map.hud.get_node("PauseMenu") as PauseMenu
	pause.open()
	var panel := pause.open_save_slots()
	await _frames(2)
	_check(panel.mode == SaveSlotsPanel.Mode.SAVE and panel.get_slot_button(0, "save").disabled,
			"Lưu / Tải trong menu: thẻ Lưu, ô tự lưu không lưu tay được")
	GameState.player_name = "Ghi"
	panel.get_slot_button(2, "save").pressed.emit()
	await _frames(1)
	_check(panel.confirm_box != null, "Ô 2 đã có: hỏi trước khi ghi đè")
	(panel.confirm_box.get_meta("yes") as Button).pressed.emit()
	await _frames(1)
	_check(SaveManager.get_slot_info(2)["player_name"] == "Ghi", "Đồng ý: ghi đè ô 2")
	panel.get_slot_button(3, "save").pressed.emit()
	await _frames(1)
	_check(SaveManager.has_save(3), "Ô trống: lưu luôn không hỏi")
	panel.get_slot_button(3, "delete").pressed.emit()
	await _frames(1)
	(panel.confirm_box.get_meta("yes") as Button).pressed.emit()
	await _frames(1)
	_check(not SaveManager.has_save(3), "Xóa ô 3 (có hỏi)")
	panel.show_mode(SaveSlotsPanel.Mode.LOAD)
	GameState.player_name = "Khác"
	panel.get_slot_button(2, "load").pressed.emit()
	await _frames(1)
	(panel.confirm_box.get_meta("yes") as Button).pressed.emit()
	await SceneRouter.transition_finished
	await _frames(4)
	_check(GameState.player_name == "Ghi" and get_tree().current_scene is OverworldMap and not get_tree().paused,
			"Thẻ Tải: tải ô 2 rồi về map, game chạy tiếp")


func _test_title() -> void:
	SceneRouter.go_to(DataPaths.TITLE_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
	await _frames(2)
	var title := get_tree().current_scene
	_check(not title.load_button.disabled, "Màn tiêu đề có nút Tải game")
	SaveManager.save_game(0)
	title._on_start_pressed()
	await _frames(1)
	var box := title.find_child("ConfirmBox", true, false) as Control
	_check(box != null, "Bắt đầu mới khi có ô tự lưu: hỏi xác nhận")
	(box.get_meta("no") as Button).pressed.emit()
	await _frames(1)
	_check(get_tree().current_scene == title, "Chọn Quay lại: không bắt đầu game mới")
	title.open_load()
	await _frames(1)
	_check(title.slots_panel.mode == SaveSlotsPanel.Mode.LOAD and title.slots_panel.get_slot_button(1, "save") == null,
			"Tải từ màn tiêu đề: chỉ có thẻ Tải")
	title.slots_panel.close()


# --- Cài đặt ---

func _test_settings() -> void:
	UserSettings.set_value("general", "text_speed", "fast")
	_check(is_equal_approx(UserSettings.text_speed(), 1.6), "Tốc độ chữ: Nhanh ×1,6")
	UserSettings.set_value("general", "text_speed", "normal")
	UserSettings.set_locale("en")
	_check(tr("MENU_GACHA") == "Wish", "Đổi ngôn ngữ sang English")
	UserSettings.set_locale("vi")
	_check(tr("MENU_GACHA") == "Ước Nguyện", "Đổi lại Tiếng Việt")
	var old_dash := UserSettings.get_key("dash")
	UserSettings.set_key("dash", KEY_L, false)
	var event := InputEventKey.new()
	event.physical_keycode = KEY_L
	_check(UserSettings.get_key("dash") == KEY_L and InputMap.event_is_action(event, "dash"), "Gán lại phím Lướt = L")
	UserSettings.set_key("interact", KEY_L, false)
	_check(UserSettings.get_key("interact") == KEY_L and UserSettings.get_key("dash") == 0,
			"Gán phím đang dùng cho hành động khác: gỡ ở hành động cũ")
	UserSettings.reset_keys()
	_check(UserSettings.get_key("dash") == old_dash and UserSettings.get_key("interact") == KEY_F
			and InputMap.action_get_events("dash").filter(func(e: InputEvent) -> bool: return e is InputEventKey).size() >= 1,
			"Khôi phục phím mặc định")
	var panel := (load("res://scenes/ui/settings/settings_panel.tscn") as PackedScene).instantiate() as SettingsPanel
	add_child(panel)
	_check(panel._tabs.get_tab_count() == 3 and panel.resolution_option.item_count == 4 and panel.locale_option.item_count == 2
			and panel.get_key_button("technique") != null, "Bảng cài đặt: 3 thẻ, độ phân giải, ngôn ngữ, gán phím")
	panel.start_rebind("technique")
	_check(panel.waiting_action == "technique" and panel.get_key_button("technique").text == tr("SETTINGS_PRESS_KEY"),
			"Bấm ô phím: chờ nhấn phím mới")
	var key := InputEventKey.new()
	key.keycode = KEY_ESCAPE
	key.pressed = true
	panel._input(key)
	_check(panel.waiting_action == "" and UserSettings.get_key("technique") == KEY_K, "Esc: hủy gán, giữ phím cũ")
	panel.queue_free()
	UserSettings.save()


# --- Âm thanh, cảm ứng ---

func _test_audio_and_touch() -> void:
	var map := await _go(StoryManager.get_zone_scene(&"vault"), {"spawn_room": &"V01"})
	_check(AudioManager.current_music_id == &"zone_vault" and AudioManager.get_music_stream() != null, "Vào Kho Chứa: nhạc khu Kho Chứa")
	map = await _go(DataPaths.HUB_SCENE, {"spawn_room": &"H01"})
	await _seconds(0.2)
	_check(AudioManager.current_music_id == &"zone_hub" and AudioManager._music_players.size() == 2
			and AudioManager._music_players[0].playing and AudioManager._music_players[1].playing,
			"Đổi khu: chuyển chéo nhạc bằng 2 máy phát")
	var before := int(AudioManager.sfx_counts.get(&"dash", 0))
	map.player.try_dash(Vector2.RIGHT)
	_check(int(AudioManager.sfx_counts.get(&"dash", 0)) == before + 1, "Lướt: phát hiệu ứng âm thanh")
	for i in 15:
		AudioManager.play_sfx(&"hit")
	_check(AudioManager._sfx_pool.size() == AudioManager.SFX_POOL_SIZE, "Hiệu ứng dùng pool %d máy phát" % AudioManager.SFX_POOL_SIZE)
	var names := PlaceholderSfx.sounds().keys()
	var all_ok := names.all(func(n: String) -> bool: return PlaceholderSfx.get_stream(StringName(n)) != null)
	_check(all_ok and names.size() >= 15, "%d hiệu ứng âm thanh tổng hợp" % names.size())
	_check(PlaceholderMusic.zone_track(&"tower") == &"zone_tower" and PlaceholderMusic.get_stream(&"title") != null,
			"Nhạc tiêu đề + nhạc 5 khu")
	UserSettings.set_touch_controls_forced(true)
	EventBus.settings_changed.emit()
	var touch := map.hud.get_node("%TouchControls") as TouchControls
	_check(touch.visible and touch.menu_button != null, "Điều khiển cảm ứng có nút Menu")
	touch.menu_button._send(true)
	await _frames(2)
	touch.menu_button._send(false)
	var pause := map.hud.get_node("PauseMenu") as PauseMenu
	_check(pause.visible and get_tree().paused, "Chạm nút Menu: mở menu tạm dừng")
	pause.close()
	UserSettings.set_touch_controls_forced(false)
	EventBus.settings_changed.emit()
	UserSettings.save()


func _test_limits() -> void:
	GameState.reset_new_game()
	var five: Array[StringName] = [&"traveler", &"mira", &"kiri", &"garren", &"nyx"]
	_check(GameConfig.MAX_LEVEL == 30 and not GameState.set_team(five), "Giới hạn cấp 30, đội tối đa 4")
