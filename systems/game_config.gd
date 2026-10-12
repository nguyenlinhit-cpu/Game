class_name GameConfig
extends RefCounted
## Hằng số cấu hình toàn game. Nâng giới hạn cấp (vd. lên 80) chỉ cần sửa MAX_LEVEL ở đây.

## Giới hạn cấp hiện tại.
const MAX_LEVEL: int = 30
## Cấp tối đa theo thiết kế: bảng chỉ số tính sẵn tới cấp này để sau nâng giới hạn.
const DESIGN_MAX_LEVEL: int = 80
## Đội hình tối đa 4 nhân vật, trong trận không đổi người.
const MAX_TEAM_SIZE: int = 4
