# 06. Nyx – 4★ · Sét · Hư Vô

Mọi file của nhân vật này nằm trong `design/nhan_vat/nyx/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `nyx` |
| Nguyên tố | Sét `#A65BF2` |
| Vận mệnh | Hư Vô |
| Tính cách | Lạnh lùng, châm chọc, cực kỳ thông minh; ghét bị gọi là "nhóc". |
| Ngoại hình gốc | tím điện #A65BF2, đen, bạc; găng tay cuộn dây đồng, kính bảo hộ đẩy lên trán; bóng đen nhận ra nhờ chiếc ăng-ten cong trên mũ và đuôi dây cáp. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/nyx/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A cool sarcastic young engineer girl with a short asymmetric black bob with one violet streak, sharp violet eyes, an oversized black work jacket with electric-violet trim, safety goggles pushed up on her forehead, a cap with one curved antenna, thick copper-coil gauntlets, a long cable with a plug hanging from her belt like a tail, tool belt. Weapon: thick copper-coil gauntlets crackling with violet electricity. One gauntlet raised with sparks jumping between the fingers, the other hand in her jacket pocket, bored expression. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a cool sarcastic young engineer girl with a short asymmetric black bob with one violet streak, sharp violet eyes, an oversized black work jacket with electric-violet trim, safety goggles pushed up on her forehead, a cap with one curved antenna, thick copper-coil gauntlets, a long cable with a plug hanging from her belt like a tail, tool belt. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: thick copper-coil gauntlets crackling with violet electricity, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, black bob, cap with a curved antenna, oversized black jacket with violet trim, cable tail, big copper gauntlets, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a cool sarcastic young engineer girl with a short asymmetric black bob with one violet streak, sharp violet eyes, an oversized black work jacket with electric-violet trim, safety goggles pushed up on her forehead, a cap with one curved antenna, thick copper-coil gauntlets, a long cable with a plug hanging from her belt like a tail, tool belt. Kneeling with both copper gauntlets punched into the ground, goggles down, antenna glowing, a violet electromagnetic storm spreading out from her. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a dark violet storm background with branching lightning, glowing lightning effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#1E1B26` |
| Lọn tóc tím | `#A65BF2` |
| Da | `#F3D6C6` |
| Áo khoác | `#24212E` |
| Viền điện | `#A65BF2` |
| Găng đồng | `#C77A3A` |
| Kính, kim loại | `#BFC3CC` |
| Mắt | `#B07BFF` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/nyx/, tạo file Krita 2_sketch/nyx_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/nyx_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
nyx | B2 phác thảo | v1 | design/nhan_vat/nyx/2_sketch/nyx_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```


## Phạm vi bản v1

Chỉ concept và sketch. Dùng imagegen tích hợp, lấy ảnh 1a làm tham chiếu cho các ảnh còn lại. Chưa làm rig, sprite, hoạt ảnh hay VFX. Pixel AI là ý tưởng thị giác, chưa phải sprite 32×32 chuẩn.

## Ghi chú bản chọn

Đã chỉnh tỷ lệ đầu/thân và đặt lại lọn tóc tím ở góc sau cho đúng phía cơ thể. Găng là trang bị đeo: giữ trên hai tay ở A-pose, không có vật cầm hoặc tia điện. Kiểm tra khớp ngón găng và điểm nối dây cáp khi duyệt.
