class_name CharacterDetailScreen
extends VBoxContainer
## Chi tiết một nhân vật: đầu trang (tên, hạng, nguyên tố, vận mệnh, cấp, thanh EXP) và 4 thẻ:
## Chỉ số (lên cấp bằng Ký Ức, đột phá), Kỹ năng (nâng cấp 4 kỹ năng), Tinh Mệnh, Cây vận mệnh.
## Các hàm công khai (level_up, ascend, upgrade_skill, unlock_trace...) được nút bấm và test cùng gọi.

signal back_requested

enum Tab { STATS, SKILLS, EIDOLONS, TRACES }

const PERCENT_STATS: Array[int] = [Stats.Type.CRIT_RATE, Stats.Type.CRIT_DMG, Stats.Type.BREAK_EFFECT,
		Stats.Type.ENERGY_REGEN, Stats.Type.EFFECT_HIT, Stats.Type.EFFECT_RES, Stats.Type.OUTGOING_HEALING]

var character_id: StringName
var current_tab: Tab = Tab.STATS

var _header: Label
var _sub_header: Label
var _exp_bar: ProgressBar
var _exp_label: Label
var _tab_buttons: Dictionary = {}
var _content: VBoxContainer
var _message: Label


func _ready() -> void:
	add_theme_constant_override("separation", 12)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	add_child(top)
	top.add_child(UiKit.make_button(tr("UI_BACK"), func() -> void: back_requested.emit(), Vector2(140.0, 56.0)))
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(titles)
	_header = UiKit.make_label("", 36)
	titles.add_child(_header)
	_sub_header = UiKit.make_label("", 22, Color(0.85, 0.85, 0.9))
	titles.add_child(_sub_header)
	var exp_box := VBoxContainer.new()
	exp_box.custom_minimum_size = Vector2(420.0, 0.0)
	top.add_child(exp_box)
	_exp_label = UiKit.make_label("", 20)
	exp_box.add_child(_exp_label)
	_exp_bar = ProgressBar.new()
	_exp_bar.show_percentage = false
	_exp_bar.custom_minimum_size = Vector2(0.0, 18.0)
	var back := UiKit.panel_style(Color(0.15, 0.13, 0.22), Color(1, 1, 1, 0.3), 6)
	back.set_content_margin_all(0)
	_exp_bar.add_theme_stylebox_override("background", back)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("7fb6ff")
	fill.set_corner_radius_all(6)
	_exp_bar.add_theme_stylebox_override("fill", fill)
	exp_box.add_child(_exp_bar)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	add_child(tabs)
	for tab: int in [Tab.STATS, Tab.SKILLS, Tab.EIDOLONS, Tab.TRACES]:
		var button := UiKit.make_button(tr(["DETAIL_TAB_STATS", "DETAIL_TAB_SKILLS", "DETAIL_TAB_EIDOLONS",
				"DETAIL_TAB_TRACES"][tab]), show_tab.bind(tab), Vector2(220.0, 52.0))
		button.toggle_mode = true
		tabs.add_child(button)
		_tab_buttons[tab] = button
	_message = UiKit.make_label("", 22, UiKit.GOLD)
	add_child(_message)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 10)
	scroll.add_child(_content)
	EventBus.inventory_changed.connect(func(_id: StringName, _c: int) -> void: _refresh_if_visible())


func open(id: StringName) -> void:
	character_id = id
	_message.text = ""
	show_tab(current_tab)


func show_tab(tab: Tab) -> void:
	current_tab = tab
	for key: int in _tab_buttons:
		(_tab_buttons[key] as Button).set_pressed_no_signal(key == tab)
	refresh()


func get_message() -> String:
	return _message.text


func _refresh_if_visible() -> void:
	if is_visible_in_tree() and character_id != &"":
		refresh()


func refresh() -> void:
	if character_id == &"" or _content == null:
		return
	var data := DataPaths.load_character(character_id)
	_header.text = "%s  %s" % [UiKit.character_name(data), "★".repeat(data.rarity)]
	_header.add_theme_color_override("font_color", Element.color(data.element).lightened(0.3))
	_sub_header.text = "%s · %s · %s" % [tr(Element.name_key(data.element)), tr(CharacterPath.NAME_KEYS[data.path]),
			tr("DETAIL_ASCENSION") % Progression.get_ascension(character_id)]
	var level := Progression.get_level(character_id)
	var cap := Progression.get_level_cap(character_id)
	var need := Progression.config().exp_for_level(level) if level < cap else 0
	_exp_label.text = tr("DETAIL_LEVEL") % [level, cap] + ("   EXP %d/%d" % [Progression.get_exp(character_id), need] if need > 0 else "")
	_exp_bar.max_value = maxf(need, 1.0)
	_exp_bar.value = Progression.get_exp(character_id) if need > 0 else _exp_bar.max_value
	UiKit.clear(_content)
	match current_tab:
		Tab.STATS:
			_build_stats(data)
		Tab.SKILLS:
			_build_skills(data)
		Tab.EIDOLONS:
			_build_eidolons(data)
		Tab.TRACES:
			_build_traces(data)


# --- Hành động (nút bấm và test) ---

## Dùng Ký Ức để lên `levels` cấp (dừng ở giới hạn). Dùng loại lớn trước, phần lẻ bù bằng loại nhỏ nhất đủ.
func level_up(levels: int = 1) -> bool:
	var target := mini(Progression.get_level(character_id) + levels, Progression.get_level_cap(character_id))
	var need := -Progression.get_exp(character_id)
	for lv in range(Progression.get_level(character_id), target):
		need += Progression.config().exp_for_level(lv)
	if need <= 0:
		return _report({"ok": false, "reason": "PROG_ERR_NEED_ASCEND" if Progression.needs_ascension(character_id)
				else "PROG_ERR_MAX_LEVEL"})
	var plan: Dictionary = {}
	var items := Progression.EXP_ITEMS.duplicate()
	items.reverse()
	for item_id: StringName in items:
		var value := UiKit.get_item(item_id).exp_value
		var count := mini(GameState.get_item_count(item_id), need / value)
		if count > 0:
			plan[item_id] = count
			need -= count * value
	if need > 0:
		for item_id in Progression.EXP_ITEMS:
			if GameState.get_item_count(item_id) > int(plan.get(item_id, 0)):
				plan[item_id] = int(plan.get(item_id, 0)) + 1
				need = 0
				break
	if need > 0 or plan.is_empty():
		return _report({"ok": false, "reason": "PROG_ERR_NOT_ENOUGH"})
	var gained := 0
	for item_id: StringName in plan:
		var result := Progression.try_use_exp_items(character_id, item_id, plan[item_id])
		if not result["ok"]:
			if gained > 0:
				break
			return _report(result)
		gained += int(result["levels"])
	return _report({"ok": true, "levels": gained})


func use_exp_item(item_id: StringName, count: int = 1) -> bool:
	return _report(Progression.try_use_exp_items(character_id, item_id, count))


func ascend() -> bool:
	return _report(Progression.try_ascend(character_id))


func upgrade_skill(skill_key: String) -> bool:
	return _report(Progression.try_upgrade_skill(character_id, skill_key))


func unlock_trace(node_id: StringName) -> bool:
	return _report(Progression.try_unlock_trace(character_id, node_id))


func _report(result: Dictionary) -> bool:
	if result.get("ok", false):
		_message.text = tr("PROG_DONE")
		if result.has("levels") and int(result["levels"]) > 0:
			_message.text = tr("PROG_LEVELS_GAINED") % int(result["levels"])
	else:
		_message.text = tr(str(result.get("reason", "PROG_ERR_INVALID")))
	refresh()
	return bool(result.get("ok", false))


# --- Các thẻ ---

func _build_stats(data: CharacterData) -> void:
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 40)
	_content.add_child(columns)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 40)
	grid.add_theme_constant_override("v_separation", 6)
	columns.add_child(grid)
	var stats := Progression.build_stats(character_id)
	for type in Stats.CORE_STAT_COUNT:
		grid.add_child(UiKit.make_label(tr(Stats.NAME_KEYS[type]), 22, Color(0.8, 0.8, 0.85)))
		var value := stats.get_value(type)
		grid.add_child(UiKit.make_label("%.1f%%" % (value * 100.0) if type in PERCENT_STATS else str(floori(value)), 22))
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(actions)
	if Progression.needs_ascension(character_id):
		var ascension := Progression.config().get_ascension_at(Progression.get_level(character_id))
		actions.add_child(UiKit.make_label(tr("DETAIL_ASCEND_TITLE") % ascension.new_cap, 26, UiKit.GOLD))
		if ascension.is_locked():
			actions.add_child(UiKit.make_label(tr("PROG_ERR_ASCENSION_LOCKED"), 22, Color(0.75, 0.75, 0.8)))
		else:
			var cost := UiKit.make_rich()
			cost.text = UiKit.format_cost(Progression.get_ascension_cost(character_id))
			actions.add_child(cost)
			actions.add_child(UiKit.make_button(tr("DETAIL_ASCEND"), ascend, Vector2(320.0, 60.0)))
		return
	actions.add_child(UiKit.make_label(tr("DETAIL_LEVEL_UP_TITLE"), 26, UiKit.GOLD))
	for item_id in Progression.EXP_ITEMS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row.add_child(UiKit.make_label("%s ×%d" % [UiKit.item_name(item_id), GameState.get_item_count(item_id)], 22))
		var use := UiKit.make_button(tr("DETAIL_USE_ONE"), use_exp_item.bind(item_id, 1), Vector2(140.0, 48.0))
		use.disabled = GameState.get_item_count(item_id) <= 0
		row.add_child(use)
		actions.add_child(row)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	buttons.add_child(UiKit.make_button(tr("DETAIL_LEVEL_UP_ONE"), level_up.bind(1), Vector2(220.0, 60.0)))
	buttons.add_child(UiKit.make_button(tr("DETAIL_LEVEL_UP_CAP"), level_up.bind(GameConfig.MAX_LEVEL), Vector2(260.0, 60.0)))
	actions.add_child(buttons)
	actions.add_child(UiKit.make_label(tr("DETAIL_EXP_COST") % Progression.config().coin_per_exp, 18, Color(0.75, 0.75, 0.8)))


func _skill_data(data: CharacterData, skill_key: String) -> Array[String]:
	match skill_key:
		"basic":
			return [data.basic_attack.name_key, data.basic_attack.desc_key]
		"skill":
			return [data.skill.name_key, data.skill.desc_key]
		"ultimate":
			return [data.ultimate.name_key, data.ultimate.desc_key]
	return [data.talent.name_key, data.talent.desc_key]


func _build_skills(data: CharacterData) -> void:
	var cap := Progression.get_skill_cap(character_id)
	_content.add_child(UiKit.make_label(tr("DETAIL_SKILL_CAP") % [cap, Progression.config().max_skill_level], 20,
			Color(0.8, 0.8, 0.85)))
	for skill_key in Progression.SKILL_KEYS:
		var keys := _skill_data(data, skill_key)
		var level := Progression.get_skill_level(character_id, skill_key)
		var panel := UiKit.make_panel(Color(0.1, 0.09, 0.17, 0.95))
		_content.add_child(panel)
		var box := VBoxContainer.new()
		panel.add_child(box)
		var title := HBoxContainer.new()
		box.add_child(title)
		var name_label := UiKit.make_label("%s – %s" % [tr("SKILL_KIND_" + skill_key.to_upper()), tr(keys[0])], 26, UiKit.GOLD)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title.add_child(name_label)
		title.add_child(UiKit.make_label(tr("DETAIL_SKILL_LEVEL") % [level, Progression.config().max_skill_level], 24))
		var desc := UiKit.make_label(tr(keys[1]), 20, Color(0.85, 0.85, 0.9))
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(desc)
		var scale := Progression.config().multiplier_scale(level)
		box.add_child(UiKit.make_label(tr("DETAIL_SKILL_SCALE") % [roundi(scale * 100.0),
				roundi(Progression.config().status_scale(level) * 100.0)], 18, Color(0.7, 0.85, 1.0)))
		if level >= Progression.config().max_skill_level:
			continue
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		box.add_child(row)
		if level >= cap:
			row.add_child(UiKit.make_label(tr("PROG_ERR_SKILL_CAP"), 20, Color(0.75, 0.75, 0.8)))
			continue
		var cost := UiKit.make_rich(20)
		cost.text = UiKit.format_cost(Progression.get_skill_cost(character_id, skill_key))
		row.add_child(cost)
		row.add_child(UiKit.make_button(tr("DETAIL_UPGRADE"), upgrade_skill.bind(skill_key), Vector2(180.0, 52.0)))


func _build_eidolons(data: CharacterData) -> void:
	var level := GameState.get_eidolon_level(character_id)
	var source := tr("DETAIL_EIDOLON_SOURCE_STORY") % GameState.get_soul_shard_count() \
			if character_id == GameState.PLAYER_CHARACTER_ID else tr("DETAIL_EIDOLON_SOURCE_DUPLICATE")
	_content.add_child(UiKit.make_label(source, 20, Color(0.8, 0.8, 0.85)))
	for i in data.eidolons.size():
		var eidolon := data.eidolons[i]
		var unlocked := i < level
		var panel := UiKit.make_panel(Color(0.12, 0.1, 0.2, 0.95) if unlocked else Color(0.08, 0.08, 0.1, 0.9))
		_content.add_child(panel)
		var box := VBoxContainer.new()
		panel.add_child(box)
		box.add_child(UiKit.make_label("%s %d · %s  %s" % [tr("DETAIL_EIDOLON"), i + 1, tr(eidolon.name_key),
				"✓" if unlocked else "🔒"], 24, UiKit.GOLD if unlocked else Color(0.6, 0.6, 0.65)))
		var desc := UiKit.make_label(tr(eidolon.desc_key), 20, Color(0.85, 0.85, 0.9) if unlocked else Color(0.55, 0.55, 0.6))
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(desc)


func _build_traces(data: CharacterData) -> void:
	var tree := Progression.get_trace_tree(data.path)
	_content.add_child(UiKit.make_label(tr("DETAIL_TRACE_INTRO") % tr(CharacterPath.NAME_KEYS[data.path]), 20,
			Color(0.8, 0.8, 0.85)))
	for node in tree.nodes:
		var owned := Progression.has_trace(character_id, node.id)
		var panel := UiKit.make_panel(Color(0.14, 0.11, 0.2, 0.95) if node.major else Color(0.1, 0.09, 0.15, 0.95))
		_content.add_child(panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		panel.add_child(row)
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var title := tr(node.name_key) if not node.major else "◆ %s" % tr(node.name_key)
		info.add_child(UiKit.make_label(title, 24 if node.major else 22, UiKit.GOLD if owned else Color.WHITE))
		if node.major:
			var desc := UiKit.make_label(tr(node.desc_key), 20, Color(0.85, 0.85, 0.9))
			desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			info.add_child(desc)
		if owned:
			row.add_child(UiKit.make_label(tr("DETAIL_TRACE_OWNED"), 22, UiKit.OK_COLOR))
			continue
		var reason := Progression.trace_block_reason(character_id, node)
		if reason == "PROG_ERR_NEED_ASCENSION":
			row.add_child(UiKit.make_label(tr("DETAIL_NEED_ASCENSION") % node.required_ascension, 20, Color(0.7, 0.7, 0.75)))
			continue
		if reason != "":
			row.add_child(UiKit.make_label(tr(reason), 20, Color(0.7, 0.7, 0.75)))
			continue
		var cost := UiKit.make_rich(20)
		cost.custom_minimum_size = Vector2(520.0, 0.0)
		cost.size_flags_horizontal = Control.SIZE_SHRINK_END
		cost.text = UiKit.format_cost(Progression.get_trace_cost(character_id, node))
		row.add_child(cost)
		row.add_child(UiKit.make_button(tr("DETAIL_UNLOCK"), unlock_trace.bind(node.id), Vector2(160.0, 52.0)))
