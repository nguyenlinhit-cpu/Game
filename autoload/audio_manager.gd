extends Node
## Bus âm thanh (Master / Music / SFX / Voice) và âm lượng; nhạc theo khu / boss (chuyển mượt bằng 2 máy phát luân
## phiên); hiệu ứng âm thanh qua pool máy phát. File thật trong assets/audio/music|sfx/<id>.(ogg|mp3|wav) được ưu tiên,
## không có thì dùng âm tổng hợp (PlaceholderMusic / PlaceholderSfx). Giọng (bus Voice) chưa có nội dung.

const BUS_NAMES: Array[String] = ["Master", "Music", "SFX", "Voice"]
const DEFAULT_VOLUME: float = 0.8


func _ready() -> void:
	_ensure_buses()
	# Mọi nút giao diện kêu "tách" khi bấm.
	get_tree().node_added.connect(func(node: Node) -> void:
		if node is BaseButton and not (node as BaseButton).pressed.is_connected(_click):
			(node as BaseButton).pressed.connect(_click))
	EventBus.character_upgraded.connect(func(_id: StringName) -> void: play_sfx(&"level_up"))
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


const MUSIC_DIR: String = "res://assets/audio/music"
const SFX_DIR: String = "res://assets/audio/sfx"
const AUDIO_EXTENSIONS: Array[String] = ["ogg", "mp3", "wav"]
const SFX_POOL_SIZE: int = 10

var _music_players: Array[AudioStreamPlayer] = []
var _music_index: int = 0
var _music_tween: Tween
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_next: int = 0
## Id bài đang phát (test đọc).
var current_music_id: StringName = &""
## Số lần phát hiệu ứng theo id (test đọc).
var sfx_counts: Dictionary = {}
var _file_cache: Dictionary = {}


func _music_player() -> AudioStreamPlayer:
	if _music_players.is_empty():
		for i in 2:
			var player := AudioStreamPlayer.new()
			player.bus = "Music"
			player.process_mode = Node.PROCESS_MODE_ALWAYS
			add_child(player)
			_music_players.append(player)
	return _music_players[_music_index]


## Phát nhạc (bus Music), chuyển chéo mờ dần sang máy phát còn lại. Cùng stream đang phát thì giữ nguyên.
func play_music(stream: AudioStream, fade_sec: float = 1.0) -> void:
	var current := _music_player()
	if stream == null or (current.stream == stream and current.playing):
		return
	if _music_tween:
		_music_tween.kill()
	_music_index = 1 - _music_index
	var next := _music_players[_music_index]
	next.stream = stream
	next.volume_db = -40.0
	next.play()
	_music_tween = create_tween().set_parallel()
	_music_tween.tween_property(next, "volume_db", 0.0, fade_sec)
	if current.playing:
		_music_tween.tween_property(current, "volume_db", -40.0, fade_sec)
		_music_tween.chain().tween_callback(current.stop)


## Phát nhạc theo id: file thật nếu có, không thì nhạc tổng hợp.
func play_music_id(id: StringName, fade_sec: float = 1.0) -> void:
	if id == &"":
		return
	var stream := _load_file(MUSIC_DIR, id)
	if stream == null:
		stream = PlaceholderMusic.get_stream(id)
	if stream:
		current_music_id = id
		play_music(stream, fade_sec)


func stop_music(fade_sec: float = 0.5) -> void:
	current_music_id = &""
	for player in _music_players:
		if player.playing:
			var tween := create_tween()
			tween.tween_property(player, "volume_db", -40.0, fade_sec)
			tween.tween_callback(player.stop)


func get_music_stream() -> AudioStream:
	var player := _music_player()
	return player.stream if player.playing else null


## Phát hiệu ứng âm thanh theo id (bus SFX) qua pool máy phát.
func play_sfx(id: StringName, pitch: float = 1.0) -> void:
	var stream := _load_file(SFX_DIR, id)
	if stream == null:
		stream = PlaceholderSfx.get_stream(id)
	if stream == null:
		return
	if _sfx_pool.is_empty():
		for i in SFX_POOL_SIZE:
			var player := AudioStreamPlayer.new()
			player.bus = "SFX"
			player.process_mode = Node.PROCESS_MODE_ALWAYS
			add_child(player)
			_sfx_pool.append(player)
	var player := _sfx_pool[_sfx_next]
	_sfx_next = (_sfx_next + 1) % SFX_POOL_SIZE
	player.stream = stream
	player.pitch_scale = pitch
	player.play()
	sfx_counts[id] = int(sfx_counts.get(id, 0)) + 1


func _click() -> void:
	play_sfx(&"ui_click")


func _load_file(dir: String, id: StringName) -> AudioStream:
	var key := dir + String(id)
	if not _file_cache.has(key):
		var stream: AudioStream = null
		for ext in AUDIO_EXTENSIONS:
			var path := dir.path_join("%s.%s" % [id, ext])
			if ResourceLoader.exists(path):
				stream = load(path) as AudioStream
				break
		_file_cache[key] = stream
	return _file_cache[key]


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
