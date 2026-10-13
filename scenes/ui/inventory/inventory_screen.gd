class_name InventoryScreen
extends VBoxContainer
## Túi đồ: thẻ theo loại vật phẩm, lưới vật phẩm đang có (số lượng), khung mô tả, nút Dùng cho đồ tiêu hao.
## Bản debug có nút cộng tài nguyên để thử.

const CATEGORY_KEYS: Dictionary = {
	ItemData.Category.CURRENCY: "INV_TAB_CURRENCY", ItemData.Category.EXP: "INV_TAB_EXP",
	ItemData.Category.ASCENSION: "INV_TAB_ASCENSION", ItemData.Category.SIGIL: "INV_TAB_SIGIL",
	ItemData.Category.UPGRADE: "INV_TAB_UPGRADE", ItemData.Category.WISH: "INV_TAB_WISH",
	ItemData.Category.CONSUMABLE: "INV_TAB_CONSUMABLE",
}

var category: ItemData.Category = ItemData.Category.CURRENCY
var selected_item: StringName = &""

var _tab_buttons: Dictionary = {}
var _grid: GridContainer
var _detail_title: Label
var _detail_desc: Label
var _use_button: Button
var _all_items: Array[ItemData] = []


func _ready() -> void:
	add_theme_constant_override("separation", 14)
	for file in DirAccess.get_files_at("res://data/items"):
		var clean := file.trim_suffix(".remap")
		if clean.ends_with(".tres"):
			_all_items.append(load("res://data/items/" + clean) as ItemData)
	# Theo nguyên tố / vận mệnh rồi bậc, để Dấu Ấn cùng vận mệnh nằm cạnh nhau.
	_all_items.sort_custom(func(a: ItemData, b: ItemData) -> bool:
		if a.path != b.path:
			return a.path < b.path
		if a.element != b.element:
			return a.element < b.element
		return a.tier < b.tier if a.tier != b.tier else a.rarity < b.rarity)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	add_child(tabs)
	for key: int in CATEGORY_KEYS:
		var button := UiKit.make_button(tr(CATEGORY_KEYS[key]), show_category.bind(key), Vector2(170.0, 52.0))
		button.toggle_mode = true
		tabs.add_child(button)
		_tab_buttons[key] = button
	if OS.is_debug_build():
		tabs.add_child(UiKit.make_button(tr("INV_DEBUG_GRANT"), func() -> void:
			Progression.debug_grant_resources()
			refresh(), Vector2(240.0, 52.0)))
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 20)
	add_child(body)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 6
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(_grid)
	var detail := UiKit.make_panel(Color(0.1, 0.09, 0.17, 0.95))
	detail.custom_minimum_size = Vector2(460.0, 0.0)
	body.add_child(detail)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	detail.add_child(box)
	_detail_title = UiKit.make_label("", 28, UiKit.GOLD)
	_detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_detail_title)
	_detail_desc = UiKit.make_label("", 22, Color(0.85, 0.85, 0.9))
	_detail_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_detail_desc)
	_use_button = UiKit.make_button(tr("INV_USE"), use_selected, Vector2(200.0, 56.0))
	box.add_child(_use_button)
	EventBus.inventory_changed.connect(func(_id: StringName, _c: int) -> void:
		if is_visible_in_tree():
			refresh())
	show_category(category)


func show_category(value: int) -> void:
	category = value as ItemData.Category
	selected_item = &""
	refresh()


## Vật phẩm đang có thuộc thẻ hiện tại.
func get_visible_items() -> Array[StringName]:
	var result: Array[StringName] = []
	for item in _all_items:
		if item.category == category and GameState.get_item_count(item.id) > 0:
			result.append(item.id)
	return result


func select_item(item_id: StringName) -> void:
	selected_item = item_id
	refresh()


## Dùng 1 vật phẩm đang chọn (Hộp Bí Kỹ: +1 Điểm Bí Kỹ). Trả về false nếu không dùng được.
func use_selected() -> bool:
	var item := UiKit.get_item(selected_item) if selected_item != &"" else null
	if item == null or not item.usable or GameState.get_item_count(selected_item) <= 0:
		return false
	if item.id == &"technique_box":
		if GameState.technique_points >= GameState.MAX_TECHNIQUE_POINTS:
			_detail_desc.text = tr("INV_TECHNIQUE_FULL")
			return false
		GameState.change_technique_points(1)
	GameState.add_item(selected_item, -1)
	refresh()
	return true


func refresh() -> void:
	if _grid == null:
		return
	for key: int in _tab_buttons:
		(_tab_buttons[key] as Button).set_pressed_no_signal(key == category)
	UiKit.clear(_grid)
	var visible_items := get_visible_items()
	if selected_item == &"" or not visible_items.has(selected_item):
		selected_item = visible_items[0] if not visible_items.is_empty() else &""
	for item_id in visible_items:
		var item := UiKit.get_item(item_id)
		var button := Button.new()
		button.custom_minimum_size = Vector2(150.0, 150.0)
		button.focus_mode = Control.FOCUS_NONE
		button.toggle_mode = true
		button.set_pressed_no_signal(item_id == selected_item)
		button.pressed.connect(select_item.bind(item_id))
		button.add_child(ItemIcon.new(item, GameState.get_item_count(item_id)))
		_grid.add_child(button)
	if visible_items.is_empty():
		_grid.add_child(UiKit.make_label(tr("INV_EMPTY"), 24, Color(0.7, 0.7, 0.75)))
	var selected := UiKit.get_item(selected_item) if selected_item != &"" else null
	_detail_title.text = "%s  ×%d" % [tr(selected.name_key), GameState.get_item_count(selected_item)] if selected else ""
	_detail_desc.text = tr(selected.desc_key) if selected else ""
	_use_button.visible = selected != null and selected.usable


## Biểu tượng tạm của vật phẩm: ô màu theo hạng, chữ viết tắt, số lượng.
class ItemIcon:
	extends Control
	const RARITY_COLORS: Array[Color] = [Color(0.5, 0.5, 0.55), Color(0.45, 0.7, 0.5), Color(0.4, 0.6, 0.9),
			Color(0.7, 0.45, 0.9), Color(0.95, 0.75, 0.35)]
	var item: ItemData
	var count: int

	func _init(p_item: ItemData, p_count: int) -> void:
		item = p_item
		count = p_count
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func _draw() -> void:
		var rect := Rect2(Vector2(14.0, 10.0), size - Vector2(28.0, 40.0))
		draw_rect(rect, RARITY_COLORS[clampi(item.rarity - 1, 0, 4)].darkened(0.3))
		draw_rect(rect.grow(-10.0), item.icon_color)
		var font := get_theme_default_font()
		var width := font.get_string_size(item.icon_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 30).x
		draw_string(font, rect.get_center() + Vector2(-width * 0.5, 10.0), item.icon_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 30,
				Color.BLACK)
		var text := str(count)
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
		draw_string(font, Vector2(size.x * 0.5 - w * 0.5, size.y - 8.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
