class_name PlaceholderArt
extends RefCounted
## Hình tạm khi chưa có sprite: khối màu + chữ cái đầu tên.
## Dùng chung cho Node2D (ngoài map) và Control (giao diện) vì cả hai đều là CanvasItem.


static func draw_character(canvas: CanvasItem, center: Vector2, radius: float,
		body_color: Color, accent_color: Color, letter: String) -> void:
	# Bóng dưới chân (hình elip = hình tròn bị bóp dọc).
	canvas.draw_set_transform(center + Vector2(0.0, radius * 0.95), 0.0, Vector2(1.0, 0.3))
	canvas.draw_circle(Vector2.ZERO, radius * 0.9, Color(0.0, 0.0, 0.0, 0.35))
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	canvas.draw_circle(center, radius, body_color)
	canvas.draw_arc(center, radius, 0.0, TAU, 64, accent_color, maxf(2.0, radius * 0.1), true)

	# Mảnh Hồn nhỏ trên đỉnh đầu, gợi ý nguyên tố Hồn của nhân vật chính.
	var shard_center := center + Vector2(0.0, -radius * 1.35)
	var shard_size := radius * 0.22
	canvas.draw_colored_polygon(PackedVector2Array([
		shard_center + Vector2(0.0, -shard_size * 1.4),
		shard_center + Vector2(shard_size, 0.0),
		shard_center + Vector2(0.0, shard_size * 1.4),
		shard_center + Vector2(-shard_size, 0.0),
	]), accent_color)

	if letter.is_empty():
		return
	var font := ThemeDB.fallback_font
	var font_size := int(radius)
	var text_width := font.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var baseline_y := center.y + (font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
	canvas.draw_string(font, Vector2(center.x - text_width * 0.5, baseline_y), letter,
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
