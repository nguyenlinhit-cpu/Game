# Pháp Sư Méo (Thường)

Sinh tự động bởi `tools/data_builder/build_art_specs.py`.

- **Mô tả:** Pháp sư méo mó, mũ chóp gãy gập, sách phép lơ lửng trước ngực.
- **Dáng / bóng đen:** Áo chùng loe. Bóng đen: mũ chóp gãy gập.
- **Trong game:** Pháp sư bị Ma Biến bẻ cong, gieo nguyên tố độc hại.

## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)

| Id | Tên | Nguyên tố | Màu |
| --- | --- | --- | --- |
| `warped_mage_fire` | Pháp Sư Méo Lửa | Lửa | `#E8552B` |
| `warped_mage_poison` | Pháp Sư Méo Độc | Độc | `#9BC53D` |
| `warped_mage_wind` | Pháp Sư Méo Phong | Phong | `#4FD1B5` |

## Ngoài map – 32×32 px/khung, hướng e, lật ngang khi đi trái

| Hành động | Số khung | Ghi chú |
| --- | --- | --- |
| `idle` | 4 | đứng thở nhẹ, lặp |
| `run` | 6 | chạy, lặp; chân chạm đất ở khung 0 và giữa chu kỳ |

## Trong trận – 256×256 px/khung, nghiêng 3/4 quay sang trái

| Hành động | Số khung | Ghi chú |
| --- | --- | --- |
| `idle` | 6 | đứng thủ thế, lặp |
| `attack` | 8 | Đánh thường – khung trúng khoảng 50% |
| `skill` | 10 | Chiến kỹ |
| `hit` | 4 | bị đánh, giật lùi |
| `down` | 6 | ngã, giữ khung cuối |

## Đặt tên file (mục 12)

Thư mục: `assets/enemies/warped_mage/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character warped_mage --kind enemies --mode map` và `--mode battle` → tự sinh `map/map_warped_mage.png/.json`, `battle/battle_warped_mage.png/.json`.
- Hoặc từng khung (Krita): `map/map_warped_mage_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_warped_mage_<hành động>_<khung>.png`.
- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.
