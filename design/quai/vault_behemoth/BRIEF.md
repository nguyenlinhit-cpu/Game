# Q16. Cự Thú Kho Chứa – Boss

Mọi file của họ quái này nằm trong `design/quai/vault_behemoth/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `vault_behemoth` | Nước | `#3A8DDE` |

Khung trận 768 px, quay sang trái. Ngoài map 48×48 px. Cao khoảng 5,0 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

Giai đoạn:

- GĐ1: lưng phủ băng và thùng hàng, chậm
- GĐ2 – Băng Vỡ (máu ≤ 50%): băng nứt rơi, lộ thân đỏ, hơi nóng, nhanh và dữ hơn

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/vault_behemoth/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`vault_behemoth`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, a huge imposing boss: a massive four-legged beast, wide and low with its head lowered, its back piled high with frozen cargo crates like a mountain, thick frost and icicles all over, small fierce eyes, heavy tusks, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

### 1a-p2. Giai đoạn 2 (`1a_battle_p2.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, the same massive four-legged beast in its second phase: the ice on its back has cracked and fallen apart revealing an angry red scarred body underneath, steam rising, eyes blazing, crates shattered, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: a huge imposing boss: a massive four-legged beast, wide and low with its head lowered, its back piled high with frozen cargo crates like a mountain, thick frost and icicles all over, small fierce eyes, heavy tusks. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 48x48 pixels, small fantasy monster, side view facing right, huge low four-legged beast with a mountain of frozen crates on its back, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Da thú | `#4A5A6E` |
| Băng | `#BFE8F7` |
| Thùng hàng | `#8A6A4A` |
| Ngà | `#EDE6D6` |
| Thân đỏ GĐ2 | `#B23A3A` |
| Mắt | `#9FE3FF` |

```text
Trong design/quai/vault_behemoth/, tạo 2_sketch/vault_behemoth_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a, 1a_p2), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/vault_behemoth_sketch_v1.png. Thêm dòng vào design/REVIEW.md: vault_behemoth | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```


## Phạm vi thực hiện
Chỉ concept và sketch. Kèm biến thể nguyên tố và giai đoạn boss để duyệt. Pixel AI là tham khảo thị giác, chưa phải sprite chuẩn.
