class_name OverworldHud
extends CanvasLayer
## HUD ngoài map: hướng dẫn + FPS, minimap, lời nhắc tương tác, thông báo nhỏ, điều khiển cảm ứng,
## menu tạm dừng.

const TOAST_SECONDS: float = 2.2
const FPS_REFRESH_SEC: float = 0.25

var _player: Player
var _toast_tween: Tween
var _fps_timer: float = 0.0

@onready var _info_label: Label = %InfoLabel
@onready var _minimap: Minimap = %Minimap
@onready var _prompt_label: Label = %PromptLabel
@onready var _toast_label: Label = %ToastLabel
@onready var _touch_controls: TouchControls = %TouchControls


func _ready() -> void:
	_prompt_label.hide()
	_toast_label.modulate.a = 0.0
	EventBus.toast_requested.connect(show_toast)


func setup(player: Player, room_manager: RoomManager) -> void:
	_player = player
	_minimap.setup(room_manager, player)
	player.focused_interactable_changed.connect(_on_focused_interactable_changed)


func _process(delta: float) -> void:
	_fps_timer -= delta
	if _fps_timer <= 0.0:
		_fps_timer = FPS_REFRESH_SEC
		_info_label.text = "%s\nFPS: %d" % [tr("HUD_HINT"), Engine.get_frames_per_second()]
	if _player and _touch_controls.visible:
		_touch_controls.dash_button.cooldown_ratio = _player.get_dash_cooldown_ratio()


func show_toast(text: String) -> void:
	_toast_label.text = text
	if _toast_tween:
		_toast_tween.kill()
	_toast_label.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(TOAST_SECONDS)
	_toast_tween.tween_property(_toast_label, "modulate:a", 0.0, 0.4)


func get_toast_text() -> String:
	return _toast_label.text


func _on_focused_interactable_changed(interactable: Interactable) -> void:
	if interactable == null:
		_prompt_label.hide()
		return
	_prompt_label.text = "[F]  %s" % interactable.get_prompt()
	_prompt_label.show()
