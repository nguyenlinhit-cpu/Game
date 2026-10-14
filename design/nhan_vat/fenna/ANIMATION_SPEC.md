# 18. Fenna – 4★ · Mộc · Săn Bắn

Mọi file của nhân vật này nằm trong `design/nhan_vat/fenna/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `fenna` |
| Nguyên tố | Mộc `#2E8B57` |
| Vận mệnh | Săn Bắn |
| Tính cách | Hoang dã, thẳng thắn, ít nói trước người lạ; rất trung thành. |
| Ngoại hình gốc | Xanh lá #2E8B57, nâu da, cam lá thu, trắng lông vũ. Bóng đen: mũ trùm tai cáo, cung ngắn cong và ống tên lông vũ. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/fenna/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A nimble playful ranger girl with short russet hair, amber eyes, a leaf-green hood with fox ears, a brown leather vest, an autumn-orange scarf, white feather accents, fingerless gloves. Weapon: a short curved bow and a quiver of white-feathered arrows. Crouching low with an arrow nocked on the short bow, fox-ear hood perked up. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a nimble playful ranger girl with short russet hair, amber eyes, a leaf-green hood with fox ears, a brown leather vest, an autumn-orange scarf, white feather accents, fingerless gloves. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a short curved bow and a quiver of white-feathered arrows, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, green hood with fox ears, orange scarf, brown vest, small curved bow, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a nimble playful ranger girl with short russet hair, amber eyes, a leaf-green hood with fox ears, a brown leather vest, an autumn-orange scarf, white feather accents, fingerless gloves. Kneeling on one knee aiming a glowing leaf-green arrow, a ring of leaves swirling around the arrowhead, fox-ear hood and orange scarf blowing. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a lush green forest background with falling leaves and flowers, glowing nature effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Mũ trùm | `#2E8B57` |
| Tóc | `#B5562E` |
| Da | `#F4D2BC` |
| Áo da | `#6B4A2E` |
| Khăn cam | `#E07B2E` |
| Lông vũ | `#F4F2EC` |
| Mắt | `#E0A33A` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/fenna/, tạo file Krita 2_sketch/fenna_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/fenna_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
fenna | B2 phác thảo | v1 | design/nhan_vat/fenna/2_sketch/fenna_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/fenna/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: 1 xương mỗi tai cáo, 2 xương khăn.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: nhún người thấp, tai cáo trên mũ giật giật, mắt dõi theo
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: xoay mũi tên trên ngón tay, tai cáo vểnh
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_fenna.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_fenna.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

Lưu ý riêng: Bẫy Dây cần thêm 1 sprite pixel cái bẫy (16×16, 2 trạng thái: chờ / sập).

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/fenna/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#2E8B57`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Tên Rừng (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill fenna_opener – Đòn Mở Màn "Tên Rừng". Cơ chế: Quạt hẹp 40°, tầm 220 px, hồi 0,6 giây. Mọc cầu qua khe vực.
Hoạt ảnh Action opener (bản map): khung 0 lắp tên; khung 1 kéo; khung 2 bắn (trúng); khung 3–4 hạ cung.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #2E8B57): mũi tên lá bay thẳng tầm 3,5 ô, lá xoáy theo.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Bẫy Dây (tác động quái trên map) (ngoài map, `technique`, 6 khung)

```text
Skill fenna_technique – Bí Kỹ "Bẫy Dây (tác động quái trên map)". Cơ chế: Đặt bẫy tại chỗ (tối đa 1): nhóm quái dẫm phải bị giữ chặt 8 giây; chạm nhóm đó luôn vào trận với Ưu Thế.
Hoạt ảnh Action technique (bản map): khung 0–2 quỳ xuống buộc dây; khung 3–5 đứng dậy phủi tay.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #2E8B57): bẫy dây xuất hiện dưới chân (sprite riêng); khi sập: dây quấn quái.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Tên Nhanh (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill fenna_attack – Đánh thường "Tên Nhanh". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): rút tên thật nhanh
- khung 3–4 (ra đòn, trúng ở khung 4): bắn
- khung 5–7 (về tư thế): rút tên tiếp
Hiệu ứng (nature, màu #2E8B57, lõi gần trắng, tan dần ở khung cuối): đạn: tên lá; hit: lá bung
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Mưa Tên (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill fenna_skill – Chiến kỹ "Mưa Tên". Cơ chế: 180% Tấn Công lên 1 quái.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): bắn 3 mũi tên lên trời
- khung 4–6 (ra đòn, trúng ở khung 6): mưa tên rơi xuống 1 mục tiêu
- khung 7–9 (về tư thế): hạ cung, nhìn kết quả
Hiệu ứng (nature, màu #2E8B57, lõi gần trắng, tan dần ở khung cuối): hit: 6 mũi tên lá xanh rơi xuống một điểm
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Mũi Tên Định Mệnh (110) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill fenna_ultimate – Tuyệt kỹ "Mũi Tên Định Mệnh (110)". Cơ chế: 360% Tấn Công lên 1 quái; quái đang Phá Vỡ thì +30% Sát thương bạo kích.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): quỳ một gối, ngắm, mắt sáng, vòng lá xoay quanh mũi tên
- khung 6–9 (ra đòn, trúng ở khung 8): bắn một mũi tên lớn xuyên qua quái
- khung 10–11 (về tư thế): giữ dáng sau khi bắn 2 khung
Hiệu ứng (nature, màu #2E8B57, lõi gần trắng, tan dần ở khung cuối): hit: mũi tên lớn xuyên + vệt xanh, lá bay theo
Hiệu ứng toàn màn hình (screen): vệt xanh xuyên ngang màn hình
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `fenna`.
