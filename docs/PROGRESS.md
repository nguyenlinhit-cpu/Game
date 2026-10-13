# Tiến độ

Đầu mỗi phiên: đọc `docs/GAME_SPEC.md` và file này.

| Phase | Trạng thái |
| --- | --- |
| 1. Khung dự án, lời dẫn, chọn nhân vật chính | Xong |
| 2. Di chuyển và phòng kiểu Soul Knight | Xong |
| 3. Quái trên map và chuyển vào trận | Xong |
| 4. Lõi trận đánh theo lượt | Xong |
| 5. Nguyên tố, khiên, phá vỡ, hiệu ứng | Xong |
| 6. Hệ thống kỹ năng, nhân vật chính, 4 nhân vật miễn phí | Xong |
| 7. 20 nhân vật còn lại | Xong |
| 8. Quái thường, tinh anh, boss | Xong |
| 9. Tiến trình nhân vật (cấp 30) | Xong |
| 10. Tài nguyên, rơi đồ, nhiệm vụ ngày/tuần | Xong |
| 11. Gacha 2 banner, cửa hàng Bụi Sao | Xong |
| 12. Bản đồ Pháo Đài Vọng Tinh và cốt truyện | Xong |
| 13. Đồ họa 2D với Blender và Krita (công cụ) | Xong |
| 14. Lưu/tải, âm thanh, cài đặt, cảm ứng, cân bằng, xuất bản | Xong, chờ duyệt |

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
- ~~Phần thưởng rương~~ (đã làm ở Phase 10).
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

- ~~Trận theo lượt thật~~ (Phase 4); trừ 25% khiên khi Ưu Thế đúng điểm yếu (Phase 5); hiệu ứng Bí Kỹ mang vào trận (Phase 6).
- Cấp đội đang là số cố định `GameState.team_level` (Phase 9 tính từ đội hình).
- ~~Phần thưởng tạm `PlaceholderRewards`~~ (Phase 10 đã thay bằng LootTable, xóa file).
- ~~Quái thường hồi lại khi rời khu~~ (Phase 10; Phase 12 đặt khu cho phòng).
- Hiệu ứng chuyển cảnh vào trận riêng (đang dùng mờ đen chung 0,7 giây).

## Phase 4 – Lõi trận đánh theo lượt

### Đã làm

- `systems/stats.gd`: 11 chỉ số mục 5 + 4 hệ số chiến đấu (Tăng sát thương, Dễ tổn thương, Giảm phòng thủ, Kháng). Bộ điều chỉnh cộng thẳng và cộng %, gỡ theo id hoặc theo nguồn. Chỉ số theo cấp từ 2 bảng `StatBlock` cấp 1 và cấp 80 (Máu/Tấn Công/Phòng Thủ nội suy tuyến tính).
- `systems/game_config.gd`: `MAX_LEVEL = 30`, `DESIGN_MAX_LEVEL = 80`, `MAX_TEAM_SIZE = 4`.
- `systems/damage_calc.gd`: đúng công thức mục 5, một hàm duy nhất; hệ số phá vỡ có sẵn tham số (0,9 còn khiên / 1,0 đã vỡ). Làm tròn xuống, tối thiểu 1.
- `BattleUnit` (logic, không vẽ) và `TurnQueue`: GTHĐ = quãng đường còn lại / Tốc Độ (quãng 10000). Kéo lượt, trì hoãn, đổi Tốc Độ giữa trận tự đúng. Dự đoán N lượt tới, xem trước khi chọn kỹ năng.
- `BattleController` (state machine): phe ta tối đa 4 (từ chối cứng đội 5 người), quái tối đa 5 mỗi đợt, nhiều đợt, người ngã không có ai thay. Điểm Chiến Kỹ dùng chung (đầu trận 3, tối đa 5). Năng lượng (hành động, bị đánh +10). Hàng chen lượt Tuyệt kỹ. Ưu Thế: cả đội đi trước vòng đầu; Phục Kích: quái đi trước.
- `SkillData` tạm (sát thương đơn/lan/toàn bộ, hồi máu, kéo/đẩy lượt, Điểm Chiến Kỹ, năng lượng). `SkillExecutor` áp kỹ năng. `EnemyAI` tạm (ngẫu nhiên theo trọng số), `AutoBattle` (Tự Động).
- Giao diện trận: phe ta trái, quái phải, thanh thứ tự lượt bên trái (có xem trước, ô thay đổi viền vàng), 4 thẻ nhân vật (máu, năng lượng, bấm để dùng Tuyệt kỹ), nút Đánh thường / Chiến kỹ (Q/E, bấm lại = ra đòn), 5 viên Điểm Chiến Kỹ, chọn mục tiêu đơn / lan 3 / toàn bộ (bấm quái, ←/→, Space). Số sát thương bay dùng object pool, bạo kích màu vàng. Băng rôn Tuyệt kỹ (bấm để bỏ qua). Nút Tự Động và x2 (nhớ lựa chọn). Màn thắng (EXP tạm, vật phẩm trống) và màn thua (Đánh lại / Rút lui).
- 4 nhân vật mẫu (`traveler`, `mira`, `kiri`, `garren`, dùng đúng id để Phase 6 ghi đè) và 3 quái mẫu có chỉ số + kỹ năng. Đội mặc định trong `GameState.team` (`set_team` từ chối >4 người và nhân vật trùng).
- Debug: F9 thắng trận ngay.
- Test `tests/phase04_test.tscn`: 57/57 đạt. Gồm 13 ca công thức sát thương (ca 10 tính tay đủ mọi hệ số = 2916), tỉ lệ bạo kích 10.000 lần, thứ tự lượt 8 lượt + đổi tốc độ + kéo/đẩy lượt, 40 trận mô phỏng (Tự Động + chọn bừa) kiểm tra Điểm Chiến Kỹ luôn trong 0–5, chen lượt Tuyệt kỹ, đánh trọn trận bằng sự kiện chuột thật, trận 2 đợt bằng Tự Động, từ chối đội 5 người ở cả GameState, BattleController và màn trận. Test Phase 1–3 vẫn đạt.

### File chính

- `systems/{stats,damage_calc,game_config,enemy_ai,auto_battle}.gd`, `systems/resources/{stat_block,skill_data}.gd`
- `scenes/battle/{battle_unit,turn_queue,skill_executor,battle_controller,battle_scene}.gd`, `scenes/battle/battle_scene.tscn`
- `scenes/battle/ui/{unit_view,character_card,turn_order_bar,skill_points_bar,damage_number_pool}.gd`
- `data/characters/{traveler,mira,kiri,garren}.tres`, `data/enemies/*.tres`, `data/skills/*.tres`
- `tests/test_base.gd`, `tests/phase04_test.*`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 4.

### Việc còn nợ

- ~~Nguyên tố, Khiên Điểm Yếu, Phá Vỡ, hiệu ứng/buff~~ (Phase 5).
- ~~Kỹ năng dạng danh sách hiệu ứng, Đặc tính, Tinh Mệnh, nhân vật thật, trọng số bị nhắm~~ (Phase 6).
- AI quái theo tình huống, báo trước đòn mạnh (Phase 8).
- Máu giữ nguyên giữa các trận, cấp từng nhân vật (Phase 9). Hiện mọi nhân vật lấy cấp đội, vào trận đầy máu và nửa năng lượng.
- ~~EXP/vật phẩm thắng trận thật~~ (Phase 10).
- Cắt cảnh Tuyệt kỹ 2D có tranh nhân vật, đổi màu nền theo nguyên tố (Phase 13; hiện là băng rôn chữ).
- Hiện kỹ năng của quái là dữ liệu tạm cho 3 quái mẫu (Phase 8 làm đủ).

## Phase 5 – Nguyên tố, khiên, phá vỡ, hiệu ứng

### Đã làm

- `Element` (7 nguyên tố, màu đúng bảng mục 6). Nguyên tố của nhân vật/quái/Đòn Mở Màn đổi từ chuỗi sang enum. Màu dùng cho viền quái, biểu tượng điểm yếu, viền số sát thương.
- Quái có 1–3 điểm yếu (`EnemyData.weaknesses`), Khiên Điểm Yếu (`max_toughness`), kháng mặc định 20% (`default_res`), đúng điểm yếu 0%. Biểu tượng điểm yếu dưới thanh máu, thanh khiên màu trắng (xám + "Phá Vỡ" khi vỡ).
- `BreakSystem` + `data/config/break_config.tres`: chỉ đòn đúng điểm yếu mới giảm khiên (`SkillData.toughness_damage`); khiên về 0 → sát thương phá vỡ (theo Hiệu Ứng Phá Vỡ, cấp, nguyên tố, độ dày khiên), trì hoãn 25%, gắn hiệu ứng theo nguyên tố; khiên hồi đầy đầu lượt kế tiếp của quái; hệ số phá vỡ 0,9 / 1,0 nối với trạng thái khiên thật.
- 7 hiệu ứng phá vỡ đúng bảng (`data/status_effects/`): Thiêu Đốt, Đóng Băng (mất lượt, tan thì thêm sát thương Nước), Điện Giật, Phong Cắt (cộng dồn 5), Nhiễm Độc (% máu tối đa có trần, −10% Phòng Thủ), Trói Rễ (+20% trì hoãn, đòn kế tiếp thêm sát thương Mộc), Giam Hồn (+30% trì hoãn, −10% Tốc Độ 1 lượt).
- Hệ thống hiệu ứng dạng dữ liệu (`StatusEffectData`, `StatusEffectInstance`, `StatusEffects`): buff/debuff có số lượt, cộng dồn (làm mới / cộng tầng), điều chỉnh chỉ số, tỉ lệ trúng = gốc × (1 + Chính Xác) × (1 − Kháng), sát thương theo lượt, mất lượt, trì hoãn thêm, kích hoạt khi bị đánh. Biểu tượng dưới thanh máu (viền xanh = buff, đỏ = debuff, số tầng), rê chuột hoặc chạm để xem mô tả.
- Bộ điều khiển trận xử lý đầu lượt (hồi khiên, sát thương theo lượt, mất lượt) và cuối lượt (trừ số lượt).
- Ưu Thế: Đòn Mở Màn đúng điểm yếu → quái mất 25% khiên khi vào trận (map truyền nguyên tố Đòn Mở Màn vào trận).
- Phòng thử trận `scenes/battle/sandbox/battle_sandbox.tscn` (mở thẳng, hoặc menu tạm dừng → "Phòng thử trận" ở bản debug): 2 bù nhìn yếu cả 7 nguyên tố + 1 bù nhìn chỉ yếu Lửa, chọn nguyên tố đòn đánh của cả đội, nút hồi khiên + hồi đội.
- Lớp test cơ sở bắt mọi lỗi engine/script và tính là thất bại (trước đây lỗi trong hàm await làm test bỏ dở lặng lẽ).
- Test `tests/phase05_test.tscn`: 63/63 đạt (từng nguyên tố, đủ 7 hiệu ứng phá vỡ, tỉ lệ trúng giả lập 10.000 lần: 50,0% so với kỳ vọng 50,4%). Test Phase 1–4 vẫn đạt.

### File chính

- `systems/{element,status_effects,status_effect_instance,break_system}.gd`, `systems/resources/{status_effect_data,stat_modifier_data,break_config}.gd`
- `data/status_effects/*.tres`, `data/config/break_config.tres`, `data/enemies/training_dummy*.tres`, `data/encounters/sandbox_dummies.tres`
- Sửa: `scenes/battle/{battle_unit,skill_executor,battle_controller,battle_scene}.gd`, `scenes/battle/ui/{unit_view,damage_number_pool}.gd`
- `scenes/battle/sandbox/battle_sandbox.*`, `tests/phase05_test.*`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 5.

### Việc còn nợ

- ~~Kỹ năng gắn hiệu ứng và Đặc tính~~ (Phase 6). `test_atk_up`, `test_def_down` chỉ để test.
- Quái gắn hiệu ứng lên phe ta (Phase 8).
- Cân bằng số liệu phá vỡ cùng báo cáo boss (Phase 8, 14).
- Biểu tượng điểm yếu/hiệu ứng thật (Phase 13; đang là ô màu + chữ).

## Phase 6 – Hệ thống kỹ năng, nhân vật chính và 4 nhân vật miễn phí

### Đã làm

- `SkillData` dạng danh sách hiệu ứng ghép (`systems/skill_effects/`): `DamageEffect` (theo chỉ số, hệ số chính/bên cạnh, giảm khiên), `HealEffect` (theo chỉ số người hồi hoặc % máu mục tiêu), `ShieldEffect`, `ApplyStatusEffect` (buff/debuff, khiêu khích), `TurnShiftEffect` (kéo/đẩy lượt), `EnergyEffect`, `SkillPointEffect`, `CleanseEffect`; phạm vi: mục tiêu / chính / bên cạnh / bản thân / cả đội / đồng đội khác / toàn bộ quái. Đánh thường, Chiến kỹ, Tuyệt kỹ, đòn phụ đều là SkillData. Tuyệt kỹ có thể có 2 chế độ (`alternate`).
- `SkillContext`: mọi sát thương/hồi máu/khiên (của kỹ năng và Đặc tính) đi chung một đường, có móc `before_damage`/`after_damage`/`before_heal`/`skill_resolved` để Đặc tính sửa số tại chỗ. Khiên chặn sát thương trước máu.
- `TalentScript`: lớp cơ sở cho Đặc tính, gắn vào EventBus (lọc theo trận) và móc của BattleController. Tinh Mệnh 1–6 bật theo cấp Tinh Mệnh (`GameState.eidolon_levels`): phần tăng số khai báo trong `EidolonData`, phần cơ chế trong TalentScript (`has_eidolon(n)`). Đòn phụ / phản công (`request_follow_up`) không tốn lượt. Có hồi sinh (`revive`).
- Vận mệnh (`CharacterPath`) + trọng số bị nhắm đúng bảng mục 6; AI quái chọn mục tiêu theo trọng số × (1 + AGGRO), Khiêu Khích bắt đòn đơn/lan nhắm người khiêu khích.
- Kỹ năng ngoài map: Đòn Mở Màn của người dẫn đầu (nguyên tố, hồi chiêu, tầm, độ rộng quạt riêng) đánh quái + mở vật cản; Bí Kỹ tốn Điểm Bí Kỹ dùng chung (tối đa 5; Hộp Bí Kỹ +1, phòng nghỉ hồi đầy). 3 kiểu Bí Kỹ: trận kế tiếp (Mira, Garren), tác động quái trên map (Kiri: choáng + đánh dấu), tiện ích khám phá (Lữ khách: lướt xuyên rào Ma Biến; Nyx: tàng hình).
- 7 vật cản nguyên tố + rào Ma Biến (`ElementalObstacle`): dây leo, tường lửa, cửa máy, sương mù, cổng gỉ, khe vực (mọc cầu), tường nứt (lối ẩn). Lưu "đã mở" trong map_states. Phòng giải đố mới `room_puzzle_01` (8 hốc, mỗi hốc 1 vật cản + rương) nối phía Nam phòng nghỉ.
- Đổi người dẫn đầu bằng phím 1–4 hoặc chạm chân dung trên thanh đội (HUD góc trái dưới, có Điểm Bí Kỹ và Bí Kỹ đang chờ trận sau). Nút cảm ứng Bí Kỹ.
- 5 nhân vật thật (Lữ khách theo mẫu mục 7, Mira, Kiri, Garren, Nyx): 2 kỹ năng ngoài map, 3 kỹ năng trận, Đặc tính, 6 Tinh Mệnh, chỉ số cấp 1/30 (`docs/CHARACTERS.md`). Dữ liệu sinh bằng `tools/data_builder/build_characters.py`; thay toàn bộ dữ liệu tạm Phase 4.
- Màn trận: Tuyệt kỹ 2 chế độ (Q để đổi), hiện khiên / năng lượng / Điểm Chiến Kỹ / giải hiệu ứng / hồi sinh, thanh khiên trên thẻ nhân vật.
- Phòng thử trận: chọn đúng 4 trong 5 nhân vật + cấp Tinh Mệnh, "Áp dụng" để đánh lại. Menu tạm dừng (debug): "Đổi đội thử".
- Test `tests/phase06_test.tscn`: 77/77 đạt. Test Phase 1–5 vẫn đạt (Phase 2 cập nhật số phòng = 5).

### File chính

- `systems/skill_effects/*.gd`, `systems/character_path.gd`, `systems/resources/{skill_data,talent_data,eidolon_data,technique_data}.gd`
- `scenes/battle/{skill_context,talent_script}.gd`, sửa `battle_controller`, `skill_executor`, `battle_unit`, `battle_scene`, `ui/*`
- `data/characters/*.tres`, `data/characters/scripts/*_talent.gd`, `data/skills/*.tres`, `data/status_effects/*.tres`
- `scenes/overworld/interactables/elemental_obstacle.*`, `scenes/overworld/rooms/room_puzzle_01.tscn`, `scenes/ui/hud/team_bar.gd`
- `tools/data_builder/build_characters.py`, `tests/phase06_test.*`, `docs/CHARACTERS.md`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 6.

### Việc còn nợ

- Sương mù (Phong) và Cổng gỉ (Độc) chưa có nhân vật mở được trong đội miễn phí (Phase 7 có nhân vật gacha; test đang dùng Đòn Mở Màn giả lập).
- 20 nhân vật còn lại, cân bằng 5★/4★, phòng thử chọn quái/cấp (Phase 7).
- Cấp kỹ năng (Phase 9); hiện Tinh Mệnh 3/5 là +15% hệ số thay cho "+2 cấp kỹ năng".
- Nhận nhân vật theo cốt truyện, Tinh Mệnh nhân vật chính theo Mảnh Hồn (Phase 12); nhân vật trùng (Phase 11). Hiện cả 5 nhân vật có sẵn, Tinh Mệnh chỉnh trong phòng thử.
- Máu giữ giữa các trận để Bí Kỹ hồi máu có nghĩa (Phase 9).
- Quái gắn hiệu ứng lên phe ta, đòn phụ của quái (Phase 8).

## Phase 7 – 20 nhân vật còn lại

### Bước A – Thiết kế (xong, chờ duyệt)

- Thiết kế 8 nhân vật 5★ và 12 nhân vật 4★ trong `tools/data_builder/roster_design.py` (nguồn duy nhất), sinh vào `docs/CHARACTERS.md` bằng `tools/data_builder/write_character_doc.py`. Mỗi người: tiểu sử, tính cách, ngoại hình (bảng màu + dáng bóng đen), Đòn Mở Màn, Bí Kỹ, 3 kỹ năng trận, Đặc tính, 6 Tinh Mệnh, chỉ số cấp 1 / cấp 30.
- Bảng tổng hợp 25 nhân vật cuối file. Script tự kiểm: 25 cơ chế Đặc tính không trùng, Bí Kỹ 24 nhân vật chia đều 8/8/8, nguyên tố/vận mệnh/hạng khớp mục 8.
- Cơ chế mới cần code ở bước B: tự tiêu máu (Ignar), chia sát thương (Marisol), dấu chuyển mục tiêu (Raiko), kéo lượt dây chuyền (Zephyra), lan độc khi chết (Vesper), vật triệu hồi (Sylvaine), tiêu thêm Điểm Chiến Kỹ (Orrin), đổi tư thế (Celestine), hút máu từ sát thương theo lượt (Quill), đỡ đòn thay (Aldric), báo thù (Rook), đòn phụ lên quái Phá Vỡ (Fenna), chuỗi Chiến kỹ (Kestrel), tăng theo số debuff (Vael), debuff thành trì hoãn (Wisp), cộng hưởng nguyên tố (Selka), nổ lan khi hạ quái (Ember), bảo hiểm bạo kích (Neris), sạc năng lượng (Pip), nhân bản debuff (Echo). Bí Kỹ mới trên map: lao để lại vệt, bắn tên, sương ngủ, rễ trói, bẫy, bom, mưa tro, lướt xa qua khe vực, hút vật phẩm, hiện rương ẩn / quái trên bản đồ nhỏ, về phòng nghỉ.

### Bước B – Code (xong)

- Dữ liệu 20 nhân vật sinh bằng `tools/data_builder/build_roster.py` (tên/mô tả lấy từ `roster_design.py`, số liệu kỹ năng khai báo trong builder), theo 4 nhóm 5 người; mỗi nhóm có test riêng trước khi sang nhóm sau. Chữ trong game ở `localization/roster.csv` (sinh tự động; cột tiếng Anh tạm dùng lại tiếng Việt).
- 20 TalentScript trong `data/characters/scripts/` (Đặc tính + Tinh Mệnh có cơ chế riêng). Tinh Mệnh 3/5 là +15% hệ số (EidolonData), Wisp E1 là +20% Chính Xác Hiệu Ứng.
- Lõi mới: vật triệu hồi (`BattleController.add_summon`, không chiếm chỗ nhân vật, quái không nhắm), móc `before_hit` (chia / đỡ sát thương), `status_applied`, `dot_damage`, `hp_consumed`; thay kỹ năng tạm thời (`BattleUnit.skill_overrides` – tư thế, Chiến kỹ cường hóa); đếm lần dùng mỗi trận (`try_use`); hiệu ứng ghép mới: tự tiêu máu, hồi sinh, triệu hồi, mất % máu tối đa, trừ % khiên; phạm vi FIRST_ENEMY, RANDOM_ENEMY. Bí Kỹ áp trước khi Đặc tính nhận `battle_began`.
- Bí Kỹ mới trên map: lao để lại vệt đánh dấu, bắn tên choáng, vùng choáng/đánh dấu (sương ngủ, rễ trói, bom, mưa tro), bẫy (luôn Ưu Thế), tăng tốc, hiện rương ẩn / quái trên bản đồ nhỏ, hút Hộp Bí Kỹ, lướt xa qua khe vực (lớp va chạm PIT), hồi máu cả đội (chờ Phase 9), về phòng nghỉ gần nhất.
- Phòng thử trận: bảng "Đội & quái…" chọn đúng 4 trong 25 nhân vật, trận quái bất kỳ trong `data/encounters`, cấp đội, cấp Tinh Mệnh.
- Báo cáo cân bằng `tools/balance/balance_report.tscn` → `docs/BALANCE_REPORT.md`: 10 lượt mỗi nhân vật, cấp 30, 8 seed, cùng đội hỗ trợ (chỉ đánh thường), cùng 3 Quái Thử Sức. Sau 8 lượt chỉnh số, cả 8 nhân vật 5★ mạnh hơn trung bình 4★ cùng vận mệnh 17–24%.
- Test `tests/phase07_test.tscn` (chạy theo nhóm: `-- --groups=1,2`): với mỗi nhân vật kiểm đủ kỹ năng, chữ dịch, 3 kỹ năng trận, 1 trận Tự Động trọn vẹn ở Tinh Mệnh 6 có Bí Kỹ, làm người dẫn đầu và dùng Bí Kỹ ngoài map; cộng kiểm tra riêng cho từng Đặc tính.

### File chính

- `tools/data_builder/{roster_design,build_roster,write_character_doc}.py`, `tools/balance/balance_report.*`
- `data/characters/*.tres` (25), `data/characters/scripts/*_talent.gd` (25), `data/skills/*`, `data/status_effects/*`
- `systems/skill_effects/{hp_cost,revive,summon,max_hp_damage,toughness_damage}_effect.gd`
- Sửa: `scenes/battle/{battle_controller,battle_unit,skill_context,talent_script,battle_scene}.gd`, `scenes/battle/ui/unit_view.gd`, `scenes/battle/sandbox/battle_sandbox.gd`, `scenes/overworld/map/overworld_map.gd`, `scenes/overworld/player/player.gd`, `scenes/ui/hud/minimap.gd`
- `docs/CHARACTERS.md`, `docs/BALANCE_REPORT.md`, `tests/phase07_test.*`

### Việc còn nợ

- Bản tiếng Anh của chữ 20 nhân vật (đang dùng lại tiếng Việt).
- Hình thật, biểu tượng (Phase 13). Vật triệu hồi đang là hình thoi.
- Sở hữu nhân vật qua gacha (Phase 11); hiện mọi nhân vật dùng được trong phòng thử, đội trên map đổi bằng phòng thử hoặc "Đổi đội thử".
- Bí Kỹ Túi Thuốc chưa hồi thật (Phase 9 giữ máu giữa các trận). Tiếng Vọng Về đang về phòng nghỉ gần nhất; dịch chuyển nhanh giữa các phòng nghỉ làm ở Phase 12.
- Cân bằng lại cùng boss ở Phase 8 và lần cuối ở Phase 14.

## Phase 8 – Quái thường, tinh anh và boss

### Đã làm

- **AI quái:** `EnemyAction` (kỹ năng, trọng số, điều kiện máu/hồi chiêu/số lần/số quái cùng họ/chỗ trống/hiệu ứng trên phe ta/tầng hiệu ứng của bản thân, ưu tiên, trọng số theo tình huống, cách chọn mục tiêu). `EnemyAI` viết lại. Đòn mạnh báo trước 1 lượt (tích tụ) hoặc đếm ngược nhiều lượt; ngắt bằng phá khiên hoặc đủ sát thương.
- **8 quái thường × 2–3 biến thể nguyên tố** (19 biến thể + 2 Ong Thợ): Mầm Ma Biến (nổ khi chết), Hồn Ảnh (khiên cho đồng minh), Giáp Sĩ Rỉ Sét (khiên dày, Thủ Thế), Xạ Thủ Hư Không (Ngắm → bắn xuyên ×2), Pháp Sư Méo (Bỏng/Độc/Gió Cắt), Chuột Mực Sách (trộm Điểm Chiến Kỹ), Bầy Ong Độc (còn 1 thì gọi tổ), Bóng Gương (sao chép buff).
- **3 tinh anh:** Kỵ Sĩ Vỡ Vụn (tích tụ rồi lao, phá khiên thì hủy), Mẫu Thể Ma Biến (cứ 2 lượt gọi Mầm, khiên theo số Mầm), Thủ Thư Câm (Phong Ấn Chiến kỹ 2 lượt).
- **4 boss nhiều giai đoạn:** Người Gác Thư Viện (Sách Bay; ≤ 50% đọc Lời Nguyền đếm ngược 3 lượt → cả đội bị Phong Ấn), Cự Thú Kho Chứa (Đông Cứng; ≤ 50% Băng Vỡ: tăng tốc, đánh lan), Lõi Lò Biến Dạng (tích Nhiệt, Quá Nhiệt nổ cả đội, phá khiên −3 tầng, 2 tay máy), Kẻ Nuốt Mảnh Hồn (hút buff; ≤ 66% tách 3 phân thân; GĐ3 xóa Điểm Chiến Kỹ, Nuốt Hồn ngắt bằng sát thương). Mỗi boss đổi điểm yếu giữa giai đoạn, luôn có điểm yếu thuộc đội miễn phí, nhạc riêng từng giai đoạn (nhạc tạm sinh bằng code), đoạn chuyển giai đoạn 2D.
- **Lõi trận:** sàn máu theo giai đoạn, `enter_boss_phase`, quái gọi thêm giữa đợt (`spawn_enemy`, giới hạn 5), kỹ năng khi chết, quái không bị nhắm được, `EnemyBehavior` (script cơ chế riêng, số liệu trong `behavior_params`), hiệu ứng ghép mới: gọi quái, sao chép/hút buff, gỡ hiệu ứng; Phong Ấn (`seal_skill`); trộm Điểm Chiến Kỹ.
- **Mức Khó cho boss** (`DifficultyConfig`), bật bằng payload `hard_mode` / ô "Boss khó" trong phòng thử.
- **35 EncounterData theo khu** (`data/encounters/<khu>_*.tres`, có `zone`, `kind`, `recommended_level`): Thư Viện cấp 1–8, Kho Băng 8–16, Lò 16–24, Đỉnh Tháp 24–30; mỗi khu 6–7 trận thường, 1–3 tinh anh, 1 boss. Bảng tổng hợp ở `docs/ENEMIES.md`.
- **Giao diện trận:** bảng cảnh báo "!" + tên đòn + số lượt trên quái đang tích tụ, vòng đỏ trên người sắp trúng, dòng nhắc cách ngắt; boss/tinh anh vẽ to hơn, thanh máu có vạch ngưỡng giai đoạn, nhãn giai đoạn; quái không bị nhắm được thì mờ; xếp quái theo bề rộng khi có quái mới; số bay cho trộm điểm, sao chép/hút buff, Nhiệt, ngắt đòn.
- **Phòng thử:** danh sách trận ghi loại (★ boss, ◆ tinh anh), cấp quái và cấp khuyến nghị; chọn đội 4 người + trận + cấp + Tinh Mệnh + Boss khó.
- **Mô phỏng boss** `tools/balance/boss_report.tscn` → `docs/BOSS_REPORT.md` (đội miễn phí, cấp khuyến nghị, Tự Động, 40 seed; thêm bảng trận thường/tinh anh). Có chế độ in diễn biến một trận (`--trace`).
- Test `tests/phase08_test.tscn`: 72/72 đạt. Test Phase 1–7 vẫn đạt.

### Kết quả mô phỏng boss (Tự Động, Tinh Mệnh 0)

| Boss | Cấp đội | Đội | Thắng | Lượt ta | Máu còn | Khó: thắng |
| --- | --- | --- | --- | --- | --- | --- |
| Người Gác Thư Viện | 10 | Lữ khách, Kiri, Garren, Nyx | 100% | 41 | 57% | 52% |
| Cự Thú Kho Chứa | 18 | Lữ khách, Kiri, Garren, Nyx | 100% | 43 | 55% | 30% |
| Lõi Lò Biến Dạng | 26 | Lữ khách, Mira, Kiri, Garren | 98% | 53 | 83% | 57% |
| Kẻ Nuốt Mảnh Hồn | 30 | Lữ khách, Mira, Kiri, Nyx | 95% | 63 | 74% | 0% |

### File chính

- `systems/resources/{enemy_action,boss_phase_data,difficulty_config}.gd`, sửa `enemy_data.gd`, `encounter_data.gd`, `status_effect_data.gd`
- `systems/enemy_ai.gd`, `systems/placeholder_music.gd`, `systems/skill_effects/{summon_enemy,buff_transfer,remove_status}_effect.gd`, sửa `skill_point_effect.gd`, `apply_status_effect.gd`, `auto_battle.gd`, `break_system.gd`
- `scenes/battle/enemy_behavior.gd`, sửa `battle_controller.gd`, `battle_unit.gd`, `skill_executor.gd`, `battle_scene.gd`, `ui/unit_view.gd`, `sandbox/battle_sandbox.gd`; `autoload/audio_manager.gd` (phát nhạc)
- `data/enemies/*.tres` (33 mới), `data/enemies/scripts/*_behavior.gd`, `data/skills/en_*.tres`, `data/status_effects/en_*.tres`, `data/encounters/{library,vault,furnace,tower}_*.tres`, `data/config/boss_hard_mode.tres`
- `tools/data_builder/build_enemies.py` (sinh toàn bộ dữ liệu quái + `localization/enemies.csv` + `docs/ENEMIES.md`), `tools/balance/boss_report.*`
- `docs/ENEMIES.md`, `docs/BOSS_REPORT.md`, `tests/phase08_test.*`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 8.

### Việc còn nợ

- ~~Phần thưởng mức Khó, rơi đồ theo trận~~ (Phase 10). Đặt EncounterData lên map, quái hồi lại khi rời khu, cảnh mở boss (Phase 12).
- Trùm cuối mức Khó: đội miễn phí Tinh Mệnh 0 cấp 30 chưa thắng được (0%) – dành cho đội đã nâng kỹ năng/Tinh Mệnh (Phase 9); cân lại ở Phase 14.
- Trận thường khá nhẹ (đội còn ~90% máu) vì máu chưa giữ giữa các trận; cân lại khi Phase 9 giữ máu.
- Hình quái/boss thật, hiệu ứng đòn (Phase 13); nhạc thật (Phase 14). Chữ tiếng Anh của quái đã có, nhưng mô tả kỹ năng quái chưa hiện trong giao diện (chỉ hiện tên đòn và dòng nhắc).

## Phase 9 – Tiến trình nhân vật (giới hạn cấp 30)

### Đã làm

- **Cấp 1–30** bằng Ký Ức Mảnh Hồn 3 bậc (100/500/2000 EXP), bảng EXP từng cấp (có sẵn tới 80), giới hạn ở `GameConfig.MAX_LEVEL`.
- **Đột phá** ở cấp 10 và 20 (Xu Aether + Tinh Thể đúng nguyên tố); mốc 30–70 có dữ liệu nhưng khóa.
- **Nâng kỹ năng** Đánh thường / Chiến kỹ / Tuyệt kỹ / Đặc tính tới cấp 5 (Xu + Dấu Ấn đúng vận mệnh, cấp 5 cần Lõi Ma Biến); giới hạn cấp kỹ năng mở theo đột phá. Cấp kỹ năng đổi số liệu trong trận (hệ số ×1,0–1,4, buff/debuff ×1,0–1,2).
- **Cây vận mệnh** cho 7 vận mệnh: 6 nút chỉ số nhỏ + 3 nút bị động lớn, mở theo đột phá; chỉ số và bị động áp vào trận.
- **Tinh Mệnh:** nhận nhân vật trùng (`GameState.grant_character`, sẵn cho Phase 11), nhân vật chính mở theo cờ cốt truyện `soul_shard_1..6`.
- **Máu giữ giữa các trận;** phòng nghỉ hồi đầy; Bí Kỹ Túi Thuốc (Quill) hồi 25% thật; thua thì về phòng nghỉ máu đầy; thanh đội ngoài map có thanh máu.
- **Túi đồ** (38 loại vật phẩm, 7 thẻ: tiền tệ, kinh nghiệm, đột phá, Dấu Ấn, nâng cấp, Ước Nguyện, tiêu hao; Hộp Bí Kỹ dùng được).
- **Giao diện** (menu tạm dừng → Nhân vật / Đội hình / Túi đồ): danh sách nhân vật lọc theo nguyên tố, vận mệnh, hạng; chi tiết nhân vật 4 thẻ (Chỉ số + lên cấp + đột phá, Kỹ năng, Tinh Mệnh, Cây vận mệnh) với chi phí đủ/thiếu; màn đội hình 4 ô, 5 đội hình lưu sẵn.
- **Lệnh debug** cộng tài nguyên (menu tạm dừng, túi đồ). Save lên v2 có chuyển đổi save cũ.
- Test `tests/phase09_test.tscn`: 61/61 đạt. Test Phase 1–8 vẫn đạt.

### Bảng chi phí (chi tiết: `docs/PROGRESSION.md`)

| Hạng mục | Chi phí |
| --- | --- |
| Lên cấp 1 → 30 | 50.750 EXP (≈ 25 Ký Ức bậc 3) + 5.075 Xu |
| Đột phá cấp 10 / 20 | 4.000 Xu + 4 Tinh Thể / 12.000 Xu + 10 Tinh Thể |
| Kỹ năng cấp 2 / 3 / 4 / 5 (mỗi kỹ năng) | 1.500 Xu + 3 Dấu Ấn bậc 1 / 4.000 + 2 bậc 2 / 8.000 + 4 bậc 2 / 16.000 + 3 bậc 3 + 1 Lõi Ma Biến |
| Cây vận mệnh (đủ 9 nút) | 54.000 Xu + Dấu Ấn bậc 1/2/3 |
| **Tổng 1 nhân vật tối đa** | **50.750 EXP, ~193.000 Xu, 14 Tinh Thể, Dấu Ấn 19/32/20 (bậc 1/2/3), 4 Lõi Ma Biến** |

### File chính

- `systems/progression.gd`, `systems/resources/{item_data,progression_config,ascension_data,skill_level_cost,trace_node_data,trace_tree_data}.gd`
- `scenes/battle/trace_passives.gd`; sửa `battle_controller.gd` (`ally_states`), `battle_unit.gd` (cấp kỹ năng), `skill_context.gd`, `battle_scene.gd` (giữ máu), `systems/status_effects.gd` + `status_effect_instance.gd` (độ mạnh hiệu ứng), `apply_status_effect.gd`, `break_system.gd`
- `scenes/ui/menu/game_menu.gd`, `scenes/ui/character_list/`, `scenes/ui/character_detail/`, `scenes/ui/team/`, `scenes/ui/inventory/`, `scenes/ui/common/ui_kit.gd`; sửa `pause_menu.gd`, `hud/team_bar.gd`, `hud/overworld_hud.gd`
- `autoload/game_state.gd` (túi đồ, tiến trình, máu, đội hình), `save_manager.gd` (v2), `event_bus.gd`; sửa `overworld_map.gd`, `overworld_enemy.gd`, `rest_point.gd`, `technique_data.gd`
- `data/items/*.tres` (38), `data/config/progression.tres`, `data/progression/traces/*.tres` (7), `localization/progression.csv`
- `tools/data_builder/build_progression.py`, `docs/PROGRESSION.md`, `tests/phase09_test.*`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 9.

### Việc còn nợ

- ~~Nguồn tài nguyên (rơi đồ, rương, nhiệm vụ)~~ (Phase 10, chi phí Xu/Dấu Ấn/Lõi đã cân lại – xem mục Phase 10).
- Mô tả kỹ năng trong màn chi tiết vẫn ghi số cấp 1 (hệ số theo cấp hiện bằng dòng "×%").
- Cân bằng boss Phase 8 tính ở kỹ năng cấp 1, chưa có cây vận mệnh → khi người chơi nâng kỹ năng, boss sẽ dễ hơn; cân lại ở Phase 14.
- Năng lượng chưa giữ giữa các trận (luôn vào trận 50%).
- Hình chân dung thật (Phase 13).

## Phase 10 – Tài nguyên, rơi đồ, nhiệm vụ ngày và tuần

### Đã làm

- **Vật phẩm:** đủ 38 ItemData cho mọi tài nguyên mục 11 (có từ Phase 9, test kiểm lại).
- **Rơi đồ** (`systems/loot.gd`, `LootTable` + `LootEntry`): bảng quái thường / tinh anh / boss đúng mục 11, cộng theo từng con; thưởng lần hạ đầu (tinh anh 20 Lệ Tinh, boss 100 Lệ Tinh + 1 Lõi Ma Biến, theo trận); boss nhận đủ thưởng 3 lần mỗi ngày rồi chỉ cho Xu; mức Khó nguyên liệu ×2 + 2 Lõi; rương thường / quý / giải đố theo khu (5/10/20 Lệ Tinh + Xu + Ký Ức, rương quý/giải đố thêm Tinh Thể theo đội). Dấu Ấn rơi theo vận mệnh của đội đang dùng. Thắng trận thật, thắng ngay, mở rương đều cộng vào túi đồ và hiện phần thưởng; xóa `PlaceholderRewards`.
- **Hồi quái:** quái thường + boss hồi khi rời khu, tinh anh hồi mỗi ngày (`GameState.record_defeat / respawn_zone / respawn_daily`, `Room.zone`, `OverworldMap.zone`).
- **Bảng chi phí** lên cấp 1–30, đột phá, kỹ năng tới cấp 5 vẫn ở `data/config/progression.tres` (sinh bằng `build_progression.py`); chi phí Xu / Dấu Ấn / Lõi cân lại theo báo cáo kinh tế.
- **QuestManager + QuestData/QuestConfig** (`data/quests/quest_config.tres`): 6 nhiệm vụ ngày (500 Hoạt Động), 5 mốc 10/15/20/25/30 Lệ Tinh + Xu + Ký Ức + 1 Hộp Bí Kỹ, làm mới 4:00 giờ máy, chỉ mở sau cờ `chapter_1_complete`; 3 nhiệm vụ tuần (160 Lệ Tinh + 1 Vé Giới Hạn + 1 Vé Thường), làm mới thứ Hai 4:00; 15 thành tựu (800 Lệ Tinh); khám phá 100% mỗi khu (160 Lệ Tinh); quà đăng nhập 7 ngày (10 Vé Thường); thưởng mỗi chương (400 Lệ Tinh + 5 Vé Thường + 3 Vé Giới Hạn) theo cờ `chapter_<n>_complete`. Chống chỉnh giờ lùi. Nhận thưởng tự lưu. Save lên v3.
- **Màn nhiệm vụ** (menu tạm dừng → Nhiệm vụ, hoặc thẻ trong menu nhân vật): thẻ Ngày / Tuần / Thành tựu / Người mới, thời gian tới lần làm mới, nút Nhận, chấm đỏ trên thẻ/nút/menu, dòng nhắc đỏ trên HUD; thông báo nhỏ khi xong nhiệm vụ.
- **Kế hoạch 4 khu** (`data/zones/`) + **mô hình kinh tế** (`data/config/economy_model.tres`), sinh bằng `tools/data_builder/build_economy.py`.
- **Báo cáo kinh tế** `systems/economy_report.gd` (+ `.tscn`) → `docs/ECONOMY_REPORT.md`: lượt quay một lần / mỗi tháng / theo banner, tài nguyên toàn bản đồ so với chi phí 4–5 nhân vật, nhịp cốt truyện theo cấp khuyến nghị boss, kiểm tra dữ liệu. Kết quả: ĐẠT.
- Test `tests/phase10_test.tscn`: 78/78 đạt. Test Phase 1–9 vẫn đạt.

### Kết quả báo cáo kinh tế (tóm tắt)

| Hạng mục | Kết quả | Mục tiêu |
| --- | --- | --- |
| Lượt quay một lần | 78,0 (cốt truyện 42, người mới 20, thành tựu + khám phá 9, boss/tinh anh/rương 7) | 78 |
| Lượt quay mỗi tháng từ nhiệm vụ | 31,6 (ngày 18,8 + tuần 12,9) + tối đa 10 từ cửa hàng | 32 + 10 |
| Banner giới hạn | một lần 48 lượt, mỗi tháng 27,4 → chắc chắn Celestine sau 4,8 tháng | 4–5 tháng |
| Nhân vật nâng tối đa được (nút thắt Dấu Ấn bậc 2) | 4,15 (EXP 5,39 · Xu 4,52 · Dấu Ấn 5,27/4,15/4,44 · Lõi 5,00) | 4–5 |
| Nhịp cốt truyện (EXP so với 4 người lên cấp khuyến nghị) | 1,45 / 1,16 / 0,97 / 1,08; Tinh Thể đủ đột phá cho 5 nguyên tố đội miễn phí | ≥ 0,9 |

### Chi phí 1 nhân vật sau khi cân lại

| Hạng mục | Chi phí |
| --- | --- |
| Lên cấp 1 → 30 | 50.750 EXP + 5.075 Xu |
| Đột phá cấp 10 / 20 | 4.000 Xu + 4 Tinh Thể / 12.000 Xu + 10 Tinh Thể |
| Kỹ năng cấp 2 / 3 / 4 / 5 (mỗi kỹ năng) | 800 Xu + 2 Dấu Ấn bậc 1 / 2.000 + 1 bậc 2 / 4.000 + 1 bậc 2 / 6.000 + 2 bậc 3 + 1 Lõi Ma Biến |
| **Tổng 1 nhân vật tối đa** | **50.750 EXP, ~97.400 Xu, 14 Tinh Thể, Dấu Ấn 15/13/9, 4 Lõi Ma Biến** |

### File chính

- `systems/loot.gd`, `systems/economy_report.{gd,tscn}`, `systems/resources/{loot_entry,loot_table,zone_data,economy_model,quest_data,quest_config}.gd`
- `autoload/quest_manager.gd` (viết đầy đủ), sửa `game_state.gd` (loot_state, hồi quái), `event_bus.gd` (`encounter_cleared`, `reward_popup_requested`), `save_manager.gd` (v3)
- `scenes/ui/quests/quest_screen.gd`; sửa `menu/game_menu.gd`, `pause/pause_menu.gd`, `hud/overworld_hud.gd`, `common/ui_kit.gd` (chấm đỏ)
- Sửa `scenes/battle/battle_scene.gd` (thưởng trận), `scenes/overworld/map/overworld_map.gd` (thắng ngay, hồi quái, khám phá), `rooms/room.gd` (khu), `interactables/chest.gd` (thưởng rương)
- `data/loot_tables/{enemies,chests}/*.tres`, `data/zones/*.tres`, `data/config/economy_model.tres`, `data/quests/quest_config.tres`, `data/config/progression.tres`, `data/progression/traces/*.tres`, `localization/economy.csv`
- `tools/data_builder/build_economy.py`, sửa `build_progression.py`; `docs/ECONOMY_REPORT.md`, `docs/PROGRESSION.md`; `tests/phase10_test.*`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 10.

### Việc còn nợ

- ~~Dựng map đúng `data/zones/*.tres`, cờ `chapter_<n>_complete`, bảng chọn mức Khó khi đánh lại boss~~ (Phase 12).
- ~~Quà mở Gacha 10 Vé Giới Hạn, cửa hàng Bụi Sao~~ (Phase 11). Ký Ức/Xu 3★ từ gacha chưa cộng vào báo cáo kinh tế (ước tính ở DESIGN_NOTES Phase 11 mục 4).
- Hồi quái khi rời khu áp ở lần nạp map kế tiếp, chưa hồi ngay trước mắt người chơi.
- Biểu tượng vật phẩm thật (Phase 13); chữ tiếng Anh của nhiệm vụ đã có, mô tả vật phẩm giữ như Phase 9.
- Cân lại cùng boss khi người chơi đã nâng kỹ năng (Phase 14); chạy lại báo cáo kinh tế sau mỗi lần đổi dữ liệu.

## Phase 11 – Gacha 2 banner và cửa hàng Bụi Sao

### Đã làm

- **BannerData** (`data/banners/`): banner thường "Ước Nguyện Vĩnh Hằng" (7 nhân vật 5★ thường, 16 nhân vật 4★, chọn 1 nhân vật 5★ sau 300 lượt, một lần) và banner giới hạn "Tiếng Gọi Của Nhãn" (Celestine 50/50 + bảo đảm; 3 nhân vật 4★ nổi bật Pip, Echo, Neris với 50/50 + bảo đảm). Tỉ lệ, bảo hiểm, nhóm nhân vật, vật phẩm 3★, vé đều nằm trong file banner. `GachaConfig` giữ danh sách banner đang mở, 160 Lệ Tinh/vé, Bụi Sao khi trùng, cửa hàng.
- **GachaManager** viết đầy đủ: 5★ 0,6% → +6%/lượt từ lượt 74 → chắc chắn lượt 90; 4★ 5,1%, chắc chắn 4★+ mỗi 10 lượt; còn lại Ký Ức bậc 2 hoặc 600 Xu. Bộ đếm theo nhóm bảo hiểm (`pity_group`), nên banner giới hạn sau kế thừa bộ đếm + trạng thái 50/50. `roll()` là hàm thuần dùng chung cho game và giả lập.
- **Vé:** Vé Thường chỉ banner thường, Vé Giới Hạn chỉ banner giới hạn; thiếu vé thì hỏi đổi 160 Lệ Tinh/vé phần còn thiếu.
- **Trùng nhân vật:** lần 1–6 mở Tinh Mệnh 1–6, từ lần 7 đổi thành Bụi Sao (+100 / +20); mỗi lần trùng +40 (5★) / +8 (4★) Bụi Sao. Nhân vật mới vào danh sách sở hữu, dùng được ở màn đội hình.
- **Cửa hàng Bụi Sao:** 20 Bụi Sao/vé, mỗi tháng tối đa 5 Vé Thường + 5 Vé Giới Hạn, làm mới 4:00 ngày 1 (dùng kỳ ngày chống chỉnh giờ của QuestManager).
- **Quà mở Gacha:** 10 Vé Giới Hạn khi cờ `chapter_1_complete` bật (một lần; save cũ đã qua Chương 1 nhận bù khi tải).
- **Lưu:** bộ đếm, 50/50, tổng lượt, lịch sử 100 lượt mỗi banner, quà chọn 5★, cửa hàng, seed + state RNG. Quay/mua xong tự lưu. Save lên v4.
- **Màn Gacha** (menu tạm dừng → Ước Nguyện, hoặc thẻ trong menu nhân vật): tranh banner tạm, nút Quay 1 / Quay 10, bộ đếm bảo hiểm + 50/50 + tiến độ 300 lượt, bảng bên phải Tỉ lệ / Lịch sử / Cửa hàng / Chọn 5★, ví tiền. Kết quả: sao băng 2D màu theo hạng (xanh 3★, tím 4★, vàng 5★, lóe màu hạng cao nhất) → màn nhận nhân vật 4★+ có tranh gacha (MỚI / Tinh Mệnh / Bụi Sao, báo lệch 50/50) → tổng kết; "Bỏ qua" tới thẳng tổng kết. Bản debug có nút mở khóa (bật cờ Chương 1) và nút cộng tài nguyên có thêm Lệ Tinh, Bụi Sao.
- Test `tests/phase11_test.tscn`: 130/130 đạt (chỉ giả lập: `-- --sim-only`). Test Phase 1–10 vẫn đạt (Phase 10 sửa kiểm tra số phiên bản save thành ≥ 3).

### Kết quả giả lập (1.000.000 lượt mỗi banner, ≈ 4 giây/banner)

| Banner | 5★ | Lượt trung bình / 5★ | Không 5★ dài nhất | 4★ | Không 4★+ dài nhất |
| --- | --- | --- | --- | --- | --- |
| Ước Nguyện Vĩnh Hằng | 1,616% | 61,9 | 87 | 11,72% | 10 |
| Tiếng Gọi Của Nhãn | 1,600% | 62,5 | 87 | 11,73% | 10 |

Banner giới hạn: Celestine 1,067% mỗi lượt (66,6% số 5★, trung bình 93,8 lượt / Celestine), hai lần Celestine cách nhau tối đa 167 lượt (≤ 180); 4★ nổi bật 66,7% số 4★; lệch 50/50 thì lần 5★ sau luôn là Celestine.

### File chính

- `systems/resources/{banner_data,gacha_config}.gd`, `data/banners/{standard,limited_celestine,gacha_config}.tres`
- `autoload/gacha_manager.gd` (viết đầy đủ); sửa `game_state.gd` (reset gacha), `save_manager.gd` (v4), `quest_manager.gd` (`day_start_unix` công khai)
- `scenes/ui/gacha/{gacha_screen,gacha_pull_overlay,gacha_art}.gd`; sửa `scenes/ui/menu/game_menu.gd`, `scenes/ui/pause/pause_menu.gd`
- `systems/resources/character_skin.gd` (`gacha_art`), `systems/progression.gd` (debug cộng Lệ Tinh/Bụi Sao)
- `localization/gacha.csv`, `project.godot`; `tests/phase11_test.*`, sửa `tests/phase10_test.gd`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 11.

### Việc còn nợ

- ~~Nhân vật miễn phí nhận theo cốt truyện~~ (Phase 12). Map thử vẫn không có cờ Chương 1 → nút mở khóa debug trên màn Gacha vẫn giữ.
- Tranh banner, tranh gacha, hiệu ứng sao băng thật (Phase 13; hiện vẽ khối màu, gắn qua `BannerData.art`, `CharacterSkin.gacha_art`). Âm thanh quay (Phase 14).
- Cửa hàng Bụi Sao chỉ bán vé (theo phase); mục 11 có ghi Bụi Sao đổi Tinh Thể – thêm dòng `shop_entries` khi cần, mô tả vật phẩm Bụi Sao đang nhắc Tinh Thể.
- Báo cáo kinh tế chưa cộng Ký Ức/Xu từ 3★ gacha (≈ 18.000 EXP + 22.000 Xu cho 78 lượt).
- Trùng nhân vật cũng tính là "nâng cấp nhân vật" cho nhiệm vụ ngày (dùng chung tín hiệu `character_upgraded`).

## Phase 12 – Bản đồ Pháo Đài Vọng Tinh và cốt truyện

### Đã làm

- **Bản đồ:** Sảnh Trung Tâm + 4 khu, mỗi khu một scene (`scenes/overworld/world/`), sinh bằng `tools/level_builder/build_world.gd`. Thư Viện 11 phòng, Kho Chứa 10, Lò 10, Đỉnh Tháp 12: phòng nghỉ (lối vào + trước boss), chiến đấu, rương, giải đố (4 hốc), tinh anh, boss. Trận, rương, Hộp Bí Kỹ đặt đúng kế hoạch khu Phase 10 (báo cáo kinh tế mục F khớp 100%). Mỗi khu tô màu riêng.
- **Sảnh Trung Tâm:** phòng y tế (nơi tỉnh dậy), sảnh chính có ông Orwen, Lio, Bram, điểm nghỉ, bàn Ước Nguyện, bảng nhiệm vụ, bàn nâng cấp, bàn đội hình, quầy hàng; Sân Tập (quái hướng dẫn); phòng Cổng Dịch Chuyển tới các khu đã mở.
- **Giải đố:** cổng nguyên tố chắn cửa trên đường chính chỉ dùng nguyên tố đội miễn phí có ở thời điểm đó; hốc giải đố mỗi khu có 2 rương ẩn cần nhân vật gacha (Sương mù / Cổng gỉ); tường nứt (Hồn) dẫn tới phòng phụ.
- **Hội thoại JSON** (37 cảnh, 184 câu) sinh bằng `tools/data_builder/build_story.py`: người nói, chân dung + biểu cảm, câu thoại, lựa chọn, sự kiện. **Hộp thoại**: chữ chạy, bấm để hiện hết / sang câu, lựa chọn, Bỏ qua (tới lựa chọn kế tiếp), Lịch sử; tạm dừng game khi thoại.
- **Cốt truyện Mở đầu → Chương 4** (mỗi chương 4–5 cảnh chính): tỉnh dậy + Mira gia nhập, Sân Tập, gặp Orwen; Thư Viện – Kiri gia nhập, tìm sơ đồ, boss, Mảnh Hồn 1 + ảo ảnh Celestine; Kho Chứa – Garren (đóng băng) gia nhập, đội đủ 4, boss, Mảnh Hồn 2; Lò – Nyx gia nhập mang bản ghi kẻ trộm, boss, Mảnh Hồn 3; Đỉnh Tháp – Celestine báo trước, đối đầu Kẻ Nuốt Mảnh Hồn (bạn cũ), Mảnh Hồn 4, vết nứt mở ra vùng đất mới (còn tiếp).
- **StoryManager** (autoload mới): cờ cốt truyện điều khiển mở khu, mở Gacha + nhiệm vụ ngày sau Chương 1, thưởng chương, Tinh Mệnh nhân vật chính, nhận nhân vật miễn phí; NPC chọn cảnh theo cờ; điểm kích hoạt khi vào map / vào vùng / nhặt vật; cảnh sau trận boss.
- **Nhiệm vụ** ở góc trái HUD (chính màu vàng, phụ màu xanh, ghi tên khu nếu ở nơi khác) + **mũi tên chỉ đường** quanh người chơi. **2 nhiệm vụ phụ**: Nhật Ký Người Gác (Lio, sau Chương 2 → Tinh Mệnh 5), Tiếng Vọng Trong Lò (Bram, sau Chương 3 → Tinh Mệnh 6).
- **Dịch chuyển nhanh** giữa Sảnh và mọi phòng nghỉ đã mở (điểm nghỉ hồi đầy + tự lưu + mở bảng dịch chuyển).
- **Thêm:** hồi quái thường + boss khi vào lại khu; hỏi mức Thường / Khó khi đánh lại boss; quầy hàng bằng Xu (Ký Ức, Hộp Bí Kỹ, giới hạn ngày); nhân vật gia nhập ở cấp trung bình của đội; sửa BattleController không lỗi khi rời trận giữa chừng.
- Game mới: tạo nhân vật → Sảnh Trung Tâm (chỉ có nhân vật chính). "Tiếp tục" không có map → Sảnh.
- Test `tests/phase12_test.tscn`: 109/109 đạt. Test Phase 1–11 vẫn đạt (Phase 1 sửa: tạo nhân vật xong vào Sảnh; Phase 11 sửa một kiểm tra phụ thuộc may rủi Bụi Sao).

### Sơ đồ phòng

Ký hiệu: `=X=` cổng nguyên tố trên cửa (cần nguyên tố X), ★ boss, ◆ tinh anh, ♥ phòng nghỉ, $ rương, ? giải đố (hốc: nguyên tố cần).

```text
SẢNH TRUNG TÂM
                [H03 Cổng Dịch Chuyển]—[H01 Sảnh chính: Orwen, Lio, Bram, ♥, các quầy]—[H02 Sân Tập (quái hướng dẫn)]
                                                    |
                                          [H04 Phòng y tế (bắt đầu)]

THƯ VIỆN CÂM LẶNG (Chương 1, cấp 1–8)
            [L03 $ quý×2]                       [L07 $ quý×2 + thường, nhật ký NV phụ 1]
                 |                                   =Hồn=
[L01 ♥]—[L02 3 nhóm]=Nước=[L04 3 nhóm, Kiri]=Lửa=[L06 3 nhóm]—[L08 3 nhóm]—[L10 ♥ sơ đồ]—[L11 ★ Người Gác]
                                  |                              |
                     [L05 ? Nước/Lửa/Phong/Độc]       [L09 ◆ Thủ Thư + 2 nhóm]

KHO CHỨA BĂNG GIÁ (Chương 2, cấp 8–16)
                                          [V06 ? Mộc/Nước/Phong/Độc]
                                                 |
[V01 ♥]—[V02 3 nhóm]—[V04 3 nhóm, Garren]=Mộc=[V05 3 nhóm]—[V07 3 nhóm]—[V09 ♥ $]—[V10 ★ Cự Thú]
            =Lửa=                                                |
       [V03 $ quý×2 + thường]                          [V08 ◆ Kỵ Sĩ, $ quý×2]

LÒ NĂNG LƯỢNG (Chương 3, cấp 16–24)
       [F03 $ quý×2 + thường]                 [F06 ? Sét/Mộc/Phong/Độc]
            =Mộc=                                    |
[F01 ♥]—[F02 3 nhóm]—[F04 3 nhóm, Nyx]=Sét=[F05 3 nhóm]—[F07 3 nhóm]—[F09 ♥ $]—[F10 ★ Lõi Lò]
                                                             |
                                          [F08 ◆ Mẫu Thể, $ quý×2, lõi NV phụ 2]

ĐỈNH THÁP QUAN SÁT (Chương 4, cấp 24–30)
       [T03 $ quý×2 + thường]              [T08 ◆ Thủ Thư, $ quý×2]
            =Nước=                                |
[T01 ♥]—[T02 3 nhóm]=Sét=[T04 3 nhóm]=Mộc=[T07 3 nhóm]—[T09 3 nhóm]—[T11 ♥ Celestine]—[T12 ★ Kẻ Nuốt Mảnh Hồn]
                              |                           |
                     [T05 ◆ Kỵ Sĩ]—[T06 ? Lửa/Hồn/Phong/Độc]  [T10 ◆ Mẫu Thể]
```

### File chính

- `autoload/story_manager.gd` (mới), sửa `game_state.gd` (dịch chuyển nhanh, quầy hàng), `project.godot` (autoload, file dịch)
- `scenes/ui/dialogue_box/dialogue_box.gd`, `scenes/ui/travel/travel_menu.gd`, `scenes/ui/shop/shop_screen.gd`; sửa `scenes/ui/hud/overworld_hud.gd` (nhiệm vụ, bảng phủ), `pause/pause_menu.gd`, `title/title_screen.gd`, `character_select/character_select.gd`
- `scenes/overworld/interactables/{npc,station,story_trigger,story_item,story_gate}.gd`; sửa `rest_point.gd`, `scenes/overworld/map/overworld_map.gd`, `scenes/battle/battle_controller.gd`
- `scenes/overworld/world/{hub,library,vault,furnace,tower}.tscn`, `tools/level_builder/build_world.{gd,tscn}`
- `tools/data_builder/build_story.py` → `data/dialogue/*.json`, `data/story/story.json`, `localization/story.csv`; `localization/world.csv`
- `data/encounters/prologue_tutorial.tres`, `systems/resources/shop_data.gd`, `data/shop/hub_shop.tres`, `systems/data_paths.gd`
- Sửa `systems/economy_report.gd` (mục F) → `docs/ECONOMY_REPORT.md`; `tests/phase12_test.*`, sửa `tests/phase01_smoke_test.gd`, `tests/phase11_test.gd`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 12.

### Việc còn nợ

- Chữ tiếng Anh của cốt truyện (đang dùng lại tiếng Việt); chân dung, biểu cảm, tranh khu vực thật (Phase 13); nhạc từng khu (Phase 14).
- Phòng dựng từ khối chữ nhật của builder, chưa có trang trí / bố cục riêng từng phòng (Phase 13 vẽ tileset từng khu).
- Map thử `test_map.tscn` vẫn giữ cho test cũ và lối debug.
- Chưa chơi tay trọn 4 chương; test kiểm tra không kẹt bằng đồ thị phòng + cổng và chạy cốt truyện bằng logic, cân bằng boss dựa trên mô phỏng Phase 8 (cân lại ở Phase 14).
- Nyx gia nhập khi đội đã đủ 4 → người chơi tự đổi đội ở menu để mở cửa máy.
- Cảnh cắt (camera di chuyển, nhân vật đi lại trong cảnh) chưa có; cảnh chỉ là hộp thoại.

## Phase 13 – Đồ họa 2D với Blender và Krita

### Đã làm

- **Bảng thông số hình** `art_specs/` (45 file, sinh bằng `tools/data_builder/build_art_specs.py`): nhân vật chính 2 skin, 24 nhân vật, 18 họ quái / boss (biến thể nguyên tố, boss mỗi giai đoạn), NPC, tileset. Mỗi file: mã màu, dáng bóng đen, trang phục, vũ khí / động tác kỹ năng, bảng hoạt ảnh + số khung, kích thước, tên file.
- **Yêu cầu hình dùng chung** `data/config/art_requirements.json` (128 px map 8 hướng, 512 px trận, quái 256 / 384 / 768, chân dung 1024 × 3 biểu cảm, tranh 2048×1152, hiệu ứng 512 px, ô 64 px).
- **Blender** (`tools/blender/`): `make_sample_blend.py` tạo nhân vật mẫu có rig + Action idle / run / attack; `render_sprites.py` – camera trực giao, ánh sáng cố định, shader hoạt hình (Shader to RGB + Color Ramp), viền Solidify lật pháp tuyến, map 8 hướng / trận 3/4, ghép sprite sheet + JSON (khung, điểm neo, fps). Đã chạy thật trên Blender 5.2: mẫu render cho Mira (map 16 hoạt ảnh, trận idle + attack).
- **Krita**: `docs/KRITA_PIPELINE.md` – canvas, lớp, chân dung 3 biểu cảm, tranh gacha, hiệu ứng bằng Animation Docker, xuất chuỗi PNG, tileset, quy tắc đặt tên.
- **Công cụ nhập** `tools/import_assets/` (cảnh chạy dòng lệnh + EditorScript): đọc sheet Blender và từng khung theo tên, tạo SpriteFrames, tạo TileSet khu, in + ghi `docs/ASSET_STATUS.md` (đã nhận / thiếu khung / còn thiếu – hiện 262 mục).
- **Game tự nhận hình** (`systems/art_library.gd`): người chơi và quái ngoài map (AnimatedSprite2D 8 hướng: đứng / chạy / lướt / Đòn Mở Màn), nhân vật và quái trong trận (idle / attack / skill / ultimate / hit / down / victory, boss theo giai đoạn), chân dung hội thoại và danh sách nhân vật, tranh gacha + cắt cảnh Tuyệt kỹ, tileset khu. Thiếu thì giữ hình tạm.
- **Shader dùng chung**: `unit_fx` (viền khi chọn mục tiêu, nháy trắng khi trúng đòn, tan biến khi quái ngã), `ultimate_bg` (nền đổi màu nguyên tố khi dùng Tuyệt kỹ).
- **Hiệu ứng kỹ năng tạm** `SkillVfx`: GPUParticles2D màu nguyên tố khi trúng đòn, tự thay bằng hoạt ảnh Krita `vfx_<id>_<attack|skill|ultimate>` nếu có.
- Test `tests/phase13_test.tscn`: 34/34 đạt. Test Phase 1–12 vẫn đạt.

### Hướng dẫn nhanh

1. Dựng `.blend` theo `tools/blender/README.md` → `blender -b ignar.blend -P tools/blender/render_sprites.py -- --character ignar --mode map` (và `--mode battle`).
2. Vẽ chân dung / tranh / hiệu ứng / tileset trong Krita theo `docs/KRITA_PIPELINE.md`, xuất PNG đúng tên vào `assets/...`.
3. Mở editor (hoặc `godot --headless --path . --import`) rồi chạy `tools/import_assets` → xem `docs/ASSET_STATUS.md`.

### File chính

- `systems/art_library.gd`, `data/config/art_requirements.json`
- `tools/blender/{make_sample_blend.py,render_sprites.py,README.md,sample_character.blend,.gdignore}`
- `tools/import_assets/{asset_importer.gd,import_assets.gd,import_assets.tscn,import_assets_editor.gd}`
- `tools/data_builder/build_art_specs.py` → `art_specs/*.md`; `docs/KRITA_PIPELINE.md`, `docs/ASSET_STATUS.md`
- `assets/vfx/shaders/{unit_fx,ultimate_bg}.gdshader`, `scenes/battle/ui/skill_vfx.gd`
- `assets/characters/mira/{map,battle}/` (hình mẫu Blender)
- Sửa: `scenes/overworld/player/player.gd`, `overworld_enemy/overworld_enemy.gd`, `map/overworld_map.gd` (tileset), `scenes/battle/ui/unit_view.gd`, `battle_scene.gd`, `scenes/ui/dialogue_box/dialogue_box.gd`, `common/ui_kit.gd`, `gacha/gacha_art.gd`, `autoload/story_manager.gd`
- `tests/phase13_test.*`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 13.

### Việc còn nợ

- Toàn bộ hình thật (262 mục trong `docs/ASSET_STATUS.md`) – phần việc vẽ / dựng của anh/chị.
- Hình mẫu đang gắn cho Mira chỉ để thử pipeline; xóa khi có hình thật.
- Hoạt ảnh Bí Kỹ (`technique`) và lướt ngoài map đã nhận tên nhưng game chỉ phát `dash` khi lướt và `opener` khi chém; Bí Kỹ chưa có lúc phát riêng.
- Vật triệu hồi, vật tương tác trên map (rương, NPC, quầy, cổng) vẫn vẽ tạm; chưa có quy ước asset cho chúng.
- Cắt cảnh Tuyệt kỹ mới là tranh trượt qua + nền shader, chưa có hoạt ảnh camera.

## Phase 14 – Hoàn thiện và xuất bản

### Đã làm

- **Lưu / tải:** ô tự lưu (phòng nghỉ, tạo nhân vật, nhận thưởng, quay gacha) + 3 ô lưu tay; màn Lưu / Tải (menu tạm dừng → Lưu / Tải; màn tiêu đề → Tải game) hiện tên, chương, khu, giờ chơi, cấp đội, thời điểm lưu; lưu đè / tải / xóa có xác nhận; Bắt đầu mới hỏi trước khi ghi đè ô tự lưu. Save v5 (thêm tóm tắt), tự nâng save v1–v4, file hỏng báo rõ. Giờ chơi chỉ đếm khi ở map / trận.
- **Âm thanh:** AudioManager bus Tổng / Nhạc / Hiệu ứng / Giọng; nhạc tiêu đề + 5 khu + trận + boss từng giai đoạn, chuyển chéo bằng 2 máy phát; 20 hiệu ứng (nút, trúng đòn, bạo kích, phá khiên, hồi máu, Tuyệt kỹ, thắng / thua, lướt, chém, rương, cửa, nghỉ, Bí Kỹ, lên cấp, gacha 3★/4★/5★) qua pool 10 máy phát. Tổng hợp bằng code từ `data/audio/*.json`, file thật trong `assets/audio/` được ưu tiên. Nguồn ghi ở `docs/CREDITS.md`.
- **Cài đặt** (3 thẻ): âm lượng 4 bus; toàn màn hình, độ phân giải cửa sổ, tốc độ chữ (lời dẫn + hội thoại), ngôn ngữ Việt / Anh; bật joystick ảo, gán lại 15 phím, khôi phục mặc định. Lưu theo máy.
- **Cảm ứng:** thêm nút ☰ Menu; kiểm tra giao diện ở 2400×1080 (tỉ lệ điện thoại).
- **Cân bằng cuối:** báo cáo kinh tế ĐẠT; mô phỏng boss thêm bảng "đội đã nâng" – không cần đổi dữ liệu (xem dưới).
- **Dọn TODO** (không còn TODO trong code), sửa nhãn nhắc nhiệm vụ bị cắt ở màn rộng.
- **Xuất bản:** `export_presets.cfg` (Windows, Linux, Android), `docs/BUILD.md`, chế độ `--self-check` cho bản build.
- Test `tests/phase14_test.tscn`: 44/44 đạt. Test Phase 1–13 vẫn đạt.

### Kết quả cuối

| Hạng mục | Kết quả |
| --- | --- |
| Báo cáo kinh tế (`docs/ECONOMY_REPORT.md`) | ĐẠT: 78 lượt quay một lần, ~32 + 10 lượt/tháng, Celestine chắc chắn sau ~4,8 tháng, đủ nâng tối đa 4,15 nhân vật, bản đồ khớp kế hoạch khu |
| Boss, đội miễn phí cấp khuyến nghị, chưa nâng | 100% / 100% / 98% / 95% thắng (Thư Viện / Kho Chứa / Lò / Trùm cuối) |
| Boss mức Khó, đội đã nâng tối đa theo cấp | 100% / 95% / 100% / 92% thắng |
| Bản build | `build/windows/Aethelgard.exe` (+ `Aethelgard.console.exe`), `build/linux/Aethelgard.x86_64`; tự kiểm tra bản Linux 14/14 đạt (cấp 30, đội 4, cốt truyện tới hết Chương 4, 1 trận thật, lưu / tải) |

### File chính

- `autoload/save_manager.gd` (v5, tóm tắt, đọc an toàn), `scenes/ui/save/save_slots_panel.gd`, sửa `scenes/ui/title/title_screen.gd`, `scenes/ui/pause/pause_menu.gd`, `scenes/ui/common/ui_kit.gd` (hộp xác nhận)
- `autoload/audio_manager.gd`, `systems/placeholder_sfx.gd`, sửa `systems/placeholder_music.gd`; `data/audio/{music,sfx}.json`; gắn âm thanh ở `battle_scene.gd`, `player.gd`, `room.gd`, `chest.gd`, `rest_point.gd`, `overworld_map.gd`, `gacha_pull_overlay.gd`
- `systems/user_settings.gd` (hiển thị, chữ, phím), `scenes/ui/settings/settings_panel.gd`, sửa `dialogue_box.gd`, `intro.gd`, `scenes/ui/touch/touch_controls.gd`, `autoload/game_state.gd`
- `tools/balance/boss_report.gd` (đội đã nâng) → `docs/BOSS_REPORT.md`; `docs/ECONOMY_REPORT.md`
- `systems/build_check.gd`, `export_presets.cfg`, `docs/BUILD.md`, `docs/CREDITS.md`
- `localization/world.csv`, `tests/phase14_test.*`

### Quyết định quan trọng

Xem `docs/DESIGN_NOTES.md` mục Phase 14.

## Để sau

### Lỗi / giới hạn đã biết

- Bản Windows chưa chạy thử trên máy Windows thật (máy build là Linux, không có Wine); bản Linux chính thức không mở được cửa sổ trên NixOS (thiếu thư viện X11/Wayland ngoài môi trường FHS) – tự kiểm tra headless đạt. Cần chơi thử tay trọn 4 chương trên Windows.
- APK Android chưa build (máy chưa có Android SDK / JDK / keystore) – preset đã sẵn, hướng dẫn ở `docs/BUILD.md`.
- Toàn bộ hình thật còn thiếu (262 mục, `docs/ASSET_STATUS.md`); Mira đang dùng hình mẫu Blender.
- Chữ tiếng Anh của cốt truyện và 20 nhân vật đang dùng lại tiếng Việt.
- Nyx gia nhập khi đội đã đủ 4: người chơi phải tự đổi đội để mở cửa máy.
- Cắt cảnh Tuyệt kỹ / cốt truyện chưa có chuyển động camera; rương, NPC, quầy, cổng, vật triệu hồi chưa có quy ước hình.
- Gacha ra nhân vật trùng cũng tính là "nâng cấp nhân vật" cho nhiệm vụ ngày.
- Báo cáo kinh tế chưa cộng Ký Ức / Xu từ vật phẩm 3★ của gacha.

### Đề xuất cho bản cập nhật sau

1. **Nâng giới hạn cấp lên 40–50:** đổi `GameConfig.MAX_LEVEL`; bảng EXP và mốc đột phá 30–70 đã có sẵn trong `data/config/progression.tres` (tự mở khi giới hạn vượt mốc). Thêm Tinh Thể bậc mới + Dấu Ấn bậc 4 cho kỹ năng cấp 6–8; chạy lại báo cáo kinh tế và mô phỏng boss.
2. **Bản đồ mới bên kia vết nứt** (móc nối kết Chương 4): thêm khu vào `tools/level_builder/build_world.gd` + `data/zones/<khu>.tres` + quái cấp 30–40 bằng `build_enemies.py`, Chương 5 trong `build_story.py` (cờ `zone_<khu>_open`, Cổng Dịch Chuyển tự nhận). Mảnh Hồn thứ 7+ cho nhân vật chính (Tinh Mệnh mở rộng).
3. **Banner giới hạn mới:** thêm `data/banners/limited_<id>.tres` cùng `pity_group = limited` (bộ đếm + bảo đảm 50/50 tự kế thừa) và đổi danh sách `banners` trong `data/banners/gacha_config.tres`; nhân vật 5★ mới qua `roster_design.py` / `build_roster.py`. Có thể thêm banner rerun Celestine.
4. Lồng tiếng (bus Giọng đã có), nhạc thật thay nhạc tổng hợp, cửa hàng Bụi Sao bán Tinh Thể, tranh cắt cảnh động.
