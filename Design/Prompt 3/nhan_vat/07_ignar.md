# 07. Ignar – 5★ · Lửa · Hủy Diệt

Mọi file của nhân vật này nằm trong `design/nhan_vat/ignar/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `ignar` |
| Nguyên tố | Lửa `#E8552B` |
| Vận mệnh | Hủy Diệt |
| Tính cách | Cộc lốc, nóng tính, che giấu sự tốt bụng; coi búa rèn như bạn. |
| Ngoại hình gốc | Đỏ cam #E8552B, đen than, đồng thau, xám tro. Bóng đen: vai trái phồng lớn quấn xích, búa rèn cán dài vác sau lưng. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/ignar/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A muscular hot-blooded young blacksmith warrior with spiky ash-grey hair with ember-orange tips, red-orange eyes, a huge iron pauldron wrapped in chains on his left shoulder, a charcoal-black leather apron over a red-orange tunic, brass buckles, soot marks on cheeks. Weapon: a giant long-handled forge hammer with a glowing molten-orange head. Carrying the giant forge hammer over his right shoulder, chest out, confident grin. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a muscular hot-blooded young blacksmith warrior with spiky ash-grey hair with ember-orange tips, red-orange eyes, a huge iron pauldron wrapped in chains on his left shoulder, a charcoal-black leather apron over a red-orange tunic, brass buckles, soot marks on cheeks. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a giant long-handled forge hammer with a glowing molten-orange head, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, spiky grey hair with orange tips, big chained iron left shoulder, black apron, giant hammer with glowing head, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a muscular hot-blooded young blacksmith warrior with spiky ash-grey hair with ember-orange tips, red-orange eyes, a huge iron pauldron wrapped in chains on his left shoulder, a charcoal-black leather apron over a red-orange tunic, brass buckles, soot marks on cheeks. Leaping high with the giant molten forge hammer raised over his head, the ground below cracking open with erupting lava. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a blazing orange-red background with flying embers and heat haze, glowing fire effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#8E8A86` |
| Đuôi tóc lửa | `#E8552B` |
| Da | `#E9B996` |
| Tạp dề | `#2A2523` |
| Áo | `#C2402A` |
| Đồng thau | `#C8A045` |
| Sắt, xích | `#5A5F66` |
| Đầu búa nung | `#FFB347` |
| Mắt | `#E8552B` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/ignar/, tạo file Krita 2_sketch/ignar_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/ignar_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
ignar | B2 phác thảo | v1 | design/nhan_vat/ignar/2_sketch/ignar_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/ignar/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: 2 xương cho xích ở vai, 1 xương vạt tạp dề.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: vác búa trên vai, nhún vai, hơi nóng bốc từ đầu búa
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: nện cán búa xuống đất, đấm ngực, cười lớn
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_ignar.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_ignar.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/ignar/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#E8552B`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Búa Lửa Giáng (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill ignar_opener – Đòn Mở Màn "Búa Lửa Giáng". Cơ chế: Nện búa hình quạt 100°, tầm 110 px, hồi 0,8 giây. Đốt dây leo.
Hoạt ảnh Action opener (bản map): khung 0 nhấc búa; khung 1 giơ cao; khung 2 nện xuống (trúng); khung 3–4 nhấc lên vai.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #E8552B): vụ nổ tàn lửa hình quạt 100°, tầm 2 ô, đá vụn.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Bước Chân Lửa (tác động quái trên map) (ngoài map, `technique`, 6 khung)

```text
Skill ignar_technique – Bí Kỹ "Bước Chân Lửa (tác động quái trên map)". Cơ chế: Lao về trước 5 ô để lại vệt lửa: quái chạm vệt bị đánh dấu; vào trận với nhóm đó, mọi quái mất 20% khiên.
Hoạt ảnh Action technique (bản map): khung 0 cúi người; khung 1–4 lao tới; khung 5 trượt dừng.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #E8552B): vệt lửa trên đất dài 5 ô cháy 2 giây; quái chạm vào có dấu lửa trên đầu.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Búa Than (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill ignar_attack – Đánh thường "Búa Than". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): kéo búa từ vai ra sau lưng
- khung 3–4 (ra đòn, trúng ở khung 4): nện búa thẳng xuống
- khung 5–7 (về tư thế): kéo búa về vai
Hiệu ứng (fire, màu #E8552B, lõi gần trắng, tan dần ở khung cuối): hit: tia lửa than bắn tung, vòng khói ngắn
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Lò Rèn Tự Thiêu (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill ignar_skill – Chiến kỹ "Lò Rèn Tự Thiêu". Cơ chế: Tiêu 15% máu hiện tại. 162% Tấn Công lên mục tiêu chính, 81% lên 2 quái bên cạnh.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): đấm đầu búa vào ngực mình, lửa bùng khắp thân, da đỏ rực (tiêu máu)
- khung 4–6 (ra đòn, trúng ở khung 6): quét búa ngang một vòng qua 3 quái
- khung 7–9 (về tư thế): thở ra khói, xoay búa về vai
Hiệu ứng (fire, màu #E8552B, lõi gần trắng, tan dần ở khung cuối): cast: lửa bao thân + số máu mất màu đỏ; hit: vụ nổ lửa trên mục tiêu chính (to) và 2 bên (nhỏ)
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Núi Lửa Bùng (130) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill ignar_ultimate – Tuyệt kỹ "Núi Lửa Bùng (130)". Cơ chế: 244% Tấn Công lên toàn bộ quái, hồi lại máu bằng 10% sát thương gây ra.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): nhảy thật cao, giơ búa bằng hai tay
- khung 6–9 (ra đòn, trúng ở khung 8): nện búa xuống đất, dung nham phun lên dưới mọi quái
- khung 10–11 (về tư thế): đứng dậy, luồng lửa nhỏ bay về người (hồi máu), giữ dáng cuối 2 khung
Hiệu ứng (fire, màu #E8552B, lõi gần trắng, tan dần ở khung cuối): hit (trên quái): cột dung nham phun; hồi máu: 5 đốm lửa bay về Ignar
Hiệu ứng toàn màn hình (screen): mặt đất nứt đỏ, dung nham sáng, khói đen bốc lên
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `ignar`.
