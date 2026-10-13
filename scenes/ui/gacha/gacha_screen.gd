class_name GachaScreen
extends HBoxContainer
## Màn Ước Nguyện (mục 10): chọn banner, tranh banner, nút Quay 1 / Quay 10, bảng bên phải đổi giữa
## Tỉ lệ & bảo hiểm / Lịch sử / Cửa hàng Bụi Sao / Chọn 5★ (banner thường sau 300 lượt).
## Thiếu vé mà đủ Lệ Tinh: hỏi đổi Lệ Tinh rồi quay. Gacha chưa mở (trước hết Chương 1) thì khóa nút quay.

enum Pane { DETAILS, HISTORY, SHOP, SELECTOR }

var banner_id: StringName = &""
var side: Pane = Pane.DETAILS
## Màn kết quả đang mở (test đọc).
var overlay: GachaPullOverlay
## Hộp hỏi đổi Lệ Tinh đang mở.
var confirm_box: Control

var _tab_box: HBoxContainer
var _tab_buttons: Dictionary = {}
var _art: GachaArt.BannerArt
var _lock_label: Label
var _unlock_button: Button
var _pity_label: RichTextLabel
var _pull_buttons: Dictionary = {}
var _side_buttons: Dictionary = {}
var _selector_dot: Control
var _currency_label: RichTextLabel
var _side_title: Label
var _side_list: VBoxContainer
## Nút mua ở cửa hàng theo id vật phẩm (test bấm).
var _shop_buttons: Dictionary = {}


func _ready() -> void:
	add_theme_constant_override("separation", 20)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.7
	left.add_theme_constant_override("separation", 12)
	add_child(left)
	_tab_box = HBoxContainer.new()
	_tab_box.add_theme_constant_override("separation", 8)
	left.add_child(_tab_box)
	for banner in GachaManager.get_banners():
		var button := UiKit.make_button(tr(banner.name_key), select_banner.bind(banner.id), Vector2(320.0, 56.0))
		button.toggle_mode = true
		_tab_box.add_child(button)
		_tab_buttons[banner.id] = button
	var art_holder := Control.new()
	art_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	art_holder.custom_minimum_size = Vector2(0.0, 420.0)
	left.add_child(art_holder)
	_art = GachaArt.BannerArt.new()
	_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_holder.add_child(_art)
	var lock_box := VBoxContainer.new()
	lock_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	lock_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	lock_box.grow_vertical = Control.GROW_DIRECTION_BOTH
	art_holder.add_child(lock_box)
	_lock_label = UiKit.make_label(tr("GACHA_LOCKED"), 30, UiKit.GOLD)
	_lock_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_lock_label.add_theme_constant_override("outline_size", 8)
	lock_box.add_child(_lock_label)
	if OS.is_debug_build():
		_unlock_button = UiKit.make_button(tr("GACHA_DEBUG_UNLOCK"), _debug_unlock, Vector2(320.0, 56.0))
		_unlock_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		lock_box.add_child(_unlock_button)
	_pity_label = UiKit.make_rich(22)
	left.add_child(_pity_label)
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 10)
	left.add_child(bottom)
	for entry: Array in [[Pane.DETAILS, "GACHA_DETAILS"], [Pane.HISTORY, "GACHA_HISTORY"], [Pane.SHOP, "GACHA_SHOP"]]:
		var button := UiKit.make_button(tr(entry[1]), show_side.bind(entry[0]), Vector2(150.0, 72.0))
		button.toggle_mode = true
		bottom.add_child(button)
		_side_buttons[entry[0]] = button
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(spacer)
	for count: int in [1, 10]:
		var button := UiKit.make_button("", request_pull.bind(count), Vector2(200.0, 72.0))
		bottom.add_child(button)
		_pull_buttons[count] = button

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(560.0, 0.0)
	right.add_theme_constant_override("separation", 12)
	add_child(right)
	var wallet := UiKit.make_panel(Color(0.1, 0.09, 0.18, 0.95))
	right.add_child(wallet)
	_currency_label = UiKit.make_rich(22)
	wallet.add_child(_currency_label)
	var side_panel := UiKit.make_panel(Color(0.1, 0.09, 0.18, 0.95))
	side_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(side_panel)
	var side_box := VBoxContainer.new()
	side_box.add_theme_constant_override("separation", 10)
	side_panel.add_child(side_box)
	var side_header := HBoxContainer.new()
	side_box.add_child(side_header)
	_side_title = UiKit.make_label("", 28, UiKit.GOLD)
	_side_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_header.add_child(_side_title)
	var selector_button := UiKit.make_button(tr("GACHA_SELECTOR"), show_side.bind(Pane.SELECTOR), Vector2(0.0, 48.0))
	selector_button.toggle_mode = true
	side_header.add_child(selector_button)
	_side_buttons[Pane.SELECTOR] = selector_button
	_selector_dot = UiKit.attach_red_dot(selector_button)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	side_box.add_child(scroll)
	_side_list = VBoxContainer.new()
	_side_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_side_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_side_list)

	GachaManager.changed.connect(func() -> void:
		if is_visible_in_tree():
			refresh())
	EventBus.inventory_changed.connect(func(_id: StringName, _count: int) -> void:
		if is_visible_in_tree():
			_refresh_wallet())
	var banners := GachaManager.get_banners()
	if not banners.is_empty():
		select_banner(banners[0].id)


func get_banner() -> BannerData:
	return GachaManager.get_banner(banner_id)


func select_banner(id: StringName) -> void:
	banner_id = id
	if side == Pane.SELECTOR and not _has_selector():
		side = Pane.DETAILS
	refresh()


func show_side(value: int) -> void:
	side = value as Pane
	refresh()


func get_pull_button(count: int) -> Button:
	return _pull_buttons.get(count)


func get_shop_button(item_id: StringName) -> Button:
	return _shop_buttons.get(item_id)


func refresh() -> void:
	var banner := get_banner()
	if banner == null:
		return
	GachaManager.refresh_shop()
	for id: StringName in _tab_buttons:
		(_tab_buttons[id] as Button).set_pressed_no_signal(id == banner_id)
	for key: int in _side_buttons:
		(_side_buttons[key] as Button).set_pressed_no_signal(key == side)
	_art.set_banner(banner)
	var unlocked := GachaManager.is_unlocked()
	_lock_label.get_parent().visible = not unlocked
	for count: int in _pull_buttons:
		var button: Button = _pull_buttons[count]
		button.text = "%s\n%s" % [tr("GACHA_PULL_%d" % count), tr("GACHA_TICKET_COST") % count]
		button.disabled = not unlocked
	(_side_buttons[Pane.SELECTOR] as Button).visible = _has_selector()
	_selector_dot.visible = GachaManager.can_claim_selector(banner)
	_refresh_pity(banner)
	_refresh_wallet()
	_refresh_side(banner)


func _has_selector() -> bool:
	var banner := get_banner()
	return banner != null and banner.selector_pulls > 0


func _refresh_pity(banner: BannerData) -> void:
	var state := GachaManager.get_pity(banner)
	var lines: Array[String] = []
	lines.append(tr("GACHA_PITY_5") % [int(state["pity_5"]), banner.hard_pity_5])
	lines.append(tr("GACHA_PITY_4") % [int(state["pity_4"]), banner.hard_pity_4])
	if banner.is_limited():
		lines.append(tr("GACHA_GUARANTEED") if bool(state["guaranteed_5"]) else tr("GACHA_5050"))
	if banner.selector_pulls > 0:
		lines.append(tr("GACHA_SELECTOR_PROGRESS") % [GachaManager.selector_progress(banner), banner.selector_pulls]
				if not GachaManager.selector_claimed.has(String(banner.id)) else tr("GACHA_SELECTOR_DONE"))
	_pity_label.text = "    ".join(lines)


func _refresh_wallet() -> void:
	var parts: Array[String] = []
	for item_id: StringName in [GachaManager.config.currency_item, &"wish_ticket_limited", &"wish_ticket_standard",
			GachaManager.config.stardust_item]:
		parts.append("%s: [color=#%s]%d[/color]" % [UiKit.item_name(item_id), UiKit.GOLD.to_html(false),
				GameState.get_item_count(item_id)])
	_currency_label.text = "\n".join(parts)


func _refresh_side(banner: BannerData) -> void:
	UiKit.clear(_side_list)
	_shop_buttons.clear()
	match side:
		Pane.DETAILS:
			_side_title.text = tr("GACHA_DETAILS")
			_build_details(banner)
		Pane.HISTORY:
			_side_title.text = tr("GACHA_HISTORY")
			_build_history(banner)
		Pane.SHOP:
			_side_title.text = tr("GACHA_SHOP")
			_build_shop()
		Pane.SELECTOR:
			_side_title.text = tr("GACHA_SELECTOR")
			_build_selector(banner)


func _add_text(text: String, font_size: int = 20) -> RichTextLabel:
	var rich := UiKit.make_rich(font_size)
	rich.text = text
	_side_list.add_child(rich)
	return rich


func _names(ids: Array[StringName]) -> String:
	var names: Array[String] = []
	for id in ids:
		var data := GachaManager.get_character(id)
		names.append(UiKit.character_name(data) if data else String(id))
	return ", ".join(names)


func _build_details(banner: BannerData) -> void:
	var gold := UiKit.GOLD.to_html(false)
	_add_text(tr("GACHA_RATES") % [banner.base_rate_5 * 100.0, banner.soft_pity_start, banner.soft_pity_step * 100.0,
			banner.hard_pity_5, banner.base_rate_4 * 100.0, banner.hard_pity_4])
	if banner.is_limited():
		_add_text(tr("GACHA_RULE_FEATURED_5") % [gold, _names(banner.featured_5), roundi(banner.featured_5_chance * 100.0)])
		_add_text(tr("GACHA_RULE_FEATURED_4") % [gold, _names(banner.featured_4), roundi(banner.featured_4_chance * 100.0)])
		_add_text(tr("GACHA_RULE_INHERIT"))
	else:
		_add_text(tr("GACHA_RULE_SELECTOR") % banner.selector_pulls)
	_add_text("[color=#%s]%s[/color] %s" % [gold, tr("GACHA_POOL_5"), _names(banner.pool_5)])
	_add_text("[color=#%s]%s[/color] %s" % [gold, tr("GACHA_POOL_4"), _names(banner.pool_4)])
	var rewards: Array[String] = []
	for entry in banner.three_star_rewards:
		rewards.append("%s ×%d" % [UiKit.item_name(StringName(str(entry["item"]))), int(entry.get("count", 1))])
	_add_text("[color=#%s]%s[/color] %s" % [gold, tr("GACHA_POOL_3"), ", ".join(rewards)])
	var config := GachaManager.config
	_add_text(tr("GACHA_RULE_DUPES") % [int(config.dupe_stardust.get(5, 0)), int(config.dupe_stardust.get(4, 0)),
			int(config.overflow_stardust.get(5, 0)), int(config.overflow_stardust.get(4, 0))])
	_add_text(tr("GACHA_RULE_TICKETS") % [config.currency_per_ticket, UiKit.item_name(config.currency_item),
			UiKit.item_name(banner.ticket_item)])


func _build_history(banner: BannerData) -> void:
	var entries := GachaManager.get_history(banner.id)
	if entries.is_empty():
		_add_text(tr("GACHA_HISTORY_EMPTY"))
		return
	var lines: Array[String] = []
	for i in entries.size():
		var entry: Dictionary = entries[i]
		var rarity := int(entry.get("rarity", 3))
		var label := ""
		if entry.has("character"):
			var data := GachaManager.get_character(StringName(str(entry["character"])))
			label = UiKit.character_name(data) if data else str(entry["character"])
		else:
			label = ", ".join(Loot.describe(entry.get("items", {})))
		var time := Time.get_datetime_string_from_unix_time(int(entry.get("time", 0)), true).left(16)
		lines.append("[color=#888899]%3d[/color]  [color=#%s]%s %s[/color]  [color=#888899]%s[/color]" % [i + 1,
				GachaPullOverlay.rarity_color(rarity).to_html(false), "★".repeat(rarity), label, time])
	_add_text("\n".join(lines), 19)


func _build_shop() -> void:
	var config := GachaManager.config
	var days := GachaManager.seconds_until_shop_reset() / 86400.0
	_add_text(tr("GACHA_SHOP_INFO") % [UiKit.item_name(config.stardust_item),
			GameState.get_item_count(config.stardust_item), days])
	for entry in config.shop_entries:
		var item_id := StringName(str(entry["item"]))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		_side_list.add_child(row)
		var info := UiKit.make_rich(20)
		info.text = "%s ×%d\n[color=#aaaabb]%s[/color]" % [UiKit.item_name(item_id), int(entry.get("count", 1)),
				tr("GACHA_SHOP_LIMIT") % [GachaManager.get_shop_remaining(item_id), int(entry.get("monthly_limit", 0))]]
		row.add_child(info)
		var button := UiKit.make_button("%d %s" % [int(entry.get("price", 0)), UiKit.item_name(config.stardust_item)],
				_buy.bind(item_id), Vector2(200.0, 56.0))
		button.disabled = not GachaManager.can_buy(item_id)
		row.add_child(button)
		_shop_buttons[item_id] = button


func _build_selector(banner: BannerData) -> void:
	var claimable := GachaManager.can_claim_selector(banner)
	if GachaManager.selector_claimed.has(String(banner.id)):
		_add_text(tr("GACHA_SELECTOR_DONE"))
		return
	_add_text(tr("GACHA_SELECTOR_INFO") % [banner.selector_pulls, GachaManager.selector_progress(banner),
			banner.selector_pulls])
	for id in banner.pool_5:
		var data := GachaManager.get_character(id)
		if data == null:
			continue
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		_side_list.add_child(row)
		row.add_child(UiKit.Portrait.new(data, 64.0))
		var label := UiKit.make_label("%s · E%d" % [UiKit.character_name(data), GameState.get_eidolon_level(id)]
				if GameState.owned_characters.has(id) else UiKit.character_name(data), 22)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var button := UiKit.make_button(tr("GACHA_SELECTOR_PICK"), _claim_selector.bind(id), Vector2(140.0, 52.0))
		button.disabled = not claimable
		row.add_child(button)


func _buy(item_id: StringName) -> void:
	if GachaManager.buy(item_id):
		EventBus.toast_requested.emit(tr("GACHA_TOAST_BOUGHT") % UiKit.item_name(item_id))


func _claim_selector(id: StringName) -> void:
	var result := GachaManager.claim_selector(banner_id, id)
	if not result.is_empty():
		_open_overlay([result] as Array[Dictionary])


## Bấm Quay: đủ vé thì quay ngay; thiếu vé mà đủ Lệ Tinh thì hỏi đổi; thiếu cả hai thì báo.
func request_pull(count: int) -> void:
	var banner := get_banner()
	if banner == null or not GachaManager.is_unlocked() or overlay != null:
		return
	var missing := GachaManager.tickets_missing(banner, count)
	if missing == 0:
		_do_pull(count)
		return
	if not GachaManager.can_afford(banner, count):
		EventBus.toast_requested.emit(tr("GACHA_TOAST_NOT_ENOUGH") % [UiKit.item_name(banner.ticket_item),
				UiKit.item_name(GachaManager.config.currency_item)])
		return
	_ask_exchange(banner, count, missing)


func _do_pull(count: int) -> void:
	var results := GachaManager.pull(banner_id, count)
	if not results.is_empty():
		_open_overlay(results)


func _open_overlay(results: Array[Dictionary]) -> void:
	overlay = GachaPullOverlay.new()
	overlay.setup(results)
	overlay.closed.connect(func() -> void:
		overlay = null
		refresh())
	add_child(overlay)


## Hộp hỏi "Đổi X Lệ Tinh lấy Y vé rồi quay?" (phủ toàn màn hình).
func _ask_exchange(banner: BannerData, count: int, missing: int) -> void:
	confirm_box = Control.new()
	confirm_box.top_level = true
	confirm_box.size = get_viewport_rect().size
	confirm_box.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(confirm_box)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	confirm_box.add_child(dim)
	var panel := UiKit.make_panel()
	panel.custom_minimum_size = Vector2(760.0, 0.0)
	panel.position = confirm_box.size * 0.5 - Vector2(380.0, 140.0)
	confirm_box.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	var cost := GachaManager.exchange_cost(missing)
	var text := UiKit.make_rich(26)
	text.text = tr("GACHA_EXCHANGE_ASK") % [cost, UiKit.item_name(GachaManager.config.currency_item), missing,
			UiKit.item_name(banner.ticket_item), GameState.get_item_count(GachaManager.config.currency_item)]
	box.add_child(text)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	box.add_child(row)
	row.add_child(UiKit.make_button(tr("UI_CONFIRM"), confirm_exchange.bind(count), Vector2(220.0, 60.0)))
	row.add_child(UiKit.make_button(tr("UI_BACK"), _close_confirm, Vector2(220.0, 60.0)))


## Đồng ý đổi Lệ Tinh rồi quay.
func confirm_exchange(count: int) -> void:
	_close_confirm()
	var banner := get_banner()
	var missing := GachaManager.tickets_missing(banner, count)
	if missing > 0 and not GachaManager.exchange_tickets(banner.ticket_item, missing):
		return
	_do_pull(count)


func _close_confirm() -> void:
	if confirm_box:
		confirm_box.queue_free()
		confirm_box = null


func _debug_unlock() -> void:
	GameState.set_story_flag(GachaManager.config.unlock_flag)
	refresh()


## Đang có lớp phủ (kết quả quay / hộp hỏi) thì menu không đóng khi bấm Esc.
func is_busy() -> bool:
	return overlay != null or confirm_box != null


func close_popups() -> void:
	if overlay:
		overlay.skip()
		overlay.close()
	_close_confirm()
