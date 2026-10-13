class_name StoryTrigger
extends Area2D
## Vùng kích hoạt cảnh cốt truyện khi người chơi đi vào (id trong data/story/story.json → "triggers").
## Chạy một lần nhờ cờ "unless" của điểm kích hoạt.

@export var trigger_id: StringName
@export var size_tiles: Vector2i = Vector2i(5, 3)


func _ready() -> void:
	collision_layer = 0
	collision_mask = PhysicsLayers.PLAYER
	monitorable = false
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(size_tiles * Room.TILE_SIZE)
	shape.shape = rect
	add_child(shape)
	body_entered.connect(func(body: Node2D) -> void:
		if body is Player:
			StoryManager.fire(trigger_id))
