class_name TouchControls
extends Control
## Lớp điều khiển cảm ứng ngoài map: joystick trái; nút Chém (Đòn Mở Màn), Lướt, Tương tác bên phải.
## Hiện khi máy có màn cảm ứng hoặc khi bật trong Cài đặt.
## Đổi người dẫn đầu: chạm chân dung trên thanh đội (TeamBar).

@onready var dash_button: TouchActionButton = %DashButton
@onready var interact_button: TouchActionButton = %InteractButton
@onready var opener_button: TouchActionButton = %OpenerButton
@onready var technique_button: TouchActionButton = %TechniqueButton


func _ready() -> void:
	EventBus.settings_changed.connect(refresh_visibility)
	refresh_visibility()


func refresh_visibility() -> void:
	visible = UserSettings.should_show_touch_controls()
