# Kẻ Nuốt Mảnh Hồn (Boss)

Sinh tự động bởi `tools/data_builder/build_art_specs.py`.

- **Mô tả:** Trùm cuối: bóng người từng là bạn của nhân vật chính, miệng là một vết nứt mở rộng, vòng Mảnh Hồn trôi quanh. Giai đoạn 2 (Phân Thân): thân tách mảnh, vòng sáng chia 3 màu. Giai đoạn 3 (Nuốt Hồn): vết nứt nuốt nửa thân, nền tối lại.
- **Dáng / bóng đen:** Cao, áo khoác dài rách, vết nứt dọc mặt. Bóng đen: vòng Mảnh Hồn sau lưng.
- **Trong game:** Kẻ đánh cắp Mảnh Hồn, lớn lên bằng ánh sáng của người khác.

## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)

| Id | Tên | Nguyên tố | Màu |
| --- | --- | --- | --- |
| `soul_devourer` | Kẻ Nuốt Mảnh Hồn | Hồn | `#F2D58A` |

## Ngoài map – 128×128 px/khung, 8 hướng

| Hành động | Số khung | Ghi chú |
| --- | --- | --- |
| `idle` | 4 | đứng thở nhẹ, lặp |
| `run` | 6 | chạy, lặp; chân chạm đất ở khung 0 và giữa chu kỳ |

## Trong trận – 768×768 px/khung, nghiêng 3/4 quay sang trái · 3 giai đoạn: hành động giai đoạn n ≥ 2 thêm hậu tố `-p<n>`

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
| `idle-p3` | 6 | đứng thủ thế, lặp |
| `attack-p3` | 8 | Đánh thường – khung trúng khoảng 50% |
| `skill-p3` | 10 | Chiến kỹ |
| `hit-p3` | 4 | bị đánh, giật lùi |
| `down-p3` | 6 | ngã, giữ khung cuối |

## Đặt tên file (mục 12)

Thư mục: `assets/enemies/soul_devourer/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character soul_devourer --kind enemies --mode map` và `--mode battle` → tự sinh `map/map_soul_devourer.png/.json`, `battle/battle_soul_devourer.png/.json`.
- Hoặc từng khung (Krita): `map/map_soul_devourer_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_soul_devourer_<hành động>_<khung>.png`.
- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.
