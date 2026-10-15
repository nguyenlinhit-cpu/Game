extends Node
## Inspect the actual story NPCs in their actual maps, using a separate preview save.

const CAST := {
	&"orwen": [&"hub", "Trưởng lão Vọng Tinh"],
	&"lio": [&"hub", "Thủ thư tập sự"],
	&"bram": [&"hub", "Thợ máy · Chủ quầy hàng"],
	&"kiri": [&"library", "Bạn đồng hành · Thư Viện"],
	&"garren": [&"vault", "Bạn đồng hành · Kho Băng"],
	&"nyx": [&"furnace", "Bạn đồng hành · Lò Năng Lượng"],
}
const EXPRESSIONS := ["neutral", "happy", "serious", "speaking"]
var selected: StringName = &"orwen"
var portrait: TextureRect
var description: Label
var expression_menu: OptionButton
var busy := false

func _ready() -> void:
	if get_tree().current_scene == self:
		get_tree().root.add_child.call_deferred((get_script() as GDScript).new())
		return
	SaveManager.save_dir = "user://npc_preview_saves"
	GameState.reset_new_game()
	GameState.owned_characters = DataPaths.list_character_ids()
	GameState.set_team([&"traveler", &"mira"])
	GameState.set_story_flag(&"prologue_done")
	for zone in [&"library", &"vault", &"furnace", &"tower"]:
		GameState.set_story_flag(StringName("zone_%s_open" % zone))
	var layer := CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	var ui := Control.new()
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(ui)
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var toolbar := PanelContainer.new()
	toolbar.position = Vector2(12, 12)
	ui.add_child(toolbar)
	var row := HBoxContainer.new()
	toolbar.add_child(row)
	for id: StringName in CAST:
		var button := Button.new()
		button.text = StoryManager.speaker_name(String(id))
		button.pressed.connect(_show_npc.bind(id))
		row.add_child(button)
	var hint := Label.new()
	hint.text = "  Di chuyển · F nói chuyện  "
	row.add_child(hint)
	var card := PanelContainer.new()
	ui.add_child(card)
	card.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	card.offset_left = -246
	card.offset_top = -302
	card.offset_right = -12
	card.offset_bottom = -12
	var column := VBoxContainer.new()
	card.add_child(column)
	description = Label.new()
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(description)
	portrait = TextureRect.new()
	portrait.custom_minimum_size = Vector2(220, 220)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	column.add_child(portrait)
	expression_menu = OptionButton.new()
	for label in ["Bình thường", "Vui", "Nghiêm túc", "Đang nói"]:
		expression_menu.add_item(label)
	expression_menu.item_selected.connect(_show_expression)
	column.add_child(expression_menu)
	await _show_npc(&"orwen")

func _show_npc(id: StringName) -> void:
	if busy or SceneRouter.is_busy() or StoryManager.is_playing():
		return
	busy = true
	selected = id
	StoryManager.auto_play = true
	if id in [&"kiri", &"garren", &"nyx"]:
		GameState.set_story_flag(StringName("%s_joined" % id), false)
	var map := get_tree().current_scene as OverworldMap
	var zone: StringName = CAST[id][0]
	if map == null or map.zone != zone:
		SceneRouter.go_to(StoryManager.get_zone_scene(zone), {}, 0.05)
		await SceneRouter.transition_finished
		map = get_tree().current_scene as OverworldMap
	if map:
		map._apply_story_gates()
		for candidate in map.find_children("*", "Npc", true, false):
			var npc := candidate as Npc
			if npc.npc_id != id:
				continue
			map.player.global_position = npc.global_position + Vector2(0, 85)
			map.player.velocity = Vector2.ZERO
			map.player.grant_invincibility(600.0)
			var focus := map.player.get_node_or_null("NpcPreviewFocus") as Marker2D
			if focus == null:
				focus = Marker2D.new()
				focus.name = "NpcPreviewFocus"
				focus.position = Vector2(0, -100)
				map.player.add_child(focus)
			map.camera.set("_target", focus)
			map.camera.zoom = Vector2.ONE * 0.95
			map.camera.set_room_limits(Room.find_room_of(npc).get_world_rect().grow(192))
			map.camera.snap_to_target()
			break
	StoryManager.auto_play = false
	description.text = "%s\n%s" % [StoryManager.speaker_name(String(id)), CAST[id][1]]
	_show_expression(expression_menu.selected)
	busy = false
	print("NPC preview ready: ", id)

func _show_expression(index: int) -> void:
	portrait.texture = StoryManager.speaker_portrait(String(selected), EXPRESSIONS[index])
