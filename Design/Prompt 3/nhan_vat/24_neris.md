# 24. Neris – 4★ · Nước · Săn Bắn

Mọi file của nhân vật này nằm trong `design/nhan_vat/neris/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `neris` |
| Nguyên tố | Nước `#3A8DDE` |
| Vận mệnh | Săn Bắn |
| Tính cách | Kiệm lời, kiên nhẫn, khô khan hài hước; ăn cá sống. |
| Ngoại hình gốc | Xanh biển #3A8DDE, xanh đậm, bạc, cam san hô. Bóng đen: giáo ba chĩa dài, tóc ngắn rối, kính lặn trên trán. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/neris/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A sporty tomboy diver girl with short messy navy hair, aqua eyes, tan skin, a round diving mask pushed up on her head, a deep-blue wetsuit-like outfit with coral-orange accents and silver clips. Weapon: a silver trident taller than her body. Holding the tall trident diagonally with both hands, ready to thrust, playful wink. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a sporty tomboy diver girl with short messy navy hair, aqua eyes, tan skin, a round diving mask pushed up on her head, a deep-blue wetsuit-like outfit with coral-orange accents and silver clips. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a silver trident taller than her body, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, short messy navy hair, diving mask on head, blue suit with coral accents, tall silver trident, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a sporty tomboy diver girl with short messy navy hair, aqua eyes, tan skin, a round diving mask pushed up on her head, a deep-blue wetsuit-like outfit with coral-orange accents and silver clips. Bursting up out of deep water with her silver trident thrust upward inside a towering spiral wave, bubbles everywhere. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a deep blue water background with bubbles and shafts of light, glowing water effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#1F3F7A` |
| Da | `#D9A27E` |
| Bộ đồ lặn | `#1F4E8C` |
| Xanh nước | `#3A8DDE` |
| Cam san hô | `#F2785C` |
| Bạc | `#C9D1DA` |
| Mắt | `#3AB0D8` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/neris/, tạo file Krita 2_sketch/neris_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/neris_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
neris | B2 phác thảo | v1 | design/nhan_vat/neris/2_sketch/neris_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/neris/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: 2 xương tóc.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: xoay giáo nhẹ, nhún gót
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: vác giáo lên vai, nháy mắt
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_neris.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_neris.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/neris/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#3A8DDE`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Giáo Xuyên (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill neris_opener – Đòn Mở Màn "Giáo Xuyên". Cơ chế: Quạt hẹp 40°, tầm 200 px, hồi 0,6 giây. Dập tường lửa.
Hoạt ảnh Action opener (bản map): khung 0 lùi; khung 1 lấy đà; khung 2 đâm giáo (trúng); khung 3–4 rút về.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #3A8DDE): vệt nước xoáy thẳng, tầm 3,5 ô.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Mắt Đáy Biển (tiện ích khám phá) (ngoài map, `technique`, 6 khung)

```text
Skill neris_technique – Bí Kỹ "Mắt Đáy Biển (tiện ích khám phá)". Cơ chế: 30 giây: bản đồ nhỏ hiện mọi nhóm quái trong khu kèm cấp và điểm yếu.
Hoạt ảnh Action technique (bản map): khung 0–2 kéo mặt nạ xuống; khung 3–5 nhìn quanh.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #3A8DDE): vòng sóng xanh lan trên mặt đất; mắt sáng xanh.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Đâm Giáo (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill neris_attack – Đánh thường "Đâm Giáo". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): lùi chân, kéo giáo
- khung 3–4 (ra đòn, trúng ở khung 4): đâm thẳng
- khung 5–7 (về tư thế): xoay giáo về
Hiệu ứng (water, màu #3A8DDE, lõi gần trắng, tan dần ở khung cuối): hit: vệt nước xoáy + bọt
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Ba Chĩa Xoáy (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill neris_skill – Chiến kỹ "Ba Chĩa Xoáy". Cơ chế: 190% Tấn Công lên 1 quái.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): xoay giáo trên đầu
- khung 4–6 (ra đòn, trúng ở khung 6): phóng giáo xoáy nước vào quái
- khung 7–9 (về tư thế): giáo quay về tay
Hiệu ứng (water, màu #3A8DDE, lõi gần trắng, tan dần ở khung cuối): đạn: giáo xoáy nước; hit: xoáy nước khoan
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Sóng Ngầm (110) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill neris_ultimate – Tuyệt kỹ "Sóng Ngầm (110)". Cơ chế: 380% Tấn Công lên 1 quái; chắc chắn bạo kích.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): lặn xuống, nước dâng che nửa người
- khung 6–9 (ra đòn, trúng ở khung 8): phóng lên từ dưới cùng cột sóng xuyên quái (chắc chắn bạo kích)
- khung 10–11 (về tư thế): đáp xuống vác giáo, giữ dáng cuối 2 khung
Hiệu ứng (water, màu #3A8DDE, lõi gần trắng, tan dần ở khung cuối): hit: cột sóng xuyên + chữ bạo kích vàng
Hiệu ứng toàn màn hình (screen): nhìn từ dưới nước lên, bong bóng, ánh sáng xuyên mặt nước
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `neris`.
