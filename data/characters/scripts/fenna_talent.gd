extends TalentScript
## Đặc tính "Mũi Tên Thứ Hai": Đánh thường lên quái đang Phá Vỡ thì bắn thêm 1 mũi tên 60% Tấn Công (đòn phụ).
## Tuyệt kỹ lên quái đang Phá Vỡ: +30% Sát thương bạo kích.
## E1: bắn 2 mũi. E2: đòn phụ +20% Tỉ Lệ Bạo Kích. E4: hạ quái thì +1 Điểm Chiến Kỹ (1 lần mỗi lượt).
## E6: Chiến kỹ cũng kích hoạt Mũi Tên Thứ Hai.

const ARROW: SkillData = preload("res://data/skills/fenna_arrow.tres")
const ULT_CRIT_DMG: float = 0.3
const E2_CRIT_RATE: float = 0.2

var _sp_turn: int = -1


func _triggers_arrow(ctx: SkillContext) -> bool:
	return ctx.get_kind() == SkillData.Kind.BASIC or (has_eidolon(6) and ctx.get_kind() == SkillData.Kind.SKILL)


func _on_after_damage(ctx: SkillContext, target: BattleUnit, _amount: float, _crit: bool) -> void:
	if ctx.user != owner:
		return
	if not target.is_alive():
		if has_eidolon(4) and _sp_turn != battle.turn_count:
			_sp_turn = battle.turn_count
			battle.change_skill_points(1)
			ctx.events.append({"type": "skill_point", "target": owner, "amount": 1.0, "crit": false})
		return
	if not ctx.is_follow_up and _triggers_arrow(ctx) and target.is_broken:
		for i in (2 if has_eidolon(1) else 1):
			battle.request_follow_up(owner, ARROW, target)


func _on_before_damage(ctx: SkillContext, target: BattleUnit, params: DamageCalc.Params) -> void:
	if ctx.user != owner:
		return
	if ctx.is_follow_up and has_eidolon(2):
		params.crit_rate += E2_CRIT_RATE
	if ctx.get_kind() == SkillData.Kind.ULTIMATE and target.is_broken:
		params.crit_dmg += ULT_CRIT_DMG
