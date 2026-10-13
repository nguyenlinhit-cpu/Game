# Q14. Thủ Thư Câm – Tinh anh

Mọi file của họ quái này nằm trong `design/quai/mute_librarian/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `mute_librarian` | Phong | `#4FD1B5` |

Khung trận 384 px, quay sang trái. Ngoài map 32×32 px. Cao khoảng 2,8 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/mute_librarian/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`mute_librarian`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, an elite monster, bigger and more detailed than normal enemies, an elite tall silent librarian in a long robe that drags on the floor, mouth stitched shut with thread, hollow tired eyes, holding high a lantern shaped like a book that glows, loose pages orbiting slowly, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: an elite tall silent librarian in a long robe that drags on the floor, mouth stitched shut with thread, hollow tired eyes, holding high a lantern shaped like a book that glows, loose pages orbiting slowly. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 32x32 pixels, small fantasy monster, side view facing right, tall robed figure holding up a glowing book-shaped lantern, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Áo dài | `#3A4A5E` |
| Da xám | `#C9C2B8` |
| Chỉ khâu | `#8E2A2A` |
| Đèn lồng sách (Phong) | `#4FD1B5` |
| Giấy | `#F4EEDF` |

```text
Trong design/quai/mute_librarian/, tạo 2_sketch/mute_librarian_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/mute_librarian_sketch_v1.png. Thêm dòng vào design/REVIEW.md: mute_librarian | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng quái (dán cho AI)

```text
Làm việc trong design/quai/mute_librarian/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Biến thể: thay các ô màu có ghi (màu biến thể) sang màu nhấn của biến thể ngay trên ảnh concept (thay màu theo vùng), mỗi biến thể 1 sheet riêng.
3. Xương: dựng cây xương theo hình dạng (chân, cánh, xúc tu, sách bay... mỗi phần chuyển động 1 xương).
4. Hoạt ảnh trận (12 fps), quay sang trái:
   - idle 6 khung, lặp: đứng thẳng, đèn lồng đung đưa, trang giấy trôi
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6): theo Bước 5
   - hit 4 khung: giật lùi, vết nứt Ma Biến lóe sáng
   - down 6 khung: đổ xuống như áo rỗng, đèn lồng tắt
5. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel: idle 4, run 4, windup 3 (gồng trước khi vồ: co người, nháy màu nhấn). Nhìn ngang, chỉ hướng phải.
6. Render:
   - trận: 5_render/<id biến thể>/battle_<id biến thể>.png + .json (khung 384, quay trái, có hit_frame) cho mỗi biến thể
   - map: 5_render/<id biến thể>/map_<id biến thể>.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: GIF mỗi Action trong 5_render/preview/, 1 ảnh ghép các biến thể cạnh nhau
7. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Chiêu: hoạt ảnh và hiệu ứng

Render vào `design/quai/mute_librarian/6_vfx/<chiêu>/`. Màu hiệu ứng theo màu nhấn của từng biến thể. Dán từng mục cho AI.

### Gáy Sách (`ml_strike`, Action attack)

```text
Chiêu mute_librarian.ml_strike – "Gáy Sách". Cơ chế: 110% Tấn Công lên 1 người.
Hoạt ảnh (8 khung, trúng khung 4):
- chuẩn bị: giơ một cuốn sách dày
- ra đòn: đập gáy sách
- kết thúc: kẹp sách lại
Hiệu ứng: hit: vết đập + trang giấy văng
Xuất 6_vfx/ml_strike/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Suỵt (`ml_seal`, Action skill)

```text
Chiêu mute_librarian.ml_seal – "Suỵt". Cơ chế: 60% Tấn Công lên người Tấn Công cao nhất, Phong Ấn Chiến kỹ của họ 2 lượt.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: giơ đèn lồng, ngón tay đặt lên môi khâu
- ra đòn: chỉ vào người tấn công cao nhất
- kết thúc: hạ đèn
Hiệu ứng: hit: chỉ đỏ khâu chéo trên biểu tượng Chiến kỹ của người đó (Phong Ấn)
Xuất 6_vfx/ml_seal/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Tĩnh Lặng (`ml_hush`, Action skill)

```text
Chiêu mute_librarian.ml_hush – "Tĩnh Lặng". Cơ chế: 45% Tấn Công lên cả đội.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: đèn lồng sáng chói
- ra đòn: sóng tĩnh lặng lan ra
- kết thúc: đèn dịu lại
Hiệu ứng: screen-nhỏ: vòng sóng xanh ngọc; hit (mọi đồng minh): chữ 'suỵt' mờ
Xuất 6_vfx/ml_hush/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng chiêu vào `design/REVIEW.md` (chờ duyệt) kèm GIF. Duyệt xong mới dùng `99_DUA_VAO_GAME.md` với id `mute_librarian`.
