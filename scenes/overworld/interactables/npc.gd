class_name Npc
extends Interactable
## NPC nói chuyện bằng F. Cảnh hội thoại chọn theo cờ cốt truyện (data/story/story.json → "npcs").
## Hình tạm: thân tròn màu của người nói, tên trên đầu, dấu "!" khi có cảnh mới (không phải câu nói thường).

@export var npc_id: StringName
## Đang bị đóng băng (Garren ở Kho Chứa): vẽ thêm khối băng.
@export var frozen: bool = false

var _time: float = 0.0


func _ready() -> void:
	super()
	if prompt_key.is_empty():
		prompt_key = "PROMPT_TALK"
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 48.0
	shape.shape = circle
	add_child(shape)
	StoryManager.story_changed.connect(queue_redraw)


func get_prompt() -> String:
	return tr(prompt_key) % get_display_name()


func get_display_name() -> String:
	return StoryManager.speaker_name(StoryManager.npc_speaker(npc_id))


func can_interact() -> bool:
	return not StoryManager.npc_dialogue(npc_id).is_empty() and not StoryManager.is_playing()


## Có cảnh quan trọng đang chờ (không phải câu nói thường ở cuối danh sách).
func has_news() -> bool:
	var dialogue := StoryManager.npc_dialogue(npc_id)
	var options: Array = StoryManager.data.get("npcs", {}).get(String(npc_id), {}).get("options", [])
	if dialogue.is_empty() or options.is_empty():
		return false
	return options.size() == 1 or dialogue != str(options[-1]["dialogue"])


func _on_interact(_by: Node) -> void:
	StoryManager.talk(npc_id)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var color := StoryManager.speaker_color(StoryManager.npc_speaker(npc_id))
	draw_set_transform(Vector2(0.0, 30.0), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 30.0, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_circle(Vector2(0.0, 0.0), 30.0, color)
	draw_circle(Vector2(0.0, -34.0), 18.0, color.lightened(0.2))
	if frozen:
		draw_rect(Rect2(-44.0, -64.0, 88.0, 104.0), Color(0.7, 0.9, 1.0, 0.45))
		draw_rect(Rect2(-44.0, -64.0, 88.0, 104.0), Color(0.85, 0.95, 1.0, 0.9), false, 3.0)
	var font := ThemeDB.fallback_font
	var label := get_display_name()
	draw_string(font, Vector2(-120.0, -66.0), label, HORIZONTAL_ALIGNMENT_CENTER, 240.0, 22, Color.WHITE)
	if has_news():
		var bob := sin(_time * 4.0) * 4.0
		draw_string(font, Vector2(-10.0, -96.0 + bob), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, UiKit.GOLD)
