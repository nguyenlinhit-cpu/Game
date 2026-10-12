class_name OverworldMap
extends Node2D
## Map gồm các phòng đặt trên lưới (Room.grid_cell). Hai phòng kề nhau cùng mở cửa ở phía
## đối diện thì được nối bằng hành lang thẳng rộng 3 ô, vẽ vào lớp Corridors lúc chạy.
## Map cũng giữ trạng thái trong GameState.map_states (quái đã hạ, rương đã mở, hộp đã phá,
## phòng đã khám phá, vật cản đã mở, vị trí người chơi), điều phối vào trận / thắng ngay / quay về,
## và chạy Bí Kỹ của người dẫn đầu (tốn Điểm Bí Kỹ dùng chung).

const CORRIDOR_HALF_WIDTH: int = 1
## Bất tử ngắn khi vừa từ trận quay về, để quái gần đó không kéo vào trận ngay.
const RETURN_INVINCIBILITY_SEC: float = 1.0
const DEBUG_TEAM_LEVEL_STEP: int = 5

## Phòng người chơi xuất hiện khi vào map lần đầu.
@export var start_room_id: StringName

var _encounter_started: bool = false

@onready var rooms_root: Node2D = %Rooms
@onready var corridor_layer: TileMapLayer = %Corridors
@onready var room_manager: RoomManager = %RoomManager
@onready var player: Player = %Player
@onready var camera: CameraRig = %CameraRig
@onready var hud: OverworldHud = %Hud


func _ready() -> void:
	GameState.current_map_scene = scene_file_path
	var rooms := _collect_rooms()
	room_manager.setup(rooms, _connect_rooms(rooms))
	room_manager.current_room_changed.connect(_on_current_room_changed)
	_restore_and_track_state()
	_place_player()
	camera.snap_to_target()
	hud.setup(player, room_manager)
	player.technique_requested.connect(use_technique)
	player.obstacle_hit.connect(_on_obstacle_hit)
	_show_battle_result()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event.is_action_pressed("debug_team_level_up"):
		_change_team_level(DEBUG_TEAM_LEVEL_STEP)
	elif event.is_action_pressed("debug_team_level_down"):
		_change_team_level(-DEBUG_TEAM_LEVEL_STEP)


func get_state() -> Dictionary:
	return GameState.get_map_state(scene_file_path)


# --- Vào trận ---

func _on_encounter_triggered(enemy: OverworldEnemy, opening: BattleTypes.Opening) -> void:
	if _encounter_started or SceneRouter.is_busy():
		return
	if opening == BattleTypes.Opening.ADVANTAGE and enemy.is_trivial_for(GameState.team_level):
		_instant_win(enemy)
		return
	_encounter_started = true
	enemy.set_triggered(true)
	player.input_enabled = false
	GameState.set_map_player(scene_file_path, player.global_position, player.facing)
	GameState.begin_battle(scene_file_path, _persistent_id(enemy), enemy.encounter, opening)
	var opener_element: int = int(player.opener.element) if opening == BattleTypes.Opening.ADVANTAGE else Element.NONE
	# Bí Kỹ: "trận kế tiếp" đang chờ + nhóm quái bị Bí Kỹ đánh dấu.
	var techniques := GameState.consume_pending_techniques()
	for mark in enemy.marks:
		if not techniques.has(mark):
			techniques.append(mark)
	SceneRouter.go_to(DataPaths.BATTLE_SCENE, {"encounter": enemy.encounter, "opening": opening,
			"opener_element": opener_element, "techniques": techniques})


## Quái yếu hơn đội ≥10 cấp bị chém trúng: thắng luôn, không vào trận.
func _instant_win(enemy: OverworldEnemy) -> void:
	var rewards := PlaceholderRewards.for_encounter(enemy.encounter)
	print("[OverworldMap] Thắng ngay %s: %s – TODO Phase 10: bảng rơi đồ" % [enemy.name, rewards])
	enemy.defeat()
	hud.show_reward_popup(tr("REWARD_INSTANT_TITLE"), PlaceholderRewards.describe(rewards))
	EventBus.battle_won.emit(enemy.encounter)


func _show_battle_result() -> void:
	var result := str(SceneRouter.payload.get("battle_result", ""))
	if result == "win":
		EventBus.toast_requested.emit(tr("TOAST_VICTORY"))
	elif result == "lose":
		EventBus.toast_requested.emit(tr("TOAST_DEFEAT"))
	if not result.is_empty():
		player.grant_invincibility(RETURN_INVINCIBILITY_SEC)
		SceneRouter.payload.clear()


# --- Trạng thái map ---

func _restore_and_track_state() -> void:
	var scene := scene_file_path
	for node in _all_descendants(rooms_root):
		var id := _persistent_id(node)
		if node is OverworldEnemy:
			var enemy := node as OverworldEnemy
			if GameState.map_state_has(scene, "defeated_enemies", id):
				enemy.remove_silently()
				continue
			enemy.encounter_triggered.connect(_on_encounter_triggered)
			enemy.defeated.connect(func(_group: Node) -> void:
				GameState.map_state_add(scene, "defeated_enemies", id))
		elif node is Chest:
			if GameState.map_state_has(scene, "opened_chests", id):
				(node as Chest).restore_opened()
			else:
				(node as Chest).interacted.connect(func(_by: Node) -> void:
					GameState.map_state_add(scene, "opened_chests", id))
		elif node is ElementalObstacle:
			var obstacle := node as ElementalObstacle
			if GameState.map_state_has(scene, "resolved_obstacles", id):
				obstacle.restore_resolved()
			else:
				obstacle.resolved.connect(func(_o: ElementalObstacle) -> void:
					GameState.map_state_add(scene, "resolved_obstacles", id))
		elif node is TechniqueBox:
			if GameState.map_state_has(scene, "broken_boxes", id):
				(node as TechniqueBox).restore_broken()
			else:
				(node as TechniqueBox).interacted.connect(func(_by: Node) -> void:
					GameState.map_state_add(scene, "broken_boxes", id))
	room_manager.restore_visited(get_state().get("visited_rooms", []))
	room_manager.room_visited.connect(func(room: Room) -> void:
		GameState.map_state_add(scene, "visited_rooms", String(room.room_id)))


func _place_player() -> void:
	var state := get_state()
	if bool(state.get("respawn_at_rest", false)):
		state.erase("respawn_at_rest")
		var saved: Variant = GameState.get_map_player_position(scene_file_path)
		var rest := _nearest_rest_room(saved if saved is Vector2 else Vector2.ZERO)
		if rest:
			player.global_position = rest.get_spawn_point()
			GameState.set_map_player(scene_file_path, player.global_position, Vector2.DOWN)
			return
	var saved_position: Variant = GameState.get_map_player_position(scene_file_path)
	if saved_position is Vector2:
		player.global_position = saved_position
		player.facing = GameState.get_map_player_facing(scene_file_path)
		return
	var start_room := room_manager.get_room(start_room_id)
	if start_room == null and not room_manager.rooms.is_empty():
		start_room = room_manager.rooms[0]
	if start_room:
		player.global_position = start_room.get_spawn_point()


## Phòng nghỉ gần nhất; ưu tiên phòng đã khám phá.
func _nearest_rest_room(from: Vector2) -> Room:
	var best: Room = null
	var best_score := INF
	for room in room_manager.rooms:
		if room.room_type != Room.RoomType.REST:
			continue
		var score := from.distance_to(room.get_center_world())
		if not room_manager.is_visited(room):
			score += 1.0e6
		if score < best_score:
			best_score = score
			best = room
	return best


func _persistent_id(node: Node) -> String:
	var room := Room.find_room_of(node)
	return room.get_persistent_id(node) if room else String(get_path_to(node))


func _all_descendants(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child in root.get_children():
		result.append(child)
		result.append_array(_all_descendants(child))
	return result


# --- Bí Kỹ ---

## Dùng Bí Kỹ của người dẫn đầu. Trả về false nếu không đủ Điểm Bí Kỹ hoặc không có Bí Kỹ.
func use_technique() -> bool:
	var leader := player.get_leader()
	var technique := leader.technique if leader else null
	if technique == null or SceneRouter.is_busy() or _encounter_started:
		return false
	if GameState.technique_points < technique.cost:
		EventBus.toast_requested.emit(tr("TOAST_NO_TECHNIQUE_POINTS"))
		return false
	GameState.change_technique_points(-technique.cost)
	var tile := float(Room.TILE_SIZE)
	match technique.map_action:
		TechniqueData.MapAction.PHASE_DASH:
			player.start_phase_dash(technique.distance_tiles * tile)
		TechniqueData.MapAction.FIREWORK_DAZE:
			var center := player.global_position + player.facing * technique.distance_tiles * tile
			var hits := 0
			for node in get_tree().get_nodes_in_group(OverworldEnemy.GROUP):
				var enemy := node as OverworldEnemy
				if enemy and not enemy.is_defeated() and enemy.global_position.distance_to(center) <= technique.radius_tiles * tile:
					enemy.daze(technique.duration_sec)
					enemy.add_mark(leader.id)
					hits += 1
			hud.show_burst(center, technique.radius_tiles * tile, Element.color(leader.element))
			print("[Technique] %s trúng %d nhóm quái" % [technique.id, hits])
		TechniqueData.MapAction.INVISIBILITY:
			player.make_invisible(technique.duration_sec, technique.speed_bonus)
	if technique.kind != TechniqueData.Kind.MAP_ENEMIES and not technique.battle_start_effects.is_empty():
		GameState.add_pending_technique(leader.id)
	EventBus.technique_used.emit(leader.id)
	EventBus.toast_requested.emit(tr("TOAST_TECHNIQUE_USED") % tr(technique.name_key))
	CameraRig.shake(4.0, 0.12)
	return true


func _on_obstacle_hit(obstacle: ElementalObstacle, opened: bool) -> void:
	var name_text := tr(ElementalObstacle.NAME_KEYS[obstacle.kind])
	if opened:
		EventBus.toast_requested.emit(tr("TOAST_OBSTACLE_OPENED") % name_text)
	elif obstacle.kind == ElementalObstacle.Kind.WARP_BARRIER:
		EventBus.toast_requested.emit(tr("TOAST_WARP_BARRIER"))
	else:
		EventBus.toast_requested.emit(tr("TOAST_OBSTACLE_NEEDS") % [name_text,
				tr(Element.name_key(obstacle.get_required_element()))])


func _change_team_level(delta: int) -> void:
	GameState.team_level = clampi(GameState.team_level + delta, 1, 80)
	EventBus.toast_requested.emit(tr("TOAST_TEAM_LEVEL") % GameState.team_level)


# --- Dựng map ---

func _collect_rooms() -> Array[Room]:
	var rooms: Array[Room] = []
	var ids: Dictionary = {}
	for child in rooms_root.get_children():
		if child is Room:
			var room := child as Room
			if ids.has(room.room_id):
				push_error("OverworldMap: trùng room_id '%s', trạng thái lưu sẽ lẫn nhau" % room.room_id)
			ids[room.room_id] = true
			rooms.append(room)
	return rooms


func _connect_rooms(rooms: Array[Room]) -> Array[Array]:
	var by_cell: Dictionary = {}
	for room in rooms:
		if by_cell.has(room.grid_cell):
			push_error("OverworldMap: 2 phòng trùng ô lưới %s" % room.grid_cell)
		by_cell[room.grid_cell] = room
	var sides: Dictionary = {}
	var connections: Array[Array] = []
	for room in rooms:
		# Chỉ xét phía Đông và Nam để mỗi cặp phòng được nối đúng một lần.
		for side: int in [Room.Side.EAST, Room.Side.SOUTH]:
			var neighbor: Room = by_cell.get(room.grid_cell + Room.side_offset(side))
			if neighbor == null:
				continue
			if not (room.door_sides & side) or not (neighbor.door_sides & Room.opposite(side)):
				continue
			sides[room] = int(sides.get(room, 0)) | side
			sides[neighbor] = int(sides.get(neighbor, 0)) | Room.opposite(side)
			connections.append([room, neighbor])
			_paint_corridor(room, neighbor, side)
	for room in rooms:
		room.apply_connections(int(sides.get(room, 0)))
	return connections


## Vẽ hành lang giữa hàng tường của phòng `from` và phòng `to` (to nằm phía Đông hoặc Nam).
func _paint_corridor(from: Room, to: Room, side: int) -> void:
	var from_center := from.get_center_world_tile()
	var to_center := to.get_center_world_tile()
	var horizontal := side == Room.Side.EAST
	var start := (from_center.x + from.get_half_extent().x + 1) if horizontal \
			else (from_center.y + from.get_half_extent().y + 1)
	var end := (to_center.x - to.get_half_extent().x) if horizontal \
			else (to_center.y - to.get_half_extent().y)
	var axis := from_center.y if horizontal else from_center.x
	for along in range(start, end):
		for across in range(-CORRIDOR_HALF_WIDTH - 1, CORRIDOR_HALF_WIDTH + 2):
			var is_wall := absi(across) > CORRIDOR_HALF_WIDTH
			var cell := Vector2i(along, axis + across) if horizontal else Vector2i(axis + across, along)
			corridor_layer.set_cell(cell, TileIds.SOURCE_ID,
					TileIds.CORRIDOR_WALL if is_wall else TileIds.CORRIDOR_FLOOR)


func _on_current_room_changed(room: Room) -> void:
	if room:
		camera.set_room_limits(room.get_world_rect())
	else:
		camera.clear_limits()
