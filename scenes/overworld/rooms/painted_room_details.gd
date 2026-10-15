extends Node2D
## Small architectural joins keep the authored painting consistent with actual doors
## and the four elemental puzzle alcoves. All samples come from the room painting.

const MATERIALS := {
	&"library": [Rect2(1010, 440, 60, 60), Rect2(540, 115, 55, 55)],
	&"vault": [Rect2(865, 490, 60, 60), Rect2(625, 125, 55, 55)],
	&"furnace": [Rect2(795, 440, 60, 60), Rect2(590, 110, 55, 55)],
	&"tower": [Rect2(620, 405, 60, 60), Rect2(595, 165, 55, 55)],
}

func _ready() -> void:
	queue_redraw.call_deferred()

func _draw() -> void:
	var room := get_parent() as Room
	if room == null or room.backdrop == null:
		return
	var theme := room.zone
	if not MATERIALS.has(theme):
		return
	var wall_sample: Rect2 = MATERIALS[theme][1]
	var material := load("res://map/remaining/%s_v1.png" % theme) as Texture2D
	var half := room.get_half_extent()
	for side in Room.ALL_SIDES:
		if not (room.connected_sides & side):
			for cell in room.get_door_gap_cells(side):
				draw_texture_rect_region(material, Rect2(Vector2(cell * 64), Vector2.ONE * 64), wall_sample)
	if room.room_type == Room.RoomType.PUZZLE:
		for cell in room.wall_layer.get_used_cells():
			if absi(cell.x) < half.x and absi(cell.y) < half.y:
				draw_texture_rect_region(material, Rect2(Vector2(cell * 64), Vector2.ONE * 64), wall_sample)
