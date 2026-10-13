# Hướng dẫn build và xuất bản

Dự án: Godot **4.7.2** (renderer Compatibility). Cấu hình xuất ở `export_presets.cfg`:

| Preset | File ra | Ghi chú |
| --- | --- | --- |
| Windows Desktop | `build/windows/Aethelgard.exe` (+ `Aethelgard.console.exe` để xem log) | PCK nhúng trong exe |
| Linux | `build/linux/Aethelgard.x86_64` | Dùng để tự kiểm tra bản build trên máy Linux |
| Android | `build/android/Aethelgard.apk` | Cần Android SDK + JDK 17 + keystore (xem dưới) |

Bản build bỏ `tests/`, `tools/`, `art_specs/`, `docs/` và JSON sprite sheet (chỉ công cụ nhập cần); giữ mọi JSON dữ liệu
(`data/**/*.json`: cốt truyện, hội thoại, âm thanh, yêu cầu hình).

## 1. Cài export template (một lần)

- Editor: Editor → Manage Export Templates → Download and Install (đúng bản 4.7.2).
- Hoặc tay: tải `Godot_v4.7.2-stable_export_templates.tpz` ở https://github.com/godotengine/godot/releases/tag/4.7.2-stable,
  giải nén (là file zip) và chép nội dung thư mục `templates/` vào:
  - Linux: `~/.local/share/godot/export_templates/4.7.2.stable/`
  - Windows: `%APPDATA%\Godot\export_templates\4.7.2.stable\`
  Cần ít nhất `windows_release_x86_64.exe`, `windows_debug_x86_64.exe`, `linux_release.x86_64`, `linux_debug.x86_64`, `version.txt`.

## 2. Trước khi build

```bash
godot --headless --path . --import                      # import lại mọi tài nguyên (sau khi thả hình / âm thanh mới)
godot --headless --path . res://tools/import_assets/import_assets.tscn   # nhận hình mới (Phase 13)
# Chạy toàn bộ test (mỗi lệnh in "Phase N: x/y kiểm tra đạt", thoát mã 1 nếu có lỗi):
for t in phase01_smoke_test phase02_test phase03_test phase04_test phase05_test phase06_test phase07_test \
         phase08_test phase09_test phase10_test phase11_test phase12_test phase13_test phase14_test; do
  godot --headless --path . res://tests/$t.tscn | tail -1
done
godot --headless --path . res://systems/economy_report.tscn      # docs/ECONOMY_REPORT.md, phải ĐẠT
godot --headless --path . res://tools/balance/boss_report.tscn   # docs/BOSS_REPORT.md
```

## 3. Build

```bash
mkdir -p build/windows build/linux
godot --headless --path . --export-release "Windows Desktop" build/windows/Aethelgard.exe
godot --headless --path . --export-release "Linux" build/linux/Aethelgard.x86_64
```

(Trong editor: Project → Export → chọn preset → Export Project, bỏ chọn "Export With Debug".)

## 4. Tự kiểm tra bản build

Bản build có chế độ tự kiểm tra (`systems/build_check.gd`): giới hạn cấp 30, đội tối đa 4, dữ liệu cốt truyện /
5 bản đồ / 2 banner / file dịch có trong gói, lưu → tải đúng. Thoát mã 0 nếu đạt hết.

```bash
build/linux/Aethelgard.x86_64 --headless -- --self-check
# Windows (cmd):  build\windows\Aethelgard.console.exe --headless -- --self-check
```

Sau đó chơi thử: Bắt đầu → lời dẫn → tạo nhân vật → Sảnh; lưu ở menu (Esc → Lưu / Tải), thoát, Tiếp tục.
Save và cài đặt nằm ở `%APPDATA%\Godot\app_userdata\Aethelgard_ Mảnh Hồn\` (Windows) hoặc
`~/.local/share/godot/app_userdata/Aethelgard_ Mảnh Hồn/` (Linux).

## 5. Android (thử)

1. Cài Android SDK (platform-tools, build-tools, platform 34), JDK 17; Editor Settings → Export → Android: đường dẫn SDK
   và Java.
2. Tạo keystore: `keytool -genkeypair -v -keystore release.keystore -alias aethelgard -keyalg RSA -validity 10000`;
   điền vào preset Android (Keystore → Release) hoặc dùng debug keystore để thử.
3. `godot --headless --path . --export-debug "Android" build/android/Aethelgard.apk`, cài bằng `adb install`.
4. Trên điện thoại: joystick ảo + nút Chém / Lướt / Bí Kỹ / F / ☰ Menu tự hiện; trận đánh bấm thẳng nút và quái.

## 6. Khi đổi phiên bản Godot

Đổi template tương ứng; mở dự án trong editor mới một lần để nâng file (`.import`, `.uid`), chạy lại toàn bộ test.
