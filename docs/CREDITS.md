# Ghi công và nguồn tài nguyên

## Mã nguồn và dữ liệu

- Toàn bộ mã GDScript, dữ liệu (`data/`), cốt truyện, hội thoại: viết riêng cho Aethelgard: Mảnh Hồn.
- Không dùng tên, hình, âm thanh hay văn bản của Honkai: Star Rail hoặc Soul Knight (đặc tả mục 1).

## Âm thanh

Bản hiện tại **không dùng file âm thanh của bên thứ ba**. Mọi nhạc và hiệu ứng âm thanh được tổng hợp ngay trong game
bằng code của dự án (tự viết, không có bản quyền bên ngoài):

| Loại | Nguồn | Số liệu |
| --- | --- | --- |
| Nhạc tiêu đề, 5 khu (Sảnh, Thư Viện, Kho Chứa, Lò, Đỉnh Tháp), trận thường, 4 boss × 2–3 giai đoạn | `systems/placeholder_music.gd` (sóng vuông / tam giác / răng cưa) | `data/audio/music.json` |
| 20 hiệu ứng (bấm nút, trúng đòn, bạo kích, phá khiên, hồi máu, Tuyệt kỹ, thắng/thua, lướt, chém, rương, cửa, nghỉ, Bí Kỹ, lên cấp, quay gacha 3★/4★/5★…) | `systems/placeholder_sfx.gd` | `data/audio/sfx.json` |

Thay bằng file thật: thả `assets/audio/music/<id>.ogg` (hoặc `.mp3`, `.wav`) hoặc `assets/audio/sfx/<id>.ogg` cùng id
trong 2 file JSON trên – AudioManager tự ưu tiên file. **Khi thêm file của người khác, ghi vào bảng dưới:**

| File | Tác giả | Nguồn (URL) | Giấy phép |
| --- | --- | --- | --- |
| (chưa có) | | | |

Gợi ý nguồn miễn phí bản quyền: OpenGameArt (lọc CC0), Kenney.nl (CC0), freesound.org (lọc CC0 / CC-BY, ghi tên tác giả).

## Hình ảnh

- Hình tạm (khối màu, chữ cái) vẽ bằng code: `systems/placeholder_art.gd`, các hàm `_draw()`.
- Tileset tạm: sinh bằng `tools/level_builder/build_rooms.gd`.
- Hình mẫu của Mira (`assets/characters/mira/`): render từ mô hình khối của `tools/blender/make_sample_blend.py`.
- Phông chữ: phông mặc định của Godot (Open Sans, giấy phép SIL Open Font License 1.1).

## Công cụ

- Godot Engine 4.7 – giấy phép MIT, © Juan Linietsky, Ariel Manzur và cộng đồng Godot (https://godotengine.org/license).
- Blender, Krita – dùng làm công cụ dựng / vẽ, không nhúng vào bản game.
