class_name OverworldMap
extends Node2D
## Map gồm các phòng đặt trên lưới (Room.grid_cell). Hai phòng kề nhau cùng mở cửa ở phía
## đối diện thì được nối bằng hành lang thẳng rộng 3 ô, vẽ vào lớp Corridors lúc chạy.
## Map cũng giữ trạng thái trong GameState.map_states (quái đã hạ, rương đã mở, hộp đã phá,
## phòng đã khám phá, vật cản đã mở, vị trí người chơi), điều phối vào trận / thắng ngay / quay về,
## và chạy Bí Kỹ của người dẫn đầu (tốn Điểm Bí Kỹ dùng chung).
## Phase 10: thưởng thắng ngay theo bảng rơi đồ, hồi quái (thường + boss khi rời khu, tinh anh mỗi ngày),
## báo % khám phá từng khu cho nhiệm vụ.
## Phase 12: vật có StoryGate ẩn/hiện theo cờ cốt truyện, xuất hiện ở phòng chỉ định (payload "spawn_room" khi
## dịch chuyển), quầy dịch vụ ở Sảnh, Cổng Dịch Chuyển / dịch chuyển nhanh, chọn mức Khó khi đánh lại boss,
## mũi tên chỉ đường tới mục tiêu nhiệm vụ.

const CORRIDOR_HALF_WIDTH: int = 1
## Bất tử ngắn khi vừa từ trận quay về, để quái gần đó không kéo vào trận ngay.
const RETURN_INVINCIBILITY_SEC: float = 1.0
const DEBUG_TEAM_LEVEL_STEP: int = 5

## Phòng người chơi xuất hiện khi vào map lần đầu.
@export var start_room_id: StringName
## Khu mặc định của các phòng không ghi khu riêng (rỗng = map thử, không tính khám phá).
@export var zone: StringName = &""

var _encounter_started: bool = false
var quest_arrow: QuestArrow
## Bí Kỹ hút vật phẩm: còn bao nhiêu giây, bán kính (px).
var _magnet_left: float = 0.0
var _magnet_radius: float = 0.0

@onready var rooms_root: Node2D = %Rooms
@onready var corridor_layer: TileMapLayer = %Corridors
@onready var room_manager: RoomManager = %RoomManager
@onready var player: Player = %Player
@onready var camera: CameraRig = %CameraRig
@onready var hud: OverworldHud = %Hud


func _ready() -> void:
	player.z_index = 10
	var previous_scene := GameState.current_map_scene
	GameState.current_map_scene = scene_file_path
	# Vào map từ map khác (không phải từ trận về, không phải tải save): coi như vừa vào khu → quái thường + boss hồi.
	if previous_scene != scene_file_path and previous_scene != "" and zone != &"" \
			and not SceneRouter.payload.has("battle_result"):
		GameState.respawn_zone(scene_file_path, zone)
	var rooms := _collect_rooms()
	_apply_zone_tileset(rooms)
	room_manager.setup(rooms, _connect_rooms(rooms))
	if RoomScenery.THEMES.has(zone):
		var corridor_art := Node2D.new()
		corridor_art.set_script(load("res://scenes/overworld/map/corridor_scenery.gd"))
		corridor_art.name = "CorridorScenery"
		corridor_art.set("map", self)
		add_child(corridor_art)
	room_manager.current_room_changed.connect(_on_current_room_changed)
	_restore_and_track_state()
	_place_player()
	camera.snap_to_target()
	hud.setup(player, room_manager)
	player.technique_requested.connect(use_technique)
	player.obstacle_hit.connect(_on_obstacle_hit)
	_show_battle_result()
	AudioManager.play_music_id(PlaceholderMusic.zone_track(zone if zone != &"" else &"hub"))
	quest_arrow = QuestArrow.new()
	quest_arrow.map = self
	add_child(quest_arrow)
	StoryManager.story_changed.connect(_apply_story_gates)
	var story_zone := StoryManager.get_scene_zone(scene_file_path)
	if story_zone != &"":
		StoryManager.map_ready.call_deferred(story_zone)


func _physics_process(delta: float) -> void:
	if _magnet_left > 0.0:
		_magnet_left -= delta
		for node in get_tree().get_nodes_in_group(Player.BREAKABLE_GROUP):
			var box := node as TechniqueBox
			if box and box.can_interact() and box.global_position.distance_to(player.global_position) <= _magnet_radius:
				box.break_open()


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
	if _encounter_started or SceneRouter.is_busy() or StoryManager.is_playing():
		return
	# Bẫy Dây: nhóm quái bị bẫy luôn vào trận với Ưu Thế.
	if opening != BattleTypes.Opening.ADVANTAGE and _has_forced_advantage(enemy):
		opening = BattleTypes.Opening.ADVANTAGE
	if opening == BattleTypes.Opening.ADVANTAGE and enemy.is_trivial_for(GameState.get_team_level()):
		_instant_win(enemy)
		return
	var hard := false
	if enemy.encounter and enemy.encounter.is_boss() and GameState.has_first_clear(String(enemy.encounter.id)):
		# Đánh lại boss: hỏi mức Thường / Khó.
		_encounter_started = true
		var choice := await StoryManager.play("boss_difficulty")
		_encounter_started = false
		if choice != "normal" and choice != "hard":
			player.grant_invincibility(2.0)
			enemy.daze(2.0)
			return
		hard = choice == "hard"
	_start_battle(enemy, opening, hard)


func _start_battle(enemy: OverworldEnemy, opening: BattleTypes.Opening, hard: bool) -> void:
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
			"opener_element": opener_element, "techniques": techniques, "hard_mode": hard})


## Quái yếu hơn đội ≥10 cấp bị chém trúng: thắng luôn, không vào trận.
func _instant_win(enemy: OverworldEnemy) -> void:
	enemy.defeat()
	var result := Loot.claim_encounter(enemy.encounter)
	hud.show_reward_popup(tr("REWARD_INSTANT_TITLE"), Loot.describe(result["items"]))
	EventBus.battle_won.emit(enemy.encounter)
	# Cảnh cốt truyện sau trận (nếu có) chạy luôn vì không nạp lại map.
	for dialogue_id: Variant in StoryManager.pop_pending():
		StoryManager.play(str(dialogue_id))


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
	_apply_respawns()
	_apply_story_gates()
	for node in _all_descendants(rooms_root):
		var id := _persistent_id(node)
		if node is OverworldEnemy:
			var enemy := node as OverworldEnemy
			if GameState.map_state_has(scene, "defeated_enemies", id):
				enemy.remove_silently()
				continue
			enemy.encounter_triggered.connect(_on_encounter_triggered)
			var kind := int(enemy.encounter.kind) if enemy.encounter else EncounterData.Kind.NORMAL
			var enemy_zone := zone_of(enemy)
			enemy.defeated.connect(func(_group: Node) -> void:
				GameState.record_defeat(scene, id, kind, enemy_zone))
		elif node is Chest:
			var chest := node as Chest
			if chest.zone == &"":
				chest.zone = zone_of(chest)
			if GameState.map_state_has(scene, "opened_chests", id):
				chest.restore_opened()
			else:
				chest.interacted.connect(func(_by: Node) -> void:
					GameState.map_state_add(scene, "opened_chests", id)
					_report_exploration())
		elif node is ElementalObstacle:
			var obstacle := node as ElementalObstacle
			if GameState.map_state_has(scene, "resolved_obstacles", id):
				obstacle.restore_resolved()
			else:
				obstacle.resolved.connect(func(_o: ElementalObstacle) -> void:
					GameState.map_state_add(scene, "resolved_obstacles", id)
					_report_exploration())
		elif node is TechniqueBox:
			if GameState.map_state_has(scene, "broken_boxes", id):
				(node as TechniqueBox).restore_broken()
			else:
				(node as TechniqueBox).interacted.connect(func(_by: Node) -> void:
					GameState.map_state_add(scene, "broken_boxes", id)
					_report_exploration())
	room_manager.restore_visited(get_state().get("visited_rooms", []))
	room_manager.room_visited.connect(func(room: Room) -> void:
		GameState.map_state_add(scene, "visited_rooms", String(room.room_id))
		if room.room_type == Room.RoomType.REST:
			GameState.unlock_fast_travel(zone_of(room), room.room_id)
		_report_exploration())
	_report_exploration()


## Khu của một node trên map: khu của phòng chứa nó, không ghi thì khu của map.
func zone_of(node: Node) -> StringName:
	var room: Room = node as Room if node is Room else Room.find_room_of(node)
	return room.zone if room and room.zone != &"" else zone


## Hồi quái khi nạp map: tinh anh hạ từ hôm trước; quái thường + boss của các khu người chơi đã rời.
func _apply_respawns() -> void:
	var state := get_state()
	GameState.respawn_daily(scene_file_path, QuestManager.get_day_index())
	for left_zone: Variant in state.get("respawn_zones", []):
		GameState.respawn_zone(scene_file_path, StringName(str(left_zone)))
	state["respawn_zones"] = []


## % khám phá từng khu = (phòng đã vào + rương đã mở + vật cản đã mở + Hộp Bí Kỹ đã phá) / tổng số trong khu.
func get_exploration() -> Dictionary:
	var scene := scene_file_path
	var totals: Dictionary = {}
	var done: Dictionary = {}
	for room in room_manager.rooms:
		var z := zone_of(room)
		totals[z] = int(totals.get(z, 0)) + 1
		if room_manager.is_visited(room):
			done[z] = int(done.get(z, 0)) + 1
	for node in _all_descendants(rooms_root):
		var key := ""
		if node is Chest:
			key = "opened_chests"
		elif node is ElementalObstacle:
			key = "resolved_obstacles"
		elif node is TechniqueBox:
			key = "broken_boxes"
		if key.is_empty():
			continue
		var z := zone_of(node)
		totals[z] = int(totals.get(z, 0)) + 1
		if GameState.map_state_has(scene, key, _persistent_id(node)):
			done[z] = int(done.get(z, 0)) + 1
	var result: Dictionary = {}
	for z: StringName in totals:
		result[z] = floori(100.0 * int(done.get(z, 0)) / int(totals[z]))
	return result


func _report_exploration() -> void:
	var exploration := get_exploration()
	for z: StringName in exploration:
		if z != &"":
			QuestManager.report(&"zone_explored", exploration[z], z)


func _place_player() -> void:
	var state := get_state()
	# Dịch chuyển (cổng / phòng nghỉ): xuất hiện ở phòng chỉ định.
	var spawn_room := room_manager.get_room(StringName(str(SceneRouter.payload.get("spawn_room", ""))))
	if spawn_room:
		SceneRouter.payload.erase("spawn_room")
		state.erase("respawn_at_rest")
		player.global_position = spawn_room.get_spawn_point()
		GameState.set_map_player(scene_file_path, player.global_position, Vector2.DOWN)
		return
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


## Có tileset vẽ tay của khu (assets/tilesets/<khu>/) thì thay cho tileset tạm (cùng bố cục ô, Phase 13).
func _apply_zone_tileset(rooms: Array[Room]) -> void:
	var tile_set := ArtLibrary.zone_tileset(zone)
	if tile_set == null:
		return
	corridor_layer.tile_set = tile_set
	corridor_layer.modulate = Color.WHITE
	for room in rooms:
		for layer: TileMapLayer in [room.floor_layer, room.wall_layer]:
			layer.tile_set = tile_set
			layer.modulate = Color.WHITE


# --- Cốt truyện (Phase 12) ---

## Ẩn/hiện vật có StoryGate theo cờ. Vật bị ẩn: không vẽ, không va chạm, quái không tính là còn trong phòng.
func _apply_story_gates() -> void:
	for node in _all_descendants(rooms_root):
		if not _has_story_gate(node):
			continue
		var allowed := StoryGate.allows(node)
		var item := node as CanvasItem
		if item:
			item.visible = allowed
		node.process_mode = Node.PROCESS_MODE_INHERIT if allowed else Node.PROCESS_MODE_DISABLED
		if node is OverworldEnemy:
			for group: StringName in [Room.ENEMY_GROUP, OverworldEnemy.GROUP]:
				if allowed and not node.is_in_group(group):
					node.add_to_group(group)
				elif not allowed and node.is_in_group(group):
					node.remove_from_group(group)


func _has_story_gate(node: Node) -> bool:
	for child in node.get_children():
		if child is StoryGate:
			return true
	return false


## Quầy dịch vụ ở Sảnh.
func open_station(kind: Station.Kind) -> void:
	match kind:
		Station.Kind.GACHA:
			hud.open_game_menu(GameMenu.Page.GACHA)
		Station.Kind.QUESTS:
			hud.open_game_menu(GameMenu.Page.QUESTS)
		Station.Kind.UPGRADE:
			hud.open_game_menu(GameMenu.Page.CHARACTERS)
		Station.Kind.TEAM:
			hud.open_game_menu(GameMenu.Page.TEAM)
		Station.Kind.SHOP:
			hud.open_panel(tr("STATION_SHOP"), ShopScreen.new())
		Station.Kind.GATE:
			var items: Array[Dictionary] = []
			for dest in StoryManager.get_gate_destinations():
				items.append({"label": StoryManager.zone_name(dest["zone"]), "scene": dest["scene"], "room": dest["room"]})
			_open_destinations(tr("STATION_GATE"), items, "TRAVEL_GATE_EMPTY")


## Bảng dịch chuyển nhanh: Sảnh Trung Tâm + mọi phòng nghỉ đã mở (trừ phòng đang đứng).
func open_travel_menu() -> Control:
	var items: Array[Dictionary] = []
	var here := room_manager.current_room
	var my_zone := StoryManager.get_scene_zone(scene_file_path)
	var hub_scene := StoryManager.get_zone_scene(StoryManager.HUB_ZONE)
	if my_zone != StoryManager.HUB_ZONE and hub_scene != "":
		items.append({"label": StoryManager.zone_name(StoryManager.HUB_ZONE), "scene": hub_scene, "room": "H01"})
	for key in GameState.fast_travel:
		var parts := key.split("/")
		if parts.size() != 2:
			continue
		var travel_zone := StringName(parts[0])
		var room_id := StringName(parts[1])
		if travel_zone == my_zone and here and here.room_id == room_id:
			continue
		var scene := StoryManager.get_zone_scene(travel_zone)
		if scene == "" or travel_zone == StoryManager.HUB_ZONE:
			continue
		items.append({"label": tr("TRAVEL_REST_LABEL") % [StoryManager.zone_name(travel_zone),
				StoryManager.rest_room_name(travel_zone, room_id)],
				"scene": scene, "room": room_id})
	return _open_destinations(tr("TRAVEL_TITLE"), items, "TRAVEL_EMPTY")


func _open_destinations(title: String, items: Array[Dictionary], empty_key: String) -> Control:
	var menu := TravelMenu.new()
	menu.setup(items, empty_key)
	menu.destination_chosen.connect(travel_to)
	return hud.open_panel(title, menu)


## Đi tới phòng `room_id` của scene `scene_path` (cùng map thì đặt người chơi luôn, khác map thì chuyển scene).
func travel_to(scene_path: String, room_id: StringName) -> void:
	hud.close_panel()
	if scene_path == scene_file_path:
		var room := room_manager.get_room(room_id)
		if room:
			player.global_position = room.get_spawn_point()
			camera.snap_to_target()
		return
	GameState.set_map_player(scene_file_path, player.global_position, player.facing)
	SceneRouter.go_to(scene_path, {"spawn_room": room_id})


## Vị trí mục tiêu nhiệm vụ để mũi tên chỉ: mục tiêu trong map này → phòng / node đó; ở Sảnh mà mục tiêu ở khu
## khác → Cổng Dịch Chuyển; ở khu mà mục tiêu ở nơi khác → phòng nghỉ gần nhất (dịch chuyển nhanh). null = không chỉ.
func get_quest_target_position() -> Variant:
	var step := StoryManager.get_main_step()
	if step.is_empty():
		var sides := StoryManager.get_side_steps()
		if sides.is_empty():
			return null
		step = sides[0]["step"]
	var my_zone := StoryManager.get_scene_zone(scene_file_path)
	if my_zone == &"":
		return null
	var target: Dictionary = step.get("target", {})
	var target_zone := StringName(str(target.get("zone", "")))
	if target_zone == my_zone:
		var room := room_manager.get_room(StringName(str(target.get("room", ""))))
		if room == null:
			return null
		var node_name := str(target.get("node", ""))
		var node := room.find_child(node_name, true, false) as Node2D if node_name != "" else null
		return node.global_position if node and node.visible else room.get_center_world()
	if my_zone == StoryManager.HUB_ZONE:
		for node in get_tree().get_nodes_in_group(Station.GROUP):
			if node is Station and (node as Station).kind == Station.Kind.GATE:
				return (node as Node2D).global_position
		return null
	var rest := _nearest_rest_room(player.global_position)
	return rest.get_center_world() if rest else null


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
	var color := Element.color(leader.element)
	match technique.map_action:
		TechniqueData.MapAction.PHASE_DASH:
			player.start_phase_dash(technique.distance_tiles * tile)
		TechniqueData.MapAction.LONG_DASH:
			player.start_phase_dash(technique.distance_tiles * tile, PhysicsLayers.PIT)
		TechniqueData.MapAction.FIREWORK_DAZE:
			var center := player.global_position + player.facing * technique.distance_tiles * tile
			var hits := _mark_enemies_in_radius(center, technique.radius_tiles * tile, technique.duration_sec, leader.id)
			hud.show_burst(center, technique.radius_tiles * tile, color)
			print("[Technique] %s trúng %d nhóm quái" % [technique.id, hits])
		TechniqueData.MapAction.DASH_TRAIL:
			# Lao về trước, đánh dấu mọi nhóm quái gần đường lao.
			var start := player.global_position
			var end := start + player.facing * technique.distance_tiles * tile
			for node in get_tree().get_nodes_in_group(OverworldEnemy.GROUP):
				var enemy := node as OverworldEnemy
				if enemy and not enemy.is_defeated() and Geometry2D.get_closest_point_to_segment(
						enemy.global_position, start, end).distance_to(enemy.global_position) <= technique.radius_tiles * tile:
					enemy.add_mark(leader.id)
			player.start_phase_dash(technique.distance_tiles * tile, 0)
			hud.show_burst(end, technique.radius_tiles * tile, color)
		TechniqueData.MapAction.ARROW:
			var target := _first_enemy_on_line(player.global_position, player.facing, technique.distance_tiles * tile)
			if target:
				target.daze(technique.duration_sec)
				target.add_mark(leader.id)
				hud.show_burst(target.global_position, tile, color)
		TechniqueData.MapAction.TRAP:
			for old in get_tree().get_nodes_in_group(TechniqueTrap.GROUP):
				old.queue_free()
			var trap := TechniqueTrap.new()
			trap.owner_id = leader.id
			trap.radius = technique.radius_tiles * tile
			trap.hold_sec = technique.duration_sec
			trap.color = color
			trap.global_position = player.global_position
			add_child(trap)
		TechniqueData.MapAction.INVISIBILITY:
			player.make_invisible(technique.duration_sec, technique.speed_bonus)
		TechniqueData.MapAction.SPEED_BOOST:
			player.boost_speed(technique.duration_sec, technique.speed_bonus)
		TechniqueData.MapAction.REVEAL_SECRETS:
			hud.reveal_on_minimap(Minimap.Reveal.SECRETS, technique.duration_sec)
		TechniqueData.MapAction.REVEAL_ENEMIES:
			hud.reveal_on_minimap(Minimap.Reveal.ENEMIES, technique.duration_sec)
		TechniqueData.MapAction.MAGNET:
			_magnet_left = technique.duration_sec
			_magnet_radius = technique.radius_tiles * tile
		TechniqueData.MapAction.HEAL_TEAM:
			GameState.heal_team(technique.heal_ratio)
			EventBus.toast_requested.emit(tr("TOAST_TEAM_HEALED") % roundi(technique.heal_ratio * 100.0))
		TechniqueData.MapAction.RETURN_TO_REST:
			var rest := _nearest_rest_room(player.global_position)
			if rest:
				player.global_position = rest.get_spawn_point()
				camera.snap_to_target()
	if technique.kind != TechniqueData.Kind.MAP_ENEMIES and not technique.battle_start_effects.is_empty():
		GameState.add_pending_technique(leader.id)
	EventBus.technique_used.emit(leader.id)
	AudioManager.play_sfx(&"technique")
	# Bí Kỹ có thông báo riêng thì không đè bằng thông báo chung.
	if technique.map_action != TechniqueData.MapAction.HEAL_TEAM:
		EventBus.toast_requested.emit(tr("TOAST_TECHNIQUE_USED") % tr(technique.name_key))
	CameraRig.shake(4.0, 0.12)
	return true


func _mark_enemies_in_radius(center: Vector2, radius: float, daze_sec: float, mark: StringName) -> int:
	var hits := 0
	for node in get_tree().get_nodes_in_group(OverworldEnemy.GROUP):
		var enemy := node as OverworldEnemy
		if enemy and not enemy.is_defeated() and enemy.global_position.distance_to(center) <= radius:
			if daze_sec > 0.0:
				enemy.daze(daze_sec)
			enemy.add_mark(mark)
			hits += 1
	return hits


func _first_enemy_on_line(origin: Vector2, direction: Vector2, length: float) -> OverworldEnemy:
	var best: OverworldEnemy = null
	var best_distance := INF
	for node in get_tree().get_nodes_in_group(OverworldEnemy.GROUP):
		var enemy := node as OverworldEnemy
		if enemy == null or enemy.is_defeated():
			continue
		var offset := enemy.global_position - origin
		var along := offset.dot(direction)
		if along < 0.0 or along > length or absf(offset.cross(direction)) > enemy.get_hit_radius() + 24.0:
			continue
		if along < best_distance:
			best_distance = along
			best = enemy
	return best


func _has_forced_advantage(enemy: OverworldEnemy) -> bool:
	for mark in enemy.marks:
		var data := DataPaths.load_character(mark)
		if data and data.technique and data.technique.marks_force_advantage:
			return true
	return false


func _on_obstacle_hit(obstacle: ElementalObstacle, opened: bool) -> void:
	var name_text := tr(ElementalObstacle.NAME_KEYS[obstacle.kind])
	if opened:
		EventBus.toast_requested.emit(tr("TOAST_OBSTACLE_OPENED") % name_text)
	elif obstacle.kind == ElementalObstacle.Kind.WARP_BARRIER:
		EventBus.toast_requested.emit(tr("TOAST_WARP_BARRIER"))
	else:
		EventBus.toast_requested.emit(tr("TOAST_OBSTACLE_NEEDS") % [name_text,
				tr(Element.name_key(obstacle.get_required_element()))])


## Debug F6/F7: ép cấp cả đội (về 0 = dùng cấp thật của từng nhân vật).
func _change_team_level(delta: int) -> void:
	var base := GameState.team_level if GameState.team_level > 0 else GameState.get_team_level()
	GameState.team_level = clampi(base + delta, 0, GameConfig.MAX_LEVEL)
	EventBus.toast_requested.emit(tr("TOAST_TEAM_LEVEL") % GameState.get_team_level())


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
		# Rời khu: quái thường và boss của khu cũ hồi lại lần nạp map sau.
		var state := get_state()
		var new_zone := String(zone_of(room))
		var old_zone := str(state.get("current_zone", new_zone))
		if old_zone != new_zone:
			var pending: Array = state.get("respawn_zones", [])
			if not pending.has(old_zone):
				pending.append(old_zone)
			state["respawn_zones"] = pending
		state["current_zone"] = new_zone
	else:
		camera.clear_limits()


## Bẫy Dây (Fenna): nhóm quái đi vào bán kính thì bị giữ chặt và đánh dấu; dùng một lần.
class TechniqueTrap extends Node2D:
	const GROUP: StringName = &"technique_trap"
	var owner_id: StringName
	var radius: float = 64.0
	var hold_sec: float = 8.0
	var color: Color = Color.WHITE

	func _ready() -> void:
		add_to_group(GROUP)

	func _physics_process(_delta: float) -> void:
		queue_redraw()
		for node in get_tree().get_nodes_in_group(OverworldEnemy.GROUP):
			var enemy := node as OverworldEnemy
			if enemy and not enemy.is_defeated() and enemy.global_position.distance_to(global_position) <= radius:
				enemy.daze(hold_sec)
				enemy.add_mark(owner_id)
				queue_free()
				return

	func _draw() -> void:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(color, 0.8), 3.0, true)
		draw_line(Vector2(-radius * 0.6, 0), Vector2(radius * 0.6, 0), color, 2.0)
		draw_line(Vector2(0, -radius * 0.6), Vector2(0, radius * 0.6), color, 2.0)


## Mũi tên vàng quanh người chơi chỉ về mục tiêu nhiệm vụ (ẩn khi đã ở gần).
class QuestArrow extends Node2D:
	const RADIUS: float = 96.0
	const HIDE_DISTANCE: float = 220.0
	var map: OverworldMap
	var _refresh: float = 0.0
	var _target: Variant = null

	func _ready() -> void:
		z_index = 50

	func _process(delta: float) -> void:
		_refresh -= delta
		if _refresh <= 0.0:
			_refresh = 0.25
			_target = map.get_quest_target_position()
		global_position = map.player.global_position
		queue_redraw()

	func get_target() -> Variant:
		return _target

	func _draw() -> void:
		if not _target is Vector2:
			return
		var offset: Vector2 = (_target as Vector2) - global_position
		if offset.length() < HIDE_DISTANCE:
			return
		var dir := offset.normalized()
		var tip := dir * (RADIUS + 26.0)
		var base := dir * RADIUS
		var side := dir.orthogonal() * 16.0
		var pulse := 0.7 + 0.3 * sin(Time.get_ticks_msec() / 200.0)
		draw_colored_polygon(PackedVector2Array([tip, base + side, base - side]), Color(UiKit.GOLD, pulse))
		draw_polyline(PackedVector2Array([tip, base + side, base - side, tip]), Color(0, 0, 0, 0.6), 2.0, true)
