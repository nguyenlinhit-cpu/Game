extends TalentScript
## Đặc tính "Nhịp Lễ Hội": mỗi khi một đồng minh đang có "Thổi Bùng" dùng Chiến kỹ, Kiri nhận 1 tầng Nhịp Lễ Hội;
## đủ 3 tầng thì cả đội +1 Điểm Chiến Kỹ và xóa tầng.
## E1: Thổi Bùng tăng Tấn Công 30% (thay 20%). E2: chỉ cần 2 tầng. E4: vào trận +1 Điểm Chiến Kỹ.
## E6: Thổi Bùng thêm +10% Tốc Độ. (E3, E5 tăng hệ số: khai báo trong EidolonData.)

const KINDLE: StatusEffectData = preload("res://data/status_effects/kiri_kindle.tres")
const KINDLE_E1: StatusEffectData = preload("res://data/status_effects/kiri_kindle_e1.tres")
const KINDLE_E6: StatusEffectData = preload("res://data/status_effects/kiri_kindle_e6.tres")
const RHYTHM: StatusEffectData = preload("res://data/status_effects/kiri_rhythm.tres")
const KINDLE_IDS: Array[StringName] = [&"kiri_kindle", &"kiri_kindle_e1", &"kiri_kindle_e6"]


func get_required_stacks() -> int:
	return 2 if has_eidolon(2) else 3


func _on_battle_start() -> void:
	if has_eidolon(4):
		battle.change_skill_points(1)
		report([{"type": "skill_point", "target": owner, "amount": 1.0, "crit": false}])


func _on_skill_resolved(ctx: SkillContext) -> void:
	if ctx.user == owner and ctx.get_kind() == SkillData.Kind.SKILL and has_eidolon(1):
		_upgrade_kindle(ctx)
	if ctx.user != owner and ctx.user.is_ally() and ctx.get_kind() == SkillData.Kind.SKILL and _has_kindle(ctx.user):
		var rhythm := StatusEffects.apply(RHYTHM, owner, owner)
		if rhythm.stacks >= get_required_stacks():
			StatusEffects.remove(owner, rhythm)
			battle.change_skill_points(1)
			ctx.events.append({"type": "skill_point", "target": owner, "amount": 1.0, "crit": false})


func _has_kindle(unit: BattleUnit) -> bool:
	for id in KINDLE_IDS:
		if unit.has_status(id):
			return true
	return false


## Tinh Mệnh 1/6: thay Thổi Bùng thường bằng bản mạnh hơn.
func _upgrade_kindle(ctx: SkillContext) -> void:
	for entry in ctx.targets:
		var target: BattleUnit = entry["unit"]
		var basic := target.get_status(KINDLE.id)
		if basic:
			StatusEffects.remove(target, basic)
			StatusEffects.apply(KINDLE_E6 if has_eidolon(6) else KINDLE_E1, owner, target)
