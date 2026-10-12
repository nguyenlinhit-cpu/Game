class_name TouchJoystick
extends Control
## Joystick ảo cho màn cảm ứng. Phát InputEventAction (move_*) với độ mạnh theo độ lệch,
## nên nhân vật đọc như tay cầm thật qua Input.get_vector(). Hỗ trợ đa chạm.
## Trên PC: bật "emulate_touch_from_mouse" nên dùng chuột thử được.

const ACTIONS: Dictionary = {
	"move_left": Vector2.LEFT,
	"move_right": Vector2.RIGHT,
	"move_up": Vector2.UP,
	"move_down": Vector2.DOWN,
}
const BASE_COLOR := Color(1.0, 1.0, 1.0, 0.12)
const RING_COLOR := Color(0.95, 0.84, 0.54, 0.5)
const KNOB_COLOR := Color(0.95, 0.84, 0.54, 0.75)

## Độ lệch tối đa của núm (px).
@export var radius: float = 110.0
@export_range(0.0, 0.9) var deadzone: float = 0.15

var vector: Vector2 = Vector2.ZERO

var _touch_index: int = -1
var _strengths: Dictionary = {}


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var touch := event as InputEventScreenTouch
	if touch:
		if touch.pressed and _touch_index == -1 and get_global_rect().has_point(touch.position):
			_touch_index = touch.index
			_update_from(touch.position)
			get_viewport().set_input_as_handled()
		elif not touch.pressed and touch.index == _touch_index:
			_touch_index = -1
			_set_vector(Vector2.ZERO)
			get_viewport().set_input_as_handled()
		return
	var drag := event as InputEventScreenDrag
	if drag and drag.index == _touch_index:
		_update_from(drag.position)
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	# Ẩn hoặc rời cây giữa chừng thì nhả hết phím để nhân vật không chạy mãi.
	if what == NOTIFICATION_VISIBILITY_CHANGED or what == NOTIFICATION_EXIT_TREE:
		_touch_index = -1
		_set_vector(Vector2.ZERO)


func _update_from(touch_position: Vector2) -> void:
	var offset := (touch_position - get_global_rect().get_center()) / radius
	_set_vector(offset.limit_length(1.0))


func _set_vector(value: Vector2) -> void:
	if value.length() < deadzone:
		value = Vector2.ZERO
	vector = value
	for action: String in ACTIONS:
		var strength := maxf(value.dot(ACTIONS[action]), 0.0)
		if is_equal_approx(strength, float(_strengths.get(action, 0.0))):
			continue
		_strengths[action] = strength
		var input_event := InputEventAction.new()
		input_event.action = action
		input_event.pressed = strength > 0.0
		input_event.strength = strength
		Input.parse_input_event(input_event)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, radius, BASE_COLOR)
	draw_arc(center, radius, 0.0, TAU, 48, RING_COLOR, 3.0, true)
	draw_circle(center + vector * radius, radius * 0.42, KNOB_COLOR)
