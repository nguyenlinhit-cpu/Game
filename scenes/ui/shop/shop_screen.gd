class_name ShopScreen
extends VBoxContainer
## Quầy hàng của Bram ở Sảnh: mua Ký Ức / Hộp Bí Kỹ bằng Xu Aether, giới hạn mỗi ngày (data/shop/hub_shop.tres).

const SHOP_PATH: String = "res://data/shop/hub_shop.tres"

var shop: ShopData
var _coins: Label
var _list: VBoxContainer
var _buttons: Dictionary = {}


static func load_shop() -> ShopData:
	return load(SHOP_PATH) as ShopData


## Số lần còn mua được hôm nay.
static func remaining(data: ShopData, item_id: StringName) -> int:
	_refresh_day()
	var entry := data.find_entry(item_id)
	var bought: Dictionary = GameState.shop_state.get("bought", {})
	return maxi(int(entry.get("daily_limit", 0)) - int(bought.get(String(item_id), 0)), 0)


static func buy(data: ShopData, item_id: StringName) -> bool:
	var entry := data.find_entry(item_id)
	if entry.is_empty() or remaining(data, item_id) <= 0:
		return false
	if not GameState.spend_items({data.currency_item: int(entry.get("price", 0))}):
		return false
	GameState.add_item(item_id, int(entry.get("count", 1)))
	var bought: Dictionary = GameState.shop_state.get("bought", {})
	bought[String(item_id)] = int(bought.get(String(item_id), 0)) + 1
	GameState.shop_state["bought"] = bought
	return true


static func _refresh_day() -> void:
	var today := QuestManager.get_day_index()
	if int(GameState.shop_state.get("day", -1)) < today:
		GameState.shop_state = {"day": today, "bought": {}}


func _ready() -> void:
	shop = load_shop()
	add_theme_constant_override("separation", 14)
	_coins = UiKit.make_label("", 26, UiKit.GOLD)
	add_child(_coins)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 10)
	add_child(_list)
	refresh()


func get_buy_button(item_id: StringName) -> Button:
	return _buttons.get(item_id)


func refresh() -> void:
	UiKit.clear(_list)
	_buttons.clear()
	_coins.text = "%s: %d" % [UiKit.item_name(shop.currency_item), GameState.get_item_count(shop.currency_item)]
	for entry in shop.entries:
		var item_id := StringName(str(entry["item"]))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		_list.add_child(row)
		var info := UiKit.make_rich(24)
		info.custom_minimum_size = Vector2(560.0, 0.0)
		info.text = "%s ×%d\n[color=#aaaabb]%s[/color]" % [UiKit.item_name(item_id), int(entry.get("count", 1)),
				tr("SHOP_DAILY_LEFT") % [remaining(shop, item_id), int(entry.get("daily_limit", 0))]]
		row.add_child(info)
		var button := UiKit.make_button("%d %s" % [int(entry.get("price", 0)), UiKit.item_name(shop.currency_item)],
				_on_buy.bind(item_id), Vector2(260.0, 60.0))
		button.disabled = remaining(shop, item_id) <= 0 \
				or GameState.get_item_count(shop.currency_item) < int(entry.get("price", 0))
		row.add_child(button)
		_buttons[item_id] = button


func _on_buy(item_id: StringName) -> void:
	if buy(shop, item_id):
		EventBus.toast_requested.emit(tr("GACHA_TOAST_BOUGHT") % UiKit.item_name(item_id))
	refresh()
