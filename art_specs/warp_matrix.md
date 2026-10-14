# Mẫu Thể Ma Biến (Tinh anh)

Sinh tự động bởi `tools/data_builder/build_art_specs.py`.

- **Mô tả:** Tinh anh: khối mẫu thể Ma Biến như tổ kén, các Mầm bám quanh; triệu hồi Mầm.
- **Dáng / bóng đen:** Khối tròn có xúc tu. Bóng đen: tổ kén nhiều nhánh.
- **Trong game:** Khối mầm mẹ đập thình thịch; mỗi Mầm còn sống làm khiên của nó dày thêm.

## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)

| Id | Tên | Nguyên tố | Màu |
| --- | --- | --- | --- |
| `warp_matrix` | Mẫu Thể Ma Biến | Độc | `#9BC53D` |

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

Thư mục: `assets/enemies/warp_matrix/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character warp_matrix --kind enemies --mode map` và `--mode battle` → tự sinh `map/map_warp_matrix.png/.json`, `battle/battle_warp_matrix.png/.json`.
- Hoặc từng khung (Krita): `map/map_warp_matrix_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_warp_matrix_<hành động>_<khung>.png`.
- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.
