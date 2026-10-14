"""Editable 32×32 map sprite, only east; shared pixel animation plus character-specific motion."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))
from pixel2d import run
from character_pixel_motion import character_frames
CONFIG = {'id': 'fenna',
 'keys': {'H': '#AA5A2C',
          'h': '#743D27',
          'S': '#F3D4B3',
          'E': '#F1A23A',
          'B': '#5D763B',
          'b': '#364D2C',
          'G': '#C67C32',
          'W': '#EEE6CB',
          'K': '#8D603A',
          'A': '#C0A56B',
          'L': '#B8CE84',
          'O': '#141018'},
 'eyes': ['#F1A23A'],
 'skin': '#F3D4B3',
 'lid': '#743D27',
 'head_ratio': 0.58,
 'feet_split': 15,
 'flap_side': 'left',
 'flap_width': 4,
 'flap_rows': 9,
 'spark': '#B8CE84'}
CONFIG["frames"] = character_frames
if __name__ == "__main__":
    run(CONFIG)
