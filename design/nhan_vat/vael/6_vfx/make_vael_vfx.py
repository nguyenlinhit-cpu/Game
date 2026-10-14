"""Procedural 2D skill effects; see remaining_cast_vfx.py and VFX_NOTES.md."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))
from remaining_cast_vfx import run_character
if __name__ == "__main__":
    run_character('vael')
