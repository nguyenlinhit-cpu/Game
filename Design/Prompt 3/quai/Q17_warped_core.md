# Q17. Lõi Lò Biến Dạng – Boss

Mọi file của họ quái này nằm trong `design/quai/warped_core/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `warped_core` | Lửa | `#E8552B` |

Khung trận 768 px, quay sang trái. Ngoài map 48×48 px. Cao khoảng 5,0 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

Giai đoạn:

- GĐ1: lửa tím trong khe nứt, quay chậm
- GĐ2 – Lò Quá Tải (máu ≤ 50%): lửa trắng chói, vỏ bung các tấm tản nhiệt

Lưu ý: Đi cùng 2 Tay Máy Lò (file riêng furnace_arm). Đặt lõi ở giữa, 2 tay hai bên.

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/warped_core/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`warped_core`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, a huge imposing boss: a giant spherical furnace core slowly rotating inside a mechanical ring, cracked dark metal shell revealing violet fire inside, heavy pipes and rivets, heat haze around it, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

### 1a-p2. Giai đoạn 2 (`1a_battle_p2.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, the same giant spherical furnace core in its overloaded second phase: the fire inside has turned blinding white, heat fins and plates of the shell have burst open, glowing red-hot edges, sparks everywhere, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: a huge imposing boss: a giant spherical furnace core slowly rotating inside a mechanical ring, cracked dark metal shell revealing violet fire inside, heavy pipes and rivets, heat haze around it. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 48x48 pixels, small fantasy monster, side view facing right, big mechanical sphere with a ring around it and violet fire in the cracks, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Vỏ kim loại | `#3E3A44` |
| Vành quay | `#6E6A72` |
| Lửa tím GĐ1 | `#9B5BF2` |
| Lửa trắng GĐ2 | `#FFF4E0` |
| Mép nung đỏ | `#E8552B` |
| Ống dẫn | `#5A5F66` |

```text
Trong design/quai/warped_core/, tạo 2_sketch/warped_core_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a, 1a_p2), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/warped_core_sketch_v1.png. Thêm dòng vào design/REVIEW.md: warped_core | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng quái (dán cho AI)

```text
Làm việc trong design/quai/warped_core/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Biến thể: thay các ô màu có ghi (màu biến thể) sang màu nhấn của biến thể ngay trên ảnh concept (thay màu theo vùng), mỗi biến thể 1 sheet riêng.
3. Xương: dựng cây xương theo hình dạng (chân, cánh, xúc tu, sách bay... mỗi phần chuyển động 1 xương).
4. Hoạt ảnh trận (12 fps), quay sang trái:
   - idle 6 khung, lặp: quay chậm, vành khuyên xoay ngược chiều, lửa phập phồng
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6): theo Bước 5
   - hit 4 khung: giật lùi, vết nứt Ma Biến lóe sáng
   - down 6 khung: ngừng quay, vỏ nứt toác, lửa tắt dần
   - hoạt ảnh thêm: telegraph (6 khung, lặp): chuẩn bị Quá Nhiệt; phase2 (12 khung); hiển thị tầng Nhiệt: 5 vạch sáng trên vành quay (lớp sáng bật dần 0–5); mọi hành động GĐ2 thêm hậu tố -p2
5. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel: idle 4, run 4, windup 3 (gồng trước khi vồ: co người, nháy màu nhấn). Nhìn ngang, chỉ hướng phải.
6. Render:
   - trận: 5_render/<id biến thể>/battle_<id biến thể>.png + .json (khung 768, quay trái, có hit_frame) cho mỗi biến thể
   - map: 5_render/<id biến thể>/map_<id biến thể>.png + .json (khung 48, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: GIF mỗi Action trong 5_render/preview/, 1 ảnh ghép các biến thể cạnh nhau
7. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Chiêu: hoạt ảnh và hiệu ứng

Render vào `design/quai/warped_core/6_vfx/<chiêu>/`. Màu hiệu ứng theo màu nhấn của từng biến thể. Dán từng mục cho AI.

### Lửa Lõi (`core_flare`, Action attack)

```text
Chiêu warped_core.core_flare – "Lửa Lõi". Cơ chế: 110% Tấn Công lên 1 người.
Hoạt ảnh (8 khung, trúng khung 4):
- chuẩn bị: một khe nứt mở rộng
- ra đòn: phun lửa vào 1 người
- kết thúc: khe khép
Hiệu ứng: đạn: luồng lửa tím (GĐ2 trắng); hit: nổ lửa
Xuất 6_vfx/core_flare/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Sóng Nhiệt (`core_wave`, Action skill)

```text
Chiêu warped_core.core_wave – "Sóng Nhiệt". Cơ chế: 50% Tấn Công lên cả đội.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: vành quay tăng tốc
- ra đòn: tỏa sóng nhiệt lên cả đội
- kết thúc: vành chậm lại
Hiệu ứng: screen-nhỏ: không khí méo vì nhiệt; hit (mọi đồng minh): vệt nóng
Xuất 6_vfx/core_wave/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Quá Nhiệt (`core_meltdown`, Action telegraph → skill)

```text
Chiêu warped_core.core_meltdown – "Quá Nhiệt". Cơ chế: Từ 4 tầng Nhiệt: báo trước 1 lượt rồi nổ, 160% Tấn Công lên cả đội và xả hết Nhiệt. Phá khiên để hủy (và mất 3 tầng).
Hoạt ảnh (lượt 1: hoạt ảnh báo trước lặp 6 khung; lượt 2: skill 10 khung, trúng khung 6):
- chuẩn bị: từ 4 tầng Nhiệt: lượt 1 vỏ đỏ rực, các vạch Nhiệt nhấp nháy (cảnh báo)
- ra đòn: lượt 2: nổ, xả hết Nhiệt
- kết thúc: vỏ nguội, bốc khói
Hiệu ứng: screen: chớp trắng + sóng nổ; hit (mọi đồng minh): lửa; bị phá khiên: hơi xả ra từ ống, mất 3 vạch
Xuất 6_vfx/core_meltdown/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Chuyển giai đoạn (`phase2`, 12 khung)

```text
Hoạt ảnh chuyển giai đoạn của warped_core: khung 0–3 khựng lại, vết nứt sáng chói; khung 4–8 lớp ngoài vỡ/biến đổi đúng mô tả giai đoạn; khung 9–11 tư thế mới, gầm hoặc tỏa sóng. Hiệu ứng screen: chớp màu nhấn 2 khung + mảnh vỡ bay. Mọi Action của giai đoạn sau thêm hậu tố -p2 / -p3.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng chiêu vào `design/REVIEW.md` (chờ duyệt) kèm GIF. Duyệt xong mới dùng `99_DUA_VAO_GAME.md` với id `warped_core`.
