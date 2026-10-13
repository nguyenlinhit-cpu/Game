class_name TravelMenu
extends VBoxContainer
## Danh sách điểm đến: Cổng Dịch Chuyển (các khu đã mở) hoặc dịch chuyển nhanh giữa các phòng nghỉ đã mở.
## Mỗi điểm đến { "label", "scene", "room" }; bấm thì phát destination_chosen.

signal destination_chosen(scene_path: String, room_id: StringName)

var destinations: Array[Dictionary] = []
var _buttons: Array[Button] = []


func setup(items: Array[Dictionary], empty_key: String) -> void:
	destinations = items
	add_theme_constant_override("separation", 10)
	if items.is_empty():
		add_child(UiKit.make_label(tr(empty_key), 26, Color(0.75, 0.75, 0.8)))
		return
	for item in items:
		var button := UiKit.make_button(str(item["label"]), _choose.bind(item), Vector2(640.0, 64.0))
		button.add_theme_font_size_override("font_size", 26)
		add_child(button)
		_buttons.append(button)


func get_buttons() -> Array[Button]:
	return _buttons


func _choose(item: Dictionary) -> void:
	destination_chosen.emit(str(item["scene"]), StringName(str(item["room"])))
