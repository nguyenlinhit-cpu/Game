"""Sprite pixel ngoài map của Quill (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/quill/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "quill",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12)
    "keys": {"O": "#141018", "R": "#C26A2E", "r": "#8A4420", "H": "#6B4A2E", "S": "#F4D2BC", "E": "#7FB43A",
             "W": "#F4F4F0", "P": "#9BC53D", "K": "#5E3E26", "G": "#C9A04A", "T": "#CFEFD8"},
    "eyes": ["#7FB43A"], "skin": "#F4D2BC", "lid": "#5E3E26",
    "head_ratio": 0.5,
    "flap_side": "left", "flap_rows": 8, "flap_width": 5,   # ba lô ống nghiệm nảy (bên phải là ống tiêm)
    "feet_split": 11,
    "spark": "#9BC53D",                                      # vệt thuốc khi lướt
})
