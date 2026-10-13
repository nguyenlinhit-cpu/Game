# PHASE 03/14 – Quái trên map và chuyển vào trận

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md` và các mục 4 (phần "Vào trận"), 9 (quy tắc chung), 13. Chỉ làm phần việc dưới đây.

## Việc cần làm

1. OverworldEnemy: tuần tra theo điểm định sẵn, tầm nhìn hình nón, đuổi khi thấy người chơi, bỏ cuộc khi ra xa, có đòn tấn công trên map (vồ/chạm) với hồi chiêu. Mỗi nhóm quái gắn một EncounterData (danh sách đợt, cấp quái).
2. Đòn Mở Màn tạm cho người chơi (vùng chém hình quạt). Xác định kiểu mở trận: ta đánh trúng trước → Ưu Thế; quái đánh trúng trước → Bị Phục Kích; chạm thường → Bình thường.
3. Quái thấp hơn đội từ 10 cấp trở lên: đánh trúng là thắng ngay, hiện popup phần thưởng tạm, không vào trận.
4. SceneRouter: lưu trạng thái map vào GameState (vị trí người chơi, quái đã hạ, rương đã mở, cửa), chuyển cảnh 0,5–1 giây, nạp scene trận kèm EncounterData và kiểu mở trận, quay lại map đúng trạng thái.
5. Scene trận tạm: hiện kiểu mở trận, danh sách quái, 2 nút Thắng/Thua. Thắng → nhóm quái biến mất khỏi map. Thua → về phòng nghỉ gần nhất, không mất đồ.
6. Cửa phòng chiến đấu (Phase 2) dùng nhóm quái thật thay vật thể giả.

## Không làm trong phase này

Hệ thống chiến đấu thật (Phase 4).

## Tiêu chí hoàn thành

- [ ] Thử được đủ 4 trường hợp: Ưu Thế, Phục Kích, Bình thường, thắng ngay quái yếu.
- [ ] Ra vào trận 10 lần liên tiếp, map vẫn giữ đúng trạng thái.
- [ ] Hạ hết quái trong phòng thì cửa mở.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
