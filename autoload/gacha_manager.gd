extends Node
## Gacha 2 banner (mục 10): quay, bảo hiểm, 50/50, vé, nhân vật trùng → Tinh Mệnh / Bụi Sao, lịch sử,
## chọn 5★ sau 300 lượt banner thường, cửa hàng Bụi Sao, quà mở Gacha.
##
## - Tỉ lệ và bảo hiểm khai báo trong BannerData. Bộ đếm lưu theo `BannerData.pity_group` nên banner giới hạn
##   sau kế thừa bộ đếm + trạng thái bảo đảm của banner giới hạn trước.
## - `roll()` là hàm thuần (chỉ đổi `state` truyền vào) để giả lập 1.000.000 lượt không đụng túi đồ.
## - Quay xong tự lưu (ô tự lưu) để thoát game giữa chừng không mất bộ đếm.

## Bộ đếm / vé / cửa hàng / lịch sử thay đổi (giao diện vẽ lại).
signal changed

const CONFIG_PATH: String = "res://data/banners/gacha_config.tres"
const CHARACTER_DIR: String = "res://data/characters"

var config: GachaConfig
## Quay / mua xong thì tự lưu (test tắt).
var autosave: bool = true

## { pity_group: { "pity_5": int, "pity_4": int, "guaranteed_5": bool, "guaranteed_4": bool } }
var pity_state: Dictionary = {}
## Tổng lượt mỗi banner { banner_id: int }.
var pull_counts: Dictionary = {}
## Lịch sử mỗi banner, mới nhất ở đầu { banner_id: [ { "rarity", "character" | "items", "time" } ] }.
var history: Dictionary = {}
## Banner đã nhận quà chọn 5★ (sau `selector_pulls` lượt).
var selector_claimed: Array[String] = []
## Cửa hàng Bụi Sao: tháng đang tính (năm × 12 + tháng − 1) và số lần đã mua mỗi món trong tháng.
var shop_month: int = -1
var shop_bought: Dictionary = {}
var open_gift_granted: bool = false
## RNG có seed lưu lại để tái hiện lỗi.
var rng := RandomNumberGenerator.new()

var _characters: Dictionary = {}


func _ready() -> void:
	config = load(CONFIG_PATH) as GachaConfig
	rng.randomize()
	EventBus.story_flag_set.connect(_on_story_flag_set)


## Game mới: xóa bộ đếm, lịch sử, cửa hàng.
func reset() -> void:
	pity_state.clear()
	pull_counts.clear()
	history.clear()
	selector_claimed.clear()
	shop_month = -1
	shop_bought.clear()
	open_gift_granted = false
	rng.randomize()
	changed.emit()


func is_unlocked() -> bool:
	return config != null and bool(GameState.get_story_flag(config.unlock_flag, false))


func get_banners() -> Array[BannerData]:
	return config.banners if config else ([] as Array[BannerData])


func get_banner(banner_id: StringName) -> BannerData:
	return config.find_banner(banner_id) if config else null


func get_character(character_id: StringName) -> CharacterData:
	if not _characters.has(character_id):
		var path := CHARACTER_DIR.path_join("%s.tres" % character_id)
		_characters[character_id] = load(path) as CharacterData if ResourceLoader.exists(path) else null
	return _characters[character_id]


# --- Bộ đếm bảo hiểm ---

static func new_pity_state() -> Dictionary:
	return {"pity_5": 0, "pity_4": 0, "guaranteed_5": false, "guaranteed_4": false}


## Bộ đếm (bản gốc, sửa trực tiếp) của nhóm bảo hiểm mà banner dùng.
func get_pity(banner: BannerData) -> Dictionary:
	var key := String(banner.pity_group)
	if not pity_state.has(key):
		pity_state[key] = new_pity_state()
	return pity_state[key]


func get_pull_count(banner_id: StringName) -> int:
	return int(pull_counts.get(String(banner_id), 0))


# --- Quay (hàm thuần) ---

## Quay 1 lượt trên `banner`, cập nhật `state` (bộ đếm của nhóm bảo hiểm).
## Trả về { "rarity": 3|4|5, "character": id ("" nếu 3★), "items": {} (3★), "featured": bool, "lost": bool, "pity": n }.
## "lost" = lệch 50/50 (lần sau chắc chắn nổi bật); "pity" = lượt thứ mấy kể từ lần 5★ / 4★ trước.
static func roll(banner: BannerData, state: Dictionary, random: RandomNumberGenerator) -> Dictionary:
	var pity_5 := int(state.get("pity_5", 0)) + 1
	var pity_4 := int(state.get("pity_4", 0)) + 1
	if random.randf() < banner.rate_5_at(pity_5):
		state["pity_5"] = 0
		state["pity_4"] = 0
		var pick := _pick_featured(banner.featured_5, banner.pool_5, banner.featured_5_chance,
				bool(state.get("guaranteed_5", false)), random)
		state["guaranteed_5"] = pick["lost"]
		pick["rarity"] = 5
		pick["pity"] = pity_5
		return pick
	state["pity_5"] = pity_5
	if pity_4 >= banner.hard_pity_4 or random.randf() < banner.base_rate_4:
		state["pity_4"] = 0
		var pick := _pick_featured(banner.featured_4, banner.get_off_featured_4(), banner.featured_4_chance,
				bool(state.get("guaranteed_4", false)), random)
		state["guaranteed_4"] = pick["lost"]
		pick["rarity"] = 4
		pick["pity"] = pity_4
		return pick
	state["pity_4"] = pity_4
	return {"rarity": 3, "character": &"", "items": _pick_three_star(banner, random), "featured": false,
			"lost": false, "pity": pity_4}


## Chọn nhân vật: không có nổi bật → đều trong `others`; có → nổi bật nếu đang bảo đảm hoặc trúng `chance`,
## lệch thì 1 người trong `others` và báo "lost".
static func _pick_featured(featured: Array[StringName], others: Array[StringName], chance: float,
		guaranteed: bool, random: RandomNumberGenerator) -> Dictionary:
	if featured.is_empty():
		return {"character": others[random.randi() % others.size()], "items": {}, "featured": false, "lost": false}
	if guaranteed or others.is_empty() or random.randf() < chance:
		return {"character": featured[random.randi() % featured.size()], "items": {}, "featured": true, "lost": false}
	return {"character": others[random.randi() % others.size()], "items": {}, "featured": false, "lost": true}


static func _pick_three_star(banner: BannerData, random: RandomNumberGenerator) -> Dictionary:
	var total := 0.0
	for entry in banner.three_star_rewards:
		total += float(entry.get("weight", 1))
	var value := random.randf() * total
	for entry in banner.three_star_rewards:
		value -= float(entry.get("weight", 1))
		if value < 0.0:
			return {str(entry["item"]): int(entry.get("count", 1))}
	if banner.three_star_rewards.is_empty():
		return {}
	var last: Dictionary = banner.three_star_rewards[-1]
	return {str(last["item"]): int(last.get("count", 1))}


# --- Vé ---

func get_ticket_count(banner: BannerData) -> int:
	return GameState.get_item_count(banner.ticket_item)


## Số vé còn thiếu để quay `count` lượt.
func tickets_missing(banner: BannerData, count: int) -> int:
	return maxi(count - get_ticket_count(banner), 0)


func exchange_cost(ticket_count: int) -> int:
	return ticket_count * config.currency_per_ticket


## Đổi Lệ Tinh lấy `ticket_count` vé `ticket_item`. Thiếu Lệ Tinh hoặc vé không đổi được thì trả về false.
func exchange_tickets(ticket_item: StringName, ticket_count: int) -> bool:
	if ticket_count <= 0 or not config.exchangeable_tickets.has(ticket_item):
		return false
	if not GameState.spend_items({config.currency_item: exchange_cost(ticket_count)}):
		return false
	GameState.add_item(ticket_item, ticket_count)
	changed.emit()
	return true


## Đủ vé quay ngay, hoặc đủ Lệ Tinh để đổi phần vé còn thiếu.
func can_afford(banner: BannerData, count: int) -> bool:
	var missing := tickets_missing(banner, count)
	return missing == 0 or GameState.get_item_count(config.currency_item) >= exchange_cost(missing)


# --- Quay thật ---

## Quay `count` lượt trên banner (trừ vé; thiếu vé thì trả về [] – giao diện hỏi đổi Lệ Tinh trước).
## Mỗi kết quả là kết quả của `roll()` thêm "new", "eidolon", "overflow", "stardust" cho nhân vật.
func pull(banner_id: StringName, count: int) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var banner := get_banner(banner_id)
	if banner == null or count <= 0 or not is_unlocked():
		return results
	if not GameState.spend_items({banner.ticket_item: count}):
		return results
	var state := get_pity(banner)
	var key := String(banner_id)
	for i in count:
		var result := roll(banner, state, rng)
		_apply(result)
		results.append(result)
		pull_counts[key] = get_pull_count(banner_id) + 1
		_add_history(key, result)
	EventBus.gacha_pulled.emit(banner_id, results)
	changed.emit()
	if autosave:
		SaveManager.save_game()
	return results


## Trao kết quả: nhân vật (mới / Tinh Mệnh / Bụi Sao khi trùng) hoặc vật phẩm 3★.
func _apply(result: Dictionary) -> void:
	if int(result["rarity"]) == 3:
		for item_id: Variant in result["items"]:
			GameState.add_item(StringName(str(item_id)), int(result["items"][item_id]))
		return
	var rarity := int(result["rarity"])
	var grant := GameState.grant_character(result["character"])
	var stardust := 0
	if not bool(grant["new"]):
		stardust += int(config.dupe_stardust.get(rarity, 0))
		if bool(grant["overflow"]):
			stardust += int(config.overflow_stardust.get(rarity, 0))
	if stardust > 0:
		GameState.add_item(config.stardust_item, stardust)
	result["new"] = grant["new"]
	result["eidolon"] = grant["eidolon"]
	result["overflow"] = grant["overflow"]
	result["stardust"] = stardust


func _add_history(banner_key: String, result: Dictionary) -> void:
	var entry := {"rarity": int(result["rarity"]), "time": QuestManager.now_unix()}
	if int(result["rarity"]) == 3:
		entry["items"] = (result["items"] as Dictionary).duplicate()
	else:
		entry["character"] = String(result["character"])
	var list: Array = history.get(banner_key, [])
	list.push_front(entry)
	if list.size() > config.history_limit:
		list.resize(config.history_limit)
	history[banner_key] = list


func get_history(banner_id: StringName) -> Array:
	return history.get(String(banner_id), [])


# --- Chọn 5★ sau 300 lượt (banner thường) ---

func selector_progress(banner: BannerData) -> int:
	return mini(get_pull_count(banner.id), banner.selector_pulls)


func can_claim_selector(banner: BannerData) -> bool:
	return banner != null and banner.selector_pulls > 0 and get_pull_count(banner.id) >= banner.selector_pulls \
			and not selector_claimed.has(String(banner.id))


## Nhận miễn phí 1 nhân vật trong pool_5 (một lần). Trả về như GameState.grant_character, {} nếu không được.
func claim_selector(banner_id: StringName, character_id: StringName) -> Dictionary:
	var banner := get_banner(banner_id)
	if not can_claim_selector(banner) or not banner.pool_5.has(character_id):
		return {}
	selector_claimed.append(String(banner_id))
	var result := {"rarity": 5, "character": character_id, "items": {}, "featured": false, "lost": false, "pity": 0}
	_apply(result)
	changed.emit()
	if autosave:
		SaveManager.save_game()
	return result


# --- Cửa hàng Bụi Sao ---

## Tháng hiện tại theo ngày làm mới của QuestManager (đổi lúc 4:00 ngày 1; đứng yên khi giờ máy bị lùi).
func current_shop_month() -> int:
	var date := Time.get_date_dict_from_unix_time(QuestManager.get_day_index() * 86400)
	return int(date["year"]) * 12 + int(date["month"]) - 1


## Sang tháng mới thì xóa số lần đã mua. Tháng lùi (chỉnh giờ) thì giữ nguyên.
func refresh_shop() -> void:
	var month := current_shop_month()
	if month > shop_month:
		shop_month = month
		shop_bought.clear()


func get_shop_remaining(item_id: StringName) -> int:
	refresh_shop()
	var entry := config.find_shop_entry(item_id)
	if entry.is_empty():
		return 0
	return maxi(int(entry.get("monthly_limit", 0)) - int(shop_bought.get(String(item_id), 0)), 0)


func can_buy(item_id: StringName, times: int = 1) -> bool:
	var entry := config.find_shop_entry(item_id)
	return not entry.is_empty() and times > 0 and get_shop_remaining(item_id) >= times \
			and GameState.get_item_count(config.stardust_item) >= int(entry.get("price", 0)) * times


func buy(item_id: StringName, times: int = 1) -> bool:
	if not can_buy(item_id, times):
		return false
	var entry := config.find_shop_entry(item_id)
	GameState.spend_items({config.stardust_item: int(entry.get("price", 0)) * times})
	GameState.add_item(item_id, int(entry.get("count", 1)) * times)
	shop_bought[String(item_id)] = int(shop_bought.get(String(item_id), 0)) + times
	changed.emit()
	if autosave:
		SaveManager.save_game()
	return true


## Giây còn lại tới lần làm mới cửa hàng (4:00 ngày 1 tháng sau).
func seconds_until_shop_reset() -> int:
	var date := Time.get_date_dict_from_unix_time(QuestManager.get_day_index() * 86400)
	var year := int(date["year"])
	var month := int(date["month"]) + 1
	if month > 12:
		month = 1
		year += 1
	var next_day := floori(Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": 1,
			"hour": 0, "minute": 0, "second": 0}) / 86400.0)
	return maxi(QuestManager.day_start_unix(next_day) - QuestManager.now_unix(), 0)


# --- Quà mở Gacha ---

## Trao quà mở Gacha (một lần) nếu gacha đã mở. Gọi khi cờ mở khóa bật và sau khi tải save.
func grant_open_gift() -> bool:
	if open_gift_granted or not is_unlocked() or QuestManager.config == null:
		return false
	open_gift_granted = true
	var gift: Dictionary = QuestManager.config.gacha_open_gift
	Loot.grant(gift)
	EventBus.reward_popup_requested.emit(tr("GACHA_TOAST_UNLOCKED"), Loot.describe(gift))
	changed.emit()
	return true


func _on_story_flag_set(flag: StringName, value: Variant) -> void:
	if config and flag == config.unlock_flag and bool(value):
		grant_open_gift()


# --- Lưu ---

## JSON đọc số thành float: đổi lại về int cho hạng, giờ, số lượng vật phẩm.
static func _normalize_history(entries: Array) -> Array:
	var result: Array = []
	for entry: Variant in entries:
		if not entry is Dictionary:
			continue
		var clean := {"rarity": int(entry.get("rarity", 3)), "time": int(entry.get("time", 0))}
		if entry.has("character"):
			clean["character"] = str(entry["character"])
		var items: Variant = entry.get("items")
		if items is Dictionary:
			var counts := {}
			for item_id: Variant in items:
				counts[str(item_id)] = int(items[item_id])
			clean["items"] = counts
		result.append(clean)
	return result


func to_dict() -> Dictionary:
	return {
		"pity_state": pity_state.duplicate(true),
		"pull_counts": pull_counts.duplicate(),
		"history": history.duplicate(true),
		"selector_claimed": selector_claimed.duplicate(),
		"shop_month": shop_month,
		"shop_bought": shop_bought.duplicate(),
		"open_gift_granted": open_gift_granted,
		"rng_seed": str(rng.seed),
		"rng_state": str(rng.state),
	}


func from_dict(data: Dictionary) -> void:
	pity_state.clear()
	var saved_pity: Variant = data.get("pity_state", {})
	if saved_pity is Dictionary:
		for group: Variant in saved_pity:
			var entry: Variant = saved_pity[group]
			if entry is Dictionary:
				var state := new_pity_state()
				state["pity_5"] = int(entry.get("pity_5", 0))
				state["pity_4"] = int(entry.get("pity_4", 0))
				state["guaranteed_5"] = bool(entry.get("guaranteed_5", false))
				state["guaranteed_4"] = bool(entry.get("guaranteed_4", false))
				pity_state[str(group)] = state
	pull_counts.clear()
	var counts: Variant = data.get("pull_counts", {})
	if counts is Dictionary:
		for key: Variant in counts:
			pull_counts[str(key)] = int(counts[key])
	history.clear()
	# Save trước Phase 11 lưu lịch sử dạng mảng rỗng → bỏ qua.
	var saved_history: Variant = data.get("history", {})
	if saved_history is Dictionary:
		for key: Variant in saved_history:
			if saved_history[key] is Array:
				history[str(key)] = _normalize_history(saved_history[key])
	selector_claimed.clear()
	var claimed: Variant = data.get("selector_claimed", [])
	if claimed is Array:
		for id: Variant in claimed:
			selector_claimed.append(str(id))
	shop_month = int(data.get("shop_month", -1))
	shop_bought.clear()
	var bought: Variant = data.get("shop_bought", {})
	if bought is Dictionary:
		for key: Variant in bought:
			shop_bought[str(key)] = int(bought[key])
	open_gift_granted = bool(data.get("open_gift_granted", false))
	if data.has("rng_seed"):
		rng.seed = int(str(data["rng_seed"]))
		rng.state = int(str(data.get("rng_state", "0")))
	# Save cũ đã qua Chương 1 trước khi có gacha: trao quà mở Gacha bù.
	grant_open_gift()
	changed.emit()
