class_name UnitView
extends Node2D
## Hình tạm của một đơn vị trên sân: nhân vật (khối màu + chữ cái) hoặc quái (thân tròn viền màu nguyên tố).
## Quái có thanh máu, thanh Khiên Điểm Yếu (trắng; xám + "PHÁ VỠ" khi vỡ) và hàng biểu tượng điểm yếu.
## Mọi đơn vị có hàng biểu tượng hiệu ứng (rê chuột/chạm để xem mô tả).
## Hiện dấu mục tiêu (chính / bên cạnh), vòng sáng khi tới lượt, nháy khi trúng đòn, mờ dần khi ngã.
## Quái đang tích tụ đòn: biểu tượng cảnh báo "!" + số lượt còn lại; phe ta sắp trúng đòn đó: dấu cảnh báo đỏ.
## Boss/tinh anh vẽ to hơn (EnemyData.size_scale), boss hiện giai đoạn; quái không bị nhắm được thì mờ đi.
## Phase 13: thân (sprite thật nếu có SpriteFrames "battle", không thì hình tạm) là node con mang shader unit_fx:
## viền khi được chọn, nháy trắng khi trúng đòn, tan biến khi quái ngã. Hành động phát hoạt ảnh tương ứng
## (attack / skill / ultimate / hit / down / victory, boss giai đoạn n thêm "-p<n>").

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
const WARNING_COLOR := Color("ff4d4d")
const WARNING_GLOW := Color(1.0, 0.85, 0.3)

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
## Phe ta: sắp trúng một đòn đang tích tụ của quái.
var threatened: bool = false

var _time: float = 0.0
var _hit_flash: float = 0.0
var _death_tween: Tween
## Thân: hình tạm vẽ trong _draw_body, hoặc sprite thật.
var body: Node2D
var sprite: AnimatedSprite2D
var fx_material: ShaderMaterial

const UNIT_FX_SHADER: String = "res://assets/vfx/shaders/unit_fx.gdshader"
const ACTION_ANIMS: Dictionary = {0: "attack", 1: "skill", 2: "ultimate", 3: "attack"}


func setup(battle_unit: BattleUnit, at: Vector2) -> void:
	unit = battle_unit
	home_position = at
	position = at
	unit.hp_changed.connect(_on_hp_changed)
	unit.toughness_changed.connect(func(_u: BattleUnit) -> void: queue_redraw())
	unit.status_changed.connect(func(_u: BattleUnit) -> void: queue_redraw())
	unit.died.connect(_on_died)
	fx_material = ShaderMaterial.new()
	fx_material.shader = load(UNIT_FX_SHADER)
	body = Node2D.new()
	body.name = "Body"
	add_child(body)
	body.draw.connect(_draw_body)
	# Thanh máu, biểu tượng, dấu mục tiêu (vẽ ở node cha) luôn nằm trên thân.
	body.show_behind_parent = true
	var frames := ArtLibrary.character_frames(unit.character, "battle") if unit.character \
			else ArtLibrary.enemy_frames(unit.enemy, "battle")
	if frames and not unit.is_summon:
		sprite = ArtLibrary.make_sprite(frames, get_radius() * 4.2)
		sprite.position = Vector2(0.0, get_radius() * 0.9)
		sprite.material = fx_material
		if unit.is_ally():
			sprite.flip_h = false
		body.add_child(sprite)
		sprite.animation_finished.connect(_on_sprite_finished)
		_play_anim("idle")
		# Tải sẵn hiệu ứng kỹ năng vẽ tay để lần ra đòn đầu tiên không bị khựng.
		if unit.character:
			ArtLibrary.vfx_frames(unit.character)
	else:
		body.material = fx_material


## Tên hoạt ảnh theo giai đoạn boss ("idle-p2"...), thiếu thì dùng bản thường.
func _anim_name(action: String) -> String:
	if unit.phase_index > 0 and sprite and sprite.sprite_frames.has_animation("%s-p%d" % [action, unit.phase_index + 1]):
		return "%s-p%d" % [action, unit.phase_index + 1]
	return action


func _play_anim(action: String) -> void:
	if sprite:
		ArtLibrary.play(sprite, _anim_name(action))


func _on_sprite_finished() -> void:
	if unit.is_alive() and not sprite.sprite_frames.get_animation_loop(sprite.animation):
		_play_anim("idle")


## Thắng trận: nhân vật còn sống phát hoạt ảnh thắng.
func play_victory() -> void:
	if unit.is_alive():
		_play_anim("victory")


func get_radius() -> float:
	return ALLY_RADIUS if unit.is_ally() else ENEMY_RADIUS * unit.size_scale


## Điểm có nằm trên hình này không (để bấm chọn mục tiêu).
func contains_point(global_point: Vector2) -> bool:
	return unit.is_targetable() and global_point.distance_to(global_position) <= get_radius() + 24.0


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
	if unit.is_alive():
		_play_anim("hit")
	var back := -14.0 if unit.is_ally() else 14.0
	var tween := create_tween()
	tween.tween_property(self, "position", home_position + Vector2(back, 0.0), 0.05)
	tween.tween_property(self, "position", home_position, 0.12)


## Ra đòn: lao về phía trước rồi quay lại.
func play_action(kind: int = 0) -> void:
	var action: String = ACTION_ANIMS.get(kind, "attack")
	_play_anim(action)
	_play_cast_vfx(action)
	var forward := 40.0 if unit.is_ally() else -40.0
	var tween := create_tween()
	tween.tween_property(self, "position", home_position + Vector2(forward, 0.0), 0.12)
	tween.tween_property(self, "position", home_position, 0.2)


## Lớp cast vẽ tay ("<hành động>-cast"): khung trùng khung sprite trận nên đặt chồng đúng lên sprite.
func _play_cast_vfx(action: String) -> void:
	var frames := ArtLibrary.vfx_frames(unit.character) if unit.character else null
	if sprite == null or frames == null or not frames.has_animation(action + "-cast"):
		return
	var cast := AnimatedSprite2D.new()
	cast.name = "CastVfx"
	cast.sprite_frames = frames
	cast.position = sprite.position
	cast.scale = sprite.scale
	cast.offset = sprite.offset
	cast.flip_h = sprite.flip_h
	body.add_child(cast)
	cast.play(action + "-cast")
	cast.animation_finished.connect(cast.queue_free)


func _process(delta: float) -> void:
	_time += delta
	_hit_flash = maxf(_hit_flash - delta * 4.0, 0.0)
	if fx_material:
		fx_material.set_shader_parameter("flash", _hit_flash * 0.8)
		fx_material.set_shader_parameter("outline_width", 3.0 if marker != Marker.NONE and unit.is_alive() else 0.0)
	queue_redraw()
	if body:
		body.queue_redraw()


func _on_died(_u: BattleUnit) -> void:
	marker = Marker.NONE
	_play_anim("down")
	_death_tween = create_tween().set_parallel()
	if not unit.is_ally():
		_death_tween.tween_method(func(v: float) -> void: fx_material.set_shader_parameter("dissolve", v), 0.0, 1.0, 0.6)
	_death_tween.tween_property(self, "modulate:a", 0.0 if not unit.is_ally() else 0.35, 0.5)
	_death_tween.tween_property(self, "scale", Vector2(1.0, 0.6) if unit.is_ally() else Vector2(0.6, 0.6), 0.5)


## Hồi sinh: hủy hoạt ảnh ngã, hiện lại bình thường.
func _on_hp_changed(_u: BattleUnit) -> void:
	if unit.is_alive() and _death_tween:
		_death_tween.kill()
		_death_tween = null
		modulate.a = 1.0
		scale = Vector2.ONE
		fx_material.set_shader_parameter("dissolve", 0.0)
		_play_anim("idle")
	queue_redraw()


func _draw() -> void:
	if unit == null:
		return
	var radius := get_radius()
	if is_acting:
		draw_set_transform(Vector2(0.0, radius * 0.95), 0.0, Vector2(1.0, 0.32))
		draw_circle(Vector2.ZERO, radius * 1.35 + sin(_time * 5.0) * 4.0, TURN_COLOR)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if not unit.is_ally() and not unit.is_summon:
		_draw_enemy_hp(radius)
		_draw_toughness(radius)
		_draw_weaknesses(radius)
		_draw_charge(radius)
	_draw_statuses()
	_draw_marker(radius)
	if threatened and unit.is_alive():
		_draw_threat(radius)


func _draw_enemy_hp(radius: float) -> void:
	var font := ThemeDB.fallback_font
	var title := "%s  Lv%d" % [unit.display_name, unit.level]
	if unit.enemy and not unit.enemy.phases.is_empty():
		title += "  [%s]" % (tr("BATTLE_PHASE_TITLE") % (unit.phase_index + 1))
	var width := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	draw_string_outline(font, Vector2(-width * 0.5, radius + 34.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 6, Color.BLACK)
	draw_string(font, Vector2(-width * 0.5, radius + 34.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
	var bar_size := HP_BAR_SIZE * Vector2(maxf(unit.size_scale, 1.0), 1.0)
	var bar := Rect2(Vector2(-bar_size.x * 0.5, radius + 44.0), bar_size)
	draw_rect(bar, HP_BACK)
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * unit.get_hp_ratio(), bar.size.y)), HP_FILL)
	# Vạch ngưỡng giai đoạn kế tiếp của boss.
	var next := unit.get_next_phase()
	if next and next.hp_threshold > 0.0:
		var x := bar.position.x + bar.size.x * next.hp_threshold
		draw_line(Vector2(x, bar.position.y - 3.0), Vector2(x, bar.end.y + 3.0), Color("ffcf4d"), 2.0)
	draw_rect(bar, Color(1, 1, 1, 0.5), false, 1.5)
	if unit.untargetable:
		var label := tr("BATTLE_UNTARGETABLE")
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		draw_string_outline(font, Vector2(-w * 0.5, -radius - 14.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, 5, Color.BLACK)
		draw_string(font, Vector2(-w * 0.5, -radius - 14.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("c7b8ff"))


func _draw_toughness(radius: float) -> void:
	if not unit.has_toughness():
		return
	var width := HP_BAR_SIZE.x * maxf(unit.size_scale, 1.0)
	var bar := Rect2(Vector2(-width * 0.5, radius + 60.0), Vector2(width, 8.0))
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


## Bảng cảnh báo trên đầu quái đang tích tụ đòn: "!" + tên đòn + số lượt còn lại.
func _draw_charge(radius: float) -> void:
	if unit.charge == null or not unit.is_alive():
		return
	var pulse := 0.5 + 0.5 * sin(_time * 8.0)
	var font := ThemeDB.fallback_font
	var label := "%s  %d" % [tr(unit.charge.action.skill.name_key), unit.charge.turns_left]
	var text_width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	var box := Rect2(Vector2(-(text_width + 52.0) * 0.5, -radius - 74.0), Vector2(text_width + 52.0, 38.0))
	draw_rect(box, Color(0.12, 0.02, 0.02, 0.85))
	draw_rect(box, WARNING_GLOW.lerp(WARNING_COLOR, pulse), false, 3.0)
	var icon := box.position + Vector2(20.0, 19.0)
	draw_circle(icon, 14.0 + pulse * 2.0, WARNING_GLOW.lerp(WARNING_COLOR, pulse))
	draw_string(font, icon + Vector2(-4.5, 9.0), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.BLACK)
	draw_string(font, box.position + Vector2(40.0, 27.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)


## Dấu cảnh báo trên nhân vật phe ta sắp trúng đòn tích tụ.
func _draw_threat(radius: float) -> void:
	var pulse := 0.5 + 0.5 * sin(_time * 8.0)
	draw_arc(Vector2.ZERO, radius + 14.0 + pulse * 4.0, 0.0, TAU, 40, Color(WARNING_COLOR, 0.5 + 0.5 * pulse), 4.0, true)
	var font := ThemeDB.fallback_font
	var at := Vector2(-radius - 26.0, -radius + 4.0)
	draw_circle(at, 15.0, WARNING_COLOR)
	draw_string(font, at + Vector2(-4.5, 9.0), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.WHITE)


func _draw_marker(radius: float) -> void:
	if marker == Marker.NONE:
		return
	var size := 22.0 if marker == Marker.MAIN else 13.0
	var top := Vector2(0.0, -radius - 30.0 + sin(_time * 6.0) * 5.0)
	draw_colored_polygon(PackedVector2Array([
		top + Vector2(-size, -size * 1.2), top + Vector2(size, -size * 1.2), top]), MARKER_COLOR)
	if marker == Marker.MAIN:
		draw_arc(Vector2.ZERO, radius + 10.0, 0.0, TAU, 40, MARKER_COLOR, 3.0, true)

## Thân hình tạm (vẽ trên node con "Body" để shader nháy / tan biến không ăn vào thanh máu, chữ).
func _draw_body() -> void:
	if unit == null:
		return
	var radius := get_radius()
	var canvas := body
	if sprite:
		# Sprite thật: chỉ vẽ bóng đổ dưới chân.
		canvas.draw_set_transform(Vector2(0.0, radius * 0.9), 0.0, Vector2(1.0, 0.3))
		canvas.draw_circle(Vector2.ZERO, radius, Color(0.0, 0.0, 0.0, 0.35))
		canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	var fill := unit.color.lerp(Color.WHITE, _hit_flash * 0.7)
	if unit.is_summon:
		# Vật triệu hồi: hình thoi nhỏ.
		var r := radius * 0.8
		canvas.draw_colored_polygon(PackedVector2Array([Vector2(0, -r), Vector2(r, 0), Vector2(0, r), Vector2(-r, 0)]), fill)
		var font := ThemeDB.fallback_font
		canvas.draw_string(font, Vector2(-10.0, 10.0), unit.letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.WHITE)
		canvas.draw_string(font, Vector2(-r, r + 22.0), "%s (%d)" % [unit.display_name, unit.summon_turns_left],
				HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	elif unit.is_ally():
		PlaceholderArt.draw_character(canvas, Vector2.ZERO, radius, fill, unit.accent_color, unit.letter, false)
	else:
		canvas.draw_set_transform(Vector2(0.0, radius * 0.9), 0.0, Vector2(1.0, 0.3))
		canvas.draw_circle(Vector2.ZERO, radius, Color(0.0, 0.0, 0.0, 0.35))
		canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var bob := sin(_time * 3.0 + unit.slot) * 4.0
		if unit.untargetable:
			fill = Color(fill, 0.35)
		canvas.draw_circle(Vector2(0.0, bob), radius, fill)
		canvas.draw_arc(Vector2(0.0, bob), radius, 0.0, TAU, 40, unit.accent_color, 4.0, true)
		canvas.draw_circle(Vector2(-radius * 0.35, bob - radius * 0.15), radius * 0.14, Color.WHITE)
		canvas.draw_circle(Vector2(radius * 0.35, bob - radius * 0.15), radius * 0.14, Color.WHITE)
