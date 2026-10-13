# Q15. Người Gác Thư Viện – Boss

Mọi file của họ quái này nằm trong `design/quai/library_warden/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `library_warden` | Phong | `#4FD1B5` |

Khung trận 768 px, quay sang trái. Ngoài map 48×48 px. Cao khoảng 6,0 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

Giai đoạn:

- GĐ1: áo giấy kín, sách xoay đều, màu sáng
- GĐ2 – Lời Nguyền Câm Lặng (máu ≤ 50%): áo giấy bung thành chữ đen bay, mắt tím, sách đen cháy mép

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/library_warden/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`library_warden`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, a huge imposing boss: a very tall librarian guardian wearing a flared cloak made entirely of layered paper pages, a high collar, a calm masked face, hundreds of books orbiting around it like satellites, long sleeves, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

### 1a-p2. Giai đoạn 2 (`1a_battle_p2.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, the same huge library guardian in its second phase: the paper cloak has burst open into a storm of flying black letters and torn pages, eyes glowing intense violet, the orbiting books now black and burning at the edges, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: a huge imposing boss: a very tall librarian guardian wearing a flared cloak made entirely of layered paper pages, a high collar, a calm masked face, hundreds of books orbiting around it like satellites, long sleeves. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 48x48 pixels, small fantasy monster, side view facing right, very tall figure in a flared paper cloak with a ring of books orbiting it, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Áo giấy | `#EDE4CF` |
| Chữ đen | `#1E1A22` |
| Bìa sách | `#5A3A2E` |
| Phép (Phong) | `#4FD1B5` |
| Mắt GĐ2 | `#A65BF2` |
| Mặt nạ | `#D9D2C2` |

```text
Trong design/quai/library_warden/, tạo 2_sketch/library_warden_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a, 1a_p2), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/library_warden_sketch_v1.png. Thêm dòng vào design/REVIEW.md: library_warden | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng quái (dán cho AI)

```text
Làm việc trong design/quai/library_warden/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Biến thể: thay các ô màu có ghi (màu biến thể) sang màu nhấn của biến thể ngay trên ảnh concept (thay màu theo vùng), mỗi biến thể 1 sheet riêng.
3. Xương: dựng cây xương theo hình dạng (chân, cánh, xúc tu, sách bay... mỗi phần chuyển động 1 xương).
4. Hoạt ảnh trận (12 fps), quay sang trái:
   - idle 6 khung, lặp: sách xoay quanh như vệ tinh, áo giấy lật nhẹ
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6): theo Bước 5
   - hit 4 khung: giật lùi, vết nứt Ma Biến lóe sáng
   - down 6 khung: sách rơi lả tả, áo giấy sụp thành đống trang
   - hoạt ảnh thêm: summon (10 khung): Gọi Sách; curse (6 khung, lặp): tụng lời nguyền, mỗi lượt đếm ngược; phase2 (12 khung): chuyển giai đoạn; mọi hành động GĐ2 thêm hậu tố -p2
5. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel: idle 4, run 4, windup 3 (gồng trước khi vồ: co người, nháy màu nhấn). Nhìn ngang, chỉ hướng phải.
6. Render:
   - trận: 5_render/<id biến thể>/battle_<id biến thể>.png + .json (khung 768, quay trái, có hit_frame) cho mỗi biến thể
   - map: 5_render/<id biến thể>/map_<id biến thể>.png + .json (khung 48, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: GIF mỗi Action trong 5_render/preview/, 1 ảnh ghép các biến thể cạnh nhau
7. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Chiêu: hoạt ảnh và hiệu ứng

Render vào `design/quai/library_warden/6_vfx/<chiêu>/`. Màu hiệu ứng theo màu nhấn của từng biến thể. Dán từng mục cho AI.

### Gáy Sách Nặng (`warden_strike`, Action attack)

```text
Chiêu library_warden.warden_strike – "Gáy Sách Nặng". Cơ chế: 120% Tấn Công lên 1 người.
Hoạt ảnh (8 khung, trúng khung 4):
- chuẩn bị: nâng một cuốn sách khổng lồ
- ra đòn: đập gáy sách xuống
- kết thúc: sách về quỹ đạo
Hiệu ứng: hit: vết đập lớn + trang giấy
Xuất 6_vfx/warden_strike/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Bão Trang (`warden_pages`, Action skill)

```text
Chiêu library_warden.warden_pages – "Bão Trang". Cơ chế: 50% Tấn Công lên cả đội.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: áo giấy xòe ra
- ra đòn: bão trang giấy cuốn về cả đội
- kết thúc: áo khép lại
Hiệu ứng: hit (mọi đồng minh): trang giấy cắt; GĐ2 trang đen
Xuất 6_vfx/warden_pages/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Gọi Sách (`warden_books`, Action summon)

```text
Chiêu library_warden.warden_books – "Gọi Sách". Cơ chế: Gọi 2 Sách Bay.
Hoạt ảnh (10 khung, quái mới xuất hiện ở khung 6):
- chuẩn bị: giơ tay, 2 cuốn sách rời quỹ đạo
- ra đòn: sách bay xuống thành Sách Bay
- kết thúc: về tư thế
Hiệu ứng: cast: 2 sách sáng xanh ngọc rơi vào vị trí trống
Xuất 6_vfx/warden_books/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Lời Nguyền Câm Lặng (`warden_curse`, Action curse)

```text
Chiêu library_warden.warden_curse – "Lời Nguyền Câm Lặng". Cơ chế: Đếm ngược 3 lượt (vẫn hành động). Hết giờ: 60% Tấn Công lên cả đội và Phong Ấn Chiến kỹ cả đội 2 lượt. Phá khiên để ngắt.
Hoạt ảnh (6 khung, lặp trong lúc có tác dụng):
- chuẩn bị: (chỉ GĐ2) chắp tay, chữ đen xoay thành vòng
- ra đòn: tụng mỗi lượt, số đếm ngược 3–2–1 hiện trên đầu
- kết thúc: hết giờ: chữ đen ập xuống cả đội; bị phá khiên: vòng chữ vỡ tan
Hiệu ứng: cast: vòng chữ đen + số đếm ngược; hit (mọi đồng minh): chỉ đỏ khâu biểu tượng Chiến kỹ
Xuất 6_vfx/warden_curse/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Chuyển giai đoạn (`phase2`, 12 khung)

```text
Hoạt ảnh chuyển giai đoạn của library_warden: khung 0–3 khựng lại, vết nứt sáng chói; khung 4–8 lớp ngoài vỡ/biến đổi đúng mô tả giai đoạn; khung 9–11 tư thế mới, gầm hoặc tỏa sóng. Hiệu ứng screen: chớp màu nhấn 2 khung + mảnh vỡ bay. Mọi Action của giai đoạn sau thêm hậu tố -p2 / -p3.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng chiêu vào `design/REVIEW.md` (chờ duyệt) kèm GIF. Duyệt xong mới dùng `99_DUA_VAO_GAME.md` với id `library_warden`.
