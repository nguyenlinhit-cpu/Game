# Các map trong game

Đủ 5 khu của Pháo Đài Vọng Tinh dùng ảnh vẽ cùng phong cách Sảnh Trung Tâm. Mỗi phòng trong 43 phòng chiến đấu có tranh riêng từ `assets/maps/<khu>/<khu>_rooms_v2.png` và cấu trúc va chạm riêng. Có kho với lối hẹp, phòng có cánh lệch, sảnh với vách ngăn, sân tám cạnh, phòng giải đố và đấu trường Lò có lõi máy phải đi vòng. Cầu nối dùng chất liệu cùng chủ đề. Đây là các scene chơi được với đường đi, quái, rương và cốt truyện.

| Khu | Scene | Phòng | Hành lang | Rương | Hộp Bí Kỹ |
|---|---|---:|---:|---:|---:|
| Sảnh Trung Tâm | `scenes/overworld/world/hub.tscn` | 4 | 3 | 0 | 0 |
| Thư Viện | `scenes/overworld/world/library.tscn` | 11 | 10 | 14 | 8 |
| Kho Băng | `scenes/overworld/world/vault.tscn` | 10 | 9 | 14 | 8 |
| Lò Năng Lượng | `scenes/overworld/world/furnace.tscn` | 10 | 9 | 14 | 8 |
| Đỉnh Tháp | `scenes/overworld/world/tower.tscn` | 12 | 11 | 14 | 8 |

Các khu mở theo chương qua Cổng Dịch Chuyển trong Sảnh. Phòng nghỉ hỗ trợ trở về Sảnh và dịch chuyển nhanh. Cấu trúc cốt truyện, quái, boss, cổng nguyên tố, NPC và mã lưu trạng thái theo phòng được giữ nguyên.

## Ảnh xem trước từ Godot

| Khu | Tổng thể | Phòng chiến đấu |
|---|---|---|
| Thư Viện | [Toàn map](../design/_reports/maps/library_overview.png) | [Phòng](../design/_reports/maps/library_room.png) |
| Kho Băng | [Toàn map](../design/_reports/maps/vault_overview.png) | [Phòng](../design/_reports/maps/vault_room.png) |
| Lò | [Toàn map](../design/_reports/maps/furnace_overview.png) | [Phòng](../design/_reports/maps/furnace_room.png) |
| Đỉnh Tháp | [Toàn map](../design/_reports/maps/tower_overview.png) | [Phòng](../design/_reports/maps/tower_room.png) |

## Dựng lại

```sh
# RoomArchitecture định nghĩa tranh, kích thước và vật cản riêng cho từng phòng.
godot --headless --path . --editor --import
godot --headless --path . res://tools/level_builder/build_world.tscn -- library vault furnace tower

# Kiểm tra hình, va chạm, mọi phòng và vị trí vật phẩm trên đồ thị ô gạch.
godot --headless --path . res://tests/map_art_test.tscn
# Kiểm tra cốt truyện, mở khu, dịch chuyển, số quái/rương và kinh tế.
godot --headless --path . res://tests/phase12_test.tscn
# Có cửa sổ đồ họa: ghi ảnh tổng thể và phòng vào /tmp/map_<khu>_*.png.
godot --path . res://tests/map_art_test.tscn -- --capture
```

`RoomArchitecture` chọn một vùng `AtlasTexture` riêng cho mỗi phòng và định nghĩa hốc bên, cánh phòng, vách ngăn, góc cắt và lõi máy. `Room.backdrop_play_area` ánh xạ tranh vào khung va chạm. Vật phẩm và điểm xuất hiện được đặt trên vùng sàn liên thông, tránh vật cản. Phòng có vật cản giữa sân được kiểm tra bằng điểm xuất hiện an toàn, thay vì giả định tâm phòng luôn là sàn. Mã lưu và số lượng nội dung được giữ nguyên. `PaintedDetails` vẽ cửa bịt và hốc giải đố. Lớp tile không vẽ nhưng giữ va chạm.

Thứ tự hiển thị cố định: nền phòng −20, hành lang −10, kiến trúc bổ sung −9, thực thể 5, cửa chiến đấu 6, người chơi 10. Hành lang được tạo sau nhân vật vẫn nằm dưới nhân vật. Preview dùng đúng scene game, hỗ trợ `--zone=library|vault|furnace|tower|hub` và chọn từng phòng trên thanh công cụ.

Kiểm tra đạt: map art với chụp hình **57/57**; Phase 12 **109/109**. Có kiểm tra tranh và cấu trúc thực tế của từng phòng không trùng nhau, đường tới mọi phòng/vật phẩm, thứ tự hiển thị và so sánh ảnh khi bật/tắt nhân vật trên cả hành lang ngang/dọc ở cả bốn khu. Ảnh từng phòng: `design/_reports/maps/rooms/`; ảnh kiểm tra hành lang: `design/_reports/maps/corridors/`. Điều kiện mở cổng nguyên tố theo nhân vật/cốt truyện được kiểm tra riêng trong Phase 12.

## Bộ hình mới

Nguồn tranh, prompt và cấu trúc atlas: [ROOM_ATLASES.md](../assets/maps/ROOM_ATLASES.md). Bốn atlas mới được tạo bằng image_gen tích hợp, giữ nguyên các ảnh cũ. Các bộ modular v3 trong [KITS.md](../map/remake/KITS.md) vẫn được giữ làm tài nguyên, không dùng làm hình phòng hiện tại.
