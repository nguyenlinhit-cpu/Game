class_name BuffTransferEffect
extends SkillEffect
## Sao chép (Bóng Gương) hoặc hút (Kẻ Nuốt Mảnh Hồn) buff của mục tiêu sang người dùng.
## Chỉ lấy buff chỉ số / hồi máu theo lượt (không lấy khiên, khiêu khích, bộ đếm của Đặc tính).

## true = gỡ khỏi mục tiêu (hút); false = chỉ sao chép.
@export var steal: bool = false
## Số buff tối đa lấy từ mỗi mục tiêu.
@export var count: int = 1


func apply(ctx: SkillContext) -> void:
	for entry in ctx.entries(scope):
		var target: BattleUnit = entry["unit"]
		var buffs: Array[StatusEffectInstance] = []
		for instance in target.status_effects:
			if EnemyAI.is_transferable(instance):
				buffs.append(instance)
		for i in mini(count, buffs.size()):
			var picked: StatusEffectInstance = buffs.pop_at(ctx.battle.rng.randi_range(0, buffs.size() - 1))
			var copy := StatusEffects.apply(picked.data, ctx.user, ctx.user, picked.base_value)
			copy.stacks = picked.stacks
			# Gắn trong lượt của chính mình: cộng 1 lượt để không hết ngay cuối lượt này.
			copy.turns_left = picked.data.duration_turns + 1
			StatusEffects.refresh_modifiers(ctx.user, copy)
			if steal:
				StatusEffects.remove(target, picked)
			ctx.events.append({"type": "buff_stolen" if steal else "buff_copied", "target": ctx.user, "amount": 0.0,
					"crit": false, "name_key": picked.data.name_key, "from": target})
