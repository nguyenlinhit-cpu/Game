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

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/wisp/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: 5 xương đuôi khói, 2 xương tóc.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: trôi lên xuống, đuôi khói xoắn
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: xoay vòng lơ lửng, cười khẽ
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_wisp.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_wisp.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/wisp/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#4FD1B5`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Hơi Thở Lạnh (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill wisp_opener – Đòn Mở Màn "Hơi Thở Lạnh". Cơ chế: Quạt 100°, tầm 140 px, hồi 0,6 giây. Thổi tan sương mù.
Hoạt ảnh Action opener (bản map): khung 0 hít vào; khung 1 phồng má; khung 2 thổi (trúng); khung 3–4 trôi về.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #4FD1B5): hơi thở lạnh trắng-xanh hình quạt 100°, tầm 2,5 ô, tinh thể nhỏ.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Gió Hút (tiện ích khám phá) (ngoài map, `technique`, 6 khung)

```text
Skill wisp_technique – Bí Kỹ "Gió Hút (tiện ích khám phá)". Cơ chế: 20 giây: tự hút vật phẩm rơi và Hộp Bí Kỹ trong bán kính 6 ô.
Hoạt ảnh Action technique (bản map): khung 0–5 xoay tròn chậm, hai tay dang.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #4FD1B5): xoáy gió nhẹ bán kính 6 ô (mờ), vật phẩm bay về.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Gió Rít (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill wisp_attack – Đánh thường "Gió Rít". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): hít sâu
- khung 3–4 (ra đòn, trúng ở khung 4): thổi luồng gió rít
- khung 5–7 (về tư thế): che miệng
Hiệu ứng (wind, màu #4FD1B5, lõi gần trắng, tan dần ở khung cuối): hit: luồng gió mờ xoáy
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Lời Quên Lãng (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill wisp_skill – Chiến kỹ "Lời Quên Lãng". Cơ chế: 70% Tấn Công lên 1 quái, gắn Lãng Quên (Tốc Độ −12%, 2 lượt) và Giảm Tấn Công 15% (2 lượt).
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): thì thầm, chữ mờ bay quanh
- khung 4–6 (ra đòn, trúng ở khung 6): thổi lời quên vào quái
- khung 7–9 (về tư thế): đặt ngón tay lên môi
Hiệu ứng (wind, màu #4FD1B5, lõi gần trắng, tan dần ở khung cuối): hit: vòng khói tím-xanh quanh đầu quái + biểu tượng chậm và giảm tấn công
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Cơn Gió Câm (110) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill wisp_ultimate – Tuyệt kỹ "Cơn Gió Câm (110)". Cơ chế: 60% Tấn Công lên toàn bộ quái, gắn Lãng Quên lên tất cả.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): im lặng, nhắm mắt, mọi thứ chậm lại
- khung 6–9 (ra đòn, trúng ở khung 8): sóng gió câm lan ra khắp mọi quái
- khung 10–11 (về tư thế): mở mắt, giữ dáng cuối 2 khung
Hiệu ứng (wind, màu #4FD1B5, lõi gần trắng, tan dần ở khung cuối): hit (trên mọi quái): quái mờ đi + biểu tượng Lãng Quên
Hiệu ứng toàn màn hình (screen): màu nhạt dần như sương, viền màn hình trắng mờ
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `wisp`.
