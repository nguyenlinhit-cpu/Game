class_name EncounterEnemyEntry
extends Resource
## Một dòng trong đợt quái: loại quái, cấp, số lượng.

@export var enemy: EnemyData
@export_range(1, 80) var level: int = 1
@export_range(1, 5) var count: int = 1
