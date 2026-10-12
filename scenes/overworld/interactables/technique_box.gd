class_name TechniqueBox
extends Interactable
## Hộp Bí Kỹ: vật phá được, phá ra hồi Điểm Bí Kỹ.
## TODO Phase 6: cộng Điểm Bí Kỹ thật. TODO Phase 3: Đòn Mở Màn cũng phá được hộp.

const BOX_COLOR := Color("3d5a80")
const GLOW_COLOR := Color("f2d58a")

@export var box_id: StringName

var is_broken: bool = false


func can_interact() -> bool:
	return not is_broken


func break_open() -> void:
	interact(null)


func _on_interact(_by: Node) -> void:
	is_broken = true
	print("[TechniqueBox] Phá hộp %s: +1 Điểm Bí Kỹ – TODO Phase 6" % box_id)
	EventBus.toast_requested.emit(tr("TOAST_BOX_BROKEN"))
	CameraRig.shake(4.0, 0.12)
	set_deferred("monitorable", false)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "scale", Vector2(1.4, 0.2), 0.18)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(hide)


func _draw() -> void:
	var rect := Rect2(-22.0, -22.0, 44.0, 44.0)
	draw_rect(rect, BOX_COLOR)
	draw_rect(rect, GLOW_COLOR, false, 2.0)
	draw_line(rect.position, rect.end, GLOW_COLOR, 2.0)
	draw_line(Vector2(rect.end.x, rect.position.y), Vector2(rect.position.x, rect.end.y), GLOW_COLOR, 2.0)
