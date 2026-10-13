class_name Room
extends Node2D
## Một phòng trên map, dựng từ phòng mẫu (TileMapLayer sàn + tường vẽ sẵn).
## Phòng mẫu chừa lỗ cửa ở cả 4 phía; lúc chạy, map báo phía nào nối hành lang
## thì phòng tạo cửa ở đó và xây tường bịt các lỗ còn lại.
## Gốc toạ độ của phòng là góc trên-trái của ô chính giữa.

signal player_entered(room: Room)
signal player_exited(room: Room)
signal cleared(room: Room)

enum RoomType { HALL, COMBAT, CHEST, REST, PUZZLE, ELITE, BOSS }
enum Side { NORTH = 1, EAST = 2, SOUTH = 4, WEST = 8 }

const TILE_SIZE: int = 64
## Khoảng cách tâm 2 ô lưới phòng (đơn vị ô gạch). Phòng to nhất phải nhỏ hơn số này.
const CELL_TILES: int = 40
## Cửa rộng 3 ô: -1, 0, 1 quanh trục giữa.
const DOOR_HALF_WIDTH: int = 1
## Vùng "đã vào phòng" lùi vào trong tường bao nhiêu ô, để cửa đóng sau lưng người chơi.
const INTERIOR_INSET_TILES: int = 2
const ALL_SIDES: Array[int] = [Side.NORTH, Side.EAST, Side.SOUTH, Side.WEST]
const ENEMY_GROUP: StringName = &"enemy_group"
## Các loại phòng khóa cửa khi còn quái.
const LOCKING_TYPES: Array[RoomType] = [RoomType.COMBAT, RoomType.ELITE, RoomType.BOSS]

@export var room_id: StringName
@export var room_type: RoomType = RoomType.COMBAT
## Kích thước tính cả tường, luôn là số lẻ để có ô chính giữa.
@export var size_tiles: Vector2i = Vector2i(17, 13)
@export var grid_cell: Vector2i = Vector2i.ZERO
## Các phía cho phép mở cửa; chỉ thành cửa thật khi phòng bên cạnh cũng mở phía đối diện.
@export_flags("Bắc", "Đông", "Nam", "Tây") var door_sides: int = 15
## Khu chứa phòng (library, vault...). Rỗng = theo khu của map (OverworldMap.zone).
@export var zone: StringName = &""

var connected_sides: int = 0

var _doors: Array[Door] = []
var _doors_locked: bool = false
var _doors_root: Node2D

@onready var floor_layer: TileMapLayer = $Floor
@onready var wall_layer: TileMapLayer = $Walls
@onready var entities: Node2D = $Entities


func _ready() -> void:
	position = Vector2(grid_cell * CELL_TILES * TILE_SIZE)
	_doors_root = Node2D.new()
	_doors_root.name = "Doors"
	add_child(_doors_root)
	_create_interior_area()
	for group in get_enemy_groups():
		group.defeated.connect(_on_enemy_group_defeated)


static func opposite(side: int) -> int:
	match side:
		Side.NORTH: return Side.SOUTH
		Side.SOUTH: return Side.NORTH
		Side.EAST: return Side.WEST
		_: return Side.EAST


static func side_offset(side: int) -> Vector2i:
	match side:
		Side.NORTH: return Vector2i.UP
		Side.SOUTH: return Vector2i.DOWN
		Side.EAST: return Vector2i.RIGHT
		_: return Vector2i.LEFT


## Nửa kích thước (số ô từ ô giữa tới hàng tường).
func get_half_extent() -> Vector2i:
	return (size_tiles - Vector2i.ONE) / 2


## Ô giữa phòng trong toạ độ ô của cả map.
func get_center_world_tile() -> Vector2i:
	return grid_cell * CELL_TILES


func get_center_world() -> Vector2:
	return Vector2(get_center_world_tile() * TILE_SIZE) + Vector2.ONE * TILE_SIZE * 0.5


## Khung phòng (cả tường) trong toạ độ thế giới.
func get_world_rect() -> Rect2:
	var top_left := Vector2((get_center_world_tile() - get_half_extent()) * TILE_SIZE)
	return Rect2(top_left, Vector2(size_tiles * TILE_SIZE))


## Ô của lỗ cửa phía `side`, toạ độ trong phòng.
func get_door_gap_cells(side: int) -> Array[Vector2i]:
	var half := get_half_extent()
	var cells: Array[Vector2i] = []
	for i in range(-DOOR_HALF_WIDTH, DOOR_HALF_WIDTH + 1):
		match side:
			Side.NORTH: cells.append(Vector2i(i, -half.y))
			Side.SOUTH: cells.append(Vector2i(i, half.y))
			Side.EAST: cells.append(Vector2i(half.x, i))
			Side.WEST: cells.append(Vector2i(-half.x, i))
	return cells


## Map gọi sau khi nối hành lang: tạo cửa ở phía có nối, bịt tường các phía còn lại.
func apply_connections(sides: int) -> void:
	connected_sides = sides
	for side in ALL_SIDES:
		if sides & side:
			_create_door(side)
		else:
			for cell in get_door_gap_cells(side):
				wall_layer.set_cell(cell, TileIds.SOURCE_ID, TileIds.WALL)


## Mã lưu trạng thái cho vật trong phòng (rương, quái...): "<room_id>/<đường dẫn trong phòng>".
## Không trùng kể cả khi nhiều phòng dùng chung 1 phòng mẫu, miễn room_id khác nhau.
func get_persistent_id(node: Node) -> String:
	return "%s/%s" % [room_id, get_path_to(node)]


## Phòng chứa node (đi ngược lên cây), null nếu không nằm trong phòng nào.
static func find_room_of(node: Node) -> Room:
	var current := node.get_parent()
	while current:
		if current is Room:
			return current
		current = current.get_parent()
	return null


func get_spawn_point() -> Vector2:
	var marker := find_child("PlayerSpawn", true, false) as Node2D
	return marker.global_position if marker else get_center_world()


## Nhóm quái còn sống trong phòng (OverworldEnemy, hoặc node khác có is_defeated/defeat/defeated).
func get_enemy_groups() -> Array[Node]:
	var groups: Array[Node] = []
	if not is_inside_tree():
		return groups
	for node in get_tree().get_nodes_in_group(ENEMY_GROUP):
		if is_ancestor_of(node) and not node.is_defeated():
			groups.append(node)
	return groups


func has_enemies() -> bool:
	return not get_enemy_groups().is_empty()


func should_lock_on_enter() -> bool:
	return room_type in LOCKING_TYPES and has_enemies()


func are_doors_locked() -> bool:
	return _doors_locked


func get_doors() -> Array[Door]:
	return _doors


func lock_doors() -> void:
	AudioManager.play_sfx(&"door")
	_doors_locked = true
	for door in _doors:
		door.set_closed(true)


func unlock_doors() -> void:
	_doors_locked = false
	for door in _doors:
		door.set_closed(false)


## Phím debug: hạ hết nhóm quái trong phòng.
func debug_clear_enemies() -> void:
	for group in get_enemy_groups():
		group.defeat()


func _on_enemy_group_defeated(_group: Node) -> void:
	if not has_enemies():
		cleared.emit(self)


## Hai vùng: "Interior" (lùi vào trong) báo đã vào phòng, để cửa đóng sau lưng người chơi;
## "Bounds" (cả khung phòng) báo đã rời phòng, nên đứng sát cửa vẫn tính là trong phòng.
func _create_interior_area() -> void:
	var interior := _add_player_area("Interior", size_tiles - Vector2i.ONE * INTERIOR_INSET_TILES * 2)
	interior.body_entered.connect(func(body: Node2D) -> void:
		if body is Player:
			player_entered.emit(self))
	var bounds := _add_player_area("Bounds", size_tiles)
	bounds.body_exited.connect(func(body: Node2D) -> void:
		if body is Player:
			player_exited.emit(self))


func _add_player_area(area_name: String, area_tiles: Vector2i) -> Area2D:
	var area := Area2D.new()
	area.name = area_name
	area.collision_layer = 0
	area.collision_mask = PhysicsLayers.PLAYER
	area.monitorable = false
	var shape := RectangleShape2D.new()
	shape.size = Vector2(area_tiles * TILE_SIZE)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2.ONE * TILE_SIZE * 0.5
	area.add_child(collision)
	add_child(area)
	return area


func _create_door(side: int) -> void:
	var cells := get_door_gap_cells(side)
	var center := Vector2.ZERO
	for cell in cells:
		center += Vector2(cell * TILE_SIZE) + Vector2.ONE * TILE_SIZE * 0.5
	center /= cells.size()
	var door := Door.new()
	door.name = "Door%d" % side
	door.setup(side, cells.size() * TILE_SIZE)
	door.position = center
	_doors_root.add_child(door)
	_doors.append(door)
