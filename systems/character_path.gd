class_name CharacterPath
extends RefCounted
## 7 vận mệnh (mục 6): vai trò trong đội và trọng số bị quái nhắm.

enum Type { DESTRUCTION, HUNT, ERUDITION, HARMONY, NIHILITY, PRESERVATION, ABUNDANCE }

const AGGRO_WEIGHTS: Dictionary = {
	Type.DESTRUCTION: 125.0,
	Type.HUNT: 75.0,
	Type.ERUDITION: 75.0,
	Type.HARMONY: 100.0,
	Type.NIHILITY: 100.0,
	Type.PRESERVATION: 150.0,
	Type.ABUNDANCE: 100.0,
}
const NAME_KEYS: Dictionary = {
	Type.DESTRUCTION: "PATH_DESTRUCTION",
	Type.HUNT: "PATH_HUNT",
	Type.ERUDITION: "PATH_ERUDITION",
	Type.HARMONY: "PATH_HARMONY",
	Type.NIHILITY: "PATH_NIHILITY",
	Type.PRESERVATION: "PATH_PRESERVATION",
	Type.ABUNDANCE: "PATH_ABUNDANCE",
}


static func aggro_weight(path: int) -> float:
	return AGGRO_WEIGHTS.get(path, 100.0)


static func name_key(path: int) -> String:
	return NAME_KEYS.get(path, "")
