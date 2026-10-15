extends Node2D
## Painted bridges cover the same three floor cells and two rail cells as collision.
var map: OverworldMap
var painting: Texture2D

const BRIDGES := {
	&"library": Rect2(0, 335, 175, 210),
	&"vault": Rect2(0, 360, 170, 140),
	&"furnace": Rect2(0, 380, 260, 110),
	&"tower": Rect2(0, 350, 290, 160),
}

func _ready() -> void:
	# Terrain must render below every actor, regardless of sibling insertion order.
	z_index = -10
	if map:
		painting = load("res://map/remaining/%s_v1.png" % map.zone) as Texture2D
		map.corridor_layer.visible = false
		queue_redraw()

func _draw() -> void:
	if map == null or painting == null or not BRIDGES.has(map.zone):
		return
	for connection in map.room_manager.connections:
		var a: Room = connection[0]
		var b: Room = connection[1]
		var horizontal := a.grid_cell.y == b.grid_cell.y
		var from := a.get_center_world_tile()
		var to := b.get_center_world_tile()
		var start := from.x + a.get_half_extent().x if horizontal else from.y + a.get_half_extent().y
		var end := to.x - b.get_half_extent().x + 1 if horizontal else to.y - b.get_half_extent().y + 1
		var axis := from.y if horizontal else from.x
		for along in range(start, end, 4):
			var length := mini(4, end - along) * Room.TILE_SIZE
			var source: Rect2 = BRIDGES[map.zone]
			source.size.x *= float(length) / 256.0
			if horizontal:
				var target := Rect2(Vector2(along * 64, (axis - 2) * 64), Vector2(length, 320))
				draw_texture_rect_region(painting, target, source)
			else:
				draw_set_transform(Vector2((axis + 3) * 64, along * 64), PI / 2)
				draw_texture_rect_region(painting, Rect2(0, 0, length, 320), source)
				draw_set_transform(Vector2.ZERO)
