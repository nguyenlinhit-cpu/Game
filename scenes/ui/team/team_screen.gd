class_name TeamScreen
extends VBoxContainer
## Màn đội hình: 5 đội hình lưu sẵn, mỗi đội đúng tối đa 4 ô. Bấm nhân vật bên dưới để thêm vào ô trống
## (đã có thì bỏ ra), bấm ô để bỏ người. "Dùng đội này" đặt làm đội hiện tại (cần ít nhất 1 người).

signal team_applied

var preset_index: int = 0
## Đội đang soạn (chưa lưu).
var draft: Array[StringName] = []

var _preset_buttons: Array[Button] = []
var _slots: HBoxContainer
var _roster: GridContainer
var _message: Label


func _ready() -> void:
	add_theme_constant_override("separation", 16)
	var presets := HBoxContainer.new()
	presets.add_theme_constant_override("separation", 8)
	add_child(presets)
	presets.add_child(UiKit.make_label(tr("TEAM_PRESETS"), 24))
	for i in GameState.TEAM_PRESET_COUNT:
		var button := UiKit.make_button(tr("TEAM_PRESET_N") % (i + 1), select_preset.bind(i), Vector2(150.0, 52.0))
		button.toggle_mode = true
		presets.add_child(button)
		_preset_buttons.append(button)
	_slots = HBoxContainer.new()
	_slots.add_theme_constant_override("separation", 24)
	add_child(_slots)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	add_child(actions)
	actions.add_child(UiKit.make_button(tr("TEAM_SAVE"), save, Vector2(220.0, 56.0)))
	actions.add_child(UiKit.make_button(tr("TEAM_USE"), apply, Vector2(260.0, 56.0)))
	_message = UiKit.make_label("", 22, UiKit.GOLD)
	actions.add_child(_message)
	add_child(UiKit.make_label(tr("TEAM_ROSTER_HINT"), 20, Color(0.8, 0.8, 0.85)))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	_roster = GridContainer.new()
	_roster.columns = 9
	_roster.add_theme_constant_override("h_separation", 12)
	_roster.add_theme_constant_override("v_separation", 12)
	scroll.add_child(_roster)
	select_preset(GameState.active_preset)


func select_preset(index: int) -> void:
	preset_index = clampi(index, 0, GameState.TEAM_PRESET_COUNT - 1)
	draft = GameState.get_preset(preset_index)
	_message.text = tr("TEAM_ACTIVE") if preset_index == GameState.active_preset else ""
	refresh()


## Thêm nhân vật vào ô trống, hoặc bỏ ra nếu đã có. Trả về false nếu đội đã đủ 4.
func toggle_character(id: StringName) -> bool:
	if draft.has(id):
		draft.erase(id)
		refresh()
		return true
	if draft.size() >= GameConfig.MAX_TEAM_SIZE:
		_message.text = tr("TEAM_ERROR_TOO_MANY") % GameConfig.MAX_TEAM_SIZE
		return false
	if not GameState.owned_characters.has(id):
		return false
	draft.append(id)
	refresh()
	return true


func remove_slot(index: int) -> void:
	if index >= 0 and index < draft.size():
		draft.remove_at(index)
		refresh()


## Lưu đội đang soạn vào ô đội hình hiện tại.
func save() -> bool:
	if draft.is_empty():
		_message.text = tr("TEAM_ERROR_EMPTY")
		return false
	var ok := GameState.save_preset(preset_index, draft)
	_message.text = tr("TEAM_SAVED") if ok else tr("TEAM_ERROR_DUPLICATE")
	return ok


## Lưu rồi dùng đội này làm đội hiện tại.
func apply() -> bool:
	if not save() or not GameState.use_preset(preset_index):
		return false
	_message.text = tr("TEAM_ACTIVE")
	team_applied.emit()
	refresh()
	return true


func refresh() -> void:
	if _slots == null:
		return
	for i in _preset_buttons.size():
		_preset_buttons[i].set_pressed_no_signal(i == preset_index)
		_preset_buttons[i].text = tr("TEAM_PRESET_N") % (i + 1) + (" ★" if i == GameState.active_preset else "")
	UiKit.clear(_slots)
	for i in GameConfig.MAX_TEAM_SIZE:
		var data := DataPaths.load_character(draft[i]) if i < draft.size() else null
		var slot := Button.new()
		slot.custom_minimum_size = Vector2(200.0, 230.0)
		slot.focus_mode = Control.FOCUS_NONE
		slot.pressed.connect(remove_slot.bind(i))
		var box := VBoxContainer.new()
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 10)
		slot.add_child(box)
		var portrait := UiKit.Portrait.new(data, 120.0)
		portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(portrait)
		var label := UiKit.make_label(UiKit.character_name(data) if data else tr("TEAM_EMPTY_SLOT"), 22)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(label)
		if data:
			var level := UiKit.make_label("Lv %d" % Progression.get_level(data.id), 18, Color(0.8, 0.8, 0.85))
			level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			level.mouse_filter = Control.MOUSE_FILTER_IGNORE
			box.add_child(level)
		_slots.add_child(slot)
	UiKit.clear(_roster)
	for id in DataPaths.list_character_ids():
		if not GameState.owned_characters.has(id):
			continue
		var data := DataPaths.load_character(id)
		var button := Button.new()
		button.custom_minimum_size = Vector2(150.0, 150.0)
		button.focus_mode = Control.FOCUS_NONE
		button.tooltip_text = UiKit.character_name(data)
		button.pressed.connect(func() -> void: toggle_character(id))
		button.custom_minimum_size = Vector2(150.0, 170.0)
		var box := VBoxContainer.new()
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 6)
		button.add_child(box)
		var portrait := UiKit.Portrait.new(data, 104.0)
		portrait.selected = draft.has(id)
		portrait.dim = not draft.has(id) and draft.size() >= GameConfig.MAX_TEAM_SIZE
		portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(portrait)
		var name_label := UiKit.make_label(UiKit.character_name(data), 18)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(name_label)
		_roster.add_child(button)
