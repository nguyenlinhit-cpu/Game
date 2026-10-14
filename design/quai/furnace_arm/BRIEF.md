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


## Phạm vi thực hiện
Chỉ concept và sketch. Kèm biến thể nguyên tố và giai đoạn boss để duyệt. Pixel AI là tham khảo thị giác, chưa phải sprite chuẩn.
