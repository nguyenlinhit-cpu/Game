# 14. Celestine – 5★ · Hồn · Săn Bắn

Mọi file của nhân vật này nằm trong `design/nhan_vat/celestine/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `celestine` |
| Nguyên tố | Hồn `#F2D58A` |
| Vận mệnh | Săn Bắn |
| Tính cách | Trang nghiêm, ít cảm xúc, trung thành tuyệt đối với lời thề; ấm áp với số ít người cô tin. |
| Ngoại hình gốc | Trắng bạc, vàng hồn #F2D58A, xanh lam đêm, đen. Bóng đen: hai thanh kiếm dài bắt chéo sau lưng, vầng sáng hình mắt sau đầu. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/celestine/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A dignified elegant swordswoman, the last Eye Warden, with long straight silver-white hair, golden eyes, a white-silver and night-blue armored long coat with golden eye emblems, black gloves, two long swords crossed on her back, a radiant eye-shaped golden halo floating behind her head. Weapon: two long elegant swords with white blades and golden eye-shaped guards. Guard stance: one sword drawn and held low in front, the second still crossed on her back, the eye halo glowing softly. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a dignified elegant swordswoman, the last Eye Warden, with long straight silver-white hair, golden eyes, a white-silver and night-blue armored long coat with golden eye emblems, black gloves, two long swords crossed on her back, a radiant eye-shaped golden halo floating behind her head. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: two long elegant swords with white blades and golden eye-shaped guards, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, long silver hair, white and night-blue coat, two swords crossed on the back, glowing eye-shaped halo behind the head, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a dignified elegant swordswoman, the last Eye Warden, with long straight silver-white hair, golden eyes, a white-silver and night-blue armored long coat with golden eye emblems, black gloves, two long swords crossed on her back, a radiant eye-shaped golden halo floating behind her head. Dashing forward with both swords drawn, leaving golden afterimages, a giant radiant eye opening in the sky behind her, silver hair streaming. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a night-blue background with golden starlight and a giant glowing eye motif, glowing soul effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#EEF0F5` |
| Da | `#F6DCCB` |
| Áo trắng bạc | `#F2F3F7` |
| Xanh lam đêm | `#1E2A55` |
| Vàng hồn | `#F2D58A` |
| Găng đen | `#1A1A22` |
| Mắt | `#F2C14E` |
| Vầng sáng | `#FFF1B8` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/celestine/, tạo file Krita 2_sketch/celestine_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/celestine_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
celestine | B2 phác thảo | v1 | design/nhan_vat/celestine/2_sketch/celestine_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/celestine/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: 3 xương tóc, 2 xương vạt áo, 1 xương vầng sáng (xoay chậm).
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: Canh Giữ: một kiếm cầm thấp, vầng sáng xoay chậm. Cần thêm idle-judge (Phán Xử): hai kiếm bắt chéo trước người
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: tra hai kiếm vào lưng, nhắm mắt, vầng sáng mờ dần
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_celestine.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_celestine.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

Lưu ý riêng: Celestine có 2 tư thế. Làm thêm hoạt ảnh idle-judge và attack-judge (2 kiếm) và báo cho AI lập trình nối vào game khi đổi tư thế.

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/celestine/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#F2D58A`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Kiếm Canh (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill celestine_opener – Đòn Mở Màn "Kiếm Canh". Cơ chế: Quạt 110°, tầm 130 px, hồi 0,6 giây. Hiện lối đi ẩn.
Hoạt ảnh Action opener (bản map): khung 0 đặt tay lên chuôi; khung 1 rút kiếm; khung 2 chém (trúng); khung 3–4 tra kiếm.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #F2D58A): vệt chém trắng-vàng 110°, tầm 2 ô, con mắt nhỏ chớp ở cuối vệt.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Lời Tiên Tri (lợi thế trận kế tiếp) (ngoài map, `technique`, 6 khung)

```text
Skill celestine_technique – Bí Kỹ "Lời Tiên Tri (lợi thế trận kế tiếp)". Cơ chế: Trận kế tiếp vào trận với +2 Điểm Chiến Kỹ và ở tư thế Phán Xử.
Hoạt ảnh Action technique (bản map): khung 0–2 nhắm mắt, vầng sáng mở to; khung 3–5 mở mắt nhìn thẳng.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #F2D58A): vầng sáng hình mắt phóng to rồi thu lại; 2 viên sáng nhỏ trên đầu báo +2 Điểm Chiến Kỹ.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Nhát Canh (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill celestine_attack – Đánh thường "Nhát Canh". Cơ chế: Tư thế Canh Giữ: 100% Tấn Công, +1 Điểm Chiến Kỹ, +10 năng lượng thêm. Tư thế Phán Xử: 160% Tấn Công.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): Canh Giữ: lùi nửa bước; Phán Xử: bắt chéo 2 kiếm
- khung 3–4 (ra đòn, trúng ở khung 4): Canh Giữ: chém một đường gọn; Phán Xử: chém chéo bằng 2 kiếm
- khung 5–7 (về tư thế): về đúng tư thế đang giữ
Hiệu ứng (soul, màu #F2D58A, lõi gần trắng, tan dần ở khung cuối): hit: Canh Giữ – vệt trắng mảnh; Phán Xử – chữ X vàng
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Đổi Kiếm (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill celestine_skill – Chiến kỹ "Đổi Kiếm". Cơ chế: Đổi tư thế rồi đánh: sang Phán Xử thì 280% Tấn Công lên 1 quái; sang Canh Giữ thì kéo lượt bản thân 30%.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): sang Phán Xử: rút kiếm thứ hai từ lưng; sang Canh Giữ: tra một kiếm vào lưng
- khung 4–6 (ra đòn, trúng ở khung 6): sang Phán Xử: chém chéo hình chữ X mạnh; sang Canh Giữ: lướt lùi nhanh
- khung 7–9 (về tư thế): đứng vào tư thế mới
Hiệu ứng (soul, màu #F2D58A, lõi gần trắng, tan dần ở khung cuối): Phán Xử – hit: chữ X vàng lớn + con mắt nhỏ chớp; Canh Giữ – cast: vệt tốc độ vàng
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Nhãn Phán Quyết (130) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill celestine_ultimate – Tuyệt kỹ "Nhãn Phán Quyết (130)". Cơ chế: Vào tư thế Phán Xử, 550% Tấn Công lên 1 quái.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): vầng sáng mắt sau đầu mở to, hai kiếm giơ lên
- khung 6–9 (ra đòn, trúng ở khung 8): lướt xuyên qua mục tiêu, hai kiếm cắt nhiều đường
- khung 10–11 (về tư thế): đứng sau quái quay lưng, vẩy kiếm, giữ dáng cuối 2 khung
Hiệu ứng (soul, màu #F2D58A, lõi gần trắng, tan dần ở khung cuối): hit: 6 đường cắt trắng-vàng đan nhau rồi nổ
Hiệu ứng toàn màn hình (screen): con mắt khổng lồ nhìn xuống, nền trắng-vàng, đường cắt ngang màn hình
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `celestine`.
