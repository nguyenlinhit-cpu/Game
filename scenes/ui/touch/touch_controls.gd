class_name TouchControls
extends Control
## Lớp điều khiển cảm ứng ngoài map: joystick trái; nút Chém (Đòn Mở Màn), Lướt, Tương tác bên phải.
## Hiện khi máy có màn cảm ứng hoặc khi bật trong Cài đặt.
## TODO Phase 6: thêm nút Bí Kỹ, đổi nhân vật.

@onready var dash_button: TouchActionButton = %DashButton
@onready var interact_button: TouchActionButton = %InteractButton
@onready var opener_button: TouchActionButton = %OpenerButton


func _ready() -> void:
	EventBus.settings_changed.connect(refresh_visibility)
	refresh_visibility()


func refresh_visibility() -> void:
	visible = UserSettings.should_show_touch_controls()
