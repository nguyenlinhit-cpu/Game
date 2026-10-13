# 04. Kiri – 4★ · Lửa · Hòa Hợp

Mọi file của nhân vật này nằm trong `design/nhan_vat/kiri/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `kiri` |
| Nguyên tố | Lửa `#E8552B` |
| Vận mệnh | Hòa Hợp |
| Tính cách | Sôi nổi, lạc quan, hơi liều; thích đặt biệt danh cho mọi người. |
| Ngoại hình gốc | cam lửa #E8552B, vàng, đỏ thẫm; túi pháo đeo chéo; bóng đen nhận ra nhờ hai bím tóc dựng như ngòi pháo. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/kiri/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. An energetic cheerful fireworks artisan girl with bright orange hair in two upright twin braids shaped like firework fuses with tiny spark tips, amber eyes, a short crimson festival jacket with yellow stripes, star-shaped hairclip, shorts with striped stockings, a cross-body satchel full of small firework rockets. Weapon: a long signal sparkler baton like a conductor's baton, with a burning star tip. Twirling the sparkler baton above her head with one hand, big grin, one leg kicked back. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng để chuyển sang 3D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: an energetic cheerful fireworks artisan girl with bright orange hair in two upright twin braids shaped like firework fuses with tiny spark tips, amber eyes, a short crimson festival jacket with yellow stripes, star-shaped hairclip, shorts with striped stockings, a cross-body satchel full of small firework rockets. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, 3D modeling reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, 3D modeling reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a long signal sparkler baton like a conductor's baton, with a burning star tip, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, orange twin braids sticking up like fuses with spark tips, crimson jacket with yellow stripe, satchel of rockets, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: an energetic cheerful fireworks artisan girl with bright orange hair in two upright twin braids shaped like firework fuses with tiny spark tips, amber eyes, a short crimson festival jacket with yellow stripes, star-shaped hairclip, shorts with striped stockings, a cross-body satchel full of small firework rockets. Lighting a row of five big firework tubes with her sparkler baton, fireworks exploding in the night sky above, twin braids sparking. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a blazing orange-red background with flying embers and heat haze, glowing fire effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho cả Krita và Blender):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#F07A2C` |
| Da | `#F6D3BE` |
| Áo khoác | `#B3222E` |
| Sọc, kẹp sao | `#F7C948` |
| Điểm nhấn lửa | `#E8552B` |
| Túi đeo | `#6B3E26` |
| Mắt | `#F2A33A` |
| Tia lửa | `#FFE08A` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/kiri/, tạo file Krita 2_sketch/kiri_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/kiri_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
kiri | B2 phác thảo | v1 | design/nhan_vat/kiri/2_sketch/kiri_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```


## Phạm vi bản v1

Chỉ B1 concept và B2 sketch theo yêu cầu. Chưa duyệt, chưa tạo model, Blender nhân vật, hoạt ảnh hay VFX. Bộ ảnh dùng công cụ imagegen tích hợp; các ảnh sau lấy 1a làm tham chiếu. Pixel AI là ý tưởng thị giác, chưa xác nhận khung 32×32 hoặc giới hạn 12 màu.

## Ghi chú duyệt ảnh v1

- Góc sau: kẹp sao đang nằm bên trái ảnh giống góc trước; cần chuyển sang bên phải ảnh để giữ cùng phía cơ thể. Túi và tất đã đảo đúng theo góc nhìn.
- Kiểm tra ngón tay và đơn giản hóa phụ kiện vàng nếu silhouette quá rối.
- Ảnh chibi còn dài người hơn tỷ lệ 2,5 đầu mục tiêu; quyết định tỷ lệ cuối ở bước duyệt sketch.
- Pixel là concept phóng lớn, có nhiều màu và ánh sáng hơn quy chuẩn sprite; chưa dùng trực tiếp trong game.
