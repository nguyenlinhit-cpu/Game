class_name BattleUnit
extends RefCounted
## Một đơn vị trong trận (nhân vật phe ta hoặc quái). Chỉ chứa logic, không vẽ;
## UnitView/CharacterCard đọc dữ liệu và nghe tín hiệu để hiển thị.

signal hp_changed(unit: BattleUnit)
signal energy_changed(unit: BattleUnit)
signal died(unit: BattleUnit)
signal toughness_changed(unit: BattleUnit)
signal status_changed(unit: BattleUnit)

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
## Nguyên tố tấn công.
var element: Element.Type = Element.Type.SOUL
## Chỉ quái có điểm yếu và Khiên Điểm Yếu.
var weaknesses: Array[Element.Type] = []
var max_toughness: float = 0.0
var toughness: float = 0.0
var is_broken: bool = false
var status_effects: Array[StatusEffectInstance] = []
## Khiên chặn sát thương (giữ khiên lớn nhất, hết khi hiệu ứng khiên hết).
var shield_hp: float = 0.0
## Tinh Mệnh tăng hệ số theo loại kỹ năng: { SkillData.Kind: phần cộng thêm }.
var skill_multiplier_bonus: Dictionary = {}
## Đặc tính thay kỹ năng tạm thời (tư thế Celestine, Chiến kỹ cường hóa của Ignar): { Kind: SkillData }.
var skill_overrides: Dictionary = {}
## Vật triệu hồi: không chiếm chỗ nhân vật, quái không nhắm, tự hành động bằng summon_skill.
var is_summon: bool = false
var summon_owner: BattleUnit
var summon_skill: SkillData
var summon_turns_left: int = 0
## Chỗ để Đặc tính/Tinh Mệnh ghi tham số riêng (vd. "hp_cost_reduction", "revive_uses_bonus").
var custom: Dictionary = {}
## Cấp kỹ năng (Phase 9): { SkillData.Kind: cấp, -1: cấp Đặc tính }. Thiếu = cấp 1.
var skill_levels: Dictionary = {}

# --- Quái (Phase 8) ---
## Bộ hành động AI hiện tại (đổi theo giai đoạn boss).
var actions: Array[EnemyAction] = []
## Giai đoạn boss hiện tại (0 = giai đoạn 1).
var phase_index: int = 0
## Máu không xuống dưới mức này (ngưỡng giai đoạn kế tiếp); 0 = không chặn.
var hp_floor: float = 0.0
## EnemyBehavior yêu cầu sang giai đoạn này (−1 = không).
var forced_phase: int = -1
## Không chọn làm mục tiêu được, đòn toàn bộ cũng bỏ qua (vd. boss khi phân thân còn sống).
var untargetable: bool = false
## Đòn đang tích tụ / đếm ngược (null = không).
var charge: Charge
## Số lượt của bản thân: cả trận và trong giai đoạn hiện tại.
var turns_taken: int = 0
var turns_in_phase: int = 0
## Lần dùng và lượt sớm nhất được dùng lại của từng EnemyAction.
var action_uses: Dictionary = {}
var action_ready_turn: Dictionary = {}
## Bị Phá Vỡ kể từ cuối lượt trước của bản thân (AI dùng).
var broken_since_turn: bool = false
## Quái được gọi ra giữa trận (triệu hồi).
var summoned: bool = false
var size_scale: float = 1.0


## Đòn tích tụ của quái: báo trước, ra đòn sau `turns_left` lượt của bản thân.
class Charge:
	extends RefCounted
	var action: EnemyAction
	var target: BattleUnit
	var turns_left: int = 1
	var damage_taken: float = 0.0
	var broken: bool = false

	func _init(p_action: EnemyAction, p_target: BattleUnit) -> void:
		action = p_action
		target = p_target
		turns_left = p_action.charge_turns


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
	unit.element = data.element
	# Vào trận với nửa thanh năng lượng (giống phổ biến của thể loại).
	unit.energy = data.max_energy * 0.5
	var skin := data.get_skin(skin_id)
	if skin:
		unit.color = skin.placeholder_color
		unit.accent_color = skin.accent_color
	return unit


## Vật triệu hồi phe ta (vd. Cây Sự Sống của Sylvaine).
static func create_summon(owner_unit: BattleUnit, summon_name: String, unit_letter: String, unit_color: Color,
		speed: float, hp_ratio: float, skill: SkillData, turns: int) -> BattleUnit:
	var unit := BattleUnit.new()
	unit.side = Faction.ALLY
	unit.is_summon = true
	unit.summon_owner = owner_unit
	unit.summon_skill = skill
	unit.summon_turns_left = turns
	unit.level = owner_unit.level
	unit.slot = 10
	unit.id = StringName("summon_%s" % owner_unit.id)
	unit.display_name = summon_name
	unit.letter = unit_letter
	unit.color = unit_color
	unit.accent_color = unit_color.lightened(0.5)
	unit.element = owner_unit.element
	unit.stats = Stats.new()
	unit.stats.level = owner_unit.level
	unit.stats.set_base(Stats.Type.HP, owner_unit.get_max_hp() * hp_ratio)
	unit.stats.set_base(Stats.Type.ATK, owner_unit.stats.get_value(Stats.Type.ATK))
	unit.stats.set_base(Stats.Type.DEF, owner_unit.stats.get_value(Stats.Type.DEF))
	unit.stats.set_base(Stats.Type.SPD, speed)
	unit.stats.set_base(Stats.Type.ENERGY_REGEN, 1.0)
	unit.hp = unit.get_max_hp()
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
	unit.element = data.element
	unit.accent_color = Element.color(data.element)
	unit.weaknesses = data.weaknesses.duplicate()
	unit.max_toughness = data.max_toughness
	unit.toughness = data.max_toughness
	unit.actions = data.get_actions()
	unit.size_scale = data.size_scale
	unit.update_hp_floor()
	return unit


func is_ally() -> bool:
	return side == Faction.ALLY


func is_alive() -> bool:
	return hp > 0.0


## Còn sống và chọn làm mục tiêu được.
func is_targetable() -> bool:
	return hp > 0.0 and not untargetable


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
	if skill_overrides.has(kind):
		return skill_overrides[kind]
	if character == null:
		return null
	match kind:
		SkillData.Kind.BASIC: return character.basic_attack
		SkillData.Kind.SKILL: return character.skill
		_: return character.ultimate


func is_ultimate_ready() -> bool:
	return is_ally() and not is_summon and is_alive() and max_energy > 0.0 and energy >= max_energy


func count_debuffs() -> int:
	var count := 0
	for instance in status_effects:
		if instance.data.kind == StatusEffectData.Kind.DEBUFF:
			count += 1
	return count


## Trúng đòn: khiên chặn trước, phần còn lại trừ máu. Trả về { "hp_lost", "absorbed" }.
func take_hit(amount: float) -> Dictionary:
	var absorbed := minf(shield_hp, maxf(amount, 0.0))
	if absorbed > 0.0:
		shield_hp -= absorbed
		if shield_hp <= 0.0:
			shield_hp = 0.0
			for instance in status_effects.duplicate():
				if instance.data.shield:
					StatusEffects.remove(self, instance)
		hp_changed.emit(self)
	return {"hp_lost": take_damage(amount - absorbed), "absorbed": absorbed}


func add_shield(amount: float) -> void:
	shield_hp = maxf(shield_hp, amount)
	hp_changed.emit(self)


func get_skill_multiplier_bonus(kind: int) -> float:
	return float(skill_multiplier_bonus.get(kind, 0.0))


## Cấp kỹ năng theo loại (-1 = Đặc tính; đòn phụ dùng cấp Đặc tính).
func get_skill_level(kind: int) -> int:
	if kind == SkillData.Kind.FOLLOW_UP:
		kind = -1
	return int(skill_levels.get(kind, 1))


## Hệ số sát thương/hồi/khiên theo cấp kỹ năng.
func get_level_multiplier(kind: int) -> float:
	return ProgressionConfig.get_config().multiplier_scale(get_skill_level(kind))


## Độ mạnh buff/debuff do kỹ năng loại này gắn.
func get_status_potency(kind: int) -> float:
	return ProgressionConfig.get_config().status_scale(get_skill_level(kind))


func is_taunting() -> bool:
	for instance in status_effects:
		if instance.data.taunt:
			return true
	return false


func get_aggro_weight() -> float:
	var path := character.path if character else CharacterPath.Type.HARMONY
	return CharacterPath.aggro_weight(path) * maxf(1.0 + stats.get_value(Stats.Type.AGGRO), 0.0)


## Hồi sinh với `ratio` phần máu tối đa (gỡ hết hiệu ứng).
func revive(ratio: float) -> void:
	StatusEffects.remove_all(self)
	hp = maxf(get_max_hp() * ratio, 1.0)
	hp_changed.emit(self)


## Trừ máu thẳng (bỏ qua khiên), trả về lượng máu thực mất.
## Boss không xuống dưới ngưỡng giai đoạn kế tiếp (hp_floor) cho tới khi chuyển giai đoạn.
func take_damage(amount: float) -> float:
	if not is_alive() or amount <= 0.0:
		return 0.0
	var dealt := minf(amount, hp)
	if hp_floor > 0.0:
		dealt = minf(dealt, maxf(hp - hp_floor, 0.0))
	if charge:
		charge.damage_taken += dealt
	if dealt <= 0.0:
		return 0.0
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


# --- Nguyên tố và khiên ---

func is_weak_to(attack_element: int) -> bool:
	return weaknesses.has(attack_element)


## Kháng nguyên tố: quái mặc định 20% (EnemyData.default_res), đúng điểm yếu 0%; cộng thêm bộ điều chỉnh RES.
func get_res(attack_element: int) -> float:
	var base := 0.0
	if enemy and not is_weak_to(attack_element):
		base = enemy.default_res
	return base + stats.get_value(Stats.Type.RES)


func has_toughness() -> bool:
	return max_toughness > 0.0


## Trừ khiên, trả về lượng đã trừ.
func reduce_toughness(amount: float) -> float:
	var reduced := minf(amount, toughness)
	toughness -= reduced
	toughness_changed.emit(self)
	return reduced


func recover_toughness() -> void:
	toughness = max_toughness
	is_broken = false
	toughness_changed.emit(self)


# --- Hiệu ứng ---

func get_status(status_id: StringName) -> StatusEffectInstance:
	for instance in status_effects:
		if instance.data.id == status_id:
			return instance
	return null


func has_status(status_id: StringName) -> bool:
	return get_status(status_id) != null


func is_skill_sealed() -> bool:
	for instance in status_effects:
		if instance.data.seal_skill:
			return true
	return false


# --- Quái: giai đoạn, hành động ---

## Giai đoạn kế tiếp (null nếu đang ở giai đoạn cuối).
func get_next_phase() -> BossPhaseData:
	if enemy == null or phase_index >= enemy.phases.size():
		return null
	return enemy.phases[phase_index]


## Đặt sàn máu theo ngưỡng giai đoạn kế tiếp (giai đoạn do script gọi: không cho ngã trước khi tới).
func update_hp_floor() -> void:
	var next := get_next_phase()
	if next == null:
		hp_floor = 0.0
	elif next.hp_threshold >= 0.0:
		hp_floor = get_max_hp() * next.hp_threshold
	else:
		hp_floor = 1.0


## Đã chạm ngưỡng giai đoạn kế tiếp hoặc được script yêu cầu.
func has_pending_phase() -> bool:
	var next := get_next_phase()
	if next == null or not is_alive():
		return false
	if forced_phase > phase_index:
		return true
	return next.hp_threshold >= 0.0 and hp <= get_max_hp() * next.hp_threshold + 0.5


func note_action_used(action: EnemyAction) -> void:
	action_uses[action] = int(action_uses.get(action, 0)) + 1
	action_ready_turn[action] = turns_taken + action.cooldown_turns + 1


func is_action_ready(action: EnemyAction) -> bool:
	if action.max_uses > 0 and int(action_uses.get(action, 0)) >= action.max_uses:
		return false
	return turns_taken >= int(action_ready_turn.get(action, 0))


func count_buffs() -> int:
	var count := 0
	for instance in status_effects:
		if instance.data.kind == StatusEffectData.Kind.BUFF:
			count += 1
	return count


func set_energy(value: float) -> void:
	energy = clampf(value, 0.0, max_energy)
	energy_changed.emit(self)
