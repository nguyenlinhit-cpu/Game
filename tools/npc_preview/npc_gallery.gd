extends Control
## Review all story NPC artwork without changing game progress or saves.

const CAST := {
	"orwen": "Trưởng lão · áo choàng thiên văn, sách và trượng pha lê",
	"lio": "Thủ thư tập sự · kính tròn, sách đỏ và túi đeo chéo",
	"bram": "Thợ máy · kính bảo hộ, tạp dề da và dụng cụ",
	"kiri": "Bạn đồng hành · Thư Viện",
	"garren": "Bạn đồng hành · Kho Chứa",
	"nyx": "Bạn đồng hành · Lò Năng Lượng",
	"devourer": "Kẻ Nuốt Mảnh Hồn · chân dung cốt truyện",
}
const EXPRESSIONS := ["neutral", "happy", "serious", "speaking"]
const LABELS := ["Bình thường", "Vui", "Nghiêm túc", "Đang nói"]

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("171b2c")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 24
	scroll.offset_top = 20
	scroll.offset_right = -24
	scroll.offset_bottom = -20
	add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 18)
	scroll.add_child(column)
	_label(column, "NGOẠI HÌNH NPC · AETHELGARD", 28)
	_label(column, "Cuộn để xem đủ 7 nhân vật · sprite trên bản đồ và 4 biểu cảm hội thoại", 18)
	for id: String in CAST:
		var card := PanelContainer.new()
		column.add_child(card)
		var content := VBoxContainer.new()
		card.add_child(content)
		_label(content, "%s — %s" % [StoryManager.speaker_name(id), CAST[id]], 21)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		content.add_child(row)
		var map_cell := VBoxContainer.new()
		map_cell.custom_minimum_size.x = 180
		row.add_child(map_cell)
		_label(map_cell, "Trên bản đồ" if id != "devourer" else "Boss trên bản đồ", 16)
		var stage := Control.new()
		stage.custom_minimum_size = Vector2(180, 210)
		map_cell.add_child(stage)
		var frames := ArtLibrary.npc_frames(StringName(id)) if id != "devourer" else load("res://assets/enemies/soul_devourer/map/soul_devourer_map_frames.tres") as SpriteFrames
		if frames:
			var sprite := ArtLibrary.make_sprite(frames, 190)
			sprite.position = Vector2(90, 205)
			stage.add_child(sprite)
			ArtLibrary.play(sprite, "idle", "s")
		for i in EXPRESSIONS.size():
			var cell := VBoxContainer.new()
			cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(cell)
			_label(cell, LABELS[i], 16)
			var portrait := TextureRect.new()
			portrait.custom_minimum_size = Vector2(160, 210)
			portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			portrait.texture = StoryManager.speaker_portrait(id, EXPRESSIONS[i])
			cell.add_child(portrait)
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/tmp/npc_gallery.png")
		get_tree().quit()

func _label(parent: Node, value: String, font_size: int) -> void:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
