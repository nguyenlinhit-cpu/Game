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


## Phạm vi thực hiện
Chỉ concept và sketch. Kèm biến thể nguyên tố và giai đoạn boss để duyệt. Pixel AI là tham khảo thị giác, chưa phải sprite chuẩn.
