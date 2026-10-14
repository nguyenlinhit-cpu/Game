"""Editable 32×32 map sprite, only east; shared pixel animation plus character-specific motion."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))
from pixel2d import run
from character_pixel_motion import character_frames
CONFIG = {'id': 'echo',
 'keys': {'H': '#F2E2A8',
          'h': '#BCAD8A',
          'S': '#F3DCD2',
          'E': '#8E6FD8',
          'B': '#27232F',
          'b': '#15151C',
          'G': '#F2D58A',
          'W': '#F4F4F4',
          'K': '#C7CCD4',
          'A': '#615376',
          'L': '#B6A0DD',
          'O': '#141018'},
 'eyes': ['#8E6FD8'],
 'skin': '#F3DCD2',
 'lid': '#BCAD8A',
 'head_ratio': 0.58,
 'feet_split': 15,
 'flap_side': 'left',
 'flap_width': 4,
 'flap_rows': 9,
 'spark': '#B6A0DD'}
CONFIG["frames"] = character_frames
if __name__ == "__main__":
    run(CONFIG)
