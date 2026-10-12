extends Control
## Trận TẠM của Phase 3: hiện kiểu mở trận, danh sách quái theo đợt, 2 nút Thắng/Thua.
## Phase 4 thay bằng trận theo lượt thật, giữ nguyên cách vào (SceneRouter.payload) và cách ra
## (GameState.finish_battle + quay về map với payload "battle_result").

var _encounter: EncounterData
var _opening: BattleTypes.Opening = BattleTypes.Opening.NORMAL

@onready var _opening_label: Label = %OpeningLabel
@onready var _enemy_list: Label = %EnemyList
@onready var _win_button: Button = %WinButton
@onready var _lose_button: Button = %LoseButton


func _ready() -> void:
	_encounter = SceneRouter.payload.get("encounter") as EncounterData
	_opening = int(SceneRouter.payload.get("opening", BattleTypes.Opening.NORMAL)) as BattleTypes.Opening
	if _encounter == null:
		# Mở thẳng scene này để thử: dùng trận mẫu.
		_encounter = load(DataPaths.DEBUG_ENCOUNTER) as EncounterData
	_opening_label.text = tr(BattleTypes.opening_key(_opening))
	_opening_label.add_theme_color_override("font_color", _opening_color())
	_enemy_list.text = _describe_encounter()
	_win_button.pressed.connect(_finish.bind(true))
	_lose_button.pressed.connect(_finish.bind(false))
	_win_button.grab_focus()
	EventBus.battle_started.emit(_encounter)


func get_opening() -> BattleTypes.Opening:
	return _opening


func _describe_encounter() -> String:
	var lines: Array[String] = []
	for i in _encounter.waves.size():
		var parts: Array[String] = []
		for entry in _encounter.waves[i].entries:
			var enemy_name := tr(entry.enemy.name_key) if entry.enemy else "?"
			parts.append("%s Lv%d ×%d" % [enemy_name, entry.level, entry.count])
		lines.append("%s: %s" % [tr("BATTLE_WAVE") % (i + 1), ", ".join(parts)])
	return "\n".join(lines)


func _opening_color() -> Color:
	match _opening:
		BattleTypes.Opening.ADVANTAGE: return Color("6fdc8c")
		BattleTypes.Opening.AMBUSHED: return Color("ff5c5c")
		_: return Color.WHITE


func _finish(won: bool) -> void:
	if SceneRouter.is_busy():
		return
	if won:
		print("[Battle] Thắng: %s – phần thưởng %s (tạm)" % [_encounter.id, PlaceholderRewards.for_encounter(_encounter)])
		EventBus.battle_won.emit(_encounter)
	else:
		EventBus.battle_lost.emit(_encounter)
	var map_scene := GameState.finish_battle(won)
	SceneRouter.go_to(map_scene, {"battle_result": "win" if won else "lose"})
