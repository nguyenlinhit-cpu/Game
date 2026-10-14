"""Editable 32×32 map sprite, only east; shared pixel animation plus character-specific motion."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))
from pixel2d import run
from character_pixel_motion import character_frames
CONFIG = {'id': 'vael',
 'keys': {'H': '#A84377',
          'h': '#612946',
          'S': '#F3D2BE',
          'E': '#9BC53D',
          'B': '#622843',
          'b': '#241E2C',
          'G': '#C29C52',
          'W': '#F1E9DB',
          'K': '#806443',
          'A': '#C26491',
          'L': '#C5D975',
          'O': '#141018'},
 'eyes': ['#9BC53D'],
 'skin': '#F3D2BE',
 'lid': '#612946',
 'head_ratio': 0.58,
 'feet_split': 15,
 'flap_side': 'left',
 'flap_width': 4,
 'flap_rows': 9,
 'spark': '#C5D975'}
CONFIG["frames"] = character_frames
if __name__ == "__main__":
    run(CONFIG)
