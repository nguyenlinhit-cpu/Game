# 21. Wisp – 4★ · Phong · Hư Vô

Mọi file của nhân vật này nằm trong `design/nhan_vat/wisp/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `wisp` |
| Nguyên tố | Phong `#4FD1B5` |
| Vận mệnh | Hư Vô |
| Tính cách | Rụt rè, tò mò, thích sưu tầm đồ lấp lánh; nói thì thầm. |
| Ngoại hình gốc | Xanh ngọc nhạt #4FD1B5, trắng sương, tím nhạt, bạc. Bóng đen: thân nhỏ trôi lơ lửng, đuôi như làn khói xoắn. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/wisp/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A small quiet ghost-like floating girl with pale mint-white hair, lavender eyes, a misty white robe with silver lining and pale teal accents, a smoky twisting tail instead of legs. Weapon: no weapon; she attacks with whispering wind from her hands and breath. Floating with hands cupped near her mouth as if whispering, smoky tail curling. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a small quiet ghost-like floating girl with pale mint-white hair, lavender eyes, a misty white robe with silver lining and pale teal accents, a smoky twisting tail instead of legs. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: no weapon; she attacks with whispering wind from her hands and breath, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, small floating ghost girl, pale mint hair, white robe, smoky curly tail instead of legs, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a small quiet ghost-like floating girl with pale mint-white hair, lavender eyes, a misty white robe with silver lining and pale teal accents, a smoky twisting tail instead of legs. Floating silently with eyes closed and a finger on her lips as a soundless pale wind ripples outward, colors fading into mist. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a pale teal sky background with swirling wind streaks and leaves, glowing wind effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#E6FBF6` |
| Đuôi khói | `#CFEFEA` |
| Da | `#F4E8EC` |
| Áo trắng sương | `#F2F6F7` |
| Tím nhạt | `#B9A3E3` |
| Xanh ngọc nhạt | `#4FD1B5` |
| Viền bạc | `#C7CCD4` |
| Mắt | `#B9A3E3` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/wisp/, tạo file Krita 2_sketch/wisp_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/wisp_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
wisp | B2 phác thảo | v1 | design/nhan_vat/wisp/2_sketch/wisp_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```


## Phạm vi
Chỉ concept và sketch v1 như Nyx. Pixel là ý tưởng thị giác, chưa phải sprite chuẩn 32×32. Dùng imagegen tích hợp.
