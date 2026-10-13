# Hồn Ảnh Lang Thang (Thường)

Sinh tự động bởi `tools/data_builder/build_art_specs.py`.

- **Mô tả:** Hồn ma nửa trong suốt, áo choàng rách trôi lơ lửng, đôi tay dài tỏa khiên sáng cho đồng minh.
- **Dáng / bóng đen:** Đuôi áo vuốt nhọn thay chân. Bóng đen: hình giọt nước ngược, hai tay dài.
- **Trong game:** Linh hồn lạc lối che chắn cho đồng bọn.

## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)

| Id | Tên | Nguyên tố | Màu |
| --- | --- | --- | --- |
| `wandering_shade` | wandering_shade | Hồn | `#F2D58A` |
| `wandering_shade_soul` | Hồn Ảnh Lang Thang Hồn | Hồn | `#F2D58A` |
| `wandering_shade_water` | Hồn Ảnh Lang Thang Nước | Nước | `#3A8DDE` |
| `wandering_shade_wind` | Hồn Ảnh Lang Thang Phong | Phong | `#4FD1B5` |

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

Thư mục: `assets/enemies/wandering_shade/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character wandering_shade --kind enemies --mode map` và `--mode battle` → tự sinh `map/map_wandering_shade.png/.json`, `battle/battle_wandering_shade.png/.json`.
- Hoặc từng khung (Krita): `map/map_wandering_shade_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_wandering_shade_<hành động>_<khung>.png`.
- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.
