extends TalentScript
## Đặc tính "Lao Tới Che": một lần mỗi lượt quái, đồng minh khác sắp nhận đòn từ 25% máu tối đa của họ trở lên
## thì Aldric nhận đòn thay (giảm 20%).
## E1: ngưỡng 20%. E2: đòn đỡ thay giảm 35%. E4: đỡ thay xong được kéo lượt 15%. E6: đỡ thay tối đa 2 lần mỗi lượt quái.

const THRESHOLD: float = 0.25
const THRESHOLD_E1: float = 0.2
const REDUCTION: float = 0.2
const REDUCTION_E2: float = 0.35
const E4_ADVANCE: float = 0.15

var _turn: int = -1
var _uses: int = 0


func _on_before_hit(ctx: SkillContext, _target: BattleUnit, box: Dictionary) -> void:
	var target: BattleUnit = box["target"]
	if ctx.user.is_ally() or not target.is_ally() or target == owner or target.is_summon or not owner.is_alive():
		return
	var amount := float(box["amount"])
	if amount < target.get_max_hp() * (THRESHOLD_E1 if has_eidolon(1) else THRESHOLD):
		return
	if _turn != battle.turn_count:
		_turn = battle.turn_count
		_uses = 0
	if _uses >= (2 if has_eidolon(6) else 1):
		return
	_uses += 1
	box["target"] = owner
	box["amount"] = amount * (1.0 - (REDUCTION_E2 if has_eidolon(2) else REDUCTION))
	ctx.events.append({"type": "intercept", "target": owner, "amount": float(box["amount"]), "crit": false, "source": owner})
	if has_eidolon(4) and battle.queue.has(owner):
		battle.queue.action_advance(owner, E4_ADVANCE)
		ctx.events.append({"type": "advance", "target": owner, "amount": E4_ADVANCE, "crit": false})
