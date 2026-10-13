# Pip

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `pip` |
| Hạng · nguyên tố · vận mệnh | 4★ · Sét · Hòa Hợp |
| Màu nguyên tố (viền, hiệu ứng) | `#A65BF2` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Tím sét #A65BF2, vàng cam, xanh dương, xám. Bóng đen: người nhỏ thó đội mũ bảo hộ to, robot tròn bay kè kè bên vai.
- **Tính cách (biểu cảm, tư thế):** Lanh lợi, vui tính, nói không ngừng; giả vờ không sợ khi rất sợ.
- **Tiểu sử:** Thợ máy nhí của xưởng robot, chế ra chú robot sạc pin tên Bolt từ đồ phế liệu. Pip và Bolt đi khắp pháo đài sửa đèn, sửa cửa, và giờ là sạc năng lượng cho người khác. Cậu hy vọng tìm thấy bố, kỹ sư trưởng mất tích ở Lò Năng Lượng.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Bolt Lao Tới*; Bí Kỹ *Sạc Đầy (lợi thế trận kế tiếp)*; Đánh thường *Tia Điện Nhỏ*; Chiến kỹ *Sạc Nhanh*; Tuyệt kỹ *Quá Áp (100)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_pip_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_pip_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_pip_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_pip.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_pip_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_pip_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_pip_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/pip/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character pip --mode map` và `--mode battle` → tự sinh `map/map_pip.png/.json`, `battle/battle_pip.png/.json`.
- Hoặc từng khung (Krita): `map/map_pip_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_pip_<hành động>_<khung>.png`.
