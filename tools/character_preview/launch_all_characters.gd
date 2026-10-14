extends Node
## Mở phòng thử với toàn bộ nhân vật, dùng thư mục save riêng.
## godot --path . res://tools/character_preview/launch_all_characters.tscn


func _ready() -> void:
	if not OS.is_debug_build():
		get_tree().change_scene_to_file(DataPaths.TITLE_SCENE)
		return
	SaveManager.save_dir = "user://character_preview_saves"
	GameState.reset_new_game()
	GameState.owned_characters = DataPaths.list_character_ids()
	GameState.team_level = 20
	GameState.current_map_scene = DataPaths.HUB_SCENE
	if OS.get_cmdline_user_args().has("--female"):
		GameState.player_gender = &"female"
		GameState.player_name = GameState.get_default_name(&"female")
	SceneRouter.payload = {}
	print("Character preview: %d characters unlocked; choose four in Đội & quái…." % GameState.owned_characters.size())
	get_tree().change_scene_to_file.call_deferred(DataPaths.BATTLE_SANDBOX_SCENE)
