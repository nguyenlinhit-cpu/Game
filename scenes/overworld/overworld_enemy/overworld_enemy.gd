class_name OverworldEnemy
extends CharacterBody2D
## Một nhóm quái trên map (đại diện bằng 1 con), gắn với một EncounterData.
## Tuần tra theo các điểm định sẵn, nhìn theo hình nón (có kiểm tra tường chắn), thấy người chơi
## thì báo "!" rồi đuổi, ra quá xa thì bỏ cuộc quay về. Vồ có báo trước (gồng người đỏ lên).
## Kiểu mở trận: người chơi chém trúng trước → Ưu Thế; quái vồ trúng → Bị Phục Kích;
## chạm nhau thường → Bình thường. Đang lướt (bất tử) thì không bị tính chạm.
## Giao diện chung với Room: group "enemy_group", is_defeated(), defeat(), tín hiệu defeated.

signal defeated(group: Node)
signal encounter_triggered(enemy: OverworldEnemy, opening: BattleTypes.Opening)

enum State { PATROL, ALERT, CHASE, RETURN, WINDUP, LUNGE, RECOVER, DAZED }

const GROUP: StringName = &"overworld_enemy"
const ARRIVE_DISTANCE: float = 8.0
## Mất dấu người chơi lâu chừng này giây khi đang đuổi thì bỏ cuộc.
const LOST_SIGHT_GIVE_UP_SEC: float = 2.0
const CONE_COLOR := Color(1.0, 0.85, 0.4, 0.07)
const ALERT_COLOR := Color("ffcf4d")
const WINDUP_COLOR := Color("ff3b3b")

## Bật trong test để quái đứng yên, không gây trận.
static var debug_frozen: bool = false

@export var encounter: EncounterData
@export var config: OverworldEnemyConfig
## Các điểm tuần tra, tính từ vị trí ban đầu. Rỗng thì đứng gác và quay nhìn quanh.
@export var patrol_points: PackedVector2Array = PackedVector2Array()

var state: State = State.PATROL
var facing: Vector2 = Vector2.DOWN

var _home: Vector2
var _patrol_index: int = 0
var _state_time: float = 0.0
var _wait_left: float = 0.0
var _grace_left: float = 0.0
var _cooldown_left: float = 0.0
var _lost_sight_time: float = 0.0
var _lunge_direction: Vector2 = Vector2.ZERO
var _defeated: bool = false
var _triggered: bool = false
var _time: float = 0.0
## Bí Kỹ đã đánh dấu nhóm này (character_id); vào trận thì áp hiệu ứng đầu trận của Bí Kỹ đó.
var marks: Array[StringName] = []


func _ready() -> void:
	add_to_group(GROUP)
	add_to_group(Room.ENEMY_GROUP)
	collision_layer = PhysicsLayers.ENEMY
	collision_mask = PhysicsLayers.WORLD
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if config == null:
		config = load(DataPaths.OVERWORLD_ENEMY_CONFIG) as OverworldEnemyConfig
	var shape := CircleShape2D.new()
	shape.radius = config.body_radius
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)
	_home = global_position
	_grace_left = config.start_grace_sec
	if encounter:
		for error in encounter.validate():
			push_error("OverworldEnemy %s: %s" % [name, error])


func _physics_process(delta: float) -> void:
	_time += delta
	queue_redraw()
	if _defeated or debug_frozen:
		velocity = Vector2.ZERO
		return
	_state_time += delta
	_grace_left = maxf(_grace_left - delta, 0.0)
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if _grace_left > 0.0:
		velocity = Vector2.ZERO
		return

	var player := _find_player()
	match state:
		State.DAZED:
			velocity = Vector2.ZERO
			if _state_time >= _daze_duration:
				_set_state(State.PATROL)
		State.PATROL:
			_process_patrol(delta)
			if can_see(player):
				_set_state(State.ALERT)
		State.ALERT:
			velocity = Vector2.ZERO
			if player:
				facing = global_position.direction_to(player.global_position)
			if _state_time >= config.alert_sec:
				_set_state(State.CHASE)
		State.CHASE:
			_process_chase(delta, player)
		State.RETURN:
			_move_toward(_current_patrol_target(), config.patrol_speed)
			if global_position.distance_to(_current_patrol_target()) < ARRIVE_DISTANCE:
				_set_state(State.PATROL)
			elif can_see(player):
				_set_state(State.ALERT)
		State.WINDUP:
			velocity = Vector2.ZERO
			if _state_time >= config.windup_sec:
				_lunge_direction = facing
				_set_state(State.LUNGE)
		State.LUNGE:
			velocity = _lunge_direction * config.lunge_speed
			if _state_time >= config.lunge_sec:
				_cooldown_left = config.attack_cooldown_sec
				_set_state(State.RECOVER)
		State.RECOVER:
			velocity = velocity.move_toward(Vector2.ZERO, config.lunge_speed * 4.0 * delta)
			if _state_time >= config.recover_sec:
				_set_state(State.CHASE)
	move_and_slide()
	_check_contact(player)


var _daze_duration: float = 0.0


# --- Giao diện cho map / phòng ---

## Bí Kỹ tác động quái trên map: choáng đứng yên, không nhìn thấy ai.
func daze(duration: float) -> void:
	if _defeated:
		return
	_daze_duration = duration
	_set_state(State.DAZED)


func add_mark(character_id: StringName) -> void:
	if not marks.has(character_id):
		marks.append(character_id)

func is_defeated() -> bool:
	return _defeated


## Hạ nhóm quái (thắng trận, thắng ngay, hoặc phím debug).
func defeat() -> void:
	if _defeated:
		return
	_defeated = true
	defeated.emit(self)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)


## Nạp lại map: nhóm này đã bị hạ từ trước, gỡ luôn không phát tín hiệu.
func remove_silently() -> void:
	_defeated = true
	remove_from_group(GROUP)
	remove_from_group(Room.ENEMY_GROUP)
	queue_free()


## Đòn Mở Màn của người chơi trúng quái → Ưu Thế.
func receive_opener_hit(_attacker: Node) -> void:
	_trigger(BattleTypes.Opening.ADVANTAGE)


func get_level() -> int:
	return encounter.get_max_level() if encounter else 1


func is_trivial_for(team_level: int) -> bool:
	return BattleTypes.is_instant_win(team_level, get_level())


func get_hit_radius() -> float:
	return config.body_radius


## Map gọi sau khi trận đã bắt đầu để khỏi phát thêm lần nữa.
func set_triggered(value: bool) -> void:
	_triggered = value


func can_see(player: Node2D) -> bool:
	if player == null or state == State.DAZED:
		return false
	if player is Player and (player as Player).is_invisible():
		return false
	var to_player := player.global_position - global_position
	var distance := to_player.length()
	if distance <= config.hearing_radius:
		return true
	if distance > config.vision_range:
		return false
	if rad_to_deg(absf(facing.angle_to(to_player))) > config.vision_half_angle_deg:
		return false
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position, PhysicsLayers.WORLD)
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


# --- Trạng thái ---

func _set_state(new_state: State) -> void:
	state = new_state
	_state_time = 0.0
	_lost_sight_time = 0.0


func _process_patrol(delta: float) -> void:
	if patrol_points.is_empty():
		velocity = Vector2.ZERO
		# Đứng gác: quay nhìn qua lại.
		facing = Vector2.DOWN.rotated(sin(_time * 0.8) * PI * 0.6)
		return
	if _wait_left > 0.0:
		_wait_left -= delta
		velocity = Vector2.ZERO
		return
	var target := _current_patrol_target()
	_move_toward(target, config.patrol_speed)
	if global_position.distance_to(target) < ARRIVE_DISTANCE:
		_patrol_index = (_patrol_index + 1) % patrol_points.size()
		_wait_left = config.patrol_wait_sec


func _process_chase(delta: float, player: Node2D) -> void:
	if player == null:
		_set_state(State.RETURN)
		return
	var distance := global_position.distance_to(player.global_position)
	if can_see(player):
		_lost_sight_time = 0.0
	else:
		_lost_sight_time += delta
	if distance > config.lose_range or global_position.distance_to(_home) > config.leash_range \
			or _lost_sight_time > LOST_SIGHT_GIVE_UP_SEC:
		_set_state(State.RETURN)
		return
	if distance <= config.attack_range and _cooldown_left <= 0.0:
		facing = global_position.direction_to(player.global_position)
		_set_state(State.WINDUP)
		return
	_move_toward(player.global_position, config.chase_speed)


func _current_patrol_target() -> Vector2:
	if patrol_points.is_empty():
		return _home
	return _home + patrol_points[_patrol_index]


func _move_toward(target: Vector2, speed: float) -> void:
	var offset := target - global_position
	if offset.length() < 1.0:
		velocity = Vector2.ZERO
		return
	facing = offset.normalized()
	velocity = facing * minf(speed, offset.length() / get_physics_process_delta_time())


func _check_contact(player: Player) -> void:
	if player == null or player.is_invincible():
		return
	if global_position.distance_to(player.global_position) > config.contact_distance:
		return
	_trigger(BattleTypes.Opening.AMBUSHED if state == State.LUNGE else BattleTypes.Opening.NORMAL)


func _trigger(opening: BattleTypes.Opening) -> void:
	if _defeated or _triggered or debug_frozen:
		return
	encounter_triggered.emit(self, opening)


func _find_player() -> Player:
	return get_tree().get_first_node_in_group(Player.GROUP) as Player


# --- Hình tạm ---

## Hình thật (Phase 13) của quái đại diện nhóm, null = vẽ tạm.
var sprite: AnimatedSprite2D


func _ensure_sprite() -> void:
	if sprite or encounter == null:
		return
	var frames := ArtLibrary.enemy_frames(encounter.get_leader(), "map")
	if frames:
		var height := ArtLibrary.frame_size_of(frames).y
		sprite = ArtLibrary.make_sprite(frames, height * 4.0 if height <= 64.0 else 130.0)
		add_child(sprite)
		move_child(sprite, 0)


func _process(_delta: float) -> void:
	_ensure_sprite()
	if sprite:
		var moving := velocity.length() > 5.0
		var dir_index := wrapi(roundi(facing.angle() / (PI / 4.0)), 0, 8)
		var action := "windup" if state == State.WINDUP else ("run" if moving else "idle")
		ArtLibrary.play(sprite, action, Player.FACING_NAMES[dir_index])


func _draw() -> void:
	var leader := encounter.get_leader() if encounter else null
	var body_color := leader.placeholder_color if leader else Color("8e2a3b")
	var radius := config.body_radius if config else 28.0

	if state in [State.PATROL, State.RETURN] and config:
		var half := deg_to_rad(config.vision_half_angle_deg)
		var points := PackedVector2Array([Vector2.ZERO])
		for i in 13:
			points.append(Vector2.from_angle(facing.angle() - half + half * 2.0 * i / 12.0) * config.vision_range)
		draw_colored_polygon(points, CONE_COLOR)

	if state == State.WINDUP:
		var t := clampf(_state_time / config.windup_sec, 0.0, 1.0)
		draw_circle(Vector2.ZERO, radius + 10.0 + t * 8.0, Color(WINDUP_COLOR, 0.25 + t * 0.4))
		draw_line(Vector2.ZERO, facing * (config.attack_range * t), Color(WINDUP_COLOR, 0.7), 4.0)

	# Bóng đổ + thân + số con trong nhóm (chấm nhỏ).
	draw_set_transform(Vector2(0.0, radius * 0.9), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, radius * 0.95, Color(0.0, 0.0, 0.0, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var bob := sin(_time * 5.0) * 3.0
	if sprite == null:
		draw_circle(Vector2(0.0, bob), radius, body_color)
		draw_arc(Vector2(0.0, bob), radius, 0.0, TAU, 32, body_color.lightened(0.4), 3.0, true)
		draw_circle(Vector2(0.0, bob) + facing * radius * 0.55, radius * 0.22, Color.WHITE)
	var count := encounter.get_total_enemy_count() if encounter else 1
	for i in mini(count, 8):
		draw_circle(Vector2(-radius + i * 9.0, radius + 12.0), 3.5, body_color.lightened(0.3))

	var font := ThemeDB.fallback_font
	if state == State.DAZED:
		for i in 3:
			var star := Vector2.from_angle(_time * 3.0 + TAU * i / 3.0) * radius * 0.8 + Vector2(0.0, -radius - 20.0)
			draw_circle(star, 5.0, ALERT_COLOR)
	if not marks.is_empty():
		draw_arc(Vector2.ZERO, radius + 8.0, 0.0, TAU, 32, Element.color(Element.Type.FIRE), 3.0, true)
	if state in [State.ALERT, State.CHASE, State.WINDUP, State.LUNGE]:
		draw_string(font, Vector2(-7.0, -radius - 34.0), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, ALERT_COLOR)
	elif state == State.RETURN:
		draw_string(font, Vector2(-9.0, -radius - 34.0), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, ALERT_COLOR)
	var weak := is_trivial_for(GameState.get_team_level())
	draw_string(font, Vector2(-26.0, -radius - 6.0), "Lv %d" % get_level(), HORIZONTAL_ALIGNMENT_LEFT, -1, 22,
			Color(0.7, 0.7, 0.7) if weak else Color.WHITE)
