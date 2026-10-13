# Wisp

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `wisp` |
| Hạng · nguyên tố · vận mệnh | 4★ · Phong · Hư Vô |
| Màu nguyên tố (viền, hiệu ứng) | `#4FD1B5` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Xanh ngọc nhạt #4FD1B5, trắng sương, tím nhạt, bạc. Bóng đen: thân nhỏ trôi lơ lửng, đuôi như làn khói xoắn.
- **Tính cách (biểu cảm, tư thế):** Rụt rè, tò mò, thích sưu tầm đồ lấp lánh; nói thì thầm.
- **Tiểu sử:** Một linh hồn nhỏ sinh ra từ gió trong Kho Chứa, không nhớ mình từng là ai. Wisp thì thầm vào tai quái những lời làm chúng quên mất phải làm gì. Cậu đi cùng Lữ khách vì cả hai đều đang tìm ký ức của mình.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Hơi Thở Lạnh*; Bí Kỹ *Gió Hút (tiện ích khám phá)*; Đánh thường *Gió Rít*; Chiến kỹ *Lời Quên Lãng*; Tuyệt kỹ *Cơn Gió Câm (110)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_wisp_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_wisp_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_wisp_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_wisp.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_wisp_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_wisp_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_wisp_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/wisp/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character wisp --mode map` và `--mode battle` → tự sinh `map/map_wisp.png/.json`, `battle/battle_wisp.png/.json`.
- Hoặc từng khung (Krita): `map/map_wisp_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_wisp_<hành động>_<khung>.png`.
