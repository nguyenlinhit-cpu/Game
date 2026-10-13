class_name Chest
extends Interactable
## Rương 3 bậc. Mở ra lăn bảng rơi đồ rương của khu (Loot.roll_chest: xu, Ký Ức, Tinh Thể; Lệ Tinh vì rương
## chỉ mở 1 lần), cộng vào túi đồ và hiện bảng phần thưởng. Trạng thái "đã mở" lưu trong GameState.map_states.

enum Tier { NORMAL, PRECIOUS, PUZZLE }

const TIER_COLORS: Dictionary = {
	Tier.NORMAL: Color("8a5a2b"),
	Tier.PRECIOUS: Color("3a6ea5"),
	Tier.PUZZLE: Color("7b4bb3"),
}
const BAND_COLOR := Color("f2d58a")

@export var chest_id: StringName
@export var tier: Tier = Tier.NORMAL
## Khu để chọn bảng rơi đồ; OverworldMap gán theo phòng/map khi nạp.
@export var zone: StringName = &""

var is_opened: bool = false
## Phần thưởng lần mở vừa rồi (test đọc).
var last_rewards: Dictionary = {}

const GROUP: StringName = &"chest"


func _ready() -> void:
	super()
	add_to_group(GROUP)


func can_interact() -> bool:
	return not is_opened


func open() -> void:
	interact(null)


## Nạp lại map: rương đã mở từ trước, không phát tín hiệu/thông báo.
func restore_opened() -> void:
	is_opened = true
	queue_redraw()


func _on_interact(_by: Node) -> void:
	is_opened = true
	queue_redraw()
	last_rewards = Loot.roll_chest(zone, tier)
	Loot.grant(last_rewards)
	EventBus.chest_opened.emit(chest_id)
	EventBus.reward_popup_requested.emit(tr("REWARD_CHEST_TITLE"), Loot.describe(last_rewards))
	CameraRig.shake(6.0, 0.15)
	AudioManager.play_sfx(&"chest")


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
