class_name RestPoint
extends Interactable
## Điểm nghỉ trong phòng nghỉ: hồi máu cả đội, lưu game, dịch chuyển nhanh.
## Hồi đầy Điểm Bí Kỹ. TODO Phase 9: hồi máu thật. TODO Phase 14: tự lưu. TODO Phase 12: dịch chuyển nhanh.

const CRYSTAL_COLOR := Color("f2d58a")

@export var rest_point_id: StringName

var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _on_interact(_by: Node) -> void:
	GameState.change_technique_points(GameState.MAX_TECHNIQUE_POINTS)
	print("[RestPoint] %s: hồi đầy máu cả đội – TODO Phase 9" % rest_point_id)
	print("[RestPoint] %s: lưu game – TODO Phase 14" % rest_point_id)
	EventBus.toast_requested.emit(tr("TOAST_RESTED"))


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_time * 2.5)
	draw_circle(Vector2.ZERO, 46.0 + pulse * 8.0, Color(CRYSTAL_COLOR, 0.12 + pulse * 0.1))
	var bob := sin(_time * 2.0) * 5.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, -46.0 + bob), Vector2(18.0, -10.0 + bob),
		Vector2(0.0, 26.0 + bob), Vector2(-18.0, -10.0 + bob),
	]), CRYSTAL_COLOR)
	draw_set_transform(Vector2(0.0, 34.0), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 30.0, Color(0.0, 0.0, 0.0, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
