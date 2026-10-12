class_name CameraRig
extends Camera2D
## Camera bám mượt nhân vật, giới hạn trong phòng đang đứng, có rung dùng chung.
## Gọi rung từ bất cứ đâu: CameraRig.shake(cường độ_px, thời_gian_giây).

const NO_LIMIT: int = 10000000

@export var target_path: NodePath
@export var follow_speed: float = 7.0

var _target: Node2D
var _shake_strength: float = 0.0
var _shake_duration: float = 0.0
var _shake_time_left: float = 0.0
var _rng := RandomNumberGenerator.new()


static func shake(strength: float = 8.0, duration: float = 0.2) -> void:
	EventBus.camera_shake_requested.emit(strength, duration)


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node2D
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	position_smoothing_enabled = true
	position_smoothing_speed = follow_speed
	limit_smoothed = true
	clear_limits()
	EventBus.camera_shake_requested.connect(_on_shake_requested)
	make_current()


func _physics_process(delta: float) -> void:
	if _target:
		global_position = _target.global_position
	if _shake_time_left > 0.0:
		_shake_time_left = maxf(_shake_time_left - delta, 0.0)
		var falloff := _shake_time_left / _shake_duration
		offset = Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)) * _shake_strength * falloff
	elif offset != Vector2.ZERO:
		offset = Vector2.ZERO


## Nhảy thẳng tới mục tiêu, bỏ qua làm mượt (dùng khi vừa vào map).
func snap_to_target() -> void:
	if _target:
		global_position = _target.global_position
	reset_smoothing()


## Giới hạn camera trong khung phòng. Phòng nhỏ hơn màn hình thì nới đều hai bên để phòng nằm giữa.
func set_room_limits(room_rect: Rect2) -> void:
	var view := get_viewport_rect().size / zoom
	var rect := room_rect
	if rect.size.x < view.x:
		var pad_x := (view.x - rect.size.x) * 0.5
		rect = rect.grow_individual(pad_x, 0.0, pad_x, 0.0)
	if rect.size.y < view.y:
		var pad_y := (view.y - rect.size.y) * 0.5
		rect = rect.grow_individual(0.0, pad_y, 0.0, pad_y)
	limit_left = floori(rect.position.x)
	limit_top = floori(rect.position.y)
	limit_right = ceili(rect.end.x)
	limit_bottom = ceili(rect.end.y)


func clear_limits() -> void:
	limit_left = -NO_LIMIT
	limit_top = -NO_LIMIT
	limit_right = NO_LIMIT
	limit_bottom = NO_LIMIT


func _on_shake_requested(strength: float, duration: float) -> void:
	# Rung mạnh hơn thì đè rung yếu đang chạy.
	if _shake_time_left > 0.0 and strength < _shake_strength * (_shake_time_left / _shake_duration):
		return
	_shake_strength = strength
	_shake_duration = maxf(duration, 0.01)
	_shake_time_left = _shake_duration
