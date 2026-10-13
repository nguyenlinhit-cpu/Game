# Sylvaine

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `sylvaine` |
| Hạng · nguyên tố · vận mệnh | 5★ · Mộc · Trù Phú |
| Màu nguyên tố (viền, hiệu ứng) | `#2E8B57` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Xanh lá #2E8B57, hồng đào, nâu đất, kem. Bóng đen: mái tóc dài kết hoa thành vòng, gậy mọc cành lá.
- **Tính cách (biểu cảm, tư thế):** Hiền, chậm rãi, kiên nhẫn; nói chuyện với cây như với người.
- **Tiểu sử:** Người làm vườn của Vườn Treo, nơi trồng những cây sao cung cấp không khí cho pháo đài. Cô mang theo hạt của Cây Sự Sống cuối cùng, mỗi hạt có thể mọc thành một cây chữa lành. Sylvaine đi khắp các khu để gieo lại sự sống ở nơi Ma Biến đã tàn phá.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Gai Hoa*; Bí Kỹ *Hạt Giống Sống (lợi thế trận kế tiếp)*; Đánh thường *Cành Quất*; Chiến kỹ *Mưa Phấn Hoa*; Tuyệt kỹ *Vườn Hồi Sinh (140)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_sylvaine_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_sylvaine_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_sylvaine_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_sylvaine.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_sylvaine_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_sylvaine_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_sylvaine_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/sylvaine/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character sylvaine --mode map` và `--mode battle` → tự sinh `map/map_sylvaine.png/.json`, `battle/battle_sylvaine.png/.json`.
- Hoặc từng khung (Krita): `map/map_sylvaine_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_sylvaine_<hành động>_<khung>.png`.
