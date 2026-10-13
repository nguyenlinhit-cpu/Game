class_name RestPoint
extends Interactable
## Điểm nghỉ trong phòng nghỉ: hồi đầy máu cả đội (kể cả người đã ngã) và Điểm Bí Kỹ, mở phòng nghỉ này cho
## dịch chuyển nhanh, tự lưu, rồi mở bảng dịch chuyển nhanh (OverworldMap.open_travel_menu).

const CRYSTAL_COLOR := Color("f2d58a")

@export var rest_point_id: StringName

var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _on_interact(_by: Node) -> void:
	GameState.change_technique_points(GameState.MAX_TECHNIQUE_POINTS)
	GameState.heal_team(1.0)
	var map := get_tree().current_scene as OverworldMap
	var room := Room.find_room_of(self)
	if map and room:
		GameState.unlock_fast_travel(map.zone_of(room), room.room_id)
		GameState.set_map_player(map.scene_file_path, map.player.global_position, map.player.facing)
	SaveManager.save_game()
	AudioManager.play_sfx(&"rest")
	EventBus.toast_requested.emit(tr("TOAST_RESTED"))
	# Map thử (không thuộc pháo đài) không có nơi để dịch chuyển.
	if map and StoryManager.get_scene_zone(map.scene_file_path) != &"":
		map.open_travel_menu()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_time * 2.5)
	draw_circle(Vector2.ZERO, 46.0 + pulse * 8.0, Color(CRYSTAL_COLOR, 0.12 + pulse * 0.1))
	var bob := sin(_time * 2.0) * 5.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, -46.0 + bob), Vector2(18.0, -10.0 + bob),
		Vector2(0.0, 26.0 + bob), Vector2(-18.0, -10.0 + bob),
	]), CRYSTAL_COLOR)
	draw_set_transform(Vector2(0.0, 34.0), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 30.0, Color(0.0, 0.0, 0.0, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
