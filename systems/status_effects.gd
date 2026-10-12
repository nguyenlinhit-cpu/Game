class_name StatusEffects
extends RefCounted
## Gắn / tính lượt / gỡ hiệu ứng trạng thái trên BattleUnit. Hàm trả về danh sách sự kiện
## cùng định dạng với SkillExecutor để giao diện hiển thị.


## Tỉ lệ trúng cuối cùng (0–1).
static func hit_chance(data: StatusEffectData, source: BattleUnit, target: BattleUnit) -> float:
	if data.ignores_resistance:
		return clampf(data.base_chance, 0.0, 1.0)
	var effect_hit := source.stats.get_value(Stats.Type.EFFECT_HIT) if source else 0.0
	var effect_res := target.stats.get_value(Stats.Type.EFFECT_RES)
	return clampf(data.base_chance * (1.0 + effect_hit) * (1.0 - effect_res), 0.0, 1.0)


## Tung tỉ lệ trúng rồi gắn. Trả về hiệu ứng đã gắn, hoặc null nếu bị kháng.
static func try_apply(data: StatusEffectData, source: BattleUnit, target: BattleUnit,
		rng: RandomNumberGenerator, base_value: float = 0.0) -> StatusEffectInstance:
	if not target.is_alive():
		return null
	if rng.randf() >= hit_chance(data, source, target):
		return null
	return apply(data, source, target, base_value)


## Gắn chắc chắn (không tung tỉ lệ). Đã có thì cộng tầng (ADD) hoặc làm mới số lượt.
static func apply(data: StatusEffectData, source: BattleUnit, target: BattleUnit,
		base_value: float = 0.0) -> StatusEffectInstance:
	var instance := target.get_status(data.id)
	if instance:
		if data.stack_mode == StatusEffectData.StackMode.ADD:
			instance.stacks = mini(instance.stacks + 1, data.max_stacks)
		instance.turns_left = data.duration_turns
		instance.base_value = maxf(instance.base_value, base_value)
	else:
		instance = StatusEffectInstance.new(data, source)
		instance.base_value = base_value
		target.status_effects.append(instance)
	_apply_modifiers(target, instance)
	target.status_changed.emit(target)
	return instance


static func remove(target: BattleUnit, instance: StatusEffectInstance) -> void:
	if instance.data.shield:
		target.shield_hp = 0.0
	target.stats.remove_source(instance.uid)
	target.status_effects.erase(instance)
	target.status_changed.emit(target)


static func remove_all(target: BattleUnit) -> void:
	for instance: StatusEffectInstance in target.status_effects.duplicate():
		remove(target, instance)


## Đầu lượt người mang: sát thương theo lượt, rồi mất lượt (Đóng Băng tan).
## Trả về { "skip": bool, "events": Array[Dictionary] }.
static func tick_turn_start(target: BattleUnit) -> Dictionary:
	var events: Array[Dictionary] = []
	var skip := false
	for instance: StatusEffectInstance in target.status_effects.duplicate():
		if not target.is_alive():
			break
		var data := instance.data
		if data.heal_per_turn_ratio > 0.0:
			var healed := target.heal(target.get_max_hp() * data.heal_per_turn_ratio)
			events.append({"type": "heal", "target": target, "amount": healed, "crit": false})
		if data.dot_mode != StatusEffectData.DotMode.NONE and data.dot_multiplier > 0.0:
			var amount := target.take_damage(compute_dot(instance, target))
			events.append({"type": "dot", "target": target, "amount": amount, "crit": false,
					"element": data.dot_element, "status": data.id, "name_key": data.name_key})
		if data.skip_turn:
			skip = true
			events.append({"type": "skip", "target": target, "amount": 0.0, "crit": false, "status": data.id, "name_key": data.name_key})
			if data.on_skip_damage_multiplier > 0.0 and target.is_alive():
				var raw := instance.base_value * data.on_skip_damage_multiplier
				var amount := target.take_damage(effect_damage(raw, data.on_skip_element, instance.source_level, target))
				events.append({"type": "dot", "target": target, "amount": amount, "crit": false,
						"element": data.on_skip_element, "status": data.id, "name_key": data.name_key})
			remove(target, instance)
	return {"skip": skip, "events": events}


## Cuối lượt người mang: trừ số lượt, gỡ hiệu ứng hết hạn.
static func tick_turn_end(target: BattleUnit) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for instance: StatusEffectInstance in target.status_effects.duplicate():
		instance.turns_left -= 1
		if instance.turns_left <= 0:
			remove(target, instance)
			events.append({"type": "expired", "target": target, "amount": 0.0, "crit": false, "status": instance.data.id, "name_key": instance.data.name_key})
	if not events.is_empty() or not target.status_effects.is_empty():
		target.status_changed.emit(target)
	return events


## Kích nổ ngay mọi sát thương theo lượt trên mục tiêu với tỉ lệ `ratio` (không trừ số lượt).
static func detonate_dots(target: BattleUnit, ratio: float) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for instance: StatusEffectInstance in target.status_effects.duplicate():
		var data := instance.data
		if data.dot_mode == StatusEffectData.DotMode.NONE or data.dot_multiplier <= 0.0 or not target.is_alive():
			continue
		var amount := target.take_damage(floorf(compute_dot(instance, target) * ratio))
		events.append({"type": "dot", "target": target, "amount": amount, "crit": false,
				"element": data.dot_element, "status": data.id, "name_key": data.name_key})
	return events


## Người mang vừa trúng đòn: kích hoạt sát thương thêm (Trói Rễ) rồi gỡ nếu là loại dùng một lần.
static func on_hit(target: BattleUnit) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for instance: StatusEffectInstance in target.status_effects.duplicate():
		var data := instance.data
		if data.on_hit_damage_multiplier <= 0.0 or not target.is_alive():
			continue
		var raw := instance.base_value * data.on_hit_damage_multiplier
		var amount := target.take_damage(effect_damage(raw, data.on_hit_element, instance.source_level, target))
		events.append({"type": "dot", "target": target, "amount": amount, "crit": false,
				"element": data.on_hit_element, "status": data.id, "name_key": data.name_key})
		if data.consume_on_hit:
			remove(target, instance)
	return events


## Sát thương một lần tick của hiệu ứng (đã qua phòng thủ, kháng, dễ tổn thương).
static func compute_dot(instance: StatusEffectInstance, target: BattleUnit) -> int:
	var data := instance.data
	var raw := 0.0
	match data.dot_mode:
		StatusEffectData.DotMode.BREAK_BASE, StatusEffectData.DotMode.ATTACKER_STAT:
			raw = instance.base_value * data.dot_multiplier * instance.stacks
		StatusEffectData.DotMode.TARGET_MAX_HP:
			raw = target.get_max_hp() * data.dot_multiplier * instance.stacks
			if data.dot_cap_multiplier > 0.0:
				raw = minf(raw, instance.base_value * data.dot_cap_multiplier)
	return effect_damage(raw, data.dot_element, instance.source_level, target)


## Sát thương của hiệu ứng: không bạo kích, không tăng sát thương, vẫn qua phòng thủ/kháng/khiên.
static func effect_damage(raw: float, element: int, source_level: int, target: BattleUnit) -> int:
	var p := DamageCalc.Params.new()
	p.base_stat = raw
	p.attacker_level = source_level
	p.defender_level = target.level
	p.def_reduction = target.stats.get_value(Stats.Type.DEF_REDUCTION)
	p.res = target.get_res(element)
	p.vulnerability = target.stats.get_value(Stats.Type.VULNERABILITY)
	p.defender_has_toughness = target.has_toughness()
	p.defender_broken = target.is_broken
	return DamageCalc.compute(p, false)


static func _apply_modifiers(target: BattleUnit, instance: StatusEffectInstance) -> void:
	target.stats.remove_source(instance.uid)
	for modifier in instance.data.stat_modifiers:
		target.stats.add_modifier(modifier.stat, modifier.flat * instance.stacks,
				modifier.percent * instance.stacks, instance.uid)
