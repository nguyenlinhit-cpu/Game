class_name PlaceholderRewards
extends RefCounted
## Phần thưởng TẠM cho thắng ngay / thắng trận ở Phase 3–4, theo mức giữa bảng mục 11
## (quái thường: 30 Xu, 60% ra 1 Ký Ức bậc 1). Phase 10 thay bằng LootTable thật, xóa file này.

const COINS_PER_ENEMY: int = 30
const MEMORY_CHANCE: float = 0.6
## Ký Ức Mảnh Hồn bậc 1 = 100 EXP (mục 11).
const EXP_PER_MEMORY_1: int = 100


static func for_encounter(encounter: EncounterData) -> Dictionary:
	var count := encounter.get_total_enemy_count() if encounter else 1
	return {
		"aether_coin": count * COINS_PER_ENEMY,
		"soul_memory_1": ceili(count * MEMORY_CHANCE),
	}


static func describe(rewards: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	if rewards.get("aether_coin", 0) > 0:
		lines.append(TranslationServer.translate("REWARD_COINS") % rewards["aether_coin"])
	if rewards.get("soul_memory_1", 0) > 0:
		lines.append(TranslationServer.translate("REWARD_MEMORY_1") % rewards["soul_memory_1"])
	return lines


static func exp_for_encounter(encounter: EncounterData) -> int:
	return int(for_encounter(encounter)["soul_memory_1"]) * EXP_PER_MEMORY_1
