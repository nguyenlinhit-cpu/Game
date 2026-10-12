# PHASE 04/14 – Lõi trận đánh theo lượt

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md` và các mục 5, 13. Chỉ làm phần việc dưới đây.

## Việc cần làm

1. `systems/stats`: lớp Stats với 11 chỉ số ở mục 5, hỗ trợ buff cộng và nhân, cấp.
2. BattleUnit (cho ta và quái) và TurnQueue theo Giá trị Hành Động = 10000 / Tốc Độ; hỗ trợ kéo lượt, trì hoãn, đổi tốc độ giữa trận. Thanh thứ tự lượt bên trái có xem trước khi chọn kỹ năng.
3. Phe ta tối đa 4 nhân vật (kiểm tra cứng: đội trên 4 người bị từ chối kèm thông báo), không đổi người giữa trận, người ngã không có ai thay. Phe quái tối đa 5 mỗi đợt, hỗ trợ nhiều đợt.
4. Điểm Chiến Kỹ dùng chung (tối đa 5, đầu trận 3), năng lượng, Tuyệt kỹ chen lượt bằng cách bấm chân dung (hàng đợi chen lượt).
5. `systems/damage_calc.gd` đúng công thức mục 5 (bạo kích, phòng thủ, kháng, dễ tổn thương, hệ số phá vỡ để sẵn tham số).
6. Áp dụng kiểu mở trận từ Phase 3: Ưu Thế cho cả đội đi trước vòng đầu, Phục Kích cho quái đi trước.
7. Giao diện trận: phe ta bên trái, quái bên phải; 4 thẻ nhân vật; nút Đánh thường, Chiến kỹ; ô Điểm Chiến Kỹ; chọn mục tiêu (đơn, lan 3, toàn bộ); số sát thương bay; nút Tự Động và Tăng Tốc x2.
8. Kết thúc trận: màn thắng (EXP, vật phẩm để trống), màn thua (đánh lại / rút lui).
9. 4 nhân vật mẫu và 3 quái mẫu bằng dữ liệu tạm (kỹ năng đơn giản, sẽ thay ở Phase 6).
10. Test: công thức sát thương (ít nhất 10 ca, có ca tính tay), thứ tự lượt khi đổi tốc độ, Điểm Chiến Kỹ luôn trong khoảng 0–5.

## Không làm trong phase này

Nguyên tố, khiên, hiệu ứng (Phase 5); kỹ năng dạng dữ liệu (Phase 6).

## Tiêu chí hoàn thành

- [ ] Đánh trọn một trận 4 nhân vật vs 3 quái bằng chuột và bằng Tự Động.
- [ ] Không thể đưa người thứ 5 vào trận.
- [ ] Tất cả test đạt.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, kết quả test, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
