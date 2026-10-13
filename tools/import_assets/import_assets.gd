extends Node
## Chạy công cụ nhập asset không cần mở editor:
##   godot --headless --path . --import
##   godot --headless --path . res://tools/import_assets/import_assets.tscn
## In danh sách đã nhận / còn thiếu và ghi docs/ASSET_STATUS.md.


func _ready() -> void:
	var importer := AssetImporter.new()
	var report := importer.run(true)
	print("== Đã nhận (%d) ==" % report["built"].size())
	for entry: String in report["built"]:
		print("  + ", entry)
	for entry: String in report["warnings"]:
		print("  ! ", entry)
	print("== Còn thiếu (%d mục, đang dùng hình tạm) ==" % report["missing"].size())
	print(importer.get_missing_text())
	print("Đã ghi ", AssetImporter.STATUS_PATH)
	get_tree().quit()
