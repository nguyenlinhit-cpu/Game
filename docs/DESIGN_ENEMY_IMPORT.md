# Toàn bộ quái trong game — 15/10/2026

Đã đưa 18 họ / 33 biến thể quái vào game, gồm 11 họ thường, 3 tinh anh và 4 boss. Giữ nguyên cơ chế, chỉ số và các trận trong dữ liệu. Giữ ba rig đã có của Mầm Ma Biến, Hồn Ảnh Lang Thang và Chuột Mực Sách; bổ sung 15 rig còn thiếu.

Đã sửa phần bỏ sót ở các màn thử: cả **39 id quái** đều có sprite map và trận. Ba id cũ `warp_sprout`, `wandering_shade`, `rusted_knight` dùng hình biến thể tương ứng; `training_dummy`, `training_dummy_fire`, `balance_brute` có atlas SVG hoạt ảnh riêng. Bộ kiểm tra duyệt toàn bộ dữ liệu và mọi encounter, không chỉ các quái có trường `family`.

- Trận: khung 256 / 384 / 768 px, idle 6, attack 8, skill 10, hit 4, down 6. Các họ cần có thêm guard, aim, charge, summon, curse, telegraph hoặc swallow.
- Boss: hình nguồn riêng cho từng giai đoạn, hậu tố `-p2` / `-p3`, hoạt ảnh chuyển hình 12 khung. Có đủ Người Gác Thư Viện, Cự Thú Kho Chứa, Lõi Lò Biến Dạng và Kẻ Nuốt Mảnh Hồn.
- Map: 32 px, boss 48 px, phóng ×4 với lọc NEAREST. Idle 4, run 6, windup 3; hướng e, lật trái. Kiểm tra toàn bộ 33 bộ có ≤12 màu và không chạm mép khung.
- Chiêu: 55 id kỹ năng trong dữ liệu, 85 bộ theo biến thể; cast và hit riêng, screen cho boss và một số chiêu diện rộng. Màu Sét tím và Hồn vàng theo `systems/element.gd`.
- Khi quái ra đòn, game dùng khung trúng trong metadata để hiện sát thương và VFX. Tư thế tích tụ, thủ thế, ngắm và đổi giai đoạn được nối vào trạng thái trận. Coroutine của trận dừng khi rời cây scene, tránh lỗi focus khi phòng thử đổi trận.

Đây là bộ hình gameplay dựng bằng rig 2D và hiệu ứng theo mô típ chiêu. Chuyển giai đoạn dùng hòa hình nguồn; chưa có hoạt cảnh phá vỡ từng mảnh áo/giáp như bản mô tả điện ảnh. Các GIF VFX là bản xem riêng hiệu ứng. Trạng thái duyệt mỹ thuật vẫn do người dùng quyết định; không tự chuyển các dòng cũ sang “duyệt”.

## Xem và thử

[Tổng quan và từng họ quái](../design/ENEMIES_IN_GAME.md), [bảng duyệt](../design/REVIEW.md).

[Ảnh trong trận thật: Kẻ Nuốt Mảnh Hồn, giai đoạn 3](../design/_reports/enemy_cast/ingame_soul_devourer_p3.png).

```bash
godot --path . res://tools/enemy_preview/enemy_preview.tscn
```

Chọn một trong 39 quái trên thanh trên cùng, chọn giai đoạn boss hoặc bấm **Đánh lại**. Phòng thử dùng màn trận thật và thư mục save riêng `user://enemy_art_preview_saves`.

## Nguồn và chạy lại

Rig chỉnh được trong `design/quai/<họ>/4_rig2d/rig_phase*.json`, pixel trong `map_<biến thể>_base.txt`. Ba rig cũ giữ ở `rig_battle.py` và `pixel_map.py`. Lõi chuyển động và hiệu ứng mới ở `design/_tools/enemy_cast.py`, `enemy_vfx.py`. `design/.gdignore` giữ tài nguyên nguồn ngoài pipeline import của Godot; game dùng các bản xuất trong `assets/`.

```bash
python3 design/_tools/render_enemy_cast.py --resume
python3 tools/import_assets/sync_design_enemies.py
python3 tools/import_assets/build_practice_enemies.py
godot --headless --path . --import
godot --headless --path . res://tools/import_assets/import_assets.tscn
godot --headless --path . res://tests/enemy_art_test.tscn
godot --headless --path . res://tests/phase08_test.tscn
godot --headless --path . res://tests/phase13_test.tscn
```

`--resume` giữ các sheet trận đã xuất; bỏ tùy chọn này hoặc xóa riêng sheet cần xuất lại khi sửa JSON xương. Công cụ đồng bộ kiểm tra toàn bộ lô trước khi chép, gồm RGBA8, kích thước, vùng cắt, số khung, giai đoạn và đủ VFX cho từng chiêu.

Log và báo cáo nằm trong `design/_reports/enemy_cast/`. Các bài kiểm tra cơ chế cũ vẫn có cảnh báo tài nguyên còn giữ khi tắt engine; đã tách khỏi lỗi script trong lúc chạy và chưa sửa toàn bộ phần dọn tài nguyên của dự án trong đợt này.

Kết quả bản cuối: **Enemy art 696/696**, **Phase 8 72/72**, **Phase 13 63/63**. Tổng 831 kiểm tra đạt; không có lỗi engine/script trong lúc các bài kiểm tra chạy. Đã mở bản render OpenGL thật và chụp boss giai đoạn 3. Công cụ đồng bộ chạy lại cập nhật 0/403 file, xác nhận tài nguyên đã khớp nguồn.
