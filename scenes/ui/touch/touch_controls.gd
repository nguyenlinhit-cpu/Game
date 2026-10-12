class_name TouchControls
extends Control
## Lớp điều khiển cảm ứng ngoài map: joystick trái, nút Lướt và Tương tác bên phải.
## Hiện khi máy có màn cảm ứng hoặc khi bật trong Cài đặt.
## TODO Phase 3/6: thêm nút Đòn Mở Màn, Bí Kỹ, đổi nhân vật.

@onready var dash_button: TouchActionButton = %DashButton
@onready var interact_button: TouchActionButton = %InteractButton


func _ready() -> void:
	EventBus.settings_changed.connect(refresh_visibility)
	refresh_visibility()


func refresh_visibility() -> void:
	visible = UserSettings.should_show_touch_controls()
