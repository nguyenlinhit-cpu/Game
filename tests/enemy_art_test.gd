extends "res://tests/test_base.gd"
## Complete cast: variant palettes, spell effects, boss phases and live UnitViews.


func _run() -> void:
	phase_name = "Enemy art"
	timeout_sec = 600.0
	GameState.reset_new_game()
	var total := 0
	for file: String in DirAccess.get_files_at("res://data/enemies"):
		if not file.ends_with(".tres"):
			continue
		var data := load("res://data/enemies/" + file) as EnemyData
		if data == null or data.family == &"":
			continue
		total += 1
		await _check_enemy(data)
		ArtLibrary.clear_cache()
	_check(total == 33, "Đủ 33 biến thể thuộc 18 họ quái")
	var water := ArtLibrary.enemy_frames(load("res://data/enemies/rusted_knight_water.tres"), "battle")
	var lightning := ArtLibrary.enemy_frames(load("res://data/enemies/rusted_knight_lightning.tres"), "battle")
	_check(water != lightning and water.get_frame_texture("idle", 0) != lightning.get_frame_texture("idle", 0),
			"Biến thể Nước / Sét tải bộ texture riêng")
	ArtLibrary.clear_cache()
	_finish()


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
