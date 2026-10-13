{
  description = "Build the Aethelgard Android debug APK";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.android_sdk.accept_license = true;
        config.allowUnfree = true;
      };
      androidSdk = (pkgs.androidenv.composeAndroidPackages {
        platformVersions = [ "35" ];
        buildToolsVersions = [ "35.0.1" ];
        includeCmake = false;
        includeEmulator = false;
        includeSystemImages = false;
      }).androidsdk;
      buildApk = pkgs.writeShellApplication {
        name = "build-aethelgard-apk";
        runtimeInputs = [ pkgs.godot pkgs.jdk17 pkgs.coreutils ];
        text = ''
          set -euo pipefail

          if [[ ! -f project.godot || ! -f export_presets.cfg ]]; then
            echo "Chạy lệnh trong thư mục gốc của dự án Godot." >&2
            exit 1
          fi

          mkdir -p build
          settings_dir="$(mktemp -d)"
          trap 'rm -rf "$settings_dir"' EXIT
          export XDG_CONFIG_HOME="$settings_dir/config"
          export XDG_DATA_HOME="$settings_dir/data"
          export XDG_CACHE_HOME="$settings_dir/cache"
          mkdir -p "$XDG_CONFIG_HOME/godot" "$XDG_DATA_HOME/godot/export_templates"

          template_version="$(godot --version | cut -d. -f1-3).stable"
          template_dir="''${GODOT_EXPORT_TEMPLATES:-$HOME/.local/share/godot/export_templates/$template_version}"
          if [[ ! -f "$template_dir/android_debug.apk" ]]; then
            template_package="$(nix build --no-link --print-out-paths .#templates)"
            template_dir="$template_package/share/godot/export_templates/$template_version"
            if [[ ! -f "$template_dir/android_debug.apk" ]]; then
              echo "Thiếu export template Android của Godot $template_version: $template_dir" >&2
              exit 1
            fi
          fi
          ln -s "$template_dir" \
            "$XDG_DATA_HOME/godot/export_templates/$template_version"

          cat > "$XDG_CONFIG_HOME/godot/editor_settings-4.7.tres" <<EOF
          [gd_resource type="EditorSettings" format=3]

          [resource]
          export/android/android_sdk_path = "${androidSdk}/libexec/android-sdk"
          export/android/java_sdk_path = "${pkgs.jdk17}"
          export/android/debug_keystore = "$(pwd)/build/debug.keystore"
          export/android/debug_keystore_user = "androiddebugkey"
          export/android/debug_keystore_pass = "android"
          EOF

          if [[ ! -f build/debug.keystore ]]; then
            keytool -genkeypair -keystore build/debug.keystore \
              -alias androiddebugkey -storepass android -keypass android \
              -keyalg RSA -keysize 2048 -validity 10000 \
              -dname "CN=Android Debug,O=Android,C=US" -noprompt
          fi

          godot --headless --path . --import
          godot --headless --path . --export-debug Android build/Aethelgard.apk
          test -s build/Aethelgard.apk
          echo "APK: $(pwd)/build/Aethelgard.apk"
        '';
      };
    in
    {
      packages.${system}.templates = pkgs.godot_4-export-templates-bin;
      apps.${system}.default = {
        type = "app";
        program = "${buildApk}/bin/build-aethelgard-apk";
        meta.description = "Export a signed Android debug APK into build/";
      };
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.godot pkgs.jdk17 androidSdk ];
      };
    };
}
