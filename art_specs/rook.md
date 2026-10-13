# Rook

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `rook` |
| Hạng · nguyên tố · vận mệnh | 4★ · Mộc · Hủy Diệt |
| Màu nguyên tố (viền, hiệu ứng) | `#2E8B57` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Xanh lá #2E8B57, nâu gỗ, đỏ sẫm, xám đá. Bóng đen: thân hình to vuông, rìu hai lưỡi khổng lồ.
- **Tính cách (biểu cảm, tư thế):** Hiền như cục đất, nổi giận như bão; nói chậm, ăn nhiều.
- **Tiểu sử:** Tiều phu khổng lồ của Vườn Treo, mất người em khi Ma Biến biến cây cổ thụ thành quái vật. Từ đó Rook mang cây rìu làm từ chính thân cây ấy. Mỗi khi đồng đội gục ngã, nỗi đau cũ trỗi dậy thành sức mạnh.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Rìu Bổ Đất*; Bí Kỹ *Rễ Đâm (tác động quái trên map)*; Đánh thường *Bổ Rìu*; Chiến kỹ *Quét Rìu*; Tuyệt kỹ *Cây Đổ (120)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_rook_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_rook_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_rook_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_rook.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_rook_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_rook_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_rook_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/rook/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character rook --mode map` và `--mode battle` → tự sinh `map/map_rook.png/.json`, `battle/battle_rook.png/.json`.
- Hoặc từng khung (Krita): `map/map_rook_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_rook_<hành động>_<khung>.png`.
