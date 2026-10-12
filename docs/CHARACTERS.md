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
