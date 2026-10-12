extends Node
## Kiểm thử Phase 3: AI quái (tuần tra, tầm nhìn, đuổi, bỏ cuộc), 4 kiểu mở trận
## (Ưu Thế, Phục Kích, Bình thường, thắng ngay), thua về phòng nghỉ, ra vào trận 10 lần
## giữ đúng trạng thái map, hạ hết quái thì cửa mở.
## Chạy: godot --headless --path . res://tests/phase03_test.tscn

const TIMEOUT_SEC: float = 180.0
## Lớn hơn start_grace_sec của quái.
const GRACE_WAIT_SEC: float = 1.7

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
	GameState.reset_new_game()
	GameState.set_player_identity(GameState.GENDER_MALE, "Kael")
	SceneRouter.go_to(DataPaths.TEST_MAP_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
	_bind_map()

	await _test_enemy_ai()
	await _test_advantage()
	await _test_instant_win()
	await _test_ambush()
	await _test_normal_and_ten_round_trips()
	_test_save_round_trip()
	_finish()


func _test_enemy_ai() -> void:
	var enemy := _enemy("EnemyGroup1")
	var start := enemy.global_position
	await _seconds(GRACE_WAIT_SEC + 1.0)
	_check(enemy.global_position.distance_to(start) > 40.0 and enemy.state == OverworldEnemy.State.PATROL,
			"Quái tuần tra theo điểm định sẵn")

	# Đứng trước mặt quái trong tầm nhìn → thấy; sau lưng ngoài tầm nghe → không thấy.
	_player.input_enabled = false
	OverworldEnemy.debug_frozen = true
	enemy.facing = Vector2.RIGHT
	_player.global_position = enemy.global_position + Vector2(300, 0)
	await _frames(2)
	_check(enemy.can_see(_player), "Thấy người chơi trong hình nón tầm nhìn")
	_player.global_position = enemy.global_position + Vector2(-300, 0)
	await _frames(2)
	_check(not enemy.can_see(_player), "Không thấy người chơi sau lưng")
	_player.global_position = enemy.global_position + Vector2(-80, 0)
	await _frames(2)
	_check(enemy.can_see(_player), "Đứng sát sau lưng thì quái vẫn nhận ra")
	# Phòng nghỉ cách tường: trong tầm nhìn nhưng bị tường chắn.
	var rest := _rooms.get_room(&"rest_01")
	_player.global_position = Vector2(rest.get_world_rect().end.x - 100, enemy.global_position.y)
	enemy.facing = enemy.global_position.direction_to(_player.global_position)
	var far_config := enemy.config.duplicate() as OverworldEnemyConfig
	far_config.vision_range = 5000.0
	var old_config := enemy.config
	enemy.config = far_config
	await _frames(2)
	_check(not enemy.can_see(_player), "Tường chắn tầm nhìn")
	enemy.config = old_config

	# Đuổi rồi bỏ cuộc: hiện ra trước mặt, đợi báo động, rồi dịch ra thật xa.
	# Đứng trong tầm nghe (quái đang tuần tra sẽ quay hướng); bất tử để không bị kéo vào trận.
	_player.grant_invincibility(10.0)
	_player.global_position = enemy.global_position + Vector2(0, 90)
	OverworldEnemy.debug_frozen = false
	await _seconds(0.6)
	_check(enemy.state != OverworldEnemy.State.PATROL, "Thấy người chơi thì báo động và đuổi (trạng thái %s)"
			% OverworldEnemy.State.keys()[enemy.state])
	_player.global_position = rest.get_spawn_point()
	# Đợi hết đòn vồ đang dở (gồng + vồ + hồi ≈ 1,2 giây).
	await _seconds(1.5)
	_check(enemy.state == OverworldEnemy.State.RETURN, "Người chơi ra quá xa thì quái bỏ cuộc quay về")
	await _seconds(3.0)
	_player.grant_invincibility(0.0)
	_player.input_enabled = true


func _test_advantage() -> void:
	var enemy := _enemy("EnemyGroup1")
	OverworldEnemy.debug_frozen = true
	_player.global_position = enemy.global_position + Vector2(-90, 0)
	_player.facing = Vector2.RIGHT
	await _frames(2)
	OverworldEnemy.debug_frozen = false
	_check(_player.try_opener(), "Dùng được Đòn Mở Màn")
	var battle := await _await_battle()
	_check(battle != null and battle.get_opening() == BattleTypes.Opening.ADVANTAGE, "Chém trúng trước → Ưu Thế")
	var enemy_id := str(GameState.pending_battle.get("enemy_id", ""))
	var saved_position: Vector2 = GameState.get_map_player_position(DataPaths.TEST_MAP_SCENE)
	await _press_battle_button(battle, true)
	_check(_find_enemy("EnemyGroup1") == null, "Thắng → nhóm quái biến mất khỏi map")
	_check(GameState.map_state_has(DataPaths.TEST_MAP_SCENE, "defeated_enemies", enemy_id),
			"Nhóm quái đã hạ được ghi vào GameState")
	_check(_player.global_position.distance_to(saved_position) < 2.0, "Thắng xong quay về đúng chỗ đứng")
	_check(_map.hud.get_toast_text() == tr("TOAST_VICTORY"), "Hiện thông báo chiến thắng")


func _test_instant_win() -> void:
	await _seconds(GRACE_WAIT_SEC)
	var enemy := _enemy("EnemyGroup3")
	GameState.team_level = 11
	_check(enemy.is_trivial_for(GameState.team_level), "Quái Lv1 là quái yếu khi đội Lv11")
	OverworldEnemy.debug_frozen = true
	_player.global_position = enemy.global_position + Vector2(-90, 0)
	_player.facing = Vector2.RIGHT
	await _frames(2)
	OverworldEnemy.debug_frozen = false
	var scene_before := get_tree().current_scene
	_player.try_opener()
	await _seconds(0.5)
	_check(get_tree().current_scene == scene_before and not SceneRouter.is_busy(), "Thắng ngay: không vào trận")
	_check(_map.hud.is_reward_popup_visible(), "Thắng ngay: hiện bảng phần thưởng tạm")
	_check(_find_enemy("EnemyGroup3") == null or enemy.is_defeated(), "Thắng ngay: quái biến mất")
	GameState.team_level = 1


func _test_ambush() -> void:
	var enemy := _enemy("EnemyGroup2")
	OverworldEnemy.debug_frozen = true
	_player.input_enabled = false
	await _seconds(0.2)
	# Trong tầm nghe nhưng ngoài tầm chạm: quái báo động, gồng rồi vồ trúng.
	_player.global_position = enemy.global_position + Vector2(-100, 0)
	await _frames(2)
	OverworldEnemy.debug_frozen = false
	var battle := await _await_battle(5.0)
	_check(battle != null and battle.get_opening() == BattleTypes.Opening.AMBUSHED, "Quái vồ trúng trước → Bị Phục Kích")
	if battle:
		await _press_battle_button(battle, false)
		var rest := _rooms.get_room(&"rest_01")
		_check(_player.global_position.distance_to(rest.get_spawn_point()) < 2.0,
				"Thua → về phòng nghỉ gần nhất")
		_check(_find_enemy("EnemyGroup2") != null, "Thua thì nhóm quái vẫn còn")


func _test_normal_and_ten_round_trips() -> void:
	# Tạo trạng thái để kiểm tra giữ nguyên: mở rương, phá hộp, khám phá đủ phòng.
	var chest := _map.find_child("Chest1", true, false) as Chest
	chest.open()
	var box := _rooms.get_room(&"rest_01").find_child("TechniqueBox1", true, false) as TechniqueBox
	box.break_open()
	for room_id: StringName in [&"chest_01", &"boss_01"]:
		_player.global_position = _rooms.get_room(room_id).get_center_world()
		await _frames(3)
	var visited := _rooms.get_visited_count()
	_check(visited == 4, "Đã khám phá 4 phòng trước khi ra vào trận")

	var ok_rounds := 0
	for round_index in 10:
		await _seconds(GRACE_WAIT_SEC)
		var enemy := _enemy("EnemyGroup2")
		var won := round_index == 9
		# Chạm từ phía sau, quái đang đứng yên → trận Bình thường.
		OverworldEnemy.debug_frozen = true
		_player.global_position = enemy.global_position + Vector2(0, 30)
		await _frames(1)
		OverworldEnemy.debug_frozen = false
		var battle := await _await_battle()
		if battle == null:
			_fail("Vòng %d: không vào được trận" % (round_index + 1))
			continue
		var opening_ok: bool = battle.get_opening() == BattleTypes.Opening.NORMAL
		var saved_position: Vector2 = GameState.get_map_player_position(DataPaths.TEST_MAP_SCENE)
		await _press_battle_button(battle, won)
		var state_ok := (_map.find_child("Chest1", true, false) as Chest).is_opened \
				and (_rooms.get_room(&"rest_01").find_child("TechniqueBox1", true, false) as TechniqueBox).is_broken \
				and _rooms.get_visited_count() == visited \
				and _find_enemy("EnemyGroup1") == null and _find_enemy("EnemyGroup3") == null
		var position_ok := _player.global_position.distance_to(
				saved_position if won else _rooms.get_room(&"rest_01").get_spawn_point()) < 2.0
		var enemy_ok := (_find_enemy("EnemyGroup2") == null) == won
		if opening_ok and state_ok and position_ok and enemy_ok:
			ok_rounds += 1
		else:
			_fail("Vòng %d: mở trận %s, trạng thái %s, vị trí %s, quái %s" % [
					round_index + 1, opening_ok, state_ok, position_ok, enemy_ok])
	_check(ok_rounds == 10, "Ra vào trận 10 lần liên tiếp, map giữ đúng trạng thái (%d/10)" % ok_rounds)

	await _frames(5)
	var combat := _rooms.get_room(&"combat_01")
	_check(not combat.has_enemies(), "Đã hạ hết quái trong phòng chiến đấu")
	_check(not combat.are_doors_locked() and combat.get_doors().all(
			func(door: Door) -> bool: return not door.is_closed()), "Hạ hết quái thì cửa mở")


func _test_save_round_trip() -> void:
	var before := GameState.to_dict()
	GameState.from_dict(JSON.parse_string(JSON.stringify(before)))
	_check(GameState.map_state_has(DataPaths.TEST_MAP_SCENE, "opened_chests", "chest_01/Entities/Chest1"),
			"Trạng thái map còn nguyên sau khi lưu/tải JSON")


# --- Tiện ích ---

func _bind_map() -> void:
	_map = get_tree().current_scene as OverworldMap
	_player = _map.player
	_rooms = _map.room_manager


func _enemy(enemy_name: String) -> OverworldEnemy:
	var enemy := _find_enemy(enemy_name)
	if enemy == null:
		_fail("Không tìm thấy %s" % enemy_name)
	return enemy


func _find_enemy(enemy_name: String) -> OverworldEnemy:
	var enemy := _map.find_child(enemy_name, true, false) as OverworldEnemy
	if enemy == null or enemy.is_queued_for_deletion() or enemy.is_defeated():
		return null
	return enemy


## Đợi chuyển sang scene trận, trả về scene trận (null nếu quá hạn).
func _await_battle(timeout: float = 3.0) -> Node:
	var elapsed := 0.0
	while elapsed < timeout:
		var scene := get_tree().current_scene
		if scene and scene.scene_file_path == DataPaths.BATTLE_SCENE and not SceneRouter.is_busy():
			return scene
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	return null


## Trận thật (Phase 4) kết thúc ngay theo kết quả mong muốn rồi bấm nút rời trận.
func _press_battle_button(battle: Node, win: bool) -> void:
	battle.debug_force_result(win)
	await _frames(2)
	battle.get_node("%ContinueButton" if win else "%RetreatButton").pressed.emit()
	await SceneRouter.transition_finished
	_bind_map()
	await _frames(3)


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
	OverworldEnemy.debug_frozen = false
	print("Phase 3: %d/%d kiểm tra đạt" % [_checks - _failures.size(), _checks])
	get_tree().quit(1 if not _failures.is_empty() else 0)
