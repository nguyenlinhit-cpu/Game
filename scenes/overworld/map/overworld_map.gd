class_name OverworldMap
extends Node2D
## Map gồm các phòng đặt trên lưới (Room.grid_cell). Hai phòng kề nhau cùng mở cửa ở phía
## đối diện thì được nối bằng hành lang thẳng rộng 3 ô, vẽ vào lớp Corridors lúc chạy.

const CORRIDOR_HALF_WIDTH: int = 1

## Phòng người chơi xuất hiện khi vào map lần đầu.
@export var start_room_id: StringName

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
	# TODO Phase 3: khôi phục vị trí người chơi từ GameState khi quay lại từ trận.
	var start_room := room_manager.get_room(start_room_id)
	if start_room == null and not rooms.is_empty():
		start_room = rooms[0]
	if start_room:
		player.global_position = start_room.get_spawn_point()
	camera.snap_to_target()
	hud.setup(player, room_manager)


func _collect_rooms() -> Array[Room]:
	var rooms: Array[Room] = []
	for child in rooms_root.get_children():
		if child is Room:
			rooms.append(child)
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
