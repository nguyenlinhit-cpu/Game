class_name DamageNumberPool
extends Control
## Số sát thương/hồi máu bay lên. Dùng lại Label có sẵn (object pool) để không tạo node mới mỗi đòn.

const POOL_SIZE: int = 24
const RISE: float = 70.0
const DURATION: float = 0.9

var _pool: Array[Label] = []
var _next: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in POOL_SIZE:
		var label := Label.new()
		label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 10)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.hide()
		add_child(label)
		_pool.append(label)


func spawn(text: String, at: Vector2, color: Color, font_size: int = 40) -> void:
	var label := _pool[_next]
	_next = (_next + 1) % _pool.size()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.reset_size()
	label.position = at - label.size * 0.5 + Vector2(randf_range(-18.0, 18.0), 0.0)
	label.modulate.a = 1.0
	label.scale = Vector2.ONE
	label.show()
	var tween := label.create_tween().set_parallel()
	tween.tween_property(label, "position:y", label.position.y - RISE, DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, DURATION * 0.4).set_delay(DURATION * 0.6)
	tween.chain().tween_callback(label.hide)


func get_active_count() -> int:
	return _pool.filter(func(label: Label) -> bool: return label.visible).size()
