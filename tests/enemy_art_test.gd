extends "res://tests/test_base.gd"
## Complete cast: variant palettes, spell effects, boss phases and live UnitViews.


func _run() -> void:
	phase_name = "Enemy art"
	timeout_sec = 600.0
	GameState.reset_new_game()
	var total := 0
	var samples := 0
	for file: String in DirAccess.get_files_at("res://data/enemies"):
		if not file.ends_with(".tres"):
			continue
		var data := load("res://data/enemies/" + file) as EnemyData
		if data == null:
			continue
		if data.family == &"":
			samples += 1
			await _check_sample_enemy(data)
			ArtLibrary.clear_cache()
			continue
		total += 1
		await _check_enemy(data)
		ArtLibrary.clear_cache()
	_check(total == 33, "Đủ 33 biến thể thuộc 18 họ quái")
	_check(samples == 6, "Cả 6 mẫu cũ, bù nhìn và quái thử cân bằng có hình")
	_check_encounters()
	var water := ArtLibrary.enemy_frames(load("res://data/enemies/rusted_knight_water.tres"), "battle")
	var lightning := ArtLibrary.enemy_frames(load("res://data/enemies/rusted_knight_lightning.tres"), "battle")
	_check(water != lightning and water.get_frame_texture("idle", 0) != lightning.get_frame_texture("idle", 0),
			"Biến thể Nước / Sét tải bộ texture riêng")
	ArtLibrary.clear_cache()
	_finish()


func _check_sample_enemy(data: EnemyData) -> void:
	var map := ArtLibrary.enemy_frames(data, "map")
	var battle := ArtLibrary.enemy_frames(data, "battle")
	_check(map != null and map.has_animation("idle_e"), "%s: có model map" % data.id)
	_check(battle != null and battle.has_animation("attack"), "%s: có model trận" % data.id)
	if battle == null:
		return
	var texture := battle.get_frame_texture("idle", 0)
	var image := texture.get_image()
	_check(image != null and image.get_used_rect().get_area() > 64,
			"%s: texture có hình nhìn thấy, không chỉ có resource trống" % data.id)
	var unit := BattleUnit.create_enemy(data, 10, 0, 0)
	var view := UnitView.new()
	add_child(view)
	view.setup(unit, Vector2(500, 350))
	_check(view.sprite != null and view.sprite.visible and view.sprite.is_playing(),
			"%s: UnitView phát sprite thật" % data.id)
	view.play_action()
	_check(view.sprite.animation == &"attack", "%s: hoạt ảnh attack hoạt động" % data.id)
	if ArtLibrary.LEGACY_ENEMY_ASSETS.has(String(data.id)):
		for skill: SkillData in data.skills:
			if ArtLibrary.LEGACY_ENEMY_SKILLS.has(String(skill.id)):
				var meta := ArtLibrary.enemy_skill_meta(data, skill.id)
				_check(not meta.is_empty(), "%s: chiêu cũ %s nối đúng metadata" % [data.id, skill.id])
			else:
				# Tiếng Hú cũ là chiêu gây sát thương, không phải Màn Hồn tạo khiên.
				var effect := SkillVfx.spawn_enemy(self, Vector2.ZERO, data, skill.id)
				_check(effect.particles != null, "%s: chiêu cũ riêng %s giữ VFX particle" % [data.id, skill.id])
				effect.queue_free()
	view.queue_free()
	await _frames(2)


func _check_encounters() -> void:
	var missing: Array[String] = []
	for path in DataPaths.list_encounter_paths():
		var encounter := load(path) as EncounterData
		for wave: EncounterWave in encounter.waves:
			for entry: EncounterEnemyEntry in wave.entries:
				if entry.enemy and ArtLibrary.enemy_frames(entry.enemy, "battle") == null:
					missing.append("%s: %s" % [path, entry.enemy.id])
	_check(missing.is_empty(), "Mọi quái trong mọi trận đều có model: %s" % str(missing))


func _check_enemy(data: EnemyData) -> void:
	var map := ArtLibrary.enemy_frames(data, "map")
	var battle := ArtLibrary.enemy_frames(data, "battle")
	var vfx := ArtLibrary.enemy_frames(data, "vfx")
	_check(map != null and map.get_frame_count("idle_e") == 4 and map.get_frame_count("run_e") == 6
			and map.get_frame_count("windup_e") == 3, "%s: map idle/run/windup" % data.id)
	_check(battle != null and vfx != null, "%s: tải trận và VFX" % data.id)
	if battle == null or vfx == null:
		return
	var unit := BattleUnit.create_enemy(data, 10, 0, 0)
	var view := UnitView.new()
	add_child(view)
	view.setup(unit, Vector2(600, 400))
	_check(view.sprite != null and view.sprite.visible, "%s: UnitView dùng sprite thật" % data.id)
	for phase in range(data.phases.size() + 1):
		unit.phase_index = phase
		var suffix := "" if phase == 0 else "-p%d" % (phase + 1)
		for action: String in ["idle", "attack", "skill", "hit", "down"]:
			_check(battle.has_animation(action + suffix), "%s: %s" % [data.id, action + suffix])
		if phase > 0:
			view.play_phase(phase)
			_check(view.sprite.animation == StringName("phase%d" % (phase + 1)), "%s: chuyển giai đoạn %d" % [data.id, phase + 1])
			view._on_sprite_finished()
			_check(view.sprite.animation == StringName("idle" + suffix), "%s: idle đúng giai đoạn" % data.id)
	unit.phase_index = 0
	var actions: Array[EnemyAction] = data.actions.duplicate()
	for phase: BossPhaseData in data.phases:
		actions.append_array(phase.actions)
	var checked: Array[StringName] = []
	for action in actions:
		if action.skill == null or checked.has(action.skill.id):
			continue
		checked.append(action.skill.id)
		var skill := action.skill
		var meta := ArtLibrary.enemy_skill_meta(data, skill.id)
		_check(Color(str(meta.get("element_color", "#000000"))) == Element.color(data.element),
				"%s: VFX đúng màu nguyên tố %s" % [data.id, skill.id])
		_check(not meta.is_empty() and vfx.has_animation(skill.id)
				and vfx.has_animation(String(skill.id) + "-cast"), "%s: chiêu %s có VFX và timing" % [data.id, skill.id])
		view.play_action(skill.kind, skill)
		_check(view.body.get_node_or_null("CastVfx") != null, "%s: phát cast %s" % [data.id, skill.id])
		var hit := SkillVfx.spawn_enemy(self, Vector2.ZERO, data, skill.id)
		_check(hit.sprite != null and hit.sprite.animation == skill.id, "%s: phát hit %s" % [data.id, skill.id])
		hit.queue_free()
		if meta.get("screen", false):
			var screen := SkillVfx.spawn_enemy_screen(self, data, skill.id, Vector2(1920, 1080))
			_check(screen != null and screen.sprite.scale == Vector2(1.875, 1.875), "%s: VFX screen đúng tỉ lệ" % data.id)
			if screen:
				screen.queue_free()
		if action.is_charged():
			unit.charge = BattleUnit.Charge.new(action, null)
			view.play_action(skill.kind, skill, true)
			_check(view.sprite.animation == StringName(str(meta.get("prepare", "telegraph"))),
					"%s: hoạt ảnh tích tụ %s" % [data.id, skill.id])
			unit.charge = null
		await _frames(2)
	view.queue_free()
	await _frames(2)
