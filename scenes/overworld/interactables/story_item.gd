class_name StoryItem
extends Interactable
## Vật cốt truyện nhặt bằng F (nhật ký, Lõi Tiếng Vọng...): chạy điểm kích hoạt "item" cùng id.
## Ẩn/hiện theo cờ bằng StoryGate con.

@export var trigger_id: StringName

var _time: float = 0.0


func _ready() -> void:
	super()
	if prompt_key.is_empty():
		prompt_key = "PROMPT_PICK_UP"
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 40.0
	shape.shape = circle
	add_child(shape)


func can_interact() -> bool:
	return StoryManager.can_fire(trigger_id) and not StoryManager.is_playing()


func _on_interact(_by: Node) -> void:
	StoryManager.fire(trigger_id)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var glow := 0.5 + 0.5 * sin(_time * 3.0)
	draw_circle(Vector2.ZERO, 34.0 + glow * 6.0, Color(UiKit.GOLD, 0.2))
	draw_rect(Rect2(-16.0, -20.0, 32.0, 40.0), Color("8a5a2b"))
	draw_rect(Rect2(-16.0, -20.0, 32.0, 40.0), UiKit.GOLD, false, 3.0)
