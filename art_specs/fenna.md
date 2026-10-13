# Fenna

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `fenna` |
| Hạng · nguyên tố · vận mệnh | 4★ · Mộc · Săn Bắn |
| Màu nguyên tố (viền, hiệu ứng) | `#2E8B57` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Xanh lá #2E8B57, nâu da, cam lá thu, trắng lông vũ. Bóng đen: mũ trùm tai cáo, cung ngắn cong và ống tên lông vũ.
- **Tính cách (biểu cảm, tư thế):** Hoang dã, thẳng thắn, ít nói trước người lạ; rất trung thành.
- **Tiểu sử:** Cô gái săn thú trong rừng treo, lớn lên giữa những cây sao và chim đêm. Fenna đặt bẫy và bắn tên nhanh tới mức con mồi không kịp đứng dậy sau cú ngã. Cô theo đoàn để tìm con chim ưng bạn đồng hành bị Ma Biến bắt đi.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Tên Rừng*; Bí Kỹ *Bẫy Dây (tác động quái trên map)*; Đánh thường *Tên Nhanh*; Chiến kỹ *Mưa Tên*; Tuyệt kỹ *Mũi Tên Định Mệnh (110)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_fenna_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_fenna_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_fenna_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_fenna.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_fenna_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_fenna_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_fenna_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/fenna/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character fenna --mode map` và `--mode battle` → tự sinh `map/map_fenna.png/.json`, `battle/battle_fenna.png/.json`.
- Hoặc từng khung (Krita): `map/map_fenna_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_fenna_<hành động>_<khung>.png`.
