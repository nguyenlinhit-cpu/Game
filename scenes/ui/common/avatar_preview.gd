@tool
class_name AvatarPreview
extends Control
## Ô xem trước nhân vật bằng hình tạm (dùng ở màn chọn nhân vật chính).

@export var body_color: Color = Color.GRAY:
	set(value):
		body_color = value
		queue_redraw()
@export var accent_color: Color = Color.WHITE:
	set(value):
		accent_color = value
		queue_redraw()
@export var letter: String = "":
	set(value):
		letter = value
		queue_redraw()


func apply_skin(skin: CharacterSkin) -> void:
	if skin == null:
		return
	body_color = skin.placeholder_color
	accent_color = skin.accent_color


func _draw() -> void:
	var radius := minf(size.x, size.y) * 0.32
	PlaceholderArt.draw_character(self, size * 0.5 + Vector2(0.0, radius * 0.25), radius,
			body_color, accent_color, letter)
