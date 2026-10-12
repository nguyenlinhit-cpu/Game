extends TalentScript
## Đặc tính "Đồng Điệu": mỗi cặp đồng minh cùng nguyên tố trong đội cho cả đội Tăng sát thương +8% (tối đa 3 cặp);
## đồng minh cùng nguyên tố với mục tiêu Hương Dũng Khí nhận thêm 10% Tấn Công.
## Số cặp = Σ (số người cùng nguyên tố − 1) theo từng nguyên tố.
## E1: Hương Dũng Khí kéo dài 3 lượt. E2: Selka tính thêm 1 cặp nếu có đồng minh cùng vận mệnh.
## E4: Hương Dũng Khí kéo lượt mục tiêu 15%. E6: mỗi cặp +10%.

const HARMONY: StatusEffectData = preload("res://data/status_effects/selka_harmony.tres")
const HARMONY_E6: StatusEffectData = preload("res://data/status_effects/selka_harmony_e6.tres")
const RESONANCE: StatusEffectData = preload("res://data/status_effects/selka_resonance.tres")
const COURAGE_ID: StringName = &"selka_courage"
const MAX_PAIRS: int = 3
const E4_ADVANCE: float = 0.15


func count_pairs() -> int:
	var by_element: Dictionary = {}
	for ally in battle.allies:
		by_element[ally.element] = int(by_element.get(ally.element, 0)) + 1
	var pairs := 0
	for element: int in by_element:
		pairs += maxi(int(by_element[element]) - 1, 0)
	if has_eidolon(2):
		for ally in battle.allies:
			if ally != owner and ally.character.path == owner.character.path:
				pairs += 1
				break
	return mini(pairs, MAX_PAIRS)


func _on_battle_start() -> void:
	var pairs := count_pairs()
	if pairs <= 0:
		return
	var data := HARMONY_E6 if has_eidolon(6) else HARMONY
	for ally in battle.allies:
		for i in pairs:
			StatusEffects.apply(data, owner, ally)


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user != owner or ctx.get_kind() != SkillData.Kind.SKILL or ctx.main_target == null:
		return
	var target := ctx.main_target
	if has_eidolon(1):
		var courage := target.get_status(COURAGE_ID)
		if courage:
			courage.turns_left += 1
	if has_eidolon(4) and battle.queue.has(target):
		battle.queue.action_advance(target, E4_ADVANCE)
		ctx.events.append({"type": "advance", "target": target, "amount": E4_ADVANCE, "crit": false})
	for ally in battle.get_friends(owner):
		if ally != target and ally.element == target.element:
			ctx.events.append_array(give_status(RESONANCE, ally))
