# Q13. Mẫu Thể Ma Biến – Tinh anh

Mọi file của họ quái này nằm trong `design/quai/warp_matrix/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `warp_matrix` | Độc | `#9BC53D` |

Khung trận 384 px, quay sang trái. Ngoài map 32×32 px. Cao khoảng 2,6 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

Lưu ý: Khiên mạnh/yếu theo số Mầm: thêm lớp phát sáng ở lõi, sáng hơn khi còn nhiều Mầm.

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/warp_matrix/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`warp_matrix`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, an elite monster, bigger and more detailed than normal enemies, an elite pulsing cocoon-like nest mass of warped organic matter with several tentacle roots, glowing cracks, smaller round sprout creatures clinging to it, a big glowing core visible through the membrane, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: an elite pulsing cocoon-like nest mass of warped organic matter with several tentacle roots, glowing cracks, smaller round sprout creatures clinging to it, a big glowing core visible through the membrane. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 32x32 pixels, small fantasy monster, side view facing right, pulsing round cocoon nest with tentacles and small sprouts clinging, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Màng kén | `#7A6A8A` |
| Xúc tu | `#5A4A6A` |
| Lõi (Độc) | `#9BC53D` |
| Vết nứt Ma Biến | `#B58CFF` |
| Mầm bám | `#C9B98A` |

```text
Trong design/quai/warp_matrix/, tạo 2_sketch/warp_matrix_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/warp_matrix_sketch_v1.png. Thêm dòng vào design/REVIEW.md: warp_matrix | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```


## Phạm vi thực hiện
Chỉ concept và sketch. Kèm biến thể nguyên tố và giai đoạn boss để duyệt. Pixel AI là tham khảo thị giác, chưa phải sprite chuẩn.
