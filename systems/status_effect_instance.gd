class_name StatusEffectInstance
extends RefCounted
## Một hiệu ứng đang gắn trên một đơn vị.

static var _next_uid: int = 1

var data: StatusEffectData
var source: BattleUnit
var stacks: int = 1
var turns_left: int = 1
## Giá trị nền chụp lúc gắn (xem StatusEffectData.DotMode).
var base_value: float = 0.0
## Cấp người gắn, dùng cho hệ số phòng thủ của sát thương theo lượt.
var source_level: int = 1
## Nguồn gỡ bộ điều chỉnh chỉ số trong Stats.
var uid: StringName


func _init(effect: StatusEffectData, from: BattleUnit) -> void:
	data = effect
	source = from
	turns_left = effect.duration_turns
	source_level = from.level if from else 1
	uid = StringName("status_%d_%s" % [_next_uid, effect.id])
	_next_uid += 1
