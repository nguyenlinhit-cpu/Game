class_name Npc
extends Interactable
## NPC nói chuyện bằng F. Cảnh hội thoại chọn theo cờ cốt truyện (data/story/story.json → "npcs").
## Idle artwork, dialogue portraits, overhead name and quest marker share one NPC identity.

@export var npc_id: StringName
## Đang bị đóng băng (Garren ở Kho Chứa): vẽ thêm khối băng.
@export var frozen: bool = false

var _time: float = 0.0
var sprite: AnimatedSprite2D
var ice_shell: Node2D
const SPRITE_HEIGHT := 170.0


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
	var frames := ArtLibrary.npc_frames(npc_id)
	if frames:
		sprite = ArtLibrary.make_sprite(frames, SPRITE_HEIGHT)
		add_child(sprite)
		ArtLibrary.play(sprite, "idle", "s")
	ice_shell = IceShell.new()
	ice_shell.name = "IceShell"
	ice_shell.z_index = 1
	ice_shell.visible = frozen
	add_child(ice_shell)


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
	ice_shell.visible = frozen
	queue_redraw()


func _draw() -> void:
	var color := StoryManager.speaker_color(StoryManager.npc_speaker(npc_id))
	draw_set_transform(Vector2(0.0, 5.0), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 30.0, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if sprite == null:
		draw_circle(Vector2(0.0, 0.0), 30.0, color)
		draw_circle(Vector2(0.0, -34.0), 18.0, color.lightened(0.2))
	var font := ThemeDB.fallback_font
	var label := get_display_name()
	var name_y := -SPRITE_HEIGHT - 16.0 if sprite else -66.0
	draw_string_outline(font, Vector2(-140.0, name_y), label, HORIZONTAL_ALIGNMENT_CENTER, 280.0, 22, 5, Color("131021"))
	draw_string(font, Vector2(-140.0, name_y), label, HORIZONTAL_ALIGNMENT_CENTER, 280.0, 22, Color.WHITE)
	if has_news():
		var bob := sin(_time * 4.0) * 4.0
		draw_string_outline(font, Vector2(-10.0, name_y - 32.0 + bob), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, 5, Color("131021"))
		draw_string(font, Vector2(-10.0, name_y - 32.0 + bob), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, UiKit.GOLD)


class IceShell:
	extends Node2D

	func _draw() -> void:
		var points := PackedVector2Array([Vector2(-55, 10), Vector2(-65, -125), Vector2(-34, -181),
			Vector2(34, -187), Vector2(65, -124), Vector2(55, 10)])
		draw_colored_polygon(points, Color(0.5, 0.82, 1.0, 0.25))
		draw_colored_polygon(PackedVector2Array([points[0], points[1], points[2], Vector2(-8, -38)]), Color(0.7, 0.94, 1.0, 0.28))
		draw_colored_polygon(PackedVector2Array([points[3], points[4], points[5], Vector2(18, -75)]), Color(0.4, 0.72, 1.0, 0.25))
		var outline := points.duplicate()
		outline.append(points[0])
		draw_polyline(outline, Color(0.7, 0.94, 1.0, 0.8), 3.0, true)
		draw_polyline(PackedVector2Array([points[2], Vector2(-8, -38), points[0]]), Color(0.85, 0.98, 1.0, 0.6), 2.0, true)
