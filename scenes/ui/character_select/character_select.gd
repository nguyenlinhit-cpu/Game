extends Control
## Chọn nhân vật chính: Nam/Nữ (2 skin của cùng CharacterData `traveler`) và đặt tên.

const UNSELECTED_MODULATE := Color(0.6, 0.6, 0.6, 1.0)
const SELECTED_BORDER_WIDTH: int = 4

var _gender: StringName
## Người chơi đã tự gõ tên chưa; chưa thì đổi giới tính sẽ đổi luôn tên mặc định.
var _name_customized: bool = false
var _traveler: CharacterData

@onready var _male_card: Button = %MaleCard
@onready var _female_card: Button = %FemaleCard
@onready var _male_preview: AvatarPreview = %MalePreview
@onready var _female_preview: AvatarPreview = %FemalePreview
@onready var _male_label: Label = %MaleLabel
@onready var _female_label: Label = %FemaleLabel
@onready var _name_edit: LineEdit = %NameEdit
@onready var _confirm_button: Button = %ConfirmButton


func _ready() -> void:
	_traveler = DataPaths.load_character(GameState.PLAYER_CHARACTER_ID)
	_setup_card(_male_preview, _male_label, GameState.GENDER_MALE)
	_setup_card(_female_preview, _female_label, GameState.GENDER_FEMALE)

	var group := ButtonGroup.new()
	_male_card.button_group = group
	_female_card.button_group = group
	_male_card.pressed.connect(_select_gender.bind(GameState.GENDER_MALE))
	_female_card.pressed.connect(_select_gender.bind(GameState.GENDER_FEMALE))

	_name_edit.max_length = GameState.MAX_PLAYER_NAME_LENGTH
	_name_edit.text_changed.connect(_on_name_changed)
	_name_edit.text_submitted.connect(func(_text: String) -> void: _confirm())
	_confirm_button.pressed.connect(_confirm)

	_select_gender(GameState.player_gender)


func _setup_card(preview: AvatarPreview, label: Label, gender: StringName) -> void:
	if _traveler == null:
		return
	var skin := _traveler.get_skin(gender)
	preview.apply_skin(skin)
	var card := preview.get_parent() as Button
	# Thẻ đang chọn có viền màu nhấn của skin.
	var selected_style := StyleBoxFlat.new()
	selected_style.bg_color = skin.placeholder_color.darkened(0.6) if skin else Color(0.1, 0.1, 0.1)
	selected_style.border_color = skin.accent_color if skin else Color.WHITE
	selected_style.set_border_width_all(SELECTED_BORDER_WIDTH)
	selected_style.set_corner_radius_all(12)
	card.add_theme_stylebox_override("pressed", selected_style)
	card.add_theme_stylebox_override("hover_pressed", selected_style)
	if skin and not skin.label_key.is_empty():
		label.text = skin.label_key


func _select_gender(gender: StringName) -> void:
	_gender = gender
	var is_male := gender == GameState.GENDER_MALE
	var selected_card := _male_card if is_male else _female_card
	selected_card.set_pressed_no_signal(true)
	selected_card.grab_focus()
	_male_card.modulate = Color.WHITE if is_male else UNSELECTED_MODULATE
	_female_card.modulate = UNSELECTED_MODULATE if is_male else Color.WHITE
	if not _name_customized:
		_name_edit.text = GameState.get_default_name(gender)
	_update_letters()


func _on_name_changed(new_text: String) -> void:
	var trimmed := new_text.strip_edges()
	# Xóa trắng hoặc gõ lại đúng tên mặc định thì coi như chưa đặt tên riêng.
	_name_customized = not trimmed.is_empty() \
			and not GameState.DEFAULT_PLAYER_NAMES.values().has(trimmed)
	_update_letters()


func _update_letters() -> void:
	var display_name := GameState.sanitize_player_name(_name_edit.text, _gender)
	var letter := display_name.left(1).to_upper()
	_male_preview.letter = letter
	_female_preview.letter = letter


func _confirm() -> void:
	if SceneRouter.is_busy():
		return
	GameState.set_player_identity(_gender, _name_edit.text)
	GameState.current_map_scene = DataPaths.TEST_MAP_SCENE
	SaveManager.save_game(SaveManager.AUTOSAVE_SLOT)
	EventBus.game_started.emit()
	SceneRouter.go_to(DataPaths.TEST_MAP_SCENE)
