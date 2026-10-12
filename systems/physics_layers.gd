class_name PhysicsLayers
extends RefCounted
## Bit lớp va chạm 2D dùng chung (tên lớp đặt trong Project Settings > Layer Names).

const WORLD: int = 1 << 0
const PLAYER: int = 1 << 1
const ENEMY: int = 1 << 2
const INTERACTABLE: int = 1 << 3
## Rào Ma Biến: chặn như tường, riêng Bí Kỹ "Bước Hư Ảnh" lướt xuyên qua được.
const WARP_BARRIER: int = 1 << 4
