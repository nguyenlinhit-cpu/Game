# Mira

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `mira` |
| Hạng · nguyên tố · vận mệnh | 4★ · Nước · Trù Phú |
| Màu nguyên tố (viền, hiệu ứng) | `#3A8DDE` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** xanh nước #3A8DDE, trắng, bạc; tạp dề dược sĩ, bình nước đeo hông; bóng đen nhận ra nhờ mũ trùm tai thỏ và bình hình giọt nước.
- **Tính cách (biểu cảm, tư thế):** Dịu dàng, hay lo, tỉ mỉ; nói nhiều khi căng thẳng.
- **Tiểu sử:** Thực tập sinh dược sĩ của trạm y tế Sảnh Trung Tâm, kẹt lại khi Ma Biến tràn vào pháo đài. Cô dùng nước tinh lọc từ các bể sao để chữa vết thương nhiễm Ma Biến. Là người đầu tiên tìm thấy và chăm sóc Lữ khách khi tỉnh dậy.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Giọt Sương Bắn*; Bí Kỹ *Mưa Sương Lành (trận kế tiếp)*; Đánh thường *Giọt Sương*; Chiến kỹ *Suối Lành*; Tuyệt kỹ *Mưa Phúc (100)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_mira_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_mira_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_mira_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_mira.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_mira_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_mira_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_mira_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/mira/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character mira --mode map` và `--mode battle` → tự sinh `map/map_mira.png/.json`, `battle/battle_mira.png/.json`.
- Hoặc từng khung (Krita): `map/map_mira_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_mira_<hành động>_<khung>.png`.
