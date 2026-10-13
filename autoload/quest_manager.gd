extends Node
## Nhiệm vụ ngày/tuần, thành tựu, quà người mới, thưởng chương (mục 11, 11b).
##
## - Nhiệm vụ ngày làm mới lúc 4:00 sáng giờ máy, nhiệm vụ tuần sáng thứ Hai cùng giờ. Chỉ chạy sau cờ
##   cốt truyện `QuestConfig.unlock_flag` (hết Chương 1).
## - Hoàn thành nhiệm vụ ngày tự cộng điểm Hoạt Động; mốc Hoạt Động, thưởng tuần, thành tựu, quà đăng nhập
##   phải bấm nhận (chấm đỏ khi có thưởng chưa nhận). Nhận xong tự lưu.
## - Chống chỉnh giờ: giờ máy nhỏ hơn mốc lớn nhất từng thấy (`last_seen_unix`, có trong file save) thì không
##   làm mới gì cho tới khi giờ vượt lại mốc đó.

## Tiến độ / trạng thái nhận thưởng thay đổi (giao diện vẽ lại, chấm đỏ).
signal changed

const CONFIG_PATH: String = "res://data/quests/quest_config.tres"
const DAILY_FULL_TRIGGER: StringName = &"daily_full"
const CHECK_INTERVAL_SEC: float = 20.0
## Ngày 4 tính từ 1970-01-01 (thứ Năm) là thứ Hai 1970-01-05.
const FIRST_MONDAY_DAY: int = 4

var config: QuestConfig
## Test đặt giờ giả (unix, giây). −1 = giờ máy thật.
var now_override: int = -1
## Độ lệch múi giờ so với UTC (phút); test đặt 0 cho dễ tính.
var utc_bias_minutes: int = 0
## Nhận thưởng xong thì tự lưu (ô tự lưu).
var autosave_on_claim: bool = true

## Mốc giờ lớn nhất từng thấy, để chống chỉnh giờ lùi.
var last_seen_unix: int = 0
## Kỳ ngày / tuần hiện tại (đếm từ 1970 theo giờ làm mới). −1 = chưa có.
var day_index: int = -1
var week_index: int = -1
var activity_points: int = 0
var claimed_milestones: Array[int] = []
var daily_progress: Dictionary = {}
var weekly_progress: Dictionary = {}
var weekly_claimed: bool = false
var achievement_progress: Dictionary = {}
## Thành tựu và quà đăng nhập đã nhận.
var claimed_quests: Array[String] = []
## Số ngày khác nhau đã vào game (quà 7 ngày đầu).
var login_days: int = 0
var granted_chapters: Array[int] = []

var _check_timer: float = 0.0


func _ready() -> void:
	config = load(CONFIG_PATH) as QuestConfig
	utc_bias_minutes = int(Time.get_time_zone_from_system().get("bias", 0))
	EventBus.encounter_cleared.connect(_on_encounter_cleared)
	EventBus.weakness_broken.connect(func(_source: Object, _target: Object) -> void:
		# Chỉ tính trận thật đi từ map (phòng thử / mô phỏng không có pending_battle).
		if not GameState.pending_battle.is_empty():
			report(&"weakness_broken"))
	EventBus.technique_used.connect(func(_id: StringName) -> void: report(&"technique_used"))
	EventBus.character_upgraded.connect(_on_character_upgraded)
	EventBus.chest_opened.connect(func(_id: StringName) -> void: report(&"chest_opened"))
	EventBus.story_flag_set.connect(_on_story_flag_set)


func _process(delta: float) -> void:
	_check_timer -= delta
	if _check_timer <= 0.0:
		_check_timer = CHECK_INTERVAL_SEC
		check_reset()


## Game mới: xóa mọi tiến độ (giữ mốc giờ chống chỉnh giờ của máy này).
func reset() -> void:
	day_index = -1
	week_index = -1
	activity_points = 0
	claimed_milestones.clear()
	daily_progress.clear()
	weekly_progress.clear()
	weekly_claimed = false
	achievement_progress.clear()
	claimed_quests.clear()
	login_days = 0
	granted_chapters.clear()
	check_reset()


func is_unlocked() -> bool:
	return config != null and bool(GameState.get_story_flag(config.unlock_flag, false))


# --- Thời gian ---

func now_unix() -> int:
	return now_override if now_override >= 0 else int(Time.get_unix_time_from_system())


## Kỳ ngày chứa thời điểm `unix` (đổi lúc reset_hour giờ địa phương).
func day_of(unix: int) -> int:
	var local := unix + utc_bias_minutes * 60 - config.reset_hour * 3600
	return floori(local / 86400.0)


static func week_of_day(day: int) -> int:
	return floori((day - FIRST_MONDAY_DAY) / 7.0)


## Giây còn lại tới lần làm mới ngày / tuần kế tiếp.
func seconds_until_daily_reset() -> int:
	return maxi(day_start_unix(day_of(now_unix()) + 1) - now_unix(), 0)


func seconds_until_weekly_reset() -> int:
	var next_monday := (week_of_day(day_of(now_unix())) + 1) * 7 + FIRST_MONDAY_DAY
	return maxi(day_start_unix(next_monday) - now_unix(), 0)


func day_start_unix(day: int) -> int:
	return day * 86400 + config.reset_hour * 3600 - utc_bias_minutes * 60


## Kỳ ngày dùng cho luật theo ngày (thưởng boss, tinh anh hồi): đứng yên khi giờ máy bị lùi.
func get_day_index() -> int:
	check_reset()
	return day_index


## So giờ máy với kỳ đang giữ: sang ngày mới thì làm mới nhiệm vụ ngày (và tuần nếu sang tuần mới).
## Giờ máy lùi so với mốc lớn nhất từng thấy thì không làm gì. Trả về true nếu đã làm mới ngày.
func check_reset() -> bool:
	if config == null:
		return false
	var now := now_unix()
	if now < last_seen_unix:
		return false
	last_seen_unix = now
	var day := day_of(now)
	if day == day_index:
		return false
	day_index = day
	activity_points = 0
	claimed_milestones.clear()
	daily_progress.clear()
	var week := week_of_day(day)
	if week != week_index:
		week_index = week
		weekly_progress.clear()
		weekly_claimed = false
	login_days += 1
	report(&"login_day")
	_report_login()
	changed.emit()
	return true


# --- Tiến độ ---

## Ghi nhận sự kiện `trigger` cho mọi nhiệm vụ khớp (lọc theo `param` nếu nhiệm vụ có).
## Nhiệm vụ `track_max` lấy giá trị lớn nhất của `amount` thay vì cộng dồn.
func report(trigger: StringName, amount: int = 1, param: StringName = &"") -> void:
	if config == null or trigger == &"":
		return
	if trigger != &"login_day":
		check_reset()
	var unlocked := is_unlocked()
	var any := false
	for quest in config.quests:
		if quest.trigger != trigger or (quest.param != &"" and quest.param != param):
			continue
		match quest.type:
			QuestData.Type.DAILY:
				if unlocked:
					any = _advance(daily_progress, quest, amount) or any
			QuestData.Type.WEEKLY:
				if unlocked:
					any = _advance(weekly_progress, quest, amount) or any
			QuestData.Type.ACHIEVEMENT:
				any = _advance(achievement_progress, quest, amount) or any
			QuestData.Type.NEWBIE:
				any = true
	if any:
		changed.emit()


func get_progress(quest: QuestData) -> int:
	var key := String(quest.id)
	match quest.type:
		QuestData.Type.DAILY:
			return int(daily_progress.get(key, 0))
		QuestData.Type.WEEKLY:
			return int(weekly_progress.get(key, 0))
		QuestData.Type.NEWBIE:
			return mini(login_days, quest.target) if quest.trigger == &"login_day" else 0
	return int(achievement_progress.get(key, 0))


func is_completed(quest: QuestData) -> bool:
	return get_progress(quest) >= quest.target


func is_claimed(quest: QuestData) -> bool:
	return claimed_quests.has(String(quest.id))


func get_daily_total() -> int:
	return config.get_daily_total_activity() if config else 0


func is_weekly_complete() -> bool:
	if not is_unlocked():
		return false
	for quest in config.get_quests(QuestData.Type.WEEKLY):
		if not is_completed(quest):
			return false
	return true


# --- Nhận thưởng ---

func is_milestone_claimable(index: int) -> bool:
	return is_unlocked() and index >= 0 and index < config.daily_milestones.size() \
			and activity_points >= config.daily_milestones[index] and not claimed_milestones.has(config.daily_milestones[index])


func claim_milestone(index: int) -> Dictionary:
	if not is_milestone_claimable(index):
		return {}
	claimed_milestones.append(config.daily_milestones[index])
	return _give(config.daily_milestone_rewards[index] if index < config.daily_milestone_rewards.size() else {})


func is_weekly_claimable() -> bool:
	return is_weekly_complete() and not weekly_claimed


func claim_weekly() -> Dictionary:
	if not is_weekly_claimable():
		return {}
	weekly_claimed = true
	return _give(config.weekly_reward)


## Thành tựu / quà đăng nhập người mới.
func is_quest_claimable(quest: QuestData) -> bool:
	return quest != null and (quest.type == QuestData.Type.ACHIEVEMENT or quest.type == QuestData.Type.NEWBIE) \
			and is_completed(quest) and not is_claimed(quest)


func claim_quest(quest_id: StringName) -> Dictionary:
	var quest := config.find(quest_id)
	if not is_quest_claimable(quest):
		return {}
	claimed_quests.append(String(quest_id))
	return _give(quest.rewards)


## Thẻ có thưởng chưa nhận (DAILY / WEEKLY / ACHIEVEMENT / NEWBIE).
func has_claimable(type: QuestData.Type) -> bool:
	if config == null:
		return false
	match type:
		QuestData.Type.DAILY:
			for i in config.daily_milestones.size():
				if is_milestone_claimable(i):
					return true
			return false
		QuestData.Type.WEEKLY:
			return is_weekly_claimable()
	for quest in config.get_quests(type):
		if is_quest_claimable(quest):
			return true
	return false


func has_any_claimable() -> bool:
	for type: int in QuestData.Type.values():
		if has_claimable(type):
			return true
	return false


# --- Lưu ---

func to_dict() -> Dictionary:
	return {
		"last_seen_unix": last_seen_unix,
		"day_index": day_index,
		"week_index": week_index,
		"activity_points": activity_points,
		"claimed_milestones": claimed_milestones.duplicate(),
		"daily_progress": daily_progress.duplicate(),
		"weekly_progress": weekly_progress.duplicate(),
		"weekly_claimed": weekly_claimed,
		"achievement_progress": achievement_progress.duplicate(),
		"claimed_quests": claimed_quests.duplicate(),
		"login_days": login_days,
		"granted_chapters": granted_chapters.duplicate(),
	}


func from_dict(data: Dictionary) -> void:
	# Mốc chống chỉnh giờ lấy giá trị lớn hơn giữa file save và phiên đang chạy.
	last_seen_unix = maxi(last_seen_unix, int(data.get("last_seen_unix", 0)))
	day_index = int(data.get("day_index", -1))
	week_index = int(data.get("week_index", -1))
	activity_points = int(data.get("activity_points", 0))
	claimed_milestones.assign(_int_array(data.get("claimed_milestones", [])))
	daily_progress = _dict(data.get("daily_progress", {}))
	weekly_progress = _dict(data.get("weekly_progress", {}))
	weekly_claimed = bool(data.get("weekly_claimed", false))
	achievement_progress = _dict(data.get("achievement_progress", {}))
	claimed_quests.clear()
	var claimed: Variant = data.get("claimed_quests", [])
	if claimed is Array:
		for id: Variant in claimed:
			claimed_quests.append(str(id))
	login_days = int(data.get("login_days", 0))
	granted_chapters.assign(_int_array(data.get("granted_chapters", [])))
	check_reset()
	changed.emit()


# --- Nội bộ ---

func _advance(store: Dictionary, quest: QuestData, amount: int) -> bool:
	var key := String(quest.id)
	var before := int(store.get(key, 0))
	if before >= quest.target:
		return false
	var after := maxi(before, amount) if quest.track_max else before + amount
	after = mini(after, quest.target)
	if after == before:
		return false
	store[key] = after
	if after >= quest.target:
		_on_completed(quest)
	return true


func _on_completed(quest: QuestData) -> void:
	EventBus.quest_completed.emit(quest.id)
	EventBus.toast_requested.emit(tr("QUEST_TOAST_COMPLETED") % tr(quest.name_key))
	if quest.type == QuestData.Type.DAILY and quest.activity > 0:
		var total := get_daily_total()
		var was_full := activity_points >= total
		activity_points = mini(activity_points + quest.activity, total)
		if not was_full and activity_points >= total:
			report(DAILY_FULL_TRIGGER)


func _report_login() -> void:
	if is_unlocked():
		report(&"login")


func _give(items: Dictionary) -> Dictionary:
	Loot.grant(items)
	changed.emit()
	if autosave_on_claim:
		SaveManager.save_game()
	return items


func _on_encounter_cleared(encounter: Resource, info: Dictionary) -> void:
	var data := encounter as EncounterData
	if data == null:
		return
	report(&"battle_won")
	if data.kind != EncounterData.Kind.NORMAL:
		report(&"elite_or_boss")
	if data.is_boss():
		report(&"boss_defeated", 1, data.id)
		if bool(info.get("hard", false)):
			report(&"hard_boss_defeated")


func _on_character_upgraded(character_id: StringName) -> void:
	report(&"upgrade")
	report(&"max_level", Progression.get_level(character_id))
	var best := 0
	for key in Progression.SKILL_KEYS:
		best = maxi(best, Progression.get_skill_level(character_id, key))
	report(&"max_skill", best)


func _on_story_flag_set(flag: StringName, value: Variant) -> void:
	if not bool(value):
		return
	if flag == config.unlock_flag:
		_report_login()
		changed.emit()
	for chapter in range(1, config.chapter_count + 1):
		if flag == StringName("chapter_%d_complete" % chapter) and not granted_chapters.has(chapter):
			granted_chapters.append(chapter)
			Loot.grant(config.chapter_reward)
			EventBus.toast_requested.emit(tr("QUEST_TOAST_CHAPTER") % chapter)
			changed.emit()


static func _int_array(value: Variant) -> Array[int]:
	var result: Array[int] = []
	if value is Array:
		for v: Variant in value:
			result.append(int(v))
	return result


static func _dict(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if value is Dictionary:
		for key: Variant in value:
			result[str(key)] = int(value[key])
	return result
