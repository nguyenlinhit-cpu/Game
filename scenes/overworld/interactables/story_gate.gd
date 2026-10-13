class_name StoryGate
extends Node
## Gắn làm con của một vật trên map để vật chỉ có mặt khi cờ cốt truyện cho phép:
## hiện khi mọi cờ `show_if` bật và mọi cờ `hide_if` tắt. OverworldMap gỡ vật không đạt khi nạp map
## và khi cờ đổi (quái bị gỡ im lặng, không tính là đã hạ).

@export var show_if: PackedStringArray = PackedStringArray()
@export var hide_if: PackedStringArray = PackedStringArray()


func is_open() -> bool:
	return StoryManager.check(Array(show_if), Array(hide_if))


## Vật `node` có được phép có mặt không (không có StoryGate con thì luôn được).
static func allows(node: Node) -> bool:
	for child in node.get_children():
		if child is StoryGate and not (child as StoryGate).is_open():
			return false
	return true
