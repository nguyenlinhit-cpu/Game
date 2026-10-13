# 15. Quill – 4★ · Độc · Trù Phú

Mọi file của nhân vật này nằm trong `design/nhan_vat/quill/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Mục | Nội dung |
| --- | --- |
| Id | `quill` |
| Nguyên tố | Độc `#9BC53D` |
| Vận mệnh | Trù Phú |
| Tính cách | Lém lỉnh, cẩu thả, tốt bụng; nói nhanh và hay pha chế lung tung. |
| Ngoại hình gốc | Xanh độc #9BC53D, cam đất, trắng, nâu. Bóng đen: ba lô đầy ống nghiệm, mũ kính phi công. |

## Bước 1 – Tạo ảnh concept

Dán từng prompt vào công cụ tạo ảnh (xem `00_CHUNG.md` mục 2). Tạo 1a trước; khi tạo 1b–1e luôn đính kèm ảnh 1a làm ảnh tham chiếu. Lưu ảnh đã chọn vào `design/nhan_vat/quill/1_concept/`.

### 1a. Trong trận – chibi (`1a_battle.png`)

```text
Chibi anime game character, full body, about 2.5 heads tall with a big head and large expressive eyes. A cheerful clumsy young field medic boy with messy brown hair, green eyes, a burnt-orange leather aviator cap with ear flaps, a white medic coat with a toxic-green cross, brown boots, a big backpack full of glowing test tubes. Weapon: a large brass syringe-like injector with green liquid. Holding the big injector over his shoulder like a bazooka, giving a thumbs-up, test tubes rattling in the backpack. Three-quarter view facing right. Clean cel shading with two tones and one soft highlight, colored dark lineart (not pure black), cool-tinted shadows, bright clean colors, detailed layered outfit, game character art, plain white background, single character, no text.
```

Tránh (negative, nếu công cụ có ô này):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Đứng thẳng nhìn trước/sau – tham chiếu dựng xương 2D (`1b_front.png`, `1b_back.png`)

```text
Same character as the reference image: a cheerful clumsy young field medic boy with messy brown hair, green eyes, a burnt-orange leather aviator cap with ear flaps, a white medic coat with a toxic-green cross, brown boots, a big backpack full of glowing test tubes. Full body front view, standing straight in an A-pose with arms about 30 degrees away from the body, legs slightly apart, neutral expression, symmetrical, empty hands (no weapon), chibi proportions about 2.5 heads tall, even flat lighting, no cast shadows, plain white background, clean simple readable shapes, character turnaround reference.
```

```text
Same character as the reference image, full body back view, A-pose, same proportions and outfit, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Vũ khí (`1c_weapon.png`)

```text
Game prop design: a large brass syringe-like injector with green liquid, shown large and complete, side view, clean cel shading, colored lineart, plain white background, no character, no text.
```

### 1d. Sprite ngoài map – pixel (`1d_pixel.png`, chỉ để tham khảo)

```text
Pixel art game sprite, 32x32 pixels, tiny chibi character with an oversized head (head is about 60 percent of the height) and very short body and legs, side view facing right, orange aviator cap with ear flaps, white coat, huge backpack of test tubes, big syringe, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

### 1e. Tranh tuyệt kỹ / gacha (`1e_splash.png`)

```text
Anime key visual splash art of the same character as the reference image: a cheerful clumsy young field medic boy with messy brown hair, green eyes, a burnt-orange leather aviator cap with ear flaps, a white medic coat with a toxic-green cross, brown boots, a big backpack full of glowing test tubes. Popping the cork of a giant potion bottle pulled from his backpack, a sparkling mint-green healing mist bursting out over the team. Dramatic dynamic composition, character placed on the right third of the frame, empty space on the left, a dark green and purple background with glowing toxic mist and bubbles, glowing poison effects, 16:9, high detail, cel shading with soft gradients, no text.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu (dùng cho Krita, sprite và hiệu ứng):

| Bộ phận | Mã màu |
| --- | --- |
| Tóc | `#6B4A2E` |
| Mũ phi công | `#C26A2E` |
| Da | `#F4D2BC` |
| Áo blouse | `#F4F4F0` |
| Chữ thập, thuốc | `#9BC53D` |
| Da nâu, ủng | `#5E3E26` |
| Ống nghiệm | `#CFEFD8` |
| Mắt | `#7FB43A` |

Dán cho AI (hoặc tự làm trong Krita):

```text
Trong thư mục design/nhan_vat/quill/, tạo file Krita 2_sketch/quill_sketch_v1.kra (3840×2160) gồm các lớp:
- concept_battle: ảnh 1_concept/1a_battle.png
- concept_front: ảnh 1b_front.png (và 1b_back.png nếu có)
- weapon: ảnh 1c_weapon.png
- map_pixel: ảnh 1d_pixel.png phóng ×8 (nearest)
- palette: các ô màu theo bảng màu trong file prompt, ghi tên bộ phận + mã HEX
- notes: tên, hạng, nguyên tố, vận mệnh, tính cách, dấu hiệu nhận diện, chỗ ảnh AI vẽ sai cần sửa
- your_sketch: lớp trống trên cùng để tôi vẽ đè khi duyệt
Xuất ảnh xem 2_sketch/quill_sketch_v1.png (1920×1080). Thêm dòng vào design/REVIEW.md:
quill | B2 phác thảo | v1 | design/nhan_vat/quill/2_sketch/quill_sketch_v1.png | chờ duyệt
Không đụng tới code, assets/ hay data/ của game. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng nhân vật (dán cho AI)

```text
Làm việc trong design/nhan_vat/quill/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Giữ màu theo bảng màu Bước 2; chỗ ảnh AI vẽ sai (thừa ngón, lệch màu) sửa trong Krita trước khi dựng xương.
3. Xương 2D: hông, ngực, đầu, tay/vũ khí như mẫu Mira. Xương phụ: 2 xương tai mũ, 1 xương ba lô (nảy), ống nghiệm lắc bằng 1 xương.
4. Mặt: giữ mặt của ảnh concept; cần chớp/nhắm mắt hay mở miệng thì cắt hình dán từ 1a_battle.png đặt lên lớp mặt.
5. Hoạt ảnh trận (12 fps, tên Action đúng như sau):
   - idle 6 khung, lặp: nhún nhẹ, ba lô lách cách, ống nghiệm sáng nhấp nháy
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6), ultimate 12 khung (trúng khung 8): theo Bước 5
   - hit 4 khung: giật lùi, nhắm mắt, tóc và áo bay về trước
   - down 6 khung: khuỵu xuống rồi ngã, giữ khung cuối
   - victory 8 khung, lặp: giơ ngón cái, ống nghiệm suýt rơi rồi chụp lại
6. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel; Action idle 4, run 6, dash 3, opener 5 (trúng khung 2), technique 6. Nhìn ngang, chỉ hướng phải.
7. Render:
   - trận: 5_render/battle_quill.png + .json (khung 512, góc 3/4 quay phải, có hit_frame)
   - map: 5_render/map_quill.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: 1 GIF cho mỗi Action trong 5_render/preview/, 1 ảnh ghép tất cả
8. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Skill: hoạt ảnh và hiệu ứng

Mỗi skill render vào `design/nhan_vat/quill/6_vfx/<skill>/`, ảnh xem GIF cùng thư mục. Hiệu ứng vẽ 2D bằng code theo mẫu `design/nhan_vat/mira/6_vfx/make_mira_vfx.py`, màu chủ đạo `#9BC53D`. Dán từng mục dưới đây cho AI.

### Đòn Mở Màn – Ống Nghiệm Vỡ (ngoài map, `opener`, 5 khung, trúng khung 2)

```text
Skill quill_opener – Đòn Mở Màn "Ống Nghiệm Vỡ". Cơ chế: Quạt 90°, tầm 140 px, hồi 0,7 giây. Ăn mòn cổng gỉ.
Hoạt ảnh Action opener (bản map): khung 0 rút ống nghiệm; khung 1 vung tay; khung 2 ném (trúng); khung 3–4 phủi tay.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #9BC53D): ống nghiệm vỡ, khói xanh hình quạt 90°, tầm 2,5 ô.
Xuất 6_vfx/opener/mapvfx_opener_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Bí Kỹ – Túi Thuốc (tiện ích khám phá) (ngoài map, `technique`, 6 khung)

```text
Skill quill_technique – Bí Kỹ "Túi Thuốc (tiện ích khám phá)". Cơ chế: Hồi cả đội 25% máu tối đa ngay trên map (có tác dụng khi máu giữ giữa các trận, Phase 9).
Hoạt ảnh Action technique (bản map): khung 0–2 tháo ba lô, lục tìm; khung 3–5 tung thuốc lên, vui vẻ.
Hiệu ứng pixel (khung 32–64 px, ≤ 6 màu, màu chính #9BC53D): lọ thuốc nhỏ bay vòng, dấu cộng xanh bay lên quanh nhân vật.
Xuất 6_vfx/technique/mapvfx_technique_<khung>.png + GIF xem trước. Không chép vào assets/.
```

### Đánh thường – Kim Thuốc (trong trận, `attack`, 8 khung, trúng khung 4)

```text
Skill quill_attack – Đánh thường "Kim Thuốc". Cơ chế: 100% Tấn Công lên 1 quái.
Hoạt ảnh Action attack:
- khung 0–2 (chuẩn bị): lắc ống tiêm
- khung 3–4 (ra đòn, trúng ở khung 4): lao tới chích
- khung 5–7 (về tư thế): lùi lại, thổi đầu kim
Hiệu ứng (poison, màu #9BC53D, lõi gần trắng, tan dần ở khung cuối): hit: giọt xanh bắn + dấu độc nhỏ
Xuất 6_vfx/attack/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Chiến kỹ – Liều Đôi (trong trận, `skill`, 10 khung, trúng khung 6)

```text
Skill quill_skill – Chiến kỹ "Liều Đôi". Cơ chế: Hồi 1 đồng minh 35% Tấn Công + 70 và gắn Độc Quill (40% Tấn Công sát thương Độc mỗi lượt, 2 lượt) lên quái ngẫu nhiên.
Hoạt ảnh Action skill:
- khung 0–3 (chuẩn bị): rút 2 ống nghiệm (xanh nhạt và xanh độc)
- khung 4–6 (ra đòn, trúng ở khung 6): ném ống xanh nhạt về đồng minh, ống xanh độc về một quái
- khung 7–9 (về tư thế): lau mồ hôi trán
Hiệu ứng (poison, màu #9BC53D, lõi gần trắng, tan dần ở khung cuối): hit (đồng minh): bong bóng xanh nhạt + dấu cộng; hit (quái): khói độc
Xuất 6_vfx/skill/<cast|hit|screen>/<khung>.png (khung 512), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

### Tuyệt kỹ – Thuốc Giải Vạn Năng (100) (trong trận, `ultimate`, 12 khung, trúng khung 8)

```text
Skill quill_ultimate – Tuyệt kỹ "Thuốc Giải Vạn Năng (100)". Cơ chế: Hồi cả đội 25% Tấn Công + 60 và giải 1 hiệu ứng xấu mỗi người.
Hoạt ảnh Action ultimate:
- khung 0–5 (chuẩn bị): lôi bình thuốc lớn từ ba lô, lắc thật mạnh
- khung 6–9 (ra đòn, trúng ở khung 8): bật nắp, phun sương thuốc khắp đội
- khung 10–11 (về tư thế): ngồi bệt thở, giơ ngón cái, giữ dáng cuối 2 khung
Hiệu ứng (poison, màu #9BC53D, lõi gần trắng, tan dần ở khung cuối): hit (trên đồng minh): sương bạc hà lấp lánh + dấu cộng
Hiệu ứng toàn màn hình (screen): sương xanh bạc hà lấp lánh trôi ngang màn hình
Cắt cảnh: dùng 1e_splash.png, cắt dải giữa 1920×540, trượt từ phải sang trái 0,8 giây, nền màu nguyên tố.
Xuất 6_vfx/ultimate/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024), cộng GIF ghép nhân vật + hiệu ứng đúng thời điểm. Ghi hit_frame vào JSON. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng skill vào `design/REVIEW.md` (chờ duyệt) kèm đường dẫn GIF. Bạn duyệt xong (cả B2, B4, từng skill) thì mới dùng `99_DUA_VAO_GAME.md` với id `quill`.
