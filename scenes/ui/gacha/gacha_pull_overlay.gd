class_name GachaPullOverlay
extends Control
## Màn kết quả quay, phủ toàn màn hình:
##   1. Sao băng 2D – mỗi lượt một vệt, màu theo độ hiếm (xanh 3★, tím 4★, vàng 5★), cuối cùng lóe màu cao nhất.
##   2. Màn nhận nhân vật (4★ trở lên): tranh gacha, tên, hạng, MỚI / Tinh Mệnh / Bụi Sao. Bấm để sang người sau.
##   3. Tổng kết: lưới mọi kết quả.
## "Bỏ qua" nhảy thẳng tới tổng kết; bấm nền ở bước 1 sang bước 2.

signal closed

enum Stage { METEORS, REVEAL, SUMMARY }

const METEOR_TIME: float = 2.6
const FLASH_TIME: float = 0.35
const RARITY_COLORS: Dictionary = {3: Color("4fa3ff"), 4: Color("b46bff"), 5: Color("ffd257")}

var stage: Stage = Stage.METEORS
var results: Array[Dictionary] = []
## Chỉ số (trong results) các kết quả có màn nhận nhân vật.
var reveal_queue: Array[int] = []
var reveal_index: int = -1

var _time: float = 0.0
var _stars: Array[Vector3] = []
var _meteors: Array[Dictionary] = []
var _skip_button: Button
var _card: CharacterRevealCard
var _summary: VBoxContainer


static func rarity_color(rarity: int) -> Color:
	return RARITY_COLORS.get(rarity, Color.WHITE)


func setup(pull_results: Array[Dictionary]) -> void:
	results = pull_results
	for i in results.size():
		if int(results[i]["rarity"]) >= 4:
			reveal_queue.append(i)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	top_level = true
	position = Vector2.ZERO
	size = get_viewport_rect().size
	mouse_filter = Control.MOUSE_FILTER_STOP
	var random := RandomNumberGenerator.new()
	random.seed = 7
	for i in 140:
		_stars.append(Vector3(random.randf() * size.x, random.randf() * size.y, random.randf() * TAU))
	# Vệt hiếm nhất bay sau cùng và to nhất.
	var order := range(results.size())
	order.sort_custom(func(a: int, b: int) -> bool: return int(results[a]["rarity"]) < int(results[b]["rarity"]))
	for k in order.size():
		var rarity := int(results[order[k]]["rarity"])
		var start := Vector2(size.x * random.randf_range(0.45, 1.15), -random.randf_range(40.0, 260.0))
		_meteors.append({
			"start": start, "dir": Vector2(-1.0, 0.62).normalized(), "speed": random.randf_range(1500.0, 1900.0),
			"delay": 0.15 + k * (1.2 / maxf(order.size(), 1.0)), "rarity": rarity,
			"width": 4.0 + (rarity - 3) * 3.0, "length": 260.0 + (rarity - 3) * 120.0,
		})
	AudioManager.play_sfx(StringName("gacha_%d" % get_best_rarity()))
	_skip_button = UiKit.make_button(tr("UI_SKIP"), skip, Vector2(200.0, 56.0))
	_skip_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_KEEP_SIZE, 30)
	_skip_button.position = Vector2(size.x - 230.0, 30.0)
	add_child(_skip_button)


func get_best_rarity() -> int:
	var best := 3
	for result in results:
		best = maxi(best, int(result["rarity"]))
	return best


func _process(delta: float) -> void:
	_time += delta
	if stage == Stage.METEORS:
		queue_redraw()
		if _time >= METEOR_TIME:
			_end_meteors()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.02, 0.06, 0.97 if stage == Stage.METEORS else 1.0))
	for star in _stars:
		var alpha := 0.35 + 0.35 * sin(_time * 2.0 + star.z)
		draw_circle(Vector2(star.x, star.y), 1.6, Color(1, 1, 1, alpha))
	if stage != Stage.METEORS:
		return
	for meteor in _meteors:
		var t := _time - float(meteor["delay"])
		if t <= 0.0:
			continue
		var dir: Vector2 = meteor["dir"]
		var head: Vector2 = meteor["start"] + dir * float(meteor["speed"]) * t
		var color := rarity_color(int(meteor["rarity"]))
		var length: float = meteor["length"]
		var points := PackedVector2Array()
		var colors := PackedColorArray()
		for s in 9:
			var f := s / 8.0
			points.append(head - dir * length * f)
			colors.append(Color(color.lightened(0.4 * (1.0 - f)), (1.0 - f) * 0.95))
		draw_polyline_colors(points, colors, float(meteor["width"]), true)
		draw_circle(head, float(meteor["width"]) * 2.2, Color(color, 0.25))
		draw_circle(head, float(meteor["width"]) * 1.1, Color.WHITE)
	# Lóe màu của kết quả hiếm nhất.
	var flash := clampf((_time - (METEOR_TIME - FLASH_TIME)) / FLASH_TIME, 0.0, 1.0)
	if flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(rarity_color(get_best_rarity()), flash * 0.85))


func _gui_input(event: InputEvent) -> void:
	var pressed: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	pressed = pressed or (event is InputEventScreenTouch and event.pressed)
	if not pressed:
		return
	accept_event()
	advance()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		advance()
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		if stage == Stage.SUMMARY:
			close()
		else:
			skip()


## Sang bước kế tiếp (bấm nền / Enter).
func advance() -> void:
	match stage:
		Stage.METEORS:
			_end_meteors()
		Stage.REVEAL:
			_next_reveal()


## Bỏ qua mọi hiệu ứng, tới thẳng tổng kết.
func skip() -> void:
	if stage != Stage.SUMMARY:
		_show_summary()


func _end_meteors() -> void:
	if stage != Stage.METEORS:
		return
	stage = Stage.REVEAL
	queue_redraw()
	_next_reveal()


func _next_reveal() -> void:
	reveal_index += 1
	if _card:
		_card.queue_free()
		_card = null
	if reveal_index >= reveal_queue.size():
		_show_summary()
		return
	_card = CharacterRevealCard.new(results[reveal_queue[reveal_index]])
	_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_card)
	move_child(_skip_button, -1)


func _show_summary() -> void:
	stage = Stage.SUMMARY
	queue_redraw()
	if _card:
		_card.queue_free()
		_card = null
	_skip_button.hide()
	_summary = VBoxContainer.new()
	_summary.add_theme_constant_override("separation", 24)
	_summary.alignment = BoxContainer.ALIGNMENT_CENTER
	_summary.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 60)
	add_child(_summary)
	var title := UiKit.make_label(tr("GACHA_RESULTS"), 40, UiKit.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_summary.add_child(title)
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_summary.add_child(grid)
	for result in results:
		grid.add_child(make_result_tile(result))
	var close_button := UiKit.make_button(tr("UI_CLOSE"), close, Vector2(260.0, 64.0))
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_summary.add_child(close_button)


func close() -> void:
	closed.emit()
	queue_free()


## Ô kết quả: viền màu theo hạng, tên nhân vật / vật phẩm, ghi chú MỚI / Tinh Mệnh / Bụi Sao.
static func make_result_tile(result: Dictionary) -> PanelContainer:
	var rarity := int(result["rarity"])
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(250.0, 150.0)
	panel.add_theme_stylebox_override("panel", UiKit.panel_style(Color(rarity_color(rarity).darkened(0.75), 0.95),
			rarity_color(rarity), 10))
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)
	box.add_child(UiKit.make_label("★".repeat(rarity), 22, rarity_color(rarity)))
	if rarity == 3:
		for line in Loot.describe(result.get("items", {})):
			box.add_child(UiKit.make_label(line, 22))
		return panel
	var data := GachaManager.get_character(result["character"])
	box.add_child(UiKit.make_label(UiKit.character_name(data) if data else String(result["character"]), 26))
	var note := UiKit.make_label(describe_grant(result), 20, UiKit.OK_COLOR if bool(result.get("new", false)) else UiKit.GOLD)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(note)
	return panel


## "MỚI" / "Tinh Mệnh 3" / "Tinh Mệnh tối đa", kèm "+40 Bụi Sao" khi trùng.
static func describe_grant(result: Dictionary) -> String:
	if bool(result.get("new", false)):
		return TranslationServer.translate("GACHA_NEW")
	var parts: Array[String] = []
	if bool(result.get("overflow", false)):
		parts.append(TranslationServer.translate("GACHA_EIDOLON_MAX"))
	else:
		parts.append(TranslationServer.translate("GACHA_EIDOLON_UP") % int(result.get("eidolon", 0)))
	if int(result.get("stardust", 0)) > 0:
		parts.append("+%d %s" % [int(result["stardust"]), UiKit.item_name(&"stardust")])
	return " · ".join(parts)


## Màn nhận nhân vật: tranh gacha (tạm vẽ bằng khối màu nếu chưa có hình) + thông tin.
class CharacterRevealCard:
	extends Control
	var result: Dictionary
	var data: CharacterData
	var _time: float = 0.0

	func _init(pull_result: Dictionary) -> void:
		result = pull_result
		data = GachaManager.get_character(result["character"])

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		if data == null:
			return
		var rarity := int(result["rarity"])
		var glow := GachaPullOverlay.rarity_color(rarity)
		var appear := clampf(_time / 0.35, 0.0, 1.0)
		var art_rect := Rect2(size.x * 0.08, size.y * 0.08, size.x * 0.48, size.y * 0.84)
		art_rect.position.x -= (1.0 - appear) * 120.0
		GachaArt.draw_art(self, art_rect, data, appear)
		var font := get_theme_default_font()
		var x := size.x * 0.6
		var y := size.y * 0.32
		draw_string(font, Vector2(x, y), "★".repeat(rarity), HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color(glow, appear))
		draw_string(font, Vector2(x, y + 90.0), UiKit.character_name(data), HORIZONTAL_ALIGNMENT_LEFT, -1, 72,
				Color(1, 1, 1, appear))
		var info := "%s  ·  %s" % [TranslationServer.translate(Element.name_key(data.element)),
				TranslationServer.translate(CharacterPath.name_key(data.path))]
		draw_string(font, Vector2(x, y + 150.0), info, HORIZONTAL_ALIGNMENT_LEFT, -1, 30,
				Color(Element.color(data.element).lightened(0.3), appear))
		var note := GachaPullOverlay.describe_grant(result)
		draw_string(font, Vector2(x, y + 220.0), note, HORIZONTAL_ALIGNMENT_LEFT, size.x - x - 40.0, 34,
				Color(UiKit.OK_COLOR if bool(result.get("new", false)) else UiKit.GOLD, appear))
		if bool(result.get("lost", false)):
			draw_string(font, Vector2(x, y + 275.0), TranslationServer.translate("GACHA_LOST_5050"),
					HORIZONTAL_ALIGNMENT_LEFT, size.x - x - 40.0, 24, Color(0.8, 0.8, 0.85, appear))
		draw_string(font, Vector2(x, size.y * 0.88), TranslationServer.translate("GACHA_TAP_CONTINUE"),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(1, 1, 1, 0.4 + 0.3 * sin(_time * 3.0)))
