class_name BattleController
extends Node
## Lõi trận theo lượt, chạy như state machine:
## Bắt đầu → Tính lượt → Lượt ta (chờ người chơi/Tự Động) hoặc Lượt quái (AI) → Xử lý kỹ năng
## → Kiểm tra thắng thua (sang đợt sau nếu còn) → lặp lại → Kết thúc.
## Tuyệt kỹ chen lượt: request_ultimate() xếp vào hàng chen lượt, chạy ngay sau hành động
## đang diễn ra (hoặc ngay lập tức nếu đang chờ người chơi chọn), không tốn lượt của ai.
## Không phụ thuộc giao diện: BattleScene nghe tín hiệu và gọi submit_action()/request_ultimate().

signal turn_started(unit: BattleUnit)
signal input_requested(unit: BattleUnit)
signal action_started(unit: BattleUnit, skill: SkillData, targets: Array[BattleUnit])
signal action_resolved(unit: BattleUnit, skill: SkillData, events: Array[Dictionary])
signal skill_points_changed(value: int)
signal queue_changed
signal wave_started(index: int, wave_enemies: Array[BattleUnit])
signal unit_died(unit: BattleUnit)
signal battle_ended(won: bool)

enum Phase { SETUP, RUNNING, AWAITING_INPUT, ENDED }

const MAX_SKILL_POINTS: int = 5
const START_SKILL_POINTS: int = 3
const START_PAUSE_SEC: float = 0.5
const TURN_START_PAUSE_SEC: float = 0.2
const WINDUP_PAUSE_SEC: float = 0.25
const ACTION_PAUSE_SEC: float = 0.55
const ULTIMATE_PAUSE_SEC: float = 1.0
const WAVE_PAUSE_SEC: float = 0.8

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

## Các tuyệt kỹ chờ chen lượt: [{ "unit": BattleUnit, "target": BattleUnit }].
var _interrupts: Array[Dictionary] = []
var _choice: Dictionary = {}
var _skip_wait: bool = false

signal _choice_made


## Chuẩn bị trận. Từ chối đội rỗng hoặc hơn 4 người, và trận có dữ liệu lỗi.
func setup(team: Array[CharacterData], team_level: int, battle_encounter: EncounterData,
		battle_opening: BattleTypes.Opening, skins: Dictionary = {}, names: Dictionary = {}) -> Error:
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
	var level := clampi(team_level, 1, GameConfig.MAX_LEVEL)
	for i in team.size():
		var data := team[i]
		var unit := BattleUnit.create_ally(data, level, i, skins.get(data.id, &""), names.get(data.id, ""))
		allies.append(unit)
		queue.add(unit)
	_spawn_wave(0)
	match opening:
		BattleTypes.Opening.ADVANTAGE:
			# Cả đội hành động trước ở vòng đầu (nhanh hơn đi trước).
			for unit in allies:
				unit.distance_left = 0.0
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
		var action: Dictionary
		if unit.is_ally():
			action = await _get_ally_action(unit)
		else:
			action = EnemyAI.choose_action(unit, allies, enemies, rng)
		if phase == Phase.ENDED:
			break
		if not action.is_empty() and unit.is_alive():
			await _perform(unit, action["skill"], action["target"])
		if queue.has(unit):
			queue.end_turn(unit)
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


## Xếp tuyệt kỹ chen lượt. Trả về false nếu chưa đầy năng lượng hoặc đã xếp rồi.
func request_ultimate(unit: BattleUnit, target: BattleUnit = null) -> bool:
	if phase == Phase.ENDED or phase == Phase.SETUP or not unit.is_ultimate_ready() or is_ultimate_queued(unit):
		return false
	_interrupts.append({"unit": unit, "target": target})
	if phase == Phase.AWAITING_INPUT:
		_choice = {"type": "interrupt"}
		_choice_made.emit()
	return true


func is_ultimate_queued(unit: BattleUnit) -> bool:
	for entry in _interrupts:
		if entry["unit"] == unit:
			return true
	return false


func set_auto(enabled: bool) -> void:
	auto_mode = enabled
	if enabled and phase == Phase.AWAITING_INPUT:
		_choice = {"type": "auto"}
		_choice_made.emit()


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
	if skill and target:
		for entry in SkillExecutor.resolve_targets(skill, current_unit, target, allies, enemies):
			var unit: BattleUnit = entry["unit"]
			if skill.action_advance > 0.0 and unit != current_unit:
				overrides[unit] = maxf(unit.distance_left - TurnQueue.BASE_DISTANCE * skill.action_advance, 0.0)
			if skill.target_delay > 0.0 and entry["main"]:
				overrides[unit] = unit.distance_left + TurnQueue.BASE_DISTANCE * skill.target_delay
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
		if not unit.is_ultimate_ready():
			continue
		var ultimate := unit.get_skill(SkillData.Kind.ULTIMATE)
		var target: BattleUnit = entry.get("target")
		var pool := SkillExecutor.get_target_pool(ultimate, unit, allies, enemies)
		if pool.is_empty():
			continue
		if target == null or not pool.has(target):
			target = AutoBattle.choose_ultimate_target(unit, self)
		await _perform(unit, ultimate, target)
		if _check_end():
			return


func _perform(unit: BattleUnit, skill: SkillData, target: BattleUnit) -> void:
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
	var events := SkillExecutor.execute(self, unit, skill, target)
	for event in events:
		if event["type"] == "death":
			var dead: BattleUnit = event["target"]
			queue.remove(dead)
			unit_died.emit(dead)
			EventBus.unit_died.emit(dead)
	action_resolved.emit(unit, skill, events)
	queue_changed.emit()
	await _wait(ACTION_PAUSE_SEC)


func _queue_auto_ultimates() -> void:
	for unit in allies:
		if AutoBattle.should_use_ultimate(unit, self) and not is_ultimate_queued(unit):
			_interrupts.append({"unit": unit, "target": null})


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
