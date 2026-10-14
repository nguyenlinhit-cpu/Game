# 01. Kael (Lữ khách – skin Nam) – 5★ · Hồn · Hủy Diệt

Mọi file của nhân vật này nằm trong `design/nhan_vat/traveler_male/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `traveler_male` (dùng chung bộ skill `traveler`) |
| Nguyên tố | Hồn `#F2D58A` |
| Vận mệnh | Hủy Diệt |
| Tính cách | Ít nói, tò mò, kiên định; đi tìm ký ức nhưng không bỏ rơi người gặp nạn. |
| Ngoại hình gốc | áo choàng xanh đêm (Nam) / đỏ mận (Nữ), viền vàng #F2D58A, Mảnh Hồn phát sáng ở ngực; bóng đen nhận ra nhờ vạt áo choàng xẻ đôi và lưỡi kiếm dài. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/traveler_male/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A quiet young man with short messy dark-navy hair and a long side bang, warm golden eyes, a midnight-blue long cloak whose back splits into two tails, gold trim, a glowing golden crystal shard embedded at the center of his chest, dark fitted tunic with crossed leather belts, knee-high boots. Weapon: a long slender single-edged sword with a pale gold glowing edge and a dark navy hilt. Holding the long sword low and diagonal behind him, leaning slightly forward toward the enemy, cloak tails flowing. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a quiet young man with short messy dark-navy hair and a long side bang, warm golden eyes, a midnight-blue long cloak whose back splits into two tails, gold trim, a glowing golden crystal shard embedded at the center of his chest, dark fitted tunic with crossed leather belts, knee-high boots. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a long slender single-edged sword with a pale gold glowing edge and a dark navy hilt, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, dark navy hair, midnight-blue cloak with two split tails and gold trim, tiny glowing gold dot on the chest, long sword with a pale gold edge, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a quiet young man with short messy dark-navy hair and a long side bang, warm golden eyes, a midnight-blue long cloak whose back splits into two tails, gold trim, a glowing golden crystal shard embedded at the center of his chest, dark fitted tunic with crossed leather belts, knee-high boots. Flying above the ground with both hands raising the glowing long sword overhead, a giant golden eye opening behind him, cloak and hair blown upward. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a night-blue background with golden starlight and a giant glowing eye motif, glowing soul effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#2A2F4A` |
| Da | `#F4D7C4` |
| Áo choàng ngoài | `#1F2A55` |
| Áo choàng lót | `#3B4C8A` |
| Viền vàng, Mảnh Hồn | `#F2D58A` |
| Áo trong, ủng | `#2B2B36` |
| Thân kiếm | `#C9CFD8` |
| Mắt | `#F2B84A` |
| Phát sáng | `#FFF1B8` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/traveler_male/, tạo file Krita 2_sketch/traveler_male_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/traveler_male_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
traveler_male | B2 phác thảo | v1 | design/nhan_vat/traveler_male/2_sketch/traveler_male_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/traveler_male/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: 2 xương cho mỗi vạt áo choàng (4 xương), 2 xương mái tóc trước.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: thở chậm, Mảnh Hồn ở ngực sáng lên rồi mờ theo nhịp, vạt áo choàng đung đưa nhẹ
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: vẩy kiếm rồi tra vào vỏ, áo choàng tung lên, cúi nhìn Mảnh Hồn đang sáng ở ngực
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_traveler_male.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_traveler_male.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/traveler_male/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#F2D58A`. Dán từng mục dưới đây cho AI.

Hiệu ứng skill dùng chung với `traveler_male`: chép từ `design/nhan_vat/traveler_male/6_vfx/`, chỉ làm lại hoạt ảnh nhân vật và GIF ghép bằng sprite nữ.

### Đòn Mở Màn – Vết Chém Hồn (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill traveler_opener – Đòn Mở Màn "Vết Chém Hồn". Cơ chế: Chém quạt 120°, tầm 120 px, hồi 0,6 giây. Trúng quái → Ưu Thế. Mở tường nứt (Hồn).
Hoạt ảnh Action opener (bản map): khung 0 kéo kiếm ra sau; khung 1 bước tới; khung 2 chém ngang hình quạt (trúng); khung 3–4 thu kiếm.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #F2D58A): vệt cung vàng nhạt 120°, bán kính 2 ô, 4 khung, đầu vệt trắng, đuôi tan thành chấm vàng.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Bước Hư Ảnh (khám phá) (ngoài map, `technique`, 6 khung)

```text
Skill traveler_technique – Bí Kỹ "Bước Hư Ảnh (khám phá)". Cơ chế: 1 Điểm Bí Kỹ: lướt 4 ô xuyên rào Ma Biến. Trận kế tiếp, lượt đầu được kéo lên 25%.
Hoạt ảnh Action technique (bản map): khung 0–1 thân mờ dần còn viền vàng; khung 2–4 lao tới, để lại 2 bóng ảnh trong suốt; khung 5 hiện hình lại.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #F2D58A): vệt bóng ảnh vàng nhạt dài 4 ô, mảnh sáng nhỏ rơi dọc đường; rào Ma Biến bị xuyên qua lóe tím.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Chém Rạn (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill traveler_attack – Đánh thường "Chém Rạn". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): xoay vai, kéo kiếm chéo ra sau lưng, áo choàng hất lên
- khung 3–4 (ra đòn, trúng ở khung 4): chém chéo từ trên xuống bằng một tay
- khung 5–7 (về tư thế): vẩy kiếm, đứng lại thế thủ, áo choàng rơi xuống
Hiệu ứng (soul, màu #F2D58A, lõi gần trắng, tan dần ở khung cuối): hit: vết nứt ánh sáng hình chữ X màu vàng trên mục tiêu, 6 mảnh pha lê nhỏ bắn ra
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Hồn Vỡ (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill traveler_skill – Chiến kỹ "Hồn Vỡ". Cơ chế: 125% Tấn Công mục tiêu chính, 50% hai bên.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): tay trái áp lên Mảnh Hồn ở ngực, lưỡi kiếm sáng dần từ chuôi tới mũi
- khung 4–6 (ra đòn, trúng ở khung 6): nhảy ngắn rồi cắm kiếm xuống đất trước mặt, sóng nứt lan về phía 3 quái
- khung 7–9 (về tư thế): rút kiếm khỏi đất, xoay một vòng về thế thủ
Hiệu ứng (soul, màu #F2D58A, lõi gần trắng, tan dần ở khung cuối): cast: vòng sáng vàng nở ra từ ngực; hit: vết nứt mạng nhện vàng dưới chân mục tiêu chính (to) và 2 bên (nhỏ), pha lê vàng bắn lên
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Tâm Nhãn Khai Mở (120) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill traveler_ultimate – Tuyệt kỹ "Tâm Nhãn Khai Mở (120)". Cơ chế: 2 chế độ (Q để đổi): 450% lên 1 quái, hoặc 270% chính + 160% hai bên.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): bay lên nửa thân người, con mắt vàng khổng lồ mở dần sau lưng, tóc và áo choàng bay ngược lên
- khung 6–9 (ra đòn, trúng ở khung 8): chém dọc một nhát từ trên trời xuống bằng hai tay, lưỡi kiếm dài gấp 3 bằng ánh sáng
- khung 10–11 (về tư thế): đáp xuống một gối, giữ dáng cuối 2 khung
Hiệu ứng (soul, màu #F2D58A, lõi gần trắng, tan dần ở khung cuối): cast: con mắt vàng sau lưng; hit: đường chém dọc trắng-vàng xé mục tiêu, nổ thành mảnh hồn; chế độ lan: thêm 2 đường chém nhỏ hai bên
Hiệu ứng toàn màn hình (screen): nền tối lại 70%, con mắt vàng lớn mở giữa màn hình rồi khép lại khi chém
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `traveler_male`.
