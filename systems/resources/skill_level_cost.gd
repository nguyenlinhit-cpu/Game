class_name SkillLevelCost
extends Resource
## Chi phí nâng một kỹ năng lên `level` (2–5): Xu Aether + Dấu Ấn Vận Mệnh đúng vận mệnh (bậc `sigil_tier`)
## + Lõi Ma Biến ở cấp cao. Cần đã đột phá ít nhất `required_ascension` lần.

@export var level: int = 2
@export var coin: int = 0
@export var sigil_tier: int = 1
@export var sigil_count: int = 0
@export var warp_cores: int = 0
@export var required_ascension: int = 0
