# 20. Vael – 4★ · Độc · Tri Thức

Mọi file của nhân vật này nằm trong `design/nhan_vat/vael/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `vael` |
| Nguyên tố | Độc `#9BC53D` |
| Vận mệnh | Tri Thức |
| Tính cách | Phô trương, kịch tính, thích được vỗ tay; sợ cô đơn. |
| Ngoại hình gốc | Xanh độc #9BC53D, tím hồng, đen, vàng kim. Bóng đen: mũ chóp cao lệch, áo choàng sân khấu xòe tròn. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/vael/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A flamboyant showy stage magician young man with pink-violet hair, toxic-green eyes, a tall crooked top hat, a black and gold stage tailcoat, a wide round flared cape with pink-violet lining, white gloves, a deck of glowing cards. Weapon: poison-tipped playing cards glowing green. Fanning out a hand of glowing cards with one hand, tipping his crooked top hat with the other, theatrical grin. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a flamboyant showy stage magician young man with pink-violet hair, toxic-green eyes, a tall crooked top hat, a black and gold stage tailcoat, a wide round flared cape with pink-violet lining, white gloves, a deck of glowing cards. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: poison-tipped playing cards glowing green, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, very tall crooked top hat, round flared cape with pink lining, fan of green cards, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a flamboyant showy stage magician young man with pink-violet hair, toxic-green eyes, a tall crooked top hat, a black and gold stage tailcoat, a wide round flared cape with pink-violet lining, white gloves, a deck of glowing cards. Taking a dramatic bow on a stage under a spotlight as a curtain call of exploding glowing poison cards fills the air, flared cape spread. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a dark green and purple background with glowing toxic mist and bubbles, glowing poison effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#C77DB8` |
| Da | `#F5D6C8` |
| Áo đuôi tôm | `#1E1A22` |
| Vàng kim | `#D4AF37` |
| Lót áo choàng | `#C77DB8` |
| Độc | `#9BC53D` |
| Mắt | `#9BC53D` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/vael/, tạo file Krita 2_sketch/vael_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/vael_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
vael | B2 phác thảo | v1 | design/nhan_vat/vael/2_sketch/vael_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```


## Phạm vi
Chỉ concept và sketch v1 như Nyx. Pixel là ý tưởng thị giác, chưa phải sprite chuẩn 32×32. Dùng imagegen tích hợp.
