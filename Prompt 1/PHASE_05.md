# PHASE 05/14 – Nguyên tố, khiên, phá vỡ, hiệu ứng

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md` và các mục 5, 6. Chỉ làm phần việc dưới đây.

## Việc cần làm

1. Enum 7 nguyên tố (Lửa, Nước, Sét, Phong, Độc, Mộc, Hồn) với màu theo bảng mục 6; dùng cho hình tạm và viền số sát thương.
2. Quái có 1–3 điểm yếu, kháng mặc định 20%, nguyên tố điểm yếu 0%. Biểu tượng điểm yếu hiện trên đầu quái.
3. Khiên Điểm Yếu: thanh khiên; chỉ đòn đúng điểm yếu mới giảm. Phá Vỡ gây sát thương phá vỡ (theo Hiệu Ứng Phá Vỡ), trì hoãn 25%, khiên hồi đầy ở lượt kế tiếp của quái; hệ số phá vỡ 0,9 / 1,0.
4. 7 hiệu ứng phá vỡ đúng bảng mục 6: Thiêu Đốt, Đóng Băng, Điện Giật, Phong Cắt (cộng dồn 5), Nhiễm Độc (theo % máu tối đa có trần, giảm 10% Phòng Thủ), Trói Rễ, Giam Hồn.
5. Hệ thống StatusEffect dạng dữ liệu: buff/debuff có số lượt, cộng dồn, tỉ lệ trúng (Chính Xác Hiệu Ứng so với Kháng Hiệu Ứng), sát thương theo lượt, mất lượt. Biểu tượng hiệu ứng dưới thanh máu, chạm/rê chuột để xem mô tả.
6. Ưu Thế: nếu nguyên tố của Đòn Mở Màn là điểm yếu của quái, quái mất 25% khiên khi vào trận.
7. Test cho từng nguyên tố và tỉ lệ trúng hiệu ứng (giả lập 10.000 lần).

## Không làm trong phase này

Kỹ năng thật của nhân vật (Phase 6).

## Tiêu chí hoàn thành

- [ ] Phòng thử trận cho chọn nguyên tố đòn đánh, kiểm chứng đủ 7 hiệu ứng phá vỡ.
- [ ] Đòn sai nguyên tố không làm giảm khiên.
- [ ] Tất cả test đạt.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, kết quả test, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
