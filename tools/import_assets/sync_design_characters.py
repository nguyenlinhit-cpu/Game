"""Validate and copy rendered character assets from design into the game.

Run from any directory: python3 tools/import_assets/sync_design_characters.py
Then run Godot --import and tools/import_assets/import_assets.tscn.
This does not change the user's design review decisions.
"""

import json
import shutil
import struct
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def png_size(path):
    header = path.read_bytes()[:26]
    assert header[:8] == b"\x89PNG\r\n\x1a\n", path
    assert header[24:26] == bytes([8, 6]), f"Expected RGBA8: {path}"
    return struct.unpack(">II", header[16:24])


def main():
    copies = []
    characters = []
    for folder in sorted((ROOT / "design/nhan_vat").iterdir()):
        if not folder.is_dir():
            continue
        ident = folder.name
        destination = ROOT / "assets/characters" / ident
        if not (folder / "5_render" / f"battle_{ident}.json").exists():
            continue
        for mode in ("map", "battle"):
            meta = folder / "5_render" / f"{mode}_{ident}.json"
            sheet = meta.with_suffix(".png")
            data = json.loads(meta.read_text())
            width, height = png_size(sheet)
            fw, fh = data["frame_size"]
            counts = Counter()
            for frame in data["frames"]:
                assert 0 <= frame["x"] <= width - fw and 0 <= frame["y"] <= height - fh, meta
                counts[frame["action"]] += 1
            required = {"idle", "run", "dash", "opener", "technique"} if mode == "map" else {
                "idle", "attack", "skill", "ultimate", "hit", "down", "victory"}
            assert required <= counts.keys() and data["fps"] > 0, meta
            for source in (meta, sheet):
                copies.append((source, destination / mode / source.name))
        for skill_dir in sorted((folder / "6_vfx").iterdir()):
            if not skill_dir.is_dir():
                continue
            skill = skill_dir.name
            meta = skill_dir / f"{skill}.json"
            if not meta.exists():
                continue
            data = json.loads(meta.read_text())
            assert data["owner"] == ident and data["fps"] > 0, meta
            copies.append((meta, destination / "vfx" / meta.name))
            if "layers" in data:
                for layer, spec in data["layers"].items():
                    frames = sorted((skill_dir / layer).glob("*.png"))
                    assert len(frames) == spec["frames"], (meta, layer)
                    animation = skill if layer == "hit" else f"{skill}-{layer}"
                    for index, source in enumerate(frames):
                        assert png_size(source) == tuple(spec["size"]), source
                        copies.append((source, destination / "vfx" / f"vfx_{ident}_{animation}_{index:02d}.png"))
            else:
                frames = sorted(skill_dir.glob(f"mapvfx_{skill}_*.png"))
                assert len(frames) == data["frames"], meta
                for index, source in enumerate(frames):
                    assert png_size(source) == tuple(data["size"]), source
                    copies.append((source, destination / "vfx" / f"vfx_{ident}_{skill}_{index:02d}.png"))
        characters.append(ident)
    # Validate the whole batch before writing any assets.
    changed = 0
    for source, target in copies:
        if target.exists() and source.read_bytes() == target.read_bytes():
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        changed += 1
    print(f"Validated {len(characters)} character skins; updated {changed}/{len(copies)} files.")
    print(", ".join(characters))


if __name__ == "__main__":
    main()
