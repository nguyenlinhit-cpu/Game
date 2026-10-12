extends Node
## Banner, bộ đếm bảo hiểm, lịch sử quay. Logic đầy đủ ở Phase 11.

const HISTORY_LIMIT: int = 100

## Bộ đếm theo banner:
## { banner_id: {"pity_5": int, "pity_4": int, "guaranteed_5": bool, "guaranteed_4": bool, "total_pulls": int} }
var pity_state: Dictionary = {}
var history: Array[Dictionary] = []
## RNG có seed lưu lại để tái hiện lỗi.
var rng := RandomNumberGenerator.new()


func is_unlocked() -> bool:
	# TODO Phase 11/12: mở sau Chương 1 bằng cờ cốt truyện.
	return false


func pull(_banner_id: StringName, _count: int) -> Array[Dictionary]:
	# TODO Phase 11: tỉ lệ 0,6% / bảo hiểm mềm từ lượt 74 / chắc chắn lượt 90, 50/50, vé theo banner.
	push_warning("GachaManager.pull: chưa làm (Phase 11)")
	return []


func to_dict() -> Dictionary:
	return {
		"pity_state": pity_state.duplicate(true),
		"history": history.duplicate(true),
		"rng_seed": str(rng.seed),
		"rng_state": str(rng.state),
	}


func from_dict(data: Dictionary) -> void:
	var state: Variant = data.get("pity_state", {})
	pity_state = state if state is Dictionary else {}
	history.clear()
	var saved_history: Variant = data.get("history", [])
	if saved_history is Array:
		for entry: Variant in saved_history:
			if entry is Dictionary:
				history.append(entry)
	if data.has("rng_seed"):
		rng.seed = int(str(data["rng_seed"]))
		rng.state = int(str(data.get("rng_state", "0")))
