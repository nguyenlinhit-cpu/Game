# 03. Mira – 4★ · Nước · Trù Phú

Mọi file của nhân vật này nằm trong `design/nhan_vat/mira/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `mira` |
| Nguyên tố | Nước `#3A8DDE` |
| Vận mệnh | Trù Phú |
| Tính cách | Dịu dàng, hay lo, tỉ mỉ; nói nhiều khi căng thẳng. |
| Ngoại hình gốc | xanh nước #3A8DDE, trắng, bạc; tạp dề dược sĩ, bình nước đeo hông; bóng đen nhận ra nhờ mũ trùm tai thỏ và bình hình giọt nước. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/mira/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A gentle shy apprentice pharmacist girl with short wavy silver-white hair and droopy blue eyes, a white hood with two long soft ear-like flaps lined in water blue, a white pharmacist apron over a light-blue dress, silver buttons, a large water-drop shaped glass flask with glowing blue water hanging at her hip, a small medicine pouch. Weapon: a slender silver dropper wand topped with a clear water-drop crystal. Holding the dropper wand close to her chest with both hands, slightly nervous but determined, hood flaps swaying. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a gentle shy apprentice pharmacist girl with short wavy silver-white hair and droopy blue eyes, a white hood with two long soft ear-like flaps lined in water blue, a white pharmacist apron over a light-blue dress, silver buttons, a large water-drop shaped glass flask with glowing blue water hanging at her hip, a small medicine pouch. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a slender silver dropper wand topped with a clear water-drop crystal, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, white hood with two long floppy flaps lined in blue, silver hair, white apron, big blue water-drop flask at the hip, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a gentle shy apprentice pharmacist girl with short wavy silver-white hair and droopy blue eyes, a white hood with two long soft ear-like flaps lined in water blue, a white pharmacist apron over a light-blue dress, silver buttons, a large water-drop shaped glass flask with glowing blue water hanging at her hip, a small medicine pouch. Throwing her glowing water-drop flask up into the sky, hands clasped in prayer, a gentle shining rain falling around her, hood flaps flowing. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a deep blue water background with bubbles and shafts of light, glowing water effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#E8EEF5` |
| Da | `#F7DCCB` |
| Mũ trùm, tạp dề | `#F4F6FA` |
| Váy | `#A9D3F2` |
| Lót mũ, điểm nhấn nước | `#3A8DDE` |
| Cúc bạc, đũa | `#BFC8D4` |
| Mắt | `#3A8DDE` |
| Nước phát sáng | `#CDEBFF` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/mira/, tạo file Krita 2_sketch/mira_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/mira_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
mira | B2 phác thảo | v1 | design/nhan_vat/mira/2_sketch/mira_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/mira/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: 2 xương cho mỗi vạt tai mũ (4 xương), 1 xương bình nước ở hông (đung đưa).
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: ôm đũa trước ngực, nhún nhẹ, vạt tai mũ lắc theo nhịp, thỉnh thoảng nhìn sang đồng đội
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: ôm chặt bình nước, thở phào, cúi chào nhỏ
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_mira.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_mira.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/mira/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#3A8DDE`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Giọt Sương Bắn (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill mira_opener – Đòn Mở Màn "Giọt Sương Bắn". Cơ chế: Quạt hẹp 60°, tầm 150 px, hồi 0,7 giây. Dập tường lửa (Nước).
Hoạt ảnh Action opener (bản map): khung 0 giơ đũa; khung 1 nghiêng người; khung 2 vẩy đũa (trúng); khung 3–4 về tư thế.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #3A8DDE): 3 giọt nước xanh bay hình quạt hẹp 60°, tầm 2,5 ô, vỡ thành 4 chấm khi chạm.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Mưa Sương Lành (trận kế tiếp) (ngoài map, `technique`, 6 khung)

```text
Skill mira_technique – Bí Kỹ "Mưa Sương Lành (trận kế tiếp)". Cơ chế: Trận kế tiếp cả đội có Sương Dưỡng: hồi 6% máu tối đa đầu mỗi lượt, 2 lượt.
Hoạt ảnh Action technique (bản map): khung 0–2 mở nắp bình giơ lên trời; khung 3–5 mưa sương nhỏ rơi quanh, nhắm mắt cầu nguyện.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #3A8DDE): hạt nước lấp lánh rơi quanh nhân vật bán kính 1 ô; sau đó 1 biểu tượng giọt nước nhỏ nổi trên đầu báo hiệu trận sau có Sương Dưỡng.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Giọt Sương (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill mira_attack – Đánh thường "Giọt Sương". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): chĩa đũa về phía quái, nhắm một mắt
- khung 3–4 (ra đòn, trúng ở khung 4): vẩy đũa, 3 giọt nước bắn liên tiếp
- khung 5–7 (về tư thế): giật mình vì lực bắn, chỉnh lại mũ
Hiệu ứng (water, màu #3A8DDE, lõi gần trắng, tan dần ở khung cuối): hit: giọt nước vỡ tung thành vòng tia nước nhỏ, bọt trắng
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Suối Lành (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill mira_skill – Chiến kỹ "Suối Lành". Cơ chế: Hồi 1 đồng minh 40% Tấn Công + 80, giải 1 hiệu ứng xấu.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): mở nắp bình ở hông, nước xoáy lên
- khung 4–6 (ra đòn, trúng ở khung 6): vung tay, dòng nước bay vòng cung tới đồng minh
- khung 7–9 (về tư thế): đóng nắp bình, mỉm cười với đồng minh
Hiệu ứng (water, màu #3A8DDE, lõi gần trắng, tan dần ở khung cuối): cast: xoáy nước nhỏ quanh bình; hit (trên đồng minh): cột nước trong bao lấy người, bong bóng bay lên, dấu cộng xanh; hiệu ứng xấu vỡ thành mảnh đen bay đi
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Mưa Phúc (100) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill mira_ultimate – Tuyệt kỹ "Mưa Phúc (100)". Cơ chế: Hồi cả đội 30% Tấn Công + 60, mỗi người giải 1 hiệu ứng xấu.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): tung bình nước lên cao, chắp tay cầu nguyện, vạt mũ bay
- khung 6–9 (ra đòn, trúng ở khung 8): bình vỡ trên trời thành đám mây, mưa sáng rơi xuống cả đội
- khung 10–11 (về tư thế): dang hai tay đón mưa, giữ dáng cuối 2 khung
Hiệu ứng (water, màu #3A8DDE, lõi gần trắng, tan dần ở khung cuối): cast: bình vỡ thành mây xanh nhạt; hit (trên từng đồng minh): mưa sáng + dấu cộng + bong bóng
Hiệu ứng toàn màn hình (screen): mây xanh nhạt phủ nửa trên màn hình, mưa sáng rơi chéo
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `mira`.
