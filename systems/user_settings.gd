class_name UserSettings
extends RefCounted
## Cài đặt theo máy (không theo ô lưu): âm lượng, ngôn ngữ... ghi ở user://settings.cfg.

const PATH: String = "user://settings.cfg"
const DEFAULT_LOCALE: String = "vi"

static var _config: ConfigFile


static func get_value(section: String, key: String, default: Variant = null) -> Variant:
	_ensure_loaded()
	return _config.get_value(section, key, default)


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
