# PHASE 12/14 – Bản đồ Pháo Đài Vọng Tinh và cốt truyện

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md`, `docs/CHARACTERS.md` và các mục 3, 4, 9, 11, 11b. Chỉ làm phần việc dưới đây.

## Việc cần làm

1. Sảnh Trung Tâm: NPC, cửa hàng, bàn Gacha, bảng nhiệm vụ, bàn nâng cấp, đổi đội hình, cổng dịch chuyển tới các khu đã mở.
2. 4 khu (Thư Viện Câm Lặng, Kho Chứa Băng Giá, Lò Năng Lượng, Đỉnh Tháp Quan Sát), mỗi khu 8–12 phòng: chiến đấu, rương, giải đố dùng tương tác nguyên tố, phòng nghỉ, tinh anh, boss. Đặt EncounterData theo cấp chương (1–8, 8–16, 16–24, 24–30).
3. Giải đố: đường chính chỉ cần nguyên tố của đội miễn phí đã có ở thời điểm đó; một vài rương ẩn cần nhân vật gacha (không bắt buộc cho cốt truyện).
4. Hệ thống hội thoại JSON: người nói, chân dung, biểu cảm, câu thoại, lựa chọn, sự kiện. Hộp thoại có chữ chạy, bỏ qua, xem lại lịch sử.
5. Viết toàn bộ cốt truyện Mở đầu → Chương 4 theo mục 3: 3–5 cảnh chính mỗi chương; cảnh gia nhập riêng cho Mira, Kiri, Garren, Nyx; ảo ảnh Celestine cuối Chương 1; kết Chương 4 mở vết nứt dẫn tới vùng đất mới.
6. Cờ cốt truyện điều khiển: mở khu, mở Gacha + nhiệm vụ ngày sau Chương 1, thưởng chương (400 Lệ Tinh + 5 Vé Thường + 3 Vé Giới Hạn), Tinh Mệnh nhân vật chính, nhận nhân vật miễn phí.
7. Nhiệm vụ chính hiện ở góc màn hình kèm mũi tên chỉ đường; 2 nhiệm vụ phụ mở Tinh Mệnh 5–6 của nhân vật chính.
8. Dịch chuyển nhanh giữa các phòng nghỉ đã mở.

## Tiêu chí hoàn thành

- [ ] Chơi từ đầu tới hết Chương 4 không bị kẹt.
- [ ] Nhận đủ 4 nhân vật miễn phí đúng chương; đội 4 người đủ vị trí từ Chương 2.
- [ ] Tổng thưởng trên map khớp báo cáo kinh tế Phase 10 (chạy lại báo cáo và đính kèm).

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, sơ đồ phòng từng khu, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
