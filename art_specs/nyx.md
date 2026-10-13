# Nyx

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `nyx` |
| Hạng · nguyên tố · vận mệnh | 4★ · Sét · Hư Vô |
| Màu nguyên tố (viền, hiệu ứng) | `#A65BF2` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** tím điện #A65BF2, đen, bạc; găng tay cuộn dây đồng, kính bảo hộ đẩy lên trán; bóng đen nhận ra nhờ chiếc ăng-ten cong trên mũ và đuôi dây cáp.
- **Tính cách (biểu cảm, tư thế):** Lạnh lùng, châm chọc, cực kỳ thông minh; ghét bị gọi là "nhóc".
- **Tiểu sử:** Kỹ sư trẻ trực Lò Năng Lượng, biết mọi đường dây trong pháo đài. Khi lò biến dạng, cô trốn trong ống dẫn và theo dõi kẻ đánh cắp Mảnh Hồn. Gia nhập ở Chương 3, mang theo bản ghi về kẻ đó.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Cú Chích Điện*; Bí Kỹ *Màn Tĩnh Điện (khám phá)*; Đánh thường *Cú Chích*; Chiến kỹ *Mạch Rò Rỉ*; Tuyệt kỹ *Bão Từ (110)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_nyx_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_nyx_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_nyx_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_nyx.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_nyx_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_nyx_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_nyx_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/nyx/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character nyx --mode map` và `--mode battle` → tự sinh `map/map_nyx.png/.json`, `battle/battle_nyx.png/.json`.
- Hoặc từng khung (Krita): `map/map_nyx_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_nyx_<hành động>_<khung>.png`.
