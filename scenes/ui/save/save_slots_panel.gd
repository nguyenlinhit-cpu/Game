class_name SaveSlotsPanel
extends Control
## Màn Lưu / Tải (Phase 14): ô tự lưu (chỉ tải) + 3 ô lưu tay. Mỗi ô hiện tên, chương đã xong, khu, giờ chơi, đội,
## thời điểm lưu. Lưu đè / tải / xóa đều hỏi xác nhận. Ở màn tiêu đề chỉ có thẻ Tải.
## Tải xong: phát `loaded(slot)` – nơi mở bảng tự chuyển scene.

signal closed
signal loaded(slot: int)

enum Mode { SAVE, LOAD }

var mode: Mode = Mode.LOAD
var allow_save: bool = true
## Hộp xác nhận đang mở (test bấm).
var confirm_box: Control

var _tabs: Dictionary = {}
var _list: VBoxContainer
var _buttons: Dictionary = {}


func setup(start_mode: Mode, can_save: bool) -> void:
	mode = start_mode if can_save else Mode.LOAD
	allow_save = can_save


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := UiKit.make_panel()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(1200.0, 0.0)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)
	for entry: Array in [[Mode.SAVE, "SAVE_TAB_SAVE"], [Mode.LOAD, "SAVE_TAB_LOAD"]]:
		if entry[0] == Mode.SAVE and not allow_save:
			continue
		var tab := UiKit.make_button(tr(entry[1]), show_mode.bind(entry[0]), Vector2(220.0, 56.0))
		tab.toggle_mode = true
		header.add_child(tab)
		_tabs[entry[0]] = tab
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	header.add_child(UiKit.make_button(tr("UI_CLOSE"), close, Vector2(180.0, 56.0)))
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 12)
	box.add_child(_list)
	show_mode(mode)


func show_mode(value: int) -> void:
	mode = value as Mode
	for key: int in _tabs:
		(_tabs[key] as Button).set_pressed_no_signal(key == mode)
	refresh()


## Nút của ô `slot`: "save" / "load" / "delete".
func get_slot_button(slot: int, action: String) -> Button:
	return _buttons.get("%d_%s" % [slot, action])


func refresh() -> void:
	UiKit.clear(_list)
	_buttons.clear()
	for slot in SaveManager.get_all_slots():
		var info := SaveManager.get_slot_info(slot)
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", UiKit.panel_style(Color(0.1, 0.09, 0.18, 0.95),
				UiKit.GOLD if slot == SaveManager.AUTOSAVE_SLOT else UiKit.PANEL_BORDER, 10))
		_list.add_child(row)
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 16)
		row.add_child(line)
		var text := UiKit.make_rich(24)
		text.custom_minimum_size = Vector2(700.0, 0.0)
		text.text = _describe(slot, info)
		line.add_child(text)
		var is_auto := slot == SaveManager.AUTOSAVE_SLOT
		if mode == Mode.SAVE:
			var save := UiKit.make_button(tr("SAVE_ACTION_SAVE"), _on_save.bind(slot), Vector2(170.0, 60.0))
			save.disabled = is_auto
			line.add_child(save)
			_buttons["%d_save" % slot] = save
		else:
			var load_button := UiKit.make_button(tr("SAVE_ACTION_LOAD"), _on_load.bind(slot), Vector2(170.0, 60.0))
			load_button.disabled = info.is_empty() or bool(info.get("corrupt", false))
			line.add_child(load_button)
			_buttons["%d_load" % slot] = load_button
		var delete := UiKit.make_button(tr("SAVE_ACTION_DELETE"), _on_delete.bind(slot), Vector2(140.0, 60.0))
		delete.disabled = info.is_empty()
		line.add_child(delete)
		_buttons["%d_delete" % slot] = delete


func _describe(slot: int, info: Dictionary) -> String:
	var title := tr("SAVE_SLOT_AUTO") if slot == SaveManager.AUTOSAVE_SLOT else tr("SAVE_SLOT_N") % slot
	var gold := UiKit.GOLD.to_html(false)
	if info.is_empty():
		return "[color=#%s]%s[/color]\n[color=#888899]%s[/color]" % [gold, title, tr("SAVE_EMPTY")]
	if bool(info.get("corrupt", false)):
		return "[color=#%s]%s[/color]\n[color=#ff6b6b]%s[/color]" % [gold, title, tr("SAVE_CORRUPT")]
	var zone := str(info.get("zone", ""))
	var place := StoryManager.zone_name(StringName(zone)) if zone != "" else tr("SAVE_UNKNOWN_PLACE")
	var chapters := int(info.get("chapters_done", 0))
	var progress := tr("SAVE_PROLOGUE") if chapters == 0 else tr("SAVE_CHAPTERS_DONE") % chapters
	var saved := Time.get_datetime_string_from_unix_time(int(info.get("saved_at_unix", 0)) + _bias(), true).left(16)
	return "[color=#%s]%s[/color] – %s · %s\n%s · %s · %s · [color=#aaaabb]%s[/color]" % [gold, title,
			str(info.get("player_name", "")), progress, place,
			tr("SAVE_PLAY_TIME") % UiKit.format_duration(int(info.get("play_time_sec", 0))),
			tr("SAVE_TEAM_LEVEL") % int(info.get("team_level", 1)), saved]


func _bias() -> int:
	return int(Time.get_time_zone_from_system().get("bias", 0)) * 60


func _on_save(slot: int) -> void:
	if not SaveManager.can_save_now():
		EventBus.toast_requested.emit(tr("SAVE_CANNOT_NOW"))
		return
	var do_save := func() -> void:
		if SaveManager.save_game(slot):
			EventBus.toast_requested.emit(tr("SAVE_DONE") % slot)
		refresh()
	if SaveManager.has_save(slot):
		confirm_box = UiKit.confirm(self, tr("SAVE_CONFIRM_OVERWRITE") % slot, do_save)
	else:
		do_save.call()


func _on_load(slot: int) -> void:
	confirm_box = UiKit.confirm(self, tr("SAVE_CONFIRM_LOAD"), func() -> void:
		if SaveManager.load_game(slot):
			loaded.emit(slot)
			close()
		else:
			EventBus.toast_requested.emit(tr("SAVE_CORRUPT")))


func _on_delete(slot: int) -> void:
	confirm_box = UiKit.confirm(self, tr("SAVE_CONFIRM_DELETE"), func() -> void:
		SaveManager.delete_slot(slot)
		refresh())


func close() -> void:
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if confirm_box and is_instance_valid(confirm_box):
			confirm_box.queue_free()
		else:
			close()


## Sau khi tải: tới map đã lưu (Sảnh nếu thiếu).
static func go_to_loaded_map(tree: SceneTree) -> void:
	tree.paused = false
	var target := GameState.current_map_scene
	if target.is_empty() or not ResourceLoader.exists(target):
		target = DataPaths.HUB_SCENE
	SceneRouter.go_to(target)
