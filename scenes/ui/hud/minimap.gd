class_name Minimap
extends Control
## Bản đồ nhỏ góc phải: phòng đã khám phá (ô đặc), phòng kề chưa vào (viền mờ), hành lang,
## biểu tượng loại phòng và chấm vị trí người chơi. Tỉ lệ đều theo ô gạch nên vị trí luôn khớp.

## Số pixel minimap cho mỗi ô gạch của map.
const PX_PER_TILE: float = 2.4
const BACKGROUND := Color(0.1, 0.1, 0.2, 0.82)
const BORDER := Color(0.95, 0.84, 0.54, 0.6)
const ROOM_VISITED := Color(0.32, 0.34, 0.5, 0.95)
const ROOM_CURRENT := Color(0.45, 0.48, 0.7, 1.0)
const ROOM_KNOWN := Color(0.6, 0.62, 0.75, 0.45)
const CORRIDOR := Color(0.55, 0.57, 0.7, 0.8)
const PLAYER_DOT := Color("f2d58a")
const SECRET_COLOR := Color("c78bff")
const ENEMY_DOT := Color("ff5c5c")

## Bí Kỹ hiện thêm thông tin trên bản đồ nhỏ.
enum Reveal { SECRETS, ENEMIES }
const ICON_COLORS: Dictionary = {
	Room.RoomType.COMBAT: Color("e8552b"),
	Room.RoomType.ELITE: Color("e8552b"),
	Room.RoomType.BOSS: Color("ff3b3b"),
	Room.RoomType.CHEST: Color("f2d58a"),
	Room.RoomType.REST: Color("6fdc8c"),
	Room.RoomType.PUZZLE: Color("a65bf2"),
}

var _manager: RoomManager
var _player: Node2D
## { Reveal: giây còn lại }
var _reveal_left: Dictionary = {}


func setup(manager: RoomManager, player: Node2D) -> void:
	_manager = manager
	_player = player
	clip_contents = true


func _process(delta: float) -> void:
	for kind: int in _reveal_left.keys():
		_reveal_left[kind] = float(_reveal_left[kind]) - delta
		if _reveal_left[kind] <= 0.0:
			_reveal_left.erase(kind)
	queue_redraw()


func reveal(kind: Reveal, duration: float) -> void:
	_reveal_left[kind] = duration


func is_revealing(kind: Reveal) -> bool:
	return _reveal_left.has(kind)


## Đổi toạ độ thế giới sang toạ độ minimap, lấy người chơi làm tâm.
func world_to_minimap(world_pos: Vector2) -> Vector2:
	var player_pos := _player.global_position if _player else Vector2.ZERO
	return size * 0.5 + (world_pos - player_pos) / Room.TILE_SIZE * PX_PER_TILE


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND)
	if _manager == null:
		return
	for pair in _manager.connections:
		var a: Room = pair[0]
		var b: Room = pair[1]
		if _manager.is_visited(a) or _manager.is_visited(b):
			var both := _manager.is_visited(a) and _manager.is_visited(b)
			draw_line(world_to_minimap(a.get_center_world()), world_to_minimap(b.get_center_world()),
					CORRIDOR if both else ROOM_KNOWN, 3.0 * PX_PER_TILE)
	for room in _manager.rooms:
		_draw_room(room)
	if is_revealing(Reveal.SECRETS):
		for node in get_tree().get_nodes_in_group(Chest.GROUP):
			if not (node as Chest).is_opened:
				draw_rect(Rect2(world_to_minimap(node.global_position) - Vector2(3, 3), Vector2(6, 6)), SECRET_COLOR)
		for node in get_tree().get_nodes_in_group(ElementalObstacle.GROUP):
			var obstacle := node as ElementalObstacle
			if obstacle.kind == ElementalObstacle.Kind.HIDDEN_WALL and not obstacle.is_resolved:
				draw_circle(world_to_minimap(obstacle.global_position), 4.0, SECRET_COLOR)
	if is_revealing(Reveal.ENEMIES):
		var font := get_theme_default_font()
		for node in get_tree().get_nodes_in_group(OverworldEnemy.GROUP):
			var enemy := node as OverworldEnemy
			if enemy.is_defeated():
				continue
			var at := world_to_minimap(enemy.global_position)
			draw_circle(at, 4.0, ENEMY_DOT)
			draw_string(font, at + Vector2(5, -3), str(enemy.get_level()), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ENEMY_DOT)
	if _player:
		draw_circle(size * 0.5, 5.0, PLAYER_DOT)
		draw_arc(size * 0.5, 7.0, 0.0, TAU, 16, Color.BLACK, 1.5, true)
	draw_rect(Rect2(Vector2.ZERO, size).grow(-2.0), BORDER, false, 4.0)


func _draw_room(room: Room) -> void:
	var visited := _manager.is_visited(room)
	if not visited and not _is_known(room):
		return
	var world_rect := room.get_world_rect()
	var top_left := world_to_minimap(world_rect.position)
	var rect := Rect2(top_left, world_rect.size / Room.TILE_SIZE * PX_PER_TILE)
	if visited:
		draw_rect(rect, ROOM_CURRENT if room == _manager.current_room else ROOM_VISITED)
		if room == _manager.current_room:
			draw_rect(rect, PLAYER_DOT, false, 2.0)
	else:
		draw_rect(rect, ROOM_KNOWN, false, 2.0)
	_draw_icon(room.room_type, rect.get_center(), minf(rect.size.x, rect.size.y) * 0.22,
			1.0 if visited else 0.5)


## Phòng chưa vào nhưng nối với phòng đã vào thì hiện viền mờ.
func _is_known(room: Room) -> bool:
	for pair in _manager.connections:
		if pair[0] == room and _manager.is_visited(pair[1]):
			return true
		if pair[1] == room and _manager.is_visited(pair[0]):
			return true
	return false


func _draw_icon(type: Room.RoomType, center: Vector2, radius: float, alpha: float) -> void:
	if not ICON_COLORS.has(type):
		return
	var color := Color(ICON_COLORS[type], alpha)
	radius = maxf(radius, 6.0)
	match type:
		Room.RoomType.COMBAT, Room.RoomType.ELITE:
			# Hai kiếm chéo.
			draw_line(center + Vector2(-radius, -radius), center + Vector2(radius, radius), color, 3.0)
			draw_line(center + Vector2(radius, -radius), center + Vector2(-radius, radius), color, 3.0)
			if type == Room.RoomType.ELITE:
				draw_arc(center, radius * 1.3, 0.0, TAU, 20, color, 2.0)
		Room.RoomType.BOSS:
			# Đầu lâu đơn giản.
			draw_circle(center, radius, color)
			draw_circle(center + Vector2(-radius * 0.4, -radius * 0.1), radius * 0.25, Color.BLACK)
			draw_circle(center + Vector2(radius * 0.4, -radius * 0.1), radius * 0.25, Color.BLACK)
		Room.RoomType.CHEST:
			draw_rect(Rect2(center - Vector2(radius, radius * 0.7), Vector2(radius * 2.0, radius * 1.4)), color)
			draw_line(center + Vector2(-radius, -radius * 0.1), center + Vector2(radius, -radius * 0.1), Color.BLACK, 2.0)
		Room.RoomType.REST:
			# Dấu cộng = hồi máu.
			draw_rect(Rect2(center - Vector2(radius * 0.3, radius), Vector2(radius * 0.6, radius * 2.0)), color)
			draw_rect(Rect2(center - Vector2(radius, radius * 0.3), Vector2(radius * 2.0, radius * 0.6)), color)
		Room.RoomType.PUZZLE:
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(0.0, -radius), center + Vector2(radius, 0.0),
				center + Vector2(0.0, radius), center + Vector2(-radius, 0.0)]), color)
