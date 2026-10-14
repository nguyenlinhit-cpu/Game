"""Sprite pixel ngoài map của Orrin (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/orrin/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "orrin",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12)
    "keys": {"O": "#141018", "N": "#1E2747", "n": "#2E3A66", "W": "#EDEBE6", "w": "#B9B6AE", "S": "#EBC6A8",
             "E": "#F2D58A", "G": "#C9A04A", "K": "#7A4E2D", "P": "#F4EEDF", "B": "#3A2A20"},
    "eyes": ["#F2D58A"], "skin": "#EBC6A8", "lid": "#7A4E2D",
    "head_ratio": 0.58,
    "flap_side": "left", "flap_rows": 12, "flap_width": 6,   # sách bay bên trái nhấp nhô (bên phải là bút)
    "feet_split": 15,
    "spark": "#F2D58A",                                      # vệt chữ vàng khi lướt
})
