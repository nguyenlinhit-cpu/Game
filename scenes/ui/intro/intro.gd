extends Control
## Lời dẫn mở đầu: chữ chạy từng dòng, mỗi trang vài dòng, có nút bỏ qua.
## Nội dung và nhịp chữ đọc từ data/dialogue/intro.json, câu chữ lấy từ file dịch.

enum State { TYPING, LINE_HOLD, PAGE_HOLD, PAGE_FADE, DONE }

const LINE_FONT_SIZE: int = 40

var _pages: Array = []
var _chars_per_second: float = 38.0
var _line_hold_sec: float = 0.7
var _page_hold_sec: float = 2.4
var _page_fade_sec: float = 0.6

var _state: State = State.DONE
var _page_index: int = -1
var _line_index: int = -1
var _current_label: Label
var _typed_chars: float = 0.0
var _timer: float = 0.0
var _finished: bool = false

@onready var _lines_box: VBoxContainer = %Lines
@onready var _skip_button: Button = %SkipButton


func _ready() -> void:
	_skip_button.pressed.connect(_finish)
	_load_script()
	if _pages.is_empty():
		_finish.call_deferred()
		return
	_start_page(0)


func _load_script() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DataPaths.INTRO_SCRIPT))
	if not parsed is Dictionary:
		push_error("Intro: không đọc được %s" % DataPaths.INTRO_SCRIPT)
		return
	var data: Dictionary = parsed
	_chars_per_second = float(data.get("chars_per_second", _chars_per_second))
	_line_hold_sec = float(data.get("line_hold_sec", _line_hold_sec))
	_page_hold_sec = float(data.get("page_hold_sec", _page_hold_sec))
	_page_fade_sec = float(data.get("page_fade_sec", _page_fade_sec))
	for page: Variant in data.get("pages", []):
		if page is Array and not page.is_empty():
			_pages.append(page)


func _process(delta: float) -> void:
	match _state:
		State.TYPING:
			_typed_chars += _chars_per_second * UserSettings.text_speed() * delta
			_current_label.visible_characters = int(_typed_chars)
			if _typed_chars >= _current_label.get_total_character_count():
				_complete_line()
		State.LINE_HOLD:
			_timer -= delta
			if _timer <= 0.0:
				_next_line()
		State.PAGE_HOLD:
			_timer -= delta
			if _timer <= 0.0:
				_state = State.PAGE_FADE
				_timer = _page_fade_sec
		State.PAGE_FADE:
			_timer -= delta
			_lines_box.modulate.a = clampf(_timer / maxf(_page_fade_sec, 0.001), 0.0, 1.0)
			if _timer <= 0.0:
				if _page_index + 1 < _pages.size():
					_start_page(_page_index + 1)
				else:
					_finish()


func _unhandled_input(event: InputEvent) -> void:
	if _state == State.DONE:
		return
	if event.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		_finish()
		return
	# Chạm màn hình cũng ra sự kiện chuột (emulate_mouse_from_touch), nên chỉ cần bắt chuột.
	var mouse_event := event as InputEventMouseButton
	var is_click := mouse_event != null and mouse_event.pressed \
			and mouse_event.button_index == MOUSE_BUTTON_LEFT
	if is_click or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_advance()


## Bấm để đọc nhanh: đang chạy chữ thì hiện hết dòng, đang chờ thì sang bước kế.
func _advance() -> void:
	match _state:
		State.TYPING:
			_complete_line()
		State.LINE_HOLD, State.PAGE_HOLD:
			_timer = 0.0


func _start_page(index: int) -> void:
	_page_index = index
	for child in _lines_box.get_children():
		child.queue_free()
	_lines_box.modulate.a = 1.0
	_line_index = -1
	_next_line()


func _next_line() -> void:
	var page: Array = _pages[_page_index]
	_line_index += 1
	if _line_index >= page.size():
		_state = State.PAGE_HOLD
		_timer = _page_hold_sec
		return
	_current_label = Label.new()
	_current_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_current_label.text = tr(str(page[_line_index]))
	_current_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_current_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Dàn chữ trước rồi mới ẩn bớt, để chữ không nhảy dòng khi đang chạy.
	_current_label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	_current_label.visible_characters = 0
	_current_label.add_theme_font_size_override("font_size", LINE_FONT_SIZE)
	_lines_box.add_child(_current_label)
	_typed_chars = 0.0
	_state = State.TYPING


func _complete_line() -> void:
	_current_label.visible_characters = -1
	_state = State.LINE_HOLD
	_timer = _line_hold_sec


func _finish() -> void:
	if _finished:
		return
	_finished = true
	_state = State.DONE
	set_process(false)
	SceneRouter.go_to(DataPaths.CHARACTER_SELECT_SCENE)
