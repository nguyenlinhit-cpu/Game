class_name ShopData
extends Resource
## Quầy hàng bán bằng Xu Aether (Sảnh Trung Tâm). Mỗi dòng { "item", "count", "price", "daily_limit" };
## số lần mua làm mới theo kỳ ngày của QuestManager (4:00, chống chỉnh giờ lùi).

@export var currency_item: StringName = &"aether_coin"
@export var entries: Array[Dictionary] = []


func find_entry(item_id: StringName) -> Dictionary:
	for entry in entries:
		if StringName(str(entry.get("item", ""))) == item_id:
			return entry
	return {}
