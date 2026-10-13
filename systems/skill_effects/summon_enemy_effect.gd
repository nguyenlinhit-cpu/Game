class_name SummonEnemyEffect
extends SkillEffect
## Quái gọi thêm quái vào đợt hiện tại (sách bay, Mầm, ong...). Quái gọi ra vẫn tính vào giới hạn 5 quái;
## hết chỗ thì không gọi thêm.

@export var enemy: EnemyData
@export var count: int = 1
## Cấp quái gọi ra = cấp người gọi + level_offset.
@export var level_offset: int = 0


func apply(ctx: SkillContext) -> void:
	for i in count:
		var unit := ctx.battle.spawn_enemy(enemy, maxi(ctx.user.level + level_offset, 1))
		if unit == null:
			break
		ctx.events.append({"type": "summon", "target": unit, "amount": 0.0, "crit": false})
