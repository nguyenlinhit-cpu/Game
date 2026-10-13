# Quill

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `quill` |
| Hạng · nguyên tố · vận mệnh | 4★ · Độc · Trù Phú |
| Màu nguyên tố (viền, hiệu ứng) | `#9BC53D` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Xanh độc #9BC53D, cam đất, trắng, nâu. Bóng đen: ba lô đầy ống nghiệm, mũ kính phi công.
- **Tính cách (biểu cảm, tư thế):** Lém lỉnh, cẩu thả, tốt bụng; nói nhanh và hay pha chế lung tung.
- **Tiểu sử:** Học trò bỏ học của Vesper, cho rằng độc và thuốc chỉ khác nhau ở liều lượng. Cậu chế loại độc khiến quái Ma Biến 'chảy' sinh lực ngược về phía đồng đội. Quill đi theo đoàn vì muốn chứng minh cô thầy cũ đã sai.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Ống Nghiệm Vỡ*; Bí Kỹ *Túi Thuốc (tiện ích khám phá)*; Đánh thường *Kim Thuốc*; Chiến kỹ *Liều Đôi*; Tuyệt kỹ *Thuốc Giải Vạn Năng (100)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_quill_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_quill_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_quill_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_quill.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_quill_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_quill_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_quill_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/quill/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character quill --mode map` và `--mode battle` → tự sinh `map/map_quill.png/.json`, `battle/battle_quill.png/.json`.
- Hoặc từng khung (Krita): `map/map_quill_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_quill_<hành động>_<khung>.png`.
