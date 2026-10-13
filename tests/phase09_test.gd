extends "res://tests/test_base.gd"
## Kiểm thử Phase 9: cấp 1–30 bằng Ký Ức, 2 lần đột phá (không vượt 30), chỉ số đúng bảng tăng trưởng,
## nâng kỹ năng đổi số liệu trong trận, cây vận mệnh, Tinh Mệnh (trùng nhân vật / cờ cốt truyện), máu giữ giữa
## các trận, giao diện (danh sách + lọc, chi tiết, đội hình ≤ 4, nhiều đội hình, túi đồ), lưu/tải, lệnh debug.
## Chạy: godot --headless --path . res://tests/phase09_test.tscn

const DUMMIES: String = "res://data/encounters/sandbox_dummies.tres"


func _run() -> void:
	phase_name = "Phase 9"
	timeout_sec = 600.0
	GameState.reset_new_game()
	_test_config()
	await _test_level_to_30()
	_test_stats_growth()
	await _test_skills()
	await _test_traces()
	_test_eidolons()
	await _test_hp()
	await _test_team_screen()
	await _test_inventory_and_list()
	_test_save_load()
	await _test_pause_menu()
	_finish()


# --- Tiện ích ---

func _menu() -> GameMenu:
	var menu := GameMenu.new()
	add_child(menu)
	await _frames(1)
	return menu


func _battle(ids: Array[StringName], states: Dictionary = {}) -> BattleController:
	var controller := BattleController.new()
	controller.instant = true
	controller.crit_mode = DamageCalc.CritMode.NEVER
	controller.rng.seed = 5
	controller.ally_states = states
	add_child(controller)
	var team: Array[CharacterData] = []
	for id in ids:
		team.append(DataPaths.load_character(id))
	controller.setup(team, 10, load(DUMMIES), BattleTypes.Opening.NORMAL)
	return controller


func _free(node: Node) -> void:
	if node is BattleController:
		(node as BattleController).force_end(true)
	node.queue_free()
	await _frames(1)


func _basic_damage(controller: BattleController, unit: BattleUnit) -> float:
	var target := controller.enemies[0]
	var events := SkillExecutor.execute(controller, unit, unit.get_skill(SkillData.Kind.BASIC), target)
	var total := 0.0
	for e in events:
		if e["type"] == "damage":
			total += float(e["amount"])
	target.heal(target.get_max_hp())
	return total


# --- Cấu hình ---

func _test_config() -> void:
	print("--- Cấu hình ---")
	var cfg := Progression.config()
	_check(GameConfig.MAX_LEVEL == 30 and cfg.exp_to_next.size() >= GameConfig.DESIGN_MAX_LEVEL - 1,
			"Giới hạn cấp 30 ở GameConfig; bảng EXP có sẵn tới cấp %d" % GameConfig.DESIGN_MAX_LEVEL)
	var exp_values: Array[int] = []
	for id in Progression.EXP_ITEMS:
		exp_values.append(UiKit.get_item(id).exp_value)
	_check(exp_values == [100, 500, 2000], "Ký Ức Mảnh Hồn 3 bậc: 100 / 500 / 2000 EXP")
	var open := cfg.ascensions.filter(func(a: AscensionData) -> bool: return not a.is_locked()).map(
			func(a: AscensionData) -> int: return a.at_level)
	var locked := cfg.ascensions.filter(func(a: AscensionData) -> bool: return a.is_locked()).map(
			func(a: AscensionData) -> int: return a.at_level)
	_check(open == [10, 20] and locked == [30, 40, 50, 60, 70], "Đột phá mở ở cấp 10, 20; mốc 30–70 có dữ liệu nhưng khóa")
	var trees_ok := true
	for path: int in CharacterPath.Type.values():
		var tree := Progression.get_trace_tree(path)
		var majors := tree.nodes.filter(func(n: TraceNodeData) -> bool: return n.major).size() if tree else 0
		if tree == null or majors != 3 or tree.nodes.size() - majors < 6:
			trees_ok = false
	_check(trees_ok, "7 cây vận mệnh, mỗi cây ≥ 6 nút chỉ số nhỏ + 3 nút bị động lớn")


# --- Lên cấp 1 → 30 qua giao diện ---

func _test_level_to_30() -> void:
	print("--- Lên cấp 1 → 30 ---")
	GameState.reset_new_game()
	Progression.debug_grant_resources()
	var coin_before := GameState.get_item_count(Progression.COIN)
	var crystals_before := GameState.get_item_count(&"crystal_soul")
	var menu := await _menu()
	menu.show_page(GameMenu.Page.CHARACTERS)
	menu.character_list.character_selected.emit(&"traveler")
	var detail := menu.character_detail
	_check(detail.visible and detail.character_id == &"traveler", "Danh sách nhân vật → mở màn chi tiết")
	_check(detail.level_up(1) and Progression.get_level(&"traveler") == 2, "Nút +1 cấp: cấp 1 → 2")
	detail.level_up(GameConfig.MAX_LEVEL)
	_check(Progression.get_level(&"traveler") == 10 and not detail.level_up(1)
			and detail.get_message() == tr("PROG_ERR_NEED_ASCEND"), "Dừng ở cấp 10, cần đột phá")
	_check(detail.ascend() and Progression.get_level_cap(&"traveler") == 20, "Đột phá lần 1: giới hạn 20")
	detail.level_up(GameConfig.MAX_LEVEL)
	_check(Progression.get_level(&"traveler") == 20, "Lên tới cấp 20")
	_check(detail.ascend() and Progression.get_level_cap(&"traveler") == 30, "Đột phá lần 2: giới hạn 30")
	detail.level_up(GameConfig.MAX_LEVEL)
	_check(Progression.get_level(&"traveler") == 30, "Lên tới cấp 30")
	var no_more := not detail.level_up(1) and not detail.ascend() \
			and detail.get_message() == tr("PROG_ERR_ASCENSION_LOCKED")
	Progression.add_exp(&"traveler", 999999)
	_check(no_more and Progression.get_level(&"traveler") == 30 and Progression.get_exp(&"traveler") == 0,
			"Không thể vượt cấp 30 (đột phá 30 bị khóa, EXP thừa bỏ đi)")
	var expected_exp := 0
	for lv in range(1, 30):
		expected_exp += Progression.config().exp_for_level(lv)
	var asc_coin := 4000 + 12000
	_check(GameState.get_item_count(&"crystal_soul") == crystals_before - 14
			and coin_before - GameState.get_item_count(Progression.COIN) >= asc_coin + int(expected_exp * 0.1),
			"Tốn đúng Tinh Thể Hồn (4 + 10) và Xu (đột phá + %.1f Xu/EXP)" % Progression.config().coin_per_exp)
	await _free(menu)


func _test_stats_growth() -> void:
	print("--- Bảng tăng trưởng ---")
	var data := DataPaths.load_character(&"traveler")
	var stats := Progression.build_stats(&"traveler")
	var ok := true
	for type in [Stats.Type.HP, Stats.Type.ATK, Stats.Type.DEF]:
		var expected := StatBlock.value_at_level(data.stats_lv1, data.stats_lv80, type, 30)
		if not is_equal_approx(stats.get_value(type), expected):
			ok = false
	_check(ok, "Chỉ số cấp 30 đúng bảng tăng trưởng (Máu %d, Tấn Công %d)" % [stats.get_value(Stats.Type.HP),
			stats.get_value(Stats.Type.ATK)])
	var unit_stats := Stats.from_blocks(data.stats_lv1, data.stats_lv80, 1)
	_check(unit_stats.get_value(Stats.Type.ATK) < stats.get_value(Stats.Type.ATK), "Cấp 30 mạnh hơn cấp 1")


# --- Kỹ năng ---

func _test_skills() -> void:
	print("--- Kỹ năng ---")
	Progression.debug_grant_resources()
	var menu := await _menu()
	menu.open_character(&"mira")
	var detail := menu.character_detail
	detail.show_tab(CharacterDetailScreen.Tab.SKILLS)
	_check(detail.upgrade_skill("basic") and Progression.get_skill_level(&"mira", "basic") == 2, "Nâng Đánh thường lên cấp 2")
	_check(not detail.upgrade_skill("basic") and detail.get_message() == tr("PROG_ERR_SKILL_CAP"),
			"Chưa đột phá: kỹ năng tối đa cấp 2")
	detail.show_tab(CharacterDetailScreen.Tab.STATS)
	detail.level_up(GameConfig.MAX_LEVEL)
	detail.ascend()
	detail.level_up(GameConfig.MAX_LEVEL)
	detail.ascend()
	detail.level_up(GameConfig.MAX_LEVEL)
	detail.show_tab(CharacterDetailScreen.Tab.SKILLS)
	var cores := GameState.get_item_count(Progression.WARP_CORE)
	for i in 3:
		detail.upgrade_skill("basic")
	_check(Progression.get_skill_level(&"mira", "basic") == 5 and GameState.get_item_count(Progression.WARP_CORE) == cores - 1,
			"Sau 2 lần đột phá nâng tới cấp 5 (cấp 5 tốn 1 Lõi Ma Biến)")
	_check(not detail.upgrade_skill("basic") and detail.get_message() == tr("PROG_ERR_SKILL_MAX"), "Cấp 5 là tối đa")
	await _free(menu)
	# Số liệu trong trận: Đánh thường cấp 5 mạnh hơn cấp 1 đúng ×1,4.
	var low := _battle([&"mira"])
	var damage_low := _basic_damage(low, low.allies[0])
	await _free(low)
	var high := _battle([&"mira"], {&"mira": Progression.battle_snapshot(&"mira", false)})
	var mira := high.allies[0]
	var damage_high := _basic_damage(high, mira)
	_check(mira.level == 30 and mira.get_skill_level(SkillData.Kind.BASIC) == 5,
			"Trận dùng cấp và cấp kỹ năng của nhân vật (cấp %d, Đánh thường cấp %d)" % [mira.level,
			mira.get_skill_level(SkillData.Kind.BASIC)])
	await _free(high)
	var same_level := _battle([&"mira"], {&"mira": {"level": 10, "skill_levels": {SkillData.Kind.BASIC: 5}}})
	var damage_skill5 := _basic_damage(same_level, same_level.allies[0])
	await _free(same_level)
	_check(damage_high > damage_low and absf(damage_skill5 / damage_low - 1.4) < 0.02,
			"Đánh thường cấp 5 gây ×1,4 sát thương (%d → %d)" % [damage_low, damage_skill5])
	# Buff do Chiến kỹ gắn mạnh hơn theo cấp kỹ năng (Kiri: +20% Tấn Công → +24% ở cấp 5).
	var buff := _battle([&"kiri", &"traveler"], {&"kiri": {"skill_levels": {SkillData.Kind.SKILL: 5}}})
	var traveler := buff.allies[1]
	var atk := traveler.stats.get_value(Stats.Type.ATK)
	SkillExecutor.execute(buff, buff.allies[0], buff.allies[0].get_skill(SkillData.Kind.SKILL), traveler)
	_check(absf(traveler.stats.get_value(Stats.Type.ATK) / atk - 1.24) < 0.005,
			"Buff Chiến kỹ cấp 5 mạnh hơn (+%.0f%% Tấn Công)" % ((traveler.stats.get_value(Stats.Type.ATK) / atk - 1.0) * 100.0))
	await _free(buff)
	# Đặc tính: sát thương/hồi do Đặc tính tạo theo cấp Đặc tính.
	var talent := _battle([&"garren"], {&"garren": {"skill_levels": {-1: 3}}})
	var ctx := SkillContext.new(talent, talent.allies[0], null, null)
	_check(is_equal_approx(ctx.get_multiplier_scale(), 1.2), "Đặc tính cấp 3: sát thương/hồi của Đặc tính ×1,2")
	await _free(talent)


# --- Cây vận mệnh ---

func _test_traces() -> void:
	print("--- Cây vận mệnh ---")
	Progression.debug_grant_resources()
	var menu := await _menu()
	menu.open_character(&"garren")
	var detail := menu.character_detail
	detail.show_tab(CharacterDetailScreen.Tab.TRACES)
	var hp_before := Progression.build_stats(&"garren").get_value(Stats.Type.HP)
	_check(detail.unlock_trace(&"preservation_s2_1"), "Mở nút nhỏ bậc 1")
	_check(Progression.build_stats(&"garren").get_value(Stats.Type.HP) > hp_before, "Nút nhỏ tăng chỉ số (Máu)")
	_check(not detail.unlock_trace(&"preservation_s2_2") and detail.get_message() == tr("PROG_ERR_NEED_ASCENSION"),
			"Nút bậc 2 cần đột phá")
	_check(not detail.unlock_trace(&"preservation_m2") and detail.get_message() == tr("PROG_ERR_NEED_ASCENSION"),
			"Nút lớn 2 cần đột phá")
	_check(detail.unlock_trace(&"preservation_m1"), "Mở nút lớn 1 (+10% Phòng Thủ)")
	detail.show_tab(CharacterDetailScreen.Tab.STATS)
	detail.level_up(GameConfig.MAX_LEVEL)
	detail.ascend()
	detail.level_up(GameConfig.MAX_LEVEL)
	detail.ascend()
	detail.level_up(GameConfig.MAX_LEVEL)
	detail.show_tab(CharacterDetailScreen.Tab.TRACES)
	_check(detail.unlock_trace(&"preservation_m2") and detail.unlock_trace(&"preservation_m3"),
			"Đột phá đủ thì mở được nút lớn 2, 3")
	await _free(menu)
	var battle := _battle([&"garren"], {&"garren": Progression.battle_snapshot(&"garren", false)})
	var garren := battle.allies[0]
	battle.battle_began.emit()
	_check(garren.shield_hp > 0.0, "Nút lớn \"Lá Chắn Đầu Trận\": có khiên khi vào trận")
	var plain := Stats.from_blocks(garren.character.stats_lv1, garren.character.stats_lv80, 30)
	_check(garren.stats.get_value(Stats.Type.DEF) > plain.get_value(Stats.Type.DEF) * 1.09, "Chỉ số cây vận mệnh áp vào trận")
	await _free(battle)
	# Bị động năng lượng đầu trận (Hòa Hợp nút lớn 2).
	var state := {"traces": [Progression.get_trace_tree(CharacterPath.Type.HARMONY).get_node_data(&"harmony_m2")]}
	var energy := _battle([&"kiri"], {&"kiri": state})
	energy.battle_began.emit()
	_check(energy.allies[0].energy > energy.allies[0].max_energy * 0.69, "Nút lớn \"Khởi Xướng\": vào trận thêm 20% năng lượng")
	await _free(energy)


# --- Tinh Mệnh ---

func _test_eidolons() -> void:
	print("--- Tinh Mệnh ---")
	var first := GameState.grant_character(&"raiko")
	var dup := GameState.grant_character(&"raiko")
	_check(first["new"] and GameState.owned_characters.has(&"raiko") and dup["eidolon"] == 1
			and GameState.get_eidolon_level(&"raiko") == 1, "Nhận nhân vật trùng: +1 Tinh Mệnh")
	for i in 6:
		GameState.grant_character(&"raiko")
	_check(GameState.get_eidolon_level(&"raiko") == 6 and GameState.grant_character(&"raiko")["overflow"],
			"Tinh Mệnh tối đa 6, bản sao thừa báo overflow (Phase 11 đổi Bụi Sao)")
	for i in range(1, 4):
		GameState.set_story_flag(StringName("soul_shard_%d" % i))
	_check(GameState.get_eidolon_level(&"traveler") == 3, "Nhân vật chính: Tinh Mệnh theo cờ cốt truyện (3 Mảnh Hồn)")


# --- Máu giữ giữa các trận ---

func _test_hp() -> void:
	print("--- Máu giữ giữa các trận ---")
	GameState.heal_team(1.0)
	GameState.set_hp_ratio(&"traveler", 0.5)
	GameState.set_hp_ratio(&"mira", 0.0)
	var ids: Array[StringName] = [&"traveler", &"mira"]
	var states := {}
	for id in ids:
		states[id] = Progression.battle_snapshot(id)
	var battle := _battle(ids, states)
	_check(is_equal_approx(battle.allies[0].get_hp_ratio(), 0.5) and not battle.allies[1].is_alive()
			and not battle.queue.has(battle.allies[1]), "Vào trận với máu đã giữ; người đã ngã không vào hàng lượt")
	await _free(battle)
	# Trận thật qua màn trận: thắng xong ghi máu lại.
	GameState.heal_team(1.0)
	GameState.set_team([&"traveler", &"mira", &"kiri", &"garren"])
	GameState.set_hp_ratio(&"kiri", 0.4)
	GameState.current_map_scene = DataPaths.TEST_MAP_SCENE
	OverworldEnemy.debug_frozen = true
	SceneRouter.go_to(DataPaths.BATTLE_SCENE, {"encounter": load(DUMMIES), "instant": true}, 0.01)
	await SceneRouter.transition_finished
	await _frames(3)
	var scene := get_tree().current_scene
	var kiri: BattleUnit = scene.controller.allies[2]
	var kiri_ok := is_equal_approx(kiri.get_hp_ratio(), 0.4)
	kiri.take_damage(kiri.get_max_hp() * 0.1)
	scene.debug_force_result(true)
	await _frames(2)
	scene._leave(true)
	await SceneRouter.transition_finished
	await _frames(2)
	_check(kiri_ok and absf(GameState.get_hp_ratio(&"kiri") - 0.3) < 0.01, "Máu sau trận thắng được giữ lại (Kiri 40% → 30%)")
	var map := get_tree().current_scene as OverworldMap
	var rest := map.find_children("*", "RestPoint", true, false)
	_check(not rest.is_empty(), "Có điểm nghỉ trên map thử")
	if not rest.is_empty():
		(rest[0] as RestPoint)._on_interact(map.player)
	_check(is_equal_approx(GameState.get_hp_ratio(&"kiri"), 1.0), "Phòng nghỉ hồi đầy máu cả đội")
	GameState.set_hp_ratio(&"kiri", 0.1)
	GameState.heal_team(0.25)
	_check(absf(GameState.get_hp_ratio(&"kiri") - 0.35) < 0.001, "Bí Kỹ hồi máu: +25% máu tối đa cả đội")
	GameState.set_hp_ratio(&"kiri", 0.1)
	GameState.pending_battle = {"map_scene": DataPaths.TEST_MAP_SCENE}
	GameState.finish_battle(false)
	_check(is_equal_approx(GameState.get_hp_ratio(&"kiri"), 1.0), "Thua: về phòng nghỉ với máu đầy")
	OverworldEnemy.debug_frozen = false


# --- Đội hình ---

func _test_team_screen() -> void:
	print("--- Đội hình ---")
	var menu := await _menu()
	menu.show_page(GameMenu.Page.TEAM)
	var screen := menu.team_screen
	screen.select_preset(1)
	_check(screen.draft.is_empty(), "Đội hình 2 ban đầu trống")
	for id: StringName in [&"nyx", &"garren", &"mira", &"kiri"]:
		screen.toggle_character(id)
	var fifth := screen.toggle_character(&"traveler")
	_check(not fifth and screen.draft.size() == 4, "Không cho quá 4 người")
	screen.remove_slot(0)
	_check(screen.draft == ([&"garren", &"mira", &"kiri"] as Array[StringName]), "Bấm ô để bỏ người")
	screen.toggle_character(&"raiko")
	_check(screen.apply() and GameState.team == ([&"garren", &"mira", &"kiri", &"raiko"] as Array[StringName])
			and GameState.active_preset == 1 and menu.is_team_changed(), "Dùng đội hình 2 làm đội hiện tại")
	screen.select_preset(0)
	_check(screen.draft == ([&"traveler", &"mira", &"kiri", &"garren"] as Array[StringName]), "Đội hình 1 vẫn được lưu")
	_check(screen.apply() and GameState.active_preset == 0, "Đổi lại đội hình 1")
	screen.select_preset(2)
	_check(not screen.apply(), "Không dùng được đội hình trống")
	_check(not GameState.save_preset(3, [&"a", &"b", &"c", &"d", &"e"] as Array[StringName]), "GameState từ chối đội 5 người")
	await _free(menu)


# --- Túi đồ, danh sách ---

func _test_inventory_and_list() -> void:
	print("--- Túi đồ và danh sách ---")
	var menu := await _menu()
	menu.show_page(GameMenu.Page.INVENTORY)
	var inv := menu.inventory_screen
	inv.show_category(ItemData.Category.SIGIL)
	var sigils := inv.get_visible_items()
	_check(sigils.size() == 21 and sigils.all(func(id: StringName) -> bool: return UiKit.get_item(id).category == ItemData.Category.SIGIL),
			"Thẻ Dấu Ấn chỉ hiện Dấu Ấn (21 loại)")
	inv.show_category(ItemData.Category.CONSUMABLE)
	inv.select_item(&"technique_box")
	GameState.technique_points = 2
	var boxes := GameState.get_item_count(&"technique_box")
	_check(inv.use_selected() and GameState.technique_points == 3 and GameState.get_item_count(&"technique_box") == boxes - 1,
			"Dùng Hộp Bí Kỹ: +1 Điểm Bí Kỹ")
	menu.show_page(GameMenu.Page.CHARACTERS)
	var list := menu.character_list
	list.set_filters(Element.Type.FIRE, CharacterListScreen.ANY, CharacterListScreen.ANY)
	_check(list.get_visible_ids() == ([&"kiri"] as Array[StringName]), "Lọc theo nguyên tố (Lửa → Kiri)")
	list.set_filters(CharacterListScreen.ANY, CharacterPath.Type.PRESERVATION, CharacterListScreen.ANY)
	_check(list.get_visible_ids() == ([&"garren"] as Array[StringName]), "Lọc theo vận mệnh (Bảo Hộ → Garren)")
	list.set_filters(CharacterListScreen.ANY, CharacterListScreen.ANY, 5)
	_check(list.get_visible_ids() == ([&"traveler", &"raiko"] as Array[StringName]), "Lọc theo hạng (5★)")
	list.set_filters(CharacterListScreen.ANY, CharacterListScreen.ANY, CharacterListScreen.ANY)
	_check(not list.get_visible_ids().has(&"vesper"), "Chỉ hiện nhân vật đã sở hữu")
	await _free(menu)


# --- Lưu / tải ---

func _test_save_load() -> void:
	print("--- Lưu / tải ---")
	var data := JSON.parse_string(JSON.stringify(GameState.to_dict())) as Dictionary
	var level := Progression.get_level(&"mira")
	var coin := GameState.get_item_count(Progression.COIN)
	var skill := Progression.get_skill_level(&"mira", "basic")
	GameState.reset_new_game()
	GameState.from_dict(data)
	_check(Progression.get_level(&"mira") == level and GameState.get_item_count(Progression.COIN) == coin
			and Progression.get_skill_level(&"mira", "basic") == skill and Progression.has_trace(&"garren", &"preservation_m3")
			and GameState.get_preset(1).size() == 4, "Lưu/tải giữ cấp, kỹ năng, cây vận mệnh, túi đồ, đội hình")
	var old := {"version": 1, "game_state": {"team_level": 15, "owned_characters": ["traveler", "mira"]}}
	var migrated: Dictionary = SaveManager._migrate(old)
	GameState.from_dict(migrated["game_state"])
	_check(Progression.get_level(&"mira") == 15 and Progression.get_ascension(&"mira") == 1 and GameState.team_level == 0,
			"Save v1: cấp đội cũ chuyển thành cấp từng nhân vật (đã đột phá tương ứng)")
	GameState.from_dict(data)


# --- Menu tạm dừng ---

func _test_pause_menu() -> void:
	print("--- Menu tạm dừng ---")
	SceneRouter.go_to(DataPaths.TEST_MAP_SCENE, {}, 0.01)
	await SceneRouter.transition_finished
	await _frames(2)
	var map := get_tree().current_scene as OverworldMap
	var pause := map.hud.find_child("PauseMenu", true, false) as PauseMenu
	var menu := pause.open_game_menu(GameMenu.Page.TEAM)
	await _frames(1)
	_check(menu.visible and menu.team_screen.visible and get_tree().paused, "Menu tạm dừng → Đội hình")
	menu.team_screen.select_preset(1)
	menu.team_screen.apply()
	menu.close()
	await SceneRouter.transition_finished
	await _frames(2)
	_check(not get_tree().paused and GameState.team[0] == &"garren", "Đổi đội xong, đóng menu: map nạp lại với đội mới")
	var hud_level: int = GameState.get_team_level()
	_check(hud_level == roundi((Progression.get_level(&"garren") + Progression.get_level(&"mira")
			+ Progression.get_level(&"kiri") + Progression.get_level(&"raiko")) / 4.0), "Cấp đội = trung bình cấp nhân vật")
