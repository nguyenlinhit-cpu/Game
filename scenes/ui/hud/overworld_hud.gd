class_name OverworldHud
extends CanvasLayer
## HUD ngoài map: hướng dẫn + FPS + cấp đội, minimap, lời nhắc tương tác, thông báo nhỏ,
## bảng phần thưởng tạm, điều khiển cảm ứng, menu tạm dừng.

const TOAST_SECONDS: float = 2.2
const FPS_REFRESH_SEC: float = 0.25
const REWARD_POPUP_SECONDS: float = 2.5

var _player: Player
var _toast_tween: Tween
var _fps_timer: float = 0.0
var _reward_tween: Tween

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
