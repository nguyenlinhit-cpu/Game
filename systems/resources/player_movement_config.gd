class_name PlayerMovementConfig
extends Resource
## Thông số di chuyển ngoài map, chỉnh trong data/config/player_movement.tres.

@export_group("Đi")
## px/giây.
@export var max_speed: float = 420.0
## px/giây² khi đang bấm hướng.
@export var acceleration: float = 3200.0
## px/giây² khi thả tay (giảm tốc).
@export var friction: float = 3800.0

@export_group("Lướt")
@export var dash_speed: float = 1450.0
@export var dash_duration: float = 0.16
@export var dash_cooldown: float = 0.7
## Thời gian bất tử tính từ lúc bắt đầu lướt (dài hơn lướt một chút).
@export var dash_invincibility: float = 0.24
