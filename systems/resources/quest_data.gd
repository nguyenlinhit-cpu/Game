class_name QuestData
extends Resource
## Một nhiệm vụ: ngày (điểm Hoạt Động), tuần, thành tựu, khám phá khu, quà đăng nhập người mới.
## Tiến độ tăng theo `trigger` (QuestManager nghe sự kiện và gọi report(trigger, amount, param)).

enum Type { DAILY, WEEKLY, ACHIEVEMENT, NEWBIE }

@export var id: StringName
@export var type: Type = Type.DAILY
@export var name_key: String = ""
## Sự kiện tính tiến độ: login, battle_won, elite_or_boss, boss_defeated, hard_boss_defeated, weakness_broken,
## technique_used, upgrade, chest_opened, daily_full, zone_explored, login_day, max_level, max_skill,
## team_level, encounter_cleared.
@export var trigger: StringName = &""
## Lọc theo tham số sự kiện (id khu, id trận...). Rỗng = mọi giá trị.
@export var param: StringName = &""
@export var target: int = 1
## Nhiệm vụ ngày: điểm Hoạt Động khi xong.
@export var activity: int = 0
## Thành tựu / người mới: phần thưởng khi nhận.
@export var rewards: Dictionary = {}
## Tiến độ là giá trị lớn nhất (vd. cấp cao nhất) thay vì cộng dồn.
@export var track_max: bool = false
