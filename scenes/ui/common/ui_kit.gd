class_name UiKit
extends RefCounted
## Hàm dựng giao diện dùng chung cho các màn menu (nút, khung, nhãn, hiển thị chi phí).

const PANEL_BG := Color(0.07, 0.06, 0.13, 0.97)
const PANEL_BORDER := Color(0.95, 0.84, 0.54, 0.8)
const OK_COLOR := Color("6fdc8c")
const BAD_COLOR := Color("ff6b6b")
const GOLD := Color("f2d58a")

static var _items: Dictionary = {}


static func panel_style(bg: Color = PANEL_BG, border: Color = PANEL_BORDER, radius: int = 14) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(16)
	return style


static func make_panel(bg: Color = PANEL_BG) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", panel_style(bg))
	return panel


static func make_button(text: String, callback: Callable = Callable(), min_size := Vector2(0.0, 56.0)) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	button.focus_mode = Control.FOCUS_NONE
	if callback.is_valid():
		button.pressed.connect(callback)
	return button


static func make_label(text: String, size: int = 24, color: Color = Color.WHITE) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


static func make_rich(size: int = 22) -> RichTextLabel:
	var rich := RichTextLabel.new()
	rich.bbcode_enabled = true
	rich.fit_content = true
	rich.scroll_active = false
	rich.add_theme_font_size_override("normal_font_size", size)
	rich.custom_minimum_size = Vector2(200.0, 0.0)
	rich.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return rich


static func clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


static func get_item(item_id: StringName) -> ItemData:
	if not _items.has(item_id):
		_items[item_id] = load("res://data/items/%s.tres" % item_id) as ItemData
	return _items[item_id]


static func item_name(item_id: StringName) -> String:
	var item := get_item(item_id)
	return TranslationServer.translate(item.name_key) if item else String(item_id)


## Chi phí dạng BBCode: "Xu Aether 1500/2300" (đỏ nếu thiếu).
static func format_cost(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for item_id: Variant in cost:
		var need := int(cost[item_id])
		var have := GameState.get_item_count(StringName(str(item_id)))
		var color := OK_COLOR if have >= need else BAD_COLOR
		parts.append("%s [color=#%s]%d[/color]/%d" % [item_name(StringName(str(item_id))), color.to_html(false), have, need])
	return "  ·  ".join(parts)


## Tên hiển thị của nhân vật (nhân vật chính dùng tên người chơi đặt).
static func character_name(data: CharacterData) -> String:
	if data.id == GameState.PLAYER_CHARACTER_ID:
		return GameState.player_name
	return TranslationServer.translate(data.name_key)


static func character_color(data: CharacterData) -> Color:
	var skin := data.get_skin(GameState.player_gender if data.id == GameState.PLAYER_CHARACTER_ID else &"default")
	return skin.placeholder_color if skin else Color.GRAY


## Ô chân dung tạm (khối màu + chữ cái + viền nguyên tố) dùng trong danh sách và đội hình.
class Portrait:
	extends Control
	var data: CharacterData
	var dim: bool = false
	var selected: bool = false

	func _init(character: CharacterData, portrait_size: float = 96.0) -> void:
		data = character
		custom_minimum_size = Vector2.ONE * portrait_size
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if data == null:
			draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.06))
			draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.25), false, 2.0)
			return
		var color := UiKit.character_color(data)
		draw_rect(Rect2(Vector2.ZERO, size), color.darkened(0.5) if dim else color)
		draw_rect(Rect2(Vector2.ZERO, size), UiKit.GOLD if selected else Element.color(data.element), false,
				5.0 if selected else 3.0)
		var font := get_theme_default_font()
		var letter := UiKit.character_name(data).left(1).to_upper()
		draw_string(font, Vector2(size.x * 0.5 - 14.0, size.y * 0.5 + 16.0), letter, HORIZONTAL_ALIGNMENT_LEFT, -1,
				int(size.y * 0.45), Color.WHITE)
		draw_string(font, Vector2(6.0, 22.0), "★".repeat(data.rarity), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UiKit.GOLD)


## Chấm đỏ góc trên-phải của `parent` (báo có thưởng chưa nhận). Bật/tắt bằng visible.
static func attach_red_dot(parent: Control) -> Control:
	var dot := RedDot.new()
	dot.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	dot.offset_left = -22.0
	dot.offset_top = 4.0
	dot.offset_right = -4.0
	dot.offset_bottom = 22.0
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.hide()
	parent.add_child(dot)
	return dot


class RedDot extends Control:
	func _draw() -> void:
		var radius := minf(size.x, size.y) * 0.5
		draw_circle(size * 0.5, radius, Color("ff4d4d"))
		draw_arc(size * 0.5, radius, 0.0, TAU, 24, Color.WHITE, 2.0, true)
