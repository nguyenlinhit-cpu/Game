# 17. Rook – 4★ · Mộc · Hủy Diệt

Mọi file của nhân vật này nằm trong `design/nhan_vat/rook/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `rook` |
| Nguyên tố | Mộc `#2E8B57` |
| Vận mệnh | Hủy Diệt |
| Tính cách | Hiền như cục đất, nổi giận như bão; nói chậm, ăn nhiều. |
| Ngoại hình gốc | Xanh lá #2E8B57, nâu gỗ, đỏ sẫm, xám đá. Bóng đen: thân hình to vuông, rìu hai lưỡi khổng lồ. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/rook/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A big boxy cheerful lumberjack warrior with a broad square body, short spiky moss-green hair and stubble, a dark red plaid shirt under wooden armor plates, stone-grey bracers, tan skin. Weapon: a giant double-bladed axe with a wooden handle and steel blades with wood-grain etching. Resting the giant double-bladed axe on his shoulder, wide stance, big grin. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a big boxy cheerful lumberjack warrior with a broad square body, short spiky moss-green hair and stubble, a dark red plaid shirt under wooden armor plates, stone-grey bracers, tan skin. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a giant double-bladed axe with a wooden handle and steel blades with wood-grain etching, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, very square body, spiky green hair, red plaid, giant double-bladed axe, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a big boxy cheerful lumberjack warrior with a broad square body, short spiky moss-green hair and stubble, a dark red plaid shirt under wooden armor plates, stone-grey bracers, tan skin. Chopping the base of a giant tree that is falling toward the enemies, his double-bladed axe glowing with red wood grain, leaves exploding. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a lush green forest background with falling leaves and flowers, glowing nature effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#4E7A3A` |
| Da | `#D8A07A` |
| Áo kẻ ca rô | `#8E2B2B` |
| Giáp gỗ | `#7A5232` |
| Bao tay đá | `#8A8A86` |
| Điểm nhấn Mộc | `#2E8B57` |
| Lưỡi rìu | `#9AA3AD` |
| Mắt | `#3F6F3A` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/rook/, tạo file Krita 2_sketch/rook_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/rook_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
rook | B2 phác thảo | v1 | design/nhan_vat/rook/2_sketch/rook_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/rook/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: không cần thêm; vân gỗ đỏ trên rìu là lớp phát sáng bật/tắt theo tầng Báo Thù.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: vác rìu, lắc vai, giậm chân
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: vác rìu, cười lớn, vỗ ngực
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_rook.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_rook.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/rook/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#2E8B57`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Rìu Bổ Đất (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill rook_opener – Đòn Mở Màn "Rìu Bổ Đất". Cơ chế: Quạt 120°, tầm 120 px, hồi 0,9 giây. Mọc cầu qua khe vực.
Hoạt ảnh Action opener (bản map): khung 0 giơ rìu; khung 1 dồn sức; khung 2 bổ xuống đất (trúng); khung 3–4 nhấc rìu.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #2E8B57): rễ và đất văng hình quạt 120°, tầm 2 ô.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Rễ Đâm (tác động quái trên map) (ngoài map, `technique`, 6 khung)

```text
Skill rook_technique – Bí Kỹ "Rễ Đâm (tác động quái trên map)". Cơ chế: Rễ trồi 4 ô phía trước: quái trúng bị trói 8 giây và đánh dấu; vào trận chúng bị Trói Rễ.
Hoạt ảnh Action technique (bản map): khung 0–2 cắm rìu xuống đất; khung 3–5 rễ chạy về trước.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #2E8B57): rễ trồi thành hàng dài 4 ô; quái trúng bị dây rễ quấn.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Bổ Rìu (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill rook_attack – Đánh thường "Bổ Rìu". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): giơ rìu cao qua đầu
- khung 3–4 (ra đòn, trúng ở khung 4): bổ thẳng xuống
- khung 5–7 (về tư thế): giật rìu lên vai
Hiệu ứng (nature, màu #2E8B57, lõi gần trắng, tan dần ở khung cuối): hit: mùn gỗ và đất tóe
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Quét Rìu (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill rook_skill – Chiến kỹ "Quét Rìu". Cơ chế: 140% Tấn Công lên mục tiêu chính, 70% lên 2 bên.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): xoay người, kéo rìu ngang
- khung 4–6 (ra đòn, trúng ở khung 6): quét ngang qua 3 quái
- khung 7–9 (về tư thế): dừng xoay, chống rìu
Hiệu ứng (nature, màu #2E8B57, lõi gần trắng, tan dần ở khung cuối): hit: vệt quét xanh lá kèm mùn gỗ trên 3 mục tiêu
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Cây Đổ (120) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill rook_ultimate – Tuyệt kỹ "Cây Đổ (120)". Cơ chế: 240% Tấn Công mục tiêu chính, 140% hai bên; mỗi tầng Báo Thù cộng thêm 40% hệ số.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): cắm rìu xuống, một cây khổng lồ mọc vụt sau lưng
- khung 6–9 (ra đòn, trúng ở khung 8): chặt gốc, cây đổ ập xuống quái
- khung 10–11 (về tư thế): phủi tay, giữ dáng cuối 2 khung
Hiệu ứng (nature, màu #2E8B57, lõi gần trắng, tan dần ở khung cuối): hit: thân cây đập xuống mục tiêu chính và 2 bên, lá văng; vân gỗ đỏ sáng theo tầng Báo Thù
Hiệu ứng toàn màn hình (screen): bóng cây đổ phủ màn hình, lá văng
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `rook`.
