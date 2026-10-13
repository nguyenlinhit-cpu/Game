# PHASE 07/14 – 20 nhân vật còn lại

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md`, `docs/CHARACTERS.md` và các mục 6, 8. Chỉ làm phần việc dưới đây.

Phase này có 2 bước. Làm xong bước A thì DỪNG chờ tôi duyệt rồi mới làm bước B.

## Bước A – Thiết kế (dừng chờ duyệt)

Viết vào `docs/CHARACTERS.md` thiết kế cho 20 nhân vật còn lại trong bảng mục 8: 8 nhân vật 5★ (Ignar, Marisol, Raiko, Zephyra, Vesper, Sylvaine, Orrin, Celestine) và 12 nhân vật 4★ (Quill, Aldric, Rook, Fenna, Kestrel, Vael, Wisp, Selka, Ember, Neris, Pip, Echo). Mỗi người gồm:

- Tiểu sử 3–4 câu, tính cách, ngoại hình (bảng 3–4 màu, dáng nhận ra qua bóng đen).
- 2 kỹ năng ngoài map (Đòn Mở Màn, Bí Kỹ), 3 kỹ năng trong trận (Đánh thường, Chiến kỹ, Tuyệt kỹ), 1 Đặc tính, 6 Tinh Mệnh, chỉ số cấp 1 và cấp 30.

Cuối file thêm bảng tổng hợp: tên, nguyên tố, vận mệnh, cơ chế Đặc tính trong 1 câu, kiểu Bí Kỹ. Bảng này phải cho thấy không có 2 Đặc tính trùng cơ chế và Bí Kỹ chia đều 3 kiểu.

## Bước B – Code (sau khi tôi duyệt)

1. Tạo dữ liệu `data/characters/<id>.tres`, SkillData, TalentScript cho từng người. Làm theo nhóm 5 người, test xong nhóm này mới sang nhóm sau.
2. Phòng thử: chọn bất kỳ 4 nhân vật, chọn quái, cấp, cấp Tinh Mệnh.
3. Báo cáo cân bằng: mô phỏng 10 lượt cho mỗi nhân vật với cùng đội hỗ trợ và cùng quái, in sát thương / hồi máu / khiên. 5★ phải hơn 4★ cùng vai trò khoảng 15–25%.

## Tiêu chí hoàn thành

- [ ] 25 nhân vật (kể cả nhân vật chính) đều dùng được trong trận và ngoài map.
- [ ] Mọi Đặc tính và Tinh Mệnh chạy đúng mô tả.
- [ ] `docs/CHARACTERS.md` khớp với dữ liệu.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, báo cáo cân bằng, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
