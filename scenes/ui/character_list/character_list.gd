class_name CharacterListScreen
extends VBoxContainer
## Danh sách nhân vật đã sở hữu, lọc theo nguyên tố, vận mệnh, hạng. Bấm thẻ để mở màn chi tiết.

signal character_selected(character_id: StringName)

const ANY: int = -1

var element_filter: int = ANY
var path_filter: int = ANY
var rarity_filter: int = ANY

var _grid: GridContainer
var _element_option: OptionButton
var _path_option: OptionButton
var _rarity_option: OptionButton


func _ready() -> void:
	add_theme_constant_override("separation", 16)
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation", 12)
	add_child(filters)
	filters.add_child(UiKit.make_label(tr("MENU_FILTER"), 24))
	_element_option = _make_option(filters, tr("FILTER_ALL_ELEMENTS"))
	for element in Element.all():
		_element_option.add_item(tr(Element.name_key(element)), element)
	_path_option = _make_option(filters, tr("FILTER_ALL_PATHS"))
	for path: int in CharacterPath.Type.values():
		_path_option.add_item(tr(CharacterPath.NAME_KEYS[path]), path)
	_rarity_option = _make_option(filters, tr("FILTER_ALL_RARITIES"))
	_rarity_option.add_item("5★", 5)
	_rarity_option.add_item("4★", 4)
	_element_option.item_selected.connect(func(i: int) -> void: set_filters(_element_option.get_item_id(i), path_filter, rarity_filter))
	_path_option.item_selected.connect(func(i: int) -> void: set_filters(element_filter, _path_option.get_item_id(i), rarity_filter))
	_rarity_option.item_selected.connect(func(i: int) -> void: set_filters(element_filter, path_filter, _rarity_option.get_item_id(i)))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 6
	_grid.add_theme_constant_override("h_separation", 16)
	_grid.add_theme_constant_override("v_separation", 16)
	scroll.add_child(_grid)
	refresh()


func _make_option(parent: Node, all_text: String) -> OptionButton:
	var option := OptionButton.new()
	option.focus_mode = Control.FOCUS_NONE
	option.add_item(all_text, ANY)
	parent.add_child(option)
	return option


## Lọc theo nguyên tố / vận mệnh / hạng (ANY = mọi).
func set_filters(element: int, path: int, rarity: int) -> void:
	element_filter = element
	path_filter = path
	rarity_filter = rarity
	refresh()


## Id nhân vật đang hiện (đã lọc), theo thứ tự hiển thị.
func get_visible_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for id in DataPaths.list_character_ids():
		if not GameState.owned_characters.has(id):
			continue
		var data := DataPaths.load_character(id)
		if (element_filter == ANY or data.element == element_filter) and (path_filter == ANY or data.path == path_filter) \
				and (rarity_filter == ANY or data.rarity == rarity_filter):
			result.append(id)
	return result


func refresh() -> void:
	if _grid == null:
		return
	UiKit.clear(_grid)
	for id in get_visible_ids():
		var data := DataPaths.load_character(id)
		var card := Button.new()
		card.custom_minimum_size = Vector2(230.0, 190.0)
		card.focus_mode = Control.FOCUS_NONE
		card.pressed.connect(func() -> void: character_selected.emit(id))
		var box := VBoxContainer.new()
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 10)
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(box)
		var portrait := UiKit.Portrait.new(data, 84.0)
		portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(portrait)
		var name_label := UiKit.make_label(UiKit.character_name(data), 22, Element.color(data.element).lightened(0.3))
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(name_label)
		var info := UiKit.make_label("Lv %d/%d · E%d" % [Progression.get_level(id), Progression.get_level_cap(id),
				GameState.get_eidolon_level(id)], 18, Color(0.85, 0.85, 0.9))
		info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		info.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(info)
		_grid.add_child(card)
