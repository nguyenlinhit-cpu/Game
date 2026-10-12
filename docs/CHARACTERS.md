# Nhân vật

Thiết kế khớp với dữ liệu trong `data/characters/*.tres`, sinh từ `tools/data_builder/build_characters.py`.
Chỉ số Máu/Tấn Công/Phòng Thủ nội suy tuyến tính giữa bảng cấp 1 và cấp 80 (`StatBlock`); các chỉ số khác giữ như cấp 1.
Mọi nhân vật: Bạo kích 5%, Sát thương bạo kích 50%, Hiệu suất hồi năng lượng 100% (trừ khi ghi khác).
Đánh thường +1 Điểm Chiến Kỹ, +20 năng lượng; Chiến kỹ −1 Điểm Chiến Kỹ, +30 năng lượng; Tuyệt kỹ +5 năng lượng.
Giảm khiên: Đánh thường 10, Chiến kỹ 20 (bên cạnh 10), Tuyệt kỹ 30/20 (đánh toàn bộ: 10–20 mỗi quái).

## Bảng tổng hợp (Phase 6)

| Nhân vật | Hạng | Nguyên tố | Vận mệnh | Vai trò | Đặc tính (1 câu) | Bí Kỹ (kiểu) | Nguồn |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Lữ khách (Kael/Kaela) | 5★ | Hồn | Hủy Diệt | Sát thương lan | Phá Vỡ khiên → tích tầng Tấn Công | Bước Hư Ảnh (khám phá + lợi thế trận sau) | Nhân vật chính |
| Mira | 4★ | Nước | Trù Phú | Hồi máu | Tự hồi ngay đồng minh vừa rơi dưới 30% máu | Mưa Sương Lành (trận kế tiếp) | Mở đầu |
| Kiri | 4★ | Lửa | Hòa Hợp | Buff, kéo lượt | Đồng minh được Thổi Bùng dùng Chiến kỹ → hoàn Điểm Chiến Kỹ | Pháo Hoa Mồi (quái trên map) | Chương 1 |
| Garren | 4★ | Mộc | Bảo Hộ | Đỡ đòn | Bị đánh thì phản công | Tường Rễ (trận kế tiếp) | Chương 2 |
| Nyx | 4★ | Sét | Hư Vô | Debuff, sát thương theo lượt | Đánh thường kích nổ sát thương theo lượt | Màn Tĩnh Điện (khám phá) | Chương 3 |

Đội miễn phí đủ vị trí: sát thương (Lữ khách), hồi máu (Mira), buff (Kiri), đỡ đòn (Garren), debuff (Nyx). Nguyên tố đội miễn phí: Hồn, Nước, Lửa, Mộc, Sét.

---

## Lữ khách – Kael / Kaela (Hồn, Hủy Diệt, 5★)

- **Tiểu sử:** Tỉnh dậy trong Pháo Đài Vọng Tinh với một Mảnh Hồn đang đập trong tim và không nhớ gì về mình. Mảnh Hồn cho phép sử dụng nguyên tố Hồn – sức mạnh của chính Tâm Thần Nhãn. Mỗi Mảnh Hồn thu hồi trả lại một đoạn ký ức.
- **Tính cách:** Ít nói, tò mò, kiên định; đi tìm ký ức nhưng không bỏ rơi người gặp nạn.
- **Ngoại hình:** áo choàng xanh đêm (Nam) / đỏ mận (Nữ), viền vàng #F2D58A, Mảnh Hồn phát sáng ở ngực; bóng đen nhận ra nhờ vạt áo choàng xẻ đôi và lưỡi kiếm dài.
- **Chỉ số:** năng lượng tối đa 120.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 160 | 80 | 60 | 100 |
| Cấp 30 | 542 | 278 | 207 | 100 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Vết Chém Hồn | Chém quạt 120°, tầm 120 px, hồi 0,6 giây. Trúng quái → Ưu Thế. Mở **tường nứt** (Hồn). |
| Bí Kỹ – Bước Hư Ảnh (khám phá) | 1 Điểm Bí Kỹ: lướt 4 ô xuyên **rào Ma Biến**. Trận kế tiếp, lượt đầu được kéo lên 25%. |
| Đánh thường – Chém Rạn | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Hồn Vỡ | 125% Tấn Công mục tiêu chính, 50% hai bên. |
| Tuyệt kỹ – Tâm Nhãn Khai Mở (120) | 2 chế độ (Q để đổi): 450% lên 1 quái, hoặc 270% chính + 160% hai bên. |
| Đặc tính – Cộng Hưởng Mảnh Hồn | Mỗi lần Phá Vỡ khiên một quái, Tấn Công +20% trong 2 lượt, tối đa 2 tầng. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Ký Ức Đầu Tiên | Cộng Hưởng tối đa 3 tầng. |
| 2 – Vết Nứt Thứ Hai | Đánh thường lên quái đang Phá Vỡ hồi 1 Điểm Chiến Kỹ (1 lần mỗi lượt). |
| 3 – Ánh Sao Lạc | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Ý Chí Không Tắt | Dưới 50% máu: Tăng sát thương +20%. |
| 5 – Mảnh Hồn Thứ Năm | Tuyệt kỹ +15% hệ số. |
| 6 – Tâm Nhãn Trọn Vẹn | Dùng Tuyệt kỹ xong được kéo lượt 30%. |

Tinh Mệnh của Lữ khách mở bằng Mảnh Hồn theo cốt truyện (mỗi chương 1, 2 nhiệm vụ phụ mở 2 cái còn lại – Phase 12).

## Mira (Nước, Trù Phú, 4★)

- **Tiểu sử:** Thực tập sinh dược sĩ của trạm y tế Sảnh Trung Tâm, kẹt lại khi Ma Biến tràn vào pháo đài. Cô dùng nước tinh lọc từ các bể sao để chữa vết thương nhiễm Ma Biến. Là người đầu tiên tìm thấy và chăm sóc Lữ khách khi tỉnh dậy.
- **Tính cách:** Dịu dàng, hay lo, tỉ mỉ; nói nhiều khi căng thẳng.
- **Ngoại hình:** xanh nước #3A8DDE, trắng, bạc; tạp dề dược sĩ, bình nước đeo hông; bóng đen nhận ra nhờ mũ trùm tai thỏ và bình hình giọt nước.
- **Chỉ số:** năng lượng tối đa 100.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 150 | 60 | 55 | 105 |
| Cấp 30 | 499 | 214 | 189 | 105 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Giọt Sương Bắn | Quạt hẹp 60°, tầm 150 px, hồi 0,7 giây. Dập **tường lửa** (Nước). |
| Bí Kỹ – Mưa Sương Lành (trận kế tiếp) | Trận kế tiếp cả đội có Sương Dưỡng: hồi 6% máu tối đa đầu mỗi lượt, 2 lượt. |
| Đánh thường – Giọt Sương | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Suối Lành | Hồi 1 đồng minh 40% Tấn Công + 80, giải 1 hiệu ứng xấu. |
| Tuyệt kỹ – Mưa Phúc (100) | Hồi cả đội 30% Tấn Công + 60, mỗi người giải 1 hiệu ứng xấu. |
| Đặc tính – Dòng Chảy Ân Cần | Lần đầu mỗi đồng minh rơi dưới 30% máu trong trận, Mira lập tức hồi người đó 15% máu tối đa (đòn phụ). |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Giọt Đầu Mùa | Chiến kỹ +10% hệ số hồi. |
| 2 – Dòng Chảy Kép | Đặc tính kích hoạt tối đa 2 lần mỗi đồng minh. |
| 3 – Hồ Tĩnh | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Mạch Nước Ngầm | Dùng Tuyệt kỹ xong cả đội hồi 10 năng lượng. |
| 5 – Thác Bạc | Tuyệt kỹ +15% hệ số. |
| 6 – Nước Hồi Sinh | Một lần mỗi trận, đồng minh đầu tiên ngã được hồi sinh với 30% máu. |

## Kiri (Lửa, Hòa Hợp, 4★)

- **Tiểu sử:** Thợ pháo hoa của lễ hội ngắm sao mỗi năm ở pháo đài, kẹt trong Thư Viện Câm Lặng khi đang tìm sách công thức pháo. Cô tin rằng ánh sáng có thể xua Ma Biến và dùng pháo hoa để tiếp sức cho đồng đội. Gia nhập ở Chương 1 sau khi được cứu khỏi đám sách bay.
- **Tính cách:** Sôi nổi, lạc quan, hơi liều; thích đặt biệt danh cho mọi người.
- **Ngoại hình:** cam lửa #E8552B, vàng, đỏ thẫm; túi pháo đeo chéo; bóng đen nhận ra nhờ hai bím tóc dựng như ngòi pháo.
- **Chỉ số:** năng lượng tối đa 110.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 140 | 70 | 50 | 110 |
| Cấp 30 | 474 | 243 | 178 | 110 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Tia Lửa | Quạt 90°, tầm 130 px, hồi 0,6 giây. Đốt **dây leo** (Lửa). |
| Bí Kỹ – Pháo Hoa Mồi (quái trên map) | Ném pháo 3 ô phía trước, bán kính 2,5 ô: quái choáng 8 giây và bị đánh dấu; vào trận với nhóm đó thì mọi quái bị Thiêu Đốt (50% Tấn Công của Kiri mỗi lượt, 2 lượt). |
| Đánh thường – Tia Lửa | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Thổi Bùng | Kéo lượt 1 đồng minh khác 50%, Tấn Công +20% trong 2 lượt. |
| Tuyệt kỹ – Pháo Hoa Rực Rỡ (110) | 60% Tấn Công lên toàn bộ quái; cả đội Tăng sát thương +20% trong 2 lượt. |
| Đặc tính – Nhịp Lễ Hội | Đồng minh đang có Thổi Bùng dùng Chiến kỹ → Kiri +1 tầng; đủ 3 tầng: đội +1 Điểm Chiến Kỹ. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Que Diêm Đầu | Thổi Bùng: Tấn Công +30% (thay 20%). |
| 2 – Nhịp Nhanh | Nhịp Lễ Hội chỉ cần 2 tầng. |
| 3 – Pháo Sáng | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Khai Mạc | Vào trận đội +1 Điểm Chiến Kỹ. |
| 5 – Bầu Trời Rực | Tuyệt kỹ +15% hệ số. |
| 6 – Ngọn Lửa Cổ Vũ | Thổi Bùng thêm +10% Tốc Độ. |

## Garren (Mộc, Bảo Hộ, 4★)

- **Tiểu sử:** Đội trưởng đội cận vệ già của pháo đài, đóng băng cùng lính trong Kho Chứa khi giữ chân Cự Thú. Áo giáp của ông mọc rễ từ hạt giống cây sao cổ thụ, cứng hơn cả thép. Được cứu ở Chương 2 và nhận Lữ khách làm "lính mới".
- **Tính cách:** Nghiêm, ít nói, che chở; thỉnh thoảng kể chuyện cũ không ai hỏi.
- **Ngoại hình:** xanh rừng #2E8B57, nâu gỗ, đồng; khiên tròn lớn bằng gỗ; bóng đen nhận ra nhờ vai giáp mọc cành và tấm khiên to bằng nửa người.
- **Chỉ số:** năng lượng tối đa 120.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 200 | 55 | 80 | 92 |
| Cấp 30 | 677 | 189 | 271 | 92 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Rễ Trồi | Quạt rộng 140°, tầm 110 px, hồi 0,8 giây. Mọc **cầu gỗ qua khe vực** (Mộc). |
| Bí Kỹ – Tường Rễ (trận kế tiếp) | Trận kế tiếp cả đội có khiên 25% Phòng Thủ của Garren + 60 trong 2 lượt. |
| Đánh thường – Đập Khiên | 100% Phòng Thủ lên 1 quái. |
| Chiến kỹ – Khiên Cổ Thụ | Khiên cả đội 30% Phòng Thủ + 80 trong 2 lượt; Garren Khiêu Khích (quái phải nhắm Garren bằng đòn đơn/lan). |
| Tuyệt kỹ – Tường Rừng (120) | 90% Phòng Thủ lên toàn bộ quái, trì hoãn 15%. |
| Đặc tính – Thân Rễ Phản Đòn | Bị quái đánh trúng → phản công kẻ đó 50% Phòng Thủ (đòn phụ, 1 lần mỗi lượt quái). |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Vỏ Dày | Chiến kỹ +10% hệ số khiên. |
| 2 – Nhựa Sống | Mỗi lần phản công hồi 5 năng lượng. |
| 3 – Rễ Sâu | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Lời Thề Cận Vệ | Khiêu Khích kéo dài thêm 1 lượt. |
| 5 – Rừng Già | Tuyệt kỹ +15% hệ số. |
| 6 – Gai Ngược | Phản công 75% Phòng Thủ và trì hoãn kẻ đó 10%. |

## Nyx (Sét, Hư Vô, 4★)

- **Tiểu sử:** Kỹ sư trẻ trực Lò Năng Lượng, biết mọi đường dây trong pháo đài. Khi lò biến dạng, cô trốn trong ống dẫn và theo dõi kẻ đánh cắp Mảnh Hồn. Gia nhập ở Chương 3, mang theo bản ghi về kẻ đó.
- **Tính cách:** Lạnh lùng, châm chọc, cực kỳ thông minh; ghét bị gọi là "nhóc".
- **Ngoại hình:** tím điện #A65BF2, đen, bạc; găng tay cuộn dây đồng, kính bảo hộ đẩy lên trán; bóng đen nhận ra nhờ chiếc ăng-ten cong trên mũ và đuôi dây cáp.
- **Chỉ số:** năng lượng tối đa 110, Chính Xác Hiệu Ứng 10%.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 135 | 75 | 50 | 106 |
| Cấp 30 | 453 | 260 | 171 | 106 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Cú Chích Điện | Quạt 70°, tầm 140 px, hồi 0,5 giây. Cấp điện **cửa máy** (Sét). |
| Bí Kỹ – Màn Tĩnh Điện (khám phá) | Tàng hình 10 giây: quái không nhìn thấy, đi nhanh hơn 20%. |
| Đánh thường – Cú Chích | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Mạch Rò Rỉ | 60% Tấn Công lên 1 quái, gắn Rò Điện (50% Tấn Công sát thương Sét mỗi lượt, 2 lượt) và Đoản Mạch (−15% Phòng Thủ, 2 lượt). |
| Tuyệt kỹ – Bão Từ (110) | 70% Tấn Công lên toàn bộ quái, gắn Tĩnh Điện (dễ tổn thương +15%, 2 lượt). |
| Đặc tính – Mạch Khuếch Đại | Đánh thường lên quái đang chịu sát thương theo lượt kích nổ ngay mọi sát thương theo lượt trên quái đó với 50% giá trị. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Quá Tải | Kích nổ 75%. |
| 2 – Dòng Tê | Đánh thường giảm 10% Tốc Độ quái 1 lượt. |
| 3 – Cuộn Cảm | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Sấm Rền | Bão Từ gắn thêm Rò Điện lên mọi quái. |
| 5 – Từ Trường | Tuyệt kỹ +15% hệ số. |
| 6 – Mạch Hoàn Hảo | Chính Xác Hiệu Ứng +20%. |

---

## Vật cản nguyên tố ngoài map

| Vật cản | Nguyên tố mở | Ai trong đội miễn phí mở được |
| --- | --- | --- |
| Dây leo | Lửa | Kiri |
| Tường lửa | Nước | Mira |
| Cửa máy | Sét | Nyx |
| Sương mù | Phong | (nhân vật gacha: Zephyra, Aldric, Kestrel, Wisp – Phase 7) |
| Cổng gỉ | Độc | (nhân vật gacha: Vesper, Quill, Vael, Selka – Phase 7) |
| Khe vực (cầu cây) | Mộc | Garren |
| Tường nứt (lối ẩn) | Hồn | Lữ khách |
| Rào Ma Biến | – (Bí Kỹ Bước Hư Ảnh) | Lữ khách |

Theo mục 6 và Phase 12: đường chính chỉ dùng vật cản mở được bằng đội miễn phí; Sương mù và Cổng gỉ chỉ dùng cho rương ẩn.

## Bí Kỹ – phân loại

| Kiểu | Nhân vật (Phase 6) |
| --- | --- |
| Lợi thế trận kế tiếp | Mira, Garren |
| Tác động quái trên map | Kiri |
| Tiện ích khám phá | Lữ khách, Nyx |

Phase 7 cân lại để 25 nhân vật chia đều 3 kiểu.

<!-- PHASE7_MARKER -->

# Phase 7 – 20 nhân vật còn lại (bước A: thiết kế, chờ duyệt)

Nguồn: `tools/data_builder/roster_design.py` (bước B sinh dữ liệu từ chính file này).
Quy ước chung như phần trên. Tinh Mệnh 3 = Đánh thường + Chiến kỹ +15% hệ số; Tinh Mệnh 5 = Tuyệt kỹ +15% hệ số.
5★ đặt chỉ số và hệ số cao hơn 4★ cùng vai trò khoảng 15–25% (bước B mô phỏng 10 lượt để kiểm chứng).

## 5★

## Ignar (Lửa, Hủy Diệt, 5★) – Banner thường

- **Vai trò:** Sát thương lan, đổi máu lấy sức mạnh
- **Tiểu sử:** Thợ rèn trưởng của xưởng đúc pháo đài, người duy nhất dám đứng giữa lò nung khi Ma Biến tràn vào. Lửa Ma Biến bám vào cánh tay trái khiến anh vừa đau đớn vừa mạnh hơn mỗi khi bị thương. Anh đi tìm Mảnh Hồn để dập ngọn lửa đang ăn dần cơ thể mình.
- **Tính cách:** Cộc lốc, nóng tính, che giấu sự tốt bụng; coi búa rèn như bạn.
- **Ngoại hình:** Đỏ cam #E8552B, đen than, đồng thau, xám tro. Bóng đen: vai trái phồng lớn quấn xích, búa rèn cán dài vác sau lưng.
- **Chỉ số:** năng lượng tối đa 130.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 185 | 92 | 62 | 100 |
| Cấp 30 | 624 | 312 | 215 | 100 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Búa Lửa Giáng | Nện búa hình quạt 100°, tầm 110 px, hồi 0,8 giây. Đốt dây leo. |
| Bí Kỹ – Bước Chân Lửa (tác động quái trên map) | Lao về trước 5 ô để lại vệt lửa: quái chạm vệt bị đánh dấu; vào trận với nhóm đó, mọi quái mất 20% khiên. |
| Đánh thường – Búa Than | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Lò Rèn Tự Thiêu | Tiêu 15% máu hiện tại. 162% Tấn Công lên mục tiêu chính, 81% lên 2 quái bên cạnh. |
| Tuyệt kỹ – Núi Lửa Bùng (130) | 244% Tấn Công lên toàn bộ quái, hồi lại máu bằng 10% sát thương gây ra. |
| Đặc tính – Lửa Trong Máu | Mỗi khi mất máu do tự tiêu, nhận 1 tầng Nhiệt Huyết (tối đa 5): Tăng sát thương +8% mỗi tầng. Đủ 5 tầng, Chiến kỹ kế tiếp đánh toàn bộ quái (hệ số 160% cho mọi quái) rồi xóa tầng. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Than Hồng | Lò Rèn Tự Thiêu chỉ tiêu 10% máu hiện tại. |
| 2 – Rèn Lại | Mỗi tầng Nhiệt Huyết còn tăng 3% Tỉ Lệ Bạo Kích. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Da Sắt | Dưới 30% máu: Phòng Thủ +40%. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Lò Không Tắt | Núi Lửa Bùng cho ngay 5 tầng Nhiệt Huyết. |

## Marisol (Nước, Bảo Hộ, 5★) – Banner thường

- **Vai trò:** Đỡ đòn, chia sát thương
- **Tiểu sử:** Thuyền trưởng tàu tuần tra của bến sao trôi quanh pháo đài, mất cả thủy thủ đoàn trong đêm vết nứt mở. Cô thề không để ai trên tàu của mình chết thêm lần nào nữa. Nước biển sao trong chiếc khiên vỏ ốc của cô hút đi một phần thương tích của đồng đội.
- **Tính cách:** Điềm tĩnh, mạnh mẽ, nói ít nhưng chắc; hay pha trò bằng giọng nghiêm.
- **Ngoại hình:** Xanh biển #3A8DDE, trắng ngà, vàng đồng, xanh rêu. Bóng đen: mũ thuyền trưởng rộng vành, khiên vỏ ốc xoắn khổng lồ.
- **Chỉ số:** năng lượng tối đa 120.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 215 | 62 | 92 | 95 |
| Cấp 30 | 731 | 212 | 319 | 95 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Sóng Vỗ | Quạt 130°, tầm 120 px, hồi 0,8 giây. Dập tường lửa. |
| Bí Kỹ – Áo Choàng Sóng (lợi thế trận kế tiếp) | Trận kế tiếp, cả đội Phòng Thủ +30% trong 2 lượt. |
| Đánh thường – Đập Vỏ Ốc | 100% Phòng Thủ lên 1 quái. |
| Chiến kỹ – Triều Che Chở | Khiên cả đội 20% Phòng Thủ + 55 trong 2 lượt; bản thân Khiêu Khích 1 lượt. |
| Tuyệt kỹ – Đại Dương Ôm Ấp (120) | Khiên cả đội 27% Phòng Thủ + 80 trong 2 lượt, giải 1 hiệu ứng xấu mỗi người, cả đội Phòng Thủ +20% trong 2 lượt. |
| Đặc tính – Thủy Triều Chia Sẻ | Khi Marisol còn trên 40% máu, 25% sát thương đồng minh khác nhận (sau khiên) được chuyển sang Marisol. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Vỏ Ốc Dày | Chia sẻ thêm 10% (thành 35%). |
| 2 – Bến Đỗ | Sát thương nhận qua chia sẻ giảm 30%. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Thuyền Không Chìm | Một lần mỗi trận, nhận đòn chí mạng thì giữ lại 1 máu và hồi 30% máu tối đa. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Thủy Triều Phản | Mỗi lần chia sẻ sát thương, gây 30% Phòng Thủ sát thương Nước lên kẻ tấn công. |

## Raiko (Sét, Săn Bắn, 5★) – Banner thường

- **Vai trò:** Sát thương đơn mục tiêu, đánh dấu
- **Tiểu sử:** Cung thủ trinh sát từng giữ đài quan sát phía Bắc, nơi sét không bao giờ ngừng. Cô có thể nhìn thấy dòng điện trong cơ thể quái Ma Biến và bắn trúng điểm chết của chúng. Raiko tin rằng kẻ đã mở vết nứt vẫn đang trốn trong pháo đài.
- **Tính cách:** Tự tin, lạnh lùng khi săn, trẻ con khi rảnh; thích thi bắn.
- **Ngoại hình:** Tím sét #A65BF2, trắng bạc, đen, vàng chanh. Bóng đen: cung dài cao hơn người, tóc buộc cao như tia sét.
- **Chỉ số:** năng lượng tối đa 120, Bạo kích 10%, Sát thương bạo kích 60%.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 150 | 98 | 55 | 112 |
| Cấp 30 | 502 | 334 | 189 | 112 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Tên Sấm | Bắn thẳng: quạt hẹp 30°, tầm 260 px, hồi 0,7 giây. Cấp điện cửa máy. |
| Bí Kỹ – Lôi Tiễn (tác động quái trên map) | Bắn tên 8 ô về trước: nhóm quái đầu tiên trúng bị choáng 6 giây và đánh dấu; vào trận, quái chính bị Dấu Sấm sẵn. |
| Đánh thường – Tên Điện | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Dấu Sấm | 147% Tấn Công lên 1 quái và gắn Dấu Sấm (3 lượt). |
| Tuyệt kỹ – Thiên Lôi Giáng (120) | 315% Tấn Công lên 1 quái; nếu quái mang Dấu Sấm thì thêm 60%. |
| Đặc tính – Mắt Thợ Săn | Quái mang Dấu Sấm nhận thêm 25% Sát thương bạo kích từ Raiko. Quái mang Dấu Sấm bị hạ thì Dấu chuyển sang quái máu cao nhất và Raiko được kéo lượt 50%. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Tên Thứ Nhất | Dấu Sấm kéo dài thêm 1 lượt. |
| 2 – Mắt Diều Hâu | Raiko +15% Tỉ Lệ Bạo Kích lên quái mang Dấu Sấm. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Đuổi Theo | Kéo lượt khi Dấu chuyển tăng lên 75%. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Sét Đánh Hai Lần | Thiên Lôi Giáng lên quái mang Dấu Sấm đánh thêm 1 lần 60% Tấn Công. |

## Zephyra (Phong, Hòa Hợp, 5★) – Banner thường

- **Vai trò:** Kéo lượt dây chuyền, tăng tốc
- **Tiểu sử:** Người giữ cối gió trên đỉnh tháp, điều khiển luồng khí giữ cho pháo đài không rơi vào hư vô. Từ khi Ma Biến lan ra, gió trở nên hỗn loạn và chỉ cô mới dỗ được chúng. Zephyra coi mỗi đồng đội như một cánh buồm cần đẩy đúng lúc.
- **Tính cách:** Phóng khoáng, nói chuyện như hát, luôn bình tĩnh trong hỗn loạn.
- **Ngoại hình:** Xanh ngọc #4FD1B5, trắng, vàng nhạt, xanh trời. Bóng đen: tà áo dài bay như cánh, quạt gió hình bán nguyệt.
- **Chỉ số:** năng lượng tối đa 110.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 165 | 76 | 62 | 118 |
| Cấp 30 | 552 | 257 | 212 | 118 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Cuộn Gió | Quạt 120°, tầm 130 px, hồi 0,6 giây. Thổi tan sương mù. |
| Bí Kỹ – Gió Nâng Bước (tiện ích khám phá) | 15 giây: đi nhanh hơn 40% và lướt hồi chiêu nhanh gấp đôi. |
| Đánh thường – Lưỡi Gió | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Thuận Buồm | Kéo lượt 1 đồng minh khác 100% (đi ngay) và tăng 20% Tốc Độ trong 1 lượt. |
| Tuyệt kỹ – Trời Lộng Gió (110) | Cả đội kéo lượt 25%, Tăng sát thương +45% và Tốc Độ +10% trong 2 lượt. |
| Đặc tính – Gió Dây Chuyền | Khi đồng minh được Thuận Buồm kết thúc lượt, đồng minh đứng ngay sau trong thứ tự lượt được kéo lượt 25%. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Hơi Thở Đầu | Vào trận, Zephyra kéo lượt 30%. |
| 2 – Gió Kép | Gió Dây Chuyền kéo lượt 35%. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Thăng Hoa | Thuận Buồm còn cho đồng minh +12 năng lượng. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Bão Lành | Trời Lộng Gió hoàn 1 Điểm Chiến Kỹ. |

## Vesper (Độc, Hư Vô, 5★) – Banner thường

- **Vai trò:** Sát thương theo lượt, lan độc
- **Tiểu sử:** Nhà độc học của phòng thí nghiệm ngầm, người đầu tiên nghiên cứu mẫu Ma Biến. Bà tiêm thử chủng độc chống Ma Biến vào chính mình và sống sót, đổi lại cơ thể luôn rỉ ra sương tím. Vesper muốn biết vết nứt được tạo ra bằng công thức nào.
- **Tính cách:** Lịch thiệp, mỉa mai, tò mò đến lạnh người.
- **Ngoại hình:** Xanh độc #9BC53D, tím than, đen, trắng xương. Bóng đen: mũ nhọn rộng vành, ống kính quai tròn, áo choàng xẻ tà nhọn.
- **Chỉ số:** năng lượng tối đa 120, Chính Xác Hiệu Ứng 15%.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 160 | 86 | 58 | 105 |
| Cấp 30 | 527 | 293 | 198 | 105 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Lọ Độc Ném | Quạt 70°, tầm 160 px, hồi 0,7 giây. Ăn mòn cổng gỉ. |
| Bí Kỹ – Sương Ngủ (tác động quái trên map) | Thả sương bán kính 3 ô: quái ngủ 10 giây và bị đánh dấu; vào trận, mọi quái bị Nhiễm Độc Vesper. |
| Đánh thường – Kim Tẩm Độc | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Chén Độc | 30% Tấn Công lên mục tiêu chính và 2 bên, gắn Độc Vesper (12% Tấn Công sát thương Độc mỗi lượt, 3 lượt) lên cả 3. |
| Tuyệt kỹ – Mùa Dịch (120) | 40% Tấn Công lên toàn bộ quái; mọi Độc Vesper đang có lập tức gây thêm 25% sát thương một lượt. |
| Đặc tính – Nọc Lan | Quái mang Độc Vesper bị hạ thì Độc lan sang 2 quái bên cạnh với số lượt còn lại (tối thiểu 1). |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Chủng Mạnh | Độc Vesper gây thêm 20% sát thương. |
| 2 – Kháng Thể Ngược | Quái mang Độc Vesper giảm 10% Kháng Hiệu Ứng. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Bệnh Dịch Kéo Dài | Độc Vesper kéo dài 4 lượt. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Đại Dịch | Nọc Lan lan sang mọi quái còn lại. |

## Sylvaine (Mộc, Trù Phú, 5★) – Banner thường

- **Vai trò:** Hồi máu, triệu hồi, hồi sinh
- **Tiểu sử:** Người làm vườn của Vườn Treo, nơi trồng những cây sao cung cấp không khí cho pháo đài. Cô mang theo hạt của Cây Sự Sống cuối cùng, mỗi hạt có thể mọc thành một cây chữa lành. Sylvaine đi khắp các khu để gieo lại sự sống ở nơi Ma Biến đã tàn phá.
- **Tính cách:** Hiền, chậm rãi, kiên nhẫn; nói chuyện với cây như với người.
- **Ngoại hình:** Xanh lá #2E8B57, hồng đào, nâu đất, kem. Bóng đen: mái tóc dài kết hoa thành vòng, gậy mọc cành lá.
- **Chỉ số:** năng lượng tối đa 140, Tăng Trị Liệu 10%.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 185 | 72 | 62 | 104 |
| Cấp 30 | 602 | 251 | 212 | 104 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Gai Hoa | Quạt 100°, tầm 130 px, hồi 0,7 giây. Mọc cầu qua khe vực. |
| Bí Kỹ – Hạt Giống Sống (lợi thế trận kế tiếp) | Trận kế tiếp, Cây Sự Sống mọc ngay đầu trận. |
| Đánh thường – Cành Quất | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Mưa Phấn Hoa | Hồi cả đội 12% Tấn Công + 33; nếu chưa có Cây Sự Sống thì gieo cây. |
| Tuyệt kỹ – Vườn Hồi Sinh (140) | Hồi cả đội 19% Tấn Công + 57; hồi sinh 1 đồng minh đã ngã với 40% máu (1 lần mỗi trận). |
| Đặc tính – Cây Sự Sống | Cây Sự Sống là vật triệu hồi (không chiếm chỗ nhân vật, quái không nhắm), Tốc Độ 80, tồn tại 3 lượt của cây: mỗi lượt hồi đồng minh ít máu nhất 6% máu tối đa của người đó. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Rễ Sâu | Cây Sự Sống tồn tại 4 lượt. |
| 2 – Hoa Nở Rộ | Cây hồi thêm cho đồng minh thứ hai ít máu nhất. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Mùa Xuân Mới | Vườn Hồi Sinh dùng được 2 lần mỗi trận. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Cổ Thụ | Cây Sự Sống đầu lượt còn giải 1 hiệu ứng xấu cho cả đội. |

## Orrin (Hồn, Tri Thức, 5★) – Banner thường

- **Vai trò:** Sát thương toàn bộ, tiêu thêm Điểm Chiến Kỹ
- **Tiểu sử:** Thủ thư trưởng của Thư Viện Câm Lặng, người ghi chép mọi vì sao từng quan sát. Ông đọc được chữ viết trong Mảnh Hồn và dùng chúng như trang sách phép. Orrin tin rằng câu trả lời cho thảm họa nằm trong một cuốn sách đã bị xé mất.
- **Tính cách:** Uyên bác, hay quên, nói vòng vo; nghiêm khắc khi có người làm hỏng sách.
- **Ngoại hình:** Vàng hồn #F2D58A, nâu da thuộc, xanh đêm, trắng giấy. Bóng đen: lưng hơi gù, chồng sách bay lơ lửng quanh vai, mũ chóp mềm.
- **Chỉ số:** năng lượng tối đa 120.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 140 | 99 | 52 | 100 |
| Cấp 30 | 478 | 338 | 180 | 100 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Trang Sách Bay | Quạt 90°, tầm 150 px, hồi 0,7 giây. Hiện lối đi ẩn. |
| Bí Kỹ – Mắt Thư Tịch (tiện ích khám phá) | Hiện vị trí mọi rương và tường nứt chưa mở trong khu trên bản đồ nhỏ trong 60 giây. |
| Đánh thường – Chữ Hồn | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Chương Hồn | 56% Tấn Công lên toàn bộ quái. |
| Tuyệt kỹ – Thư Tịch Khai Mở (120) | 128% Tấn Công lên toàn bộ quái, rồi 3 lần 40% lên quái ngẫu nhiên. |
| Đặc tính – Thư Tịch Hồn | Chiến kỹ tự tiêu thêm tối đa 2 Điểm Chiến Kỹ nếu có: mỗi điểm thêm cộng 50 điểm % vào hệ số (56% → tối đa 156%). |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Chú Thích | Mỗi Điểm Chiến Kỹ tiêu thêm còn hoàn 10 năng lượng. |
| 2 – Phụ Lục | Tiêu thêm tối đa 3 điểm (tối đa 206%). |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Mục Lục | Thư Tịch Khai Mở hoàn 1 Điểm Chiến Kỹ. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Cuốn Sách Mất | Chiến kỹ tiêu đủ điểm thì giảm khiên gấp đôi. |

## Celestine (Hồn, Săn Bắn, 5★) – Banner giới hạn

- **Vai trò:** Sát thương đơn mục tiêu, đổi tư thế
- **Tiểu sử:** Người Gác Nhãn cuối cùng, sống sót trong ảo ảnh của Tâm Thần Nhãn sau khi nó vỡ. Cô giữ hai thanh kiếm làm từ hai mảnh lớn nhất của Nhãn: một để canh, một để phán xử. Celestine xuất hiện trong ảo ảnh cuối Chương 1 và tìm người mang Mảnh Hồn trong tim.
- **Tính cách:** Trang nghiêm, ít cảm xúc, trung thành tuyệt đối với lời thề; ấm áp với số ít người cô tin.
- **Ngoại hình:** Trắng bạc, vàng hồn #F2D58A, xanh lam đêm, đen. Bóng đen: hai thanh kiếm dài bắt chéo sau lưng, vầng sáng hình mắt sau đầu.
- **Chỉ số:** năng lượng tối đa 130, Bạo kích 10%, Sát thương bạo kích 60%.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 158 | 102 | 58 | 112 |
| Cấp 30 | 529 | 347 | 195 | 112 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Kiếm Canh | Quạt 110°, tầm 130 px, hồi 0,6 giây. Hiện lối đi ẩn. |
| Bí Kỹ – Lời Tiên Tri (lợi thế trận kế tiếp) | Trận kế tiếp vào trận với +2 Điểm Chiến Kỹ và ở tư thế Phán Xử. |
| Đánh thường – Nhát Canh | Tư thế Canh Giữ: 100% Tấn Công, +1 Điểm Chiến Kỹ, +10 năng lượng thêm. Tư thế Phán Xử: 160% Tấn Công. |
| Chiến kỹ – Đổi Kiếm | Đổi tư thế rồi đánh: sang Phán Xử thì 280% Tấn Công lên 1 quái; sang Canh Giữ thì kéo lượt bản thân 30%. |
| Tuyệt kỹ – Nhãn Phán Quyết (130) | Vào tư thế Phán Xử, 550% Tấn Công lên 1 quái. |
| Đặc tính – Hai Tư Thế | Canh Giữ: Tốc Độ +20%. Phán Xử: Sát thương bạo kích +50%, Tỉ Lệ Bạo Kích +15%. Đầu trận ở Canh Giữ. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Lời Thề Đầu | Đổi tư thế cho thêm 15 năng lượng. |
| 2 – Hai Mảnh Một Lòng | Tư thế Phán Xử Tăng sát thương +20%. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Người Canh Không Ngủ | Tư thế Canh Giữ: đầu lượt hồi 8% máu tối đa. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Nhãn Toàn Tri | Nhãn Phán Quyết bỏ qua 30% Phòng Thủ quái. |

## 4★

## Quill (Độc, Trù Phú, 4★) – Cả 2 banner

- **Vai trò:** Hồi máu từ sát thương theo lượt
- **Tiểu sử:** Học trò bỏ học của Vesper, cho rằng độc và thuốc chỉ khác nhau ở liều lượng. Cậu chế loại độc khiến quái Ma Biến 'chảy' sinh lực ngược về phía đồng đội. Quill đi theo đoàn vì muốn chứng minh cô thầy cũ đã sai.
- **Tính cách:** Lém lỉnh, cẩu thả, tốt bụng; nói nhanh và hay pha chế lung tung.
- **Ngoại hình:** Xanh độc #9BC53D, cam đất, trắng, nâu. Bóng đen: ba lô đầy ống nghiệm, mũ kính phi công.
- **Chỉ số:** năng lượng tối đa 100.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 155 | 62 | 55 | 104 |
| Cấp 30 | 513 | 219 | 185 | 104 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Ống Nghiệm Vỡ | Quạt 90°, tầm 140 px, hồi 0,7 giây. Ăn mòn cổng gỉ. |
| Bí Kỹ – Túi Thuốc (tiện ích khám phá) | Hồi cả đội 25% máu tối đa ngay trên map (có tác dụng khi máu giữ giữa các trận, Phase 9). |
| Đánh thường – Kim Thuốc | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Liều Đôi | Hồi 1 đồng minh 35% Tấn Công + 70 và gắn Độc Quill (40% Tấn Công sát thương Độc mỗi lượt, 2 lượt) lên quái ngẫu nhiên. |
| Tuyệt kỹ – Thuốc Giải Vạn Năng (100) | Hồi cả đội 25% Tấn Công + 60 và giải 1 hiệu ứng xấu mỗi người. |
| Đặc tính – Độc Hóa Thuốc | Mỗi khi quái chịu sát thương theo lượt (của bất kỳ ai), đồng minh ít máu nhất hồi 15% lượng sát thương đó. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Liều Chuẩn | Độc Hóa Thuốc hồi 20%. |
| 2 – Pha Kép | Liều Đôi gắn Độc Quill lên 2 quái. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Kháng Sinh | Thuốc Giải Vạn Năng còn cho cả đội Kháng Hiệu Ứng +20% trong 2 lượt. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Thần Dược | Lượng hồi vượt máu tối đa chuyển thành khiên (tối đa 20% máu tối đa). |

## Aldric (Phong, Bảo Hộ, 4★) – Cả 2 banner

- **Vai trò:** Đỡ đòn thay đồng đội
- **Tiểu sử:** Lính gác cổng gió lâu năm, từng đứng chắn cửa một mình suốt ba ngày khi Ma Biến tràn lên. Ông dùng tấm khiên buồm để bắt gió và lao tới che chắn trong chớp mắt. Aldric giữ lời hứa với Garren là bảo vệ thế hệ lính mới.
- **Tính cách:** Trầm, kỷ luật, hay càu nhàu; luôn đứng trước người khác.
- **Ngoại hình:** Xanh ngọc #4FD1B5, xám thép, đỏ sẫm, trắng. Bóng đen: khiên buồm hình cánh diều, áo choàng ngắn rách mép.
- **Chỉ số:** năng lượng tối đa 120.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 195 | 52 | 82 | 98 |
| Cấp 30 | 645 | 180 | 279 | 98 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Khiên Gió Đập | Quạt 140°, tầm 110 px, hồi 0,8 giây. Thổi tan sương mù. |
| Bí Kỹ – Bức Tường Gió (lợi thế trận kế tiếp) | Trận kế tiếp, mọi quái bị trì hoãn 20% ngay đầu trận. |
| Đánh thường – Đâm Khiên | 100% Phòng Thủ lên 1 quái. |
| Chiến kỹ – Tấm Khiên Buồm | Khiên 1 đồng minh 40% Phòng Thủ + 100 trong 2 lượt, khiên bản thân 20% Phòng Thủ + 50. |
| Tuyệt kỹ – Gió Bão Che Thân (120) | Khiên cả đội 30% Phòng Thủ + 80 trong 2 lượt, 70% Phòng Thủ sát thương Phong lên toàn bộ quái. |
| Đặc tính – Lao Tới Che | Một lần mỗi lượt quái: đồng minh khác sắp nhận đòn từ 25% máu tối đa của họ trở lên thì Aldric nhận đòn thay (giảm 20%). |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Phản Xạ Nhanh | Đỡ thay khi đòn từ 20% máu tối đa. |
| 2 – Cứng Như Đá | Đòn đỡ thay giảm 35%. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Gió Đáp Trả | Đỡ thay xong được kéo lượt 15%. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Không Ai Bị Bỏ Lại | Đỡ thay tối đa 2 lần mỗi lượt quái. |

## Rook (Mộc, Hủy Diệt, 4★) – Cả 2 banner

- **Vai trò:** Sát thương lan, báo thù
- **Tiểu sử:** Tiều phu khổng lồ của Vườn Treo, mất người em khi Ma Biến biến cây cổ thụ thành quái vật. Từ đó Rook mang cây rìu làm từ chính thân cây ấy. Mỗi khi đồng đội gục ngã, nỗi đau cũ trỗi dậy thành sức mạnh.
- **Tính cách:** Hiền như cục đất, nổi giận như bão; nói chậm, ăn nhiều.
- **Ngoại hình:** Xanh lá #2E8B57, nâu gỗ, đỏ sẫm, xám đá. Bóng đen: thân hình to vuông, rìu hai lưỡi khổng lồ.
- **Chỉ số:** năng lượng tối đa 120.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 175 | 80 | 60 | 98 |
| Cấp 30 | 588 | 271 | 203 | 98 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Rìu Bổ Đất | Quạt 120°, tầm 120 px, hồi 0,9 giây. Mọc cầu qua khe vực. |
| Bí Kỹ – Rễ Đâm (tác động quái trên map) | Rễ trồi 4 ô phía trước: quái trúng bị trói 8 giây và đánh dấu; vào trận chúng bị Trói Rễ. |
| Đánh thường – Bổ Rìu | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Quét Rìu | 140% Tấn Công lên mục tiêu chính, 70% lên 2 bên. |
| Tuyệt kỹ – Cây Đổ (120) | 240% Tấn Công mục tiêu chính, 140% hai bên; mỗi tầng Báo Thù cộng thêm 40% hệ số. |
| Đặc tính – Báo Thù | Mỗi đồng minh ngã: Rook nhận 1 tầng Báo Thù vĩnh viễn trong trận (Tấn Công +25%, tối đa 3) và đầy năng lượng ngay. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Nỗi Nhớ | Vào trận có sẵn 1 tầng Báo Thù. |
| 2 – Cơn Giận Dồn | Bị đánh trúng +8 năng lượng thêm. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Gốc Vững | Mỗi tầng Báo Thù còn Phòng Thủ +10%. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Cây Không Gục | Một lần mỗi trận, khi ngã Rook đứng dậy với 30% máu. |

## Fenna (Mộc, Săn Bắn, 4★) – Cả 2 banner

- **Vai trò:** Sát thương đơn, đòn phụ lên quái Phá Vỡ
- **Tiểu sử:** Cô gái săn thú trong rừng treo, lớn lên giữa những cây sao và chim đêm. Fenna đặt bẫy và bắn tên nhanh tới mức con mồi không kịp đứng dậy sau cú ngã. Cô theo đoàn để tìm con chim ưng bạn đồng hành bị Ma Biến bắt đi.
- **Tính cách:** Hoang dã, thẳng thắn, ít nói trước người lạ; rất trung thành.
- **Ngoại hình:** Xanh lá #2E8B57, nâu da, cam lá thu, trắng lông vũ. Bóng đen: mũ trùm tai cáo, cung ngắn cong và ống tên lông vũ.
- **Chỉ số:** năng lượng tối đa 110, Bạo kích 8%.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 135 | 82 | 50 | 108 |
| Cấp 30 | 449 | 276 | 167 | 108 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Tên Rừng | Quạt hẹp 40°, tầm 220 px, hồi 0,6 giây. Mọc cầu qua khe vực. |
| Bí Kỹ – Bẫy Dây (tác động quái trên map) | Đặt bẫy tại chỗ (tối đa 1): nhóm quái dẫm phải bị giữ chặt 8 giây; chạm nhóm đó luôn vào trận với Ưu Thế. |
| Đánh thường – Tên Nhanh | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Mưa Tên | 180% Tấn Công lên 1 quái. |
| Tuyệt kỹ – Mũi Tên Định Mệnh (110) | 360% Tấn Công lên 1 quái; quái đang Phá Vỡ thì +30% Sát thương bạo kích. |
| Đặc tính – Mũi Tên Thứ Hai | Đánh thường lên quái đang Phá Vỡ thì bắn thêm 1 mũi tên 60% Tấn Công (đòn phụ, không tốn lượt). |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Mũi Tên Ba | Mũi Tên Thứ Hai bắn 2 mũi. |
| 2 – Ngắm Kỹ | Đòn phụ +20% Tỉ Lệ Bạo Kích. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Kẻ Đi Săn | Hạ quái thì +1 Điểm Chiến Kỹ (1 lần mỗi lượt). |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Ưng Trở Về | Mũi Tên Thứ Hai kích hoạt cả với Chiến kỹ. |

## Kestrel (Phong, Hủy Diệt, 4★) – Cả 2 banner

- **Vai trò:** Sát thương lan, chuỗi Chiến kỹ
- **Tiểu sử:** Lính đưa thư bay của pháo đài, lướt giữa các tháp bằng đôi cánh gió buộc ở chân. Từ khi đường bay đứt gãy, Kestrel chuyển sang chém quái bằng cặp lưỡi liềm gió. Cậu muốn trở thành người đầu tiên bay qua vết nứt.
- **Tính cách:** Hiếu động, khoe khoang, sợ độ cao một cách bí mật.
- **Ngoại hình:** Xanh ngọc #4FD1B5, vàng nghệ, nâu, trắng. Bóng đen: hai lưỡi liềm cầm ngược, đôi cánh gió nhỏ ở mắt cá.
- **Chỉ số:** năng lượng tối đa 120.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 165 | 82 | 56 | 106 |
| Cấp 30 | 549 | 276 | 190 | 106 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Liềm Gió | Quạt 150°, tầm 110 px, hồi 0,6 giây. Thổi tan sương mù. |
| Bí Kỹ – Lướt Gió (tiện ích khám phá) | Lướt xa 6 ô, bay qua khe vực chưa có cầu. |
| Đánh thường – Chém Gió | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Xoáy Liềm | 130% Tấn Công lên mục tiêu chính, 65% lên 2 bên. |
| Tuyệt kỹ – Cuồng Phong (120) | 200% Tấn Công lên toàn bộ quái. |
| Đặc tính – Lốc Tích Tụ | Mỗi lượt liên tiếp dùng Chiến kỹ: Xoáy Liềm +20% hệ số (tối đa 3 tầng); dùng Đánh thường thì mất hết tầng. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Đà Bay | Đủ 3 tầng thì Xoáy Liềm hoàn 1 Điểm Chiến Kỹ. |
| 2 – Gió Không Ngừng | Đánh thường chỉ mất 1 tầng. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Mắt Bão | Mỗi tầng Lốc Tích Tụ còn Tốc Độ +4%. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Vượt Nứt | Cuồng Phong tính như 1 lần Chiến kỹ cho Lốc Tích Tụ. |

## Vael (Độc, Tri Thức, 4★) – Cả 2 banner

- **Vai trò:** Sát thương toàn bộ theo số hiệu ứng xấu
- **Tiểu sử:** Pháp sư sương độc từng làm phù thủy giải trí cho các buổi tiệc ngắm sao. Ma Biến biến trò ảo thuật sương màu của cô thành sương ăn mòn thật. Vael học cách điều khiển nó thay vì để nó điều khiển mình.
- **Tính cách:** Phô trương, kịch tính, thích được vỗ tay; sợ cô đơn.
- **Ngoại hình:** Xanh độc #9BC53D, tím hồng, đen, vàng kim. Bóng đen: mũ chóp cao lệch, áo choàng sân khấu xòe tròn.
- **Chỉ số:** năng lượng tối đa 120.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 130 | 84 | 48 | 100 |
| Cấp 30 | 435 | 284 | 159 | 100 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Màn Sương Ảo | Quạt 110°, tầm 140 px, hồi 0,7 giây. Ăn mòn cổng gỉ. |
| Bí Kỹ – Bom Độc (tác động quái trên map) | Ném bom 3 ô phía trước, bán kính 2 ô: quái trúng bị đánh dấu; vào trận chúng mất 10% máu tối đa. |
| Đánh thường – Phi Bài Độc | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Màn Sương Tím | 90% Tấn Công lên toàn bộ quái. |
| Tuyệt kỹ – Đêm Diễn Cuối (120) | 180% Tấn Công lên toàn bộ quái. |
| Đặc tính – Khán Giả Bị Bỏ Bùa | Sát thương của Vael lên mỗi quái tăng 12% cho mỗi hiệu ứng xấu quái đó đang mang (tối đa 5). |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Mở Màn | Màn Sương Tím có 50% gắn Giảm Phòng Thủ 10% (2 lượt). |
| 2 – Tiếng Vỗ Tay | Tính tối đa 6 hiệu ứng xấu. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Diễn Lại | Đêm Diễn Cuối hoàn 15 năng lượng. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Ngôi Sao | Mỗi hiệu ứng xấu cộng 16% thay 12%. |

## Wisp (Phong, Hư Vô, 4★) – Cả 2 banner

- **Vai trò:** Trì hoãn quái mang nhiều hiệu ứng xấu
- **Tiểu sử:** Một linh hồn nhỏ sinh ra từ gió trong Kho Chứa, không nhớ mình từng là ai. Wisp thì thầm vào tai quái những lời làm chúng quên mất phải làm gì. Cậu đi cùng Lữ khách vì cả hai đều đang tìm ký ức của mình.
- **Tính cách:** Rụt rè, tò mò, thích sưu tầm đồ lấp lánh; nói thì thầm.
- **Ngoại hình:** Xanh ngọc nhạt #4FD1B5, trắng sương, tím nhạt, bạc. Bóng đen: thân nhỏ trôi lơ lửng, đuôi như làn khói xoắn.
- **Chỉ số:** năng lượng tối đa 110, Chính Xác Hiệu Ứng 10%.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 140 | 72 | 52 | 112 |
| Cấp 30 | 463 | 244 | 172 | 112 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Hơi Thở Lạnh | Quạt 100°, tầm 140 px, hồi 0,6 giây. Thổi tan sương mù. |
| Bí Kỹ – Gió Hút (tiện ích khám phá) | 20 giây: tự hút vật phẩm rơi và Hộp Bí Kỹ trong bán kính 6 ô. |
| Đánh thường – Gió Rít | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Lời Quên Lãng | 70% Tấn Công lên 1 quái, gắn Lãng Quên (Tốc Độ −12%, 2 lượt) và Giảm Tấn Công 15% (2 lượt). |
| Tuyệt kỹ – Cơn Gió Câm (110) | 60% Tấn Công lên toàn bộ quái, gắn Lãng Quên lên tất cả. |
| Đặc tính – Lời Thì Thầm | Cuối lượt của quái mang từ 2 hiệu ứng xấu trở lên, Wisp trì hoãn lượt kế tiếp của quái đó 15%. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Gió Lẻn | Chính Xác Hiệu Ứng +20%. |
| 2 – Thì Thầm Lớn | Trì hoãn 20%. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Quên Hẳn | Lãng Quên kéo dài 3 lượt. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Im Lặng Tuyệt Đối | Chỉ cần 1 hiệu ứng xấu để kích hoạt Lời Thì Thầm. |

## Selka (Độc, Hòa Hợp, 4★) – Cả 2 banner

- **Vai trò:** Buff, cộng hưởng cùng nguyên tố
- **Tiểu sử:** Nghệ nhân pha hương của chợ trời pháo đài, biết mùi hương nào làm người ta dũng cảm hơn. Ma Biến khiến hương của cô mang theo sức mạnh thật của nguyên tố. Selka tin rằng một đội hòa hợp mạnh hơn mười chiến binh lẻ.
- **Tính cách:** Dịu dàng, tinh tế, hơi chậm chạp; ghét cãi nhau.
- **Ngoại hình:** Xanh độc #9BC53D, tím oải hương, hồng phấn, vàng. Bóng đen: lư hương treo trên gậy dài, tóc búi cao cắm trâm.
- **Chỉ số:** năng lượng tối đa 110.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 150 | 66 | 58 | 108 |
| Cấp 30 | 499 | 225 | 198 | 108 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Khói Hương | Quạt 100°, tầm 130 px, hồi 0,7 giây. Ăn mòn cổng gỉ. |
| Bí Kỹ – Hương Đồng Điệu (lợi thế trận kế tiếp) | Trận kế tiếp, cả đội Tấn Công +15% trong 3 lượt. |
| Đánh thường – Trâm Hương | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Hương Dũng Khí | 1 đồng minh: Tấn Công +25% và Tăng sát thương +15% trong 2 lượt. |
| Tuyệt kỹ – Hội Tụ Hương (110) | Cả đội Tăng sát thương +20% trong 2 lượt, hồi 10 năng lượng cho mỗi người. |
| Đặc tính – Đồng Điệu | Mỗi cặp đồng minh cùng nguyên tố trong đội cho cả đội Tăng sát thương +8% (tối đa 3 cặp); đồng minh cùng nguyên tố với mục tiêu Hương Dũng Khí nhận thêm 10% Tấn Công. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Hương Bền | Hương Dũng Khí kéo dài 3 lượt. |
| 2 – Hòa Âm | Đồng Điệu tính cả Selka như một cặp với người cùng vận mệnh. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Mùi Quen | Hương Dũng Khí còn kéo lượt mục tiêu 15%. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Bản Hòa Tấu | Mỗi cặp Đồng Điệu cho +10% (thay 8%). |

## Ember (Lửa, Tri Thức, 4★) – Cả 2 banner

- **Vai trò:** Sát thương toàn bộ, nổ lan khi hạ quái
- **Tiểu sử:** Học viên lò luyện phép lửa của Lò Năng Lượng, nổi tiếng vì làm nổ ba phòng thí nghiệm. Ma Biến cuối cùng cũng cho cô một mục tiêu đáng để cho nổ. Ember muốn chứng minh phép của mình không chỉ để phá hoại.
- **Tính cách:** Bốc đồng, vui vẻ, liều lĩnh; xin lỗi rất nhiều sau mỗi vụ nổ.
- **Ngoại hình:** Đỏ cam #E8552B, vàng, xám tro, trắng. Bóng đen: mái tóc xù như ngọn lửa, cuốn sách phép cháy sém mép.
- **Chỉ số:** năng lượng tối đa 120.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 130 | 85 | 48 | 102 |
| Cấp 30 | 435 | 289 | 159 | 102 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Đốm Lửa | Quạt 90°, tầm 150 px, hồi 0,6 giây. Đốt dây leo. |
| Bí Kỹ – Mưa Tro (tác động quái trên map) | Mưa lửa bán kính 3 ô quanh mình: quái trúng bị đánh dấu; vào trận chúng mất 15% khiên. |
| Đánh thường – Cầu Lửa Nhỏ | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Biển Lửa | 85% Tấn Công lên toàn bộ quái. |
| Tuyệt kỹ – Sao Băng Lửa (120) | 170% Tấn Công lên toàn bộ quái. |
| Đặc tính – Tro Tàn Lan | Ember hạ một quái thì vụ nổ gây 50% Tấn Công sát thương Lửa lên mọi quái còn lại (tối đa 1 lần mỗi hành động). |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Than Còn Nóng | Vụ nổ giảm khiên 10 mỗi quái. |
| 2 – Phản Ứng Dây Chuyền | Vụ nổ hạ quái thì nổ tiếp (tối đa 2 lần mỗi hành động). |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Mồi Lửa | Hạ quái hồi 10 năng lượng. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Siêu Tân Tinh | Vụ nổ gây 80% Tấn Công. |

## Neris (Nước, Săn Bắn, 4★) – Cả 2 banner

- **Vai trò:** Sát thương đơn, bảo hiểm bạo kích
- **Tiểu sử:** Thợ lặn mò ngọc ở các bể sao, quen với bóng tối và áp lực dưới đáy nước. Cô dùng giáo ba chĩa mò ngọc để săn quái Ma Biến trong kho băng. Neris tin vào nhẫn nại: không trúng lần này thì lần sau chắc chắn trúng.
- **Tính cách:** Kiệm lời, kiên nhẫn, khô khan hài hước; ăn cá sống.
- **Ngoại hình:** Xanh biển #3A8DDE, xanh đậm, bạc, cam san hô. Bóng đen: giáo ba chĩa dài, tóc ngắn rối, kính lặn trên trán.
- **Chỉ số:** năng lượng tối đa 110, Bạo kích 8%.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 138 | 83 | 50 | 108 |
| Cấp 30 | 454 | 280 | 167 | 108 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Giáo Xuyên | Quạt hẹp 40°, tầm 200 px, hồi 0,6 giây. Dập tường lửa. |
| Bí Kỹ – Mắt Đáy Biển (tiện ích khám phá) | 30 giây: bản đồ nhỏ hiện mọi nhóm quái trong khu kèm cấp và điểm yếu. |
| Đánh thường – Đâm Giáo | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Ba Chĩa Xoáy | 190% Tấn Công lên 1 quái. |
| Tuyệt kỹ – Sóng Ngầm (110) | 380% Tấn Công lên 1 quái; chắc chắn bạo kích. |
| Đặc tính – Nhẫn Nại | Mỗi đòn không bạo kích: Neris +12% Tỉ Lệ Bạo Kích (cộng dồn); bạo kích thì mất hết. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Hơi Thở Dài | Mỗi tầng +15% thay 12%. |
| 2 – Áp Lực Sâu | Bạo kích sau khi có từ 3 tầng: +30% Sát thương bạo kích. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Mò Ngọc | Bạo kích hồi 8 năng lượng. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Ngọc Đen | Sóng Ngầm bỏ qua 20% Phòng Thủ quái. |

## Pip (Sét, Hòa Hợp, 4★) – Cả 2 banner

- **Vai trò:** Sạc năng lượng đồng đội
- **Tiểu sử:** Thợ máy nhí của xưởng robot, chế ra chú robot sạc pin tên Bolt từ đồ phế liệu. Pip và Bolt đi khắp pháo đài sửa đèn, sửa cửa, và giờ là sạc năng lượng cho người khác. Cậu hy vọng tìm thấy bố, kỹ sư trưởng mất tích ở Lò Năng Lượng.
- **Tính cách:** Lanh lợi, vui tính, nói không ngừng; giả vờ không sợ khi rất sợ.
- **Ngoại hình:** Tím sét #A65BF2, vàng cam, xanh dương, xám. Bóng đen: người nhỏ thó đội mũ bảo hộ to, robot tròn bay kè kè bên vai.
- **Chỉ số:** năng lượng tối đa 100, Hồi năng lượng 110%.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 145 | 64 | 55 | 110 |
| Cấp 30 | 481 | 220 | 189 | 110 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Bolt Lao Tới | Quạt 80°, tầm 140 px, hồi 0,6 giây. Cấp điện cửa máy. |
| Bí Kỹ – Sạc Đầy (lợi thế trận kế tiếp) | Trận kế tiếp, cả đội vào trận thêm 30 năng lượng. |
| Đánh thường – Tia Điện Nhỏ | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Sạc Nhanh | 1 đồng minh khác: +25 năng lượng và Tấn Công +15% trong 2 lượt. |
| Tuyệt kỹ – Quá Áp (100) | Cả đội +20 năng lượng và Tốc Độ +12% trong 2 lượt. |
| Đặc tính – Pin Dự Phòng | Đầu mỗi lượt của Pip, đồng minh có tỉ lệ năng lượng thấp nhất (trừ Pip) nhận 8 năng lượng. |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Pin Lớn | Pin Dự Phòng cho 12 năng lượng. |
| 2 – Hai Cổng Sạc | Pin Dự Phòng sạc 2 đồng minh. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Bolt Nâng Cấp | Sạc Nhanh còn kéo lượt mục tiêu 15%. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Lò Phản Ứng Mini | Quá Áp hoàn 1 Điểm Chiến Kỹ. |

## Echo (Hồn, Hư Vô, 4★) – Cả 2 banner

- **Vai trò:** Nhân bản hiệu ứng xấu
- **Tiểu sử:** Bóng phản chiếu của một người gác Nhãn, tách ra từ gương khi Tâm Thần Nhãn vỡ. Echo có thể lặp lại mọi thứ nó nghe thấy, kể cả lời nguyền. Nó muốn biết người mà nó là bóng phản chiếu đang ở đâu.
- **Tính cách:** Lạ lùng, hay nhại lời người khác, thật lòng ngây thơ.
- **Ngoại hình:** Vàng hồn nhạt #F2D58A, đen gương, xám bạc, tím. Bóng đen: hai cái bóng chồng lệch nhau, mặt nạ nửa trắng nửa đen.
- **Chỉ số:** năng lượng tối đa 110, Chính Xác Hiệu Ứng 10%.

| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |
| --- | --- | --- | --- | --- |
| Cấp 1 | 142 | 74 | 54 | 108 |
| Cấp 30 | 472 | 252 | 181 | 108 |

| Kỹ năng | Nội dung |
| --- | --- |
| Đòn Mở Màn – Gương Vỡ | Quạt 100°, tầm 140 px, hồi 0,6 giây. Hiện lối đi ẩn. |
| Bí Kỹ – Tiếng Vọng Về (tiện ích khám phá) | Dịch chuyển về phòng nghỉ đã khám phá gần nhất. |
| Đánh thường – Lời Nhại | 100% Tấn Công lên 1 quái. |
| Chiến kỹ – Lời Nguyền Vọng | 75% Tấn Công lên 1 quái, gắn Rạn Hồn (dễ tổn thương +12%, 2 lượt). |
| Tuyệt kỹ – Gương Ngàn Mặt (110) | 70% Tấn Công lên toàn bộ quái; mỗi quái nhận lại 1 hiệu ứng xấu đang có ở quái khác. |
| Đặc tính – Vang Vọng | Mỗi khi đồng minh khác gắn hiệu ứng xấu lên quái, Echo gắn bản sao hiệu ứng đó lên 1 quái ngẫu nhiên khác (tối đa 1 lần mỗi lượt của đồng minh đó). |

| Tinh Mệnh | Nội dung |
| --- | --- |
| 1 – Gương Thứ Hai | Rạn Hồn kéo dài 3 lượt. |
| 2 – Tiếng Vọng Kép | Vang Vọng tối đa 2 lần mỗi lượt. |
| 3 – Kỹ Năng Thuần Thục | Đánh thường và Chiến kỹ +15% hệ số. |
| 4 – Mặt Nạ | Bản sao từ Vang Vọng kéo dài thêm 1 lượt. |
| 5 – Tuyệt Kỹ Thuần Thục | Tuyệt kỹ +15% hệ số. |
| 6 – Bản Thể | Vang Vọng cũng sao chép hiệu ứng xấu Echo tự gắn. |

---

## Bảng tổng hợp 25 nhân vật

| # | Nhân vật | Hạng | Nguyên tố | Vận mệnh | Cơ chế Đặc tính | Đặc tính (1 câu) | Kiểu Bí Kỹ | Nguồn |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Lữ khách (Kael/Kaela) | 5★ | Hồn | Hủy Diệt | tích tầng khi Phá Vỡ | Phá Vỡ khiên quái → Tấn Công +20%, tối đa 2 tầng. | Tiện ích khám phá | Nhân vật chính |
| 2 | Mira | 4★ | Nước | Trù Phú | hồi khẩn cấp | Đồng minh vừa rơi dưới 30% máu → hồi ngay 15% máu tối đa. | Lợi thế trận kế tiếp | Miễn phí (Mở đầu) + 2 banner |
| 3 | Kiri | 4★ | Lửa | Hòa Hợp | hoàn Điểm Chiến Kỹ | Đồng minh đang Thổi Bùng dùng Chiến kỹ 3 lần → đội +1 Điểm Chiến Kỹ. | Tác động quái trên map | Miễn phí (Chương 1) + 2 banner |
| 4 | Garren | 4★ | Mộc | Bảo Hộ | phản công | Bị quái đánh trúng → phản công 50% Phòng Thủ. | Lợi thế trận kế tiếp | Miễn phí (Chương 2) + 2 banner |
| 5 | Nyx | 4★ | Sét | Hư Vô | kích nổ sát thương theo lượt | Đánh thường kích nổ ngay sát thương theo lượt trên quái (50%). | Tiện ích khám phá | Miễn phí (Chương 3) + 2 banner |
| 6 | Ignar | 5★ | Lửa | Hủy Diệt | tiêu máu bản thân | Mỗi khi mất máu do tự tiêu, nhận 1 tầng Nhiệt Huyết (tối đa 5): Tăng sát thương +8% mỗi tầng. Đủ 5 tầng, Chiến kỹ kế tiếp đánh toàn bộ quái (hệ số 160% cho mọi quái) rồi xóa tầng. | Tác động quái trên map | Banner thường |
| 7 | Marisol | 5★ | Nước | Bảo Hộ | chia sát thương với đồng đội | Khi Marisol còn trên 40% máu, 25% sát thương đồng minh khác nhận (sau khiên) được chuyển sang Marisol. | Lợi thế trận kế tiếp | Banner thường |
| 8 | Raiko | 5★ | Sét | Săn Bắn | đánh dấu mục tiêu | Quái mang Dấu Sấm nhận thêm 25% Sát thương bạo kích từ Raiko. Quái mang Dấu Sấm bị hạ thì Dấu chuyển sang quái máu cao nhất và Raiko được kéo lượt 50%. | Tác động quái trên map | Banner thường |
| 9 | Zephyra | 5★ | Phong | Hòa Hợp | kéo lượt dây chuyền | Khi đồng minh được Thuận Buồm kết thúc lượt, đồng minh đứng ngay sau trong thứ tự lượt được kéo lượt 25%. | Tiện ích khám phá | Banner thường |
| 10 | Vesper | 5★ | Độc | Hư Vô | lan hiệu ứng khi chết | Quái mang Độc Vesper bị hạ thì Độc lan sang 2 quái bên cạnh với số lượt còn lại (tối thiểu 1). | Tác động quái trên map | Banner thường |
| 11 | Sylvaine | 5★ | Mộc | Trù Phú | triệu hồi | Cây Sự Sống là vật triệu hồi (không chiếm chỗ nhân vật, quái không nhắm), Tốc Độ 80, tồn tại 3 lượt của cây: mỗi lượt hồi đồng minh ít máu nhất 6% máu tối đa của người đó. | Lợi thế trận kế tiếp | Banner thường |
| 12 | Orrin | 5★ | Hồn | Tri Thức | tiêu thêm Điểm Chiến Kỹ | Chiến kỹ tự tiêu thêm tối đa 2 Điểm Chiến Kỹ nếu có: mỗi điểm thêm cộng 50 điểm % vào hệ số (56% → tối đa 156%). | Tiện ích khám phá | Banner thường |
| 13 | Celestine | 5★ | Hồn | Săn Bắn | đổi thế đứng | Canh Giữ: Tốc Độ +20%. Phán Xử: Sát thương bạo kích +50%, Tỉ Lệ Bạo Kích +15%. Đầu trận ở Canh Giữ. | Lợi thế trận kế tiếp | Banner giới hạn |
| 14 | Quill | 4★ | Độc | Trù Phú | hồi máu từ sát thương theo lượt | Mỗi khi quái chịu sát thương theo lượt (của bất kỳ ai), đồng minh ít máu nhất hồi 15% lượng sát thương đó. | Tiện ích khám phá | Cả 2 banner |
| 15 | Aldric | 4★ | Phong | Bảo Hộ | đỡ đòn thay | Một lần mỗi lượt quái: đồng minh khác sắp nhận đòn từ 25% máu tối đa của họ trở lên thì Aldric nhận đòn thay (giảm 20%). | Lợi thế trận kế tiếp | Cả 2 banner |
| 16 | Rook | 4★ | Mộc | Hủy Diệt | sức mạnh khi đồng đội ngã | Mỗi đồng minh ngã: Rook nhận 1 tầng Báo Thù vĩnh viễn trong trận (Tấn Công +25%, tối đa 3) và đầy năng lượng ngay. | Tác động quái trên map | Cả 2 banner |
| 17 | Fenna | 4★ | Mộc | Săn Bắn | đòn phụ lên quái Phá Vỡ | Đánh thường lên quái đang Phá Vỡ thì bắn thêm 1 mũi tên 60% Tấn Công (đòn phụ, không tốn lượt). | Tác động quái trên map | Cả 2 banner |
| 18 | Kestrel | 4★ | Phong | Hủy Diệt | chuỗi Chiến kỹ liên tiếp | Mỗi lượt liên tiếp dùng Chiến kỹ: Xoáy Liềm +20% hệ số (tối đa 3 tầng); dùng Đánh thường thì mất hết tầng. | Tiện ích khám phá | Cả 2 banner |
| 19 | Vael | 4★ | Độc | Tri Thức | tăng theo số hiệu ứng xấu | Sát thương của Vael lên mỗi quái tăng 12% cho mỗi hiệu ứng xấu quái đó đang mang (tối đa 5). | Tác động quái trên map | Cả 2 banner |
| 20 | Wisp | 4★ | Phong | Hư Vô | hiệu ứng xấu thành trì hoãn | Cuối lượt của quái mang từ 2 hiệu ứng xấu trở lên, Wisp trì hoãn lượt kế tiếp của quái đó 15%. | Tiện ích khám phá | Cả 2 banner |
| 21 | Selka | 4★ | Độc | Hòa Hợp | cộng hưởng khi đội cùng nguyên tố | Mỗi cặp đồng minh cùng nguyên tố trong đội cho cả đội Tăng sát thương +8% (tối đa 3 cặp); đồng minh cùng nguyên tố với mục tiêu Hương Dũng Khí nhận thêm 10% Tấn Công. | Lợi thế trận kế tiếp | Cả 2 banner |
| 22 | Ember | 4★ | Lửa | Tri Thức | nổ lan khi hạ quái | Ember hạ một quái thì vụ nổ gây 50% Tấn Công sát thương Lửa lên mọi quái còn lại (tối đa 1 lần mỗi hành động). | Tác động quái trên map | Cả 2 banner |
| 23 | Neris | 4★ | Nước | Săn Bắn | bảo hiểm bạo kích | Mỗi đòn không bạo kích: Neris +12% Tỉ Lệ Bạo Kích (cộng dồn); bạo kích thì mất hết. | Tiện ích khám phá | Cả 2 banner |
| 24 | Pip | 4★ | Sét | Hòa Hợp | sạc năng lượng đồng đội | Đầu mỗi lượt của Pip, đồng minh có tỉ lệ năng lượng thấp nhất (trừ Pip) nhận 8 năng lượng. | Lợi thế trận kế tiếp | Cả 2 banner |
| 25 | Echo | 4★ | Hồn | Hư Vô | nhân bản hiệu ứng xấu | Mỗi khi đồng minh khác gắn hiệu ứng xấu lên quái, Echo gắn bản sao hiệu ứng đó lên 1 quái ngẫu nhiên khác (tối đa 1 lần mỗi lượt của đồng minh đó). | Tiện ích khám phá | Cả 2 banner |

**Kiểm tra tự động (khi sinh file):**

- 25 cơ chế Đặc tính khác nhau (cột "Cơ chế Đặc tính" không có dòng trùng).
- Bí Kỹ của 24 nhân vật trong banner/miễn phí chia đều: Lợi thế trận kế tiếp 8, Tác động quái trên map 8, Tiện ích khám phá 8 (nhân vật chính thêm 1 Tiện ích khám phá).
- Nguyên tố / vận mệnh / hạng khớp bảng mục 8.
- Mỗi nguyên tố (24 người): Nước 3, Lửa 3, Mộc 4, Sét 3, Phong 4, Độc 4, Hồn 3.
- Mỗi vận mệnh (24 người): Trù Phú 3, Hòa Hợp 4, Bảo Hộ 3, Hư Vô 4, Hủy Diệt 3, Săn Bắn 4, Tri Thức 3.

**Vật cản nguyên tố có người mở sau Phase 7:** Phong (Zephyra, Aldric, Kestrel, Wisp) mở sương mù; Độc (Vesper, Quill, Vael, Selka) mở cổng gỉ – chỉ dùng cho rương ẩn, không chặn đường chính.
