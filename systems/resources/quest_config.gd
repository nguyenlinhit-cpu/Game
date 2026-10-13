class_name QuestConfig
extends Resource
## Cấu hình nhiệm vụ (mục 11b): danh sách nhiệm vụ, mốc Hoạt Động, thưởng tuần, cờ mở khóa, giờ làm mới.

@export var quests: Array[QuestData] = []
## Mốc Hoạt Động ngày (tăng dần) và thưởng từng mốc (cùng thứ tự).
@export var daily_milestones: PackedInt32Array = PackedInt32Array()
@export var daily_milestone_rewards: Array[Dictionary] = []
## Nhiệm vụ tuần: xong cả 3 thì nhận thưởng này.
@export var weekly_reward: Dictionary = {}
## Nhiệm vụ ngày/tuần mở khi cờ cốt truyện này bật.
@export var unlock_flag: StringName = &"chapter_1_complete"
@export var reset_hour: int = 4
## Mỗi chương hoàn thành (mục 11): cấp tự động khi cờ chapter_<n>_complete bật.
@export var chapter_reward: Dictionary = {}
@export var chapter_count: int = 4
## Quà mở Gacha (mục 11b) – Phase 11 trao; báo cáo kinh tế vẫn cộng.
@export var gacha_open_gift: Dictionary = {}


func get_quests(type: QuestData.Type) -> Array[QuestData]:
	var result: Array[QuestData] = []
	for quest in quests:
		if quest.type == type:
			result.append(quest)
	return result


func find(quest_id: StringName) -> QuestData:
	for quest in quests:
		if quest.id == quest_id:
			return quest
	return null


func get_daily_total_activity() -> int:
	var total := 0
	for quest in get_quests(QuestData.Type.DAILY):
		total += quest.activity
	return total
