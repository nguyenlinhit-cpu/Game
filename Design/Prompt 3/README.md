# Prompt 3 – Thiết kế từng nhân vật, từng quái bằng ảnh AI → sprite 2D

Bộ này thay cho Prompt 2. Mỗi con đi theo đường **ảnh AI → Krita duyệt → sprite 2D**: sprite trận làm bằng xương 2D uốn trực tiếp ảnh concept, sprite ngoài map vẽ pixel tay, hiệu ứng skill vẽ 2D bằng code. Game 2D nên không cần mô hình 3D.

Mọi thứ làm trong thư mục `design/` riêng. Code và `assets/` của game không bị đụng tới cho tới khi bạn duyệt.

## Trong thư mục này

| File | Dùng để |
| --- | --- |
| `00_CHUNG.md` | Đọc trước: quy trình, công cụ, prompt tạo thư mục `design/` và script dùng chung (dán 1 lần) |
| `nhan_vat/01_…md` → `26_…md` | Mỗi nhân vật 1 file: prompt ảnh, bảng màu, phác thảo Krita, sprite 2D, 5 skill |
| `quai/Q01_…md` → `Q18_…md` | Mỗi họ quái 1 file: prompt ảnh, biến thể màu, giai đoạn boss, sprite 2D, từng chiêu |
| `99_DUA_VAO_GAME.md` | Chỉ dùng khi đã duyệt hết: đưa vào `assets/` và chỉnh code game |
| `reference/` | 2 ảnh mẫu phong cách của bạn |

## Cách dùng cho 1 con (ví dụ Mira)

1. Mở `nhan_vat/03_mira.md`. Dán từng prompt ở Bước 1 vào công cụ tạo ảnh, lưu ảnh đẹp nhất vào `design/nhan_vat/mira/1_concept/`.
2. Dán khối Bước 2 cho AI → được file Krita phác thảo + ảnh xem. **Bạn duyệt** trong `design/REVIEW.md`.
3. Bước 3 đã bỏ (không làm 3D).
4. Dán khối Bước 4 cho AI → sprite trận (xương 2D), sprite pixel ngoài map, GIF. **Bạn duyệt.**
5. Dán từng khối skill ở Bước 5 → hiệu ứng + GIF ghép với sprite. **Bạn duyệt.**
6. Duyệt hết thì dán `99_DUA_VAO_GAME.md` với id `mira`.

## Nói trước về chất lượng

- Đẹp hay không phụ thuộc chủ yếu vào ảnh concept 1a (sprite trận giữ nguyên nét vẽ của ảnh này). Chọn 1a có tư thế đứng dễ cử động: tay, vũ khí không che mặt quá nhiều.
- Xương 2D chỉ uốn ảnh: nghiêng, vẩy, nhún, bay vạt áo được; xoay người hay đổi hướng thì không. Nét mặt giữ như ảnh, muốn chớp mắt phải dán thêm hình mắt.
- Sprite pixel ngoài map vẽ tay theo lưới ký tự (`map_base.txt`); sửa từng điểm ảnh trực tiếp trong file đó.
- Ảnh mẫu là ảnh chụp từ game khác, chỉ dùng để lấy phong cách. Repo đang public: nếu không muốn công khai, đừng commit thư mục `reference/`.

## Danh sách nhân vật

| # | Nhân vật | Hạng | Nguyên tố | Vận mệnh | File |
| --- | --- | --- | --- | --- | --- |
| 01 | Kael (Lữ khách – skin Nam) | 5★ | Hồn | Hủy Diệt | `nhan_vat/01_traveler_male.md` |
| 02 | Kaela (Lữ khách – skin Nữ) | 5★ | Hồn | Hủy Diệt | `nhan_vat/02_traveler_female.md` |
| 03 | Mira | 4★ | Nước | Trù Phú | `nhan_vat/03_mira.md` |
| 04 | Kiri | 4★ | Lửa | Hòa Hợp | `nhan_vat/04_kiri.md` |
| 05 | Garren | 4★ | Mộc | Bảo Hộ | `nhan_vat/05_garren.md` |
| 06 | Nyx | 4★ | Sét | Hư Vô | `nhan_vat/06_nyx.md` |
| 07 | Ignar | 5★ | Lửa | Hủy Diệt | `nhan_vat/07_ignar.md` |
| 08 | Marisol | 5★ | Nước | Bảo Hộ | `nhan_vat/08_marisol.md` |
| 09 | Raiko | 5★ | Sét | Săn Bắn | `nhan_vat/09_raiko.md` |
| 10 | Zephyra | 5★ | Phong | Hòa Hợp | `nhan_vat/10_zephyra.md` |
| 11 | Vesper | 5★ | Độc | Hư Vô | `nhan_vat/11_vesper.md` |
| 12 | Sylvaine | 5★ | Mộc | Trù Phú | `nhan_vat/12_sylvaine.md` |
| 13 | Orrin | 5★ | Hồn | Tri Thức | `nhan_vat/13_orrin.md` |
| 14 | Celestine | 5★ | Hồn | Săn Bắn | `nhan_vat/14_celestine.md` |
| 15 | Quill | 4★ | Độc | Trù Phú | `nhan_vat/15_quill.md` |
| 16 | Aldric | 4★ | Phong | Bảo Hộ | `nhan_vat/16_aldric.md` |
| 17 | Rook | 4★ | Mộc | Hủy Diệt | `nhan_vat/17_rook.md` |
| 18 | Fenna | 4★ | Mộc | Săn Bắn | `nhan_vat/18_fenna.md` |
| 19 | Kestrel | 4★ | Phong | Hủy Diệt | `nhan_vat/19_kestrel.md` |
| 20 | Vael | 4★ | Độc | Tri Thức | `nhan_vat/20_vael.md` |
| 21 | Wisp | 4★ | Phong | Hư Vô | `nhan_vat/21_wisp.md` |
| 22 | Selka | 4★ | Độc | Hòa Hợp | `nhan_vat/22_selka.md` |
| 23 | Ember | 4★ | Lửa | Tri Thức | `nhan_vat/23_ember.md` |
| 24 | Neris | 4★ | Nước | Săn Bắn | `nhan_vat/24_neris.md` |
| 25 | Pip | 4★ | Sét | Hòa Hợp | `nhan_vat/25_pip.md` |
| 26 | Echo | 4★ | Hồn | Hư Vô | `nhan_vat/26_echo.md` |

## Danh sách quái

| # | Quái | Loại | Biến thể | File |
| --- | --- | --- | --- | --- |
| Q01 | Mầm Ma Biến | Thường | warp_sprout, warp_sprout_poison, warp_sprout_water, warp_sprout_fire | `quai/Q01_warp_sprout.md` |
| Q02 | Hồn Ảnh Lang Thang | Thường | wandering_shade, wandering_shade_wind, wandering_shade_water, wandering_shade_soul | `quai/Q02_wandering_shade.md` |
| Q03 | Giáp Sĩ Rỉ Sét | Thường | rusted_knight, rusted_knight_water, rusted_knight_lightning | `quai/Q03_rusted_knight.md` |
| Q04 | Xạ Thủ Hư Không | Thường | void_archer_wind, void_archer_lightning | `quai/Q04_void_archer.md` |
| Q05 | Pháp Sư Méo | Thường | warped_mage_poison, warped_mage_fire, warped_mage_wind | `quai/Q05_warped_mage.md` |
| Q06 | Chuột Mực Sách | Thường | ink_rat_wind, ink_rat_lightning | `quai/Q06_ink_rat.md` |
| Q07 | Ong Độc | Thường | venom_bee_poison, venom_bee_poison_drone, venom_bee_wind, venom_bee_wind_drone | `quai/Q07_venom_bee.md` |
| Q08 | Bóng Gương | Thường | mirror_shade_water, mirror_shade_soul | `quai/Q08_mirror_shade.md` |
| Q09 | Sách Bay | Thường | flying_book | `quai/Q09_flying_book.md` |
| Q10 | Tay Máy Lò | Thường | furnace_arm | `quai/Q10_furnace_arm.md` |
| Q11 | Phân Thân | Thường | devourer_clone_flame, devourer_clone_tide, devourer_clone_storm | `quai/Q11_devourer_clone.md` |
| Q12 | Kỵ Sĩ Vỡ Vụn | Tinh anh | shattered_knight | `quai/Q12_shattered_knight.md` |
| Q13 | Mẫu Thể Ma Biến | Tinh anh | warp_matrix | `quai/Q13_warp_matrix.md` |
| Q14 | Thủ Thư Câm | Tinh anh | mute_librarian | `quai/Q14_mute_librarian.md` |
| Q15 | Người Gác Thư Viện | Boss | library_warden | `quai/Q15_library_warden.md` |
| Q16 | Cự Thú Kho Chứa | Boss | vault_behemoth | `quai/Q16_vault_behemoth.md` |
| Q17 | Lõi Lò Biến Dạng | Boss | warped_core | `quai/Q17_warped_core.md` |
| Q18 | Kẻ Nuốt Mảnh Hồn | Boss | soul_devourer | `quai/Q18_soul_devourer.md` |
