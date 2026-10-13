# Giáp Sĩ Rỉ Sét (Thường)

Sinh tự động bởi `tools/data_builder/build_art_specs.py`.

- **Mô tả:** Bộ giáp rỗng gỉ sét, khiên tháp to, mũ có khe sáng; tư thế Thủ Thế chống khiên xuống đất.
- **Dáng / bóng đen:** Vuông, nặng. Bóng đen: khiên tháp cao bằng người.
- **Trong game:** Bộ giáp rỗng gỉ sét, khiên dày, biết thủ thế khi bị dồn ép.

## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)

| Id | Tên | Nguyên tố | Màu |
| --- | --- | --- | --- |
| `rusted_knight` | rusted_knight | Sét | `#A65BF2` |
| `rusted_knight_lightning` | Giáp Sĩ Rỉ Sét Sét | Sét | `#A65BF2` |
| `rusted_knight_water` | Giáp Sĩ Rỉ Sét Nước | Nước | `#3A8DDE` |

## Ngoài map – 128×128 px/khung, 8 hướng

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

Thư mục: `assets/enemies/rusted_knight/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character rusted_knight --kind enemies --mode map` và `--mode battle` → tự sinh `map/map_rusted_knight.png/.json`, `battle/battle_rusted_knight.png/.json`.
- Hoặc từng khung (Krita): `map/map_rusted_knight_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_rusted_knight_<hành động>_<khung>.png`.
- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.
