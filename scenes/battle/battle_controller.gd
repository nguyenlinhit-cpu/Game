class_name BattleController
extends Node
## Lõi trận theo lượt, chạy như state machine:
## Bắt đầu → Tính lượt → Lượt ta (chờ người chơi/Tự Động) hoặc Lượt quái (AI) → Xử lý kỹ năng
## → Kiểm tra thắng thua (sang đợt sau nếu còn) → lặp lại → Kết thúc.
## Tuyệt kỹ chen lượt: request_ultimate() xếp vào hàng chen lượt, chạy ngay sau hành động
## đang diễn ra (hoặc ngay lập tức nếu đang chờ người chơi chọn), không tốn lượt của ai.
## Đòn đánh phụ / phản công của Đặc tính (request_follow_up) đi chung hàng này.
## Đặc tính/Tinh Mệnh (TalentScript) gắn khi setup, gỡ khi trận rời cây.
## Không phụ thuộc giao diện: BattleScene nghe tín hiệu và gọi submit_action()/request_ultimate().

signal turn_started(unit: BattleUnit)
signal input_requested(unit: BattleUnit)
signal action_started(unit: BattleUnit, skill: SkillData, targets: Array[BattleUnit])
signal action_resolved(unit: BattleUnit, skill: SkillData, events: Array[Dictionary])
## Sự kiện đầu/cuối lượt: hồi khiên, sát thương theo lượt, mất lượt, hiệu ứng hết hạn.
signal status_events(unit: BattleUnit, events: Array[Dictionary])
signal skill_points_changed(value: int)
signal queue_changed
signal wave_started(index: int, wave_enemies: Array[BattleUnit])
signal unit_died(unit: BattleUnit)
signal battle_ended(won: bool)
## Móc cho TalentScript.
signal battle_began
signal before_damage(ctx: SkillContext, target: BattleUnit, params: DamageCalc.Params)
signal after_damage(ctx: SkillContext, target: BattleUnit, amount: float, crit: bool)
signal before_heal(ctx: SkillContext, target: BattleUnit, box: Dictionary)
signal skill_resolved(ctx: SkillContext)
## box = { "amount": float, "target": BattleUnit } – sửa được để chia/đỡ sát thương.
signal before_hit(ctx: SkillContext, target: BattleUnit, box: Dictionary)
signal status_applied(source: BattleUnit, target: BattleUnit, instance: StatusEffectInstance)
signal dot_damage(target: BattleUnit, amount: float, source: BattleUnit)
## Mất máu do tự tiêu (HpCostEffect).
signal hp_consumed(unit: BattleUnit, amount: float)
signal summon_added(unit: BattleUnit)
signal summon_removed(unit: BattleUnit)

enum Phase { SETUP, RUNNING, AWAITING_INPUT, ENDED }

const MAX_SKILL_POINTS: int = 5
const START_SKILL_POINTS: int = 3
const START_PAUSE_SEC: float = 0.5
const TURN_START_PAUSE_SEC: float = 0.2
const WINDUP_PAUSE_SEC: float = 0.25
const ACTION_PAUSE_SEC: float = 0.55
const ULTIMATE_PAUSE_SEC: float = 1.0
const WAVE_PAUSE_SEC: float = 0.8
const STATUS_PAUSE_SEC: float = 0.45

var allies: Array[BattleUnit] = []
## Quái của đợt hiện tại.
var enemies: Array[BattleUnit] = []
var queue := TurnQueue.new()
var skill_points: int = START_SKILL_POINTS
var wave_index: int = 0
var encounter: EncounterData
var opening: BattleTypes.Opening = BattleTypes.Opening.NORMAL
var auto_mode: bool = false
## Bỏ qua mọi thời gian chờ (dùng trong test).
var instant: bool = false
var crit_mode: DamageCalc.CritMode = DamageCalc.CritMode.ROLL
var rng := RandomNumberGenerator.new()
var phase: Phase = Phase.SETUP
var current_unit: BattleUnit
var turn_count: int = 0
var won: bool = false
## Nguyên tố Đòn Mở Màn khi vào trận bằng Ưu Thế (Element.NONE nếu không có).
var opener_element: int = Element.NONE
## Phòng thử: ép nguyên tố mọi đòn của phe ta (Element.NONE = theo nhân vật).
var debug_element_override: int = Element.NONE

## Bí Kỹ áp đầu trận: [character_id] (trận kế tiếp + nhóm quái bị đánh dấu).
var technique_users: Array[StringName] = []
var talents: Array[TalentScript] = []
## Vật triệu hồi phe ta đang có mặt (không nằm trong `allies`).
var summons: Array[BattleUnit] = []
## Đếm số lần dùng giới hạn mỗi trận (hồi sinh...): { khóa: số lần }.
var use_counts: Dictionary = {}
## Tự Động riêng cho từng đơn vị (công cụ cân bằng): { BattleUnit: Callable(unit) -> { "skill", "target" } }.
var auto_overrides: Dictionary = {}
## Đơn vị không tự dùng Tuyệt kỹ khi Tự Động.
var auto_ultimate_blocklist: Array[BattleUnit] = []
## Hàng chen lượt: [{ "unit", "target", "skill"?: SkillData, "follow_up"?: bool }].
var _interrupts: Array[Dictionary] = []
var _choice: Dictionary = {}
var _skip_wait: bool = false

signal _choice_made


## Chuẩn bị trận. Từ chối đội rỗng hoặc hơn 4 người, và trận có dữ liệu lỗi.
func setup(team: Array[CharacterData], team_level: int, battle_encounter: EncounterData,
		battle_opening: BattleTypes.Opening, skins: Dictionary = {}, names: Dictionary = {},
		battle_opener_element: int = Element.NONE, eidolon_levels: Dictionary = {},
		techniques: Array[StringName] = []) -> Error:
	if team.is_empty():
		push_warning("BattleController: đội trống")
		return ERR_INVALID_PARAMETER
	if team.size() > GameConfig.MAX_TEAM_SIZE:
		push_warning("BattleController: đội %d người, tối đa %d" % [team.size(), GameConfig.MAX_TEAM_SIZE])
		return ERR_PARAMETER_RANGE_ERROR
	if battle_encounter == null or not battle_encounter.validate().is_empty():
		push_warning("BattleController: dữ liệu trận lỗi %s" % (battle_encounter.validate() if battle_encounter else []))
		return ERR_INVALID_DATA
	encounter = battle_encounter
	opening = battle_opening
	opener_element = battle_opener_element
	technique_users = techniques.duplicate()
	var level := clampi(team_level, 1, GameConfig.MAX_LEVEL)
	for i in team.size():
		var data := team[i]
		var unit := BattleUnit.create_ally(data, level, i, skins.get(data.id, &""), names.get(data.id, ""))
		allies.append(unit)
		queue.add(unit)
	_spawn_wave(0)
	for unit in allies:
		_attach_character_scripts(unit, int(eidolon_levels.get(unit.character.id, 0)))
	match opening:
		BattleTypes.Opening.ADVANTAGE:
			# Cả đội hành động trước ở vòng đầu (nhanh hơn đi trước).
			for unit in allies:
				unit.distance_left = 0.0
			# Đòn Mở Màn đúng điểm yếu: quái mất 25% khiên (không đủ để Phá Vỡ).
			if opener_element != Element.NONE:
				for unit in enemies:
					if unit.is_weak_to(opener_element) and unit.has_toughness():
						unit.reduce_toughness(unit.max_toughness * BreakSystem.config().advantage_toughness_loss)
		BattleTypes.Opening.AMBUSHED:
			for unit in enemies:
				unit.distance_left = 0.0
	phase = Phase.SETUP
	return OK


func start() -> void:
	phase = Phase.RUNNING
	skill_points_changed.emit(skill_points)
	queue_changed.emit()
	await _wait(START_PAUSE_SEC)
	# Bí Kỹ áp trước để Đặc tính (vd. tư thế Celestine) thấy được trạng thái đầu trận.
	var technique_events := _apply_technique_effects()
	battle_began.emit()
	if not technique_events.is_empty():
		report_events(allies[0], technique_events)
		await _wait(STATUS_PAUSE_SEC)
	while phase != Phase.ENDED:
		await _process_interrupts()
		var wave_before := wave_index
		if _check_end():
			break
		if wave_index != wave_before:
			await _wait(WAVE_PAUSE_SEC)
		var unit := queue.advance_to_next()
		current_unit = unit
		turn_count += 1
		turn_started.emit(unit)
		EventBus.turn_started.emit(unit)
		queue_changed.emit()
		await _wait(TURN_START_PAUSE_SEC)
		var start_result := process_turn_start(unit)
		var start_events: Array[Dictionary] = start_result["events"]
		if not start_events.is_empty():
			_handle_deaths(start_events)
			status_events.emit(unit, start_events)
			queue_changed.emit()
			await _wait(STATUS_PAUSE_SEC)
		if not unit.is_alive():
			current_unit = null
			continue
		if not bool(start_result["skip"]):
			var action: Dictionary
			if unit.is_summon:
				action = _summon_action(unit)
			elif unit.is_ally():
				action = await _get_ally_action(unit)
			else:
				action = EnemyAI.choose_action(unit, allies, enemies, rng)
			if phase == Phase.ENDED:
				break
			if not action.is_empty() and unit.is_alive():
				await _perform(unit, action["skill"], action["target"])
		if unit.is_alive():
			var end_events := process_turn_end(unit)
			if not end_events.is_empty():
				status_events.emit(unit, end_events)
		if queue.has(unit):
			queue.end_turn(unit)
		if unit.is_summon:
			unit.summon_turns_left -= 1
			if unit.summon_turns_left <= 0:
				remove_summon(unit)
		EventBus.turn_ended.emit(unit)
		current_unit = null
		queue_changed.emit()
		if auto_mode:
			_queue_auto_ultimates()


# --- Giao diện gọi vào ---

func is_awaiting_input() -> bool:
	return phase == Phase.AWAITING_INPUT


func can_use(unit: BattleUnit, skill: SkillData) -> bool:
	if skill == null or not unit.is_alive():
		return false
	if skill.kind == SkillData.Kind.ULTIMATE:
		return unit.is_ultimate_ready()
	return skill.sp_change >= 0 or skill_points + skill.sp_change >= 0


## Người chơi chọn hành động cho nhân vật đang tới lượt. Trả về false nếu không hợp lệ.
func submit_action(kind: SkillData.Kind, target: BattleUnit) -> bool:
	if phase != Phase.AWAITING_INPUT or current_unit == null or kind == SkillData.Kind.ULTIMATE:
		return false
	var skill := current_unit.get_skill(kind)
	if not can_use(current_unit, skill):
		return false
	if not SkillExecutor.get_target_pool(skill, current_unit, allies, enemies).has(target):
		return false
	_choice = {"type": "action", "skill": skill, "target": target}
	_choice_made.emit()
	return true


## Xếp tuyệt kỹ chen lượt. `skill`: chế độ khác của Tuyệt kỹ (SkillData.alternate), null = mặc định.
## Trả về false nếu chưa đầy năng lượng hoặc đã xếp rồi.
func request_ultimate(unit: BattleUnit, target: BattleUnit = null, skill: SkillData = null) -> bool:
	if phase == Phase.ENDED or phase == Phase.SETUP or not unit.is_ultimate_ready() or is_ultimate_queued(unit):
		return false
	_interrupts.append({"unit": unit, "target": target, "skill": skill})
	if phase == Phase.AWAITING_INPUT:
		_choice = {"type": "interrupt"}
		_choice_made.emit()
	return true


func is_ultimate_queued(unit: BattleUnit) -> bool:
	for entry in _interrupts:
		if entry["unit"] == unit and not entry.get("follow_up", false):
			return true
	return false


## Đòn đánh phụ / phản công: hành động riêng, không tốn lượt, chạy sau hành động hiện tại.
func request_follow_up(unit: BattleUnit, skill: SkillData, target: BattleUnit = null) -> void:
	if phase == Phase.ENDED or not unit.is_alive():
		return
	_interrupts.append({"unit": unit, "target": target, "skill": skill, "follow_up": true})
	if phase == Phase.AWAITING_INPUT:
		_choice = {"type": "interrupt"}
		_choice_made.emit()


## Thêm vật triệu hồi (đã có của cùng chủ thì làm mới số lượt). Trả về vật triệu hồi.
func add_summon(owner_unit: BattleUnit, summon_name: String, unit_letter: String, unit_color: Color,
		speed: float, hp_ratio: float, skill: SkillData, turns: int) -> BattleUnit:
	for existing in summons:
		if existing.summon_owner == owner_unit:
			existing.summon_turns_left = maxi(existing.summon_turns_left, turns)
			return existing
	var unit := BattleUnit.create_summon(owner_unit, summon_name, unit_letter, unit_color, speed, hp_ratio, skill, turns)
	summons.append(unit)
	queue.add(unit)
	summon_added.emit(unit)
	queue_changed.emit()
	return unit


func get_summon_of(owner_unit: BattleUnit) -> BattleUnit:
	for unit in summons:
		if unit.summon_owner == owner_unit:
			return unit
	return null


func remove_summon(unit: BattleUnit) -> void:
	summons.erase(unit)
	queue.remove(unit)
	summon_removed.emit(unit)
	queue_changed.emit()


## Đếm lần dùng giới hạn mỗi trận. Trả về true (và tăng đếm) nếu còn lượt dùng.
func try_use(key: String, limit: int) -> bool:
	var used := int(use_counts.get(key, 0))
	if used >= limit:
		return false
	use_counts[key] = used + 1
	return true


func _summon_action(unit: BattleUnit) -> Dictionary:
	if unit.summon_skill == null:
		return {}
	var pool := SkillExecutor.get_target_pool(unit.summon_skill, unit, allies, enemies)
	if pool.is_empty():
		return {}
	var target := pool[0]
	for candidate in pool:
		if candidate.get_hp_ratio() < target.get_hp_ratio():
			target = candidate
	return {"skill": unit.summon_skill, "target": target}


## Hồi sinh đồng minh đã ngã: trở lại hàng lượt với quãng đường đầy.
func revive(unit: BattleUnit, ratio: float) -> Array[Dictionary]:
	if unit.is_alive():
		return []
	unit.revive(ratio)
	queue.add(unit)
	queue_changed.emit()
	return [{"type": "revive", "target": unit, "amount": unit.hp, "crit": false}]


## Sự kiện ngoài kỹ năng (Đặc tính, Bí Kỹ đầu trận): xử lý đơn vị ngã rồi báo giao diện.
func report_events(unit: BattleUnit, events: Array[Dictionary]) -> void:
	_handle_deaths(events)
	status_events.emit(unit, events)
	queue_changed.emit()


## Phe mình (còn sống) của đơn vị.
func get_friends(unit: BattleUnit) -> Array[BattleUnit]:
	return (allies if unit.is_ally() else enemies).filter(func(u: BattleUnit) -> bool: return u.is_alive())


func get_foes(unit: BattleUnit) -> Array[BattleUnit]:
	return (enemies if unit.is_ally() else allies).filter(func(u: BattleUnit) -> bool: return u.is_alive())


func set_auto(enabled: bool) -> void:
	auto_mode = enabled
	if enabled and phase == Phase.AWAITING_INPUT:
		_choice = {"type": "auto"}
		_choice_made.emit()


## Nguyên tố đòn đánh của đơn vị (phòng thử có thể ép nguyên tố cho phe ta).
func get_attack_element(unit: BattleUnit) -> int:
	if unit.is_ally() and debug_element_override != Element.NONE:
		return debug_element_override
	return unit.element


## Tung tỉ lệ trúng rồi gắn hiệu ứng, kèm trì hoãn thêm nếu có. Trả về sự kiện.
func apply_status(data: StatusEffectData, source: BattleUnit, target: BattleUnit,
		base_value: float = 0.0) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var instance := StatusEffects.try_apply(data, source, target, rng, base_value)
	if instance == null:
		events.append({"type": "status_resisted", "target": target, "amount": 0.0, "crit": false, "status": data.id, "name_key": data.name_key})
		return events
	status_applied.emit(source, target, instance)
	events.append({"type": "status_applied", "target": target, "amount": float(instance.stacks), "crit": false,
			"status": data.id, "name_key": data.name_key})
	if data.extra_delay > 0.0 and queue.has(target):
		queue.delay(target, data.extra_delay)
		events.append({"type": "delay", "target": target, "amount": data.extra_delay, "crit": false})
	return events


## Đầu lượt: quái đang bị Phá Vỡ hồi đầy khiên; xử lý sát thương theo lượt và mất lượt.
## Trả về { "skip": bool, "events": Array[Dictionary] }.
func process_turn_start(unit: BattleUnit) -> Dictionary:
	var events: Array[Dictionary] = []
	if unit.is_broken:
		unit.recover_toughness()
		events.append({"type": "recover", "target": unit, "amount": unit.max_toughness, "crit": false})
	var result := StatusEffects.tick_turn_start(unit)
	events.append_array(result["events"])
	return {"skip": result["skip"], "events": events}


func process_turn_end(unit: BattleUnit) -> Array[Dictionary]:
	return StatusEffects.tick_turn_end(unit)


## Kết thúc trận ngay (phím debug và test của các phase map).
func force_end(battle_won: bool) -> void:
	if phase != Phase.ENDED:
		_end(battle_won)


## Bỏ qua thời gian chờ hiện tại (vd. bấm để bỏ qua cắt cảnh tuyệt kỹ).
func skip_wait() -> void:
	_skip_wait = true


func change_skill_points(delta: int) -> void:
	if delta == 0:
		return
	skill_points = clampi(skill_points + delta, 0, MAX_SKILL_POINTS)
	skill_points_changed.emit(skill_points)


## Xem trước thứ tự lượt nếu nhân vật đang tới lượt dùng `skill` lên `target`.
func preview_order(skill: SkillData, target: BattleUnit, count: int) -> Array[Dictionary]:
	var overrides: Dictionary = {}
	if skill and target and current_unit:
		var ctx := SkillContext.new(self, current_unit, skill, target)
		for effect in skill.effects:
			if effect:
				effect.collect_turn_overrides(ctx, overrides)
	return queue.predict(count, current_unit, overrides)


func get_wave_count() -> int:
	return encounter.waves.size() if encounter else 0


# --- Nội bộ ---

func _get_ally_action(unit: BattleUnit) -> Dictionary:
	while phase != Phase.ENDED:
		if auto_mode:
			_queue_auto_ultimates()
			if not _interrupts.is_empty():
				await _process_interrupts()
				if _check_end() or not unit.is_alive():
					return {}
			if auto_overrides.has(unit):
				return (auto_overrides[unit] as Callable).call(unit)
			return AutoBattle.choose_action(unit, self)
		phase = Phase.AWAITING_INPUT
		input_requested.emit(unit)
		await _choice_made
		if phase == Phase.ENDED:
			return {}
		phase = Phase.RUNNING
		match str(_choice.get("type", "")):
			"interrupt":
				await _process_interrupts()
				if _check_end() or not unit.is_alive():
					return {}
			"action":
				return _choice
	return {}


func _process_interrupts() -> void:
	while not _interrupts.is_empty() and phase != Phase.ENDED:
		var entry: Dictionary = _interrupts.pop_front()
		var unit: BattleUnit = entry["unit"]
		var follow_up: bool = entry.get("follow_up", false)
		if not unit.is_alive() or (not follow_up and not unit.is_ultimate_ready()):
			continue
		var skill: SkillData = entry.get("skill")
		if skill == null:
			skill = unit.get_skill(SkillData.Kind.ULTIMATE)
		var target: BattleUnit = entry.get("target")
		var pool := SkillExecutor.get_target_pool(skill, unit, allies, enemies)
		if pool.is_empty():
			continue
		if target == null or not pool.has(target):
			target = AutoBattle.choose_ultimate_target(unit, self) if not follow_up \
					else EnemyAI.choose_target(skill, pool, rng) if not unit.is_ally() else pool[0]
			if not pool.has(target):
				target = pool[0]
		await _perform(unit, skill, target, follow_up)
		if _check_end():
			return


func _perform(unit: BattleUnit, skill: SkillData, target: BattleUnit, follow_up: bool = false) -> void:
	var targets: Array[BattleUnit] = []
	for entry in SkillExecutor.resolve_targets(skill, unit, target, allies, enemies):
		targets.append(entry["unit"])
	if targets.is_empty():
		return
	action_started.emit(unit, skill, targets)
	var is_ultimate := skill.kind == SkillData.Kind.ULTIMATE
	await _wait(ULTIMATE_PAUSE_SEC if is_ultimate else WINDUP_PAUSE_SEC)
	if phase == Phase.ENDED:
		return
	var events := SkillExecutor.execute(self, unit, skill, target, follow_up)
	_handle_deaths(events)
	action_resolved.emit(unit, skill, events)
	queue_changed.emit()
	await _wait(ACTION_PAUSE_SEC)


## Đơn vị trong sự kiện đã hết máu: rời hàng lượt, thêm sự kiện "death".
func _handle_deaths(events: Array[Dictionary]) -> void:
	for event in events.duplicate():
		if event["type"] == "dot":
			dot_damage.emit(event["target"], float(event["amount"]), event.get("source"))
	var dead_units: Array[BattleUnit] = []
	for event in events:
		var target: BattleUnit = event["target"]
		if not target.is_alive() and queue.has(target) and not dead_units.has(target):
			dead_units.append(target)
	for dead in dead_units:
		queue.remove(dead)
		events.append({"type": "death", "target": dead, "amount": 0.0, "crit": false})
		# Báo trước khi gỡ hiệu ứng để Đặc tính còn đọc được hiệu ứng trên đơn vị vừa ngã (vd. lan độc).
		unit_died.emit(dead)
		EventBus.unit_died.emit(dead)
		if not dead.is_alive():
			StatusEffects.remove_all(dead)


func _queue_auto_ultimates() -> void:
	for unit in allies:
		if auto_ultimate_blocklist.has(unit):
			continue
		if AutoBattle.should_use_ultimate(unit, self) and not is_ultimate_queued(unit):
			_interrupts.append({"unit": unit, "target": null, "skill": AutoBattle.choose_ultimate_skill(unit, self)})


func _attach_character_scripts(unit: BattleUnit, eidolon_level: int) -> void:
	var data := unit.character
	if data.talent and data.talent.script_class:
		var talent := data.talent.script_class.new() as TalentScript
		talent.attach(self, unit, eidolon_level)
		talents.append(talent)
	for i in mini(eidolon_level, data.eidolons.size()):
		var eidolon := data.eidolons[i]
		if eidolon == null:
			continue
		for kind in eidolon.bonus_kinds:
			unit.skill_multiplier_bonus[kind] = unit.get_skill_multiplier_bonus(kind) + eidolon.multiplier_bonus
		for modifier in eidolon.stat_modifiers:
			unit.stats.add_modifier(modifier.stat, modifier.flat, modifier.percent, StringName("eidolon_%d" % (i + 1)))
		if eidolon.script_class:
			var extra := eidolon.script_class.new() as TalentScript
			extra.attach(self, unit, eidolon_level)
			talents.append(extra)


## Hiệu ứng đầu trận của Bí Kỹ (người dùng phải có trong đội).
func _apply_technique_effects() -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for character_id in technique_users:
		for unit in allies:
			if unit.character.id != character_id or unit.character.technique == null:
				continue
			var ctx := SkillContext.new(self, unit, null, null)
			for effect in unit.character.technique.battle_start_effects:
				if effect:
					effect.apply(ctx)
			events.append_array(ctx.events)
	return events


func _exit_tree() -> void:
	for talent in talents:
		talent.detach()
	talents.clear()


## Kiểm tra thắng/thua; hết quái đợt này mà còn đợt sau thì gọi đợt mới. Trả về true nếu trận đã kết thúc.
func _check_end() -> bool:
	if phase == Phase.ENDED:
		return true
	if not allies.any(func(unit: BattleUnit) -> bool: return unit.is_alive()):
		_end(false)
		return true
	if not enemies.any(func(unit: BattleUnit) -> bool: return unit.is_alive()):
		if wave_index + 1 < get_wave_count():
			_spawn_wave(wave_index + 1)
			return false
		_end(true)
		return true
	return false


func _end(battle_won: bool) -> void:
	won = battle_won
	phase = Phase.ENDED
	_interrupts.clear()
	battle_ended.emit(battle_won)
	if battle_won:
		EventBus.battle_won.emit(encounter)
	else:
		EventBus.battle_lost.emit(encounter)
	# Gỡ vòng chờ người chơi nếu đang chờ.
	_choice_made.emit()


func _spawn_wave(index: int) -> void:
	wave_index = index
	enemies.clear()
	var wave: EncounterWave = encounter.waves[index]
	var counts: Dictionary = {}
	for entry in wave.entries:
		counts[entry.enemy] = int(counts.get(entry.enemy, 0)) + entry.count
	var seen: Dictionary = {}
	var slot := 0
	for entry in wave.entries:
		for i in entry.count:
			# Trùng loại thì thêm chữ A, B, C... để phân biệt.
			var suffix := ""
			if int(counts[entry.enemy]) > 1:
				seen[entry.enemy] = int(seen.get(entry.enemy, 0)) + 1
				suffix = " " + char(64 + int(seen[entry.enemy]))
			var unit := BattleUnit.create_enemy(entry.enemy, entry.level, slot, index, suffix)
			enemies.append(unit)
			queue.add(unit)
			slot += 1
	wave_started.emit(index, enemies)
	queue_changed.emit()


func _wait(seconds: float) -> void:
	if instant:
		await get_tree().process_frame
		return
	_skip_wait = false
	var left := seconds
	while left > 0.0 and not _skip_wait:
		await get_tree().process_frame
		left -= get_process_delta_time()
