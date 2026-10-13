# Quái và boss

File sinh tự động bởi `tools/data_builder/build_enemies.py` – đừng sửa tay.

Chỉ số = đường cong quái chuẩn (Máu 90→900, Tấn Công 30→240 từ cấp 1→80) × hệ số trong bảng.

| Id | Tên | Loại | Vai trò | Nguyên tố | Điểm yếu | Khiên | ×Máu | ×Tấn Công | Tốc Độ |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `warp_sprout_poison` | Mầm Ma Biến Độc | Thường | Yếu, đông | Độc | Lửa, Phong | 20 | 0.6 | 0.8 | 90 |
| `warp_sprout_water` | Mầm Ma Biến Nước | Thường | Yếu, đông | Nước | Sét, Mộc | 20 | 0.6 | 0.8 | 90 |
| `warp_sprout_fire` | Mầm Ma Biến Lửa | Thường | Yếu, đông | Lửa | Nước, Phong | 20 | 0.6 | 0.8 | 90 |
| `wandering_shade_wind` | Hồn Ảnh Lang Thang Phong | Thường | Hỗ trợ | Phong | Hồn, Lửa | 30 | 0.9 | 0.8 | 105 |
| `wandering_shade_water` | Hồn Ảnh Lang Thang Nước | Thường | Hỗ trợ | Nước | Sét, Hồn | 30 | 0.9 | 0.8 | 105 |
| `wandering_shade_soul` | Hồn Ảnh Lang Thang Hồn | Thường | Hỗ trợ | Hồn | Lửa, Độc | 30 | 0.9 | 0.8 | 105 |
| `rusted_knight_water` | Giáp Sĩ Rỉ Sét Nước | Thường | Khiên dày | Nước | Sét, Lửa, Phong | 60 | 1.3 | 1 | 80 |
| `rusted_knight_lightning` | Giáp Sĩ Rỉ Sét Sét | Thường | Khiên dày | Sét | Mộc, Nước, Lửa | 60 | 1.3 | 1 | 80 |
| `void_archer_wind` | Xạ Thủ Hư Không Phong | Thường | Đánh xa | Phong | Sét, Hồn | 30 | 0.9 | 1.1 | 100 |
| `void_archer_lightning` | Xạ Thủ Hư Không Sét | Thường | Đánh xa | Sét | Mộc, Phong | 30 | 0.9 | 1.1 | 100 |
| `warped_mage_poison` | Pháp Sư Méo Độc | Thường | Gây hiệu ứng | Độc | Lửa, Nước | 30 | 0.9 | 1 | 100 |
| `warped_mage_fire` | Pháp Sư Méo Lửa | Thường | Gây hiệu ứng | Lửa | Nước, Hồn | 30 | 0.9 | 1 | 100 |
| `warped_mage_wind` | Pháp Sư Méo Phong | Thường | Gây hiệu ứng | Phong | Sét, Mộc | 30 | 0.9 | 1 | 100 |
| `ink_rat_wind` | Chuột Mực Sách Phong | Thường | Nhanh | Phong | Lửa, Sét | 20 | 0.7 | 0.8 | 125 |
| `ink_rat_lightning` | Chuột Mực Sách Sét | Thường | Nhanh | Sét | Mộc, Hồn | 20 | 0.7 | 0.8 | 125 |
| `venom_bee_poison_drone` | Ong Thợ Độc | Thường | Ong được gọi thêm | Độc | Lửa, Phong | 10 | 0.45 | 0.6 | 110 |
| `venom_bee_poison` | Ong Độc Độc | Thường | Nhiều mục tiêu | Độc | Lửa, Phong | 10 | 0.45 | 0.6 | 110 |
| `venom_bee_wind_drone` | Ong Thợ Phong | Thường | Ong được gọi thêm | Phong | Sét, Nước | 10 | 0.45 | 0.6 | 110 |
| `venom_bee_wind` | Ong Độc Phong | Thường | Nhiều mục tiêu | Phong | Sét, Nước | 10 | 0.45 | 0.6 | 110 |
| `mirror_shade_water` | Bóng Gương Nước | Thường | Gây rối | Nước | Sét, Mộc | 30 | 1 | 1 | 100 |
| `mirror_shade_soul` | Bóng Gương Hồn | Thường | Gây rối | Hồn | Lửa, Nước, Hồn | 30 | 1 | 1 | 100 |
| `shattered_knight` | Kỵ Sĩ Vỡ Vụn | Tinh anh | Tinh anh: tích tụ rồi lao | Nước | Lửa, Sét, Phong | 100 | 5 | 1.6 | 95 |
| `warp_matrix` | Mẫu Thể Ma Biến | Tinh anh | Tinh anh: triệu hồi, khiên theo số Mầm | Độc | Lửa, Mộc, Nước | 60 | 5 | 1.5 | 90 |
| `mute_librarian` | Thủ Thư Câm | Tinh anh | Tinh anh: Phong Ấn Chiến kỹ | Phong | Lửa, Hồn, Sét | 90 | 4.6 | 1.6 | 105 |
| `flying_book` | Sách Bay | Thường | Triệu hồi của boss | Phong | Lửa, Phong | 20 | 0.6 | 0.7 | 110 |
| `library_warden` | Người Gác Thư Viện | Boss | Boss Chương 1 | Phong | Lửa, Hồn | 160 | 22 | 2.2 | 105 |
| `vault_behemoth` | Cự Thú Kho Chứa | Boss | Boss Chương 2 | Nước | Lửa, Hồn | 180 | 24 | 2.2 | 95 |
| `furnace_arm` | Tay Máy Lò | Thường | Mục tiêu phụ của boss | Lửa | Nước, Mộc | 40 | 2.5 | 1.8 | 95 |
| `warped_core` | Lõi Lò Biến Dạng | Boss | Boss Chương 3 | Lửa | Nước, Hồn | 170 | 18 | 3.2 | 95 |
| `devourer_clone_flame` | Phân Thân Lửa | Thường | Phân thân của trùm cuối | Lửa | Lửa, Phong | 60 | 4 | 2 | 100 |
| `devourer_clone_tide` | Phân Thân Nước | Thường | Phân thân của trùm cuối | Nước | Nước, Độc | 60 | 4 | 2 | 100 |
| `devourer_clone_storm` | Phân Thân Sét | Thường | Phân thân của trùm cuối | Sét | Sét, Mộc | 60 | 4 | 2 | 100 |
| `soul_devourer` | Kẻ Nuốt Mảnh Hồn | Boss | Trùm cuối Chương 4 | Hồn | Hồn, Nước | 180 | 22 | 2.7 | 105 |

## Giai đoạn boss

- **Người Gác Thư Viện**: GĐ1 điểm yếu Lửa, Hồn; GĐ2 "Lời Nguyền Câm Lặng" (máu ≤ 50%) điểm yếu Phong, Hồn
- **Cự Thú Kho Chứa**: GĐ1 điểm yếu Lửa, Hồn; GĐ2 "Băng Vỡ" (máu ≤ 50%) điểm yếu Sét, Hồn
- **Lõi Lò Biến Dạng**: GĐ1 điểm yếu Nước, Hồn; GĐ2 "Lò Quá Tải" (máu ≤ 50%) điểm yếu Mộc, Hồn
- **Kẻ Nuốt Mảnh Hồn**: GĐ1 điểm yếu Hồn, Nước; GĐ2 "Phân Thân" (máu ≤ 66%) điểm yếu Hồn, Nước; GĐ3 "Nuốt Hồn" (hạ hết phân thân) điểm yếu Hồn, Lửa, Sét

## Trận theo khu

### Thư Viện Câm Lặng (Chương 1, cấp 1–8)

| Trận | Loại | Cấp khuyến nghị | Đợt |
| --- | --- | --- | --- |
| `library_01_sprouts` | Thường | 3 | warp_sprout_poison Lv1 ×3 |
| `library_02_shade` | Thường | 3 | wandering_shade_wind Lv2, warp_sprout_poison Lv2 ×2 |
| `library_03_rats` | Thường | 4 | ink_rat_wind Lv3 ×2 |
| `library_04_archer` | Thường | 5 | void_archer_wind Lv4, ink_rat_wind Lv4 |
| `library_05_mage` | Thường | 6 | warp_sprout_poison Lv5, warped_mage_poison Lv5, warp_sprout_poison Lv5 |
| `library_06_bees` | Thường | 7 | venom_bee_poison Lv6 ×3 |
| `library_07_patrol` | Thường | 8 | void_archer_wind Lv7, wandering_shade_wind Lv7 → ink_rat_wind Lv7, warped_mage_poison Lv7, warp_sprout_poison Lv7 |
| `library_elite_librarian` | Tinh anh | 10 | ink_rat_wind Lv8, mute_librarian Lv8, ink_rat_wind Lv8 |
| `library_boss_warden` | Boss | 10 | library_warden Lv8 |

### Kho Chứa Băng Giá (Chương 2, cấp 8–16)

| Trận | Loại | Cấp khuyến nghị | Đợt |
| --- | --- | --- | --- |
| `vault_01_sprouts` | Thường | 10 | warp_sprout_water Lv9 ×3, wandering_shade_water Lv9 |
| `vault_02_knight` | Thường | 11 | warp_sprout_water Lv10, rusted_knight_water Lv10, warp_sprout_water Lv10 |
| `vault_03_mirror` | Thường | 12 | mirror_shade_water Lv11, wandering_shade_water Lv11 |
| `vault_04_guards` | Thường | 13 | rusted_knight_water Lv12 ×2 |
| `vault_05_mixed` | Thường | 14 | mirror_shade_water Lv13, rusted_knight_water Lv13, warp_sprout_water Lv13 |
| `vault_06_patrol` | Thường | 15 | wandering_shade_water Lv14, warp_sprout_water Lv14 ×2 → rusted_knight_water Lv14, mirror_shade_water Lv14 |
| `vault_elite_knight` | Tinh anh | 17 | shattered_knight Lv15, wandering_shade_water Lv15 |
| `vault_boss_behemoth` | Boss | 18 | vault_behemoth Lv16 |

### Lò Năng Lượng (Chương 3, cấp 16–24)

| Trận | Loại | Cấp khuyến nghị | Đợt |
| --- | --- | --- | --- |
| `furnace_01_sprouts` | Thường | 18 | warp_sprout_fire Lv17 ×3 |
| `furnace_02_mage` | Thường | 19 | warp_sprout_fire Lv18, warped_mage_fire Lv18, warp_sprout_fire Lv18 |
| `furnace_03_knight` | Thường | 20 | rusted_knight_lightning Lv19, ink_rat_lightning Lv19 |
| `furnace_04_bees` | Thường | 21 | venom_bee_poison Lv20 ×3 |
| `furnace_05_rats` | Thường | 22 | ink_rat_lightning Lv21, warped_mage_fire Lv21, ink_rat_lightning Lv21 |
| `furnace_06_patrol` | Thường | 23 | warp_sprout_fire Lv22 ×2, warped_mage_fire Lv22 → rusted_knight_lightning Lv22, ink_rat_lightning Lv22 |
| `furnace_elite_matrix` | Tinh anh | 25 | warp_sprout_poison Lv23, warp_matrix Lv23, warp_sprout_poison Lv23 |
| `furnace_boss_core` | Boss | 26 | furnace_arm Lv24, warped_core Lv24, furnace_arm Lv24 |

### Đỉnh Tháp Quan Sát (Chương 4, cấp 24–30)

| Trận | Loại | Cấp khuyến nghị | Đợt |
| --- | --- | --- | --- |
| `tower_01_shade` | Thường | 26 | wandering_shade_soul Lv25, void_archer_lightning Lv25 |
| `tower_02_mirror` | Thường | 27 | mirror_shade_soul Lv26, warped_mage_wind Lv26 |
| `tower_03_bees` | Thường | 28 | venom_bee_wind Lv27 ×3 |
| `tower_04_archers` | Thường | 28 | void_archer_lightning Lv27, wandering_shade_soul Lv27, void_archer_lightning Lv27 |
| `tower_05_patrol` | Thường | 29 | warped_mage_wind Lv28, mirror_shade_soul Lv28 → rusted_knight_lightning Lv28, void_archer_lightning Lv28, wandering_shade_soul Lv28 |
| `tower_06_sprouts` | Thường | 29 | warp_sprout_fire Lv28 ×2, mirror_shade_soul Lv28, warp_sprout_poison Lv28 |
| `tower_elite_knight` | Tinh anh | 30 | shattered_knight Lv28, wandering_shade_soul Lv28 |
| `tower_elite_librarian` | Tinh anh | 30 | mirror_shade_soul Lv29, mute_librarian Lv29 |
| `tower_elite_matrix` | Tinh anh | 30 | warp_sprout_poison Lv29, warp_matrix Lv29, warp_sprout_poison Lv29 |
| `tower_boss_devourer` | Boss | 30 | soul_devourer Lv30 |
