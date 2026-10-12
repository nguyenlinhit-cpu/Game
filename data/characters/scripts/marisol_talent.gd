extends TalentScript
## Đặc tính "Thủy Triều Chia Sẻ": khi Marisol còn trên 40% máu, 25% sát thương quái gây cho đồng minh khác
## được chuyển sang Marisol (phần chuyển vẫn bị khiên của Marisol chặn).
## E1: chia 35%. E2: phần chia sẻ giảm 30%. E4: một lần mỗi trận, đòn chí mạng chí tử chỉ để lại 1 máu và hồi 30%.
## E6: mỗi lần chia sẻ gây 30% Phòng Thủ sát thương Nước lên kẻ tấn công.

const HP_THRESHOLD: float = 0.4
const SHARE: float = 0.25
const SHARE_E1: float = 0.35
const E2_REDUCTION: float = 0.3
const E4_HEAL: float = 0.3
const E6_MULTIPLIER: float = 0.3


func _on_before_hit(ctx: SkillContext, _target: BattleUnit, box: Dictionary) -> void:
	var target: BattleUnit = box["target"]
	if ctx.user.is_ally() or not target.is_ally():
		return
	if target == owner:
		_last_stand(ctx, box)
		return
	if not owner.is_alive() or owner.get_hp_ratio() <= HP_THRESHOLD or target.is_summon:
		return
	var shared := float(box["amount"]) * (SHARE_E1 if has_eidolon(1) else SHARE)
	box["amount"] = float(box["amount"]) - shared
	var taken := shared * ((1.0 - E2_REDUCTION) if has_eidolon(2) else 1.0)
	var outcome := owner.take_hit(taken)
	ctx.events.append({"type": "damage", "target": owner, "amount": outcome["hp_lost"], "crit": false,
			"absorbed": outcome["absorbed"], "shared": true, "protector": owner, "protected": taken})
	if has_eidolon(6) and ctx.user.is_alive():
		var counter := make_context()
		counter.deal_damage(ctx.user, Stats.Type.DEF, E6_MULTIPLIER)
		ctx.events.append_array(counter.events)


var _e4_pending: bool = false


func _last_stand(_ctx: SkillContext, box: Dictionary) -> void:
	if not has_eidolon(4) or not bool(box.get("crit", false)):
		return
	if float(box["amount"]) < owner.hp + owner.shield_hp:
		return
	if not battle.try_use("marisol_e4_%s" % owner.id, 1):
		return
	box["amount"] = owner.hp + owner.shield_hp - 1.0
	_e4_pending = true


func _on_after_damage(ctx: SkillContext, target: BattleUnit, _amount: float, _crit: bool) -> void:
	if _e4_pending and target == owner and owner.is_alive():
		_e4_pending = false
		ctx.heal(owner, owner.get_max_hp() * E4_HEAL)
