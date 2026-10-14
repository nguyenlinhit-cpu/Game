# Cự Thú Kho Chứa (Boss)

Sinh tự động bởi `tools/data_builder/build_art_specs.py`.

- **Mô tả:** Boss Chương 2: thú khổng lồ bốn chân, lưng mọc thùng hàng đóng băng. Giai đoạn 2 (Băng Vỡ): lớp băng nứt toác, lộ thân đỏ hằn, nhanh và hung dữ hơn.
- **Dáng / bóng đen:** Rộng, thấp, đầu cúi. Bóng đen: lưng chất thùng như núi.
- **Trong game:** Con thú khổng lồ ngủ đông giữa kho băng, lớp băng trên lưng dày như tường thành.

## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)

| Id | Tên | Nguyên tố | Màu |
| --- | --- | --- | --- |
| `vault_behemoth` | Cự Thú Kho Chứa | Nước | `#3A8DDE` |

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

Thư mục: `assets/enemies/vault_behemoth/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận.

- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character vault_behemoth --kind enemies --mode map` và `--mode battle` → tự sinh `map/map_vault_behemoth.png/.json`, `battle/battle_vault_behemoth.png/.json`.
- Hoặc từng khung (Krita): `map/map_vault_behemoth_<hành động>_<hướng>_<khung>.png` (hướng: e, se, s, sw, w, nw, n, ne, khung 00, 01…), `battle/battle_vault_behemoth_<hành động>_<khung>.png`.
- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.
