# Ember

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `ember` |
| Hạng · nguyên tố · vận mệnh | 4★ · Lửa · Tri Thức |
| Màu nguyên tố (viền, hiệu ứng) | `#E8552B` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Đỏ cam #E8552B, vàng, xám tro, trắng. Bóng đen: mái tóc xù như ngọn lửa, cuốn sách phép cháy sém mép.
- **Tính cách (biểu cảm, tư thế):** Bốc đồng, vui vẻ, liều lĩnh; xin lỗi rất nhiều sau mỗi vụ nổ.
- **Tiểu sử:** Học viên lò luyện phép lửa của Lò Năng Lượng, nổi tiếng vì làm nổ ba phòng thí nghiệm. Ma Biến cuối cùng cũng cho cô một mục tiêu đáng để cho nổ. Ember muốn chứng minh phép của mình không chỉ để phá hoại.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Đốm Lửa*; Bí Kỹ *Mưa Tro (tác động quái trên map)*; Đánh thường *Cầu Lửa Nhỏ*; Chiến kỹ *Biển Lửa*; Tuyệt kỹ *Sao Băng Lửa (120)*.

## Ngoài map (Blender) – 128×128 px/khung, 8 hướng (e, se, s, sw, w, nw, n, ne)

| Hành động | Số khung | Ghi chú |
| --- | --- | --- |
| `idle` | 4 | đứng thở nhẹ, lặp |
| `run` | 8 | chạy, lặp; chân chạm đất ở khung 0 và giữa chu kỳ |
| `dash` | 4 | lướt nhanh, người đổ về trước, vạt áo bay |
| `opener` | 6 | Đòn Mở Màn – vung vũ khí theo hướng nhìn, khung 2–3 là lúc trúng |
| `technique` | 6 | Bí Kỹ – tư thế dùng kỹ năng ngoài map |

## Trong trận (Blender + Krita sửa nét) – 512×512 px/khung, nghiêng 3/4 quay sang phải

| Hành động | Số khung | Ghi chú |
| --- | --- | --- |
| `idle` | 6 | đứng thủ thế, lặp |
| `attack` | 8 | Đánh thường – khung trúng khoảng 50% |
| `skill` | 10 | Chiến kỹ |
| `ultimate` | 12 | Tuyệt kỹ – động tác lớn nhất, giữ dáng cuối 2 khung |
| `hit` | 4 | bị đánh, giật lùi |
| `down` | 6 | ngã, giữ khung cuối |
| `victory` | 8 | ăn mừng khi thắng, lặp |

## Krita

| Hình | Kích thước | File |
| --- | --- | --- |
| Chân dung neutral | 1024×1024 | `portrait/portrait_ember_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_ember_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_ember_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_ember.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_ember_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_ember_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_ember_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/ember/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character ember --mode map` và `--mode battle` → tự sinh `map/map_ember.png/.json`, `battle/battle_ember.png/.json`.
- Hoặc từng khung (Krita): `map/map_ember_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_ember_<hành động>_<khung>.png`.
