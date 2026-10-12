class_name Interactable
extends Area2D
## Vật tương tác bằng phím F (hoặc nút cảm ứng). Người chơi tự tìm vật gần nhất trong tầm.
## Lớp con ghi đè can_interact() và _on_interact(); nhớ gọi super() nếu viết _ready().

signal interacted(by: Node)

## Khóa dịch của lời nhắc, vd. "PROMPT_OPEN_CHEST".
@export var prompt_key: String = ""


func _ready() -> void:
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	monitoring = false
	monitorable = true


func can_interact() -> bool:
	return true


func get_prompt() -> String:
	return tr(prompt_key)


func interact(by: Node) -> void:
	if not can_interact():
		return
	_on_interact(by)
	interacted.emit(by)


func _on_interact(_by: Node) -> void:
	pass
