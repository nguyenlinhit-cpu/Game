@tool
extends EditorScript
## Trong editor: mở file này ở Script Editor → File → Run (Ctrl+Shift+X). Quét assets/, tạo SpriteFrames / TileSet,
## in danh sách còn thiếu ở Output và ghi docs/ASSET_STATUS.md. Editor tự import PNG mới khi thả vào thư mục.


func _run() -> void:
	var importer := AssetImporter.new()
	var report := importer.run(true)
	print("Đã nhận %d mục, còn thiếu %d mục." % [report["built"].size(), report["missing"].size()])
	for entry: String in report["warnings"]:
		push_warning(entry)
	print(importer.get_missing_text())
	EditorInterface.get_resource_filesystem().scan()
