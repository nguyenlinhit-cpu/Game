"""Sprite pixel ngoài map của Nyx (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/nyx/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import OUTLINE, default_frames, run, shift  # noqa: E402


def glitch(f, k):
    """Nhiễu sọc điện: các dải 2 hàng lệch ngang ±1 px xen kẽ (k đổi pha)."""
    out = np.zeros_like(f)
    for y in range(f.shape[0]):
        d = (1 if (y // 2 + k) % 2 else -1) if (y // 2 + k) % 3 else 0
        out[y:y + 1] = shift(f[y:y + 1], 0, d)
    return out


def dither(f, keep):
    """Trong suốt kiểu pixel: bỏ pixel theo lưới bàn cờ (keep = 1/2 hoặc 1/4 số pixel còn lại)."""
    y, x = np.mgrid[0:f.shape[0], 0:f.shape[1]]
    mask = (x + y) % 2 == 0 if keep == 2 else ((x % 2 == 0) & (y % 2 == 0))
    out = f.copy()
    out[~mask] = 0
    return out


def frames(p, cfg):
    """Bộ chuẩn, riêng technique: bấm nút găng → thân nhiễu sọc rồi trong suốt (mờ ~60%) → chỉ còn viền mờ."""
    seq = default_frames(p, cfg)
    base = p.compose()
    outline_only = base.copy()
    outline_only[np.abs(base[..., :3] - OUTLINE).sum(axis=2) > 0.02] = 0
    seq["technique"] = [p.compose(), p.compose(lean=-1, squint=True),
                        glitch(base, 0), dither(glitch(base, 1), 2), dither(glitch(base, 2), 2),
                        dither(outline_only, 2)]
    return seq


run({
    "id": "nyx",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12). Tóc sáng hơn #1E1B26 một bậc để không lẫn vào viền.
    "keys": {"O": "#141018", "H": "#2E2A3C", "J": "#24212E", "j": "#3E3850", "V": "#A65BF2", "E": "#B07BFF",
             "S": "#F3D6C6", "N": "#3A1F4A", "C": "#C77A3A", "c": "#8A4E22", "G": "#BFC3CC", "P": "#3B2A33"},
    "eyes": ["#B07BFF"], "skin": "#F3D6C6", "lid": "#3A1F4A",
    "flap_side": "left", "flap_rows": 8,   # tóc sau gáy nảy (bên phải là găng đồng)
    "feet_split": 15,                      # dây cáp ở cột trái không được tính là khe giữa hai chân
    "spark": "#A65BF2",                    # vệt điện khi lướt
    "frames": frames,
})
