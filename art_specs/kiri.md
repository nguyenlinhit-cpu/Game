# Kiri

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `kiri` |
| Hạng · nguyên tố · vận mệnh | 4★ · Lửa · Hòa Hợp |
| Màu nguyên tố (viền, hiệu ứng) | `#E8552B` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** cam lửa #E8552B, vàng, đỏ thẫm; túi pháo đeo chéo; bóng đen nhận ra nhờ hai bím tóc dựng như ngòi pháo.
- **Tính cách (biểu cảm, tư thế):** Sôi nổi, lạc quan, hơi liều; thích đặt biệt danh cho mọi người.
- **Tiểu sử:** Thợ pháo hoa của lễ hội ngắm sao mỗi năm ở pháo đài, kẹt trong Thư Viện Câm Lặng khi đang tìm sách công thức pháo. Cô tin rằng ánh sáng có thể xua Ma Biến và dùng pháo hoa để tiếp sức cho đồng đội. Gia nhập ở Chương 1 sau khi được cứu khỏi đám sách bay.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Tia Lửa*; Bí Kỹ *Pháo Hoa Mồi (quái trên map)*; Đánh thường *Tia Lửa*; Chiến kỹ *Thổi Bùng*; Tuyệt kỹ *Pháo Hoa Rực Rỡ (110)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_kiri_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_kiri_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_kiri_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_kiri.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_kiri_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_kiri_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_kiri_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/kiri/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character kiri --mode map` và `--mode battle` → tự sinh `map/map_kiri.png/.json`, `battle/battle_kiri.png/.json`.
- Hoặc từng khung (Krita): `map/map_kiri_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_kiri_<hành động>_<khung>.png`.
