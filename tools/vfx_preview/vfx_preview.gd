extends Node
## Xem thử hiệu ứng kỹ năng vẽ tay: đặt đội 4 nhân vật đã có đủ hình trận + VFX rồi mở phòng thử trận.
##   godot --path . res://tools/vfx_preview/vfx_preview.tscn

const TEAM: Array[StringName] = [&"mira", &"kiri", &"garren", &"nyx"]


func _ready() -> void:
	GameState.reset_new_game()
	for id in TEAM:
		if not GameState.owned_characters.has(id):
			GameState.owned_characters.append(id)
	GameState.set_team(TEAM)
	SceneRouter.go_to.call_deferred(DataPaths.BATTLE_SANDBOX_SCENE, {}, 0.01)
