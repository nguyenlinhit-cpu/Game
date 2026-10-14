"""Sprite pixel ngoài map của Hồn Ảnh Lang Thang (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/quai/wandering_shade/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "wandering_shade", "kind": "quai",
    "keys": {"C": "#5B5F7A", "c": "#3E4158", "K": "#15161E", "Y": "#F2D58A", "y": "#FFF3C4", "R": "#8A6A3A", "S": "#C9D6E8", "s": "#93A6C4"},
    "eyes": [],
    "flap_side": "left", "flap_rows": 8,
    "spark": "#FFF3C4",
    # quái ngoài map chỉ cần idle + run (art_requirements.json)
    "actions": {"idle": 4, "run": 6}, "hit_frames": {}, "loops": ["idle", "run"],
})
