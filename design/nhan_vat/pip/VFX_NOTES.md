# Pip – bản nháp hoạt ảnh v1

Bolt và mắt là lớp riêng, có chuyển động bay; Quá Áp phóng Bolt gấp 3 và có cần gạt ở VFX. Cờ lê tách theo đa giác sau khi kiểm tra để không rời lưỡi. Sprite map có Bolt nhún độc lập.

Bản nháp 2D để duyệt. Chỉ hướng phải cho map. Mặt giữ từ concept, chưa tách hình dán để nhắm mắt/mở miệng trong trận. Down hiện khuỵu/gục; victory dùng cử chỉ gần ý brief, chưa đủ mọi thao tác cất vũ khí/tháo mặt nạ. Ánh sáng nhịp thở ở ngực/tóc chưa có lớp riêng cho idle. B2 cũ vẫn giữ trạng thái của bạn.

Nguồn yêu cầu đầy đủ: [ANIMATION_SPEC.md](ANIMATION_SPEC.md). Các PNG 1a_clean là bản dẫn xuất; không ghi đè 1a gốc.

Chạy từ gốc repo:

```bash
blender -b -noaudio -t 2 -P design/nhan_vat/pip/4_rig2d/rig_battle.py
blender -b -noaudio -t 2 -P design/nhan_vat/pip/4_rig2d/pixel_map.py
blender -b -noaudio -t 2 -P design/nhan_vat/pip/6_vfx/make_pip_vfx.py
```

Render lại sprite trước VFX để GIF ghép đúng bản. Không chép vào assets/.
