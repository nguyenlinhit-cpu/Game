class_name QuestScreen
extends VBoxContainer
## Màn nhiệm vụ: thẻ Ngày / Tuần / Thành tựu / Người mới, mỗi thẻ có chấm đỏ khi còn thưởng chưa nhận.
## Ngày: điểm Hoạt Động, 5 mốc thưởng (bấm nhận), 6 nhiệm vụ. Tuần: 3 nhiệm vụ + thưởng chung.
## Thành tựu (kể cả khám phá 100% khu) và quà đăng nhập 7 ngày: bấm nhận từng mục.

const TAB_KEYS: Dictionary = {
	QuestData.Type.DAILY: "QUEST_TAB_DAILY", QuestData.Type.WEEKLY: "QUEST_TAB_WEEKLY",
	QuestData.Type.ACHIEVEMENT: "QUEST_TAB_ACHIEVEMENT", QuestData.Type.NEWBIE: "QUEST_TAB_NEWBIE",
}
const DONE_COLOR := Color("6fdc8c")
const DIM_COLOR := Color(0.7, 0.7, 0.75)

var tab: QuestData.Type = QuestData.Type.DAILY

var _tab_buttons: Dictionary = {}
var _tab_dots: Dictionary = {}
var _header: Label
var _list: VBoxContainer
## Nút nhận đang hiện, khóa theo mục (test bấm): "milestone_<i>", "weekly", "<quest id>".
var _claim_buttons: Dictionary = {}


func _ready() -> void:
	add_theme_constant_override("separation", 14)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	add_child(tabs)
	for key: int in TAB_KEYS:
		var button := UiKit.make_button(tr(TAB_KEYS[key]), show_tab.bind(key), Vector2(200.0, 52.0))
		button.toggle_mode = true
		tabs.add_child(button)
		_tab_buttons[key] = button
		_tab_dots[key] = UiKit.attach_red_dot(button)
	_header = UiKit.make_label("", 24, UiKit.GOLD)
	add_child(_header)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 10)
	scroll.add_child(_list)
	QuestManager.changed.connect(func() -> void:
		if is_visible_in_tree():
			refresh())
	show_tab(tab)


func show_tab(value: int) -> void:
	tab = value as QuestData.Type
	refresh()


func has_tab_dot(type: QuestData.Type) -> bool:
	return (_tab_dots[type] as Control).visible


func get_claim_button(key: String) -> Button:
	return _claim_buttons.get(key)


func refresh() -> void:
	if _list == null:
		return
	QuestManager.check_reset()
	for key: int in _tab_buttons:
		(_tab_buttons[key] as Button).set_pressed_no_signal(key == tab)
		(_tab_dots[key] as Control).visible = QuestManager.has_claimable(key)
	UiKit.clear(_list)
	_claim_buttons.clear()
	match tab:
		QuestData.Type.DAILY:
			_build_daily()
		QuestData.Type.WEEKLY:
			_build_weekly()
		QuestData.Type.ACHIEVEMENT:
			_header.text = ""
			for quest in QuestManager.config.get_quests(QuestData.Type.ACHIEVEMENT):
				_add_claim_row(quest)
		QuestData.Type.NEWBIE:
			_header.text = tr("QUEST_LOGIN_DAYS") % QuestManager.login_days
			for quest in QuestManager.config.get_quests(QuestData.Type.NEWBIE):
				_add_claim_row(quest)


func _build_daily() -> void:
	if not QuestManager.is_unlocked():
		_header.text = ""
		_list.add_child(UiKit.make_label(tr("QUEST_LOCKED"), 26, DIM_COLOR))
		return
	_header.text = "%s    %s" % [tr("QUEST_ACTIVITY") % [QuestManager.activity_points, QuestManager.get_daily_total()],
			tr("QUEST_RESET_IN") % _format_time(QuestManager.seconds_until_daily_reset())]
	var milestones := HBoxContainer.new()
	milestones.add_theme_constant_override("separation", 10)
	_list.add_child(milestones)
	var config := QuestManager.config
	for i in config.daily_milestones.size():
		var box := VBoxContainer.new()
		box.custom_minimum_size = Vector2(250.0, 0.0)
		var reached := QuestManager.activity_points >= config.daily_milestones[i]
		box.add_child(UiKit.make_label(tr("QUEST_MILESTONE") % config.daily_milestones[i], 22,
				UiKit.GOLD if reached else DIM_COLOR))
		var rewards := UiKit.make_label("\n".join(Loot.describe(config.daily_milestone_rewards[i])), 18)
		rewards.custom_minimum_size = Vector2(0.0, 124.0)
		box.add_child(rewards)
		var claimed := QuestManager.claimed_milestones.has(config.daily_milestones[i])
		box.add_child(_claim_button("milestone_%d" % i, QuestManager.is_milestone_claimable(i), claimed,
				func() -> Dictionary: return QuestManager.claim_milestone(i)))
		milestones.add_child(box)
	for quest in config.get_quests(QuestData.Type.DAILY):
		var row := _row(quest)
		row.add_child(UiKit.make_label(tr("QUEST_ACTIVITY_SHORT") % quest.activity, 22, UiKit.GOLD))


func _build_weekly() -> void:
	if not QuestManager.is_unlocked():
		_header.text = ""
		_list.add_child(UiKit.make_label(tr("QUEST_LOCKED"), 26, DIM_COLOR))
		return
	_header.text = tr("QUEST_RESET_IN") % _format_time(QuestManager.seconds_until_weekly_reset())
	for quest in QuestManager.config.get_quests(QuestData.Type.WEEKLY):
		_row(quest)
	var reward := HBoxContainer.new()
	reward.add_theme_constant_override("separation", 16)
	_list.add_child(reward)
	var label := UiKit.make_label("%s: %s" % [tr("QUEST_WEEKLY_REWARD"),
			", ".join(Loot.describe(QuestManager.config.weekly_reward))], 22, UiKit.GOLD)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reward.add_child(label)
	reward.add_child(_claim_button("weekly", QuestManager.is_weekly_claimable(), QuestManager.weekly_claimed,
			QuestManager.claim_weekly))


## Dòng nhiệm vụ: tên + tiến độ (trả về hàng để thêm cột).
func _row(quest: QuestData) -> HBoxContainer:
	var panel := UiKit.make_panel(Color(0.1, 0.09, 0.17, 0.95))
	_list.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	panel.add_child(row)
	var done := QuestManager.is_completed(quest)
	var name_label := UiKit.make_label(("✓ " if done else "") + tr(quest.name_key), 24, DONE_COLOR if done else Color.WHITE)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(name_label)
	var progress := mini(QuestManager.get_progress(quest), quest.target)
	row.add_child(UiKit.make_label(tr("QUEST_PROGRESS") % [progress, quest.target], 22, DIM_COLOR))
	return row


## Thành tựu / quà đăng nhập: dòng + phần thưởng + nút nhận.
func _add_claim_row(quest: QuestData) -> void:
	var row := _row(quest)
	var rewards := UiKit.make_label(", ".join(Loot.describe(quest.rewards)), 20, UiKit.GOLD)
	rewards.custom_minimum_size = Vector2(380.0, 0.0)
	rewards.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(rewards)
	row.add_child(_claim_button(String(quest.id), QuestManager.is_quest_claimable(quest), QuestManager.is_claimed(quest),
			func() -> Dictionary: return QuestManager.claim_quest(quest.id)))


func _claim_button(key: String, claimable: bool, claimed: bool, claim: Callable) -> Button:
	var text := tr("QUEST_CLAIMED") if claimed else (tr("QUEST_CLAIM") if claimable else tr("QUEST_NOT_DONE"))
	var button := UiKit.make_button(text, Callable(), Vector2(160.0, 52.0))
	button.disabled = not claimable
	button.pressed.connect(func() -> void:
		var items: Dictionary = claim.call()
		if not items.is_empty():
			EventBus.toast_requested.emit("%s: %s" % [tr("QUEST_TOAST_CLAIMED"), ", ".join(Loot.describe(items))])
		refresh())
	if claimable:
		UiKit.attach_red_dot(button).show()
	_claim_buttons[key] = button
	return button


static func _format_time(seconds: int) -> String:
	var hours := seconds / 3600
	if hours >= 24:
		return TranslationServer.translate("QUEST_TIME_DAYS") % [hours / 24, hours % 24]
	return TranslationServer.translate("QUEST_TIME") % [hours, (seconds % 3600) / 60]
