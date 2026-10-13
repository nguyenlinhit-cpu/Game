class_name UserSettings
extends RefCounted
## Cài đặt theo máy (không theo ô lưu): âm lượng, ngôn ngữ, cửa sổ, tốc độ chữ, phím... ghi ở user://settings.cfg.

const PATH: String = "user://settings.cfg"
const DEFAULT_LOCALE: String = "vi"

static var _config: ConfigFile


static func get_value(section: String, key: String, default: Variant = null) -> Variant:
	_ensure_loaded()
	return _config.get_value(section, key, default)


static func has_value(section: String, key: String) -> bool:
	_ensure_loaded()
	return _config.has_section_key(section, key)


static func set_value(section: String, key: String, value: Variant) -> void:
	_ensure_loaded()
	_config.set_value(section, key, value)


static func save() -> void:
	_ensure_loaded()
	var err := _config.save(PATH)
	if err != OK:
		push_warning("UserSettings: không ghi được %s (lỗi %d)" % [PATH, err])


static func get_locale() -> String:
	return str(get_value("general", "locale", DEFAULT_LOCALE))


static func _ensure_loaded() -> void:
	if _config != null:
		return
	_config = ConfigFile.new()
	var err := _config.load(PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_warning("UserSettings: file cài đặt hỏng (lỗi %d), dùng mặc định" % err)


## Đã bật điều khiển cảm ứng trong Cài đặt (để thử trên PC).
static func is_touch_controls_forced() -> bool:
	return bool(get_value("controls", "touch_enabled", false))


static func set_touch_controls_forced(enabled: bool) -> void:
	set_value("controls", "touch_enabled", enabled)


## Điện thoại/máy tính bảng luôn hiện; PC hiện khi người chơi bật.
## Không dùng DisplayServer.is_touchscreen_available(): nó luôn true khi bật emulate_touch_from_mouse.
static func should_show_touch_controls() -> bool:
	return OS.has_feature("mobile") or is_touch_controls_forced()


# --- Hiển thị, chữ, phím (Phase 14) ---

const RESOLUTIONS: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440)]
## Tốc độ chữ chạy (lời dẫn, hội thoại): hệ số nhân. "instant" = hiện ngay.
const TEXT_SPEEDS: Dictionary = {"slow": 0.6, "normal": 1.0, "fast": 1.6, "instant": 100.0}
const LOCALES: Array[String] = ["vi", "en"]
## Hành động gán lại được phím (phím đầu tiên của mỗi hành động; tay cầm giữ nguyên).
const REBINDABLE: Array[String] = ["move_up", "move_down", "move_left", "move_right", "dash", "opener_attack", "technique",
	"interact", "menu", "switch_character_1", "switch_character_2", "switch_character_3", "switch_character_4",
	"battle_basic", "battle_skill"]

static var _default_keys: Dictionary = {}


static func set_locale(locale: String) -> void:
	set_value("general", "locale", locale)
	TranslationServer.set_locale(locale)


static func get_text_speed_id() -> String:
	var id := str(get_value("general", "text_speed", "normal"))
	return id if TEXT_SPEEDS.has(id) else "normal"


static func text_speed() -> float:
	return float(TEXT_SPEEDS[get_text_speed_id()])


static func is_fullscreen() -> bool:
	return bool(get_value("display", "fullscreen", false))


static func get_resolution() -> Vector2i:
	var value: Variant = get_value("display", "resolution", Vector2i(1920, 1080))
	return value if value is Vector2i else Vector2i(1920, 1080)


## Áp cài đặt theo máy khi khởi động: ngôn ngữ, cửa sổ, phím.
static func apply_all() -> void:
	TranslationServer.set_locale(get_locale())
	apply_display()
	apply_keys()


static func apply_display() -> void:
	if DisplayServer.get_name() == "headless" or OS.has_feature("mobile"):
		return
	if is_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		if not has_value("display", "resolution"):
			return
		var size := get_resolution()
		var screen := DisplayServer.screen_get_size()
		if screen.x > 0:
			size = size.min(screen)
		DisplayServer.window_set_size(size)
		DisplayServer.window_set_position((screen - size) / 2)


## Phím bàn phím hiện tại của hành động (physical keycode), 0 nếu không có.
static func get_key(action: String) -> int:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var key := event as InputEventKey
			return key.physical_keycode if key.physical_keycode != 0 else key.keycode
	return 0


static func key_name(action: String) -> String:
	var code := get_key(action)
	return OS.get_keycode_string(code) if code != 0 else "—"


## Gán phím mới cho hành động: thay mọi phím bàn phím của hành động bằng phím này (tay cầm giữ nguyên);
## phím đó đang dùng ở hành động khác thì gỡ ở đó.
static func set_key(action: String, physical_keycode: int, save_now: bool = true) -> void:
	_capture_defaults()
	for other in REBINDABLE:
		if other != action and _has_key(other, physical_keycode):
			_set_keys(other, [])
			set_value("keys", other, 0)
	_set_keys(action, [physical_keycode])
	set_value("keys", action, physical_keycode)
	if save_now:
		save()


static func reset_keys() -> void:
	_capture_defaults()
	for action in REBINDABLE:
		_set_keys(action, _default_keys.get(action, []))
	_ensure_loaded()
	if _config.has_section("keys"):
		_config.erase_section("keys")
	save()


static func apply_keys() -> void:
	_capture_defaults()
	for action in REBINDABLE:
		if has_value("keys", action):
			var code := int(get_value("keys", action, 0))
			_set_keys(action, [code] if code != 0 else [])


## Phím mặc định (mọi phím bàn phím) của từng hành động, lấy một lần trước khi áp phím người chơi gán.
static func _capture_defaults() -> void:
	if not _default_keys.is_empty():
		return
	for action in REBINDABLE:
		if not InputMap.has_action(action):
			continue
		var codes: Array = []
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				var key := event as InputEventKey
				codes.append(key.physical_keycode if key.physical_keycode != 0 else key.keycode)
		_default_keys[action] = codes


static func _has_key(action: String, code: int) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var key := event as InputEventKey
			if (key.physical_keycode if key.physical_keycode != 0 else key.keycode) == code:
				return true
	return false


static func _set_keys(action: String, codes: Array) -> void:
	if not InputMap.has_action(action):
		return
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			InputMap.action_erase_event(action, event)
	for code: Variant in codes:
		if int(code) != 0:
			var key := InputEventKey.new()
			key.physical_keycode = int(code) as Key
			InputMap.action_add_event(action, key)
