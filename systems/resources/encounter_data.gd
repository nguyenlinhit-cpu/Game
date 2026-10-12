class_name EncounterData
extends Resource
## Một nhóm quái trên map = một trận, có thể nhiều đợt. Gắn vào OverworldEnemy.

enum Kind { NORMAL, ELITE, BOSS }

@export var id: StringName
@export var waves: Array[EncounterWave] = []
@export var kind: Kind = Kind.NORMAL
## Khu vực (Phase 12 đặt lên map): lobby, library, vault, furnace, tower; rỗng = trận thử.
@export var zone: StringName = &""
## Cấp đội khuyến nghị (0 = không ghi).
@export var recommended_level: int = 0
## Nhạc trận (PlaceholderMusic id; rỗng = nhạc trận thường hoặc nhạc của boss).
@export var music_id: StringName = &""


func get_max_level() -> int:
	var best := 0
	for wave in waves:
		for entry in wave.entries:
			best = maxi(best, entry.level)
	return best


func get_total_enemy_count() -> int:
	var total := 0
	for wave in waves:
		total += wave.get_enemy_count()
	return total


## Quái đầu tiên của đợt đầu, dùng làm hình đại diện trên map.
func get_leader() -> EnemyData:
	for wave in waves:
		for entry in wave.entries:
			if entry.enemy:
				return entry.enemy
	return null


func is_boss() -> bool:
	return kind == Kind.BOSS


## Boss đầu tiên trong trận (null nếu không có).
func get_boss() -> EnemyData:
	for wave in waves:
		for entry in wave.entries:
			if entry.enemy and entry.enemy.is_boss():
				return entry.enemy
	return null


## Trả về danh sách lỗi dữ liệu (rỗng = hợp lệ).
func validate() -> Array[String]:
	var errors: Array[String] = []
	if waves.is_empty():
		errors.append("%s: không có đợt quái nào" % id)
	for i in waves.size():
		var count := waves[i].get_enemy_count()
		if count == 0 or count > BattleTypes.MAX_ENEMIES_PER_WAVE:
			errors.append("%s: đợt %d có %d quái (phải 1–%d)" % [id, i + 1, count, BattleTypes.MAX_ENEMIES_PER_WAVE])
		for entry in waves[i].entries:
			if entry.enemy == null:
				errors.append("%s: đợt %d có dòng thiếu EnemyData" % [id, i + 1])
	return errors
