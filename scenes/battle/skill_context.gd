class_name SkillContext
extends RefCounted
## Bối cảnh khi chạy một kỹ năng (hoặc đòn phụ của Đặc tính): ai dùng, mục tiêu, sự kiện sinh ra.
## Các SkillEffect và TalentScript gọi deal_damage()/heal()/give_shield() để mọi thứ đi qua
## cùng một đường (móc before_damage/after_damage, khiên, Phá Vỡ, sự kiện cho giao diện).

var battle: BattleController
var user: BattleUnit
## null khi là sát thương/hồi máu do Đặc tính tạo trực tiếp.
var skill: SkillData
var main_target: BattleUnit
## [{ "unit": BattleUnit, "main": bool }]
var targets: Array[Dictionary] = []
var events: Array[Dictionary] = []
var element: int = Element.NONE
## Đòn đánh phụ / phản công (không tốn lượt).
var is_follow_up: bool = false
## Chỗ để TalentScript ghi dấu trong một hành động (vd. đã tiêu thêm Điểm Chiến Kỹ, đã nổ lan).
var custom: Dictionary = {}


func _init(p_battle: BattleController, p_user: BattleUnit, p_skill: SkillData, p_main: BattleUnit) -> void:
	battle = p_battle
	user = p_user
	skill = p_skill
	main_target = p_main
	element = battle.get_attack_element(user)
	if skill:
		targets = SkillExecutor.resolve_targets(skill, user, main_target, battle.allies, battle.enemies)
		if not targets.is_empty():
			main_target = targets[0]["unit"]


func get_kind() -> int:
	return skill.kind if skill else -1


## Hệ số nhân thêm cho kỹ năng này: Tinh Mệnh tăng hệ số theo loại × cấp kỹ năng
## (sát thương/hồi máu/khiên do Đặc tính tạo trực tiếp và đòn phụ dùng cấp Đặc tính).
func get_multiplier_scale() -> float:
	return (1.0 + user.get_skill_multiplier_bonus(get_kind())) * user.get_level_multiplier(get_kind())


## Độ mạnh buff/debuff gắn bởi kỹ năng này (theo cấp kỹ năng).
func get_status_potency() -> float:
	return user.get_status_potency(get_kind())


func entries(scope: SkillEffect.Scope) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	match scope:
		SkillEffect.Scope.TARGETS:
			result = targets.duplicate()
		SkillEffect.Scope.MAIN:
			result = targets.filter(func(e: Dictionary) -> bool: return e["main"])
		SkillEffect.Scope.ADJACENT:
			result = targets.filter(func(e: Dictionary) -> bool: return not e["main"])
		SkillEffect.Scope.SELF:
			result = [{"unit": user, "main": true}]
		SkillEffect.Scope.ALL_ALLIES, SkillEffect.Scope.ALLIES_EXCEPT_SELF:
			for unit in battle.get_friends(user):
				if scope == SkillEffect.Scope.ALL_ALLIES or unit != user:
					result.append({"unit": unit, "main": true})
		SkillEffect.Scope.ALL_ENEMIES:
			for unit in battle.get_foes(user):
				result.append({"unit": unit, "main": true})
		SkillEffect.Scope.FIRST_ENEMY:
			var foes := battle.get_foes(user)
			if not foes.is_empty():
				result.append({"unit": foes[0], "main": true})
		SkillEffect.Scope.RANDOM_ENEMY:
			var foes := battle.get_foes(user)
			if not foes.is_empty():
				result.append({"unit": foes[battle.rng.randi_range(0, foes.size() - 1)], "main": true})
	return result


## Gây sát thương đầy đủ: móc Đặc tính, bạo kích, khiên chặn, năng lượng khi bị đánh,
## kích hoạt khi bị đánh (Trói Rễ), giảm Khiên Điểm Yếu / Phá Vỡ. Trả về máu thực mất.
func deal_damage(target: BattleUnit, scaling_stat: Stats.Type, multiplier: float, toughness: float = 0.0) -> float:
	if target == null or not target.is_alive() or multiplier <= 0.0:
		return 0.0
	# Sát thương tính theo trạng thái khiên TRƯỚC đòn này (đòn phá vỡ vẫn chịu hệ số 0,9).
	var params := SkillExecutor.build_damage_params(user, target, scaling_stat,
			multiplier * get_multiplier_scale(), element)
	battle.before_damage.emit(self, target, params)
	var result := DamageCalc.roll(params, battle.rng, battle.crit_mode)
	# Móc đổi người nhận / chia sát thương (Marisol, Aldric).
	var box := {"amount": float(result["amount"]), "target": target, "crit": result["crit"]}
	battle.before_hit.emit(self, target, box)
	target = box["target"]
	var outcome := target.take_hit(box["amount"])
	events.append({"type": "damage", "target": target, "amount": outcome["hp_lost"], "crit": result["crit"],
			"element": element, "absorbed": outcome["absorbed"], "source": user})
	EventBus.damage_dealt.emit(user, target, int(outcome["hp_lost"]), result["crit"])
	target.add_energy(BattleUnit.ENERGY_ON_HIT)
	events.append_array(StatusEffects.on_hit(target))
	events.append_array(BreakSystem.apply_toughness_damage(battle, user, target, element, toughness))
	battle.after_damage.emit(self, target, outcome["hp_lost"], result["crit"])
	return outcome["hp_lost"]


## Hồi máu (đã cộng Tăng Trị Liệu của người hồi). Trả về lượng thực hồi.
func heal(target: BattleUnit, raw_amount: float) -> float:
	if target == null or not target.is_alive():
		return 0.0
	var amount := raw_amount * (1.0 + user.stats.get_value(Stats.Type.OUTGOING_HEALING))
	var box := {"amount": amount}
	battle.before_heal.emit(self, target, box)
	var healed := target.heal(box["amount"])
	events.append({"type": "heal", "target": target, "amount": healed, "crit": false, "raw": box["amount"],
			"source": user})
	return healed


func give_shield(target: BattleUnit, amount: float, status: StatusEffectData) -> void:
	if target == null or not target.is_alive() or status == null:
		return
	StatusEffects.apply(status, user, target)
	target.add_shield(amount)
	events.append({"type": "shield", "target": target, "amount": amount, "crit": false, "source": user})
