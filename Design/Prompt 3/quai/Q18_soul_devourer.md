# Q18. Kẻ Nuốt Mảnh Hồn – Boss

Mọi file của họ quái này nằm trong `design/quai/soul_devourer/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `soul_devourer` | Hồn | `#F2D58A` |

Khung trận 768 px, quay sang trái. Ngoài map 48×48 px. Cao khoảng 6,0 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

Giai đoạn:

- GĐ1: dáng người, vòng Mảnh Hồn vàng
- GĐ2 – Phân Thân (máu ≤ 66%): thân tách mảnh, vòng sáng chia 3 màu, gọi 3 Phân Thân
- GĐ3 – Nuốt Hồn (hạ hết phân thân): vết nứt nuốt nửa thân, nền tối

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/soul_devourer/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`soul_devourer`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, a huge imposing final boss: a tall gaunt figure in a long tattered coat, once a friend of the hero, a vertical glowing crack splitting its face that acts as a mouth, a ring of stolen glowing soul shards floating behind its back like a halo, long clawed hands, dark night colors with golden soul light, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

### 1a-p2. Giai đoạn 2 (`1a_battle_p2.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, the same final boss in phase two: its body splitting into fragments, the ring of soul shards behind it divided into three colors (orange fire, blue water, violet lightning), corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

### 1a-p3. Giai đoạn 3 (`1a_battle_p3.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, the same final boss in phase three: the vertical crack has swallowed half of its body into a void, the background darkening, soul shards being sucked into the crack, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: a huge imposing final boss: a tall gaunt figure in a long tattered coat, once a friend of the hero, a vertical glowing crack splitting its face that acts as a mouth, a ring of stolen glowing soul shards floating behind its back like a halo, long clawed hands, dark night colors with golden soul light. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 48x48 pixels, small fantasy monster, side view facing right, tall figure in a long tattered coat with a ring of glowing shards behind its back, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Áo khoác rách | `#1E1A26` |
| Da xám | `#8A8696` |
| Vết nứt, mảnh hồn | `#F2D58A` |
| Hư không | `#0A0810` |
| GĐ2 lửa | `#E8552B` |
| GĐ2 nước | `#3A8DDE` |
| GĐ2 sét | `#A65BF2` |

```text
Trong design/quai/soul_devourer/, tạo 2_sketch/soul_devourer_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a, 1a_p2, 1a_p3), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/soul_devourer_sketch_v1.png. Thêm dòng vào design/REVIEW.md: soul_devourer | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng quái (dán cho AI)

```text
Làm việc trong design/quai/soul_devourer/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Biến thể: thay các ô màu có ghi (màu biến thể) sang màu nhấn của biến thể ngay trên ảnh concept (thay màu theo vùng), mỗi biến thể 1 sheet riêng.
3. Xương: dựng cây xương theo hình dạng (chân, cánh, xúc tu, sách bay... mỗi phần chuyển động 1 xương).
4. Hoạt ảnh trận (12 fps), quay sang trái:
   - idle 6 khung, lặp: lơ lửng nhẹ, vòng Mảnh Hồn xoay chậm, vết nứt mặt phập phồng
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6): theo Bước 5
   - hit 4 khung: giật lùi, vết nứt Ma Biến lóe sáng
   - down 6 khung: vết nứt khép lại, Mảnh Hồn bay ra khắp nơi, thân tan thành tro
   - hoạt ảnh thêm: telegraph (6 khung, lặp): gồng Xung Hư Không; swallow (6 khung, lặp): đếm ngược Nuốt Hồn; summon (10 khung): tách 3 Phân Thân; phase2, phase3 (12 khung); hành động GĐ2 thêm -p2, GĐ3 thêm -p3
5. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel: idle 4, run 4, windup 3 (gồng trước khi vồ: co người, nháy màu nhấn). Nhìn ngang, chỉ hướng phải.
6. Render:
   - trận: 5_render/<id biến thể>/battle_<id biến thể>.png + .json (khung 768, quay trái, có hit_frame) cho mỗi biến thể
   - map: 5_render/<id biến thể>/map_<id biến thể>.png + .json (khung 48, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: GIF mỗi Action trong 5_render/preview/, 1 ảnh ghép các biến thể cạnh nhau
7. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Chiêu: hoạt ảnh và hiệu ứng

Render vào `design/quai/soul_devourer/6_vfx/<chiêu>/`. Màu hiệu ứng theo màu nhấn của từng biến thể. Dán từng mục cho AI.

### Cắn Hồn (`dev_bite`, Action attack)

```text
Chiêu soul_devourer.dev_bite – "Cắn Hồn". Cơ chế: 120% Tấn Công lên 1 người.
Hoạt ảnh (8 khung, trúng khung 4):
- chuẩn bị: vết nứt mặt mở toác
- ra đòn: lao tới cắn hồn
- kết thúc: lùi về
Hiệu ứng: hit: vết cắn tối + mảnh sáng bị hút ra
Xuất 6_vfx/dev_bite/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Nuốt Ánh Sáng (`dev_devour`, Action skill)

```text
Chiêu soul_devourer.dev_devour – "Nuốt Ánh Sáng". Cơ chế: 50% Tấn Công lên cả đội và hút 1 buff của mỗi người.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: vòng Mảnh Hồn xoay nhanh
- ra đòn: hút ánh sáng từ cả đội
- kết thúc: nuốt, thân sáng lên
Hiệu ứng: hit (mọi đồng minh): biểu tượng buff bị kéo bay về vết nứt
Xuất 6_vfx/dev_devour/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Xung Hư Không (`dev_pulse`, Action telegraph → skill)

```text
Chiêu soul_devourer.dev_pulse – "Xung Hư Không". Cơ chế: Báo trước 1 lượt: 110% Tấn Công lên cả đội. Phá khiên để hủy.
Hoạt ảnh (lượt 1: hoạt ảnh báo trước lặp 6 khung; lượt 2: skill 10 khung, trúng khung 6):
- chuẩn bị: lượt 1: co người, vết nứt sáng (cảnh báo)
- ra đòn: lượt 2: xung hư không
- kết thúc: đứng thẳng
Hiệu ứng: screen: vòng hư không đen lan ra; bị phá khiên: vết nứt bị nghẹn, lóe vàng
Xuất 6_vfx/dev_pulse/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Bóng Nuốt (`dev_shadow`, Action skill)

```text
Chiêu soul_devourer.dev_shadow – "Bóng Nuốt". Cơ chế: 40% Tấn Công lên cả đội.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: (GĐ2) thân mờ, bóng lan dài
- ra đòn: bóng nuốt quét qua cả đội
- kết thúc: bóng rút về
Hiệu ứng: hit (mọi đồng minh): bóng tối quấn chân
Xuất 6_vfx/dev_shadow/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Nuốt Hồn (`dev_swallow`, Action swallow)

```text
Chiêu soul_devourer.dev_swallow – "Nuốt Hồn". Cơ chế: Đếm ngược 2 lượt (vẫn hành động). Hết giờ: 180% Tấn Công lên cả đội. Gây đủ 10% máu tối đa của nó trong lúc đếm ngược để ngắt.
Hoạt ảnh (6 khung, lặp trong lúc có tác dụng):
- chuẩn bị: (GĐ3) vết nứt mở rộng, đếm ngược 2–1 trên đầu
- ra đòn: hết giờ: nuốt hồn cả đội
- kết thúc: gây đủ sát thương để ngắt: vết nứt khép lại đau đớn
Hiệu ứng: screen: màn hình bị hút về giữa; hit (mọi đồng minh): mảnh sáng bị hút
Xuất 6_vfx/dev_swallow/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Chuyển giai đoạn (`phase2`, `phase3`, 12 khung)

```text
Hoạt ảnh chuyển giai đoạn của soul_devourer: khung 0–3 khựng lại, vết nứt sáng chói; khung 4–8 lớp ngoài vỡ/biến đổi đúng mô tả giai đoạn; khung 9–11 tư thế mới, gầm hoặc tỏa sóng. Hiệu ứng screen: chớp màu nhấn 2 khung + mảnh vỡ bay. Mọi Action của giai đoạn sau thêm hậu tố -p2 / -p3.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng chiêu vào `design/REVIEW.md` (chờ duyệt) kèm GIF. Duyệt xong mới dùng `99_DUA_VAO_GAME.md` với id `soul_devourer`.
