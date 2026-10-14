# Phân Thân (Thường)

Sinh tự động bởi `tools/data_builder/build_art_specs.py`.

- **Mô tả:** Phân thân của Kẻ Nuốt Mảnh Hồn: bóng người mờ một nguyên tố (Lửa / Nước / Sét).
- **Dáng / bóng đen:** Giống bản thể nhưng nhỏ hơn, viền rực màu nguyên tố.
- **Trong game:** Mảnh hồn bị Kẻ Nuốt tách ra; hạ nó làm bản thể bị thương.

## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)

| Id | Tên | Nguyên tố | Màu |
| --- | --- | --- | --- |
| `devourer_clone_flame` | Phân Thân Lửa | Lửa | `#E8552B` |
| `devourer_clone_storm` | Phân Thân Sét | Sét | `#A65BF2` |
| `devourer_clone_tide` | Phân Thân Nước | Nước | `#3A8DDE` |

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

Thư mục: `assets/enemies/devourer_clone/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character devourer_clone --kind enemies --mode map` và `--mode battle` → tự sinh `map/map_devourer_clone.png/.json`, `battle/battle_devourer_clone.png/.json`.
- Hoặc từng khung (Krita): `map/map_devourer_clone_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_devourer_clone_<hành động>_<khung>.png`.
- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.
