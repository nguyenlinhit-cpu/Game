extends Node
## Lớp cơ sở cho các bộ test chạy bằng scene:
##   godot --headless --path . res://tests/<tên>.tscn
## Lớp con ghi đè _run() và đặt PHASE_NAME. Scene test tự tách ra chạy dưới root
## để SceneRouter đổi scene không xóa luôn bộ test.

var phase_name: String = "Test"
var timeout_sec: float = 120.0

var _failures: Array[String] = []
var _checks: int = 0


func _ready() -> void:
	if get_tree().current_scene == self:
		get_tree().root.add_child.call_deferred((get_script() as GDScript).new())
		return
	get_tree().create_timer(timeout_sec, true, false, true).timeout.connect(func() -> void:
		_fail("Quá thời gian %d giây" % timeout_sec)
		_finish())
	_run()


func _run() -> void:
	_finish()


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
	Engine.time_scale = 1.0
	print("%s: %d/%d kiểm tra đạt" % [phase_name, _checks - _failures.size(), _checks])
	get_tree().quit(1 if not _failures.is_empty() else 0)


func _seconds(duration: float) -> void:
	await get_tree().create_timer(duration, true, false, true).timeout


func _frames(count: int) -> void:
	for i in count:
		await get_tree().process_frame
