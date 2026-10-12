class_name TileIds
extends RefCounted
## Toạ độ ô trong tileset tạm `assets/tilesets/placeholder_tileset.tres`.
## Phase 12–13 mỗi khu có tileset riêng nhưng giữ cùng bố cục ô này để phòng mẫu dùng lại được.

const SOURCE_ID: int = 0
const FLOOR_A := Vector2i(0, 0)
const FLOOR_B := Vector2i(1, 0)
const WALL := Vector2i(2, 0)
const CORRIDOR_FLOOR := Vector2i(3, 0)
const CORRIDOR_WALL := Vector2i(4, 0)
## Các ô có va chạm.
const SOLID: Array[Vector2i] = [WALL, CORRIDOR_WALL]
