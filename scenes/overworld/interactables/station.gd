class_name Station
extends Interactable
## Quầy dịch vụ ở Sảnh Trung Tâm: bàn Ước Nguyện, bảng nhiệm vụ, bàn nâng cấp, bàn đổi đội hình, quầy hàng,
## Cổng Dịch Chuyển. Bấm F → OverworldMap.open_station(kind).

enum Kind { GACHA, QUESTS, UPGRADE, TEAM, SHOP, GATE }

const NAME_KEYS: Dictionary = {
	Kind.GACHA: "STATION_GACHA", Kind.QUESTS: "STATION_QUESTS", Kind.UPGRADE: "STATION_UPGRADE",
	Kind.TEAM: "STATION_TEAM", Kind.SHOP: "STATION_SHOP", Kind.GATE: "STATION_GATE",
}
const COLORS: Dictionary = {
	Kind.GACHA: Color("ffd257"), Kind.QUESTS: Color("6fdc8c"), Kind.UPGRADE: Color("ff9a5c"),
	Kind.TEAM: Color("6fb8ff"), Kind.SHOP: Color("d9b38f"), Kind.GATE: Color("c78bff"),
}

const GROUP: StringName = &"station"

@export var kind: Kind = Kind.GACHA

var _time: float = 0.0


func _ready() -> void:
	super()
	add_to_group(GROUP)
	prompt_key = NAME_KEYS[kind]
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(150.0, 110.0) if kind != Kind.GATE else Vector2(220.0, 220.0)
	shape.shape = rect
	add_child(shape)


func get_prompt() -> String:
	return tr("PROMPT_USE") % tr(NAME_KEYS[kind])


func _on_interact(_by: Node) -> void:
	var map := get_tree().current_scene as OverworldMap
	if map:
		map.open_station(kind)


func _process(delta: float) -> void:
	_time += delta
	if kind == Kind.GATE or kind == Kind.GACHA:
		queue_redraw()


func _draw() -> void:
	var color: Color = COLORS[kind]
	var font := ThemeDB.fallback_font
	if kind == Kind.GATE:
		var pulse := 0.5 + 0.5 * sin(_time * 2.0)
		draw_circle(Vector2.ZERO, 96.0, Color(color, 0.15 + 0.1 * pulse))
		draw_arc(Vector2.ZERO, 96.0, 0.0, TAU, 48, color, 6.0, true)
		draw_arc(Vector2.ZERO, 70.0, _time, _time + PI * 1.4, 32, Color(color, 0.7), 4.0, true)
	else:
		draw_rect(Rect2(-70.0, -30.0, 140.0, 60.0), color.darkened(0.5))
		draw_rect(Rect2(-70.0, -30.0, 140.0, 60.0), color, false, 3.0)
		if kind == Kind.GACHA:
			draw_circle(Vector2(0.0, -10.0), 16.0 + sin(_time * 3.0) * 3.0, Color(color, 0.8))
	draw_string(font, Vector2(-120.0, -58.0 if kind != Kind.GATE else -112.0), tr(NAME_KEYS[kind]),
			HORIZONTAL_ALIGNMENT_CENTER, 240.0, 22, color.lightened(0.3))
