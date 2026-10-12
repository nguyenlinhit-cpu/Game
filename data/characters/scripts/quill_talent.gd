extends TalentScript
## Đặc tính "Độc Hóa Thuốc": mỗi khi quái chịu sát thương theo lượt (của bất kỳ ai), đồng minh ít máu nhất hồi 15%
## lượng sát thương đó.
## E1: hồi 20%. E2: Liều Đôi gắn Độc Quill lên 2 quái. E4: Thuốc Giải Vạn Năng cho cả đội Kháng Hiệu Ứng +20% (2 lượt).
## E6: lượng hồi vượt máu tối đa của Quill chuyển thành khiên (tối đa 20% máu tối đa người nhận).

const POISON: StatusEffectData = preload("res://data/status_effects/quill_poison.tres")
const RESIST: StatusEffectData = preload("res://data/status_effects/quill_resist.tres")
const SHIELD: StatusEffectData = preload("res://data/status_effects/shield.tres")
const RATIO: float = 0.15
const RATIO_E1: float = 0.2
const E6_SHIELD_CAP: float = 0.2


func _on_dot_damage(target: BattleUnit, amount: float, _source: BattleUnit) -> void:
	if target.is_ally() or amount <= 0.0 or not owner.is_alive():
		return
	var lowest: BattleUnit = null
	for ally in battle.get_friends(owner):
		if lowest == null or ally.get_hp_ratio() < lowest.get_hp_ratio():
			lowest = ally
	if lowest:
		var ctx := make_context()
		ctx.heal(lowest, amount * (RATIO_E1 if has_eidolon(1) else RATIO))
		report(ctx.events)


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user != owner:
		return
	if ctx.get_kind() == SkillData.Kind.SKILL and has_eidolon(2):
		var foes := battle.get_foes(owner).filter(func(e: BattleUnit) -> bool: return not e.has_status(POISON.id))
		if not foes.is_empty():
			ctx.events.append_array(give_status(POISON, foes[0], owner.stats.get_value(Stats.Type.ATK)))
	elif ctx.get_kind() == SkillData.Kind.ULTIMATE and has_eidolon(4):
		for ally in battle.get_friends(owner):
			ctx.events.append_array(give_status(RESIST, ally))


func _on_before_heal(ctx: SkillContext, target: BattleUnit, box: Dictionary) -> void:
	if not has_eidolon(6) or ctx.user != owner:
		return
	var overflow := float(box["amount"]) - (target.get_max_hp() - target.hp)
	if overflow > 0.0:
		ctx.give_shield(target, minf(overflow, target.get_max_hp() * E6_SHIELD_CAP), SHIELD)
