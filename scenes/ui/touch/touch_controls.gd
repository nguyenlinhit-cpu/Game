class_name TouchControls
extends Control
## Lớp điều khiển cảm ứng ngoài map: joystick trái; nút Chém (Đòn Mở Màn), Lướt, Tương tác bên phải.
## Hiện khi máy có màn cảm ứng hoặc khi bật trong Cài đặt.
## Đổi người dẫn đầu: chạm chân dung trên thanh đội (TeamBar). Nút ☰ (dưới bản đồ nhỏ) mở menu tạm dừng
## vì điện thoại không có phím Esc.

@onready var dash_button: TouchActionButton = %DashButton
@onready var interact_button: TouchActionButton = %InteractButton
@onready var opener_button: TouchActionButton = %OpenerButton
@onready var technique_button: TouchActionButton = %TechniqueButton


var menu_button: TouchActionButton


func _ready() -> void:
	menu_button = TouchActionButton.new()
	menu_button.name = "MenuButton"
	menu_button.action = &"menu"
	menu_button.label_key = "TOUCH_MENU"
	menu_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	menu_button.offset_left = -160.0
	menu_button.offset_top = 330.0
	menu_button.offset_right = -40.0
	menu_button.offset_bottom = 450.0
	add_child(menu_button)
	EventBus.settings_changed.connect(refresh_visibility)
	refresh_visibility()


func refresh_visibility() -> void:
	visible = UserSettings.should_show_touch_controls()
