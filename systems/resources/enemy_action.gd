class_name EnemyAction
extends Resource
## Một lựa chọn trong bộ kỹ năng của quái: kỹ năng + trọng số + điều kiện + trọng số theo tình huống
## + cách chọn mục tiêu + báo trước (tích tụ / đếm ngược).
## AI (EnemyAI) lọc các hành động đủ điều kiện, nhân trọng số theo tình huống rồi chọn ngẫu nhiên theo trọng số.

## Cách chọn mục tiêu (với kỹ năng nhắm phe ta; kỹ năng nhắm phe quái luôn chọn quái ít máu nhất).
enum TargetRule {
	## Trọng số bị nhắm theo vận mệnh × (1 + AGGRO), có Khiêu Khích thì phải nhắm người khiêu khích.
	AGGRO,
	LOWEST_HP,
	HIGHEST_ATK,
	RANDOM,
	## Người đang mang hiệu ứng `requires_foe_status` do chính quái này gắn (vd. Đánh Dấu của Xạ Thủ).
	MARKED,
	## Người có nhiều buff nhất (hút / sao chép buff).
	MOST_BUFFS,
}

@export var skill: SkillData
@export var weight: float = 1.0
@export var target_rule: TargetRule = TargetRule.AGGRO

@export_group("Điều kiện")
## Chỉ dùng khi tỉ lệ máu bản thân nằm trong [min, max].
@export_range(0.0, 1.0) var min_hp_ratio: float = 0.0
@export_range(0.0, 1.0) var max_hp_ratio: float = 1.0
## Sau khi dùng phải chờ chừng này lượt của bản thân (1 = cách 1 lượt).
@export var cooldown_turns: int = 0
## Lượt sớm nhất được dùng (đếm lượt của bản thân trong giai đoạn hiện tại, bắt đầu từ 1).
@export var first_turn: int = 1
## Số lần dùng tối đa mỗi trận (0 = không giới hạn).
@export var max_uses: int = 0
## Chỉ dùng khi số quái cùng họ (EnemyData.family) còn sống ≤ giá trị này (0 = bỏ qua). Vd. Bầy Ong gọi thêm khi còn 1.
@export var max_family_alive: int = 0
## Kỹ năng triệu hồi: cần còn chỗ trong giới hạn 5 quái.
@export var needs_free_slot: bool = false
## Chỉ dùng khi có người phe ta mang hiệu ứng này do chính quái gắn.
@export var requires_foe_status: StringName = &""
## Chỉ dùng khi phe ta có buff (hút / sao chép buff).
@export var requires_foe_buff: bool = false
## Chỉ dùng khi bản thân mang hiệu ứng này với ít nhất `self_status_min_stacks` tầng (vd. 4 tầng Nhiệt).
@export var self_status: StringName = &""
@export var self_status_min_stacks: int = 1
## Đủ điều kiện thì dùng ngay, bỏ qua trọng số.
@export var priority: bool = false
## Dùng ngay ở lượt đầu của giai đoạn (nếu đủ điều kiện), bỏ qua trọng số.
@export var priority_on_phase_start: bool = false

@export_group("Trọng số theo tình huống")
## Máu bản thân dưới 50%.
@export var low_hp_weight_mult: float = 1.0
## Đã có quái phe mình bị hạ trong trận.
@export var ally_fallen_weight_mult: float = 1.0
## Bản thân vừa bị Phá Vỡ kể từ lượt trước.
@export var after_break_weight_mult: float = 1.0
## Có quái phe mình dưới 60% máu (kỹ năng hỗ trợ).
@export var injured_ally_weight_mult: float = 1.0

@export_group("Báo trước")
## 0 = ra đòn ngay. ≥1 = lượt này chỉ báo trước (biểu tượng cảnh báo), ra đòn sau chừng này lượt của bản thân.
@export var charge_turns: int = 0
## Trong lúc đếm ngược vẫn hành động bình thường (đếm ngược kiểu lời nguyền); false = đứng tích tụ.
@export var act_while_charging: bool = false
## Bị Phá Vỡ trong lúc tích tụ thì hủy đòn.
@export var cancel_on_break: bool = false
## Nhận đủ chừng này phần máu tối đa trong lúc tích tụ thì hủy đòn (0 = không).
@export var cancel_damage_ratio: float = 0.0


func is_charged() -> bool:
	return charge_turns > 0
