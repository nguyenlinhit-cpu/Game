# Lữ khách – Kael / Kaela – skin Nữ (Kaela)

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `traveler_female` |
| Hạng · nguyên tố · vận mệnh | 5★ · Hồn · Hủy Diệt |
| Màu nguyên tố (viền, hiệu ứng) | `#F2D58A` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** áo choàng xanh đêm (Nam) / đỏ mận (Nữ), viền vàng #F2D58A, Mảnh Hồn phát sáng ở ngực; bóng đen nhận ra nhờ vạt áo choàng xẻ đôi và lưỡi kiếm dài.
- **Tính cách (biểu cảm, tư thế):** Ít nói, tò mò, kiên định; đi tìm ký ức nhưng không bỏ rơi người gặp nạn.
- **Tiểu sử:** Tỉnh dậy trong Pháo Đài Vọng Tinh với một Mảnh Hồn đang đập trong tim và không nhớ gì về mình. Mảnh Hồn cho phép sử dụng nguyên tố Hồn – sức mạnh của chính Tâm Thần Nhãn. Mỗi Mảnh Hồn thu hồi trả lại một đoạn ký ức.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Vết Chém Hồn*; Bí Kỹ *Bước Hư Ảnh (khám phá)*; Đánh thường *Chém Rạn*; Chiến kỹ *Hồn Vỡ*; Tuyệt kỹ *Tâm Nhãn Khai Mở (120)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_traveler_female_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_traveler_female_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_traveler_female_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_traveler_female.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_traveler_female_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_traveler_female_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_traveler_female_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/traveler_female/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character traveler_female --mode map` và `--mode battle` → tự sinh `map/map_traveler_female.png/.json`, `battle/battle_traveler_female.png/.json`.
- Hoặc từng khung (Krita): `map/map_traveler_female_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_traveler_female_<hành động>_<khung>.png`.
