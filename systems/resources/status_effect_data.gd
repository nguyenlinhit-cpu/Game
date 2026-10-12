class_name StatusEffectData
extends Resource
## Hiệu ứng trạng thái dạng dữ liệu: buff/debuff có số lượt, cộng dồn, tỉ lệ trúng,
## sát thương theo lượt, mất lượt, trì hoãn, kích hoạt khi bị đánh.
## Thời điểm: sát thương theo lượt và mất lượt xử lý ĐẦU lượt của người mang;
## số lượt trừ ở CUỐI lượt của người mang (gắn giữa chừng thì lượt hiện tại không bị tính).

enum Kind { BUFF, DEBUFF }
enum StackMode { REFRESH, ADD }
## Cách tính giá trị nền của sát thương theo lượt.
## BREAK_BASE: mức phá vỡ theo cấp người gắn × (1 + Hiệu Ứng Phá Vỡ).
## TARGET_MAX_HP: % máu tối đa người mang, có trần = dot_cap_multiplier × mức phá vỡ.
## ATTACKER_STAT: chỉ số của người gắn (Phase 6 dùng cho kỹ năng gây Thiêu Đốt...).
enum DotMode { NONE, BREAK_BASE, TARGET_MAX_HP, ATTACKER_STAT }

@export var id: StringName
@export var name_key: String = ""
@export var desc_key: String = ""
@export var kind: Kind = Kind.DEBUFF
## Chữ trên biểu tượng tạm (1–2 ký tự).
@export var icon_text: String = "?"
@export var icon_color: Color = Color.WHITE
@export_range(1, 10) var duration_turns: int = 2
@export_range(1, 10) var max_stacks: int = 1
@export var stack_mode: StackMode = StackMode.REFRESH

@export_group("Tỉ lệ trúng")
## Tỉ lệ cuối = tỉ lệ gốc × (1 + Chính Xác Hiệu Ứng của người gắn) × (1 − Kháng Hiệu Ứng của mục tiêu).
@export var base_chance: float = 1.0
## Bỏ qua Chính Xác/Kháng Hiệu Ứng (buff cho đồng minh, hiệu ứng cố định).
@export var ignores_resistance: bool = false

@export_group("Chỉ số")
@export var stat_modifiers: Array[StatModifierData] = []

@export_group("Sát thương theo lượt")
@export var dot_mode: DotMode = DotMode.NONE
@export var dot_element: Element.Type = Element.Type.FIRE
## Hệ số trên giá trị nền, nhân số tầng.
@export var dot_multiplier: float = 0.0
## Trần cho TARGET_MAX_HP (× mức phá vỡ). 0 = không trần.
@export var dot_cap_multiplier: float = 0.0
@export var dot_scaling_stat: Stats.Type = Stats.Type.ATK

@export_group("Điều khiển")
## Mất lượt kế tiếp (hết hiệu ứng ngay khi mất lượt).
@export var skip_turn: bool = false
## Trì hoãn thêm khi vừa gắn (0,2 = 20%).
@export var extra_delay: float = 0.0

@export_group("Kích hoạt")
## Sát thương khi hết mất lượt (Đóng Băng tan), × giá trị nền.
@export var on_skip_damage_multiplier: float = 0.0
@export var on_skip_element: Element.Type = Element.Type.WATER
## Sát thương thêm khi người mang trúng đòn kế tiếp (Trói Rễ), × giá trị nền.
@export var on_hit_damage_multiplier: float = 0.0
@export var on_hit_element: Element.Type = Element.Type.WOOD
@export var consume_on_hit: bool = false
