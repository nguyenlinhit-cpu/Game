extends Node
## Kiểm thử khói Phase 1: tiêu đề → lời dẫn (bỏ qua) → chọn Nữ + đặt tên → phòng trống → lưu/tải.
## Chạy: godot --headless --path . res://tests/phase01_smoke_test.tscn
## Dùng thư mục save riêng nên không đụng save thật.

const TEST_SAVE_DIR: String = "user://test_saves"
const TIMEOUT_SEC: float = 30.0

var _failures: Array[String] = []
var _checks: int = 0


func _ready() -> void:
	if get_tree().current_scene == self:
		# Scene test sẽ bị xóa khi SceneRouter đổi scene, nên tách một bản chạy độc lập dưới root.
		get_tree().root.add_child.call_deferred((get_script() as GDScript).new())
		return
	get_tree().create_timer(TIMEOUT_SEC).timeout.connect(func() -> void:
		_fail("Quá thời gian %d giây" % TIMEOUT_SEC)
		_finish())
	_run()


func _run() -> void:
	SaveManager.save_dir = TEST_SAVE_DIR
	_clear_test_saves()

	get_tree().paused = false
	SceneRouter.go_to(DataPaths.TITLE_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
	var title := get_tree().current_scene
	_check(title.get_node("%ContinueButton").disabled, "Tiếp tục phải mờ khi chưa có save")
	_check(InputMap.has_action("opener_attack") and InputMap.has_action("switch_character_4"),
			"Input map phải có đủ action")

	title.get_node("%StartButton").pressed.emit()
	await SceneRouter.transition_finished
	var intro := get_tree().current_scene
	_check(intro.scene_file_path == DataPaths.INTRO_SCENE, "Bắt đầu phải vào lời dẫn")
	_check(tr("INTRO_P1_L1") != "INTRO_P1_L1", "Chữ lời dẫn phải lấy từ file dịch")
	await get_tree().create_timer(0.3).timeout
	_check(intro.get_node("%Lines").get_child_count() > 0, "Lời dẫn phải đang chạy chữ")

	intro.get_node("%SkipButton").pressed.emit()
	await SceneRouter.transition_finished
	var select := get_tree().current_scene
	_check(select.scene_file_path == DataPaths.CHARACTER_SELECT_SCENE, "Bỏ qua phải tới màn chọn nhân vật")
	var name_edit: LineEdit = select.get_node("%NameEdit")
	_check(name_edit.text == "Kael", "Tên mặc định Nam là Kael")
	select.get_node("%FemaleCard").pressed.emit()
	_check(name_edit.text == "Kaela", "Chọn Nữ thì tên mặc định đổi thành Kaela")
	_check(GameState.sanitize_player_name("  ABCDEFGHIJKLMNOP ", &"male") == "ABCDEFGHIJKL",
			"Tên bị cắt còn 12 ký tự")
	_check(GameState.sanitize_player_name("   ", &"female") == "Kaela", "Tên rỗng dùng tên mặc định")
	name_edit.text = "Linh"
	name_edit.text_changed.emit("Linh")
	select.get_node("%MaleCard").pressed.emit()
	_check(name_edit.text == "Linh", "Tên tự đặt không bị đổi khi đổi giới tính")
	select.get_node("%FemaleCard").pressed.emit()

	select.get_node("%ConfirmButton").pressed.emit()
	await SceneRouter.transition_finished
	var room := get_tree().current_scene
	_check(room.scene_file_path == DataPaths.HUB_SCENE, "Xác nhận phải vào Sảnh Trung Tâm (Phase 12)")
	# Cảnh tỉnh dậy tự mở ở Sảnh: bỏ qua cho test chạy tiếp.
	await get_tree().process_frame
	StoryManager.box.skip()
	var player: Player = room.get_node("%Player")
	_check(player.get_display_name() == "Linh", "Tên trên đầu phải là Linh")
	_check(player.get_skin_id() == &"female", "Skin phải là female")
	_check(GameState.player_gender == &"female" and GameState.player_name == "Linh",
			"GameState lưu đúng giới tính và tên")
	_check(SaveManager.has_any_save(), "Phải có ô tự lưu sau khi tạo nhân vật")

	GameState.reset_new_game()
	_check(SaveManager.load_latest(), "Tải được save")
	_check(GameState.player_name == "Linh" and GameState.player_gender == &"female",
			"Save giữ đúng tên và giới tính")

	get_tree().paused = false
	SceneRouter.go_to(DataPaths.TITLE_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
	_check(not get_tree().current_scene.get_node("%ContinueButton").disabled,
			"Có save thì Tiếp tục phải bấm được")
	_finish()


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("  ĐẠT  ", description)
	else:
		_fail(description)


func _fail(description: String) -> void:
	_failures.append(description)
	printerr("  LỖI  ", description)


func _finish() -> void:
	_clear_test_saves()
	print("Phase 1: %d/%d kiểm tra đạt" % [_checks - _failures.size(), _checks])
	get_tree().quit(1 if not _failures.is_empty() else 0)


func _clear_test_saves() -> void:
	for slot in SaveManager.get_all_slots():
		SaveManager.delete_slot(slot)
