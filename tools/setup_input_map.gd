extends SceneTree
## Ghi Input Map chuẩn của game vào project.godot.
## Chạy lại khi muốn khôi phục phím mặc định:
##   godot --headless --path . --script res://tools/setup_input_map.gd

const MOVE_DEADZONE: float = 0.2
const BUTTON_DEADZONE: float = 0.5


func _init() -> void:
	var actions: Dictionary = {
		"move_left": [_key(KEY_A), _key(KEY_LEFT), _axis(JOY_AXIS_LEFT_X, -1.0)],
		"move_right": [_key(KEY_D), _key(KEY_RIGHT), _axis(JOY_AXIS_LEFT_X, 1.0)],
		"move_up": [_key(KEY_W), _key(KEY_UP), _axis(JOY_AXIS_LEFT_Y, -1.0)],
		"move_down": [_key(KEY_S), _key(KEY_DOWN), _axis(JOY_AXIS_LEFT_Y, 1.0)],
		"dash": [_key(KEY_SPACE), _key(KEY_SHIFT), _joy(JOY_BUTTON_B)],
		"opener_attack": [_key(KEY_J), _mouse(MOUSE_BUTTON_LEFT), _joy(JOY_BUTTON_X)],
		"technique": [_key(KEY_K), _key(KEY_E), _joy(JOY_BUTTON_Y)],
		"switch_character_1": [_key(KEY_1), _joy(JOY_BUTTON_DPAD_UP)],
		"switch_character_2": [_key(KEY_2), _joy(JOY_BUTTON_DPAD_RIGHT)],
		"switch_character_3": [_key(KEY_3), _joy(JOY_BUTTON_DPAD_DOWN)],
		"switch_character_4": [_key(KEY_4), _joy(JOY_BUTTON_DPAD_LEFT)],
		"interact": [_key(KEY_F), _joy(JOY_BUTTON_A)],
		"menu": [_key(KEY_ESCAPE), _joy(JOY_BUTTON_START)],
		# Chỉ có tác dụng ở bản debug.
		"debug_clear_enemies": [_key(KEY_F8)],
		"debug_team_level_down": [_key(KEY_F6)],
		"debug_team_level_up": [_key(KEY_F7)],
	}
	for action_name: String in actions:
		for event: InputEvent in actions[action_name]:
			# -1 = mọi thiết bị (tay cầm nào cũng nhận), giống Input Map trong editor.
			event.device = -1
		var deadzone := MOVE_DEADZONE if action_name.begins_with("move_") else BUTTON_DEADZONE
		ProjectSettings.set_setting("input/" + action_name, {
			"deadzone": deadzone,
			"events": actions[action_name],
		})
	var err := ProjectSettings.save()
	print("Input map: ghi %d action, kết quả %s" % [actions.size(), error_string(err)])
	quit(0 if err == OK else 1)


func _key(physical: Key) -> InputEventKey:
	var event := InputEventKey.new()
	# Dùng phím vật lý để WASD đúng vị trí trên mọi kiểu bàn phím.
	event.physical_keycode = physical
	return event


func _mouse(button: MouseButton) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	return event


func _joy(button: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	return event


func _axis(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	return event
