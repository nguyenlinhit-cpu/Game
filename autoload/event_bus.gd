extends Node
## Trung tâm tín hiệu toàn game.
## Đặc tính, Tinh Mệnh, nhiệm vụ ngày... chỉ cần nối vào đây, không cần biết ai phát tín hiệu.

@warning_ignore_start("unused_signal")

# --- Luồng game ---
signal game_started
signal scene_changed(scene_path: String)
signal settings_changed
## Thông báo nhỏ trên HUD.
signal toast_requested(text: String)

# --- Trận đánh (Phase 4–6). Đơn vị trong trận là BattleUnit (RefCounted). ---
signal battle_started(encounter: Resource)
signal turn_started(unit: Object)
signal turn_ended(unit: Object)
signal damage_dealt(source: Object, target: Object, amount: int, is_crit: bool)
signal weakness_broken(source: Object, target: Object)
signal ultimate_used(unit: Object)
signal unit_died(unit: Object)
signal battle_won(encounter: Resource)
signal battle_lost(encounter: Resource)

# --- Ngoài map (Phase 2–6) ---
signal technique_used(character_id: StringName)
signal technique_points_changed(value: int)
signal leader_changed(index: int)
signal obstacle_resolved(obstacle_id: String)
signal camera_shake_requested(strength: float, duration: float)
signal chest_opened(chest_id: StringName)

# --- Tiến trình, gacha, nhiệm vụ (Phase 9–11) ---
signal character_upgraded(character_id: StringName)
signal gacha_pulled(banner_id: StringName, results: Array)
signal quest_completed(quest_id: StringName)
signal story_flag_set(flag: StringName, value: Variant)

@warning_ignore_restore("unused_signal")
