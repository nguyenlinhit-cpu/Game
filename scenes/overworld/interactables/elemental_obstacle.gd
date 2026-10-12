class_name ElementalObstacle
extends StaticBody2D
## Vật cản giải đố: chỉ Đòn Mở Màn đúng nguyên tố mới mở được (mục 6, cột "Tương tác ngoài map").
## Rào Ma Biến không mở bằng Đòn Mở Màn, chỉ lướt xuyên qua bằng Bí Kỹ "Bước Hư Ảnh".
## Mở rồi thì lưu trong GameState.map_states["resolved_obstacles"].

signal resolved(obstacle: ElementalObstacle)

enum Kind { VINES, FIRE_WALL, MACHINE_DOOR, FOG, RUSTED_GATE, CHASM, HIDDEN_WALL, WARP_BARRIER }

const GROUP: StringName = &"elemental_obstacle"
const REQUIRED_ELEMENTS: Dictionary = {
	Kind.VINES: Element.Type.FIRE,
	Kind.FIRE_WALL: Element.Type.WATER,
	Kind.MACHINE_DOOR: Element.Type.LIGHTNING,
	Kind.FOG: Element.Type.WIND,
	Kind.RUSTED_GATE: Element.Type.POISON,
	Kind.CHASM: Element.Type.WOOD,
	Kind.HIDDEN_WALL: Element.Type.SOUL,
}
const NAME_KEYS: Dictionary = {
	Kind.VINES: "OBSTACLE_VINES",
	Kind.FIRE_WALL: "OBSTACLE_FIRE_WALL",
	Kind.MACHINE_DOOR: "OBSTACLE_MACHINE_DOOR",
	Kind.FOG: "OBSTACLE_FOG",
	Kind.RUSTED_GATE: "OBSTACLE_RUSTED_GATE",
	Kind.CHASM: "OBSTACLE_CHASM",
	Kind.HIDDEN_WALL: "OBSTACLE_HIDDEN_WALL",
	Kind.WARP_BARRIER: "OBSTACLE_WARP_BARRIER",
}

@export var kind: Kind = Kind.VINES
@export var size_tiles: Vector2i = Vector2i(2, 1)

var is_resolved: bool = false

var _shape: CollisionShape2D
var _time: float = 0.0
## 0 = còn nguyên, 1 = đã mở hẳn (hoạt ảnh).
var _open_amount: float = 0.0:
	set(value):
		_open_amount = value
		queue_redraw()


func _ready() -> void:
	add_to_group(GROUP)
	match kind:
		Kind.WARP_BARRIER: collision_layer = PhysicsLayers.WARP_BARRIER
		Kind.CHASM: collision_layer = PhysicsLayers.PIT
		_: collision_layer = PhysicsLayers.WORLD
	collision_mask = 0
	var rect := RectangleShape2D.new()
	rect.size = get_size_px()
	_shape = CollisionShape2D.new()
	_shape.shape = rect
	add_child(_shape)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func get_size_px() -> Vector2:
	return Vector2(size_tiles * Room.TILE_SIZE)


func get_required_element() -> int:
	return REQUIRED_ELEMENTS.get(kind, Element.NONE)


func get_hit_radius() -> float:
	return get_size_px().length() * 0.5


## Đòn Mở Màn trúng. Trả về true nếu mở được.
func receive_opener(element: int) -> bool:
	if is_resolved or element != get_required_element():
		return false
	is_resolved = true
	_shape.set_deferred("disabled", true)
	create_tween().tween_property(self, "_open_amount", 1.0, 0.5)
	resolved.emit(self)
	EventBus.obstacle_resolved.emit(name)
	return true


## Nạp lại map: đã mở từ trước.
func restore_resolved() -> void:
	is_resolved = true
	_shape.disabled = true
	_open_amount = 1.0


func _draw() -> void:
	var size := get_size_px()
	var rect := Rect2(-size * 0.5, size)
	var fade := 1.0 - _open_amount
	match kind:
		Kind.VINES:
			draw_rect(rect, Color(0.12, 0.35, 0.15, 0.95 * fade))
			for i in 7:
				var x := rect.position.x + rect.size.x * (i + 0.5) / 7.0
				draw_line(Vector2(x, rect.position.y), Vector2(x + sin(_time + i) * 8.0, rect.end.y),
						Color(0.3, 0.7, 0.25, fade), 6.0)
		Kind.FIRE_WALL:
			for i in 6:
				var x := rect.position.x + rect.size.x * (i + 0.5) / 6.0
				var h := rect.size.y * (0.7 + 0.3 * sin(_time * 8.0 + i * 1.7))
				draw_colored_polygon(PackedVector2Array([Vector2(x - 12.0, rect.end.y), Vector2(x + 12.0, rect.end.y),
						Vector2(x, rect.end.y - h)]), Color(Element.color(Element.Type.FIRE), fade))
		Kind.MACHINE_DOOR:
			# Cửa máy trượt sang hai bên khi có điện.
			var half := rect.size.x * 0.5 * (1.0 - _open_amount)
			draw_rect(Rect2(rect.position, Vector2(half, rect.size.y)), Color(0.35, 0.37, 0.45))
			draw_rect(Rect2(Vector2(rect.end.x - half, rect.position.y), Vector2(half, rect.size.y)), Color(0.35, 0.37, 0.45))
			draw_circle(rect.get_center(), 8.0, Element.color(Element.Type.LIGHTNING) if is_resolved else Color(0.3, 0.1, 0.1))
		Kind.FOG:
			for i in 5:
				var center := rect.position + Vector2(rect.size.x * (i + 0.5) / 5.0, rect.size.y * 0.5 + sin(_time + i) * 6.0)
				draw_circle(center, rect.size.y * 0.7, Color(0.8, 0.85, 0.9, 0.5 * fade))
		Kind.RUSTED_GATE:
			draw_rect(rect, Color(0.45, 0.28, 0.15, 0.3 * fade))
			for i in 6:
				var x := rect.position.x + rect.size.x * (i + 0.5) / 6.0
				draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), Color(0.6, 0.35, 0.2, fade), 7.0)
		Kind.CHASM:
			draw_rect(rect, Color(0.02, 0.02, 0.04))
			if _open_amount > 0.0:
				# Cầu gỗ mọc ra.
				var bridge := Rect2(rect.position + Vector2(8.0, 0.0), Vector2((rect.size.x - 16.0), rect.size.y * _open_amount))
				draw_rect(bridge, Color(0.45, 0.3, 0.15))
				for y in range(0, int(bridge.size.y), 12):
					draw_line(Vector2(bridge.position.x, bridge.position.y + y), Vector2(bridge.end.x, bridge.position.y + y),
							Color(0.3, 0.2, 0.1), 2.0)
		Kind.HIDDEN_WALL:
			# Trông như tường thường có vết nứt; mở thì biến mất.
			draw_rect(rect, Color(Color("4a3f5c"), fade))
			draw_polyline(PackedVector2Array([rect.get_center() + Vector2(-20, -24), rect.get_center() + Vector2(-4, -4),
					rect.get_center() + Vector2(-12, 10), rect.get_center() + Vector2(8, 26)]),
					Color(Element.color(Element.Type.SOUL), 0.5 * fade), 2.0)
		Kind.WARP_BARRIER:
			var pulse := 0.5 + 0.5 * sin(_time * 4.0)
			draw_rect(rect, Color(0.55, 0.15, 0.6, 0.35 + 0.2 * pulse))
			draw_rect(rect, Color(0.85, 0.4, 0.95), false, 3.0)
