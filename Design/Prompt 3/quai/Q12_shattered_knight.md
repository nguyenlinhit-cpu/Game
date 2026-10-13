# Q12. Kỵ Sĩ Vỡ Vụn – Tinh anh

Mọi file của họ quái này nằm trong `design/quai/shattered_knight/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `shattered_knight` | Nước | `#3A8DDE` |

Khung trận 384 px, quay sang trái. Ngoài map 32×32 px. Cao khoảng 3,0 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/shattered_knight/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`shattered_knight`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, an elite monster, bigger and more detailed than normal enemies, an elite giant knight, 1.5 times the height of a person, with cracked shattered plate armor revealing glowing pale-blue ice inside the cracks, a broken cape, a very long lance pointed forward, a cracked helmet with one horn missing, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: an elite giant knight, 1.5 times the height of a person, with cracked shattered plate armor revealing glowing pale-blue ice inside the cracks, a broken cape, a very long lance pointed forward, a cracked helmet with one horn missing. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 32x32 pixels, small fantasy monster, side view facing right, big knight with cracked armor showing blue ice, very long lance pointed forward, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Giáp | `#6E7A88` |
| Băng bên trong | `#9FE3FF` |
| Vết nứt sáng | `#3A8DDE` |
| Áo choàng rách | `#2E3A55` |
| Thương | `#B8C4D0` |

```text
Trong design/quai/shattered_knight/, tạo 2_sketch/shattered_knight_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/shattered_knight_sketch_v1.png. Thêm dòng vào design/REVIEW.md: shattered_knight | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng quái (dán cho AI)

```text
Làm việc trong design/quai/shattered_knight/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Biến thể: thay các ô màu có ghi (màu biến thể) sang màu nhấn của biến thể ngay trên ảnh concept (thay màu theo vùng), mỗi biến thể 1 sheet riêng.
3. Xương: dựng cây xương theo hình dạng (chân, cánh, xúc tu, sách bay... mỗi phần chuyển động 1 xương).
4. Hoạt ảnh trận (12 fps), quay sang trái:
   - idle 6 khung, lặp: đứng nặng, băng trong vết nứt sáng nhấp nháy, hơi lạnh bốc
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6): theo Bước 5
   - hit 4 khung: giật lùi, vết nứt Ma Biến lóe sáng
   - down 6 khung: giáp vỡ tung, khối băng bên trong đổ sập
   - hoạt ảnh thêm: charge (6 khung, lặp): Tích Tụ – hạ thấp người, chĩa thương, băng sáng dần, mặt đất đóng băng dưới chân; hiện biểu tượng cảnh báo
5. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel: idle 4, run 4, windup 3 (gồng trước khi vồ: co người, nháy màu nhấn). Nhìn ngang, chỉ hướng phải.
6. Render:
   - trận: 5_render/<id biến thể>/battle_<id biến thể>.png + .json (khung 384, quay trái, có hit_frame) cho mỗi biến thể
   - map: 5_render/<id biến thể>/map_<id biến thể>.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: GIF mỗi Action trong 5_render/preview/, 1 ảnh ghép các biến thể cạnh nhau
7. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Chiêu: hoạt ảnh và hiệu ứng

Render vào `design/quai/shattered_knight/6_vfx/<chiêu>/`. Màu hiệu ứng theo màu nhấn của từng biến thể. Dán từng mục cho AI.

### Kiếm Gãy (`sk_slash`, Action attack)

```text
Chiêu shattered_knight.sk_slash – "Kiếm Gãy". Cơ chế: 110% Tấn Công lên 1 người.
Hoạt ảnh (8 khung, trúng khung 4):
- chuẩn bị: nâng thương
- ra đòn: đâm/chém một nhát
- kết thúc: rút thương
Hiệu ứng: hit: vệt băng + mảnh giáp
Xuất 6_vfx/sk_slash/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Vung Mảnh Vỡ (`sk_sweep`, Action skill)

```text
Chiêu shattered_knight.sk_sweep – "Vung Mảnh Vỡ". Cơ chế: 80% Tấn Công lên 1 người và 50% lên người bên cạnh.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: xoay thương ngang
- ra đòn: vung qua 2 người
- kết thúc: chống thương
Hiệu ứng: hit: mảnh băng bay trên mục tiêu chính và người bên cạnh
Xuất 6_vfx/sk_sweep/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Lao Vỡ Vụn (`sk_charge`, Action charge → skill)

```text
Chiêu shattered_knight.sk_charge – "Lao Vỡ Vụn". Cơ chế: Tích tụ 1 lượt rồi lao tới: 350% Tấn Công lên 1 người. Phá khiên lúc đang tích tụ thì hủy đòn.
Hoạt ảnh (lượt 1: hoạt ảnh báo trước lặp 6 khung; lượt 2: skill 10 khung, trúng khung 6):
- chuẩn bị: lượt 1: hoạt ảnh charge (báo trước)
- ra đòn: lượt 2: lao tới xuyên 1 người
- kết thúc: trượt dừng, băng tóe
Hiệu ứng: cast: băng tụ ở mũi thương + cảnh báo; hit: vụ nổ băng lớn; bị phá khiên khi đang tích tụ: băng vỡ vụn, quỵ xuống
Xuất 6_vfx/sk_charge/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng chiêu vào `design/REVIEW.md` (chờ duyệt) kèm GIF. Duyệt xong mới dùng `99_DUA_VAO_GAME.md` với id `shattered_knight`.
