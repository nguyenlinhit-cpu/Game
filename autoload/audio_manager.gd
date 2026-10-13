extends Node
## Bus âm thanh và âm lượng. Phát nhạc theo khu/boss, hiệu ứng, giọng làm ở Phase 14.

const BUS_NAMES: Array[String] = ["Master", "Music", "SFX", "Voice"]
const DEFAULT_VOLUME: float = 0.8


func _ready() -> void:
	_ensure_buses()
	for bus_name in BUS_NAMES:
		_apply_volume(bus_name, get_volume(bus_name))


## Âm lượng tuyến tính 0–1.
func get_volume(bus_name: String) -> float:
	return clampf(float(UserSettings.get_value("audio", bus_name, DEFAULT_VOLUME)), 0.0, 1.0)


func set_volume(bus_name: String, linear: float) -> void:
	linear = clampf(linear, 0.0, 1.0)
	UserSettings.set_value("audio", bus_name, linear)
	_apply_volume(bus_name, linear)


func save_settings() -> void:
	UserSettings.save()


var _music_player: AudioStreamPlayer
var _music_tween: Tween


## Phát nhạc (bus Music), mờ dần nhạc cũ. Cùng stream đang phát thì giữ nguyên.
## TODO Phase 14: 2 AudioStreamPlayer luân phiên để chuyển nhạc mượt hơn.
func play_music(stream: AudioStream, fade_sec: float = 1.0) -> void:
	if _music_player == null:
		_music_player = AudioStreamPlayer.new()
		_music_player.bus = "Music"
		add_child(_music_player)
	if stream == null or (_music_player.stream == stream and _music_player.playing):
		return
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	if _music_player.playing:
		_music_tween.tween_property(_music_player, "volume_db", -40.0, fade_sec * 0.5)
	_music_tween.tween_callback(func() -> void:
		_music_player.stream = stream
		_music_player.volume_db = -40.0
		_music_player.play())
	_music_tween.tween_property(_music_player, "volume_db", 0.0, fade_sec * 0.5)


func stop_music(fade_sec: float = 0.5) -> void:
	if _music_player == null or not _music_player.playing:
		return
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_music_player, "volume_db", -40.0, fade_sec)
	_music_tween.tween_callback(_music_player.stop)


func get_music_stream() -> AudioStream:
	return _music_player.stream if _music_player and _music_player.playing else null


func play_sfx(_stream: AudioStream) -> void:
	# TODO Phase 14: pool AudioStreamPlayer cho hiệu ứng.
	pass


func _apply_volume(bus_name: String, linear: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index == -1:
		return
	AudioServer.set_bus_mute(index, linear <= 0.001)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))


## Tạo bus còn thiếu để chưa cần file default_bus_layout.tres.
func _ensure_buses() -> void:
	for bus_name in BUS_NAMES:
		if AudioServer.get_bus_index(bus_name) != -1:
			continue
		AudioServer.add_bus()
		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, bus_name)
		AudioServer.set_bus_send(index, "Master")
