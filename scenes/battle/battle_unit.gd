class_name BattleUnit
extends RefCounted
## Một đơn vị trong trận (nhân vật phe ta hoặc quái). Chỉ chứa logic, không vẽ;
## UnitView/CharacterCard đọc dữ liệu và nghe tín hiệu để hiển thị.

signal hp_changed(unit: BattleUnit)
signal energy_changed(unit: BattleUnit)
signal died(unit: BattleUnit)

enum Faction { ALLY, ENEMY }

## Năng lượng nhận khi bị đánh trúng (mỗi lần trúng đòn).
const ENERGY_ON_HIT: float = 10.0

var id: StringName
var display_name: String = ""
## Chữ cái hiện trên hình tạm.
var letter: String = ""
var side: Faction = Faction.ALLY
## Vị trí trong hàng (0 = đầu), dùng cho đòn lan và vẽ.
var slot: int = 0
var wave: int = 0
var level: int = 1
var stats: Stats
var hp: float = 1.0
var energy: float = 0.0
var max_energy: float = 0.0
var color: Color = Color.GRAY
var accent_color: Color = Color.WHITE
var character: CharacterData
var enemy: EnemyData
## Quãng đường còn lại tới lượt (TurnQueue dùng). Giá trị Hành Động = quãng đường / Tốc Độ.
var distance_left: float = 10000.0


static func create_ally(data: CharacterData, unit_level: int, unit_slot: int,
		skin_id: StringName = &"", name_override: String = "") -> BattleUnit:
	var unit := BattleUnit.new()
	unit.character = data
	unit.side = Faction.ALLY
	unit.slot = unit_slot
	unit.level = unit_level
	unit.id = StringName("ally_%d_%s" % [unit_slot, data.id])
	unit.display_name = name_override if not name_override.is_empty() else TranslationServer.translate(data.name_key)
	unit.letter = unit.display_name.left(1).to_upper()
	unit.stats = Stats.from_blocks(data.stats_lv1, data.stats_lv80, unit_level)
	unit.hp = unit.get_max_hp()
	unit.max_energy = data.max_energy
	# Vào trận với nửa thanh năng lượng (giống phổ biến của thể loại).
	unit.energy = data.max_energy * 0.5
	var skin := data.get_skin(skin_id)
	if skin:
		unit.color = skin.placeholder_color
		unit.accent_color = skin.accent_color
	return unit


static func create_enemy(data: EnemyData, unit_level: int, unit_slot: int, unit_wave: int,
		suffix: String = "") -> BattleUnit:
	var unit := BattleUnit.new()
	unit.enemy = data
	unit.side = Faction.ENEMY
	unit.slot = unit_slot
	unit.wave = unit_wave
	unit.level = unit_level
	unit.id = StringName("enemy_w%d_%d_%s" % [unit_wave, unit_slot, data.id])
	unit.display_name = TranslationServer.translate(data.name_key) + suffix
	unit.letter = TranslationServer.translate(data.name_key).left(1).to_upper()
	unit.stats = Stats.from_blocks(data.stats_lv1, data.stats_lv80, unit_level)
	unit.hp = unit.get_max_hp()
	unit.color = data.placeholder_color
	unit.accent_color = data.placeholder_color.lightened(0.4)
	return unit


func is_ally() -> bool:
	return side == Faction.ALLY


func is_alive() -> bool:
	return hp > 0.0


func get_max_hp() -> float:
	return maxf(stats.get_value(Stats.Type.HP), 1.0)


func get_hp_ratio() -> float:
	return hp / get_max_hp()


func get_speed() -> float:
	return maxf(stats.get_value(Stats.Type.SPD), 1.0)


## Giá trị Hành Động: thấp nhất đi trước.
func get_action_value() -> float:
	return distance_left / get_speed()


func get_skill(kind: SkillData.Kind) -> SkillData:
	if character == null:
		return null
	match kind:
		SkillData.Kind.BASIC: return character.basic_attack
		SkillData.Kind.SKILL: return character.skill
		_: return character.ultimate


func is_ultimate_ready() -> bool:
	return is_ally() and is_alive() and max_energy > 0.0 and energy >= max_energy


## Trừ máu, trả về lượng máu thực mất.
func take_damage(amount: float) -> float:
	if not is_alive() or amount <= 0.0:
		return 0.0
	var dealt := minf(amount, hp)
	hp -= dealt
	hp_changed.emit(self)
	if hp <= 0.0:
		hp = 0.0
		died.emit(self)
	return dealt


## Hồi máu, trả về lượng máu thực hồi.
func heal(amount: float) -> float:
	if not is_alive() or amount <= 0.0:
		return 0.0
	var healed := minf(amount, get_max_hp() - hp)
	hp += healed
	hp_changed.emit(self)
	return healed


## Cộng năng lượng (nhân Hiệu Suất Hồi Năng Lượng), không vượt tối đa.
func add_energy(amount: float, apply_regen: bool = true) -> void:
	if not is_ally() or max_energy <= 0.0:
		return
	var gain := amount * (stats.get_value(Stats.Type.ENERGY_REGEN) if apply_regen else 1.0)
	set_energy(energy + gain)


func set_energy(value: float) -> void:
	energy = clampf(value, 0.0, max_energy)
	energy_changed.emit(self)
