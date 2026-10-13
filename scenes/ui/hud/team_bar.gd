class_name TeamBar
extends Control
## Thanh đội ngoài map (góc trái dưới): 4 chân dung, người dẫn đầu viền vàng, số phím 1–4.
## Dưới mỗi chân dung: thanh máu giữ giữa các trận (người đã ngã thì chân dung xám).
## Bên dưới: Điểm Bí Kỹ (5 viên) và Bí Kỹ đang chờ trận kế tiếp. Bấm/chạm chân dung để đổi người.

signal slot_pressed(index: int)

const SLOT_RADIUS: float = 40.0
const SLOT_GAP: float = 100.0
const LEADER_COLOR := Color("f2d58a")
const POINT_ON := Color("c78bff")
const POINT_OFF := Color(1, 1, 1, 0.18)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	EventBus.leader_changed.connect(func(_i: int) -> void: queue_redraw())
	EventBus.technique_points_changed.connect(func(_v: int) -> void: queue_redraw())
	EventBus.technique_used.connect(func(_id: StringName) -> void: queue_redraw())
	EventBus.team_hp_changed.connect(queue_redraw)


func _gui_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if mouse and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
		var index := int((mouse.position.x) / SLOT_GAP)
		if mouse.position.y < SLOT_RADIUS * 2.0 + 20.0 and index >= 0 and index < GameState.team.size():
			accept_event()
			slot_pressed.emit(index)


func get_slot_center(index: int) -> Vector2:
	return Vector2(SLOT_GAP * index + SLOT_RADIUS + 10.0, SLOT_RADIUS + 10.0)


func _draw() -> void:
	var font := get_theme_default_font()
	var team := GameState.get_team_data()
	for i in team.size():
		var data := team[i]
		var center := get_slot_center(i)
		var skin := data.get_skin(GameState.player_gender if data.id == GameState.PLAYER_CHARACTER_ID else &"default")
		var hp_ratio := GameState.get_hp_ratio(data.id)
		var body := skin.placeholder_color if skin else Color.GRAY
		draw_circle(center, SLOT_RADIUS, body if hp_ratio > 0.0 else body.darkened(0.6))
		var leader := i == GameState.leader_index
		draw_arc(center, SLOT_RADIUS, 0.0, TAU, 40, LEADER_COLOR if leader else Element.color(data.element),
				5.0 if leader else 2.5, true)
		var name_text := GameState.player_name if data.id == GameState.PLAYER_CHARACTER_ID else tr(data.name_key)
		draw_string(font, center + Vector2(-11.0, 12.0), name_text.left(1).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color.WHITE)
		var bar := Rect2(center + Vector2(-SLOT_RADIUS, SLOT_RADIUS + 4.0), Vector2(SLOT_RADIUS * 2.0, 6.0))
		draw_rect(bar, Color(0.1, 0.08, 0.12, 0.9))
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * hp_ratio, bar.size.y)), Color("6fdc8c") if hp_ratio > 0.3 else Color("d64545"))
		draw_string_outline(font, center + Vector2(SLOT_RADIUS - 14.0, -SLOT_RADIUS + 14.0), str(i + 1),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 20, 5, Color.BLACK)
		draw_string(font, center + Vector2(SLOT_RADIUS - 14.0, -SLOT_RADIUS + 14.0), str(i + 1),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	var y := SLOT_RADIUS * 2.0 + 44.0
	draw_string_outline(font, Vector2(10.0, y), tr("HUD_TECHNIQUE_POINTS"), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 5, Color.BLACK)
	draw_string(font, Vector2(10.0, y), tr("HUD_TECHNIQUE_POINTS"), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
	for i in GameState.MAX_TECHNIQUE_POINTS:
		var center := Vector2(150.0 + i * 30.0, y - 8.0)
		draw_colored_polygon(PackedVector2Array([center + Vector2(0, -11), center + Vector2(8, 0),
				center + Vector2(0, 11), center + Vector2(-8, 0)]), POINT_ON if i < GameState.technique_points else POINT_OFF)
	if not GameState.pending_techniques.is_empty():
		var names: Array[String] = []
		for id in GameState.pending_techniques:
			var data := DataPaths.load_character(id)
			if data and data.technique:
				names.append(tr(data.technique.name_key))
		var text := tr("HUD_PENDING_TECHNIQUES") % ", ".join(names)
		draw_string_outline(font, Vector2(10.0, y + 32.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, 5, Color.BLACK)
		draw_string(font, Vector2(10.0, y + 32.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("c78bff"))
