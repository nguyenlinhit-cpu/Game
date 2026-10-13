class_name GameMenu
extends Control
## Menu nhân vật (mở từ menu tạm dừng): thẻ Nhân vật (danh sách → chi tiết), Đội hình, Túi đồ, Nhiệm vụ, Ước Nguyện.
## Đổi đội hình thì khi đóng menu, map được nạp lại với đội mới.

signal closed

enum Page { CHARACTERS, TEAM, INVENTORY, QUESTS, GACHA }

var page: Page = Page.CHARACTERS
var character_list: CharacterListScreen
var character_detail: CharacterDetailScreen
var team_screen: TeamScreen
var inventory_screen: InventoryScreen
var quest_screen: QuestScreen
var gacha_screen: GachaScreen

var _team_changed: bool = false
var _page_buttons: Dictionary = {}
var _quest_dot: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := UiKit.make_panel()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 40)
	add_child(panel)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 18)
	panel.add_child(root)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	root.add_child(top)
	for key: int in Page.values():
		var button := UiKit.make_button(tr(["MENU_CHARACTERS", "MENU_TEAM", "MENU_INVENTORY", "MENU_QUESTS", "MENU_GACHA"][key]),
				show_page.bind(key), Vector2(240.0, 60.0))
		button.toggle_mode = true
		top.add_child(button)
		_page_buttons[key] = button
	_quest_dot = UiKit.attach_red_dot(_page_buttons[Page.QUESTS])
	_quest_dot.visible = QuestManager.has_any_claimable()
	QuestManager.changed.connect(func() -> void: _quest_dot.visible = QuestManager.has_any_claimable())
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	top.add_child(UiKit.make_button(tr("UI_CLOSE"), close, Vector2(160.0, 60.0)))
	var body := Control.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	character_list = CharacterListScreen.new()
	character_detail = CharacterDetailScreen.new()
	team_screen = TeamScreen.new()
	inventory_screen = InventoryScreen.new()
	quest_screen = QuestScreen.new()
	gacha_screen = GachaScreen.new()
	for screen: Control in [character_list, character_detail, team_screen, inventory_screen, quest_screen, gacha_screen]:
		screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		body.add_child(screen)
	character_list.character_selected.connect(open_character)
	character_detail.back_requested.connect(func() -> void: show_page(Page.CHARACTERS))
	team_screen.team_applied.connect(func() -> void: _team_changed = true)
	show_page(Page.CHARACTERS)


func show_page(value: int) -> void:
	page = value as Page
	for key: int in _page_buttons:
		(_page_buttons[key] as Button).set_pressed_no_signal(key == page)
	character_list.visible = page == Page.CHARACTERS
	character_detail.visible = false
	team_screen.visible = page == Page.TEAM
	inventory_screen.visible = page == Page.INVENTORY
	quest_screen.visible = page == Page.QUESTS
	gacha_screen.visible = page == Page.GACHA
	match page:
		Page.CHARACTERS:
			character_list.refresh()
		Page.TEAM:
			team_screen.select_preset(GameState.active_preset)
		Page.INVENTORY:
			inventory_screen.refresh()
		Page.QUESTS:
			quest_screen.refresh()
		Page.GACHA:
			gacha_screen.refresh()


func open_character(id: StringName) -> void:
	show_page(Page.CHARACTERS)
	character_list.visible = false
	character_detail.visible = true
	character_detail.open(id)


func is_team_changed() -> bool:
	return _team_changed


func close() -> void:
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if gacha_screen.visible and gacha_screen.is_busy():
			gacha_screen.close_popups()
		elif character_detail.visible:
			show_page(Page.CHARACTERS)
		else:
			close()
