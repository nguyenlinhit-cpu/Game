class_name Player
extends CharacterBody2D
## Nhân vật dẫn đầu ngoài map (đổi giữa 4 người trong đội bằng phím 1–4): đi 8 hướng có tăng/giảm tốc,
## lướt có hồi chiêu và bất tử ngắn, Đòn Mở Màn của người dẫn đầu (J/chuột trái) đánh quái / mở vật cản
## đúng nguyên tố, Bí Kỹ (K/E) do OverworldMap xử lý, tương tác vật gần nhất bằng F. Hình tạm vẽ theo skin, có chỉ hướng và nhấp nhô khi chạy.
## Thông số di chuyển trong data/config/player_movement.tres.

signal dashed
## Số quái và vật phá được trúng đòn.
signal opener_used(hit_count: int)
signal focused_interactable_changed(interactable: Interactable)
signal technique_requested
## Đòn Mở Màn trúng vật cản: mở được hay không.
signal obstacle_hit(obstacle: ElementalObstacle, opened: bool)

## Thứ tự trùng với góc: 0 = đông, tăng theo chiều kim đồng hồ (trục y hướng xuống).
## Dùng cho tên file sprite theo mục 12, vd. map_ignar_run_se_03.png.
const FACING_NAMES: Array[String] = ["e", "se", "s", "sw", "w", "nw", "n", "ne"]
const BODY_RADIUS: float = 30.0
const INPUT_FACING_THRESHOLD: float = 0.2
const RUN_ANIM_SPEED: float = 20.0
const DASH_GHOST_COUNT: int = 4
const GROUP: StringName = &"player"
const BREAKABLE_GROUP: StringName = &"breakable"
const SWING_SEC: float = 0.15
const SWING_COLOR := Color(1.0, 0.95, 0.75, 0.55)

@export var movement: PlayerMovementConfig
## Đòn Mở Màn của người dẫn đầu (đổi khi đổi người).
@export var opener: OpenerAttackData

## Hướng nhìn (đã chuẩn hóa).
var facing: Vector2 = Vector2.DOWN
## Tắt khi đang hội thoại, chuyển cảnh...
var input_enabled: bool = true

var _skin: CharacterSkin
var _leader: CharacterData
var _phase_left: float = 0.0
var _phase_direction: Vector2 = Vector2.ZERO
var _phase_speed: float = 1600.0
var _invisible_left: float = 0.0
var _speed_bonus: float = 0.0
var _dash_time_left: float = 0.0
var _dash_cooldown_left: float = 0.0
var _invincible_left: float = 0.0
var _opener_cooldown_left: float = 0.0
var _swing_left: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO
var _anim_time: float = 0.0
var _focused: Interactable
## Vị trí bóng mờ khi lướt, toạ độ thế giới.
var _ghosts: Array[Vector2] = []

@onready var _name_label: Label = %NameLabel
@onready var _interaction_area: Area2D = %InteractionArea


func _ready() -> void:
	add_to_group(GROUP)
	if opener == null:
		opener = load(DataPaths.TRAVELER_OPENER) as OpenerAttackData
	if movement == null:
		movement = load(DataPaths.PLAYER_MOVEMENT_CONFIG) as PlayerMovementConfig
	collision_mask = PhysicsLayers.WORLD | PhysicsLayers.WARP_BARRIER
	set_leader(GameState.leader_index)


func _physics_process(delta: float) -> void:
	_invisible_left = maxf(_invisible_left - delta, 0.0)
	modulate.a = 0.45 if is_invisible() else 1.0
	if _phase_left > 0.0 or _is_inside_barrier():
		_process_phase_dash(delta)
		return
	collision_mask = PhysicsLayers.WORLD | PhysicsLayers.WARP_BARRIER
	_dash_cooldown_left = maxf(_dash_cooldown_left - delta, 0.0)
	_invincible_left = maxf(_invincible_left - delta, 0.0)
	_opener_cooldown_left = maxf(_opener_cooldown_left - delta, 0.0)
	_swing_left = maxf(_swing_left - delta, 0.0)

	var input_vector := Vector2.ZERO
	if input_enabled:
		input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.length() > INPUT_FACING_THRESHOLD:
		facing = input_vector.normalized()
	if input_enabled and Input.is_action_just_pressed("dash"):
		try_dash(input_vector)

	if is_dashing():
		_dash_time_left -= delta
		velocity = _dash_direction * movement.dash_speed
		_ghosts.append(global_position)
		if _ghosts.size() > DASH_GHOST_COUNT:
			_ghosts.pop_front()
		if _dash_time_left <= 0.0:
			# Ra khỏi lướt ở tốc độ chạy để không bị khựng.
			velocity = _dash_direction * movement.max_speed
	else:
		var bonus := 1.0 + (_speed_bonus if is_invisible() else 0.0)
		var target := input_vector * movement.max_speed * bonus
		var rate := movement.acceleration if input_vector != Vector2.ZERO else movement.friction
		velocity = velocity.move_toward(target, rate * delta)
		if not _ghosts.is_empty():
			_ghosts.pop_front()
	move_and_slide()

	_anim_time += delta
	_update_focus()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	for i in GameConfig.MAX_TEAM_SIZE:
		if event.is_action_pressed("switch_character_%d" % (i + 1)):
			get_viewport().set_input_as_handled()
			set_leader(i)
			return
	if event.is_action_pressed("technique"):
		get_viewport().set_input_as_handled()
		technique_requested.emit()
		return
	if event.is_action_pressed("interact") and _focused != null:
		get_viewport().set_input_as_handled()
		_focused.interact(self)
	elif event.is_action_pressed("opener_attack"):
		get_viewport().set_input_as_handled()
		# Bấm chuột thì chém về phía con trỏ, còn lại chém theo hướng nhìn.
		var aim := Vector2.ZERO
		if event is InputEventMouseButton:
			aim = get_global_mouse_position() - global_position
		try_opener(aim)


## Chém hình quạt trước mặt. Trúng quái → báo quái (Ưu Thế); trúng vật phá được → phá.
## Trả về false nếu đang hồi chiêu hoặc đang lướt.
func try_opener(aim: Vector2 = Vector2.ZERO) -> bool:
	if _opener_cooldown_left > 0.0 or is_dashing():
		return false
	if aim.length() > 0.01:
		facing = aim.normalized()
	_opener_cooldown_left = opener.cooldown_sec
	_swing_left = SWING_SEC
	var hits := 0
	# Mỗi lần chém chỉ mở 1 trận: chọn con quái gần nhất trong quạt.
	var target: OverworldEnemy = null
	var best_distance := INF
	for node in get_tree().get_nodes_in_group(OverworldEnemy.GROUP):
		var enemy := node as OverworldEnemy
		if enemy and not enemy.is_defeated() and is_in_opener_arc(enemy.global_position, enemy.get_hit_radius()):
			var distance := global_position.distance_to(enemy.global_position)
			if distance < best_distance:
				best_distance = distance
				target = enemy
	for node in get_tree().get_nodes_in_group(ElementalObstacle.GROUP):
		var obstacle := node as ElementalObstacle
		if obstacle and not obstacle.is_resolved and is_in_opener_arc(obstacle.global_position, obstacle.get_hit_radius()):
			var opened := obstacle.receive_opener(opener.element)
			obstacle_hit.emit(obstacle, opened)
			hits += 1
	for node in get_tree().get_nodes_in_group(BREAKABLE_GROUP):
		# Vật phá được là Interactable có hàm break_open() (Hộp Bí Kỹ...).
		var breakable := node as Interactable
		if breakable and breakable.can_interact() and is_in_opener_arc(breakable.global_position, 22.0):
			breakable.call("break_open")
			hits += 1
	if target:
		hits += 1
		target.receive_opener_hit(self)
	if hits > 0:
		CameraRig.shake(5.0, 0.12)
	opener_used.emit(hits)
	queue_redraw()
	return true


func is_in_opener_arc(point: Vector2, target_radius: float = 0.0) -> bool:
	var offset := point - global_position
	if offset.length() > opener.range_px + target_radius:
		return false
	if offset.length() <= target_radius:
		return true
	return rad_to_deg(absf(facing.angle_to(offset))) <= opener.arc_degrees * 0.5


func get_opener_cooldown_ratio() -> float:
	return _opener_cooldown_left / opener.cooldown_sec if opener.cooldown_sec > 0.0 else 0.0


## Đổi người dẫn đầu theo vị trí trong đội. Trả về false nếu vị trí trống.
func set_leader(index: int) -> bool:
	var team := GameState.get_team_data()
	if index < 0 or index >= team.size():
		return false
	GameState.leader_index = index
	_leader = team[index]
	var is_traveler := _leader.id == GameState.PLAYER_CHARACTER_ID
	_skin = _leader.get_skin(GameState.player_gender if is_traveler else &"default")
	if _leader.opener:
		opener = _leader.opener
	_name_label.text = GameState.player_name if is_traveler else tr(_leader.name_key)
	EventBus.leader_changed.emit(index)
	queue_redraw()
	return true


func get_leader() -> CharacterData:
	return _leader


## Bí Kỹ "Bước Hư Ảnh": lướt xuyên rào Ma Biến (bỏ lớp va chạm rào trong lúc lướt).
func start_phase_dash(distance_px: float) -> void:
	_phase_direction = facing.normalized()
	_phase_left = distance_px / _phase_speed
	_invincible_left = maxf(_invincible_left, _phase_left + 0.1)
	collision_mask = PhysicsLayers.WORLD


func is_phase_dashing() -> bool:
	return _phase_left > 0.0


## Bí Kỹ tàng hình: quái không nhìn thấy, đi nhanh hơn.
func make_invisible(duration: float, speed_bonus: float) -> void:
	_invisible_left = duration
	_speed_bonus = speed_bonus


func is_invisible() -> bool:
	return _invisible_left > 0.0


func _process_phase_dash(delta: float) -> void:
	_phase_left = maxf(_phase_left - delta, 0.0)
	velocity = _phase_direction * _phase_speed
	_ghosts.append(global_position)
	if _ghosts.size() > DASH_GHOST_COUNT:
		_ghosts.pop_front()
	move_and_slide()
	_anim_time += delta
	queue_redraw()


## Còn kẹt trong rào Ma Biến thì đi tiếp cho ra hẳn.
func _is_inside_barrier() -> bool:
	if collision_mask & PhysicsLayers.WARP_BARRIER:
		return false
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = ($CollisionShape2D as CollisionShape2D).shape
	query.transform = ($CollisionShape2D as CollisionShape2D).global_transform
	query.collision_mask = PhysicsLayers.WARP_BARRIER
	return not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


## Bất tử tạm thời (vd. vừa từ trận quay về map).
func grant_invincibility(duration: float) -> void:
	_invincible_left = maxf(_invincible_left, duration)


## Lướt theo hướng đang bấm, không bấm thì theo hướng nhìn. Trả về false nếu đang hồi chiêu.
func try_dash(direction: Vector2 = Vector2.ZERO) -> bool:
	if is_dashing() or _dash_cooldown_left > 0.0:
		return false
	_dash_direction = (direction if direction.length() > INPUT_FACING_THRESHOLD else facing).normalized()
	_dash_time_left = movement.dash_duration
	_dash_cooldown_left = movement.dash_cooldown
	_invincible_left = movement.dash_invincibility
	_ghosts.clear()
	dashed.emit()
	return true


func is_dashing() -> bool:
	return _dash_time_left > 0.0


## Phase 3 dùng để bỏ qua đòn đánh của quái trên map.
func is_invincible() -> bool:
	return _invincible_left > 0.0


## 1 = vừa lướt xong, 0 = lướt được.
func get_dash_cooldown_ratio() -> float:
	if movement.dash_cooldown <= 0.0:
		return 0.0
	return _dash_cooldown_left / movement.dash_cooldown


func get_facing_name() -> String:
	return FACING_NAMES[wrapi(roundi(facing.angle() / (PI / 4.0)), 0, FACING_NAMES.size())]


## Tên hoạt ảnh theo mục 12 (idle/run/dash); Phase 13 nối vào SpriteFrames.
func get_animation_name() -> String:
	if is_dashing():
		return "dash"
	return "run" if velocity.length() > RUN_ANIM_SPEED else "idle"


func get_skin_id() -> StringName:
	return _skin.skin_id if _skin else &""


func get_display_name() -> String:
	return _name_label.text


func get_focused_interactable() -> Interactable:
	return _focused


func _update_focus() -> void:
	var best: Interactable = null
	var best_distance := INF
	for area in _interaction_area.get_overlapping_areas():
		var interactable := area as Interactable
		if interactable == null or not interactable.can_interact():
			continue
		var distance := global_position.distance_squared_to(interactable.global_position)
		if distance < best_distance:
			best_distance = distance
			best = interactable
	if best != _focused:
		_focused = best
		focused_interactable_changed.emit(best)


func _draw() -> void:
	var body := _skin.placeholder_color if _skin else Color.GRAY
	var accent := _skin.accent_color if _skin else Color.WHITE
	for i in _ghosts.size():
		var alpha := 0.12 + 0.1 * i
		draw_circle(to_local(_ghosts[i]), BODY_RADIUS, Color(accent, alpha))

	var animation := get_animation_name()
	var bob := absf(sin(_anim_time * 14.0)) * 5.0 if animation == "run" else 0.0
	var center := Vector2(0.0, -bob)
	if is_invincible():
		draw_arc(center, BODY_RADIUS + 6.0, 0.0, TAU, 32, Color(accent, 0.6), 3.0, true)
	PlaceholderArt.draw_character(self, center, BODY_RADIUS, body, accent,
			get_display_name().left(1).to_upper())

	if _swing_left > 0.0:
		# Vệt chém hình quạt, mờ dần.
		var alpha := _swing_left / SWING_SEC
		var half := deg_to_rad(opener.arc_degrees * 0.5)
		var points := PackedVector2Array()
		for i in 13:
			points.append(Vector2.from_angle(facing.angle() - half + half * 2.0 * i / 12.0) * opener.range_px)
		for i in range(12, -1, -1):
			points.append(Vector2.from_angle(facing.angle() - half + half * 2.0 * i / 12.0) * opener.range_px * 0.55)
		draw_colored_polygon(points, Color(SWING_COLOR, SWING_COLOR.a * alpha))

	# Mũi tên chỉ hướng nhìn (8 hướng).
	var snapped_facing := Vector2.from_angle(roundi(facing.angle() / (PI / 4.0)) * PI / 4.0)
	var tip := center + snapped_facing * (BODY_RADIUS + 16.0)
	var side := snapped_facing.orthogonal() * 8.0
	var base := center + snapped_facing * (BODY_RADIUS + 4.0)
	draw_colored_polygon(PackedVector2Array([tip, base + side, base - side]), accent)
