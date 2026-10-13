# Vael

Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / `tools/data_builder/roster_design.py` rồi chạy lại.

| Mục | Nội dung |
| --- | --- |
| Id asset | `vael` |
| Hạng · nguyên tố · vận mệnh | 4★ · Độc · Tri Thức |
| Màu nguyên tố (viền, hiệu ứng) | `#9BC53D` |

## Thiết kế

- **Ngoại hình, mã màu, dáng bóng đen:** Xanh độc #9BC53D, tím hồng, đen, vàng kim. Bóng đen: mũ chóp cao lệch, áo choàng sân khấu xòe tròn.
- **Tính cách (biểu cảm, tư thế):** Phô trương, kịch tính, thích được vỗ tay; sợ cô đơn.
- **Tiểu sử:** Pháp sư sương độc từng làm phù thủy giải trí cho các buổi tiệc ngắm sao. Ma Biến biến trò ảo thuật sương màu của cô thành sương ăn mòn thật. Vael học cách điều khiển nó thay vì để nó điều khiển mình.
- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *Màn Sương Ảo*; Bí Kỹ *Bom Độc (tác động quái trên map)*; Đánh thường *Phi Bài Độc*; Chiến kỹ *Màn Sương Tím*; Tuyệt kỹ *Đêm Diễn Cuối (120)*.

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
| Chân dung neutral | 1024×1024 | `portrait/portrait_vael_neutral.png` |
| Chân dung happy | 1024×1024 | `portrait/portrait_vael_happy.png` |
| Chân dung serious | 1024×1024 | `portrait/portrait_vael_serious.png` |
| Tranh gacha + cắt cảnh Tuyệt kỹ | 2048×1152 | `splash/splash_vael.png` |
| Hiệu ứng attack (8 khung) | 512×512/khung | `vfx/vfx_vael_attack_<khung>.png` |
| Hiệu ứng skill (12 khung) | 512×512/khung | `vfx/vfx_vael_skill_<khung>.png` |
| Hiệu ứng ultimate (16 khung) | 512×512/khung | `vfx/vfx_vael_ultimate_<khung>.png` |

## Đặt tên file (mục 12)

Thư mục: `assets/characters/vael/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character vael --mode map` và `--mode battle` → tự sinh `map/map_vael.png/.json`, `battle/battle_vael.png/.json`.
- Hoặc từng khung (Krita): `map/map_vael_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_vael_<hành động>_<khung>.png`.
