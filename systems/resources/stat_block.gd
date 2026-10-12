class_name StatBlock
extends Resource
## Bảng 11 chỉ số gốc. Nhân vật/quái có 2 bảng: cấp 1 và cấp 80.
## Máu, Tấn Công, Phòng Thủ nội suy tuyến tính theo cấp; các chỉ số khác lấy theo bảng cấp 1.
## TODO Phase 9: cộng thêm thưởng đột phá ở cấp 10/20.

@export var hp: float = 100.0
@export var atk: float = 50.0
@export var def: float = 50.0
@export var spd: float = 100.0
@export var crit_rate: float = 0.05
@export var crit_dmg: float = 0.5
@export var break_effect: float = 0.0
@export var energy_regen: float = 1.0
@export var effect_hit: float = 0.0
@export var effect_res: float = 0.0
@export var outgoing_healing: float = 0.0

const SCALING_TYPES: Array[int] = [Stats.Type.HP, Stats.Type.ATK, Stats.Type.DEF]


func get_value(type: Stats.Type) -> float:
	match type:
		Stats.Type.HP: return hp
		Stats.Type.ATK: return atk
		Stats.Type.DEF: return def
		Stats.Type.SPD: return spd
		Stats.Type.CRIT_RATE: return crit_rate
		Stats.Type.CRIT_DMG: return crit_dmg
		Stats.Type.BREAK_EFFECT: return break_effect
		Stats.Type.ENERGY_REGEN: return energy_regen
		Stats.Type.EFFECT_HIT: return effect_hit
		Stats.Type.EFFECT_RES: return effect_res
		Stats.Type.OUTGOING_HEALING: return outgoing_healing
	return 0.0


static func value_at_level(lv1: StatBlock, lv80: StatBlock, type: Stats.Type, level: int) -> float:
	if lv1 == null:
		return 0.0
	if lv80 == null or not (type in SCALING_TYPES):
		return lv1.get_value(type)
	var t := clampf(float(level - 1) / float(GameConfig.DESIGN_MAX_LEVEL - 1), 0.0, 1.0)
	return lerpf(lv1.get_value(type), lv80.get_value(type), t)
