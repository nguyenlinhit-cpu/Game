extends TalentScript
## Đặc tính "Dòng Chảy Ân Cần": lần đầu mỗi đồng minh rơi xuống dưới 30% máu trong trận,
## Mira lập tức hồi cho người đó 15% máu tối đa (đòn phụ, không tốn lượt).
## E2: kích hoạt tối đa 2 lần cho mỗi đồng minh. E4: dùng Tuyệt kỹ xong cả đội hồi 10 năng lượng.
## E6: một lần mỗi trận, đồng minh đầu tiên ngã được hồi sinh với 30% máu.
## (E1, E3, E5 tăng hệ số: khai báo trong EidolonData.)

const TALENT_HEAL: SkillData = preload("res://data/skills/mira_talent_heal.tres")
const HP_THRESHOLD: float = 0.3
const E4_ENERGY: float = 10.0
const E6_REVIVE_RATIO: float = 0.3

var _triggers: Dictionary = {}
var _revive_used: bool = false


func _on_attach() -> void:
	for ally in battle.allies:
		_connect(ally.hp_changed, _on_ally_hp_changed)


func _on_ally_hp_changed(ally: BattleUnit) -> void:
	if not ally.is_alive() or ally.get_hp_ratio() >= HP_THRESHOLD or not owner.is_alive():
		return
	var limit := 2 if has_eidolon(2) else 1
	if int(_triggers.get(ally, 0)) >= limit:
		return
	_triggers[ally] = int(_triggers.get(ally, 0)) + 1
	battle.request_follow_up(owner, TALENT_HEAL, ally)


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user == owner and has_eidolon(4) and ctx.get_kind() == SkillData.Kind.ULTIMATE:
		for ally in battle.get_friends(owner):
			ally.add_energy(E4_ENERGY)
			ctx.events.append({"type": "energy", "target": ally, "amount": E4_ENERGY, "crit": false})


func _on_unit_died(unit: BattleUnit) -> void:
	if has_eidolon(6) and not _revive_used and unit.is_ally():
		_revive_used = true
		report(battle.revive(unit, E6_REVIVE_RATIO))
