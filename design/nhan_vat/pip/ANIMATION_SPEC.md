# 25. Pip – 4★ · Sét · Hòa Hợp

Mọi file của nhân vật này nằm trong `design/nhan_vat/pip/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `pip` |
| Nguyên tố | Sét `#A65BF2` |
| Vận mệnh | Hòa Hợp |
| Tính cách | Lanh lợi, vui tính, nói không ngừng; giả vờ không sợ khi rất sợ. |
| Ngoại hình gốc | Tím sét #A65BF2, vàng cam, xanh dương, xám. Bóng đen: người nhỏ thó đội mũ bảo hộ to, robot tròn bay kè kè bên vai. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/pip/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A tiny cheerful mechanic kid with short brown hair, blue eyes, an oversized yellow-orange hard hat, grey overalls with blue pockets and violet lightning patches, big work boots, and a round floating robot companion with one glowing eye hovering beside the shoulder. Weapon: the round floating robot companion (white shell, violet lightning stripes, one blue eye) plus a big wrench. Pointing forward with the wrench while the round robot buddy charges a spark beside him. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a tiny cheerful mechanic kid with short brown hair, blue eyes, an oversized yellow-orange hard hat, grey overalls with blue pockets and violet lightning patches, big work boots, and a round floating robot companion with one glowing eye hovering beside the shoulder. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: the round floating robot companion (white shell, violet lightning stripes, one blue eye) plus a big wrench, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, huge orange hard hat on a tiny body, grey overalls, small round floating robot next to the head, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a tiny cheerful mechanic kid with short brown hair, blue eyes, an oversized yellow-orange hard hat, grey overalls with blue pockets and violet lightning patches, big work boots, and a round floating robot companion with one glowing eye hovering beside the shoulder. Pulling a giant lever as his round robot buddy grows three times bigger and releases a huge violet-yellow energy pulse, hard hat tilted. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a dark violet storm background with branching lightning, glowing lightning effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Mũ bảo hộ | `#F2A23A` |
| Tóc | `#6B4A2E` |
| Da | `#F6D8C6` |
| Quần yếm | `#8C9096` |
| Túi xanh | `#3A6FD8` |
| Miếng vá sét | `#A65BF2` |
| Vỏ robot | `#EDEFF2` |
| Mắt, mắt robot | `#6FA8FF` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/pip/, tạo file Krita 2_sketch/pip_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/pip_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
pip | B2 phác thảo | v1 | design/nhan_vat/pip/2_sketch/pip_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/pip/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: robot là vật riêng có 1 xương gốc (bay quanh) + 1 xương mắt.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: robot bay vòng quanh đầu, Pip lau mồ hôi, chỉnh mũ
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: đập tay với robot, mũ lệch
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_pip.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_pip.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/pip/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#A65BF2`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Bolt Lao Tới (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill pip_opener – Đòn Mở Màn "Bolt Lao Tới". Cơ chế: Quạt 80°, tầm 140 px, hồi 0,6 giây. Cấp điện cửa máy.
Hoạt ảnh Action opener (bản map): khung 0 chỉ tay; khung 1 robot lao ra; khung 2 robot đâm (trúng); khung 3–4 robot quay về.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #A65BF2): tia điện tím đi theo robot quạt 80°, tầm 2,5 ô.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Sạc Đầy (lợi thế trận kế tiếp) (ngoài map, `technique`, 6 khung)

```text
Skill pip_technique – Bí Kỹ "Sạc Đầy (lợi thế trận kế tiếp)". Cơ chế: Trận kế tiếp, cả đội vào trận thêm 30 năng lượng.
Hoạt ảnh Action technique (bản map): khung 0–2 robot cắm dây sạc vào Pip; khung 3–5 thanh pin đầy, Pip giơ tay.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #A65BF2): thanh pin pixel đầy dần trên đầu; tia điện vàng nhỏ.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Tia Điện Nhỏ (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill pip_attack – Đánh thường "Tia Điện Nhỏ". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): chỉ cờ lê về phía quái
- khung 3–4 (ra đòn, trúng ở khung 4): robot bắn tia điện nhỏ
- khung 5–7 (về tư thế): robot quay về vai
Hiệu ứng (lightning, màu #A65BF2, lõi gần trắng, tan dần ở khung cuối): đạn: tia điện nhỏ; hit: tia nổ
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Sạc Nhanh (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill pip_skill – Chiến kỹ "Sạc Nhanh". Cơ chế: 1 đồng minh khác: +25 năng lượng và Tấn Công +15% trong 2 lượt.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): vặn cờ lê vào robot
- khung 4–6 (ra đòn, trúng ở khung 6): robot bay tới đồng minh, cắm dây sạc
- khung 7–9 (về tư thế): robot quay về
Hiệu ứng (lightning, màu #A65BF2, lõi gần trắng, tan dần ở khung cuối): hit (đồng minh): thanh pin đầy + tia điện vàng + mũi tên đỏ
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Quá Áp (100) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill pip_ultimate – Tuyệt kỹ "Quá Áp (100)". Cơ chế: Cả đội +20 năng lượng và Tốc Độ +12% trong 2 lượt.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): Pip kéo một cần gạt lớn hiện ra từ đất
- khung 6–9 (ra đòn, trúng ở khung 8): robot phóng to gấp 3, phát xung năng lượng cho cả đội
- khung 10–11 (về tư thế): robot nhỏ lại, Pip ngã ngồi cười, giữ dáng cuối 2 khung
Hiệu ứng (lightning, màu #A65BF2, lõi gần trắng, tan dần ở khung cuối): hit (đồng minh): vòng năng lượng tím-vàng + vệt tốc độ
Hiệu ứng toàn màn hình (screen): thanh pin khổng lồ đầy ở đỉnh màn hình, tia điện chạy viền
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `pip`.
