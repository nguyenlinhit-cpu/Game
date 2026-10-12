class_name EncounterWave
extends Resource
## Một đợt quái trong trận (tối đa 5 con).

@export var entries: Array[EncounterEnemyEntry] = []


func get_enemy_count() -> int:
	var total := 0
	for entry in entries:
		total += entry.count
	return total
