class_name OverworldEnemyConfig
extends Resource
## Thông số AI quái trên map: tuần tra, tầm nhìn, đuổi, vồ.

@export_group("Di chuyển")
@export var patrol_speed: float = 130.0
@export var chase_speed: float = 300.0
@export var patrol_wait_sec: float = 0.8

@export_group("Phát hiện")
@export var vision_range: float = 420.0
@export_range(5.0, 180.0) var vision_half_angle_deg: float = 50.0
## Đứng sát thế này thì quái nhận ra kể cả sau lưng.
@export var hearing_radius: float = 110.0
@export var alert_sec: float = 0.4
## Người chơi xa hơn thế này thì quái bỏ cuộc.
@export var lose_range: float = 700.0
## Quái không đuổi xa điểm xuất phát quá thế này.
@export var leash_range: float = 1100.0

@export_group("Vồ")
@export var attack_range: float = 160.0
@export var windup_sec: float = 0.45
@export var lunge_speed: float = 950.0
@export var lunge_sec: float = 0.2
@export var recover_sec: float = 0.5
@export var attack_cooldown_sec: float = 1.2

@export_group("Va chạm")
@export var body_radius: float = 28.0
## Khoảng cách tâm–tâm để tính là chạm người chơi.
@export var contact_distance: float = 52.0
## Sau khi vào map (vd. vừa ra khỏi trận), quái đứng yên chừng này giây.
@export var start_grace_sec: float = 1.5
