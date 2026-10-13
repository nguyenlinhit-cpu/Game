# 12. Sylvaine – 5★ · Mộc · Trù Phú

Mọi file của nhân vật này nằm trong `design/nhan_vat/sylvaine/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `sylvaine` |
| Nguyên tố | Mộc `#2E8B57` |
| Vận mệnh | Trù Phú |
| Tính cách | Hiền, chậm rãi, kiên nhẫn; nói chuyện với cây như với người. |
| Ngoại hình gốc | Xanh lá #2E8B57, hồng đào, nâu đất, kem. Bóng đen: mái tóc dài kết hoa thành vòng, gậy mọc cành lá. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/sylvaine/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A kind serene forest healer woman with very long brown-green hair braided with a ring of peach-pink flowers, soft green eyes, a cream dress with a leaf-green layered capelet, peach-pink accents, root-like sandals. Weapon: a living wooden staff sprouting leafy branches and small flowers at the top. Holding the leafy staff with both hands, gentle smile, petals drifting around her. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a kind serene forest healer woman with very long brown-green hair braided with a ring of peach-pink flowers, soft green eyes, a cream dress with a leaf-green layered capelet, peach-pink accents, root-like sandals. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a living wooden staff sprouting leafy branches and small flowers at the top, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, very long hair with a ring of pink flowers, cream dress, green capelet, leafy wooden staff, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a kind serene forest healer woman with very long brown-green hair braided with a ring of peach-pink flowers, soft green eyes, a cream dress with a leaf-green layered capelet, peach-pink accents, root-like sandals. Praying with eyes closed as an entire garden of flowers blooms around her, her long flower-braided hair floating, warm green and golden light. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a lush green forest background with falling leaves and flowers, glowing nature effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#6B8F4A` |
| Hoa | `#F5A89A` |
| Da | `#F6DCC8` |
| Váy kem | `#F3EAD6` |
| Áo choàng lá | `#2E8B57` |
| Gỗ | `#7A5A3A` |
| Mắt | `#6CC36A` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/sylvaine/, tạo file Krita 2_sketch/sylvaine_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/sylvaine_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
sylvaine | B2 phác thảo | v1 | design/nhan_vat/sylvaine/2_sketch/sylvaine_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/sylvaine/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: 4 xương tóc dài, 2 xương áo choàng lá.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: ôm gậy, nghiêng đầu, cánh hoa rơi chậm quanh người
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: ngửi bông hoa trên gậy, xoay một vòng
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_sylvaine.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_sylvaine.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

Lưu ý riêng: Cây Sự Sống là vật triệu hồi: làm thêm 1 sprite cây nhỏ (cao bằng nửa nhân vật) với hoạt ảnh idle 6 khung và mọc lên 6 khung.

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/sylvaine/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#2E8B57`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Gai Hoa (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill sylvaine_opener – Đòn Mở Màn "Gai Hoa". Cơ chế: Quạt 100°, tầm 130 px, hồi 0,7 giây. Mọc cầu qua khe vực.
Hoạt ảnh Action opener (bản map): khung 0 giơ gậy; khung 1 xoay; khung 2 vung gậy, gai hoa bắn (trúng); khung 3–4 về thế.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #2E8B57): gai hoa hồng-xanh hình quạt 100°, tầm 2 ô, cánh hoa rơi.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Hạt Giống Sống (lợi thế trận kế tiếp) (ngoài map, `technique`, 6 khung)

```text
Skill sylvaine_technique – Bí Kỹ "Hạt Giống Sống (lợi thế trận kế tiếp)". Cơ chế: Trận kế tiếp, Cây Sự Sống mọc ngay đầu trận.
Hoạt ảnh Action technique (bản map): khung 0–2 cúi gieo hạt; khung 3–5 mầm nhỏ mọc lên, vỗ tay.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #2E8B57): mầm cây pixel mọc lên rồi thu nhỏ thành biểu tượng hạt giống trên đầu.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Cành Quất (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill sylvaine_attack – Đánh thường "Cành Quất". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): xoay gậy ra sau
- khung 3–4 (ra đòn, trúng ở khung 4): quất cành lá vào quái
- khung 5–7 (về tư thế): ôm gậy lại
Hiệu ứng (nature, màu #2E8B57, lõi gần trắng, tan dần ở khung cuối): hit: lá xoáy và cánh hoa bung
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Mưa Phấn Hoa (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill sylvaine_skill – Chiến kỹ "Mưa Phấn Hoa". Cơ chế: Hồi cả đội 12% Tấn Công + 33; nếu chưa có Cây Sự Sống thì gieo cây.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): cắm gậy xuống đất
- khung 4–6 (ra đòn, trúng ở khung 6): hoa nở trên gậy, phấn hoa vàng rơi xuống cả đội; Cây Sự Sống mọc sau đội nếu chưa có
- khung 7–9 (về tư thế): rút gậy, mỉm cười
Hiệu ứng (nature, màu #2E8B57, lõi gần trắng, tan dần ở khung cuối): hit (trên đồng minh): hạt phấn sáng + dấu cộng xanh; Cây Sự Sống mọc (sprite riêng)
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Vườn Hồi Sinh (140) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill sylvaine_ultimate – Tuyệt kỹ "Vườn Hồi Sinh (140)". Cơ chế: Hồi cả đội 19% Tấn Công + 57; hồi sinh 1 đồng minh đã ngã với 40% máu (1 lần mỗi trận).
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): chắp tay cầu nguyện, tóc và hoa bay lên
- khung 6–9 (ra đòn, trúng ở khung 8): cả khu vườn nở bung, ánh sáng trắng hồi sinh đồng minh ngã
- khung 10–11 (về tư thế): mở mắt, dang tay, giữ dáng cuối 2 khung
Hiệu ứng (nature, màu #2E8B57, lõi gần trắng, tan dần ở khung cuối): hit (trên đồng minh): cột sáng xanh-vàng + hoa nở dưới chân; hồi sinh: cánh hoa xoáy nâng người dậy
Hiệu ứng toàn màn hình (screen): hoa nở kín viền màn hình, ánh sáng xanh vàng
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `sylvaine`.
