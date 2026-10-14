"""Editable 32×32 map sprite, only east; shared pixel animation plus character-specific motion."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))
from pixel2d import run
from character_pixel_motion import character_frames
CONFIG = {'id': 'wisp',
 'keys': {'H': '#E6FBF6',
          'h': '#9ABDBB',
          'S': '#F4E8EC',
          'E': '#B9A3E3',
          'B': '#F2F6F7',
          'b': '#AFCBD1',
          'G': '#4FD1B5',
          'W': '#F7FFFF',
          'K': '#C7CCD4',
          'A': '#CFEFEA',
          'L': '#7BA9AE',
          'O': '#141018'},
 'eyes': ['#B9A3E3'],
 'skin': '#F4E8EC',
 'lid': '#9ABDBB',
 'head_ratio': 0.58,
 'feet_split': 15,
 'flap_side': 'left',
 'flap_width': 4,
 'flap_rows': 9,
 'spark': '#7BA9AE'}
CONFIG["frames"] = character_frames
if __name__ == "__main__":
    run(CONFIG)
