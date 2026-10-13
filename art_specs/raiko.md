# Raiko

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `raiko` |
| Hạng · nguyên tố · vận mệnh | 5★ · Sét · Săn Bắn |
| Màu nguyên tố (viền, hiệu ứng) | `#A65BF2` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Tím sét #A65BF2, trắng bạc, đen, vàng chanh. Bóng đen: cung dài cao hơn người, tóc buộc cao như tia sét.
- **Tính cách (biểu cảm, tư thế):** Tự tin, lạnh lùng khi săn, trẻ con khi rảnh; thích thi bắn.
- **Tiểu sử:** Cung thủ trinh sát từng giữ đài quan sát phía Bắc, nơi sét không bao giờ ngừng. Cô có thể nhìn thấy dòng điện trong cơ thể quái Ma Biến và bắn trúng điểm chết của chúng. Raiko tin rằng kẻ đã mở vết nứt vẫn đang trốn trong pháo đài.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Tên Sấm*; Bí Kỹ *Lôi Tiễn (tác động quái trên map)*; Đánh thường *Tên Điện*; Chiến kỹ *Dấu Sấm*; Tuyệt kỹ *Thiên Lôi Giáng (120)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_raiko_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_raiko_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_raiko_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_raiko.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_raiko_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_raiko_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_raiko_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/raiko/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character raiko --mode map` và `--mode battle` → tự sinh `map/map_raiko.png/.json`, `battle/battle_raiko.png/.json`.
- Hoặc từng khung (Krita): `map/map_raiko_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_raiko_<hành động>_<khung>.png`.
