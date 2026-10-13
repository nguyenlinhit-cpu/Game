# Celestine

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `celestine` |
| Hạng · nguyên tố · vận mệnh | 5★ · Hồn · Săn Bắn |
| Màu nguyên tố (viền, hiệu ứng) | `#F2D58A` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Trắng bạc, vàng hồn #F2D58A, xanh lam đêm, đen. Bóng đen: hai thanh kiếm dài bắt chéo sau lưng, vầng sáng hình mắt sau đầu.
- **Tính cách (biểu cảm, tư thế):** Trang nghiêm, ít cảm xúc, trung thành tuyệt đối với lời thề; ấm áp với số ít người cô tin.
- **Tiểu sử:** Người Gác Nhãn cuối cùng, sống sót trong ảo ảnh của Tâm Thần Nhãn sau khi nó vỡ. Cô giữ hai thanh kiếm làm từ hai mảnh lớn nhất của Nhãn: một để canh, một để phán xử. Celestine xuất hiện trong ảo ảnh cuối Chương 1 và tìm người mang Mảnh Hồn trong tim.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Kiếm Canh*; Bí Kỹ *Lời Tiên Tri (lợi thế trận kế tiếp)*; Đánh thường *Nhát Canh*; Chiến kỹ *Đổi Kiếm*; Tuyệt kỹ *Nhãn Phán Quyết (130)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_celestine_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_celestine_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_celestine_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_celestine.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_celestine_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_celestine_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_celestine_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/celestine/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character celestine --mode map` và `--mode battle` → tự sinh `map/map_celestine.png/.json`, `battle/battle_celestine.png/.json`.
- Hoặc từng khung (Krita): `map/map_celestine_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_celestine_<hành động>_<khung>.png`.
