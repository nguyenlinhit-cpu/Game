class_name PlaceholderMusic
extends RefCounted
## Nhạc tạm sinh bằng code (vòng lặp vài ô nhịp sóng vuông/tam giác) cho trận thường và từng giai đoạn boss.
## Phase 14 thay bằng file nhạc thật: chỉ cần map id → AudioStream khác trong get_stream().

const MIX_RATE: int = 22050
## id → { bpm, root (MIDI), lead: [bậc, −1 = nghỉ], bass: [bậc], wave: "square"|"triangle"|"saw" }
## Mỗi phần tử lead/bass dài 1 móc đơn (nửa phách).
const TRACKS: Dictionary = {
	&"battle_normal": {"bpm": 132, "root": 57, "wave": "square",
		"lead": [0, 3, 7, 3, 10, 7, 3, -1, 0, 3, 7, 12, 10, 7, 5, -1],
		"bass": [0, 0, 0, 0, -4, -4, -4, -4, -2, -2, -2, -2, -5, -5, -5, -5]},
	&"boss_library": {"bpm": 112, "root": 50, "wave": "triangle",
		"lead": [0, 1, 5, 1, 7, 8, 7, 5, 0, 1, 5, 8, 10, 8, 7, -1],
		"bass": [0, 0, 0, 0, 1, 1, 1, 1, -2, -2, -2, -2, -5, -5, -5, -5]},
	&"boss_library_2": {"bpm": 136, "root": 50, "wave": "square",
		"lead": [12, 13, 12, 8, 7, 8, 7, 1, 0, 1, 0, -4, -5, -4, -5, -1],
		"bass": [0, 0, 1, 1, 0, 0, -2, -2, -4, -4, -5, -5, -4, -4, -2, -2]},
	&"boss_vault": {"bpm": 96, "root": 45, "wave": "triangle",
		"lead": [0, -1, 7, -1, 3, 2, 0, -1, 5, -1, 3, -1, 2, 0, -2, -1],
		"bass": [0, 0, 0, 0, 0, 0, 0, 0, -4, -4, -4, -4, -5, -5, -5, -5]},
	&"boss_vault_2": {"bpm": 150, "root": 45, "wave": "saw",
		"lead": [0, 3, 7, 10, 12, 10, 7, 3, 2, 5, 8, 12, 14, 12, 8, 5],
		"bass": [0, 0, 0, 0, -4, -4, -4, -4, -2, -2, -2, -2, -5, -5, -7, -7]},
	&"boss_furnace": {"bpm": 120, "root": 52, "wave": "square",
		"lead": [0, 0, 3, 0, 6, 0, 3, 0, 0, 0, 3, 0, 7, 6, 3, -1],
		"bass": [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, -1, -1, -1, -1]},
	&"boss_furnace_2": {"bpm": 156, "root": 52, "wave": "saw",
		"lead": [0, 6, 0, 6, 1, 7, 1, 7, 3, 9, 3, 9, 6, 12, 6, 12],
		"bass": [0, 0, 1, 1, 0, 0, 1, 1, 3, 3, 1, 1, 0, 0, -1, -1]},
	&"boss_devourer": {"bpm": 100, "root": 48, "wave": "triangle",
		"lead": [0, -1, 1, -1, 4, -1, 1, 0, 6, -1, 4, -1, 1, -1, 0, -1],
		"bass": [0, 0, 0, 0, -6, -6, -6, -6, 0, 0, 0, 0, -5, -5, -5, -5]},
	&"boss_devourer_2": {"bpm": 124, "root": 48, "wave": "square",
		"lead": [0, 6, 1, 7, 0, 6, 1, 7, 3, 9, 4, 10, 3, 9, 1, -1],
		"bass": [0, 0, 6, 6, 0, 0, 6, 6, 1, 1, 7, 7, 1, 1, 6, 6]},
	&"boss_devourer_3": {"bpm": 168, "root": 48, "wave": "saw",
		"lead": [12, 11, 12, 6, 13, 12, 13, 6, 12, 11, 12, 6, 15, 13, 12, 11],
		"bass": [0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, -1, -1, -2, -2]},
}

static var _cache: Dictionary = {}


static func has_track(id: StringName) -> bool:
	return TRACKS.has(id)


## Vòng nhạc của id (sinh một lần rồi giữ lại). null nếu không có id.
static func get_stream(id: StringName) -> AudioStream:
	if not TRACKS.has(id):
		return null
	if not _cache.has(id):
		_cache[id] = _render(TRACKS[id])
	return _cache[id]


static func _render(track: Dictionary) -> AudioStreamWAV:
	var step_samples := int(MIX_RATE * 60.0 / float(track["bpm"]) / 2.0)
	var lead: Array = track["lead"]
	var bass: Array = track["bass"]
	var steps := maxi(lead.size(), bass.size()) * 2
	var total := steps * step_samples
	var data := PackedByteArray()
	data.resize(total * 2)
	var root := int(track["root"])
	var wave := str(track["wave"])
	for step in steps:
		var lead_note := int(lead[step % lead.size()])
		var bass_note := int(bass[step % bass.size()])
		var lead_freq := _freq(root + 12 + lead_note) if lead_note >= -12 and lead_note != -1 else 0.0
		var bass_freq := _freq(root - 12 + bass_note)
		for i in step_samples:
			var t := float(step * step_samples + i) / MIX_RATE
			# Bao hình đơn giản: tắt dần trong mỗi móc đơn để nghe rõ nhịp.
			var envelope := 1.0 - float(i) / step_samples * 0.7
			var sample := 0.0
			if lead_freq > 0.0:
				sample += _osc(wave, lead_freq * t) * 0.16 * envelope
			sample += _osc("triangle", bass_freq * t) * 0.2
			data.encode_s16((step * step_samples + i) * 2, int(clampf(sample, -1.0, 1.0) * 32000.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = total
	return stream


static func _freq(midi: int) -> float:
	return 440.0 * pow(2.0, (midi - 69) / 12.0)


static func _osc(wave: String, phase: float) -> float:
	var x := phase - floorf(phase)
	match wave:
		"square":
			return 1.0 if x < 0.5 else -1.0
		"saw":
			return x * 2.0 - 1.0
	return 4.0 * absf(x - 0.5) - 1.0
