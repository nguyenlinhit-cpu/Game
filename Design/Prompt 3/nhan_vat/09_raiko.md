# 09. Raiko – 5★ · Sét · Săn Bắn

Mọi file của nhân vật này nằm trong `design/nhan_vat/raiko/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `raiko` |
| Nguyên tố | Sét `#A65BF2` |
| Vận mệnh | Săn Bắn |
| Tính cách | Tự tin, lạnh lùng khi săn, trẻ con khi rảnh; thích thi bắn. |
| Ngoại hình gốc | Tím sét #A65BF2, trắng bạc, đen, vàng chanh. Bóng đen: cung dài cao hơn người, tóc buộc cao như tia sét. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/raiko/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A sharp focused young archer woman with very long silver-white hair in a high ponytail shaped like a lightning bolt, lime-yellow eyes, a white and black hunting outfit with violet lightning-pattern trims, a short cape, arm guard. Weapon: a longbow taller than her body, dark metal with violet electricity crackling along the limbs. Holding the tall longbow vertically at her side, an arrow between her fingers, eyes narrowed at the target. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a sharp focused young archer woman with very long silver-white hair in a high ponytail shaped like a lightning bolt, lime-yellow eyes, a white and black hunting outfit with violet lightning-pattern trims, a short cape, arm guard. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a longbow taller than her body, dark metal with violet electricity crackling along the limbs, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, high zigzag silver ponytail, white and black outfit, very tall bow with violet sparks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a sharp focused young archer woman with very long silver-white hair in a high ponytail shaped like a lightning bolt, lime-yellow eyes, a white and black hunting outfit with violet lightning-pattern trims, a short cape, arm guard. Drawing her giant longbow straight up toward a dark thunderstorm sky, a massive violet lightning bolt about to strike, ponytail floating with static. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a dark violet storm background with branching lightning, glowing lightning effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#E7E9F0` |
| Da | `#F6D8C8` |
| Áo trắng | `#F3F3F7` |
| Áo đen | `#22202A` |
| Điểm nhấn sét | `#A65BF2` |
| Vàng chanh | `#D9F25A` |
| Thân cung | `#3A3550` |
| Mắt | `#D9F25A` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/raiko/, tạo file Krita 2_sketch/raiko_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/raiko_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
raiko | B2 phác thảo | v1 | design/nhan_vat/raiko/2_sketch/raiko_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/raiko/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: 4 xương đuôi tóc, 1 xương áo choàng, dây cung uốn bằng 2 xương.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: đứng nghiêng, tóc đuôi ngựa đung đưa, điện chạy dọc cung
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: xoay cung một vòng trên tay, gió thổi tóc
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_raiko.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_raiko.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/raiko/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#A65BF2`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Tên Sấm (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill raiko_opener – Đòn Mở Màn "Tên Sấm". Cơ chế: Bắn thẳng: quạt hẹp 30°, tầm 260 px, hồi 0,7 giây. Cấp điện cửa máy.
Hoạt ảnh Action opener (bản map): khung 0 lắp tên; khung 1 kéo cung; khung 2 buông (trúng); khung 3–4 hạ cung.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #A65BF2): mũi tên sét bay thẳng tầm 4 ô, vệt điện mảnh.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Lôi Tiễn (tác động quái trên map) (ngoài map, `technique`, 6 khung)

```text
Skill raiko_technique – Bí Kỹ "Lôi Tiễn (tác động quái trên map)". Cơ chế: Bắn tên 8 ô về trước: nhóm quái đầu tiên trúng bị choáng 6 giây và đánh dấu; vào trận, quái chính bị Dấu Sấm sẵn.
Hoạt ảnh Action technique (bản map): khung 0–1 rút tên khắc; khung 2–3 kéo căng, cung sáng; khung 4 buông; khung 5 hạ cung.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #A65BF2): mũi tên sét bay 8 ô; nhóm quái đầu tiên trúng có ký hiệu tia sét trên đầu và sao choáng.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Tên Điện (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill raiko_attack – Đánh thường "Tên Điện". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): lắp tên, kéo cung
- khung 3–4 (ra đòn, trúng ở khung 4): buông tên
- khung 5–7 (về tư thế): hạ cung, ngón tay còn tia điện
Hiệu ứng (lightning, màu #A65BF2, lõi gần trắng, tan dần ở khung cuối): đạn: tên sét bay thẳng; hit: tia nổ nhỏ hình chữ thập
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Dấu Sấm (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill raiko_skill – Chiến kỹ "Dấu Sấm". Cơ chế: 147% Tấn Công lên 1 quái và gắn Dấu Sấm (3 lượt).
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): rút một mũi tên khắc ký hiệu sét, ký hiệu sáng lên
- khung 4–6 (ra đòn, trúng ở khung 6): bắn, tên cắm vào quái
- khung 7–9 (về tư thế): chỉ tay vào quái như đánh dấu
Hiệu ứng (lightning, màu #A65BF2, lõi gần trắng, tan dần ở khung cuối): hit: ký hiệu tia sét khắc lơ lửng trên đầu quái, nhấp nháy (Dấu Sấm)
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Thiên Lôi Giáng (120) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill raiko_ultimate – Tuyệt kỹ "Thiên Lôi Giáng (120)". Cơ chế: 315% Tấn Công lên 1 quái; nếu quái mang Dấu Sấm thì thêm 60%.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): kéo cung chĩa thẳng lên trời, mây sấm tụ lại
- khung 6–9 (ra đòn, trúng ở khung 8): buông tên, sét khổng lồ giáng xuống 1 quái
- khung 10–11 (về tư thế): hạ cung, tóc còn dựng vì điện, giữ dáng cuối 2 khung
Hiệu ứng (lightning, màu #A65BF2, lõi gần trắng, tan dần ở khung cuối): hit: cột sét trắng-tím giáng thẳng; nếu có Dấu Sấm: dấu nổ thêm một vòng điện
Hiệu ứng toàn màn hình (screen): trời tối, mây sấm, chớp trắng toàn màn hình 1 khung
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `raiko`.
