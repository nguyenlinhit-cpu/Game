# Ngoại hình NPC

Phong cách fantasy anime vẽ tay, theo thiết kế nhân vật và quái hiện có.

Nhân vật chơi được ngoài map (cả hai phiên bản Lữ khách) và NPC Kiri, Garren, Nyx dùng chung texture với bộ trong trận thông qua `ArtLibrary.overworld_character_frames()`. Đứng dùng `idle`, mở màn dùng `attack`, Bí Kỹ có ánh xạ `skill`. Khi chạy/lướt dùng idle nhanh hơn; người chơi có nhấp nhô nhẹ khi chạy. Bộ hình trong trận chưa có chu kỳ bước chân riêng. Tỉ lệ ngoài map là khung cao 170 px; giữ điểm neo chân từ bộ trong trận và lật ngang theo hướng trái/phải.

| NPC | Nhận diện | Hình sử dụng |
| --- | --- | --- |
| Orwen | Tóc bạc búi cao, kính tròn, áo choàng thiên văn, sách và trượng pha lê | 4 khung idle + 4 chân dung |
| Lio | Tóc nâu, kính tròn, khăn vàng, sách đỏ, túi da | 4 khung idle + 4 chân dung |
| Bram | Dáng chắc, râu nâu, kính bảo hộ, tạp dề da, cờ lê | 4 khung idle + 4 chân dung |
| Kiri | Giữ thiết kế nhân vật đã có | Sprite nhân vật + 4 chân dung |
| Garren | Giữ thiết kế nhân vật, lớp băng khi bị đóng băng | Sprite nhân vật + 4 chân dung |
| Nyx | Giữ thiết kế nhân vật đã có | Sprite nhân vật + 4 chân dung |
| Kẻ Nuốt Mảnh Hồn | Tóc xám, áo đen tím viền vàng, vết nứt vàng dọc mặt | Sprite boss + 4 chân dung mới |

Biểu cảm: `neutral`, `happy`, `serious`, `speaking`. Biểu cảm hội thoại được ánh xạ qua `data/config/art_requirements.json`.

## Xem và kiểm tra

- Toàn bộ ngoại hình: `godot --path . res://tools/npc_preview/npc_gallery.tscn`
- Sáu NPC trong bản đồ thật: `godot --path . res://tools/npc_preview/npc_preview.tscn`
- Kiểm tra: `godot --headless --path . res://tests/npc_art_test.tscn`
- Tạo lại atlas: `godot --headless --path . --script res://tools/import_assets/build_npc_art.gd`

Ảnh nguồn: `assets/characters/<id>/npc/` hoặc `portrait/`; tài nguyên `.tres` tham chiếu trực tiếp PNG.

Chân dung Kẻ Nuốt Mảnh Hồn tạo bằng image_gen tích hợp, dựa trên `design/quai/soul_devourer/1_concept/1a_battle.png`. Lưu tại `assets/characters/devourer/portrait/devourer_portraits_v1.png`. Prompt: [devourer_prompt.txt](devourer_prompt.txt).
