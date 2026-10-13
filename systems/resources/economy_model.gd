class_name EconomyModel
extends Resource
## Giả định "chơi hết bản đồ" cho báo cáo kinh tế (systems/economy_report.gd) và các mục tiêu mục 11/11b.
## Mọi số ở đây sửa được để cân bằng lại mà không đụng code.

@export var zones: Array[ZoneData] = []

@export_group("Cách chơi giả định")
## Số ngày chơi hết 4 chương (nhiệm vụ ngày/tuần trong thời gian này được cộng vào tổng toàn bản đồ).
@export var story_days: int = 14
## Nhiệm vụ ngày mở sau Chương 1: số ngày đầu chưa có nhiệm vụ.
@export var days_before_daily_unlock: int = 2
## Cày lại quái thường tối đa mỗi chương (mục 11: không quá 15 phút) = số trận thường thêm.
@export var grind_battles_per_chapter: int = 8
## Số quái thường trung bình mỗi trận cày lại.
@export var grind_enemies_per_battle: float = 3.0
## Số ngày đánh lại mỗi trận tinh anh (hồi mỗi ngày) ngoài lần đầu.
@export var elite_repeat_days: int = 5
## Mỗi boss: số lần đánh lại mức thường (nhận đủ thưởng) và mức Khó, ngoài lần đầu.
@export var boss_repeat_runs: int = 0
@export var boss_hard_runs: int = 2
## Đội miễn phí dùng để kiểm tra nhịp cốt truyện (đủ cấp khuyến nghị boss).
@export var free_team: Array[StringName] = []

@export_group("Mục tiêu")
@export var target_characters_min: float = 4.0
@export var target_characters_max: float = 5.0
@export var target_onetime_pulls: float = 78.0
@export var target_monthly_pulls: float = 32.0
@export var stardust_monthly_max_pulls: float = 10.0
@export var tolerance: float = 0.1
@export var star_tears_per_pull: int = 160
@export var days_per_month: float = 30.0
@export var weeks_per_month: float = 4.3
