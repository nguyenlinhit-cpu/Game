"""Sprite pixel ngoài map của Rook (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/rook/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "rook",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12)
    "keys": {"O": "#141018", "H": "#4E7A3A", "S": "#D8A07A", "E": "#3F6F3A", "R": "#8E2B2B", "r": "#5E1A1A",
             "W": "#7A5232", "G": "#8A8A86", "A": "#9AA3AD", "K": "#3E3A2A", "N": "#4A3020"},
    "eyes": ["#3F6F3A"], "skin": "#D8A07A", "lid": "#4A3020",
    "head_ratio": 0.48,
    "flap_side": "left", "flap_rows": 10, "flap_width": 7,   # lưỡi rìu sau vai nhấp nhô
    "feet_split": 15,
    "spark": "#6CC36A",                                      # vệt lá khi lướt
})
