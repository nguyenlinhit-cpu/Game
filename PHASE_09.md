# PHASE 09/14 – Tiến trình nhân vật (giới hạn cấp 30)

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md` và các mục 5 (chỉ số, giới hạn cấp), 7, 8, 11. Chỉ làm phần việc dưới đây.

## Việc cần làm

1. Cấp 1–30. Giới hạn cấp là hằng số `MAX_LEVEL = 30` trong một file cấu hình duy nhất để sau nâng lên 80. Lên cấp bằng Ký Ức Mảnh Hồn 3 bậc (100 / 500 / 2000 EXP), có bảng EXP cần cho từng cấp.
2. Đột phá ở cấp 10 và 20, tốn Xu Aether + Tinh Thể Nguyên Tố đúng nguyên tố nhân vật. Dữ liệu chừa sẵn mốc 30–70 nhưng khóa.
3. Nâng kỹ năng (Đánh thường, Chiến kỹ, Tuyệt kỹ, Đặc tính) tối đa cấp 5, tốn Xu + Dấu Ấn Vận Mệnh đúng vận mệnh, cấp cao cần Lõi Ma Biến. Giới hạn cấp kỹ năng mở theo mốc đột phá.
4. Cây vận mệnh: các nút chỉ số nhỏ + 3 nút bị động lớn, mở theo đột phá.
5. Tinh Mệnh: nhận từ nhân vật trùng (nối với Phase 11); nhân vật chính mở bằng cờ cốt truyện.
6. Máu giữ nguyên giữa các trận; hồi đầy ở phòng nghỉ.
7. Giao diện: túi đồ (tab theo loại), danh sách nhân vật (lọc theo nguyên tố, vận mệnh, hạng), chi tiết nhân vật (chỉ số, kỹ năng, Tinh Mệnh, cây vận mệnh, nút nâng cấp), màn đội hình đúng 4 ô và lưu được nhiều đội hình.
8. Lệnh debug để cộng tài nguyên khi thử.

## Không làm trong phase này

Bảng rơi đồ và nhiệm vụ (Phase 10), gacha (Phase 11).

## Tiêu chí hoàn thành

- [ ] Nâng 1 nhân vật từ cấp 1 lên 30 qua giao diện, qua 2 lần đột phá; không thể vượt cấp 30.
- [ ] Chỉ số tăng đúng bảng tăng trưởng; nâng kỹ năng thay đổi số liệu trong trận.
- [ ] Màn đội hình không cho quá 4 người.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, bảng chi phí đã dùng, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
