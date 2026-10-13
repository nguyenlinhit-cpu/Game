# Q10. Tay Máy Lò – Thường

Mọi file của họ quái này nằm trong `design/quai/furnace_arm/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `furnace_arm` | Lửa | `#E8552B` |

Khung trận 256 px, quay sang trái. Ngoài map 32×32 px. Cao khoảng 3,0 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

Lưu ý: Đứng hai bên Lõi Lò Biến Dạng; gốc tay nằm ngoài khung, nên khung hình cắt ở gốc.

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/furnace_arm/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`furnace_arm`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a huge curved mechanical arm emerging from a furnace wall socket, riveted dark iron segments, glowing orange joints spitting sparks, a three-fingered clamp claw, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: a huge curved mechanical arm emerging from a furnace wall socket, riveted dark iron segments, glowing orange joints spitting sparks, a three-fingered clamp claw. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 32x32 pixels, small fantasy monster, side view facing right, curved mechanical arm with a clamp claw and glowing joints, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Sắt | `#3E3A3A` |
| Đinh tán | `#8A8580` |
| Khớp nóng | `#E8552B` |
| Tia lửa | `#FFB347` |
| Ống dẫn | `#5A5F66` |

```text
Trong design/quai/furnace_arm/, tạo 2_sketch/furnace_arm_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/furnace_arm_sketch_v1.png. Thêm dòng vào design/REVIEW.md: furnace_arm | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng quái (dán cho AI)

```text
Làm việc trong design/quai/furnace_arm/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Biến thể: thay các ô màu có ghi (màu biến thể) sang màu nhấn của biến thể ngay trên ảnh concept (thay màu theo vùng), mỗi biến thể 1 sheet riêng.
3. Xương: dựng cây xương theo hình dạng (chân, cánh, xúc tu, sách bay... mỗi phần chuyển động 1 xương).
4. Hoạt ảnh trận (12 fps), quay sang trái:
   - idle 6 khung, lặp: lắc lư chậm, khớp tóe lửa
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6): theo Bước 5
   - hit 4 khung: giật lùi, vết nứt Ma Biến lóe sáng
   - down 6 khung: gãy gập, khớp tắt sáng, rơi thõng
5. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel: idle 4, run 4, windup 3 (gồng trước khi vồ: co người, nháy màu nhấn). Nhìn ngang, chỉ hướng phải.
6. Render:
   - trận: 5_render/<id biến thể>/battle_<id biến thể>.png + .json (khung 256, quay trái, có hit_frame) cho mỗi biến thể
   - map: 5_render/<id biến thể>/map_<id biến thể>.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: GIF mỗi Action trong 5_render/preview/, 1 ảnh ghép các biến thể cạnh nhau
7. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Chiêu: hoạt ảnh và hiệu ứng

Render vào `design/quai/furnace_arm/6_vfx/<chiêu>/`. Màu hiệu ứng theo màu nhấn của từng biến thể. Dán từng mục cho AI.

### Kẹp Máy (`arm_strike`, Action attack)

```text
Chiêu furnace_arm.arm_strike – "Kẹp Máy". Cơ chế: 90% Tấn Công lên 1 người.
Hoạt ảnh (8 khung, trúng khung 4):
- chuẩn bị: rút tay về, mở kẹp
- ra đòn: vươn ra kẹp mạnh
- kết thúc: thu về
Hiệu ứng: hit: tia lửa + vết kẹp
Xuất 6_vfx/arm_strike/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Nạp Nhiệt (`arm_stoke`, Action skill)

```text
Chiêu furnace_arm.arm_stoke – "Nạp Nhiệt". Cơ chế: Thêm 1 tầng Nhiệt cho Lõi Lò.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: quay về phía Lõi Lò
- ra đòn: xúc than nạp vào lõi
- kết thúc: quay lại
Hiệu ứng: cast: than đỏ bay vào lõi; lõi sáng thêm 1 vạch Nhiệt
Xuất 6_vfx/arm_stoke/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng chiêu vào `design/REVIEW.md` (chờ duyệt) kèm GIF. Duyệt xong mới dùng `99_DUA_VAO_GAME.md` với id `furnace_arm`.
