# PHASE 06/14 – Hệ thống kỹ năng, nhân vật chính và 4 nhân vật miễn phí

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md` và các mục 4 (kỹ năng ngoài map), 6, 7, 8, 13. Chỉ làm phần việc dưới đây.

## Việc cần làm

1. SkillData dạng danh sách hiệu ứng ghép: sát thương theo chỉ số, hồi máu, khiên, buff/debuff, kéo/đẩy lượt, hồi năng lượng, cộng/trừ Điểm Chiến Kỹ, khiêu khích, giải hiệu ứng, kiểu mục tiêu. Đánh thường, Chiến kỹ, Tuyệt kỹ đều là SkillData.
2. TalentScript: lớp cơ sở cho Đặc tính, gắn vào EventBus. Tinh Mệnh 1–6 dùng cùng cơ chế, bật theo cấp Tinh Mệnh.
3. Vận mệnh: trọng số bị nhắm theo bảng mục 6; AI quái chọn mục tiêu theo trọng số.
4. Kỹ năng ngoài map: Đòn Mở Màn (mang nguyên tố, hồi chiêu, tương tác môi trường) và Bí Kỹ (tốn Điểm Bí Kỹ dùng chung, tối đa 5). Bí Kỹ có 3 kiểu: hiệu ứng mang vào trận kế tiếp, tác động quái trên map, tiện ích khám phá.
5. Vật cản môi trường cho 7 nguyên tố: dây leo (Lửa), lửa chắn (Nước), cửa máy (Sét), sương mù (Phong), cổng gỉ (Độc), khe vực cần cầu cây (Mộc), tường ẩn (Hồn).
6. Nhân vật chính đúng mẫu mục 7, 2 skin nam/nữ dùng chung dữ liệu.
7. Thiết kế và code đầy đủ Mira (Nước, Trù Phú), Kiri (Lửa, Hòa Hợp), Garren (Mộc, Bảo Hộ), Nyx (Sét, Hư Vô): 2 kỹ năng ngoài map, 3 kỹ năng trong trận, 1 Đặc tính riêng, 6 Tinh Mệnh, chỉ số cấp 1 và cấp 30. Đưa bảng thiết kế của 4 người này vào báo cáo và vào `docs/CHARACTERS.md`.
8. Đổi người dẫn đầu ngoài map bằng phím 1–4.
9. Thay dữ liệu tạm của Phase 4 bằng dữ liệu thật.

## Không làm trong phase này

20 nhân vật còn lại (Phase 7), tiến trình nâng cấp (Phase 9).

## Tiêu chí hoàn thành

- [ ] Có 5 nhân vật; chọn đúng 4 người vào trận; mỗi người dùng đủ 5 kỹ năng và Đặc tính chạy đúng mô tả.
- [ ] Mở được cả 7 loại vật cản môi trường bằng Đòn Mở Màn đúng nguyên tố.
- [ ] Bí Kỹ của từng người hoạt động, Điểm Bí Kỹ trừ và hồi đúng.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, bảng thiết kế 5 nhân vật, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
