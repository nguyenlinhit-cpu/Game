# Q15. Người Gác Thư Viện – Boss

Mọi file của họ quái này nằm trong `design/quai/library_warden/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `library_warden` | Phong | `#4FD1B5` |

Khung trận 768 px, quay sang trái. Ngoài map 48×48 px. Cao khoảng 6,0 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

Giai đoạn:

- GĐ1: áo giấy kín, sách xoay đều, màu sáng
- GĐ2 – Lời Nguyền Câm Lặng (máu ≤ 50%): áo giấy bung thành chữ đen bay, mắt tím, sách đen cháy mép

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/library_warden/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`library_warden`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, a huge imposing boss: a very tall librarian guardian wearing a flared cloak made entirely of layered paper pages, a high collar, a calm masked face, hundreds of books orbiting around it like satellites, long sleeves, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

### 1a-p2. Giai đoạn 2 (`1a_battle_p2.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, the same huge library guardian in its second phase: the paper cloak has burst open into a storm of flying black letters and torn pages, eyes glowing intense violet, the orbiting books now black and burning at the edges, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: a huge imposing boss: a very tall librarian guardian wearing a flared cloak made entirely of layered paper pages, a high collar, a calm masked face, hundreds of books orbiting around it like satellites, long sleeves. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 48x48 pixels, small fantasy monster, side view facing right, very tall figure in a flared paper cloak with a ring of books orbiting it, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Áo giấy | `#EDE4CF` |
| Chữ đen | `#1E1A22` |
| Bìa sách | `#5A3A2E` |
| Phép (Phong) | `#4FD1B5` |
| Mắt GĐ2 | `#A65BF2` |
| Mặt nạ | `#D9D2C2` |

```text
Trong design/quai/library_warden/, tạo 2_sketch/library_warden_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a, 1a_p2), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/library_warden_sketch_v1.png. Thêm dòng vào design/REVIEW.md: library_warden | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```


## Phạm vi thực hiện
Chỉ concept và sketch. Kèm biến thể nguyên tố và giai đoạn boss để duyệt. Pixel AI là tham khảo thị giác, chưa phải sprite chuẩn.
