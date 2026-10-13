class_name Progression
extends RefCounted
## Tiến trình nhân vật (Phase 9): cấp + EXP, đột phá, cấp kỹ năng, cây vận mệnh. Đọc/ghi GameState.character_progress
## và túi đồ; số liệu lấy từ ProgressionConfig (data/config/progression.tres) và TraceTreeData theo vận mệnh.
## Mọi hàm "try_*" trả về { "ok": bool, "reason": khóa dịch khi thất bại, ... } để giao diện hiện lý do.

const COIN: StringName = &"aether_coin"
const WARP_CORE: StringName = &"warp_core"
const EXP_ITEMS: Array[StringName] = [&"soul_memory_1", &"soul_memory_2", &"soul_memory_3"]
## Khóa cấp kỹ năng trong save và loại SkillData tương ứng (Đặc tính = -1).
const SKILL_KEYS: Array[String] = ["basic", "skill", "ultimate", "talent"]
const SKILL_KINDS: Dictionary = {"basic": SkillData.Kind.BASIC, "skill": SkillData.Kind.SKILL,
		"ultimate": SkillData.Kind.ULTIMATE, "talent": -1}
const TRACES_DIR: String = "res://data/progression/traces"

static var _trees: Dictionary = {}


static func config() -> ProgressionConfig:
	return ProgressionConfig.get_config()


# --- Đọc trạng thái ---

## Bản ghi tiến trình (tạo mặc định nếu chưa có, sửa giá trị lệch).
static func get_progress(character_id: StringName) -> Dictionary:
	var key := String(character_id)
	var progress: Dictionary = GameState.character_progress.get(key, {})
	var level := clampi(int(progress.get("level", 1)), 1, GameConfig.MAX_LEVEL)
	var ascension := maxi(int(progress.get("ascension", 0)), 0)
	# Save cũ (hoặc lệnh debug) có cấp vượt giới hạn: coi như đã đột phá đủ.
	while level > config().level_cap(ascension) and ascension < config().ascensions.size():
		ascension += 1
	var skills: Dictionary = progress.get("skills", {})
	for skill_key in SKILL_KEYS:
		skills[skill_key] = clampi(int(skills.get(skill_key, 1)), 1, config().max_skill_level)
	progress["level"] = level
	progress["exp"] = maxi(int(progress.get("exp", 0)), 0)
	progress["ascension"] = ascension
	progress["skills"] = skills
	progress["traces"] = progress.get("traces", []) if progress.get("traces", []) is Array else []
	GameState.character_progress[key] = progress
	return progress


static func get_level(character_id: StringName) -> int:
	return int(get_progress(character_id)["level"])


static func get_exp(character_id: StringName) -> int:
	return int(get_progress(character_id)["exp"])


static func get_ascension(character_id: StringName) -> int:
	return int(get_progress(character_id)["ascension"])


static func get_level_cap(character_id: StringName) -> int:
	return config().level_cap(get_ascension(character_id))


static func get_skill_level(character_id: StringName, skill_key: String) -> int:
	return int(get_progress(character_id)["skills"].get(skill_key, 1))


static func get_skill_cap(character_id: StringName) -> int:
	return config().skill_cap(get_ascension(character_id))


static func has_trace(character_id: StringName, node_id: StringName) -> bool:
	return (get_progress(character_id)["traces"] as Array).has(String(node_id))


## Đang ở giới hạn cấp và còn mốc đột phá (mở hoặc khóa).
static func needs_ascension(character_id: StringName) -> bool:
	return get_level(character_id) >= get_level_cap(character_id) \
			and config().get_ascension_at(get_level(character_id)) != null


static func get_trace_tree(path: int) -> TraceTreeData:
	if not _trees.has(path):
		var file_name := String(CharacterPath.Type.keys()[path]).to_lower()
		_trees[path] = load("%s/%s.tres" % [TRACES_DIR, file_name]) as TraceTreeData
	return _trees[path]


static func element_key(element: int) -> String:
	return String(Element.Type.keys()[element]).to_lower()


static func crystal_id(element: int) -> StringName:
	return StringName("crystal_" + element_key(element))


static func sigil_id(path: int, tier: int) -> StringName:
	return StringName("sigil_%s_%d" % [String(CharacterPath.Type.keys()[path]).to_lower(), tier])


# --- Lên cấp ---

## Tổng EXP còn thiếu để lên tới giới hạn cấp hiện tại.
static func exp_to_cap(character_id: StringName) -> int:
	var level := get_level(character_id)
	var cap := get_level_cap(character_id)
	var total := -get_exp(character_id)
	for lv in range(level, cap):
		total += config().exp_for_level(lv)
	return maxi(total, 0)


## Cộng EXP (dừng ở giới hạn cấp, phần thừa bỏ). Trả về số cấp đã lên.
static func add_exp(character_id: StringName, amount: int) -> int:
	var progress := get_progress(character_id)
	var cap := get_level_cap(character_id)
	var level := int(progress["level"])
	var exp := int(progress["exp"]) + maxi(amount, 0)
	var start := level
	while level < cap and exp >= config().exp_for_level(level):
		exp -= config().exp_for_level(level)
		level += 1
	if level >= cap:
		exp = 0
	progress["level"] = level
	progress["exp"] = exp
	if level != start:
		EventBus.character_upgraded.emit(character_id)
	return level - start


## Số Ký Ức (bậc `item_id`) nên dùng để lên tới cấp `target` (không vượt giới hạn, không vượt số đang có).
static func items_needed(character_id: StringName, item_id: StringName, target_level: int) -> int:
	var item := load("res://data/items/%s.tres" % item_id) as ItemData
	if item == null or item.exp_value <= 0:
		return 0
	var level := get_level(character_id)
	var cap := get_level_cap(character_id)
	var need := -get_exp(character_id)
	for lv in range(level, mini(target_level, cap)):
		need += config().exp_for_level(lv)
	if need <= 0:
		return 0
	return mini(ceili(float(need) / item.exp_value), GameState.get_item_count(item_id))


## Dùng `count` Ký Ức loại `item_id`, tốn Xu theo EXP. Trả về { ok, reason, levels }.
static func try_use_exp_items(character_id: StringName, item_id: StringName, count: int) -> Dictionary:
	var item := load("res://data/items/%s.tres" % item_id) as ItemData
	if item == null or item.exp_value <= 0 or count <= 0:
		return {"ok": false, "reason": "PROG_ERR_INVALID"}
	if get_level(character_id) >= get_level_cap(character_id):
		return {"ok": false, "reason": "PROG_ERR_NEED_ASCEND" if needs_ascension(character_id) else "PROG_ERR_MAX_LEVEL"}
	var exp := item.exp_value * count
	var cost := {item_id: count, COIN: ceili(exp * config().coin_per_exp)}
	if not GameState.spend_items(cost):
		return {"ok": false, "reason": "PROG_ERR_NOT_ENOUGH"}
	return {"ok": true, "levels": add_exp(character_id, exp)}


# --- Đột phá ---

static func get_ascension_cost(character_id: StringName) -> Dictionary:
	var data := config().get_ascension_at(get_level(character_id))
	if data == null:
		return {}
	var character := DataPaths.load_character(character_id)
	return {COIN: data.coin, crystal_id(character.element): data.crystals}


static func try_ascend(character_id: StringName) -> Dictionary:
	var level := get_level(character_id)
	var data := config().get_ascension_at(level)
	if data == null or level < get_level_cap(character_id):
		return {"ok": false, "reason": "PROG_ERR_NOT_AT_CAP"}
	if data.is_locked():
		return {"ok": false, "reason": "PROG_ERR_ASCENSION_LOCKED"}
	if not GameState.spend_items(get_ascension_cost(character_id)):
		return {"ok": false, "reason": "PROG_ERR_NOT_ENOUGH"}
	get_progress(character_id)["ascension"] = get_ascension(character_id) + 1
	EventBus.character_upgraded.emit(character_id)
	return {"ok": true}


# --- Kỹ năng ---

static func get_skill_cost(character_id: StringName, skill_key: String) -> Dictionary:
	var cost := config().get_skill_cost(get_skill_level(character_id, skill_key) + 1)
	if cost == null:
		return {}
	var character := DataPaths.load_character(character_id)
	var result := {COIN: cost.coin, sigil_id(character.path, cost.sigil_tier): cost.sigil_count}
	if cost.warp_cores > 0:
		result[WARP_CORE] = cost.warp_cores
	return result


static func try_upgrade_skill(character_id: StringName, skill_key: String) -> Dictionary:
	if not SKILL_KEYS.has(skill_key):
		return {"ok": false, "reason": "PROG_ERR_INVALID"}
	var level := get_skill_level(character_id, skill_key)
	if level >= config().max_skill_level:
		return {"ok": false, "reason": "PROG_ERR_SKILL_MAX"}
	var cost := config().get_skill_cost(level + 1)
	if level >= get_skill_cap(character_id) or cost == null or get_ascension(character_id) < cost.required_ascension:
		return {"ok": false, "reason": "PROG_ERR_SKILL_CAP"}
	if not GameState.spend_items(get_skill_cost(character_id, skill_key)):
		return {"ok": false, "reason": "PROG_ERR_NOT_ENOUGH"}
	get_progress(character_id)["skills"][skill_key] = level + 1
	EventBus.character_upgraded.emit(character_id)
	return {"ok": true}


# --- Cây vận mệnh ---

static func get_trace_cost(character_id: StringName, node: TraceNodeData) -> Dictionary:
	var character := DataPaths.load_character(character_id)
	return {COIN: node.coin, sigil_id(character.path, node.sigil_tier): node.sigil_count}


## Lý do chưa mở được nút ("" = mở được nếu đủ tài nguyên).
static func trace_block_reason(character_id: StringName, node: TraceNodeData) -> String:
	if has_trace(character_id, node.id):
		return "PROG_ERR_TRACE_OWNED"
	if get_ascension(character_id) < node.required_ascension:
		return "PROG_ERR_NEED_ASCENSION"
	if node.requires != &"" and not has_trace(character_id, node.requires):
		return "PROG_ERR_REQUIRES_NODE"
	return ""


static func try_unlock_trace(character_id: StringName, node_id: StringName) -> Dictionary:
	var character := DataPaths.load_character(character_id)
	var node := get_trace_tree(character.path).get_node_data(node_id)
	if node == null:
		return {"ok": false, "reason": "PROG_ERR_INVALID"}
	var reason := trace_block_reason(character_id, node)
	if reason != "":
		return {"ok": false, "reason": reason}
	if not GameState.spend_items(get_trace_cost(character_id, node)):
		return {"ok": false, "reason": "PROG_ERR_NOT_ENOUGH"}
	(get_progress(character_id)["traces"] as Array).append(String(node_id))
	EventBus.character_upgraded.emit(character_id)
	return {"ok": true}


## Các nút đã mở (TraceNodeData).
static func get_unlocked_traces(character_id: StringName) -> Array[TraceNodeData]:
	var result: Array[TraceNodeData] = []
	var character := DataPaths.load_character(character_id)
	var tree := get_trace_tree(character.path)
	if tree == null:
		return result
	for node in tree.nodes:
		if has_trace(character_id, node.id):
			result.append(node)
	return result


# --- Chỉ số và trận ---

## Chỉ số ngoài trận (cấp + cây vận mệnh + Tinh Mệnh dạng chỉ số) để hiện ở màn chi tiết.
static func build_stats(character_id: StringName) -> Stats:
	var data := DataPaths.load_character(character_id)
	var stats := Stats.from_blocks(data.stats_lv1, data.stats_lv80, get_level(character_id))
	apply_trace_modifiers(stats, get_unlocked_traces(character_id))
	for i in mini(GameState.get_eidolon_level(character_id), data.eidolons.size()):
		for modifier in data.eidolons[i].stat_modifiers:
			stats.add_modifier(modifier.stat, modifier.flat, modifier.percent, StringName("eidolon_%d" % (i + 1)))
	return stats


static func apply_trace_modifiers(stats: Stats, nodes: Array[TraceNodeData]) -> void:
	for node in nodes:
		for modifier in node.stat_modifiers:
			stats.add_modifier(modifier.stat, modifier.flat, modifier.percent, StringName("trace_" + node.id))


## Ảnh chụp cho BattleController.ally_states: cấp, cấp kỹ năng, nút cây vận mệnh, máu hiện tại.
static func battle_snapshot(character_id: StringName, use_hp: bool = true) -> Dictionary:
	var progress := get_progress(character_id)
	var skills: Dictionary = {}
	for skill_key in SKILL_KEYS:
		skills[SKILL_KINDS[skill_key]] = int(progress["skills"][skill_key])
	return {
		"level": int(progress["level"]),
		"skill_levels": skills,
		"traces": get_unlocked_traces(character_id),
		"hp_ratio": GameState.get_hp_ratio(character_id) if use_hp else 1.0,
	}


# --- Debug ---

## Cộng nhiều tài nguyên để thử (lệnh debug).
static func debug_grant_resources(multiplier: int = 1) -> void:
	GameState.add_item(COIN, 500000 * multiplier)
	GameState.add_item(WARP_CORE, 20 * multiplier)
	for item_id in EXP_ITEMS:
		GameState.add_item(item_id, 50 * multiplier)
	for element in Element.all():
		GameState.add_item(crystal_id(element), 30 * multiplier)
	for path in CharacterPath.Type.values():
		for tier in [1, 2, 3]:
			GameState.add_item(sigil_id(path, tier), 40 * multiplier)
	GameState.add_item(&"technique_box", 5 * multiplier)
