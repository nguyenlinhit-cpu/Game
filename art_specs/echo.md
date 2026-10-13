# Echo

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `echo` |
| Hạng · nguyên tố · vận mệnh | 4★ · Hồn · Hư Vô |
| Màu nguyên tố (viền, hiệu ứng) | `#F2D58A` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Vàng hồn nhạt #F2D58A, đen gương, xám bạc, tím. Bóng đen: hai cái bóng chồng lệch nhau, mặt nạ nửa trắng nửa đen.
- **Tính cách (biểu cảm, tư thế):** Lạ lùng, hay nhại lời người khác, thật lòng ngây thơ.
- **Tiểu sử:** Bóng phản chiếu của một người gác Nhãn, tách ra từ gương khi Tâm Thần Nhãn vỡ. Echo có thể lặp lại mọi thứ nó nghe thấy, kể cả lời nguyền. Nó muốn biết người mà nó là bóng phản chiếu đang ở đâu.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Gương Vỡ*; Bí Kỹ *Tiếng Vọng Về (tiện ích khám phá)*; Đánh thường *Lời Nhại*; Chiến kỹ *Lời Nguyền Vọng*; Tuyệt kỹ *Gương Ngàn Mặt (110)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_echo_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_echo_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_echo_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_echo.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_echo_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_echo_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_echo_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/echo/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character echo --mode map` và `--mode battle` → tự sinh `map/map_echo.png/.json`, `battle/battle_echo.png/.json`.
- Hoặc từng khung (Krita): `map/map_echo_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_echo_<hành động>_<khung>.png`.
