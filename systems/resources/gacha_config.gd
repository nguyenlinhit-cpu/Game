class_name GachaConfig
extends Resource
## Cấu hình gacha chung (mục 10): banner đang mở, đổi Lệ Tinh lấy vé, Bụi Sao khi trùng, cửa hàng Bụi Sao.
## Quà mở Gacha nằm ở QuestConfig.gacha_open_gift (một nguồn cho cả báo cáo kinh tế).

## Banner đang mở, theo thứ tự trên màn gacha.
@export var banners: Array[BannerData] = []
## Gacha mở khi cờ cốt truyện này bật.
@export var unlock_flag: StringName = &"chapter_1_complete"
@export var currency_item: StringName = &"star_tear"
## Lệ Tinh đổi 1 vé bất kỳ.
@export var currency_per_ticket: int = 160
## Vé đổi được bằng Lệ Tinh.
@export var exchangeable_tickets: Array[StringName] = [&"wish_ticket_standard", &"wish_ticket_limited"]
@export var stardust_item: StringName = &"stardust"
## Bụi Sao mỗi lần trùng, theo hạng { 5: 40, 4: 8 }.
@export var dupe_stardust: Dictionary = {5: 40, 4: 8}
## Trùng từ lần thứ 7 (Tinh Mệnh đã đủ 6): đổi thành Bụi Sao, cộng thêm vào phần trên.
@export var overflow_stardust: Dictionary = {5: 100, 4: 20}
## Cửa hàng Bụi Sao: mỗi dòng { "item": id, "count": số lượng mỗi lần mua, "price": Bụi Sao, "monthly_limit": lần/tháng }.
## Làm mới 4:00 (giờ làm mới nhiệm vụ) ngày 1 hằng tháng.
@export var shop_entries: Array[Dictionary] = []
## Số lượt giữ trong lịch sử mỗi banner.
@export var history_limit: int = 100


func find_banner(banner_id: StringName) -> BannerData:
	for banner in banners:
		if banner.id == banner_id:
			return banner
	return null


func find_shop_entry(item_id: StringName) -> Dictionary:
	for entry in shop_entries:
		if StringName(str(entry.get("item", ""))) == item_id:
			return entry
	return {}
