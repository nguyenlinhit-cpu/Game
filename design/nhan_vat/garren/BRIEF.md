# 05. Garren – 4★ · Mộc · Bảo Hộ

Mọi file của nhân vật này nằm trong `design/nhan_vat/garren/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `garren` |
| Nguyên tố | Mộc `#2E8B57` |
| Vận mệnh | Bảo Hộ |
| Tính cách | Nghiêm, ít nói, che chở; thỉnh thoảng kể chuyện cũ không ai hỏi. |
| Ngoại hình gốc | xanh rừng #2E8B57, nâu gỗ, đồng; khiên tròn lớn bằng gỗ; bóng đen nhận ra nhờ vai giáp mọc cành và tấm khiên to bằng nửa người. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/garren/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A stern elderly guard captain with short grey hair and a thick grey mustache, green eyes, heavy wooden and bronze armor with living tree branches and green leaves sprouting from the shoulder pauldrons, a forest-green tabard with a tree emblem, sturdy boots. Weapon: a huge round wooden shield half his height with a bronze rim and a carved tree emblem, plus a short bronze mace. Planting the huge round shield in front of him with a firm wide stance, mace resting on his shoulder. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a stern elderly guard captain with short grey hair and a thick grey mustache, green eyes, heavy wooden and bronze armor with living tree branches and green leaves sprouting from the shoulder pauldrons, a forest-green tabard with a tree emblem, sturdy boots. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a huge round wooden shield half his height with a bronze rim and a carved tree emblem, plus a short bronze mace, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, grey mustache, wooden armor with leafy branches on the shoulders, huge round wooden shield with bronze rim, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a stern elderly guard captain with short grey hair and a thick grey mustache, green eyes, heavy wooden and bronze armor with living tree branches and green leaves sprouting from the shoulder pauldrons, a forest-green tabard with a tree emblem, sturdy boots. Slamming his giant round wooden shield into the ground as a wall of enormous trees bursts up in front of him, leaves swirling. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a lush green forest background with falling leaves and flowers, glowing nature effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc, râu | `#B8B8B0` |
| Da | `#E2B08E` |
| Giáp gỗ | `#7A5232` |
| Đồng | `#B8803A` |
| Áo khoác ngoài | `#2E8B57` |
| Lá | `#6CC36A` |
| Mắt | `#3F8F4F` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/garren/, tạo file Krita 2_sketch/garren_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/garren_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
garren | B2 phác thảo | v1 | design/nhan_vat/garren/2_sketch/garren_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```


## Phạm vi bản v1

Chỉ B1 concept và B2 sketch. Dùng imagegen tích hợp, lấy 1a làm tham chiếu cho các ảnh còn lại. Chưa làm sprite, rig, hoạt ảnh hay VFX. Pixel AI chỉ là tham khảo thị giác, chưa phải sprite 32×32 chuẩn.
