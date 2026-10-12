class_name TurnOrderBar
extends Control
## Thanh thứ tự lượt dọc bên trái: các lượt sắp tới kèm Giá trị Hành Động.
## Khi đang chọn kỹ năng có kéo/đẩy lượt, hiện bản xem trước và đánh dấu ô thay đổi.

const ENTRY_HEIGHT: float = 78.0
const ALLY_BACK := Color(0.16, 0.22, 0.38, 0.9)
const ENEMY_BACK := Color(0.38, 0.14, 0.16, 0.9)
const CHANGED_COLOR := Color("f2d58a")

var _entries: Array[Dictionary] = []
var _baseline: Array[Dictionary] = []
var _current: BattleUnit
var _previewing: bool = false


## `entries`: kết quả TurnQueue.predict (lượt sau lượt hiện tại). `current`: đơn vị đang trong lượt.
func show_order(current: BattleUnit, entries: Array[Dictionary]) -> void:
	_current = current
	_entries = entries
	_baseline = entries
	_previewing = false
	queue_redraw()


func show_preview(entries: Array[Dictionary]) -> void:
	_entries = entries
	_previewing = true
	queue_redraw()


func is_previewing() -> bool:
	return _previewing


func get_entries() -> Array[Dictionary]:
	return _entries


func _draw() -> void:
	var font := get_theme_default_font()
	var y := 0.0
	if _current:
		_draw_entry(font, Rect2(0.0, y, size.x, ENTRY_HEIGHT + 10.0), _current, -1.0, false, true)
		y += ENTRY_HEIGHT + 22.0
	for i in _entries.size():
		if y + ENTRY_HEIGHT > size.y:
			break
		var entry := _entries[i]
		var changed: bool = _previewing and (i >= _baseline.size() or _baseline[i]["unit"] != entry["unit"])
		_draw_entry(font, Rect2(0.0, y, size.x, ENTRY_HEIGHT - 6.0), entry["unit"], entry["time"], changed, false)
		y += ENTRY_HEIGHT


func _draw_entry(font: Font, rect: Rect2, unit: BattleUnit, time: float, changed: bool, acting: bool) -> void:
	draw_rect(rect, ALLY_BACK if unit.is_ally() else ENEMY_BACK)
	if acting:
		draw_rect(rect, CHANGED_COLOR, false, 3.0)
	elif changed:
		draw_rect(rect, CHANGED_COLOR, false, 2.0)
	var center := Vector2(rect.position.x + 38.0, rect.get_center().y)
	draw_circle(center, 26.0, unit.color)
	draw_string(font, center + Vector2(-9.0, 10.0), unit.letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)
	var label := tr("BATTLE_NOW") if acting else "%d" % roundi(time)
	draw_string(font, Vector2(rect.position.x + 74.0, center.y + 9.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 24,
			CHANGED_COLOR if changed or acting else Color.WHITE)
