# Bộ prompt làm game Aethelgard: Mảnh Hồn

Gồm 16 file:

- `GAME_SPEC.md`: đặc tả đầy đủ (cốt truyện, map, chiến đấu, 24 nhân vật, quái, boss, gacha, tài nguyên, nhiệm vụ ngày, đồ họa, kiến trúc code).
- `PHASE_01.md` → `PHASE_14.md`: prompt cho từng giai đoạn, gửi lần lượt.
- `README.md`: file này.

## Cách dùng

1. Tạo thư mục dự án trống, chép `GAME_SPEC.md` vào `docs/GAME_SPEC.md` trong thư mục đó.
2. Mở AI lập trình có quyền đọc/ghi file trong thư mục dự án (Claude Code, Cursor...). Dán nội dung `PHASE_01.md` rồi gửi.
3. AI làm xong sẽ dừng và báo cáo. Mở Godot chạy thử. Ổn thì gửi phase tiếp theo; chưa ổn thì yêu cầu sửa trước khi đi tiếp.
4. Nếu AI chỉ chat được (không đọc được file): dán `GAME_SPEC.md` trước, sau đó dán từng PHASE.
5. Khi mở phiên mới, AI tự đọc `docs/GAME_SPEC.md` và `docs/PROGRESS.md` nên không mất mạch.

Thứ tự: Phase 1 → 14. Phase 13 (đồ họa) làm song song được từ sau Phase 6. Phase 7 có điểm dừng giữa chừng để bạn duyệt thiết kế 20 nhân vật trước khi AI code.

## Những điểm đã chốt

- Giới hạn cấp hiện tại 30 (đột phá ở cấp 10 và 20, kỹ năng tối đa cấp 5).
- Trong trận tối đa 4 nhân vật, không đổi người giữa trận.
- Nhiệm vụ hàng ngày cho 100 Lệ Tinh/ngày, nhiệm vụ tuần cho 160 Lệ Tinh + 2 vé/tuần.
- Nội dung một lần cho khoảng 78 lượt quay; nhiệm vụ cho khoảng 32 lượt/tháng.
- Nhân vật chính không tính trong 24 nhân vật; nguyên tố thứ 7 là Hồn.

## Lưu ý

AI không tự vẽ trong Blender hay Krita. Nó viết script render, bảng thông số hình (`art_specs/`) và dùng hình tạm; bạn vẽ/dựng rồi thả file vào `assets/` theo quy tắc tên ở mục 12.
