extends TalentScript
## Đặc tính "Tro Tàn Lan": Ember hạ một quái thì vụ nổ gây 50% Tấn Công sát thương Lửa lên mọi quái còn lại
## (tối đa 1 lần mỗi hành động).
## E1: vụ nổ giảm khiên 10 mỗi quái. E2: vụ nổ hạ quái thì nổ tiếp (tối đa 2 lần mỗi hành động).
## E4: hạ quái hồi 10 năng lượng. E6: vụ nổ 80% Tấn Công.

const BLAST: float = 0.5
const BLAST_E6: float = 0.8
const E1_TOUGHNESS: float = 10.0
const E4_ENERGY: float = 10.0


func _on_after_damage(ctx: SkillContext, target: BattleUnit, _amount: float, _crit: bool) -> void:
	if ctx.user != owner or target.is_alive() or target.is_ally():
		return
	if has_eidolon(4):
		owner.add_energy(E4_ENERGY)
	var limit := 2 if has_eidolon(2) else 1
	var blasts := int(ctx.custom.get("ember_blasts", 0))
	if blasts >= limit:
		return
	ctx.custom["ember_blasts"] = blasts + 1
	ctx.events.append({"type": "blast", "target": target, "amount": 0.0, "crit": false})
	for enemy in battle.get_foes(owner):
		ctx.deal_damage(enemy, Stats.Type.ATK, BLAST_E6 if has_eidolon(6) else BLAST, E1_TOUGHNESS if has_eidolon(1) else 0.0)
