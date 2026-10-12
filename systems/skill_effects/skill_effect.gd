class_name SkillEffect
extends Resource
## Một hiệu ứng ghép trong SkillData. Kỹ năng = danh sách hiệu ứng chạy lần lượt.
## Lớp con ghi đè apply(); `scope` chọn ai chịu hiệu ứng (xem SkillContext.entries).

enum Scope {
	## Mục tiêu của kỹ năng (chính + bên cạnh với kỹ năng lan).
	TARGETS,
	MAIN,
	ADJACENT,
	SELF,
	ALL_ALLIES,
	ALLIES_EXCEPT_SELF,
	ALL_ENEMIES,
	## Quái còn sống đầu hàng (dùng cho hiệu ứng đầu trận không có mục tiêu chọn).
	FIRST_ENEMY,
	## 1 quái còn sống ngẫu nhiên.
	RANDOM_ENEMY,
}

@export var scope: Scope = Scope.TARGETS


func apply(_ctx: SkillContext) -> void:
	pass


## Thay đổi quãng đường để xem trước thứ tự lượt (chỉ TurnShiftEffect dùng).
func collect_turn_overrides(_ctx: SkillContext, _overrides: Dictionary) -> void:
	pass
