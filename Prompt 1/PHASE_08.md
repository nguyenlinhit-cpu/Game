# PHASE 08/14 – Quái thường, tinh anh và boss

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md` và mục 9. Chỉ làm phần việc dưới đây.

## Việc cần làm

1. EnemyData và AI chọn kỹ năng theo trọng số và tình huống (máu thấp, đồng minh bị hạ, đang bị phá khiên...). Đòn mạnh báo trước 1 lượt bằng biểu tượng cảnh báo.
2. 8 quái thường theo bảng mục 9, mỗi loại ít nhất 2 biến thể nguyên tố.
3. 3 quái tinh anh: Kỵ Sĩ Vỡ Vụn, Mẫu Thể Ma Biến, Thủ Thư Câm.
4. 4 boss nhiều giai đoạn đúng bảng mục 9: đổi điểm yếu giữa giai đoạn, đoạn chuyển giai đoạn 2D ngắn, nhạc riêng (tạm).
5. Các cơ chế đặc biệt: nổ khi chết, triệu hồi (quái phụ vẫn tính vào giới hạn 5 quái), trộm Điểm Chiến Kỹ, sao chép buff, Phong Ấn kỹ năng, đếm ngược phải ngắt bằng phá khiên hoặc đủ sát thương, tích tầng Nhiệt, hút buff, phân thân.
6. Cấp quái theo chương: 1–8, 8–16, 16–24, 24–30. Mỗi boss có ít nhất 1 điểm yếu thuộc đội miễn phí (Hồn, Nước, Lửa, Mộc, Sét).
7. Chế độ khó cao hơn cho boss (bật được; phần thưởng làm ở Phase 10).
8. Tạo EncounterData cho từng khu để Phase 12 đặt lên map.
9. Phòng thử: chọn đội 4 người + boss + cấp.

## Tiêu chí hoàn thành

- [ ] Đánh được từng boss qua đủ giai đoạn, mọi cơ chế hiển thị rõ.
- [ ] Đội miễn phí (nhân vật chính, Mira, Kiri, Garren, Nyx) ở cấp khuyến nghị thắng được từng boss; báo cáo số lượt trung bình và tỉ lệ thắng khi để Tự Động.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, kết quả mô phỏng boss, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
