# Tiến trình nhân vật – bảng chi phí

Sinh tự động bởi `tools/data_builder/build_progression.py` – đừng sửa tay.
Giới hạn cấp hiện tại: 30 (`GameConfig.MAX_LEVEL`). Ký Ức Mảnh Hồn: bậc 1/2/3 = 100/500/2000 EXP; nạp EXP tốn 0.1 Xu mỗi EXP.

## EXP lên cấp

| Cấp | EXP lên cấp kế | Cộng dồn từ cấp 1 |
| --- | --- | --- |
| 1 → 2 | 150 | 150 |
| 2 → 3 | 200 | 350 |
| 3 → 4 | 250 | 600 |
| 4 → 5 | 300 | 900 |
| 5 → 6 | 370 | 1270 |
| 6 → 7 | 440 | 1710 |
| 7 → 8 | 530 | 2240 |
| 8 → 9 | 620 | 2860 |
| 9 → 10 | 710 | 3570 |
| 10 → 11 | 820 | 4390 |
| 11 → 12 | 930 | 5320 |
| 12 → 13 | 1060 | 6380 |
| 13 → 14 | 1190 | 7570 |
| 14 → 15 | 1320 | 8890 |
| 15 → 16 | 1470 | 10360 |
| 16 → 17 | 1620 | 11980 |
| 17 → 18 | 1790 | 13770 |
| 18 → 19 | 1960 | 15730 |
| 19 → 20 | 2130 | 17860 |
| 20 → 21 | 2320 | 20180 |
| 21 → 22 | 2510 | 22690 |
| 22 → 23 | 2720 | 25410 |
| 23 → 24 | 2930 | 28340 |
| 24 → 25 | 3140 | 31480 |
| 25 → 26 | 3370 | 34850 |
| 26 → 27 | 3600 | 38450 |
| 27 → 28 | 3850 | 42300 |
| 28 → 29 | 4100 | 46400 |
| 29 → 30 | 4350 | 50750 |

## Đột phá

| Ở cấp | Giới hạn mới | Xu Aether | Tinh Thể đúng nguyên tố | Trạng thái |
| --- | --- | --- | --- | --- |
| 10 | 20 | 4000 | 4 | Mở |
| 20 | 30 | 12000 | 10 | Mở |
| 30 | 40 | 30000 | 15 | Khóa (chờ nâng giới hạn) |
| 40 | 50 | 60000 | 20 | Khóa (chờ nâng giới hạn) |
| 50 | 60 | 100000 | 25 | Khóa (chờ nâng giới hạn) |
| 60 | 70 | 160000 | 30 | Khóa (chờ nâng giới hạn) |
| 70 | 80 | 240000 | 40 | Khóa (chờ nâng giới hạn) |

## Nâng kỹ năng (mỗi kỹ năng: Đánh thường, Chiến kỹ, Tuyệt kỹ, Đặc tính)

Cấp kỹ năng tối đa theo số lần đột phá: 0 lần → cấp 2 / 1 lần → cấp 4 / 2 lần → cấp 5. Hệ số sát thương/hồi/khiên theo cấp: ×1, ×1.1, ×1.2, ×1.3, ×1.4; độ mạnh buff/debuff: ×1, ×1.05, ×1.1, ×1.15, ×1.2.

| Lên cấp | Xu Aether | Dấu Ấn Vận Mệnh | Lõi Ma Biến | Cần đột phá |
| --- | --- | --- | --- | --- |
| 2 | 1500 | 3 × bậc 1 | 0 | 0 lần |
| 3 | 4000 | 2 × bậc 2 | 0 | 1 lần |
| 4 | 8000 | 4 × bậc 2 | 0 | 1 lần |
| 5 | 16000 | 3 × bậc 3 | 1 | 2 lần |

## Cây vận mệnh (mỗi vận mệnh 6 nút nhỏ + 3 nút lớn)

| Nút | Xu Aether | Dấu Ấn | Cần đột phá |
| --- | --- | --- | --- |
| 2 nút nhỏ bậc 1 (mỗi nút) | 1500 | 2 × bậc 1 | 0 lần |
| Nút lớn 1 | 3000 | 3 × bậc 1 | 0 lần |
| 2 nút nhỏ bậc 2 (mỗi nút) | 4000 | 2 × bậc 2 | 1 lần |
| Nút lớn 2 | 8000 | 4 × bậc 2 | 1 lần |
| 2 nút nhỏ bậc 3 (mỗi nút) | 8000 | 2 × bậc 3 | 2 lần |
| Nút lớn 3 | 16000 | 4 × bậc 3 | 2 lần |

### Nút lớn theo vận mệnh

- **Hủy Diệt**: Thân Thép – +10% Máu tối đa.; Liều Mạng – Máu dưới 50%: +15% sát thương gây ra.; Đà Phá Vỡ – Phá Vỡ khiên quái thì hồi 10 năng lượng.
- **Săn Bắn**: Mắt Diều Hâu – +12% Sát Thương Bạo Kích.; Phục Kích – Vào trận với thêm 15% năng lượng.; Kết Liễu – +12% sát thương lên quái đang mang debuff.
- **Tri Thức**: Uyên Bác – +8% Tấn Công.; Phân Tích – +12% sát thương lên quái đang mang debuff.; Chuẩn Bị – Vào trận với thêm 20% năng lượng.
- **Hòa Hợp**: Nhịp Chung – +5 Tốc Độ.; Khởi Xướng – Vào trận với thêm 20% năng lượng.; Hòa Âm – +8% Hiệu Suất Hồi Năng Lượng.
- **Hư Vô**: Ám Ảnh – +10% Chính Xác Hiệu Ứng.; Bào Mòn – +15% sát thương lên quái đang mang debuff.; Rạn Vỡ – Phá Vỡ khiên quái thì hồi 10 năng lượng.
- **Bảo Hộ**: Tường Thành – +10% Phòng Thủ.; Kiên Định – +15% Kháng Hiệu Ứng.; Lá Chắn Đầu Trận – Đầu trận nhận khiên bằng 40% Phòng Thủ trong 2 lượt.
- **Trù Phú**: Mạch Sống – +8% Tăng Trị Liệu.; Cấp Cứu – +15% lượng hồi lên đồng minh dưới 50% máu.; Chuẩn Bị – Vào trận với thêm 20% năng lượng.

## Tổng chi phí 1 nhân vật lên tối đa (cấp 30, 4 kỹ năng cấp 5, đủ cây vận mệnh)

| Hạng mục | Số lượng |
| --- | --- |
| EXP (cấp 1 → 30) | 50750 (≈ 25.4 Ký Ức bậc 3) |
| Xu Aether | 193075 (cấp 5075 + đột phá 16000 + kỹ năng 118000 + cây 54000) |
| Tinh Thể Nguyên Tố | 14 |
| Dấu Ấn Vận Mệnh | bậc 1: 19, bậc 2: 32, bậc 3: 20 |
| Lõi Ma Biến | 4 |

Mục tiêu mục 11: 4–5 nhân vật như trên → nhân 4–5 lần. Phase 10 cân bảng rơi đồ theo con số này.
