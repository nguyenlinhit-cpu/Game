extends Node
## Kiểm thử Phase 2: di chuyển, lướt, va chạm tường, 4 phòng + hành lang, khóa/mở cửa,
## minimap, rương, Hộp Bí Kỹ, phòng nghỉ, joystick ảo. Đi bộ thật bằng input giả lập.
## Chạy: godot --headless --path . res://tests/phase02_test.tscn

const TIMEOUT_SEC: float = 90.0
const MOVE_ACTIONS: Array[String] = ["move_left", "move_right", "move_up", "move_down"]

var _failures: Array[String] = []
var _checks: int = 0
var _map: OverworldMap
var _player: Player
var _rooms: RoomManager


func _ready() -> void:
	if get_tree().current_scene == self:
		get_tree().root.add_child.call_deferred((get_script() as GDScript).new())
		return
	get_tree().create_timer(TIMEOUT_SEC).timeout.connect(func() -> void:
		_fail("Quá thời gian %d giây" % TIMEOUT_SEC)
		_finish())
	_run()


func _run() -> void:
	# Quái của Phase 3 đứng yên để không kéo người chơi vào trận giữa chừng.
	OverworldEnemy.debug_frozen = true
	GameState.set_player_identity(GameState.GENDER_FEMALE, "Linh")
	SceneRouter.go_to(DataPaths.TEST_MAP_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
	_map = get_tree().current_scene as OverworldMap
	_player = _map.player
	_rooms = _map.room_manager
	await _frames(5)

	await _test_layout()
	await _test_movement()
	await _test_rest_room()
	await _test_combat_room()
	await _test_chest_room()
	await _test_boss_room()
	await _test_touch_controls()
	_finish()


func _test_layout() -> void:
	_check(_rooms.rooms.size() == 4, "Map có 4 phòng")
	_check(_rooms.connections.size() == 3, "Có 3 hành lang nối phòng")
	_check(_map.corridor_layer.get_used_cells().size() > 100, "Hành lang được vẽ ra TileMapLayer")
	var rest := _rooms.get_room(&"rest_01")
	var combat := _rooms.get_room(&"combat_01")
	var boss := _rooms.get_room(&"boss_01")
	_check(rest.connected_sides == Room.Side.EAST, "Phòng nghỉ chỉ mở cửa phía Đông")
	_check(combat.connected_sides == Room.Side.WEST | Room.Side.EAST | Room.Side.NORTH,
			"Phòng chiến đấu mở cửa Tây, Đông, Bắc")
	_check(boss.connected_sides == Room.Side.SOUTH, "Phòng boss mở cửa phía Nam")
	_check(rest.wall_layer.get_cell_atlas_coords(Vector2i(0, -rest.get_half_extent().y)) == TileIds.WALL,
			"Lỗ cửa không dùng được bịt tường")
	_check(_rooms.current_room == rest and _rooms.get_visited_count() == 1,
			"Bắt đầu trong phòng nghỉ, minimap đánh dấu 1 phòng")
	_check(_map.camera.limit_left > -CameraRig.NO_LIMIT, "Camera bị giới hạn theo phòng")


func _test_movement() -> void:
	var cfg := _player.movement
	_press(Vector2.RIGHT)
	await _seconds(0.04)
	var early_speed := _player.velocity.length()
	await _seconds(0.4)
	var full_speed := _player.velocity.length()
	_release()
	await _seconds(0.3)
	_check(early_speed > 0.0 and early_speed < cfg.max_speed * 0.8, "Có gia tốc (không đạt tốc tối đa ngay)")
	_check(absf(full_speed - cfg.max_speed) < 5.0, "Đạt tốc độ tối đa %.0f px/s" % cfg.max_speed)
	_check(_player.velocity.length() < 1.0, "Thả phím thì giảm tốc về 0")

	_press(Vector2(1, 1))
	await _seconds(0.3)
	_release()
	_check(_player.get_facing_name() == "se", "Đi chéo xuống phải → hướng 'se'")

	_check(_player.try_dash(Vector2.UP), "Lướt được")
	_check(_player.is_invincible() and _player.is_dashing(), "Đang lướt thì bất tử")
	_check(not _player.try_dash(Vector2.UP), "Không lướt liên tiếp khi đang hồi chiêu")
	await _seconds(cfg.dash_invincibility + 0.05)
	_check(not _player.is_invincible(), "Hết bất tử sau %.2f giây" % cfg.dash_invincibility)
	await _seconds(cfg.dash_cooldown)
	_check(_player.try_dash(Vector2.DOWN), "Hết hồi chiêu thì lướt lại được")
	await _seconds(0.3)

	# Đâm vào tường trái phòng nghỉ: không được lọt ra ngoài.
	var rest := _rooms.get_room(&"rest_01")
	_press(Vector2.LEFT)
	await _seconds(2.0)
	_release()
	_check(_player.global_position.x > rest.get_world_rect().position.x + Room.TILE_SIZE,
			"Tường chặn nhân vật")


func _test_rest_room() -> void:
	var rest := _rooms.get_room(&"rest_01")
	var rest_point := rest.find_child("RestPoint", true, false) as RestPoint
	await _walk_to(rest_point.global_position + Vector2(0, 70))
	_check(_player.get_focused_interactable() == rest_point, "Đứng gần điểm nghỉ thì hiện lời nhắc")
	_send_action("interact")
	await _frames(3)
	_check(_map.hud.get_toast_text() == tr("TOAST_RESTED"), "Tương tác điểm nghỉ (log tạm)")

	var box := rest.find_child("TechniqueBox1", true, false) as TechniqueBox
	await _walk_to(box.global_position + Vector2(0, 70))
	_send_action("interact")
	await _frames(3)
	_check(box.is_broken, "Phá được Hộp Bí Kỹ bằng F")


func _test_combat_room() -> void:
	var combat := _rooms.get_room(&"combat_01")
	await _walk_to(combat.get_center_world() + Vector2(-500, 0))
	_check(_rooms.current_room == combat, "Đi qua hành lang vào phòng chiến đấu")
	await _seconds(0.3)
	_check(combat.are_doors_locked(), "Vào phòng còn quái thì khóa cửa")
	_check(combat.get_doors().all(func(door: Door) -> bool: return door.is_closed()), "Mọi cửa đều đóng")

	var before_x := _player.global_position.x
	_press(Vector2.LEFT)
	await _seconds(2.0)
	_release()
	_check(_player.global_position.x > combat.get_world_rect().position.x + Room.TILE_SIZE \
			and _rooms.current_room == combat,
			"Cửa khóa chặn đường lui (x %.0f → %.0f)" % [before_x, _player.global_position.x])

	_send_action("debug_clear_enemies")
	await _seconds(0.5)
	_check(not combat.has_enemies(), "Phím debug F8 xóa hết nhóm quái")
	_check(not combat.are_doors_locked(), "Hết quái thì mở cửa")
	await _seconds(0.3)


func _test_chest_room() -> void:
	var chest_room := _rooms.get_room(&"chest_01")
	var chest := chest_room.find_child("Chest1", true, false) as Chest
	await _walk_to(chest.global_position + Vector2(0, 80))
	_check(_rooms.current_room == chest_room, "Vào phòng rương")
	_send_action("interact")
	await _frames(3)
	_check(chest.is_opened, "Mở rương bằng F")
	_check(_player.get_focused_interactable() == null, "Rương đã mở không nhắc nữa")


func _test_boss_room() -> void:
	var combat := _rooms.get_room(&"combat_01")
	var boss := _rooms.get_room(&"boss_01")
	await _walk_to(combat.get_center_world())
	await _walk_to(boss.get_center_world())
	_check(_rooms.current_room == boss, "Đi lên phòng boss qua cửa Bắc")
	_check(not boss.are_doors_locked(), "Phòng boss trống không khóa cửa")
	_check(_rooms.get_visited_count() == 4, "Minimap đã khám phá đủ 4 phòng")


func _test_touch_controls() -> void:
	var was_forced := UserSettings.is_touch_controls_forced()
	UserSettings.set_touch_controls_forced(true)
	EventBus.settings_changed.emit()
	var touch_controls := _map.hud.get_node("%TouchControls") as TouchControls
	_check(touch_controls.visible, "Bật trong Cài đặt thì hiện điều khiển cảm ứng")
	await _frames(2)
	var joystick := touch_controls.get_node("%Joystick") as TouchJoystick
	var center := joystick.get_global_rect().get_center()
	var start := _player.global_position
	_touch(0, center, true)
	_drag(0, center + Vector2(joystick.radius, 0))
	await _seconds(0.5)
	_check(joystick.vector.x > 0.9, "Kéo joystick sang phải")
	_check(_player.global_position.x - start.x > 50.0, "Joystick ảo làm nhân vật đi sang phải")
	_touch(0, center + Vector2(joystick.radius, 0), false)
	await _seconds(0.3)
	_check(_player.velocity.length() < 1.0, "Thả joystick thì dừng")

	var dash_button := touch_controls.dash_button
	await _seconds(_player.movement.dash_cooldown)
	_touch(1, dash_button.get_global_rect().get_center(), true)
	await _frames(2)
	_touch(1, dash_button.get_global_rect().get_center(), false)
	_check(_player.get_dash_cooldown_ratio() > 0.0, "Nút Lướt cảm ứng kích hoạt lướt")
	UserSettings.set_touch_controls_forced(was_forced)


# --- Tiện ích ---

func _walk_to(target: Vector2, timeout: float = 15.0) -> void:
	var elapsed := 0.0
	while elapsed < timeout:
		var offset := target - _player.global_position
		if offset.length() < 24.0:
			break
		_press(offset.normalized())
		await get_tree().physics_frame
		elapsed += get_physics_process_delta_time()
	_release()
	await _seconds(0.2)
	if _player.global_position.distance_to(target) > 40.0:
		_fail("Không đi tới được %s (đang ở %s)" % [target, _player.global_position])


func _press(direction: Vector2) -> void:
	_set_action("move_right", direction.x)
	_set_action("move_left", -direction.x)
	_set_action("move_down", direction.y)
	_set_action("move_up", -direction.y)


func _set_action(action: StringName, strength: float) -> void:
	if strength > 0.0:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)


func _release() -> void:
	for action in MOVE_ACTIONS:
		Input.action_release(action)


func _send_action(action: StringName) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
	Input.flush_buffered_events()


func _touch(index: int, position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = _to_window(position)
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _drag(index: int, position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = _to_window(position)
	Input.parse_input_event(event)
	Input.flush_buffered_events()


## Input.parse_input_event nhận toạ độ cửa sổ; đổi từ toạ độ viewport 1920×1080 đã co giãn.
func _to_window(viewport_position: Vector2) -> Vector2:
	return get_viewport().get_final_transform() * viewport_position


func _seconds(duration: float) -> void:
	await get_tree().create_timer(duration, true, true).timeout


func _frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame


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
	_release()
	print("Phase 2: %d/%d kiểm tra đạt" % [_checks - _failures.size(), _checks])
	get_tree().quit(1 if not _failures.is_empty() else 0)
