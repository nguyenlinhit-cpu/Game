class_name GachaArt
extends RefCounted
## Tranh gacha tạm (Phase 13 thay bằng CharacterSkin.gacha_art / BannerData.art):
## nền chuyển màu theo nguyên tố, bóng nhân vật bằng khối màu, chữ cái đầu tên.


## Vẽ tranh gacha của nhân vật vào `rect` trên `canvas`.
static func draw_art(canvas: CanvasItem, rect: Rect2, data: CharacterData, alpha: float = 1.0) -> void:
	var skin := data.get_skin(GameState.player_gender if data.id == GameState.PLAYER_CHARACTER_ID else &"default")
	if skin and skin.gacha_art:
		canvas.draw_texture_rect(skin.gacha_art, rect, false, Color(1, 1, 1, alpha))
		return
	var element_color := Element.color(data.element)
	var body := skin.placeholder_color if skin else Color.GRAY
	var accent := skin.accent_color if skin else Color.WHITE
	draw_gradient(canvas, rect, Color(element_color.darkened(0.2), alpha), Color(element_color.darkened(0.85), alpha))
	# Vòng sáng sau lưng.
	var center := rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.42)
	for i in 4:
		canvas.draw_circle(center, rect.size.x * (0.42 - i * 0.07), Color(element_color.lightened(0.4), 0.08 * alpha))
	# Bóng nhân vật: thân + đầu.
	var body_rect := Rect2(center.x - rect.size.x * 0.22, center.y + rect.size.y * 0.02, rect.size.x * 0.44, rect.size.y * 0.52)
	canvas.draw_rect(body_rect, Color(body, alpha))
	canvas.draw_rect(Rect2(body_rect.position, Vector2(body_rect.size.x, 10.0)), Color(accent, alpha))
	canvas.draw_circle(center + Vector2(0.0, -rect.size.y * 0.06), rect.size.x * 0.16, Color(body.lightened(0.15), alpha))
	var font := ThemeDB.fallback_font
	var letter := UiKit.character_name(data).left(1).to_upper()
	var font_size := int(rect.size.x * 0.22)
	canvas.draw_string(font, center + Vector2(-font_size * 0.32, -rect.size.y * 0.06 + font_size * 0.36), letter,
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 1, 1, alpha))
	canvas.draw_rect(rect, Color(element_color.lightened(0.3), alpha), false, 4.0)


## Nền chuyển màu dọc từ `top` xuống `bottom`.
static func draw_gradient(canvas: CanvasItem, rect: Rect2, top: Color, bottom: Color) -> void:
	var points := PackedVector2Array([rect.position, rect.position + Vector2(rect.size.x, 0.0), rect.end,
			rect.position + Vector2(0.0, rect.size.y)])
	canvas.draw_polygon(points, PackedColorArray([top, top, bottom, bottom]))


## Tranh banner: banner giới hạn vẽ to nhân vật nổi bật + 3 ô 4★ nổi bật; banner thường vẽ 7 nhân vật 5★.
class BannerArt:
	extends Control
	var banner: BannerData

	func _init() -> void:
		custom_minimum_size = Vector2(700.0, 420.0)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func set_banner(value: BannerData) -> void:
		banner = value
		queue_redraw()

	func _draw() -> void:
		if banner == null:
			return
		var rect := Rect2(Vector2.ZERO, size)
		if banner.art:
			draw_texture_rect(banner.art, rect, false)
			return
		GachaArt.draw_gradient(self, rect, banner.art_color_top, banner.art_color_bottom)
		var random := RandomNumberGenerator.new()
		random.seed = hash(banner.id)
		for i in 60:
			draw_circle(Vector2(random.randf() * size.x, random.randf() * size.y), random.randf_range(1.0, 2.5),
					Color(1, 1, 1, random.randf_range(0.2, 0.7)))
		var font := get_theme_default_font()
		if banner.is_limited() and not banner.featured_5.is_empty():
			var featured := GachaManager.get_character(banner.featured_5[0])
			if featured:
				GachaArt.draw_art(self, Rect2(size.x * 0.52, size.y * 0.06, size.x * 0.42, size.y * 0.88), featured)
				draw_string(font, Vector2(size.x * 0.04, size.y * 0.42), "★★★★★  " + UiKit.character_name(featured),
						HORIZONTAL_ALIGNMENT_LEFT, -1, 40, UiKit.GOLD)
			var x := size.x * 0.04
			for id in banner.featured_4:
				var data := GachaManager.get_character(id)
				if data == null:
					continue
				GachaArt.draw_art(self, Rect2(x, size.y * 0.55, 110.0, 150.0), data)
				draw_string(font, Vector2(x, size.y * 0.55 + 180.0), UiKit.character_name(data),
						HORIZONTAL_ALIGNMENT_LEFT, 120.0, 20, Color.WHITE)
				x += 130.0
		else:
			var count := banner.pool_5.size()
			var w := minf((size.x * 0.9) / maxf(count, 1.0), 150.0)
			for i in count:
				var data := GachaManager.get_character(banner.pool_5[i])
				if data == null:
					continue
				var x := size.x * 0.05 + i * w
				GachaArt.draw_art(self, Rect2(x, size.y * 0.42, w - 12.0, size.y * 0.42), data)
				draw_string(font, Vector2(x, size.y * 0.42 + size.y * 0.42 + 30.0), UiKit.character_name(data),
						HORIZONTAL_ALIGNMENT_LEFT, w - 12.0, 20, Color.WHITE)
		draw_string(font, Vector2(size.x * 0.04, 70.0), tr(banner.name_key), HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.5,
				46, Color.WHITE)
		draw_string(font, Vector2(size.x * 0.04, 116.0),
				tr("GACHA_TYPE_LIMITED") if banner.is_limited() else tr("GACHA_TYPE_STANDARD"),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 24, UiKit.GOLD)
		draw_multiline_string(font, Vector2(size.x * 0.04, 160.0), tr(banner.desc_key), HORIZONTAL_ALIGNMENT_LEFT,
				size.x * 0.46, 20, 4, Color(1, 1, 1, 0.85))
		draw_rect(rect, UiKit.PANEL_BORDER, false, 2.0)
