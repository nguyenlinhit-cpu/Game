# Mầm Ma Biến (Thường)

Sinh tự động bởi `tools/data_builder/build_art_specs.py`.

- **Mô tả:** Mầm cây Ma Biến tròn, thấp, hai lá mầm trên đầu, miệng nứt phát sáng; nổ khi chết.
- **Dáng / bóng đen:** Tròn trịa, cao bằng nửa nhân vật. Bóng đen: củ tròn + 2 lá dựng.
- **Trong game:** Mầm nhỏ nhiễm Ma Biến, đi thành bầy, nổ tung khi bị hạ.

## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)

| Id | Tên | Nguyên tố | Màu |
| --- | --- | --- | --- |
| `warp_sprout` | warp_sprout | Độc | `#9BC53D` |
| `warp_sprout_fire` | Mầm Ma Biến Lửa | Lửa | `#E8552B` |
| `warp_sprout_poison` | Mầm Ma Biến Độc | Độc | `#9BC53D` |
| `warp_sprout_water` | Mầm Ma Biến Nước | Nước | `#3A8DDE` |

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

Thư mục: `assets/enemies/warp_sprout/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character warp_sprout --kind enemies --mode map` và `--mode battle` → tự sinh `map/map_warp_sprout.png/.json`, `battle/battle_warp_sprout.png/.json`.
- Hoặc từng khung (Krita): `map/map_warp_sprout_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_warp_sprout_<hành động>_<khung>.png`.
- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.
