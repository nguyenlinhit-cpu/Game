# 13. Orrin – 5★ · Hồn · Tri Thức

Mọi file của nhân vật này nằm trong `design/nhan_vat/orrin/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `orrin` |
| Nguyên tố | Hồn `#F2D58A` |
| Vận mệnh | Tri Thức |
| Tính cách | Uyên bác, hay quên, nói vòng vo; nghiêm khắc khi có người làm hỏng sách. |
| Ngoại hình gốc | Vàng hồn #F2D58A, nâu da thuộc, xanh đêm, trắng giấy. Bóng đen: lưng hơi gù, chồng sách bay lơ lửng quanh vai, mũ chóp mềm. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/orrin/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A kind slightly hunched elderly scholar with a long white beard and round spectacles, golden eyes, a soft floppy pointed cap, a night-blue robe with paper-white patches and brown leather straps, a stack of glowing old books floating around his shoulders. Weapon: a tall quill-shaped staff with a golden feather tip, plus floating spellbooks. Writing glowing golden runes in the air with the quill staff while books orbit his shoulders. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a kind slightly hunched elderly scholar with a long white beard and round spectacles, golden eyes, a soft floppy pointed cap, a night-blue robe with paper-white patches and brown leather straps, a stack of glowing old books floating around his shoulders. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a tall quill-shaped staff with a golden feather tip, plus floating spellbooks, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, slightly hunched, white beard, floppy cap, night-blue robe, books floating around the shoulders, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a kind slightly hunched elderly scholar with a long white beard and round spectacles, golden eyes, a soft floppy pointed cap, a night-blue robe with paper-white patches and brown leather straps, a stack of glowing old books floating around his shoulders. A giant glowing tome opening above his head, golden ancient runes spiraling down, his quill staff raised, floating books orbiting him. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a night-blue background with golden starlight and a giant glowing eye motif, glowing soul effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc, râu | `#EDEBE6` |
| Da | `#EBC6A8` |
| Áo chùng | `#1E2747` |
| Da thuộc | `#7A4E2D` |
| Giấy | `#F4EEDF` |
| Vàng hồn | `#F2D58A` |
| Mắt | `#F2D58A` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/orrin/, tạo file Krita 2_sketch/orrin_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/orrin_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
orrin | B2 phác thảo | v1 | design/nhan_vat/orrin/2_sketch/orrin_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/orrin/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: mỗi cuốn sách bay 1 xương riêng (3 xương), 2 xương râu, 1 xương mũ.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: vuốt râu, 3 cuốn sách bay chậm quanh vai, một trang lật
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: đóng sách cái bộp, vuốt râu cười
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_orrin.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_orrin.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/orrin/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#F2D58A`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Trang Sách Bay (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill orrin_opener – Đòn Mở Màn "Trang Sách Bay". Cơ chế: Quạt 90°, tầm 150 px, hồi 0,7 giây. Hiện lối đi ẩn.
Hoạt ảnh Action opener (bản map): khung 0 lật sách; khung 1 vẫy bút; khung 2 trang sách bay ra (trúng); khung 3–4 thu sách.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #F2D58A): 3 trang giấy vàng bay quạt 90°, tầm 2,5 ô.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Mắt Thư Tịch (tiện ích khám phá) (ngoài map, `technique`, 6 khung)

```text
Skill orrin_technique – Bí Kỹ "Mắt Thư Tịch (tiện ích khám phá)". Cơ chế: Hiện vị trí mọi rương và tường nứt chưa mở trong khu trên bản đồ nhỏ trong 60 giây.
Hoạt ảnh Action technique (bản map): khung 0–2 mở sách, mắt sau kính sáng; khung 3–5 nhìn quanh.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #F2D58A): con mắt vàng nhỏ trên đầu; vòng sáng vàng lan trên mặt đất.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Chữ Hồn (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill orrin_attack – Đánh thường "Chữ Hồn". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): sách bay mở ra trước mặt
- khung 3–4 (ra đòn, trúng ở khung 4): vạch bút lông, một chữ cổ vàng bay tới
- khung 5–7 (về tư thế): đẩy kính
Hiệu ứng (soul, màu #F2D58A, lõi gần trắng, tan dần ở khung cuối): hit: chữ cổ vàng nổ thành bụi sáng
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Chương Hồn (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill orrin_skill – Chiến kỹ "Chương Hồn". Cơ chế: 56% Tấn Công lên toàn bộ quái.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): 3 cuốn sách bay lên mở cùng lúc
- khung 4–6 (ra đòn, trúng ở khung 6): trang giấy bay thành bão về mọi quái
- khung 7–9 (về tư thế): sách quay về vai
Hiệu ứng (soul, màu #F2D58A, lõi gần trắng, tan dần ở khung cuối): hit (trên mọi quái): trang giấy vàng cắt qua
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Thư Tịch Khai Mở (120) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill orrin_ultimate – Tuyệt kỹ "Thư Tịch Khai Mở (120)". Cơ chế: 128% Tấn Công lên toàn bộ quái, rồi 3 lần 40% lên quái ngẫu nhiên.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): một cuốn sách khổng lồ mở trên đầu, chữ vàng xoay quanh
- khung 6–9 (ra đòn, trúng ở khung 8): cột chữ vàng giáng xuống mọi quái, rồi 3 tia chữ lần lượt bắn vào quái ngẫu nhiên (khung 9, 10, 11)
- khung 10–11 (về tư thế): gập sách lớn, giữ dáng cuối 2 khung
Hiệu ứng (soul, màu #F2D58A, lõi gần trắng, tan dần ở khung cuối): hit: cột chữ vàng; 3 tia chữ nhỏ (hit thêm ở khung 9, 10, 11)
Hiệu ứng toàn màn hình (screen): thư viện vàng hiện mờ sau nền, chữ cổ trôi
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `orrin`.
