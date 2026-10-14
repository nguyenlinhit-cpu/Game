# Q06. Chuột Mực Sách – Thường

Mọi file của họ quái này nằm trong `design/quai/ink_rat/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `ink_rat_wind` | Phong | `#4FD1B5` |
| `ink_rat_lightning` | Sét | `#A65BF2` |

Khung trận 256 px, quay sang trái. Ngoài map 32×32 px. Cao khoảng 0,6 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/ink_rat/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`ink_rat_wind`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a small fast rat with fur soaked and dripping with black ink, beady glowing eyes, a long tail shaped like a curved fountain-pen nib, ink paw prints, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: a small fast rat with fur soaked and dripping with black ink, beady glowing eyes, a long tail shaped like a curved fountain-pen nib, ink paw prints. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 32x32 pixels, small fantasy monster, side view facing right, small ink-black rat with a curved pen-nib tail, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Lông mực | `#1C1C26` |
| Bụng | `#4A4A5A` |
| Ngòi bút đuôi | `#B89A4A` |
| Mắt, điện (màu biến thể) | `#4FD1B5` |
| Giọt mực | `#2E2A4A` |

```text
Trong design/quai/ink_rat/, tạo 2_sketch/ink_rat_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/ink_rat_sketch_v1.png. Thêm dòng vào design/REVIEW.md: ink_rat | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```


## Phạm vi thực hiện
Chỉ concept và sketch. Kèm biến thể nguyên tố và giai đoạn boss để duyệt. Pixel AI là tham khảo thị giác, chưa phải sprite chuẩn.
