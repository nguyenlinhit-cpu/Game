# PHASE 14/14 – Hoàn thiện và xuất bản

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc toàn bộ `docs/PROGRESS.md` và các mục 2, 13. Chỉ làm phần việc dưới đây.

## Việc cần làm

1. Lưu/tải: 3 ô lưu + tự lưu ở phòng nghỉ, số phiên bản file save, chuyển đổi save cũ. Test lưu ở mọi trạng thái: giữa khu, sau gacha, sau nhận thưởng nhiệm vụ, giữa ngày làm mới.
2. Âm thanh: AudioManager với bus Nhạc / Hiệu ứng / Giọng; nhạc theo khu và boss (tạm dùng âm thanh miễn phí bản quyền, ghi nguồn trong `docs/CREDITS.md`).
3. Cài đặt: âm lượng, độ phân giải, toàn màn hình, tốc độ chữ, gán lại phím, bật joystick ảo, ngôn ngữ.
4. Điều khiển cảm ứng đầy đủ cho map và trận; giao diện co giãn đúng màn hình điện thoại.
5. Cân bằng lần cuối: chạy lại báo cáo kinh tế, mô phỏng boss, chỉnh số trong file dữ liệu (không sửa code).
6. Sửa lỗi, tối ưu (object pool, giữ 60 FPS), dọn hết TODO hoặc chuyển vào `docs/PROGRESS.md` mục "Để sau".
7. Xuất bản Windows (và APK Android thử nếu được), kèm `docs/BUILD.md` hướng dẫn build.

## Tiêu chí hoàn thành

- [ ] Bản Windows chơi trọn Mở đầu → Chương 4, lưu/tải đúng, không lỗi nghiêm trọng.
- [ ] Báo cáo kinh tế và mô phỏng boss cuối cùng đạt mục tiêu ở mục 11, 11b.
- [ ] Giới hạn cấp 30 và đội tối đa 4 nhân vật vẫn đúng ở bản build.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, đường dẫn bản build, danh sách lỗi đã biết, đề xuất cho bản cập nhật sau (nâng giới hạn cấp, bản đồ mới, banner giới hạn mới).
