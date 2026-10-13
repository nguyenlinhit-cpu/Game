# Orrin

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `orrin` |
| Hạng · nguyên tố · vận mệnh | 5★ · Hồn · Tri Thức |
| Màu nguyên tố (viền, hiệu ứng) | `#F2D58A` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Vàng hồn #F2D58A, nâu da thuộc, xanh đêm, trắng giấy. Bóng đen: lưng hơi gù, chồng sách bay lơ lửng quanh vai, mũ chóp mềm.
- **Tính cách (biểu cảm, tư thế):** Uyên bác, hay quên, nói vòng vo; nghiêm khắc khi có người làm hỏng sách.
- **Tiểu sử:** Thủ thư trưởng của Thư Viện Câm Lặng, người ghi chép mọi vì sao từng quan sát. Ông đọc được chữ viết trong Mảnh Hồn và dùng chúng như trang sách phép. Orrin tin rằng câu trả lời cho thảm họa nằm trong một cuốn sách đã bị xé mất.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Trang Sách Bay*; Bí Kỹ *Mắt Thư Tịch (tiện ích khám phá)*; Đánh thường *Chữ Hồn*; Chiến kỹ *Chương Hồn*; Tuyệt kỹ *Thư Tịch Khai Mở (120)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_orrin_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_orrin_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_orrin_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_orrin.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_orrin_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_orrin_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_orrin_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/orrin/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character orrin --mode map` và `--mode battle` → tự sinh `map/map_orrin.png/.json`, `battle/battle_orrin.png/.json`.
- Hoặc từng khung (Krita): `map/map_orrin_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_orrin_<hành động>_<khung>.png`.
