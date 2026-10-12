class_name Chest
extends Interactable
## Rương. Phase 2 chỉ mở và báo log; phần thưởng ở Phase 10, lưu "đã mở" ở Phase 3.

enum Tier { NORMAL, PRECIOUS, PUZZLE }

const TIER_COLORS: Dictionary = {
	Tier.NORMAL: Color("8a5a2b"),
	Tier.PRECIOUS: Color("3a6ea5"),
	Tier.PUZZLE: Color("7b4bb3"),
}
const BAND_COLOR := Color("f2d58a")

@export var chest_id: StringName
@export var tier: Tier = Tier.NORMAL

var is_opened: bool = false


func can_interact() -> bool:
	return not is_opened


func open() -> void:
	interact(null)


func _on_interact(_by: Node) -> void:
	is_opened = true
	queue_redraw()
	print("[Chest] Mở rương %s (bậc %s) – TODO Phase 10: bảng rơi đồ" % [chest_id, Tier.keys()[tier]])
	EventBus.chest_opened.emit(chest_id)
	EventBus.toast_requested.emit(tr("TOAST_CHEST_OPENED"))
	CameraRig.shake(6.0, 0.15)


func _draw() -> void:
	var body := Rect2(-30.0, -18.0, 60.0, 40.0)
	var color: Color = TIER_COLORS[tier]
	draw_rect(body, color.darkened(0.4) if is_opened else color)
	draw_rect(body, BAND_COLOR, false, 3.0)
	if is_opened:
		# Nắp bật ra sau, lộ lòng rương tối.
		draw_rect(Rect2(-30.0, -40.0, 60.0, 14.0), color)
		draw_rect(Rect2(-26.0, -16.0, 52.0, 12.0), Color(0.05, 0.03, 0.02))
	else:
		draw_rect(Rect2(-30.0, -24.0, 60.0, 14.0), color.lightened(0.15))
		draw_rect(Rect2(-6.0, -12.0, 12.0, 14.0), BAND_COLOR)
