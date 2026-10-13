# PHASE 01/14 – Khung dự án, lời dẫn, chọn nhân vật chính

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Đây là phase đầu tiên: đọc TOÀN BỘ đặc tả trước, rồi chỉ làm phần việc dưới đây.

## Trước khi code

- Tóm tắt lại game trong 10 dòng ở đầu câu trả lời.
- Liệt kê những điểm đặc tả chưa rõ hoặc mâu thuẫn, kèm phương án bạn chọn.

## Việc cần làm

1. Tạo dự án Godot 4: renderer Compatibility, 1920×1080, stretch mode canvas_items, aspect expand, `.gitignore` cho Godot. Cấu trúc thư mục đúng mục 13.
2. Tạo các autoload có khung hàm (chưa cần logic đầy đủ, ghi TODO): GameState, SaveManager, EventBus, SceneRouter (chuyển scene có hiệu ứng mờ), GachaManager, AudioManager, QuestManager.
3. Input map: di chuyển (WASD, mũi tên, cần trái tay cầm), lướt (Space/Shift), Đòn Mở Màn (J/chuột trái), Bí Kỹ (K/E), đổi nhân vật 1–4, tương tác (F), menu (Esc).
4. Màn hình tiêu đề: Bắt đầu, Tiếp tục (mờ khi chưa có save), Cài đặt (âm lượng tạm), Thoát.
5. Lời dẫn mở đầu (mục 3): chữ chạy từng dòng trên nền tranh tạm, có nút bỏ qua, chữ lấy từ file dịch.
6. Màn chọn nhân vật chính (mục 7): Nam/Nữ (hình tạm khác màu), ô đặt tên (mặc định Kael/Kaela, tối đa 12 ký tự), nút xác nhận. Lưu `player_gender`, `player_name` vào GameState. Cả hai dùng chung 1 CharacterData id `traveler` với 2 skin.
7. Một phòng trống tạm có nhân vật chính đứng giữa, tên hiện trên đầu (chưa cần di chuyển).
8. Tạo `localization/strings.csv` (cột keys, vi, en), `docs/DESIGN_NOTES.md`, `docs/PROGRESS.md`.

## Không làm trong phase này

Di chuyển, quái, trận đánh, dữ liệu nhân vật khác.

## Tiêu chí hoàn thành

- [ ] Bấm chạy → màn tiêu đề → lời dẫn (bỏ qua được) → chọn Nam/Nữ + đặt tên → vào phòng trống.
- [ ] Nhân vật đúng skin đã chọn, tên đúng.
- [ ] Không có lỗi đỏ trong Output.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, cách chạy thử, việc còn nợ. Dừng lại chờ tôi duyệt, không tự làm phase sau.
