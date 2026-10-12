# Tiến độ

Đầu mỗi phiên: đọc `docs/GAME_SPEC.md` và file này.

| Phase | Trạng thái |
| --- | --- |
| 1. Khung dự án, lời dẫn, chọn nhân vật chính | Xong |
| 2. Di chuyển và phòng kiểu Soul Knight | Xong, chờ duyệt |
| 3–14 | Chưa làm |

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

- Lưu phòng đã khám phá, rương đã mở, hộp đã phá, vị trí người chơi vào GameState (Phase 3).
- Đòn Mở Màn phá Hộp Bí Kỹ (Phase 3); Điểm Bí Kỹ thật (Phase 6).
- Hồi máu, lưu game, dịch chuyển nhanh ở phòng nghỉ (Phase 9, 12, 14).
- Phần thưởng rương (Phase 10).
- Nút cảm ứng cho Đòn Mở Màn, Bí Kỹ, đổi nhân vật (Phase 3, 6).
- Phòng boss đang trống (Phase 8).

## Để sau

(Chưa có.)
