extends Node
## Nhiệm vụ ngày/tuần, thành tựu, quà người mới. Logic đầy đủ ở Phase 10.

## Nhiệm vụ ngày làm mới lúc 4:00 sáng giờ máy; nhiệm vụ tuần làm mới sáng thứ Hai cùng giờ.
const DAILY_RESET_HOUR: int = 4

var activity_points: int = 0
var claimed_milestones: Array[int] = []
## Mốc giờ lớn nhất từng thấy, để chống chỉnh giờ lùi.
var last_seen_unix: int = 0


func is_unlocked() -> bool:
	# TODO Phase 10/12: mở sau Chương 1 bằng cờ cốt truyện.
	return false


func check_reset() -> void:
	# TODO Phase 10: so giờ máy với last_seen_unix; giờ lùi thì không làm mới cho tới khi vượt mốc cũ.
	pass


func to_dict() -> Dictionary:
	return {
		"activity_points": activity_points,
		"claimed_milestones": claimed_milestones.duplicate(),
		"last_seen_unix": last_seen_unix,
	}


func from_dict(data: Dictionary) -> void:
	activity_points = int(data.get("activity_points", 0))
	claimed_milestones.clear()
	var milestones: Variant = data.get("claimed_milestones", [])
	if milestones is Array:
		for value: Variant in milestones:
			claimed_milestones.append(int(value))
	last_seen_unix = int(data.get("last_seen_unix", 0))
