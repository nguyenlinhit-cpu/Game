class_name BattleTypes
extends RefCounted
## Kiểu dữ liệu dùng chung giữa map và trận.

## Kiểu mở trận (mục 4 "Vào trận").
enum Opening { NORMAL, ADVANTAGE, AMBUSHED }

## Quái thấp hơn đội từ chừng này cấp trở lên: đánh trúng trên map là thắng ngay.
const INSTANT_WIN_LEVEL_GAP: int = 10
## Phe quái tối đa mỗi đợt (mục 5).
const MAX_ENEMIES_PER_WAVE: int = 5

const OPENING_KEYS: Dictionary = {
	Opening.NORMAL: "OPENING_NORMAL",
	Opening.ADVANTAGE: "OPENING_ADVANTAGE",
	Opening.AMBUSHED: "OPENING_AMBUSHED",
}


static func opening_key(opening: Opening) -> String:
	return OPENING_KEYS.get(opening, "OPENING_NORMAL")


static func is_instant_win(team_level: int, enemy_level: int) -> bool:
	return team_level - enemy_level >= INSTANT_WIN_LEVEL_GAP
