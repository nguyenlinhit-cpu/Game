extends TalentScript
## Đặc tính "Vang Vọng": mỗi khi đồng minh khác gắn hiệu ứng xấu lên quái, Echo gắn bản sao hiệu ứng đó lên 1 quái
## ngẫu nhiên khác (tối đa 1 lần mỗi lượt của đồng minh đó). Tuyệt kỹ: mỗi quái nhận lại 1 hiệu ứng xấu đang có ở quái khác.
## E1: Rạn Hồn kéo dài 3 lượt. E2: tối đa 2 lần mỗi lượt. E4: bản sao kéo dài thêm 1 lượt.
## E6: Vang Vọng cũng sao chép hiệu ứng xấu Echo tự gắn.

const CRACK_ID: StringName = &"echo_crack"

var _copying: bool = false
## { "<source id>:<turn>": số lần đã sao chép }
var _counts: Dictionary = {}


func _on_status_applied(source: BattleUnit, target: BattleUnit, instance: StatusEffectInstance) -> void:
	if _copying or source == null or not source.is_ally() or target.is_ally():
		return
	if has_eidolon(1) and source == owner and instance.data.id == CRACK_ID:
		instance.turns_left = instance.data.duration_turns + 1
	if instance.data.kind != StatusEffectData.Kind.DEBUFF or (source == owner and not has_eidolon(6)):
		return
	var key := "%s:%d" % [source.id, battle.turn_count]
	if int(_counts.get(key, 0)) >= (2 if has_eidolon(2) else 1):
		return
	var others := battle.get_foes(owner).filter(func(e: BattleUnit) -> bool:
		return e != target and not e.has_status(instance.data.id))
	if others.is_empty():
		return
	_counts[key] = int(_counts.get(key, 0)) + 1
	_copy(instance, others[battle.rng.randi_range(0, others.size() - 1)])


func _copy(instance: StatusEffectInstance, target: BattleUnit) -> void:
	_copying = true
	var copy := StatusEffects.apply(instance.data, instance.source if instance.source else owner, target, instance.base_value)
	copy.turns_left = instance.data.duration_turns + (1 if has_eidolon(4) else 0)
	_copying = false
	report([{"type": "status_applied", "target": target, "amount": 1.0, "crit": false, "status": instance.data.id,
			"name_key": instance.data.name_key}])


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user != owner or ctx.get_kind() != SkillData.Kind.ULTIMATE:
		return
	var foes := battle.get_foes(owner)
	for enemy in foes:
		for other in foes:
			if other == enemy:
				continue
			var picked: StatusEffectInstance = null
			for candidate in other.status_effects:
				if candidate.data.kind == StatusEffectData.Kind.DEBUFF and not enemy.has_status(candidate.data.id):
					picked = candidate
					break
			if picked:
				_copy(picked, enemy)
				break
