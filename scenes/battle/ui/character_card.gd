class_name CharacterCard
extends Control
## Thẻ nhân vật phe ta ở dưới màn hình: chân dung, tên, máu, năng lượng.
## Năng lượng đầy thì thẻ sáng lên; bấm vào thẻ để dùng Tuyệt kỹ chen lượt.

signal pressed(unit: BattleUnit)

const BACK := Color(0.08, 0.07, 0.14, 0.92)
const BORDER := Color(0.6, 0.6, 0.75, 0.6)
const ACTING_BORDER := Color("f2d58a")
const HP_FILL := Color("5fd38a")
const HP_LOW := Color("e0a040")
const ENERGY_FILL := Color("7fb6ff")
const READY_GLOW := Color("f2d58a")

var unit: BattleUnit
## Phím tắt hiện góc thẻ (1–4).
var hotkey: String = ""
var is_acting: bool = false:
	set(value):
		is_acting = value
		queue_redraw()
var is_queued: bool = false:
	set(value):
		is_queued = value
		queue_redraw()

var _time: float = 0.0


func setup(battle_unit: BattleUnit, key_label: String) -> void:
	unit = battle_unit
	hotkey = key_label
	custom_minimum_size = Vector2(300.0, 150.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	unit.hp_changed.connect(func(_u: BattleUnit) -> void: queue_redraw())
	unit.energy_changed.connect(func(_u: BattleUnit) -> void: queue_redraw())


func _gui_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if mouse and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		pressed.emit(unit)


func _process(delta: float) -> void:
	_time += delta
	if unit and unit.is_ultimate_ready():
		queue_redraw()


func _draw() -> void:
	if unit == null:
		return
	var rect := Rect2(Vector2.ZERO, size)
	var ready := unit.is_ultimate_ready()
	var alpha := 1.0 if unit.is_alive() else 0.45
	draw_rect(rect, Color(BACK, BACK.a * alpha))
	if ready:
		var pulse := 0.5 + 0.5 * sin(_time * 5.0)
		draw_rect(rect.grow(-2.0), Color(READY_GLOW, 0.15 + pulse * 0.25))
	var border := ACTING_BORDER if is_acting else (READY_GLOW if ready else BORDER)
	draw_rect(rect, border, false, 4.0 if is_acting or ready else 2.0)

	var center := Vector2(62.0, 70.0)
	var body := unit.color if unit.is_alive() else Color(0.3, 0.3, 0.3)
	draw_circle(center, 44.0, body)
	draw_arc(center, 44.0, 0.0, TAU, 40, unit.accent_color, 3.0, true)
	var font := get_theme_default_font()
	_text(font, unit.letter, center + Vector2(-12.0, 14.0), 40, Color.WHITE)
	_text(font, hotkey, Vector2(10.0, 28.0), 20, Color(1, 1, 1, 0.6))

	_text(font, unit.display_name, Vector2(120.0, 34.0), 24, Color(1, 1, 1, alpha))
	var hp_rect := Rect2(120.0, 48.0, size.x - 136.0, 16.0)
	draw_rect(hp_rect, Color(0, 0, 0, 0.6))
	draw_rect(Rect2(hp_rect.position, Vector2(hp_rect.size.x * unit.get_hp_ratio(), hp_rect.size.y)),
			HP_FILL if unit.get_hp_ratio() > 0.3 else HP_LOW)
	_text(font, "%d / %d" % [ceili(unit.hp), ceili(unit.get_max_hp())], Vector2(120.0, 90.0), 20, Color(1, 1, 1, alpha))

	var energy_ratio := unit.energy / unit.max_energy if unit.max_energy > 0.0 else 0.0
	var energy_rect := Rect2(120.0, 104.0, size.x - 136.0, 12.0)
	draw_rect(energy_rect, Color(0, 0, 0, 0.6))
	draw_rect(Rect2(energy_rect.position, Vector2(energy_rect.size.x * energy_ratio, energy_rect.size.y)),
			READY_GLOW if ready else ENERGY_FILL)
	if ready:
		_text(font, tr("BATTLE_ULTIMATE_READY") if not is_queued else tr("BATTLE_ULTIMATE_QUEUED"),
				Vector2(120.0, 140.0), 20, READY_GLOW)
	elif not unit.is_alive():
		_text(font, tr("BATTLE_FALLEN"), Vector2(120.0, 140.0), 20, Color(1, 0.5, 0.5))


func _text(font: Font, text: String, pos: Vector2, font_size: int, color: Color) -> void:
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
