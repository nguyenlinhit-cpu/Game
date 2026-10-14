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


## Phạm vi thực hiện
Chỉ concept và sketch. Kèm biến thể nguyên tố và giai đoạn boss để duyệt. Pixel AI là tham khảo thị giác, chưa phải sprite chuẩn.
