extends TalentScript
## Đặc tính "Thân Rễ Phản Đòn": khi bị quái đánh trúng, Garren phản công kẻ đó 50% Phòng Thủ
## (đòn phụ, không tốn lượt; tối đa 1 lần mỗi lượt của quái).
## E2: mỗi lần phản công Garren hồi 5 năng lượng. E4: Khiêu Khích của Chiến kỹ kéo dài thêm 1 lượt.
## E6: phản công 75% Phòng Thủ và trì hoãn kẻ đó 10%. (E1, E3, E5 tăng hệ số: khai báo trong EidolonData.)

const COUNTER: SkillData = preload("res://data/skills/garren_counter.tres")
const COUNTER_E6: SkillData = preload("res://data/skills/garren_counter_e6.tres")
const TAUNT_ID: StringName = &"garren_taunt"
const E2_ENERGY: float = 5.0

var _countered_turn: int = -1


func _on_after_damage(ctx: SkillContext, target: BattleUnit, _amount: float, _crit: bool) -> void:
	if target != owner or ctx.user.is_ally() or ctx.is_follow_up or not owner.is_alive():
		return
	if _countered_turn == battle.turn_count:
		return
	_countered_turn = battle.turn_count
	battle.request_follow_up(owner, COUNTER_E6 if has_eidolon(6) else COUNTER, ctx.user)
	if has_eidolon(2):
		owner.add_energy(E2_ENERGY)


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user == owner and ctx.get_kind() == SkillData.Kind.SKILL and has_eidolon(4):
		var taunt := owner.get_status(TAUNT_ID)
		if taunt:
			taunt.turns_left += 1
