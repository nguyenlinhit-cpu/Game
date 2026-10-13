# 00 – Phần dùng chung (đọc trước, làm 1 lần)

Nguyên tắc: mọi thiết kế nằm trong thư mục `design/` ở gốc repo. Godot bỏ qua thư mục này (có file `.gdignore`). Code, `assets/`, `data/`, `tools/` của game giữ nguyên cho tới khi bạn duyệt. Chỉ `99_DUA_VAO_GAME.md` mới được đưa đồ đã duyệt vào game.

## 1. Quy trình cho mỗi con

1. **Ảnh concept:** dán prompt Bước 1 của file con đó vào công cụ tạo ảnh, chọn ảnh đẹp nhất.
2. **Phác thảo Krita:** ghép ảnh concept, bảng màu, ghi chú vào 1 file `.kra`. → **Bạn duyệt.**
3. *(bỏ – game 2D không cần mô hình 3D)*
4. **Sprite 2D:** sprite trận bằng xương 2D uốn ảnh concept 1a; sprite pixel ngoài map vẽ tay. Xuất sheet + JSON và GIF xem thử. → **Bạn duyệt.**
5. **Skill:** hiệu ứng từng skill vẽ 2D bằng code, GIF ghép với sprite. → **Bạn duyệt.**
6. **Đưa vào game:** chỉ khi mọi bước của con đó đã duyệt, dùng `99_DUA_VAO_GAME.md`.

Gợi ý thứ tự: Mira trước (thử trọn quy trình), rồi Mầm Ma Biến, Lữ khách, Kiri, Garren, Nyx, rồi các nhân vật 5★, 4★, quái, tinh anh, boss.

## 2. Công cụ

| Việc | Công cụ gợi ý | Ghi chú |
| --- | --- | --- |
| Tạo ảnh concept | ChatGPT (tạo ảnh), Gemini, Midjourney (`--niji 6`), Krita AI Diffusion | Krita AI Diffusion chạy ngay trong Krita, cần card NVIDIA khoảng 6 GB VRAM trở lên hoặc dịch vụ cloud của plugin |
| Sprite trận, sprite map, hiệu ứng | AI lập trình (Claude Code…) viết/chạy script Python trong `design/` | Script chạy bằng `blender -b -P script.py` chỉ để có sẵn Python + numpy và đọc/ghi PNG; không dựng cảnh 3D |
| Phác thảo, sửa ảnh, pixel | Krita | Sửa ảnh concept trước khi dựng xương; sửa pixel trực tiếp trong `map_base.txt` |

Giá, giới hạn miễn phí và quyền dùng thương mại của các công cụ trên thay đổi thường xuyên. Kiểm tra trước khi dùng cho game phát hành.

## 3. Giữ đúng một nhân vật qua nhiều ảnh

- Tạo ảnh 1a trước. Khi tạo 1b, 1c, 1d, 1e luôn đính kèm ảnh 1a và giữ câu "same character as the reference image".
- Midjourney: dùng tham chiếu nhân vật (`--cref` + link ảnh 1a).
- Ảnh gần đúng mà sai chi tiết nhỏ (thừa ngón, lệch màu) thì sửa trong Krita, đừng tạo lại cả ảnh.
- Lưu mọi ảnh đã chọn đúng tên trong file con, để AI ở bước sau tìm thấy.

## 4. Phong cách (đã nằm sẵn trong từng prompt)

- **Trong trận:** chibi anime cao khoảng 2,5 đầu, mắt to, tô cel 2 tông, nét màu tối (không đen tuyền), bóng ngả lạnh. Phe ta quay phải, quái quay trái. Sprite khung 512 px (quái 256 / 384 / 768).
- **Ngoài map:** pixel art kiểu roguelike: khung 32×32 (boss 48), đầu khoảng 60% chiều cao, viền 1 px `#141018`, tối đa 12 màu, chỉ vẽ hướng phải.
- Ảnh tham khảo của bạn (chibi trong trận, hiệp sĩ pixel ngoài map) chỉ dùng để lấy phong cách, không chép nhân vật hay giao diện của game khác.

## 5. Thiết lập thư mục `design/` – dán 1 lần cho AI

```text
Bạn làm việc trong repo game Aethelgard (Godot 4). Việc này chỉ được tạo/sửa file bên trong thư mục design/. Không sửa bất kỳ file nào ngoài design/ (code, assets/, data/, tools/, project.godot giữ nguyên).

1. Tạo design/ ở gốc repo, có file .gdignore (để Godot bỏ qua), và:
   - design/REVIEW.md: bảng duyệt | Id | Bước | Bản | Ảnh/GIF xem | Trạng thái | Ghi chú của bạn |, phần đầu ghi hướng dẫn ngắn cho tôi.
     Trạng thái: "chờ duyệt" (AI đặt), "duyệt", "sửa", "bỏ" (chỉ tôi đặt). AI không bao giờ ghi "duyệt".
   - design/nhan_vat/<id>/ và design/quai/<id>/ cho mọi id trong danh sách, mỗi thư mục có 1_concept/, 2_sketch/, 4_rig2d/, 5_render/preview/, 6_vfx/.
   - design/_tools/ chứa script dùng chung: build_sketch.py (mục 2), make_gif.py (ghi GIF không cần thư viện ngoài).
2. design/_tools/build_sketch.py: ghép ảnh concept + ô bảng màu + ghi chú thành file Krita .kra có đủ lớp (dựng .ora rồi dùng Krita mở và lưu .kra, chạy offscreen; không có Krita thì xuất .ora và báo tôi), xuất ảnh xem PNG 1920×1080.
3. Không làm 3D, không dùng Blender dựng cảnh. Mẫu cho mọi con là các script của Mira (chép sang thư mục của con mới rồi chỉnh):
   - design/nhan_vat/mira/4_rig2d/rig_battle.py – sprite trận bằng xương 2D:
     · bỏ nền trắng ảnh 1a bằng loang từ mép ảnh; xương có pivot + vùng ảnh hưởng (đoạn thẳng + bán kính, mép mềm), cha–con;
     · phần đè lên mặt hoặc xoay nhiều (tay, vũ khí) là lớp riêng trọng số cứng; lớp nền dưới nó tô lấp bằng loang màu;
     · tư thế từng Action là khung khoá (xoay/dời/co giãn mỗi xương) nội suy mượt; vạt áo, tóc, phụ kiện đung đưa cộng thêm;
     · vẽ ×2 rồi thu nhỏ; xuất 5_render/battle_<id>.png + .json (frame_size, anchor, fps, loop, hit_frame) + GIF từng Action;
     · đặt pivot theo ảnh lưới toạ độ của 1a và kiểm tra bằng 4_rig2d/weights.png.
   - design/nhan_vat/mira/4_rig2d/map_base.txt + pixel_map.py – sprite pixel ngoài map:
     · khung gốc 32×32 (boss 48) vẽ tay dạng lưới ký tự, mỗi ký tự 1 màu; ≤ 12 màu gồm viền #141018;
     · Action làm bằng dời nhóm pixel (đầu, thân, chân trước/sau, vạt), nghiêng, nhắm mắt; chỉ hướng "e";
     · xuất 5_render/map_<id>.png + .json + GIF phóng ×8.
   - design/nhan_vat/mira/6_vfx/make_mira_vfx.py – hiệu ứng skill vẽ 2D bằng code:
     · hình vẽ bằng hàm khoảng cách (giọt, vòng, tia, sao lấp lánh, mây, mảnh vỡ, dấu cộng...), tô cel 3–4 bậc: rìa màu nguyên tố → sáng → lõi gần trắng, tan dần ở khung cuối;
     · lớp cast (tại người dùng), hit (tại mục tiêu, bắt đầu ở hit_frame), screen (1024×576); khung 512; JSON ghi khung bắt đầu từng lớp và điểm neo;
     · skill ngoài map: pixel 64×64, ≤ 6 màu;
     · GIF xem thử ghép với sprite đã render ở 5_render/.
4. Mọi script chạy bằng: blender -b -P <script> (chỉ để có Python + numpy). Báo tôi lệnh chạy và thời gian. Dừng lại chờ tôi duyệt.
```

## 6. Bảng hoạt ảnh chuẩn

| Nơi | Action | Số khung | Khung trúng | Lặp |
| --- | --- | --- | --- | --- |
| Trận – nhân vật | idle | 6 | – | có |
| | attack | 8 | 4 | |
| | skill | 10 | 6 | |
| | ultimate | 12 | 8 | |
| | hit | 4 | – | |
| | down | 6 | – | giữ khung cuối |
| | victory | 8 | – | có |
| Trận – quái | idle 6, attack 8 (trúng 4), skill 10 (trúng 6), hit 4, down 6; thêm hoạt ảnh riêng ghi trong file quái; boss GĐ2/GĐ3 thêm hậu tố `-p2`/`-p3` | | | |
| Ngoài map – nhân vật | idle | 4 | – | có |
| | run | 6 | – | có |
| | dash | 3 | – | |
| | opener | 5 | 2 | |
| | technique | 6 | – | |
| Ngoài map – quái | idle 4, run 4, windup 3 | | | |

12 fps. Tên Action viết đúng như bảng (chữ thường, tiếng Anh) vì game tìm theo tên này.

## 7. Cách duyệt

- Mở `design/REVIEW.md` trên GitHub (biểu tượng bút chì), xem ảnh/GIF theo đường dẫn.
- Đổi `chờ duyệt` → `duyệt`, hoặc → `sửa` và ghi góp ý ở cột cuối.
- Muốn sửa bằng hình: mở `.kra`, vẽ đè lên lớp `your_sketch`, lưu, ghi `sửa – xem nét vẽ đè`.
- AI làm bản mới (v2, v3...) cho dòng `sửa`, giữ bản cũ.
