# PHASE 11/14 – Gacha 2 banner và cửa hàng Bụi Sao

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md` và các mục 8, 10, 11b. Chỉ làm phần việc dưới đây.

## Việc cần làm

1. BannerData và GachaManager:
    - Banner thường "Ước Nguyện Vĩnh Hằng": 7 nhân vật 5★ thường, 16 nhân vật 4★; sau 300 lượt được chọn 1 nhân vật 5★ thường (một lần).
    - Banner giới hạn "Tiếng Gọi Của Nhãn": Celestine 5★ nổi bật với 50/50 và bảo đảm lần sau; 3 nhân vật 4★ nổi bật (đặt trong file banner) với 50/50 và bảo đảm.
2. Tỉ lệ: 5★ 0,6%, từ lượt 74 cộng 6% mỗi lượt, lượt 90 chắc chắn; 4★ 5,1%, cứ 10 lượt chắc chắn có 4★ trở lên; còn lại vật phẩm 3★.
3. Bộ đếm bảo hiểm riêng từng banner, lưu trong save; bộ đếm banner giới hạn kế thừa sang banner giới hạn sau.
4. Vé Thường chỉ dùng cho banner thường, Vé Giới Hạn chỉ dùng cho banner giới hạn; đổi 160 Lệ Tinh lấy 1 vé bất kỳ.
5. Nhân vật trùng: lần 1–6 mở Tinh Mệnh 1–6, lần 7 trở đi đổi thành Bụi Sao; mỗi lần trùng tặng Bụi Sao (5★: 40, 4★: 8).
6. Cửa hàng Bụi Sao: 20 Bụi Sao/vé, mỗi tháng tối đa 5 Vé Thường và 5 Vé Giới Hạn, làm mới ngày 1 hằng tháng.
7. Quà mở Gacha sau Chương 1: 10 Vé Giới Hạn.
8. Màn Gacha: tranh banner, nút quay 1 / 10, xem tỉ lệ và bộ đếm bảo hiểm, lịch sử 100 lượt gần nhất; hiệu ứng sao băng 2D màu theo độ hiếm (xanh 3★, tím 4★, vàng 5★), bỏ qua được; màn nhận nhân vật mới hiện tranh gacha.
9. Test giả lập 1.000.000 lượt mỗi banner: tỉ lệ 5★ tổng (khoảng 1,6% khi tính bảo hiểm), số lượt trung bình mỗi 5★, tỉ lệ ra Celestine, không chuỗi nào quá 90 lượt không có 5★ hoặc quá 10 lượt không có 4★.

## Tiêu chí hoàn thành

- [ ] Test giả lập đạt và in kết quả.
- [ ] Lưu/tải giữa chừng không mất bộ đếm bảo hiểm hay trạng thái 50/50.
- [ ] Nhân vật nhận từ gacha vào được đội hình, Tinh Mệnh tăng đúng khi trùng.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, kết quả giả lập, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
