# PHASE 10/14 – Tài nguyên, rơi đồ, nhiệm vụ hàng ngày và hàng tuần

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md` và các mục 10 (Bụi Sao), 11, 11b. Chỉ làm phần việc dưới đây.

## Việc cần làm

1. ItemData cho toàn bộ tài nguyên trong bảng mục 11.
2. LootTable cho quái thường, tinh anh, boss (cả mức khó cao), rương thường/quý/giải đố; thưởng lần hạ đầu tiên; quy tắc hồi quái (thường hồi khi rời khu, tinh anh mỗi ngày, boss nhận đủ thưởng 3 lần mỗi ngày rồi chỉ cho xu).
3. Bảng chi phí lên cấp 1–30, đột phá, nâng kỹ năng tối đa cấp 5 trong file dữ liệu sửa được.
4. Nhiệm vụ hàng ngày (QuestData + QuestManager): 6 nhiệm vụ ở mục 11b, tổng 500 Hoạt Động, 5 mốc thưởng 10/15/20/25/30 Lệ Tinh (tổng 100 Lệ Tinh mỗi ngày) kèm xu, Ký Ức, Hộp Bí Kỹ. Làm mới 4:00 sáng giờ máy. Chỉ mở sau Chương 1 (dùng cờ cốt truyện).
5. Nhiệm vụ hàng tuần: đủ 500 Hoạt Động trong 5 ngày, hạ boss 3 lần, thắng 30 trận; thưởng 160 Lệ Tinh + 1 Vé Giới Hạn + 1 Vé Thường. Làm mới sáng thứ Hai.
6. Phần thưởng một lần: đăng nhập 7 ngày đầu (tổng 10 Vé Thường), thành tựu (tổng 800 Lệ Tinh), khám phá 100% mỗi khu (160 Lệ Tinh). Quà mở Gacha làm ở Phase 11.
7. Chống chỉnh giờ: giờ máy lùi so với lần lưu gần nhất thì không làm mới nhiệm vụ cho tới khi giờ vượt mốc cũ.
8. Màn nhiệm vụ (tab Ngày / Tuần / Thành tựu / Người mới), thông báo nhỏ khi hoàn thành, chấm đỏ khi có thưởng chưa nhận.
9. Script báo cáo kinh tế `systems/economy_report` (chạy được từ editor hoặc dòng lệnh):
    - Cộng mọi nguồn Lệ Tinh và vé một lần, quy ra lượt quay, so với bảng mục 11b (mục tiêu 78).
    - Tính nguồn mỗi tháng từ nhiệm vụ ngày, tuần, cửa hàng Bụi Sao (mục tiêu khoảng 32 + tối đa 10).
    - Tách riêng lượt dùng được cho banner giới hạn và banner thường.
    - Cộng EXP, Xu, nguyên liệu toàn bản đồ, so với chi phí nâng 4–5 nhân vật lên cấp 30, kỹ năng cấp 5.

## Tiêu chí hoàn thành

- [ ] Báo cáo kinh tế lệch không quá 10% so với mục 11 và 11b; nếu lệch hơn, đề xuất chỉnh số trong file dữ liệu.
- [ ] Nhiệm vụ ngày làm mới đúng khi chỉnh giờ tiến, không làm mới khi chỉnh giờ lùi.
- [ ] Nhận thưởng nhiệm vụ cộng đúng vào túi đồ và được lưu.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, toàn văn báo cáo kinh tế, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
