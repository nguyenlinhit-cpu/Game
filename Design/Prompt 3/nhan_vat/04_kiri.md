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

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: an energetic cheerful fireworks artisan girl with bright orange hair in two upright twin braids shaped like firework fuses with tiny spark tips, amber eyes, a short crimson festival jacket with yellow stripes, star-shaped hairclip, shorts with striped stockings, a cross-body satchel full of small firework rockets. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
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

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

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

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/kiri/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: 3 xương cho mỗi bím tóc (6 xương), 1 xương túi đeo.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: nhún nhảy tại chỗ, xoay gậy pháo một vòng, bím tóc nảy theo
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: tung một quả pháo nhỏ nổ hình ngôi sao, nhảy lên giơ hai tay
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_kiri.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_kiri.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/kiri/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#E8552B`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Tia Lửa (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill kiri_opener – Đòn Mở Màn "Tia Lửa". Cơ chế: Quạt 90°, tầm 130 px, hồi 0,6 giây. Đốt dây leo (Lửa).
Hoạt ảnh Action opener (bản map): khung 0 giơ gậy; khung 1 vung ra trước; khung 2 tia lửa bắn ra (trúng); khung 3–4 xoay gậy về.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #E8552B): chùm tia lửa cam-vàng hình quạt 90°, tầm 2 ô, tàn lửa rơi.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Pháo Hoa Mồi (quái trên map) (ngoài map, `technique`, 6 khung)

```text
Skill kiri_technique – Bí Kỹ "Pháo Hoa Mồi (quái trên map)". Cơ chế: Ném pháo 3 ô phía trước, bán kính 2,5 ô: quái choáng 8 giây và bị đánh dấu; vào trận với nhóm đó thì mọi quái bị Thiêu Đốt (50% Tấn Công của Kiri mỗi lượt, 2 lượt).
Hoạt ảnh Action technique (bản map): khung 0–1 rút pháo từ túi; khung 2–3 ném vòng cung; khung 4–5 che tai cười.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #E8552B): quả pháo bay vòng cung 3 ô, nổ hoa lửa bán kính 2,5 ô; quái trúng có dấu sao vàng trên đầu.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Tia Lửa (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill kiri_attack – Đánh thường "Tia Lửa". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): thổi vào đầu gậy, đầu sao bùng sáng
- khung 3–4 (ra đòn, trúng ở khung 4): chĩa gậy, bắn 1 tia pháo thẳng
- khung 5–7 (về tư thế): gậy giật lùi, cười hì hì
Hiệu ứng (fire, màu #E8552B, lõi gần trắng, tan dần ở khung cuối): cast: tia lửa ở đầu gậy; hit: nổ hoa lửa nhỏ 5 cánh
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Thổi Bùng (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill kiri_skill – Chiến kỹ "Thổi Bùng". Cơ chế: Kéo lượt 1 đồng minh khác 50%, Tấn Công +20% trong 2 lượt.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): xoay gậy như nhạc trưởng hai vòng
- khung 4–6 (ra đòn, trúng ở khung 6): chỉ gậy về đồng minh, một quả pháo bay vòng tới chân họ
- khung 7–9 (về tư thế): nháy mắt, giơ ngón cái
Hiệu ứng (fire, màu #E8552B, lõi gần trắng, tan dần ở khung cuối): hit (trên đồng minh): vòng lửa vàng bùng quanh chân, mũi tên đỏ đi lên (tăng tấn công), vệt tốc độ ngang (kéo lượt)
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Pháo Hoa Rực Rỡ (110) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill kiri_ultimate – Tuyệt kỹ "Pháo Hoa Rực Rỡ (110)". Cơ chế: 60% Tấn Công lên toàn bộ quái; cả đội Tăng sát thương +20% trong 2 lượt.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): cắm 5 ống pháo xuống đất trước mặt, châm ngòi bằng gậy
- khung 6–9 (ra đòn, trúng ở khung 8): 5 quả pháo phóng lên, nổ trên đầu mọi quái
- khung 10–11 (về tư thế): ngửa mặt nhìn pháo hoa, hai tay chống hông, giữ dáng cuối 2 khung
Hiệu ứng (fire, màu #E8552B, lõi gần trắng, tan dần ở khung cuối): hit (trên quái): pháo hoa nổ cam-vàng-đỏ; buff (trên đồng minh): ánh sáng vàng rọi xuống
Hiệu ứng toàn màn hình (screen): nền tối lại, pháo hoa nhiều màu nở khắp nửa trên màn hình
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `kiri`.
