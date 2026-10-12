class_name TouchActionButton
extends Control
## Nút tròn cảm ứng bấm một action (lướt, tương tác...). Phát InputEventAction thật nên
## Input.is_action_just_pressed() và _unhandled_input() nhận như bấm phím.

const FILL_COLOR := Color(1.0, 1.0, 1.0, 0.14)
const PRESSED_COLOR := Color(0.95, 0.84, 0.54, 0.4)
const RING_COLOR := Color(0.95, 0.84, 0.54, 0.6)
const COOLDOWN_COLOR := Color(0.0, 0.0, 0.0, 0.55)

@export var action: StringName
@export var label_key: String = ""

## 0–1, phần nút bị che khi đang hồi chiêu.
var cooldown_ratio: float = 0.0:
	set(value):
		if not is_equal_approx(value, cooldown_ratio):
			cooldown_ratio = value
			queue_redraw()

var _touch_index: int = -1


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var touch := event as InputEventScreenTouch
	if touch == null:
		return
	if touch.pressed and _touch_index == -1 and _contains(touch.position):
		_touch_index = touch.index
		_send(true)
		get_viewport().set_input_as_handled()
	elif not touch.pressed and touch.index == _touch_index:
		_touch_index = -1
		_send(false)
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if (what == NOTIFICATION_VISIBILITY_CHANGED or what == NOTIFICATION_EXIT_TREE) and _touch_index != -1:
		_touch_index = -1
		_send(false)


func _contains(point: Vector2) -> bool:
	var rect := get_global_rect()
	return point.distance_to(rect.get_center()) <= minf(rect.size.x, rect.size.y) * 0.5


func _send(pressed: bool) -> void:
	var input_event := InputEventAction.new()
	input_event.action = action
	input_event.pressed = pressed
	Input.parse_input_event(input_event)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.5
	draw_circle(center, radius, PRESSED_COLOR if _touch_index != -1 else FILL_COLOR)
	if cooldown_ratio > 0.0:
		# Quạt tối thu nhỏ dần theo thời gian hồi.
		var points := PackedVector2Array([center])
		var steps := 32
		for i in steps + 1:
			points.append(center + Vector2.from_angle(-PI * 0.5 + TAU * cooldown_ratio * i / steps) * radius)
		draw_colored_polygon(points, COOLDOWN_COLOR)
	draw_arc(center, radius, 0.0, TAU, 48, RING_COLOR, 3.0, true)
	if not label_key.is_empty():
		var font := get_theme_default_font()
		var font_size := 26
		var text := tr(label_key)
		var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		draw_string(font, center + Vector2(-width * 0.5, font_size * 0.35), text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
