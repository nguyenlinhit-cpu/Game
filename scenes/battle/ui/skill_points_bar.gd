class_name SkillPointsBar
extends Control
## Ô Điểm Chiến Kỹ: 5 viên kim cương, viên sáng = điểm đang có.

const ON_COLOR := Color("f2d58a")
const OFF_COLOR := Color(1, 1, 1, 0.18)

var value: int = 0:
	set(new_value):
		value = new_value
		queue_redraw()
var max_value: int = 5


func _draw() -> void:
	var gap := size.x / max_value
	for i in max_value:
		var center := Vector2(gap * (i + 0.5), size.y * 0.5)
		var r := minf(gap * 0.38, size.y * 0.45)
		var points := PackedVector2Array([center + Vector2(0, -r), center + Vector2(r * 0.7, 0),
				center + Vector2(0, r), center + Vector2(-r * 0.7, 0)])
		draw_colored_polygon(points, ON_COLOR if i < value else OFF_COLOR)
