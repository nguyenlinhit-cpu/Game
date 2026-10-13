class_name PlaceholderSfx
extends RefCounted
## Hiệu ứng âm thanh tạm tổng hợp bằng code từ data/audio/sfx.json (Phase 14): quét tần số (f0 → f1 trong dur giây)
## hoặc chuỗi nốt (notes: số MIDI, note_dur giây mỗi nốt), sóng square / triangle / saw / noise, tắt dần.

const DATA_PATH: String = "res://data/audio/sfx.json"
const MIX_RATE: int = 22050

static var _sounds: Dictionary = {}
static var _cache: Dictionary = {}


static func sounds() -> Dictionary:
	if _sounds.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
		_sounds = parsed.get("sounds", {}) if parsed is Dictionary else {}
	return _sounds


static func has_sound(id: StringName) -> bool:
	return sounds().has(String(id))


static func get_stream(id: StringName) -> AudioStream:
	if not has_sound(id):
		return null
	if not _cache.has(id):
		_cache[id] = _render(sounds()[String(id)])
	return _cache[id]


static func _render(spec: Dictionary) -> AudioStreamWAV:
	var wave := str(spec.get("wave", "square"))
	var volume := float(spec.get("vol", 0.3))
	var segments: Array = []  # [f0, f1, giây]
	if spec.has("notes"):
		for note: Variant in spec["notes"]:
			var f := 440.0 * pow(2.0, (float(note) - 69.0) / 12.0)
			segments.append([f, f, float(spec.get("note_dur", 0.1))])
	else:
		segments.append([float(spec.get("f0", 440)), float(spec.get("f1", 440)), float(spec.get("dur", 0.1))])
	var total := 0
	for seg: Array in segments:
		total += int(float(seg[2]) * MIX_RATE)
	var data := PackedByteArray()
	data.resize(total * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var pos := 0
	var phase := 0.0
	var noise_value := 0.0
	for seg: Array in segments:
		var count := int(float(seg[2]) * MIX_RATE)
		for i in count:
			var k := float(i) / maxf(count, 1.0)
			var freq := lerpf(float(seg[0]), float(seg[1]), k)
			phase += freq / MIX_RATE
			var x := phase - floorf(phase)
			var sample := 0.0
			match wave:
				"square":
					sample = 1.0 if x < 0.5 else -1.0
				"saw":
					sample = x * 2.0 - 1.0
				"noise":
					# Nhiễu giữ mẫu theo tần số để có "cao độ".
					if x < freq / MIX_RATE:
						noise_value = rng.randf_range(-1.0, 1.0)
					sample = noise_value
				_:
					sample = 4.0 * absf(x - 0.5) - 1.0
			var envelope := minf(k * 20.0, 1.0) * (1.0 - k)
			data.encode_s16(pos * 2, int(clampf(sample * envelope * volume, -1.0, 1.0) * 32000.0))
			pos += 1
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.data = data
	return stream
