class_name OverworldHud
extends CanvasLayer
## HUD ngoài map: hướng dẫn + FPS + cấp đội, minimap, lời nhắc tương tác, thông báo nhỏ,
## bảng phần thưởng tạm, điều khiển cảm ứng, menu tạm dừng, nhiệm vụ chính / phụ ở góc trái (Phase 12),
## bảng phủ (quầy hàng, dịch chuyển) tạm dừng game.

const TOAST_SECONDS: float = 2.2
const FPS_REFRESH_SEC: float = 0.25
const REWARD_POPUP_SECONDS: float = 2.5

var _player: Player
var _toast_tween: Tween
var _fps_timer: float = 0.0
var _reward_tween: Tween
## Nhắc "có thưởng nhiệm vụ chưa nhận" dưới bản đồ nhỏ.
var quest_badge: Label
## Nhiệm vụ chính / phụ đang làm (góc trái).
var quest_tracker: RichTextLabel
## Bảng phủ đang mở (quầy hàng, dịch chuyển).
var panel_overlay: Control

@onready var _info_label: Label = %InfoLabel
@onready var _minimap: Minimap = %Minimap
@onready var _prompt_label: Label = %PromptLabel
@onready var _toast_label: Label = %ToastLabel
@onready var _touch_controls: TouchControls = %TouchControls
@onready var _reward_popup: PanelContainer = %RewardPopup
@onready var _reward_title: Label = %RewardTitle
@onready var _reward_lines: Label = %RewardLines
@onready var _team_bar: TeamBar = %TeamBar


func _ready() -> void:
	_prompt_label.hide()
	_toast_label.modulate.a = 0.0
	_reward_popup.hide()
	EventBus.toast_requested.connect(show_toast)
	quest_badge = UiKit.make_label(tr("HUD_QUEST_BADGE"), 22, Color("ff6b6b"))
	quest_badge.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	quest_badge.offset_left = -352.0
	quest_badge.offset_top = 292.0
	quest_badge.offset_right = -32.0
	quest_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(quest_badge)
	# Nằm dưới menu tạm dừng.
	move_child(quest_badge, get_node("PauseMenu").get_index())
	QuestManager.changed.connect(_refresh_quest_badge)
	_refresh_quest_badge()
	quest_tracker = UiKit.make_rich(24)
	quest_tracker.position = Vector2(32.0, 140.0)
	quest_tracker.custom_minimum_size = Vector2(760.0, 0.0)
	quest_tracker.size = Vector2(760.0, 0.0)
	quest_tracker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quest_tracker.add_theme_color_override("font_outline_color", Color.BLACK)
	quest_tracker.add_theme_constant_override("outline_size", 6)
	add_child(quest_tracker)
	move_child(quest_tracker, get_node("PauseMenu").get_index())
	StoryManager.story_changed.connect(refresh_quest_tracker)
	refresh_quest_tracker()
	EventBus.reward_popup_requested.connect(func(title: String, lines: Array) -> void:
		var text_lines: Array[String] = []
		text_lines.assign(lines)
		show_reward_popup(title, text_lines))


func setup(player: Player, room_manager: RoomManager) -> void:
	_player = player
	_minimap.setup(room_manager, player)
	_team_bar.slot_pressed.connect(func(index: int) -> void: player.set_leader(index))
	player.focused_interactable_changed.connect(_on_focused_interactable_changed)


func _process(delta: float) -> void:
	_fps_timer -= delta
	if _fps_timer <= 0.0:
		_fps_timer = FPS_REFRESH_SEC
		_info_label.text = "%s\n%s · FPS: %d" % [tr("HUD_HINT"),
				tr("HUD_TEAM_LEVEL") % GameState.get_team_level(), Engine.get_frames_per_second()]
	if _player and _touch_controls.visible:
		_touch_controls.dash_button.cooldown_ratio = _player.get_dash_cooldown_ratio()
		_touch_controls.opener_button.cooldown_ratio = _player.get_opener_cooldown_ratio()
	_team_bar.queue_redraw()


func show_toast(text: String) -> void:
	_toast_label.text = text
	if _toast_tween:
		_toast_tween.kill()
	_toast_label.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(TOAST_SECONDS)
	_toast_tween.tween_property(_toast_label, "modulate:a", 0.0, 0.4)


func _refresh_quest_badge() -> void:
	quest_badge.visible = QuestManager.has_any_claimable()


## Dòng nhiệm vụ: chính (vàng) + phụ (xanh); ghi tên khu nếu mục tiêu ở khu khác. Map thử thì ẩn.
func refresh_quest_tracker() -> void:
	var map := get_parent() as OverworldMap
	var zone := StoryManager.get_scene_zone(map.scene_file_path) if map else &""
	if zone == &"":
		quest_tracker.text = ""
		return
	var lines: Array[String] = []
	var main := StoryManager.get_main_step()
	if main.is_empty():
		lines.append("[color=#%s]◆ %s[/color]" % [UiKit.GOLD.to_html(false), tr(str(StoryManager.data.get("main_quest_done", "")))])
	else:
		lines.append("[color=#%s]◆ %s[/color]%s" % [UiKit.GOLD.to_html(false), tr(str(main["title"])), _where(main, zone)])
	for entry in StoryManager.get_side_steps():
		var step: Dictionary = entry["step"]
		lines.append("[color=#8fd3ff]◇ %s: %s[/color]%s" % [tr(str(entry["quest"]["title"])), tr(str(step["title"])),
				_where(step, zone)])
	quest_tracker.text = "\n".join(lines)


func _where(step: Dictionary, zone: StringName) -> String:
	var target_zone := StringName(str(step.get("target", {}).get("zone", "")))
	if target_zone == &"" or target_zone == zone:
		return ""
	return "  [color=#aaaabb](%s)[/color]" % StoryManager.zone_name(target_zone)


## Bảng phủ giữa màn hình (tạm dừng game) chứa `content`; Esc hoặc nút Đóng để đóng. Trả về bảng phủ.
func open_panel(title: String, content: Control) -> Control:
	close_panel()
	var overlay := Control.new()
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	var panel := UiKit.make_panel()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(900.0, 0.0)
	overlay.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	var label := UiKit.make_label(title, 34, UiKit.GOLD)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(label)
	header.add_child(UiKit.make_button(tr("UI_CLOSE"), close_panel, Vector2(160.0, 56.0)))
	box.add_child(content)
	add_child(overlay)
	move_child(overlay, get_node("PauseMenu").get_index())
	panel_overlay = overlay
	get_tree().paused = true
	return overlay


func close_panel() -> void:
	if panel_overlay:
		panel_overlay.queue_free()
		panel_overlay = null
		get_tree().paused = false


func open_game_menu(page: int) -> GameMenu:
	return (get_node("PauseMenu") as PauseMenu).open_game_menu(page, true)


## Bảng phần thưởng nhỏ giữa màn hình, tự ẩn.
func show_reward_popup(title: String, lines: Array[String]) -> void:
	_reward_title.text = title
	_reward_lines.text = "\n".join(lines)
	if _reward_tween:
		_reward_tween.kill()
	_reward_popup.modulate.a = 1.0
	_reward_popup.show()
	_reward_tween = create_tween()
	_reward_tween.tween_interval(REWARD_POPUP_SECONDS)
	_reward_tween.tween_property(_reward_popup, "modulate:a", 0.0, 0.4)
	_reward_tween.tween_callback(_reward_popup.hide)


## Vòng nổ hiệu ứng Bí Kỹ tại vị trí trên map (toạ độ thế giới).
func show_burst(world_position: Vector2, radius: float, color: Color) -> void:
	var burst := BurstEffect.new()
	burst.radius = radius
	burst.color = color
	burst.global_position = world_position
	_player.get_parent().add_child(burst)


func reveal_on_minimap(kind: Minimap.Reveal, duration: float) -> void:
	_minimap.reveal(kind, duration)


func is_reward_popup_visible() -> bool:
	return _reward_popup.visible


func get_toast_text() -> String:
	return _toast_label.text


func _on_focused_interactable_changed(interactable: Interactable) -> void:
	if interactable == null:
		_prompt_label.hide()
		return
	_prompt_label.text = "[F]  %s" % interactable.get_prompt()
	_prompt_label.show()


## Vòng tròn lan ra rồi mờ dần.
class BurstEffect extends Node2D:
	var radius: float = 100.0
	var color: Color = Color.WHITE
	var _t: float = 0.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()
		if _t > 0.6:
			queue_free()

	func _draw() -> void:
		var k := clampf(_t / 0.6, 0.0, 1.0)
		draw_circle(Vector2.ZERO, radius * k, Color(color, 0.35 * (1.0 - k)))
		draw_arc(Vector2.ZERO, radius * k, 0.0, TAU, 48, Color(color, 1.0 - k), 4.0, true)
