"""Sprite pixel ngoài map của Chuột Mực Sách (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/quai/ink_rat/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "ink_rat", "kind": "quai",
    "keys": {"K": "#1C1C26", "k": "#34344A", "B": "#4A4A5A", "E": "#8A6A70", "G": "#4FD1B5", "N": "#B89A4A", "n": "#7A6230", "I": "#2E2A4A", "P": "#C98A8A"},
    "eyes": [],
    "flap_side": "left", "flap_rows": 8,
    "spark": "#4FD1B5",
    # quái ngoài map chỉ cần idle + run (art_requirements.json)
    "actions": {"idle": 4, "run": 6}, "hit_frames": {}, "loops": ["idle", "run"],
})
