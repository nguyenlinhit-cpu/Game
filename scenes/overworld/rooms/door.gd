class_name Door
extends StaticBody2D
## Cửa phòng. Mở thì không chặn; đóng thì hiện song chắn và bật va chạm.

const CLOSE_TIME: float = 0.2
const BAR_COLOR := Color("c8553d")
const FRAME_COLOR := Color("f2d58a")
const OPEN_MARK_COLOR := Color(0.95, 0.84, 0.54, 0.18)

var side: int = 0

var _size: Vector2
var _shape: CollisionShape2D
var _closed: bool = false
## 0 = mở hẳn, 1 = đóng hẳn (cho hoạt ảnh).
var _close_amount: float = 0.0:
	set(value):
		_close_amount = value
		queue_redraw()


func setup(door_side: int, span_px: float) -> void:
	side = door_side
	collision_layer = PhysicsLayers.WORLD
	collision_mask = 0
	var horizontal := side == Room.Side.NORTH or side == Room.Side.SOUTH
	_size = Vector2(span_px, Room.TILE_SIZE) if horizontal else Vector2(Room.TILE_SIZE, span_px)
	var rect := RectangleShape2D.new()
	rect.size = _size
	_shape = CollisionShape2D.new()
	_shape.shape = rect
	_shape.disabled = true
	add_child(_shape)


func is_closed() -> bool:
	return _closed


func set_closed(closed: bool) -> void:
	if closed == _closed:
		return
	_closed = closed
	# Đổi va chạm trong lúc vật lý đang chạy phải hoãn tới cuối khung.
	_shape.set_deferred("disabled", not closed)
	create_tween().tween_property(self, "_close_amount", 1.0 if closed else 0.0, CLOSE_TIME)


func _draw() -> void:
	var rect := Rect2(-_size * 0.5, _size)
	if _close_amount <= 0.01:
		draw_rect(rect.grow(-6.0), OPEN_MARK_COLOR, false, 2.0)
		return
	var horizontal := _size.x > _size.y
	var bar_count := 6
	var bar_color := Color(BAR_COLOR, _close_amount)
	for i in bar_count:
		var t := (i + 0.5) / bar_count
		if horizontal:
			var x := rect.position.x + rect.size.x * t
			var half_len := rect.size.y * 0.5 * _close_amount
			draw_line(Vector2(x, -half_len), Vector2(x, half_len), bar_color, 8.0)
		else:
			var y := rect.position.y + rect.size.y * t
			var half_len := rect.size.x * 0.5 * _close_amount
			draw_line(Vector2(-half_len, y), Vector2(half_len, y), bar_color, 8.0)
	draw_rect(rect, Color(FRAME_COLOR, _close_amount), false, 4.0)
