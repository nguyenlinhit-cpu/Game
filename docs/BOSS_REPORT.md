# Báo cáo mô phỏng boss (Phase 8, cập nhật Phase 14)

Sinh bởi `tools/balance/boss_report.tscn`. Đội miễn phí (chọn 4 trong Lữ khách, Mira, Kiri, Garren, Nyx),
cấp khuyến nghị của trận, Tinh Mệnh 0, Tự Động, 40 seed. Đội được chọn = cách chọn 4 người thắng nhiều nhất
(hòa thì ít lượt hơn) qua 12 seed thử. "Lượt ta" = số lượt phe ta trong trận thắng; "mọi lượt" tính cả quái.
"Ngắt" = số lần trung bình ngắt được đòn tích tụ; "trúng" = số đòn tích tụ/đòn mạnh của boss đã ra.

| Boss | Cấp đội | Đội | Thắng | Lượt ta | Mọi lượt | Máu còn | Tới GĐ cuối | Ngắt | Trúng | Khó: thắng | Khó: lượt ta |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| library_boss_warden | 10 | traveler, kiri, garren, nyx | 100% | 40.9 | 50.8 | 57% | 100% | 0.0 | 1.0 | 52% | 63.2 |
| vault_boss_behemoth | 18 | traveler, kiri, garren, nyx | 100% | 43.3 | 53.5 | 55% | 100% | 0.1 | 1.6 | 30% | 63.8 |
| furnace_boss_core | 26 | traveler, mira, kiri, garren | 98% | 53.0 | 70.8 | 83% | 100% | 0.2 | 1.9 | 57% | 95.0 |
| tower_boss_devourer | 30 | traveler, mira, kiri, nyx | 95% | 62.9 | 90.3 | 74% | 98% | 0.8 | 0.7 | 0% | 0.0 |

## Đội đã nâng cấp (Phase 14)

Cùng đội, cùng cấp; kỹ năng ở giới hạn đột phá của cấp đó (cấp ≤10: 2, ≤20: 4, 30: 5) và mở đủ cây vận mệnh cho phép –
mức người chơi đạt được khi dồn tài nguyên (báo cáo kinh tế: đủ nâng tối đa 4–5 nhân vật).

| Boss | Cấp đội | Thường: thắng | Thường: lượt ta | Khó: thắng | Khó: lượt ta | Khó: máu còn |
| --- | --- | --- | --- | --- | --- | --- |
| library_boss_warden | 10 | 100% | 35.0 | 100% | 55.3 | 57% |
| vault_boss_behemoth | 18 | 100% | 28.9 | 95% | 46.1 | 43% |
| furnace_boss_core | 26 | 100% | 35.0 | 100% | 51.0 | 84% |
| tower_boss_devourer | 30 | 100% | 36.2 | 92% | 59.9 | 79% |

## Trận thường và tinh anh

Đội Lữ khách, Mira, Kiri, Garren; cấp khuyến nghị; Tự Động; 8 seed. "Máu còn" = trung bình tỉ lệ máu cả đội cuối trận thắng.

| Trận | Khu | Loại | Cấp đội | Thắng | Lượt ta | Máu còn |
| --- | --- | --- | --- | --- | --- | --- |
| furnace_01_sprouts | furnace | Thường | 18 | 100% | 6.0 | 89% |
| furnace_02_mage | furnace | Thường | 19 | 100% | 6.0 | 91% |
| furnace_03_knight | furnace | Thường | 20 | 100% | 6.0 | 97% |
| furnace_04_bees | furnace | Thường | 21 | 100% | 5.5 | 96% |
| furnace_05_rats | furnace | Thường | 22 | 100% | 6.2 | 93% |
| furnace_06_patrol | furnace | Thường | 23 | 100% | 9.9 | 90% |
| furnace_elite_matrix | furnace | Tinh anh | 25 | 100% | 13.2 | 85% |
| library_01_sprouts | library | Thường | 3 | 100% | 5.1 | 92% |
| library_02_shade | library | Thường | 3 | 100% | 5.9 | 92% |
| library_03_rats | library | Thường | 4 | 100% | 4.4 | 96% |
| library_04_archer | library | Thường | 5 | 100% | 5.5 | 97% |
| library_05_mage | library | Thường | 6 | 100% | 5.8 | 91% |
| library_06_bees | library | Thường | 7 | 100% | 4.4 | 97% |
| library_07_patrol | library | Thường | 8 | 100% | 7.0 | 98% |
| library_elite_librarian | library | Tinh anh | 10 | 100% | 11.2 | 91% |
| prologue_tutorial | hub | Thường | 1 | 100% | 4.0 | 100% |
| tower_01_shade | tower | Thường | 26 | 100% | 6.1 | 97% |
| tower_02_mirror | tower | Thường | 27 | 100% | 6.1 | 97% |
| tower_03_bees | tower | Thường | 28 | 100% | 5.6 | 96% |
| tower_04_archers | tower | Thường | 28 | 100% | 6.5 | 97% |
| tower_05_patrol | tower | Thường | 29 | 100% | 10.5 | 97% |
| tower_06_sprouts | tower | Thường | 29 | 100% | 5.6 | 89% |
| tower_elite_knight | tower | Tinh anh | 30 | 100% | 15.9 | 94% |
| tower_elite_librarian | tower | Tinh anh | 30 | 100% | 11.6 | 93% |
| tower_elite_matrix | tower | Tinh anh | 30 | 100% | 14.0 | 86% |
| vault_01_sprouts | vault | Thường | 10 | 100% | 5.8 | 91% |
| vault_02_knight | vault | Thường | 11 | 100% | 6.0 | 91% |
| vault_03_mirror | vault | Thường | 12 | 100% | 6.1 | 98% |
| vault_04_guards | vault | Thường | 13 | 100% | 6.0 | 98% |
| vault_05_mixed | vault | Thường | 14 | 100% | 6.0 | 94% |
| vault_06_patrol | vault | Thường | 15 | 100% | 12.4 | 92% |
| vault_elite_knight | vault | Tinh anh | 17 | 100% | 13.8 | 94% |
