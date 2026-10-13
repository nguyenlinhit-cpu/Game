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
	sprite.scale = Vector2.ONE * 0.6 * size
	add_child(sprite)
	sprite.play(action)
	sprite.animation_finished.connect(queue_free)


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
