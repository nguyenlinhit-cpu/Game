"""Sprite pixel ngoài map của Zephyra (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/zephyra/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "zephyra",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12)
    "keys": {"O": "#141018", "H": "#4FD1B5", "h": "#2F8F80", "S": "#F7DDD0", "E": "#8FD3F4", "W": "#F5F7F7",
             "w": "#C9DCE0", "Y": "#F4E3A1", "G": "#2FA88E", "N": "#2B3550", "B": "#2A6E62"},
    "eyes": ["#8FD3F4"], "skin": "#F7DDD0", "lid": "#2B3550",
    "head_ratio": 0.6,
    "flap_side": "left", "flap_rows": 10, "flap_width": 6,   # tóc + dải lụa bên trái bay (bên phải là quạt)
    "feet_split": 17,
    "spark": "#C9F5EA",                                      # vệt gió khi lướt
})
