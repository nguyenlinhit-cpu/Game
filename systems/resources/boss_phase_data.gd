class_name BossPhaseData
extends Resource
## Một giai đoạn sau của boss (giai đoạn 1 là dữ liệu gốc trong EnemyData).
## Máu chạm ngưỡng thì dừng lại ở ngưỡng (không bỏ qua giai đoạn), chuyển giai đoạn ngay sau hành động đó.
## Trường để trống = giữ như giai đoạn trước.

@export var name_key: String = ""
## Vào giai đoạn khi máu ≤ ngưỡng này. Âm = do EnemyBehavior gọi (vd. hạ hết phân thân).
@export var hp_threshold: float = 0.5
@export var weaknesses: Array[Element.Type] = []
@export var max_toughness: float = 0.0
@export var actions: Array[EnemyAction] = []
@export var stat_modifiers: Array[StatModifierData] = []
## Gỡ mọi debuff trên boss khi chuyển giai đoạn.
@export var cleanse_debuffs: bool = true
## Kéo lượt boss khi chuyển giai đoạn (0,5 = 50%).
@export var action_advance: float = 0.0
## Màu nền đoạn chuyển giai đoạn.
@export var color: Color = Color(0.6, 0.1, 0.2)
## Nhạc của giai đoạn (PlaceholderMusic id; rỗng = giữ nhạc cũ).
@export var music_id: StringName = &""
