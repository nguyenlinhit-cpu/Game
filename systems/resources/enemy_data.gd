class_name EnemyData
extends Resource
## Dữ liệu một loại quái: nhận diện, nguyên tố, điểm yếu, Khiên Điểm Yếu, chỉ số theo cấp,
## bộ hành động AI (EnemyAction), giai đoạn boss, kỹ năng khi chết, script cơ chế riêng.

enum Kind { NORMAL, ELITE, BOSS }

@export var id: StringName
@export var name_key: String = ""
@export var desc_key: String = ""
@export var kind: Kind = Kind.NORMAL
## Họ quái (các biến thể nguyên tố chung một họ), dùng cho điều kiện "còn bao nhiêu con cùng loại".
@export var family: StringName = &""
## Nguyên tố tấn công.
@export var element: Element.Type = Element.Type.POISON
## 1–3 nguyên tố điểm yếu (kháng 0%); các nguyên tố khác kháng default_res.
@export var weaknesses: Array[Element.Type] = []
@export var max_toughness: float = 30.0
@export var default_res: float = 0.2
@export var placeholder_color: Color = Color("8e2a3b")
## Hình tạm lớn hơn (boss, tinh anh).
@export var size_scale: float = 1.0

@export_group("Chiến đấu")
@export var stats_lv1: StatBlock
@export var stats_lv80: StatBlock
## Bộ hành động AI. Để trống thì dùng skills + skill_weights (dữ liệu cũ Phase 3–7).
@export var actions: Array[EnemyAction] = []
@export var skills: Array[SkillData] = []
## Trọng số chọn từng kỹ năng (cùng thứ tự với skills). Thiếu thì coi như 1.
@export var skill_weights: PackedFloat32Array = PackedFloat32Array()
## Chạy khi quái này ngã (vd. Mầm Ma Biến nổ). Không tốn lượt.
@export var death_skill: SkillData
## Script cơ chế riêng (lớp con EnemyBehavior), gắn khi quái xuất hiện.
@export var behavior_script: Script
## Số liệu cho behavior_script (để cân bằng mà không sửa code).
@export var behavior_params: Dictionary = {}

@export_group("Boss")
## Giai đoạn 2, 3... (giai đoạn 1 = dữ liệu ở trên).
@export var phases: Array[BossPhaseData] = []
@export var music_id: StringName = &""


## Bộ hành động thực dùng (chuyển skills cũ sang EnemyAction nếu chưa khai báo actions).
func get_actions() -> Array[EnemyAction]:
	if not actions.is_empty():
		return actions
	var result: Array[EnemyAction] = []
	for i in skills.size():
		var action := EnemyAction.new()
		action.skill = skills[i]
		action.weight = skill_weights[i] if i < skill_weights.size() else 1.0
		result.append(action)
	return result


func is_boss() -> bool:
	return kind == Kind.BOSS
