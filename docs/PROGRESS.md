# Tiến độ

Đầu mỗi phiên: đọc `docs/GAME_SPEC.md` và file này.

| Phase | Trạng thái |
| --- | --- |
| 1. Khung dự án, lời dẫn, chọn nhân vật chính | Xong |
| 2. Di chuyển và phòng kiểu Soul Knight | Xong |
| 3. Quái trên map và chuyển vào trận | Xong, chờ duyệt |
| 4–14 | Chưa làm |

## Phase 1 – Khung dự án, lời dẫn, chọn nhân vật chính

### Đã làm

- Dự án Godot 4.7, renderer Compatibility, 1920×1080, stretch `canvas_items`, aspect `expand`, `.gitignore`. Cấu trúc thư mục theo mục 13.
- 7 autoload: `EventBus` (khai báo sẵn tín hiệu cho các phase sau), `GameState`, `SaveManager` (JSON có số phiên bản), `SceneRouter` (mờ đen ≈0,7 giây, có `payload`), `AudioManager` (bus Master/Music/SFX/Voice, âm lượng), `GachaManager`, `QuestManager` (khung + TODO).
- Input map: `move_*`, `dash`, `opener_attack`, `technique`, `switch_character_1..4`, `interact`, `menu` (bàn phím, chuột, tay cầm). Sinh bằng `tools/setup_input_map.gd`.
- Màn tiêu đề (Bắt đầu / Tiếp tục mờ khi chưa có save / Cài đặt âm lượng tạm / Thoát), lời dẫn chữ chạy có bỏ qua, màn chọn Nam/Nữ + đặt tên, phòng trống tạm có nhân vật chính và tên trên đầu.
- `CharacterData` + `CharacterSkin`; `data/characters/traveler.tres` có 2 skin `male`/`female`.
- Chữ trong game ở `localization/strings.csv` (vi, en).
- Test khói `tests/phase01_smoke_test.tscn`: 19/19 đạt.

### File chính

- `project.godot`, `autoload/*.gd`
- `systems/data_paths.gd`, `systems/user_settings.gd`, `systems/placeholder_art.gd`, `systems/resources/character_data.gd`, `systems/resources/character_skin.gd`
- `scenes/ui/title/`, `scenes/ui/intro/`, `scenes/ui/character_select/`, `scenes/ui/settings/`, `scenes/ui/common/avatar_preview.gd`
- `scenes/overworld/player/player.*`, `scenes/overworld/rooms/test_room.*`
- `data/characters/traveler.tres`, `data/dialogue/intro.json`, `localization/strings.csv`
- `assets/vfx/shaders/starfield_bg.gdshader`, `assets/ui/main_theme.tres`
- `tools/setup_input_map.gd`, `tests/phase01_smoke_test.*`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 1. Tóm tắt: tự lưu ngay sau khi tạo nhân vật; cài đặt theo máy để trong `UserSettings` (lớp tĩnh, không thêm autoload); nguyên tố/vận mệnh tạm là `StringName`.

### Việc còn nợ

- Hỏi xác nhận khi "Bắt đầu" ghi đè save cũ (Phase 14).
- ~~Menu tạm dừng~~ (đã làm ở Phase 2).
- Hình thật cho nhân vật chính, tranh nền lời dẫn (Phase 13).
- Nhạc nền màn tiêu đề (Phase 14).

## Phase 2 – Di chuyển và phòng kiểu Soul Knight

### Đã làm

- `Player` (CharacterBody2D, chế độ floating): đi 8 hướng có gia tốc/giảm tốc, lướt có hồi chiêu và bất tử ngắn, hình tạm có mũi tên hướng, nhấp nhô khi chạy, bóng mờ khi lướt. Thông số ở `data/config/player_movement.tres`. Có `get_facing_name()` (e, se, s...) và `get_animation_name()` (idle/run/dash) để Phase 13 nối sprite.
- `CameraRig`: bám mượt, giới hạn theo phòng (phòng nhỏ hơn màn hình thì căn giữa), hành lang bỏ giới hạn. Rung dùng chung: `CameraRig.shake(cường_độ, thời_gian)`.
- Hệ phòng: `Room` + 4 phòng mẫu TileMapLayer (sàn, tường có va chạm): nghỉ 17×13, chiến đấu 27×19, rương 17×13, boss 31×23. Phòng mẫu chừa lỗ cửa 3 ô ở 4 cạnh; `OverworldMap` nối các phòng kề nhau trên lưới bằng hành lang, tạo cửa ở phía có nối và bịt tường phía còn lại.
- `RoomManager`: phòng hiện tại (null = hành lang), phòng đã khám phá, khóa cửa phòng chiến đấu/tinh anh/boss khi còn nhóm quái, mở khi hết. F8 (chỉ bản debug) xóa nhóm quái giả.
- Minimap góc phải: phòng đã vào, phòng kề chưa vào (viền mờ), hành lang, biểu tượng loại phòng, chấm vị trí người chơi.
- Vật tương tác bằng F: rương (3 bậc), Hộp Bí Kỹ (phá được), điểm nghỉ (chỉ in log + TODO).
- Điều khiển cảm ứng: joystick ảo, nút Lướt (hiện thời gian hồi), nút F. Đa chạm. Tự hiện trên điện thoại; PC bật trong Cài đặt → "Điều khiển cảm ứng".
- Menu tạm dừng (Esc): Chơi tiếp, Cài đặt, Về màn hình tiêu đề.
- Công cụ `tools/level_builder/build_rooms.tscn` sinh tileset tạm và 4 phòng mẫu.
- Test `tests/phase02_test.tscn`: 39/39 đạt (đi bộ thật qua 4 phòng bằng input giả lập). Test Phase 1 vẫn đạt 19/19.
- FPS đo khi đi qua các phòng (renderer thật, Radeon 740M): thấp nhất 140, trung bình 143 (giới hạn bởi vsync 144 Hz).

### File chính

- `scenes/overworld/player/player.*`, `scenes/overworld/map/{overworld_map,room_manager,camera_rig}.gd`, `scenes/overworld/map/test_map.tscn`
- `scenes/overworld/rooms/{room,door}.gd`, `room_rest_01|room_combat_01|room_chest_01|room_boss_01.tscn`
- `scenes/overworld/interactables/{interactable,chest,technique_box,rest_point}.*`
- `scenes/overworld/overworld_enemy/enemy_group_placeholder.*`
- `scenes/ui/hud/{overworld_hud,minimap}.*`, `scenes/ui/touch/*`, `scenes/ui/pause/*`
- `systems/{physics_layers,tile_ids}.gd`, `systems/resources/player_movement_config.gd`, `data/config/player_movement.tres`
- `assets/tilesets/placeholder_tiles.png`, `assets/tilesets/placeholder_tileset.tres`
- `tools/level_builder/build_rooms.*`, `tests/phase02_test.*`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 2.

### Việc còn nợ

- ~~Lưu trạng thái map vào GameState~~, ~~Đòn Mở Màn phá Hộp Bí Kỹ~~ (đã làm ở Phase 3). Điểm Bí Kỹ thật (Phase 6).
- Hồi máu, lưu game, dịch chuyển nhanh ở phòng nghỉ (Phase 9, 12, 14).
- Phần thưởng rương (Phase 10).
- Nút cảm ứng cho Bí Kỹ, đổi nhân vật (Phase 6). Nút Đòn Mở Màn đã có từ Phase 3.
- Phòng boss đang trống (Phase 8).

## Phase 3 – Quái trên map và chuyển vào trận

### Đã làm

- Dữ liệu: `EnemyData`, `EncounterData` (nhiều đợt) → `EncounterWave` (tối đa 5 quái, có kiểm tra) → `EncounterEnemyEntry` (quái, cấp, số lượng). 3 quái mẫu (`data/enemies/`), 3 trận mẫu (`data/encounters/`).
- `OverworldEnemy`: tuần tra theo điểm định sẵn (hoặc đứng gác quay nhìn), tầm nhìn hình nón có kiểm tra tường chắn, nghe được khi đứng sát sau lưng, báo "!" rồi đuổi, bỏ cuộc ("?") khi người chơi quá xa / mất dấu 2 giây / quá xa điểm gác, vồ có báo trước (gồng đỏ 0,45 giây). Thông số trong `data/config/overworld_enemy_default.tres`. Hiện cấp quái trên đầu (xám nếu là quái yếu).
- Đòn Mở Màn tạm "Vết Chém Hồn" (`data/skills/traveler_opener.tres`): quạt 120°, tầm 120 px, hồi 0,6 giây; J, chuột trái (chém về phía con trỏ) hoặc nút cảm ứng "Chém". Phá luôn Hộp Bí Kỹ trong quạt.
- Kiểu mở trận: chém trúng trước → Ưu Thế; quái vồ trúng → Bị Phục Kích; chạm thường → Bình thường. Đang lướt (bất tử) thì né được cả vồ lẫn chạm.
- Thắng ngay: quái thấp hơn cấp đội ≥10 cấp bị chém trúng → biến mất, hiện bảng phần thưởng tạm, không vào trận.
- Trạng thái map trong `GameState.map_states` (có trong file save): vị trí + hướng người chơi, quái đã hạ, rương đã mở, hộp đã phá, phòng đã khám phá. Mã vật thể = `<room_id>/<đường dẫn trong phòng>` nên không trùng khi dùng chung phòng mẫu.
- Trận tạm `scenes/battle/battle_scene.tscn`: hiện kiểu mở trận, quái theo đợt, nút Thắng/Thua. Thắng → nhóm quái biến mất, về đúng chỗ đứng. Thua → về phòng nghỉ gần nhất (ưu tiên phòng đã khám phá), không mất đồ, nhóm quái vẫn còn. Vừa quay về: người chơi bất tử 1 giây, quái đứng yên 1,5 giây.
- Phòng chiến đấu dùng 3 nhóm quái thật (Lv3, Lv5 hai đợt, Lv1 để thử thắng ngay). Cửa tự khóa lại nếu quay về giữa phòng còn quái.
- Debug: F6/F7 giảm/tăng cấp đội 5 cấp, F8 xóa quái trong phòng.
- Test `tests/phase03_test.tscn`: 25/25 đạt, gồm đủ 4 kiểu mở trận và ra vào trận 10 lần liên tiếp giữ đúng trạng thái. Test Phase 1 (19/19), Phase 2 (39/39) vẫn đạt.

### File chính

- `scenes/overworld/overworld_enemy/overworld_enemy.*`, `scenes/overworld/map/overworld_map.gd`, `scenes/battle/battle_scene.*`
- `systems/battle_types.gd`, `systems/placeholder_rewards.gd`, `systems/resources/{enemy_data,encounter_data,encounter_wave,encounter_enemy_entry,overworld_enemy_config,opener_attack_data}.gd`
- `data/enemies/*.tres`, `data/encounters/*.tres`, `data/config/overworld_enemy_default.tres`, `data/skills/traveler_opener.tres`
- `autoload/game_state.gd` (map_states, pending_battle, team_level), `scenes/overworld/player/player.gd` (Đòn Mở Màn)
- `tests/phase03_test.*`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 3.

### Việc còn nợ

- Trận theo lượt thật thay cho trận tạm (Phase 4); trừ 25% khiên khi Ưu Thế đúng điểm yếu (Phase 5); hiệu ứng Bí Kỹ mang vào trận (Phase 6).
- Cấp đội đang là số cố định `GameState.team_level` (Phase 9 tính từ đội hình).
- Phần thưởng tạm `PlaceholderRewards` (Phase 10 thay bằng LootTable, xóa file).
- Quái thường hồi lại khi rời khu (Phase 10/12; hiện quái đã hạ biến mất hẳn).
- Hiệu ứng chuyển cảnh vào trận riêng (đang dùng mờ đen chung 0,7 giây).

## Để sau

(Chưa có.)
