# Xạ Thủ Hư Không (Thường)

Sinh tự động bởi `tools/data_builder/build_art_specs.py`.

- **Mô tả:** Cung thủ hư không gầy, mặt trùm kín, cung dài tạo từ vết nứt; Ngắm: dây cung kéo căng phát sáng.
- **Dáng / bóng đen:** Cao gầy. Bóng đen: cung dài cong hơn người.
- **Trong game:** Cung thủ đứng xa, ngắm trước rồi bắn xuyên.

## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)

| Id | Tên | Nguyên tố | Màu |
| --- | --- | --- | --- |
| `void_archer_lightning` | Xạ Thủ Hư Không Sét | Sét | `#A65BF2` |
| `void_archer_wind` | Xạ Thủ Hư Không Phong | Phong | `#4FD1B5` |

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

Thư mục: `assets/enemies/void_archer/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character void_archer --kind enemies --mode map` và `--mode battle` → tự sinh `map/map_void_archer.png/.json`, `battle/battle_void_archer.png/.json`.
- Hoặc từng khung (Krita): `map/map_void_archer_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_void_archer_<hành động>_<khung>.png`.
- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.
