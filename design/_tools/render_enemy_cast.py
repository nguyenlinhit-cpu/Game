"""Render all enemy families in bounded Blender subprocesses, recording results."""
import argparse
import concurrent.futures
import json
import os
from pathlib import Path
import subprocess
import threading
import time

ROOT=Path(__file__).resolve().parents[2]
REPORT=ROOT/'design/_reports/enemy_cast'
REPORT.mkdir(parents=True,exist_ok=True)
BOSS_LOCK=threading.Lock()


def render(family,resume):
    start=time.monotonic();log=REPORT/f'{family}.log'
    command=['blender','-b','-noaudio','-t','2','-P',str(ROOT/'design/_tools/enemy_cast.py'),'--','--family',family]
    if resume:command.append('--resume')
    env=os.environ.copy();env['ALSOFT_DRIVERS']='null'
    boss=family in ('library_warden','vault_behemoth','warped_core','soul_devourer')
    if boss:BOSS_LOCK.acquire()
    try:
        with log.open('w') as out:
            proc=subprocess.run(command,stdout=out,stderr=subprocess.STDOUT,env=env,timeout=1800)
        # Blender can exit 0 after a Python exception: require the completion marker.
        ok=proc.returncode==0 and f'COMPLETE {family}:' in log.read_text()
    finally:
        if boss:BOSS_LOCK.release()
    result=dict(family=family,ok=ok,seconds=round(time.monotonic()-start,1),log=str(log.relative_to(ROOT)))
    print(json.dumps(result),flush=True)
    return result


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--ids');parser.add_argument('--resume',action='store_true')
    args=parser.parse_args();families=args.ids.split(',') if args.ids else sorted(p.name for p in (ROOT/'design/quai').iterdir() if p.is_dir())
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        results=list(pool.map(lambda f:render(f,args.resume),families))
    previous={}
    if args.ids and (REPORT/'render_results.json').exists():
        previous={r['family']:r for r in json.loads((REPORT/'render_results.json').read_text())}
    previous.update({r['family']:r for r in results})
    (REPORT/'render_results.json').write_text(json.dumps(list(previous.values()),indent=2))
    if not all(r['ok'] for r in results):raise SystemExit(1)
