"""Render the final cast in bounded Blender workers, with per-stage logs and timings.

python3 design/_tools/render_remaining_cast.py [--ids fenna,pip] [--resume]
No game imports. --resume skips complete stages; failures retain their logs.
"""
import argparse
import concurrent.futures
import json
import os
from pathlib import Path
import shutil
import subprocess
import time
from build_remaining_cast import CAST

ROOT=Path(__file__).resolve().parents[1]
REPORT=ROOT/'_reports/remaining_cast';REPORT.mkdir(parents=True,exist_ok=True)

def render(ident,resume,selected):
 folder=ROOT/'nhan_vat'/ident;beg=time.monotonic();stages=[]
 for stage,script,check in [('battle',folder/'4_rig2d/rig_battle.py',folder/'5_render'/f'battle_{ident}.json'),('map',folder/'4_rig2d/pixel_map.py',folder/'5_render'/f'map_{ident}.json'),('vfx',folder/'6_vfx'/f'make_{ident}_vfx.py',folder/'6_vfx/technique/technique.json')]:
  if stage not in selected:continue
  if not (resume and check.exists()):
   log=REPORT/f'{ident}_{stage}.log';t=time.monotonic()
   with log.open('w') as out:
    env=os.environ.copy();env['ALSOFT_DRIVERS']='null'
    proc=subprocess.run(['blender','-b','-noaudio','-t','2','-P',str(script)],stdout=out,stderr=subprocess.STDOUT,env=env,timeout=900)
   elapsed=round(time.monotonic()-t,1)
   if proc.returncode or not check.exists():
    print(f'FAILED {ident} {stage}: {log}',flush=True)
    return dict(id=ident,ok=False,stage=stage,log=str(log))
   stages.append(dict(stage=stage,seconds=elapsed));print(ident,stage,elapsed,'s',flush=True)
  if stage=='map' and ident.startswith('traveler'):
   shutil.copy2(folder/'4_rig2d/map_base.png',folder/'1_concept/1d_pixel.png')
 return dict(id=ident,ok=True,seconds=round(time.monotonic()-beg,1),stages=stages)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--ids',default=','.join(CAST));ap.add_argument('--resume',action='store_true');ap.add_argument('--stages',default='battle,map,vfx');ap.add_argument('--report-tag',default='render');args=ap.parse_args()
 with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
  results=list(pool.map(lambda x:render(x,args.resume,args.stages.split(',')),args.ids.split(',')))
 (REPORT/(args.report_tag+'_results.json')).write_text(json.dumps(results,indent=2))
 print('FINISHED',sum(r['ok'] for r in results),'/',len(results),flush=True)
 if not all(r['ok'] for r in results):raise SystemExit(1)
if __name__=='__main__':main()
