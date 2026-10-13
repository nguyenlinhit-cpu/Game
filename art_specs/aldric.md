# Aldric

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `aldric` |
| Hạng · nguyên tố · vận mệnh | 4★ · Phong · Bảo Hộ |
| Màu nguyên tố (viền, hiệu ứng) | `#4FD1B5` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Xanh ngọc #4FD1B5, xám thép, đỏ sẫm, trắng. Bóng đen: khiên buồm hình cánh diều, áo choàng ngắn rách mép.
- **Tính cách (biểu cảm, tư thế):** Trầm, kỷ luật, hay càu nhàu; luôn đứng trước người khác.
- **Tiểu sử:** Lính gác cổng gió lâu năm, từng đứng chắn cửa một mình suốt ba ngày khi Ma Biến tràn lên. Ông dùng tấm khiên buồm để bắt gió và lao tới che chắn trong chớp mắt. Aldric giữ lời hứa với Garren là bảo vệ thế hệ lính mới.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Khiên Gió Đập*; Bí Kỹ *Bức Tường Gió (lợi thế trận kế tiếp)*; Đánh thường *Đâm Khiên*; Chiến kỹ *Tấm Khiên Buồm*; Tuyệt kỹ *Gió Bão Che Thân (120)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_aldric_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_aldric_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_aldric_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_aldric.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_aldric_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_aldric_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_aldric_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/aldric/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character aldric --mode map` và `--mode battle` → tự sinh `map/map_aldric.png/.json`, `battle/battle_aldric.png/.json`.
- Hoặc từng khung (Krita): `map/map_aldric_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_aldric_<hành động>_<khung>.png`.
