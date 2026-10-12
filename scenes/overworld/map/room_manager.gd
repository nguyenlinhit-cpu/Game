class_name RoomManager
extends Node
## Biết người chơi đang ở phòng nào (null = đang ở hành lang), phòng nào đã khám phá,
## khóa cửa phòng chiến đấu khi còn quái và mở khi hạ hết.
## Phòng đã khám phá được OverworldMap ghi vào GameState để giữ khi ra vào trận.

signal current_room_changed(room: Room)
signal room_visited(room: Room)
signal room_locked(room: Room)
signal room_cleared(room: Room)

var rooms: Array[Room] = []
## Mỗi phần tử là [Room, Room] đã nối hành lang.
var connections: Array[Array] = []
var current_room: Room

var _visited: Dictionary = {}
## Vừa nạp map (vd. từ trận về) thì khóa cửa lại không cần báo.
var _quiet_until_msec: int = 0


func setup(map_rooms: Array[Room], map_connections: Array[Array]) -> void:
	rooms = map_rooms
	connections = map_connections
	for room in rooms:
		room.player_entered.connect(_on_player_entered)
		room.player_exited.connect(_on_player_exited)
		room.cleared.connect(_on_room_cleared)
	_quiet_until_msec = Time.get_ticks_msec() + 500


## Nạp lại danh sách phòng đã khám phá (không phát room_visited).
func restore_visited(room_ids: Array) -> void:
	for room_id: Variant in room_ids:
		_visited[StringName(str(room_id))] = true


func is_visited(room: Room) -> bool:
	return _visited.has(room.room_id)


func get_visited_count() -> int:
	return _visited.size()


func get_room(room_id: StringName) -> Room:
	for room in rooms:
		if room.room_id == room_id:
			return room
	return null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_clear_enemies") and OS.is_debug_build() and current_room:
		get_viewport().set_input_as_handled()
		current_room.debug_clear_enemies()


func _on_player_entered(room: Room) -> void:
	current_room = room
	if not is_visited(room):
		_visited[room.room_id] = true
		room_visited.emit(room)
	if room.should_lock_on_enter() and not room.are_doors_locked():
		room.lock_doors()
		room_locked.emit(room)
		if Time.get_ticks_msec() > _quiet_until_msec:
			EventBus.toast_requested.emit(tr("TOAST_ROOM_LOCKED"))
	current_room_changed.emit(room)


func _on_player_exited(room: Room) -> void:
	if current_room == room:
		current_room = null
		current_room_changed.emit(null)


func _on_room_cleared(room: Room) -> void:
	room.unlock_doors()
	room_cleared.emit(room)
	EventBus.toast_requested.emit(tr("TOAST_ROOM_CLEARED"))
