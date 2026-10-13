class_name DialogueBox
extends CanvasLayer
## Hộp thoại (mục 13): chân dung + biểu cảm, tên người nói, chữ chạy, lựa chọn, sự kiện của câu thoại.
## Bấm / Space / F / Enter: chữ đang chạy thì hiện hết, đã hiện hết thì sang câu sau.
## "Bỏ qua" chạy nhanh tới lựa chọn kế tiếp hoặc hết cảnh (sự kiện vẫn được áp). "Lịch sử" xem lại các câu đã qua.
## Mở hộp thoại thì tạm dừng game (map, quái đứng yên), đóng thì chạy lại.

signal finished

const CHARS_PER_SECOND: float = 45.0
const HISTORY_LIMIT: int = 200
const PANEL_HEIGHT: float = 300.0

## Lịch sử câu thoại trong phiên: [{ "name", "text" }].
var history: Array[Dictionary] = []
var lines: Array = []
var index: int = -1
var dialogue_id: String = ""

var _typed: float = 0.0
var _typing: bool = false
var _paused_before: bool = false
var _root: Control
var _portrait: Portrait
var _name_label: Label
var _text: RichTextLabel
var _next_hint: Label
var _choices_box: VBoxContainer
var _history_panel: PanelContainer
var _history_text: RichTextLabel


func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.gui_input.connect(_on_root_input)
	add_child(_root)
	var panel := UiKit.make_panel(Color(0.05, 0.05, 0.1, 0.94))
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 40.0
	panel.offset_right = -40.0
	panel.offset_top = -PANEL_HEIGHT - 30.0
	panel.offset_bottom = -30.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(row)
	_portrait = Portrait.new()
	_portrait.custom_minimum_size = Vector2(230.0, 230.0)
	row.add_child(_portrait)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(column)
	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(header)
	_name_label = UiKit.make_label("", 34, UiKit.GOLD)
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_name_label)
	header.add_child(UiKit.make_button(tr("DIALOGUE_HISTORY"), toggle_history, Vector2(160.0, 48.0)))
	header.add_child(UiKit.make_button(tr("UI_SKIP"), skip, Vector2(160.0, 48.0)))
	_text = UiKit.make_rich(30)
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_text)
	_next_hint = UiKit.make_label("▼", 26, UiKit.GOLD)
	_next_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	column.add_child(_next_hint)
	_choices_box = VBoxContainer.new()
	_choices_box.add_theme_constant_override("separation", 12)
	_choices_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_choices_box.offset_left = -760.0
	_choices_box.offset_right = -80.0
	_choices_box.offset_top = -300.0
	_choices_box.offset_bottom = 60.0
	_choices_box.alignment = BoxContainer.ALIGNMENT_END
	_root.add_child(_choices_box)
	_history_panel = UiKit.make_panel()
	_history_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 80)
	_root.add_child(_history_panel)
	var history_box := VBoxContainer.new()
	_history_panel.add_child(history_box)
	var history_header := HBoxContainer.new()
	history_box.add_child(history_header)
	var title := UiKit.make_label(tr("DIALOGUE_HISTORY"), 32, UiKit.GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	history_header.add_child(title)
	history_header.add_child(UiKit.make_button(tr("UI_CLOSE"), toggle_history, Vector2(160.0, 52.0)))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	history_box.add_child(scroll)
	_history_text = UiKit.make_rich(24)
	scroll.add_child(_history_text)
	_history_panel.hide()
	hide()


func is_open() -> bool:
	return visible


func open(dialogue: Dictionary) -> void:
	dialogue_id = str(dialogue.get("id", ""))
	lines = dialogue.get("lines", [])
	_paused_before = get_tree().paused
	get_tree().paused = true
	show()
	_history_panel.hide()
	_show_line(0)


func close() -> void:
	hide()
	_clear_choices()
	lines = []
	index = -1
	get_tree().paused = _paused_before
	finished.emit()


func get_current_line() -> Dictionary:
	return lines[index] if index >= 0 and index < lines.size() else {}


func is_typing() -> bool:
	return _typing


func has_choices() -> bool:
	return _choices_box.get_child_count() > 0


func _process(delta: float) -> void:
	if not visible or not _typing:
		return
	_typed += CHARS_PER_SECOND * UserSettings.text_speed() * delta
	_text.visible_characters = int(_typed)
	if _typed >= _text.get_total_character_count():
		_finish_typing()


func _show_line(new_index: int) -> void:
	_clear_choices()
	if new_index < 0 or new_index >= lines.size():
		close()
		return
	index = new_index
	var line: Dictionary = lines[index]
	var speaker := str(line.get("speaker", "narrator"))
	var name_text := StoryManager.speaker_name(speaker)
	var body := StoryManager.format_text(tr(str(line.get("text", ""))))
	_name_label.text = name_text
	_portrait.setup(speaker, name_text, str(line.get("expression", "neutral")))
	_text.text = "[i]%s[/i]" % body if speaker == "narrator" else body
	_text.visible_characters = 0
	_typed = 0.0
	_typing = true
	_next_hint.hide()
	history.append({"name": name_text, "text": body})
	if history.size() > HISTORY_LIMIT:
		history.pop_front()
	StoryManager.apply_events(line.get("events", []))


func _finish_typing() -> void:
	_typing = false
	_text.visible_characters = -1
	var line := get_current_line()
	if line.has("choices"):
		_show_choices(line["choices"])
	else:
		_next_hint.show()


## Bấm tiếp: chữ đang chạy thì hiện hết; xong rồi thì sang câu sau (trừ khi đang chờ lựa chọn).
func advance() -> void:
	if not visible or _history_panel.visible:
		return
	if _typing:
		_finish_typing()
		return
	if has_choices():
		return
	var line := get_current_line()
	if bool(line.get("end", false)):
		close()
		return
	_show_line(StoryManager.find_label(lines, str(line.get("goto", "")), index + 1))


## Chọn lựa chọn thứ `choice_index` của câu hiện tại.
func choose(choice_index: int) -> void:
	var line := get_current_line()
	var choices: Array = line.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return
	var choice: Dictionary = choices[choice_index]
	history.append({"name": "›", "text": tr(str(choice.get("text", "")))})
	StoryManager.apply_events(choice.get("events", []))
	if bool(choice.get("end", false)):
		close()
		return
	_show_line(StoryManager.find_label(lines, str(choice.get("goto", "")), index + 1))


## Chạy nhanh tới lựa chọn kế tiếp hoặc hết cảnh.
func skip() -> void:
	var guard := 0
	while visible and guard < 1000:
		guard += 1
		if _typing:
			_finish_typing()
		if has_choices():
			return
		advance()


func toggle_history() -> void:
	_history_panel.visible = not _history_panel.visible
	if _history_panel.visible:
		var parts: Array[String] = []
		for entry in history:
			var name_text := str(entry["name"])
			parts.append(("[color=#%s]%s[/color]\n" % [UiKit.GOLD.to_html(false), name_text] if name_text != "" else "")
					+ str(entry["text"]))
		_history_text.text = "\n\n".join(parts)


func _show_choices(choices: Array) -> void:
	_clear_choices()
	for i in choices.size():
		var button := UiKit.make_button(tr(str(choices[i].get("text", ""))), choose.bind(i), Vector2(0.0, 64.0))
		button.add_theme_font_size_override("font_size", 26)
		_choices_box.add_child(button)


func _clear_choices() -> void:
	for child in _choices_box.get_children():
		_choices_box.remove_child(child)
		child.queue_free()


func _on_root_input(event: InputEvent) -> void:
	var pressed: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	pressed = pressed or (event is InputEventScreenTouch and event.pressed)
	if pressed:
		_root.accept_event()
		advance()


## Phím xử lý ở _input để đi trước menu tạm dừng / người chơi (chuột thì để nút giao diện nhận).
func _input(event: InputEvent) -> void:
	if not visible or event is InputEventMouse or event is InputEventScreenTouch:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact") \
			or (event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).keycode == KEY_SPACE):
		get_viewport().set_input_as_handled()
		advance()
	elif event.is_action_pressed("menu") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if _history_panel.visible:
			_history_panel.hide()
	elif event.is_pressed():
		# Không để phím di chuyển / đánh lọt xuống map khi đang thoại.
		get_viewport().set_input_as_handled()


## Chân dung tạm: khối màu của người nói, chữ cái đầu, biểu cảm.
class Portrait:
	extends Control
	var color: Color = Color.GRAY
	var letter: String = ""
	var expression: String = "neutral"
	var narrator: bool = false
	var texture: Texture2D

	func setup(speaker_id: String, name_text: String, expression_id: String) -> void:
		narrator = speaker_id == "narrator"
		texture = StoryManager.speaker_portrait(speaker_id, expression_id)
		color = StoryManager.speaker_color(speaker_id)
		letter = name_text.left(1).to_upper()
		expression = expression_id
		queue_redraw()

	func _draw() -> void:
		var rect := Rect2(Vector2.ZERO, size)
		if narrator:
			draw_rect(rect, Color(1, 1, 1, 0.04))
			draw_string(get_theme_default_font(), Vector2(size.x * 0.5 - 24.0, size.y * 0.5 + 24.0), "✦",
					HORIZONTAL_ALIGNMENT_LEFT, -1, 64, Color(color, 0.8))
			return
		if texture:
			draw_texture_rect(texture, rect, false)
			draw_rect(rect, UiKit.GOLD, false, 3.0)
			return
		draw_rect(rect, color.darkened(0.55))
		draw_circle(Vector2(size.x * 0.5, size.y * 0.42), size.x * 0.28, color)
		draw_rect(Rect2(size.x * 0.2, size.y * 0.66, size.x * 0.6, size.y * 0.34), color.darkened(0.15))
		var font := get_theme_default_font()
		draw_string(font, Vector2(size.x * 0.5 - 26.0, size.y * 0.42 + 26.0), letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 72,
				Color.WHITE)
		draw_rect(Rect2(0.0, size.y - 34.0, size.x, 34.0), Color(0, 0, 0, 0.55))
		draw_string(font, Vector2(8.0, size.y - 9.0), TranslationServer.translate("EXPRESSION_" + expression.to_upper()),
				HORIZONTAL_ALIGNMENT_LEFT, size.x - 16.0, 20, Color(1, 1, 1, 0.85))
		draw_rect(rect, UiKit.GOLD, false, 3.0)
