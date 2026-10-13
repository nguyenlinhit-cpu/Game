# Báo cáo kinh tế

Sinh tự động bởi `systems/economy_report.gd` từ dữ liệu trong `data/` – đừng sửa tay.
Chạy lại: `godot --headless --path . res://systems/economy_report.tscn`. Ngưỡng lệch cho phép: 10%.

## A. Lượt quay từ nội dung một lần (mục 11b)

| Nguồn | Lệ Tinh | Vé Thường | Vé Giới Hạn | Lượt quy đổi | Mục 11b | Lệch |
| --- | --- | --- | --- | --- | --- | --- |
| Cốt truyện 4 chương (mỗi chương Lệ Tinh ×400, Vé Ước Nguyện Giới Hạn ×3, Vé Ước Nguyện Thường ×5) | 1600 | 20 | 12 | 42.0 | 42 | ✓ +0% |
| Quà người mới (đăng nhập 7 ngày + quà mở Gacha – Phase 11 trao) | 0 | 10 | 10 | 20.0 | 20 | ✓ +0% |
| Thành tựu (800 Lệ Tinh) + khám phá 100% (640 Lệ Tinh) | 1440 | 0 | 0 | 9.0 | 9 | ✓ +0% |
| Boss lần đầu (400), tinh anh lần đầu (120), rương (600 Lệ Tinh) | 1120 | 0 | 0 | 7.0 | 7 | ✓ +0% |
| **Tổng** | **4160** | **30** | **22** | **78.0** | **78** | **✓ +0%** |

Lệ Tinh dùng được cho cả hai banner; Vé Thường chỉ banner thường, Vé Giới Hạn chỉ banner giới hạn:

- Dồn hết vào banner giới hạn: 48.0 lượt (26.0 từ Lệ Tinh + 22 Vé Giới Hạn); 30 Vé Thường còn lại cho banner thường.
- Dồn hết vào banner thường: 56.0 lượt; 22 Vé Giới Hạn còn lại cho banner giới hạn.

## B. Lượt quay mỗi tháng (30 ngày, 4.3 tuần)

| Nguồn | Lệ Tinh | Vé Thường | Vé Giới Hạn | Lượt | Mục 11b | Lệch |
| --- | --- | --- | --- | --- | --- | --- |
| Nhiệm vụ ngày (100 Lệ Tinh/ngày) | 3000 | 0 | 0 | 18.8 | 19 | ✓ -1% |
| Nhiệm vụ tuần (Lệ Tinh ×160, Vé Ước Nguyện Giới Hạn ×1, Vé Ước Nguyện Thường ×1/tuần) | 688 | 4.3 | 4.3 | 12.9 | 13 | ✓ -1% |
| **Tổng nhiệm vụ** | | | | **31.6** | **32** | **✓ -1%** |
| Cửa hàng Bụi Sao (tối đa, cần nhân vật trùng – Phase 11) | | ≤ 5 | ≤ 5 | ≤ 10 | ≤ 10 | |

- Banner giới hạn mỗi tháng: 27.4 lượt (Lệ Tinh 23.1 + Vé Giới Hạn 4.3), thêm tối đa 5 từ cửa hàng.
- Banner thường mỗi tháng: 27.4 lượt (nếu dồn Lệ Tinh vào đây), thêm tối đa 5 từ cửa hàng.
- Chắc chắn có Celestine (180 lượt) khi dồn mọi Lệ Tinh vào banner giới hạn: sau 4.8 tháng (có cửa hàng: 4.1 tháng). Mục 11b: 4–5 tháng.

## C. Tài nguyên toàn bản đồ so với chi phí nâng nhân vật (mục 11)

Giả định "chơi hết bản đồ" (`data/config/economy_model.tres`): mỗi nhóm quái đặt trên map hạ 1 lần, mở hết rương, cày lại tối đa 8 trận thường mỗi chương (~15 phút), đánh lại mỗi tinh anh 5 ngày, mỗi boss 0 lần thường + 2 lần mức Khó, nhiệm vụ ngày/tuần và quà đăng nhập trong 14 ngày chơi cốt truyện (nhiệm vụ mở từ ngày 3).

| Nguồn | EXP (Ký Ức) | Xu Aether | Tinh Thể (mọi nguyên tố) | Dấu Ấn bậc 1 | Dấu Ấn bậc 2 | Dấu Ấn bậc 3 | Lõi Ma Biến |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Quái đặt trên map (mỗi nhóm 1 lần) | 40020 | 12510 | 21 | 42 | 9.0 | 8.0 | 0 |
| Thưởng hạ lần đầu (Lõi Ma Biến) | 0 | 0 | 0 | 0 | 0 | 0 | 4.0 |
| Rương | 115800 | 257000 | 80 | 0 | 0 | 0 | 0 |
| Cày lại quái thường (≤ 15 phút/chương) | 5760 | 2880 | 2.9 | 24 | 0 | 0 | 0 |
| Tinh anh hồi mỗi ngày (×5 ngày) | 32700 | 8850 | 13 | 11 | 45 | 0 | 0 |
| Boss đánh lại mức thường (×0) | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| Boss mức Khó (×2) | 48240 | 24240 | 28 | 2.0 | 0 | 32 | 16 |
| Nhiệm vụ ngày/tuần + quà đăng nhập (14 ngày) | 31200 | 135000 | 0 | 0 | 0 | 0 | 0 |
| **Tổng** | **273720** | **440480** | **146** | **79** | **54** | **40** | **20** |
| Chi phí 1 nhân vật tối đa | 50750 | 97375 | 14 | 15 | 13 | 9.0 | 4.0 |
| **Số nhân vật nâng tối đa được** | **5.39** | **4.52** | **10.42** | **5.27** | **4.15** | **4.44** | **5.00** |

Mục tiêu: 4–5 nhân vật lên cấp 30, 4 kỹ năng cấp 5, đủ cây vận mệnh (chấp nhận 3.6–5.5).

- ✓ Nút thắt: **Dấu Ấn bậc 2** → nâng tối đa được **4.15** nhân vật.
- Dư Tinh Thể (mọi nguyên tố) (10.4 nhân vật): boss/tinh anh rơi đúng nguyên tố của chúng (mục 11) và đánh lại được, nên nguyên tố của boss dư còn nguyên tố khác chỉ có từ rương – xem bảng D. Không cần chỉnh.

Tinh Thể (cần 14 mỗi nhân vật cùng nguyên tố): 80 theo nguyên tố đội đang dùng (rương) + rơi đúng nguyên tố quái:

- Lửa 12.0 · Nước 17.3 · Sét 1.1 · Phong 16.9 · Độc 7.1 · Mộc 0.0 · Hồn 11.4

Dấu Ấn luôn rơi theo vận mệnh của 1 nhân vật ngẫu nhiên trong đội đang dùng, nên tính chung theo bậc.

## D. Nhịp cốt truyện: đội miễn phí có đủ cấp khuyến nghị boss không

Cộng dồn tới trước mỗi boss: quái đặt trên map, tinh anh (cả 5 ngày đánh lại), rương, 8 trận cày lại, nhiệm vụ/quà theo ngày, boss các chương trước. EXP cần = 4 nhân vật lên cấp khuyến nghị; Tinh Thể cần = 1 nhân vật mỗi nguyên tố đội miễn phí đột phá đủ để tới cấp đó (Tinh Thể rương chia đều cho 4 người trong đội).

| Boss | Cấp khuyến nghị | EXP có | EXP cần | Tỉ lệ | Tinh Thể Hồn | Tinh Thể Nước | Tinh Thể Lửa | Tinh Thể Mộc | Tinh Thể Sét |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| library_boss_warden | 10 | 20680 | 14280 | ✓ 1.45 | ✓ 5.0/0 | ✓ 5.0/0 | ✓ 5.0/0 | ✓ 5.0/0 | ✓ 5.0/0 |
| vault_boss_behemoth | 18 | 64060 | 55080 | ✓ 1.16 | ✓ 10.0/4 | ✓ 14.4/4 | ✓ 10.0/4 | ✓ 10.0/4 | ✓ 10.0/4 |
| furnace_boss_core | 26 | 134900 | 139400 | ✓ 0.97 | ✓ 15.0/14 | ✓ 22.9/14 | ✓ 16.0/14 | ✓ 15.0/14 | ✓ 15.6/14 |
| tower_boss_devourer | 30 | 219480 | 203000 | ✓ 1.08 | ✓ 20.9/14 | ✓ 30.3/14 | ✓ 24.7/14 | ✓ 20.0/14 | ✓ 21.1/14 |

Thiếu ít (✗ gần 1,0) bù bằng cày thêm quái thường hoặc đánh lại tinh anh/boss chương trước; thiếu Tinh Thể bù bằng đánh lại boss cùng nguyên tố hoặc đổi Bụi Sao (Phase 11).

## E. Kiểm tra dữ liệu

- ✓ Mọi quái trên map có bảng rơi đồ, mọi vật phẩm tồn tại, tổng nhiệm vụ đúng mục 11b.

## Kết luận

**ĐẠT – mọi chỉ số trong ngưỡng.**
