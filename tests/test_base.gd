extends Node
## Lớp cơ sở cho các bộ test chạy bằng scene:
##   godot --headless --path . res://tests/<tên>.tscn
## Lớp con ghi đè _run() và đặt PHASE_NAME. Scene test tự tách ra chạy dưới root
## để SceneRouter đổi scene không xóa luôn bộ test.

var phase_name: String = "Test"
var timeout_sec: float = 120.0

var _failures: Array[String] = []
var _checks: int = 0
var _error_catcher := ErrorCatcher.new()
var _finished: bool = false


## Đếm lỗi engine/script trong lúc chạy test: lỗi trong hàm await làm test bỏ dở lặng lẽ,
## nên có lỗi nào là test thất bại.
class ErrorCatcher extends Logger:
	var messages: Array[String] = []
	## Gọi (deferred) khi có lỗi đầu tiên.
	var on_first_error: Callable
	var _mutex := Mutex.new()

	func _log_error(function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if error_type == ERROR_TYPE_WARNING:
			return
		_mutex.lock()
		messages.append("%s (%s:%d %s) %s" % [code, file.get_file(), line, function, rationale])
		var first := messages.size() == 1
		_mutex.unlock()
		if first and on_first_error.is_valid():
			on_first_error.call_deferred()

	func _log_message(_message: String, _error: bool) -> void:
		pass


func _ready() -> void:
	if get_tree().current_scene == self:
		get_tree().root.add_child.call_deferred((get_script() as GDScript).new())
		return
	# Lỗi script làm hàm await đang chạy dừng hẳn, nên kết thúc test sớm thay vì đợi hết giờ.
	_error_catcher.on_first_error = _on_first_error
	OS.add_logger(_error_catcher)
	get_tree().create_timer(timeout_sec, true, false, true).timeout.connect(func() -> void:
		_fail("Quá thời gian %d giây" % timeout_sec)
		_finish())
	_run()


func _run() -> void:
	_finish()


func _on_first_error() -> void:
	get_tree().create_timer(2.0, true, false, true).timeout.connect(_finish)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("  ĐẠT  ", description)
	else:
		_fail(description)


func _fail(description: String) -> void:
	_failures.append(description)
	printerr("  LỖI  ", description)


func _finish() -> void:
	if _finished:
		return
	_finished = true
	Engine.time_scale = 1.0
	OS.remove_logger(_error_catcher)
	_checks += 1
	if _error_catcher.messages.is_empty():
		print("  ĐẠT  Không có lỗi engine/script trong lúc chạy")
	else:
		_fail("Có %d lỗi engine/script: %s" % [_error_catcher.messages.size(), _error_catcher.messages.slice(0, 3)])
	print("%s: %d/%d kiểm tra đạt" % [phase_name, _checks - _failures.size(), _checks])
	get_tree().quit(1 if not _failures.is_empty() else 0)


func _seconds(duration: float) -> void:
	await get_tree().create_timer(duration, true, false, true).timeout


func _frames(count: int) -> void:
	for i in count:
		await get_tree().process_frame
