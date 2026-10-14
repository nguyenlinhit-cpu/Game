"""Editable 32×32 map sprite, only east; shared pixel animation plus character-specific motion."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))
from pixel2d import run
from character_pixel_motion import character_frames
CONFIG = {'id': 'ember',
 'keys': {'H': '#E8552B',
          'h': '#9B3022',
          'S': '#F3CFAD',
          'E': '#E8AE3D',
          'B': '#4E3834',
          'b': '#2C262B',
          'G': '#E87532',
          'W': '#E9DABC',
          'K': '#79503A',
          'A': '#B9914D',
          'L': '#FFD16D',
          'O': '#141018'},
 'eyes': ['#E8AE3D'],
 'skin': '#F3CFAD',
 'lid': '#9B3022',
 'head_ratio': 0.58,
 'feet_split': 15,
 'flap_side': 'left',
 'flap_width': 4,
 'flap_rows': 9,
 'spark': '#FFD16D'}
CONFIG["frames"] = character_frames
if __name__ == "__main__":
    run(CONFIG)
