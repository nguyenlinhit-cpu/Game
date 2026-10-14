"""Sprite pixel ngoài map của Mầm Ma Biến (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/quai/warp_sprout/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "warp_sprout", "kind": "quai",
    "keys": {"B": "#C9B98A", "b": "#A08A5E", "L": "#7DBF5A", "l": "#4E8A3A", "G": "#9BC53D", "Y": "#E4F27A", "R": "#7A5A3A", "r": "#4E3824", "P": "#B58CFF"},
    "eyes": [],
    "flap_side": "right", "flap_rows": 8,
    "spark": "#E4F27A",
    # quái ngoài map chỉ cần idle + run (art_requirements.json)
    "actions": {"idle": 4, "run": 6}, "hit_frames": {}, "loops": ["idle", "run"],
})
