class_name EnemyGroupPlaceholder
extends Node2D
## Vật thể giả thay cho một nhóm quái (Phase 2). Phase 3 thay bằng OverworldEnemy thật,
## giữ nguyên giao diện: group "enemy_group", is_defeated(), defeat(), tín hiệu defeated.

signal defeated(group: Node)

const BODY_COLOR := Color("8e2a3b")
const RIM_COLOR := Color("e8552b")

@export var group_id: StringName
@export_range(1, 5) var enemy_count: int = 3

var _defeated: bool = false
var _time: float = 0.0


func _ready() -> void:
	add_to_group(Room.ENEMY_GROUP)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func is_defeated() -> bool:
	return _defeated


func defeat() -> void:
	if _defeated:
		return
	_defeated = true
	defeated.emit(self)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)


func _draw() -> void:
	# Các chấm đỏ xếp vòng tròn, mỗi chấm một con quái; nhấp nhô để dễ thấy.
	for i in enemy_count:
		var angle := TAU * i / enemy_count - PI * 0.5
		var offset := Vector2.from_angle(angle) * (0.0 if enemy_count == 1 else 36.0)
		offset.y += sin(_time * 4.0 + i) * 4.0
		draw_circle(offset, 22.0, BODY_COLOR)
		draw_arc(offset, 22.0, 0.0, TAU, 32, RIM_COLOR, 3.0, true)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(-8.0, -64.0), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, RIM_COLOR)
