class_name UnitView
extends Node2D
## Hình tạm của một đơn vị trên sân: nhân vật (khối màu + chữ cái) hoặc quái (thân tròn viền màu nguyên tố).
## Quái có thanh máu, thanh Khiên Điểm Yếu (trắng; xám + "PHÁ VỠ" khi vỡ) và hàng biểu tượng điểm yếu.
## Mọi đơn vị có hàng biểu tượng hiệu ứng (rê chuột/chạm để xem mô tả).
## Hiện dấu mục tiêu (chính / bên cạnh), vòng sáng khi tới lượt, nháy khi trúng đòn, mờ dần khi ngã.

const ALLY_RADIUS: float = 52.0
const ENEMY_RADIUS: float = 56.0
const HP_BAR_SIZE := Vector2(150.0, 12.0)
const MARKER_COLOR := Color("f2d58a")
const TURN_COLOR := Color(0.95, 0.84, 0.54, 0.5)
const HP_BACK := Color(0.1, 0.08, 0.12, 0.9)
const HP_FILL := Color("d64545")
const TOUGHNESS_FILL := Color(0.95, 0.95, 1.0)
const TOUGHNESS_BROKEN := Color(0.4, 0.4, 0.45)
const WEAKNESS_RADIUS: float = 12.0
const STATUS_ICON_SIZE: float = 30.0
const STATUS_ICON_GAP: float = 4.0
const BUFF_BORDER := Color("6fdc8c")
const DEBUFF_BORDER := Color("ff6b6b")

enum Marker { NONE, MAIN, ADJACENT }

var unit: BattleUnit
## Vị trí đứng gốc; hoạt ảnh lao/giật luôn quay về đây.
var home_position: Vector2
var marker: Marker = Marker.NONE:
	set(value):
		marker = value
		queue_redraw()
var is_acting: bool = false:
	set(value):
		is_acting = value
		queue_redraw()

var _time: float = 0.0
var _hit_flash: float = 0.0
var _death_tween: Tween


func setup(battle_unit: BattleUnit, at: Vector2) -> void:
	unit = battle_unit
	home_position = at
	position = at
	unit.hp_changed.connect(_on_hp_changed)
	unit.toughness_changed.connect(func(_u: BattleUnit) -> void: queue_redraw())
	unit.status_changed.connect(func(_u: BattleUnit) -> void: queue_redraw())
	unit.died.connect(_on_died)


func get_radius() -> float:
	return ALLY_RADIUS if unit.is_ally() else ENEMY_RADIUS


## Điểm có nằm trên hình này không (để bấm chọn mục tiêu).
func contains_point(global_point: Vector2) -> bool:
	return unit.is_alive() and global_point.distance_to(global_position) <= get_radius() + 24.0


## Bị đánh: nháy trắng, giật lùi về phía sau.
## Khung biểu tượng hiệu ứng thứ `index` (toạ độ trong view).
func get_status_icon_rect(index: int) -> Rect2:
	var count := unit.status_effects.size()
	var total := count * STATUS_ICON_SIZE + maxi(count - 1, 0) * STATUS_ICON_GAP
	var y := get_radius() + (104.0 if not unit.is_ally() else 16.0)
	return Rect2(Vector2(-total * 0.5 + index * (STATUS_ICON_SIZE + STATUS_ICON_GAP), y),
			Vector2.ONE * STATUS_ICON_SIZE)


## Hiệu ứng có biểu tượng dưới điểm (toạ độ toàn cục), null nếu không có.
func get_status_at(global_point: Vector2) -> StatusEffectInstance:
	var local := to_local(global_point)
	for i in unit.status_effects.size():
		if get_status_icon_rect(i).grow(2.0).has_point(local):
			return unit.status_effects[i]
	return null


func play_hit() -> void:
	_hit_flash = 1.0
	var back := -14.0 if unit.is_ally() else 14.0
	var tween := create_tween()
	tween.tween_property(self, "position", home_position + Vector2(back, 0.0), 0.05)
	tween.tween_property(self, "position", home_position, 0.12)


## Ra đòn: lao về phía trước rồi quay lại.
func play_action() -> void:
	var forward := 40.0 if unit.is_ally() else -40.0
	var tween := create_tween()
	tween.tween_property(self, "position", home_position + Vector2(forward, 0.0), 0.12)
	tween.tween_property(self, "position", home_position, 0.2)


func _process(delta: float) -> void:
	_time += delta
	_hit_flash = maxf(_hit_flash - delta * 4.0, 0.0)
	queue_redraw()


func _on_died(_u: BattleUnit) -> void:
	marker = Marker.NONE
	_death_tween = create_tween().set_parallel()
	_death_tween.tween_property(self, "modulate:a", 0.0 if not unit.is_ally() else 0.35, 0.5)
	_death_tween.tween_property(self, "scale", Vector2(1.0, 0.6) if unit.is_ally() else Vector2(0.6, 0.6), 0.5)


## Hồi sinh: hủy hoạt ảnh ngã, hiện lại bình thường.
func _on_hp_changed(_u: BattleUnit) -> void:
	if unit.is_alive() and _death_tween:
		_death_tween.kill()
		_death_tween = null
		modulate.a = 1.0
		scale = Vector2.ONE
	queue_redraw()


func _draw() -> void:
	if unit == null:
		return
	var radius := get_radius()
	if is_acting:
		draw_set_transform(Vector2(0.0, radius * 0.95), 0.0, Vector2(1.0, 0.32))
		draw_circle(Vector2.ZERO, radius * 1.35 + sin(_time * 5.0) * 4.0, TURN_COLOR)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var body := unit.color.lerp(Color.WHITE, _hit_flash * 0.7)
	if unit.is_summon:
		# Vật triệu hồi: hình thoi nhỏ.
		var r := radius * 0.8
		draw_colored_polygon(PackedVector2Array([Vector2(0, -r), Vector2(r, 0), Vector2(0, r), Vector2(-r, 0)]), body)
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(-10.0, 10.0), unit.letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.WHITE)
		draw_string(font, Vector2(-r, r + 22.0), "%s (%d)" % [unit.display_name, unit.summon_turns_left],
				HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	elif unit.is_ally():
		PlaceholderArt.draw_character(self, Vector2.ZERO, radius, body, unit.accent_color, unit.letter, false)
	else:
		draw_set_transform(Vector2(0.0, radius * 0.9), 0.0, Vector2(1.0, 0.3))
		draw_circle(Vector2.ZERO, radius, Color(0.0, 0.0, 0.0, 0.35))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var bob := sin(_time * 3.0 + unit.slot) * 4.0
		draw_circle(Vector2(0.0, bob), radius, body)
		draw_arc(Vector2(0.0, bob), radius, 0.0, TAU, 40, unit.accent_color, 4.0, true)
		draw_circle(Vector2(-radius * 0.35, bob - radius * 0.15), radius * 0.14, Color.WHITE)
		draw_circle(Vector2(radius * 0.35, bob - radius * 0.15), radius * 0.14, Color.WHITE)
		_draw_enemy_hp(radius)
		_draw_toughness(radius)
		_draw_weaknesses(radius)
	_draw_statuses()
	_draw_marker(radius)


func _draw_enemy_hp(radius: float) -> void:
	var font := ThemeDB.fallback_font
	var title := "%s  Lv%d" % [unit.display_name, unit.level]
	var width := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	draw_string_outline(font, Vector2(-width * 0.5, radius + 34.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 6, Color.BLACK)
	draw_string(font, Vector2(-width * 0.5, radius + 34.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
	var bar := Rect2(Vector2(-HP_BAR_SIZE.x * 0.5, radius + 44.0), HP_BAR_SIZE)
	draw_rect(bar, HP_BACK)
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * unit.get_hp_ratio(), bar.size.y)), HP_FILL)
	draw_rect(bar, Color(1, 1, 1, 0.5), false, 1.5)


func _draw_toughness(radius: float) -> void:
	if not unit.has_toughness():
		return
	var bar := Rect2(Vector2(-HP_BAR_SIZE.x * 0.5, radius + 60.0), Vector2(HP_BAR_SIZE.x, 8.0))
	draw_rect(bar, HP_BACK)
	if unit.is_broken:
		draw_rect(bar, TOUGHNESS_BROKEN)
		var font := ThemeDB.fallback_font
		draw_string(font, bar.position + Vector2(bar.size.x + 6.0, 9.0), tr("BATTLE_BROKEN"),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ffcf4d"))
	else:
		var ratio := unit.toughness / unit.max_toughness
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), TOUGHNESS_FILL)


func _draw_weaknesses(radius: float) -> void:
	var count := unit.weaknesses.size()
	var font := ThemeDB.fallback_font
	for i in count:
		var element: int = unit.weaknesses[i]
		var center := Vector2((i - (count - 1) * 0.5) * (WEAKNESS_RADIUS * 2.0 + 6.0), radius + 84.0)
		draw_circle(center, WEAKNESS_RADIUS, Element.color(element))
		draw_arc(center, WEAKNESS_RADIUS, 0.0, TAU, 20, Color.BLACK, 1.5, true)
		var text := Element.letter(element)
		var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		draw_string(font, center + Vector2(-width * 0.5, 5.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.BLACK)


func _draw_statuses() -> void:
	var font := ThemeDB.fallback_font
	for i in unit.status_effects.size():
		var instance := unit.status_effects[i]
		var rect := get_status_icon_rect(i)
		draw_rect(rect, Color(instance.data.icon_color, 0.9))
		var border := BUFF_BORDER if instance.data.kind == StatusEffectData.Kind.BUFF else DEBUFF_BORDER
		draw_rect(rect, border, false, 2.0)
		var width := font.get_string_size(instance.data.icon_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		draw_string(font, rect.get_center() + Vector2(-width * 0.5, 5.0), instance.data.icon_text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.BLACK)
		if instance.stacks > 1:
			draw_string(font, rect.end + Vector2(-10.0, -1.0), str(instance.stacks),
					HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)


func _draw_marker(radius: float) -> void:
	if marker == Marker.NONE:
		return
	var size := 22.0 if marker == Marker.MAIN else 13.0
	var top := Vector2(0.0, -radius - 30.0 + sin(_time * 6.0) * 5.0)
	draw_colored_polygon(PackedVector2Array([
		top + Vector2(-size, -size * 1.2), top + Vector2(size, -size * 1.2), top]), MARKER_COLOR)
	if marker == Marker.MAIN:
		draw_arc(Vector2.ZERO, radius + 10.0, 0.0, TAU, 40, MARKER_COLOR, 3.0, true)
