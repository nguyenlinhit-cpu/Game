# Kỵ Sĩ Vỡ Vụn (Tinh anh)

Sinh tự động bởi `tools/data_builder/build_art_specs.py`.

- **Mô tả:** Tinh anh: kỵ sĩ giáp vỡ nứt lộ băng xanh bên trong, thương dài; tích tụ rồi lao.
- **Dáng / bóng đen:** To hơn người 1,5 lần. Bóng đen: thương dài chĩa trước + vai giáp vỡ.
- **Trong game:** Kỵ sĩ canh kho xưa, thân giáp nứt toác nhưng cú lao vẫn đủ sức xuyên tường.

## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)

| Id | Tên | Nguyên tố | Màu |
| --- | --- | --- | --- |
| `shattered_knight` | Kỵ Sĩ Vỡ Vụn | Nước | `#3A8DDE` |

## Ngoài map – 32×32 px/khung, hướng e, lật ngang khi đi trái

| Hành động | Số khung | Ghi chú |
| --- | --- | --- |
| `idle` | 4 | đứng thở nhẹ, lặp |
| `run` | 6 | chạy, lặp; chân chạm đất ở khung 0 và giữa chu kỳ |

## Trong trận – 384×384 px/khung, nghiêng 3/4 quay sang trái

| Hành động | Số khung | Ghi chú |
| --- | --- | --- |
| `idle` | 6 | đứng thủ thế, lặp |
| `attack` | 8 | Đánh thường – khung trúng khoảng 50% |
| `skill` | 10 | Chiến kỹ |
| `hit` | 4 | bị đánh, giật lùi |
| `down` | 6 | ngã, giữ khung cuối |

## Đặt tên file (mục 12)

Thư mục: `assets/enemies/shattered_knight/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character shattered_knight --kind enemies --mode map` và `--mode battle` → tự sinh `map/map_shattered_knight.png/.json`, `battle/battle_shattered_knight.png/.json`.
- Hoặc từng khung (Krita): `map/map_shattered_knight_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_shattered_knight_<hành động>_<khung>.png`.
- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.
