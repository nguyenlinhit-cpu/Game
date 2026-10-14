class_name SkillVfx
extends Node2D
## Hiệu ứng kỹ năng trong trận (Phase 13). Có hoạt ảnh vẽ tay của nhân vật (assets/characters/<id>/vfx/, hoạt ảnh
## attack / skill / ultimate) thì phát hoạt ảnh đó; không có thì phát chùm hạt GPUParticles2D màu nguyên tố.
## Tự hủy khi xong.

const LIFETIME: float = 0.7
const AMOUNTS: Dictionary = {"attack": 24, "skill": 48, "ultimate": 96}

## Hoạt ảnh vẽ tay đang dùng (null = particle).
var sprite: AnimatedSprite2D
var particles: GPUParticles2D


## Tạo hiệu ứng `action` (attack / skill / ultimate) của `source` tại `at` (toạ độ trong `parent`).
static func spawn(parent: Node, at: Vector2, element: int, source: CharacterData, action: String,
		size: float = 1.0) -> SkillVfx:
	# Màn trận đã rời cây scene (đang đổi màn): bỏ qua hiệu ứng.
	if not parent.is_inside_tree():
		return null
	var vfx := SkillVfx.new()
	vfx.position = at
	parent.add_child(vfx)
	var frames := ArtLibrary.vfx_frames(source) if source else null
	if frames and frames.has_animation(action):
		vfx._play_frames(frames, action, size)
	else:
		vfx._emit(Element.color(element) if element != Element.NONE else Color(1.0, 0.95, 0.8), action, size)
	return vfx


func _play_frames(frames: SpriteFrames, action: String, size: float) -> void:
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	# Khung hit vẽ trùng khung sprite trận mục tiêu: cùng tỉ lệ với sprite trận (cao ALLY_RADIUS × 4.2).
	var frame_h := float(frames.get_frame_texture(action, 0).get_height())
	sprite.scale = Vector2.ONE * (UnitView.ALLY_RADIUS * 4.2 / frame_h if frame_h > 0.0 else 0.6) * size
	add_child(sprite)
	sprite.play(action)
	sprite.animation_finished.connect(queue_free)


## VFX quái theo id kỹ năng, ưu tiên bộ màu của biến thể.
static func spawn_enemy(parent: Node, at: Vector2, source: EnemyData, skill_id: StringName,
		size: float = 1.0) -> SkillVfx:
	if not parent.is_inside_tree():
		return null
	var vfx := SkillVfx.new()
	vfx.position = at
	parent.add_child(vfx)
	var frames := ArtLibrary.enemy_frames(source, "vfx")
	var action := ArtLibrary.enemy_skill_asset_id(skill_id)
	if frames and frames.has_animation(action):
		vfx._play_frames(frames, action, size)
	else:
		vfx._emit(Element.color(source.element), "skill", size)
	return vfx


static func spawn_enemy_screen(parent: Node, source: EnemyData, skill_id: StringName, viewport_size: Vector2) -> SkillVfx:
	var frames := ArtLibrary.enemy_frames(source, "vfx")
	var action := ArtLibrary.enemy_skill_asset_id(skill_id) + "-screen"
	if not parent.is_inside_tree() or frames == null or not frames.has_animation(action):
		return null
	var vfx := SkillVfx.new()
	vfx.position = viewport_size * 0.5
	vfx.z_index = 8
	parent.add_child(vfx)
	vfx._play_frames(frames, action, 1.0)
	var texture := frames.get_frame_texture(action, 0)
	vfx.sprite.scale = viewport_size / texture.get_size()
	return vfx


func _emit(color: Color, action: String, size: float) -> void:
	particles = GPUParticles2D.new()
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.amount = int(AMOUNTS.get(action, 24))
	particles.lifetime = LIFETIME
	var process := ParticleProcessMaterial.new()
	process.direction = Vector3(0.0, -1.0, 0.0)
	process.spread = 180.0
	process.initial_velocity_min = 120.0 * size
	process.initial_velocity_max = (360.0 if action == "ultimate" else 240.0) * size
	process.gravity = Vector3(0.0, 300.0, 0.0)
	process.damping_min = 80.0
	process.damping_max = 160.0
	process.scale_min = 4.0 * size
	process.scale_max = (12.0 if action == "ultimate" else 8.0) * size
	var ramp := Gradient.new()
	ramp.set_color(0, Color(color.lightened(0.5), 1.0))
	ramp.set_color(1, Color(color, 0.0))
	var ramp_tex := GradientTexture1D.new()
	ramp_tex.gradient = ramp
	process.color_ramp = ramp_tex
	particles.process_material = process
	add_child(particles)
	particles.emitting = true
	get_tree().create_timer(LIFETIME + 0.3, false).timeout.connect(queue_free)
