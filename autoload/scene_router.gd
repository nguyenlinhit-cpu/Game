extends CanvasLayer
## Chuyển scene có hiệu ứng mờ đen (mờ vào + mờ ra ≈ 0,7 giây).
## Dữ liệu truyền sang scene mới (EncounterData, kiểu mở trận...) đặt trong `payload`.

signal transition_started(target_path: String)
signal transition_finished(target_path: String)

const DEFAULT_FADE_SEC: float = 0.35

var payload: Dictionary = {}

var _fade_rect: ColorRect
var _busy: bool = false


func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade_rect = ColorRect.new()
	_fade_rect.name = "Fade"
	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_fade_rect)


func is_busy() -> bool:
	return _busy


func go_to(scene_path: String, data: Dictionary = {}, fade_sec: float = DEFAULT_FADE_SEC) -> void:
	if _busy:
		push_warning("SceneRouter: đang chuyển scene, bỏ qua yêu cầu tới %s" % scene_path)
		return
	_busy = true
	payload = data
	transition_started.emit(scene_path)
	# Chặn bấm chuột trong lúc chuyển cảnh.
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0, fade_sec)

	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("SceneRouter: không mở được scene %s (lỗi %d)" % [scene_path, err])
	# change_scene_to_file chỉ thay scene ở cuối khung hình; đợi để scene mới chạy xong _ready.
	await get_tree().process_frame
	await get_tree().process_frame
	EventBus.scene_changed.emit(scene_path)

	await _fade_to(0.0, fade_sec)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
	transition_finished.emit(scene_path)


func _fade_to(alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", alpha, duration)
	await tween.finished
