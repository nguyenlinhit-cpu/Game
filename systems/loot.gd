class_name Loot
extends RefCounted
## Rơi đồ (mục 11): lăn LootTable cho trận thắng và rương, thưởng lần hạ đầu tiên, giới hạn thưởng boss
## mỗi ngày, mức Khó; tính kỳ vọng cho báo cáo kinh tế. Trạng thái (đã hạ lần đầu, số lần nhận thưởng boss
## trong ngày) nằm ở GameState.loot_state.
##
## Bảng của quái tìm theo thứ tự: data/loot_tables/enemies/<id>.tres → <họ quái>.tres → default_<loại>.tres.
## Bảng của rương: ZoneData.chest_tables của khu (data/zones/<khu>.tres), thiếu thì dùng khu đầu tiên.

const ENEMY_TABLE_DIR: String = "res://data/loot_tables/enemies"
const ZONE_DIR: String = "res://data/zones"
const ECONOMY_MODEL: String = "res://data/config/economy_model.tres"
const QUEST_CONFIG: String = "res://data/quests/quest_config.tres"
const HARD_MODE_CONFIG: String = "res://data/config/boss_hard_mode.tres"
const DEFAULT_ZONE: StringName = &"library"
const COIN: StringName = &"aether_coin"
const KIND_NAMES: Array[String] = ["normal", "elite", "boss"]

static var _tables: Dictionary = {}
static var _zones: Dictionary = {}
## Nguyên tố / vận mệnh của đội đang dùng: { "key": "id,id...", "members": [[nguyên tố, vận mệnh], ...] }.
static var _team_cache: Dictionary = {}


# --- Tra bảng ---

static func table_for_enemy(enemy: EnemyData) -> LootTable:
	if enemy == null:
		return null
	var key := String(enemy.id)
	if _tables.has(key):
		return _tables[key]
	var table: LootTable = null
	for file_id: String in [String(enemy.id), String(enemy.family), "default_" + KIND_NAMES[enemy.kind]]:
		var path := ENEMY_TABLE_DIR.path_join(file_id + ".tres")
		if not file_id.is_empty() and ResourceLoader.exists(path):
			table = load(path) as LootTable
			break
	_tables[key] = table
	return table


static func get_zone(zone_id: StringName) -> ZoneData:
	if _zones.has(zone_id):
		return _zones[zone_id]
	var path := ZONE_DIR.path_join("%s.tres" % zone_id)
	var zone: ZoneData = load(path) as ZoneData if ResourceLoader.exists(path) else null
	_zones[zone_id] = zone
	return zone


static func chest_table(zone_id: StringName, tier: int) -> LootTable:
	var zone := get_zone(zone_id)
	if zone == null or zone.get_chest_table(tier) == null:
		zone = get_zone(DEFAULT_ZONE)
	return zone.get_chest_table(tier) if zone else null


static func hard_multiplier() -> float:
	if not _tables.has(HARD_MODE_CONFIG):
		var config := load(HARD_MODE_CONFIG) as DifficultyConfig
		_tables[HARD_MODE_CONFIG] = config.reward_multiplier if config else 1.0
	return _tables[HARD_MODE_CONFIG]


# --- Lăn ---

## Lăn các dòng của bảng, cộng vào `out` ({ item_id: số lượng }).
## `multiplier` chỉ áp cho dòng scales_with_difficulty; `coins_only` bỏ mọi dòng trừ Xu Aether.
static func roll_entries(entries: Array[LootEntry], rng: RandomNumberGenerator, enemy: EnemyData, out: Dictionary,
		multiplier: float = 1.0, coins_only: bool = false) -> void:
	for entry in entries:
		if coins_only and entry.item_id != COIN:
			continue
		if entry.chance < 1.0 and rng.randf() >= entry.chance:
			continue
		var count := rng.randi_range(entry.min_count, maxi(entry.max_count, entry.min_count))
		if entry.scales_with_difficulty:
			count = roundi(count * multiplier)
		if entry.pool.is_empty() and not is_team_token(entry.item_id):
			_add(out, _resolve(entry.item_id, enemy, rng), count)
			continue
		# Mỗi món chọn riêng (vd. 2 Dấu Ấn có thể khác vận mệnh).
		for i in count:
			var id := entry.item_id if entry.pool.is_empty() else entry.pool[rng.randi() % entry.pool.size()]
			_add(out, _resolve(id, enemy, rng), 1)


## Phần thưởng một trận. options: { "rng", "hard": bool, "first_clear": bool, "coins_only": bool }.
## Cộng theo từng con quái đặt sẵn trong trận (quái gọi thêm giữa trận không có thưởng).
static func roll_encounter(encounter: EncounterData, options: Dictionary = {}) -> Dictionary:
	var rng: RandomNumberGenerator = options.get("rng", RandomNumberGenerator.new())
	var hard := bool(options.get("hard", false)) and encounter.is_boss()
	var multiplier := hard_multiplier() if hard else 1.0
	var coins_only := bool(options.get("coins_only", false))
	var result: Dictionary = {}
	for enemy in _encounter_enemies(encounter):
		var table := table_for_enemy(enemy)
		if table == null:
			continue
		roll_entries(table.entries, rng, enemy, result, multiplier, coins_only)
		if bool(options.get("first_clear", false)):
			roll_entries(table.first_clear, rng, enemy, result)
		if hard and not coins_only:
			roll_entries(table.hard_extra, rng, enemy, result)
	return result


static func roll_chest(zone_id: StringName, tier: int, rng: RandomNumberGenerator = null) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var table := chest_table(zone_id, tier)
	var result: Dictionary = {}
	if table:
		roll_entries(table.entries, rng, null, result)
		# Rương chỉ mở được 1 lần nên lần mở nào cũng là lần đầu (Lệ Tinh).
		roll_entries(table.first_clear, rng, null, result)
	return result


# --- Kỳ vọng (báo cáo kinh tế) ---

## Số lượng kỳ vọng mỗi lần lăn; pool chia đều cho từng id. Id theo đội ("crystal_team", "sigil_team_N")
## giữ nguyên (báo cáo kinh tế tính như tài nguyên dùng được cho đội).
static func expected_entries(entries: Array[LootEntry], enemy: EnemyData, out: Dictionary,
		multiplier: float = 1.0, coins_only: bool = false) -> void:
	for entry in entries:
		if coins_only and entry.item_id != COIN:
			continue
		var count := entry.expected_count() * (multiplier if entry.scales_with_difficulty else 1.0)
		if entry.pool.is_empty():
			_add(out, _resolve_expected(entry.item_id, enemy), count)
		else:
			for id in entry.pool:
				_add(out, _resolve_expected(id, enemy), count / entry.pool.size())


static func expected_encounter(encounter: EncounterData, options: Dictionary = {}) -> Dictionary:
	var hard := bool(options.get("hard", false)) and encounter.is_boss()
	var multiplier := hard_multiplier() if hard else 1.0
	var coins_only := bool(options.get("coins_only", false))
	var result: Dictionary = {}
	for enemy in _encounter_enemies(encounter):
		var table := table_for_enemy(enemy)
		if table == null:
			continue
		if not bool(options.get("first_clear_only", false)):
			expected_entries(table.entries, enemy, result, multiplier, coins_only)
		if bool(options.get("first_clear", false)) or bool(options.get("first_clear_only", false)):
			expected_entries(table.first_clear, enemy, result)
		if hard and not coins_only:
			expected_entries(table.hard_extra, enemy, result)
	return result


static func expected_chest(zone_id: StringName, tier: int) -> Dictionary:
	var table := chest_table(zone_id, tier)
	var result: Dictionary = {}
	if table:
		expected_entries(table.entries, null, result)
		expected_entries(table.first_clear, null, result)
	return result


# --- Trao thưởng có trạng thái ---

## Thắng một trận thật (map hoặc thắng ngay): lăn thưởng theo luật lần đầu / giới hạn boss trong ngày / mức Khó,
## cộng vào túi đồ, phát EventBus.encounter_cleared. Trả về { "items", "first_clear", "coins_only", "hard" }.
static func claim_encounter(encounter: EncounterData, hard: bool = false, rng: RandomNumberGenerator = null) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	hard = hard and encounter.is_boss()
	var key := String(encounter.id) if encounter.id != &"" else encounter.resource_path
	var first_clear := not GameState.has_first_clear(key)
	var coins_only := false
	if encounter.is_boss():
		var limit := boss_claim_limit(encounter)
		coins_only = limit > 0 and GameState.get_boss_claims(key) >= limit
		if not coins_only:
			GameState.add_boss_claim(key)
	var items := roll_encounter(encounter, {"rng": rng, "hard": hard, "first_clear": first_clear, "coins_only": coins_only})
	if first_clear:
		GameState.mark_first_clear(key)
	grant(items)
	var info := {"items": items, "first_clear": first_clear, "coins_only": coins_only, "hard": hard}
	EventBus.encounter_cleared.emit(encounter, info)
	return info


## Số lần nhận đủ thưởng mỗi ngày của boss trong trận (0 = không giới hạn).
static func boss_claim_limit(encounter: EncounterData) -> int:
	var boss := encounter.get_boss()
	var table := table_for_enemy(boss)
	return table.full_claims_per_day if table else 0


static func grant(items: Dictionary) -> void:
	for item_id: Variant in items:
		GameState.add_item(StringName(str(item_id)), int(items[item_id]))


## Dòng chữ "Tên ×số", vật phẩm hiếm trước.
static func describe(items: Dictionary) -> Array[String]:
	var ids: Array = items.keys()
	ids.sort_custom(func(a: Variant, b: Variant) -> bool:
		var ia := UiKit.get_item(StringName(str(a)))
		var ib := UiKit.get_item(StringName(str(b)))
		var ra := ia.rarity if ia else 0
		var rb := ib.rarity if ib else 0
		return ra > rb if ra != rb else str(a) < str(b))
	var lines: Array[String] = []
	for id: Variant in ids:
		if int(items[id]) > 0:
			lines.append("%s ×%d" % [UiKit.item_name(StringName(str(id))), int(items[id])])
	return lines


# --- Nội bộ ---

static func _encounter_enemies(encounter: EncounterData) -> Array[EnemyData]:
	var result: Array[EnemyData] = []
	if encounter == null:
		return result
	for wave in encounter.waves:
		for entry in wave.entries:
			if entry.enemy:
				for i in maxi(entry.count, 1):
					result.append(entry.enemy)
	return result


static func is_team_token(item_id: StringName) -> bool:
	return item_id == LootEntry.TEAM_CRYSTAL or String(item_id).begins_with(LootEntry.TEAM_SIGIL_PREFIX)


static func _resolve(item_id: StringName, enemy: EnemyData, rng: RandomNumberGenerator = null) -> StringName:
	if item_id == LootEntry.ENEMY_CRYSTAL:
		return Progression.crystal_id(enemy.element) if enemy else &""
	if is_team_token(item_id):
		var members := _team_members()
		if members.is_empty():
			return &""
		var member: Array = members[(rng.randi() if rng else randi()) % members.size()]
		if item_id == LootEntry.TEAM_CRYSTAL:
			return Progression.crystal_id(member[0])
		return Progression.sigil_id(member[1], int(String(item_id).trim_prefix(LootEntry.TEAM_SIGIL_PREFIX)))
	return item_id


## [[nguyên tố, vận mệnh], ...] của đội đang dùng (đọc CharacterData một lần mỗi khi đội đổi).
static func _team_members() -> Array:
	var key := ",".join(GameState.team.map(func(id: StringName) -> String: return String(id)))
	if _team_cache.get("key", null) != key:
		var members: Array = []
		for data in GameState.get_team_data():
			members.append([data.element, data.path])
		_team_cache = {"key": key, "members": members}
	return _team_cache["members"]


static func _resolve_expected(item_id: StringName, enemy: EnemyData) -> StringName:
	return item_id if is_team_token(item_id) else _resolve(item_id, enemy)


static func _add(out: Dictionary, item_id: StringName, amount: Variant) -> void:
	if item_id == &"" or amount == 0:
		return
	var key := String(item_id)
	out[key] = out.get(key, 0) + amount
