# Lõi Lò Biến Dạng (Boss)

Sinh tự động bởi `tools/data_builder/build_art_specs.py`.

- **Mô tả:** Boss Chương 3: lõi lò khổng lồ quay chậm, vỏ kim loại nứt lộ lửa tím, hai tay máy. Giai đoạn 2 (Lò Quá Tải): lửa chuyển trắng chói, vỏ bung các tấm tản nhiệt.
- **Dáng / bóng đen:** Hình cầu cơ khí có vành quay. Bóng đen: vành khuyên quanh lõi.
- **Trong game:** Trái tim của Lò Năng Lượng bị Ma Biến nuốt, nóng dần tới khi nổ tung.

## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)

| Id | Tên | Nguyên tố | Màu |
| --- | --- | --- | --- |
| `warped_core` | Lõi Lò Biến Dạng | Lửa | `#E8552B` |

## Ngoài map – 48×48 px/khung, hướng e, lật ngang khi đi trái

| Hành động | Số khung | Ghi chú |
| --- | --- | --- |
| `idle` | 4 | đứng thở nhẹ, lặp |
| `run` | 6 | chạy, lặp; chân chạm đất ở khung 0 và giữa chu kỳ |

## Trong trận – 768×768 px/khung, nghiêng 3/4 quay sang trái · 2 giai đoạn: hành động giai đoạn n ≥ 2 thêm hậu tố `-p<n>`

| Hành động | Số khung | Ghi chú |
| --- | --- | --- |
| `idle` | 6 | đứng thủ thế, lặp |
| `attack` | 8 | Đánh thường – khung trúng khoảng 50% |
| `skill` | 10 | Chiến kỹ |
| `hit` | 4 | bị đánh, giật lùi |
| `down` | 6 | ngã, giữ khung cuối |
| `idle-p2` | 6 | đứng thủ thế, lặp |
| `attack-p2` | 8 | Đánh thường – khung trúng khoảng 50% |
| `skill-p2` | 10 | Chiến kỹ |
| `hit-p2` | 4 | bị đánh, giật lùi |
| `down-p2` | 6 | ngã, giữ khung cuối |

## Đặt tên file (mục 12)

Thư mục: `assets/enemies/warped_core/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character warped_core --kind enemies --mode map` và `--mode battle` → tự sinh `map/map_warped_core.png/.json`, `battle/battle_warped_core.png/.json`.
- Hoặc từng khung (Krita): `map/map_warped_core_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_warped_core_<hành động>_<khung>.png`.
- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.
