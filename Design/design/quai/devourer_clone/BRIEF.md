# Q11. Phân Thân – Thường

Mọi file của họ quái này nằm trong `design/quai/devourer_clone/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `devourer_clone_flame` | Lửa | `#E8552B` |
| `devourer_clone_tide` | Nước | `#3A8DDE` |
| `devourer_clone_storm` | Sét | `#A65BF2` |

Khung trận 256 px, quay sang trái. Ngoài map 32×32 px. Cao khoảng 2,4 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

Lưu ý: Chỉ có trong trận trùm cuối giai đoạn 2. Không cần sprite map.

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/devourer_clone/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`devourer_clone_flame`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a blurred smaller shadow copy of a tall figure in a long tattered coat with a vertical crack across its face, its outline burning with one element color, smoky edges, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: a blurred smaller shadow copy of a tall figure in a long tattered coat with a vertical crack across its face, its outline burning with one element color, smoky edges. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Thân bóng | `#1E1A26` |
| Áo khoác rách | `#2E2838` |
| Viền nguyên tố (màu biến thể) | `#E8552B` |
| Vết nứt mặt | `#F2D58A` |

```text
Trong design/quai/devourer_clone/, tạo 2_sketch/devourer_clone_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a), concept_front (1b), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/devourer_clone_sketch_v1.png. Thêm dòng vào design/REVIEW.md: devourer_clone | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```


## Phạm vi thực hiện
Chỉ concept và sketch. Kèm biến thể nguyên tố và giai đoạn boss để duyệt. Pixel AI là tham khảo thị giác, chưa phải sprite chuẩn.
