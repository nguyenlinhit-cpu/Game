# PHASE 02/14 – Di chuyển và phòng kiểu Soul Knight

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md` và các mục 4, 13 của đặc tả. Chỉ làm phần việc dưới đây.

## Việc cần làm

1. Nhân vật người chơi: CharacterBody2D đi 8 hướng có gia tốc và giảm tốc (số liệu chỉnh được qua Resource), lướt có hồi chiêu và khoảng bất tử ngắn, hoạt ảnh tạm theo hướng.
2. Camera2D bám mượt, giới hạn theo phòng; một hàm rung camera dùng chung.
3. Hệ phòng: scene phòng mẫu dùng TileMapLayer (sàn, tường, va chạm), cửa 4 phía, hành lang nối. Làm 4 phòng mẫu: chiến đấu, rương, nghỉ, boss (để trống).
4. RoomManager: biết người chơi đang ở phòng nào. Phòng chiến đấu khóa cửa khi bước vào nếu còn "nhóm quái" (tạm là vật thể giả, có phím debug để xóa), mở khi hết.
5. Minimap góc phải: ô vuông cho phòng đã khám phá, biểu tượng loại phòng, vị trí hiện tại.
6. Rương và vật phá được (Hộp Bí Kỹ) dạng tạm, tương tác bằng F.
7. Phòng nghỉ: điểm lưu và hồi máu (tạm chỉ in log, ghi TODO).
8. Joystick ảo và nút lướt trên màn hình cho thiết bị cảm ứng; có tùy chọn bật trên PC để thử.

## Không làm trong phase này

Quái thật, trận đánh, kỹ năng nhân vật.

## Tiêu chí hoàn thành

- [ ] Đi qua 4 phòng mượt ở 60 FPS, lướt có hồi chiêu.
- [ ] Cửa phòng chiến đấu khóa/mở đúng, minimap cập nhật đúng.
- [ ] Joystick ảo dùng được.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
