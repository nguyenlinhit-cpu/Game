# Garren

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `garren` |
| Hạng · nguyên tố · vận mệnh | 4★ · Mộc · Bảo Hộ |
| Màu nguyên tố (viền, hiệu ứng) | `#2E8B57` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** xanh rừng #2E8B57, nâu gỗ, đồng; khiên tròn lớn bằng gỗ; bóng đen nhận ra nhờ vai giáp mọc cành và tấm khiên to bằng nửa người.
- **Tính cách (biểu cảm, tư thế):** Nghiêm, ít nói, che chở; thỉnh thoảng kể chuyện cũ không ai hỏi.
- **Tiểu sử:** Đội trưởng đội cận vệ già của pháo đài, đóng băng cùng lính trong Kho Chứa khi giữ chân Cự Thú. Áo giáp của ông mọc rễ từ hạt giống cây sao cổ thụ, cứng hơn cả thép. Được cứu ở Chương 2 và nhận Lữ khách làm "lính mới".
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Rễ Trồi*; Bí Kỹ *Tường Rễ (trận kế tiếp)*; Đánh thường *Đập Khiên*; Chiến kỹ *Khiên Cổ Thụ*; Tuyệt kỹ *Tường Rừng (120)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_garren_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_garren_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_garren_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_garren.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_garren_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_garren_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_garren_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/garren/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character garren --mode map` và `--mode battle` → tự sinh `map/map_garren.png/.json`, `battle/battle_garren.png/.json`.
- Hoặc từng khung (Krita): `map/map_garren_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_garren_<hành động>_<khung>.png`.
