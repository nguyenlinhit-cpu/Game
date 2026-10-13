class_name PlaceholderMusic
extends RefCounted
## Nhạc tạm sinh bằng code (vòng lặp vài ô nhịp sóng vuông/tam giác) cho trận thường và từng giai đoạn boss.
## Số liệu bài nhạc trong data/audio/music.json. File nhạc thật (assets/audio/music/<id>.*) do AudioManager ưu tiên.

const MIX_RATE: int = 22050
## id → { bpm, root (MIDI), lead: [bậc, −1 = nghỉ], bass: [bậc], wave: "square"|"triangle"|"saw" }
## Mỗi phần tử lead/bass dài 1 móc đơn (nửa phách).
## Bài nhạc: data/audio/music.json → "tracks" { id: { bpm, root (MIDI), lead: [bậc, −1 = nghỉ], bass: [bậc],
## wave: "square"|"triangle"|"saw" } }. Mỗi phần tử lead/bass dài 1 móc đơn (nửa phách).
const DATA_PATH: String = "res://data/audio/music.json"
static var _data: Dictionary = {}


static func data() -> Dictionary:
	if _data.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
		_data = parsed if parsed is Dictionary else {"tracks": {}}
	return _data


static func tracks() -> Dictionary:
	return data().get("tracks", {})


## Bài nhạc của khu (Sảnh, Thư Viện...), &"" nếu không có.
static func zone_track(zone: StringName) -> StringName:
	return StringName(str(data().get("zone_tracks", {}).get(String(zone), "")))


static var _cache: Dictionary = {}


static func has_track(id: StringName) -> bool:
	return tracks().has(String(id))


## Vòng nhạc của id (sinh một lần rồi giữ lại). null nếu không có id.
static func get_stream(id: StringName) -> AudioStream:
	if not has_track(id):
		return null
	if not _cache.has(id):
		_cache[id] = _render(tracks()[String(id)])
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
