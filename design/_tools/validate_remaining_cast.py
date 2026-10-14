"""Validate rendered design artifacts, metadata, palettes and frame bounds.

blender -b -P design/_tools/validate_remaining_cast.py
This checks design deliverables; it does not change game files or approve art.
"""
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import json
import struct
from collections import Counter
import numpy as np
from vfx2d import load_rgba
from build_remaining_cast import CAST, PALETTES
ROOT=Path(__file__).resolve().parents[1]
BATTLE={'idle':6,'attack':8,'skill':10,'ultimate':12,'hit':4,'down':6,'victory':8}
MAP={'idle':4,'run':6,'dash':3,'opener':5,'technique':6}

def png_size(p):
 with p.open('rb') as f:h=f.read(26)
 assert h[:8]==b'\x89PNG\r\n\x1a\n',str(p)
 w,hgt=struct.unpack('>II',h[16:24]);assert h[24]==8 and h[25]==6,(p,'RGBA8 required')
 return w,hgt

def main():
 report={'characters':[],'errors':[],'warnings':[]};counts=Counter()
 for ident in CAST:
  folder=ROOT/'nhan_vat'/ident;entry={'id':ident,'modes':{}}
  try:
   for mode,actions,F in [('battle',BATTLE,512),('map',MAP,32)]:
    path=folder/'5_render'/f'{mode}_{ident}.png';meta=json.loads(path.with_suffix('.json').read_text());w,h=png_size(path)
    assert meta['asset_id']==ident and meta['frame_size']==[F,F] and meta['fps']==12
    assert Counter(e['action'] for e in meta['frames'])==Counter(actions)
    assert w==max(actions.values())*F and h==len(actions)*F
    assert meta['hit_frame']==({'attack':4,'skill':6,'ultimate':8} if mode=='battle' else {'opener':2})
    sheet=load_rgba(path);edge=[];ult=[];trail_edges=[]
    for e in meta['frames']:
     f=sheet[e['y']:e['y']+F,e['x']:e['x']+F];a=f[...,3]>.2
     assert e['dir']==('e' if mode=='map' else '')
     if a[0].any() or a[-1].any() or a[:,0].any() or a[:,-1].any():
      expected=False
      if mode=='map' and e['action'] in ('dash','technique') and not (a[0].any() or a[-1].any() or a[:,-1].any()):
       ys=np.flatnonzero(a[:,0]);hcol=PALETTES[ident][-1]
       spark=np.array([int(hcol[k:k+2],16)/255 for k in (1,3,5)])
       expected=set(ys).issubset({11,17,23}) and np.abs(f[ys,0,:3]-spark).max()<.01
      (trail_edges if expected else edge).append(f"{e['action']}:{e['index']}")
     # Echo's technique disappears intentionally.
     assert a.any() or ident=='echo' and mode=='map' and e['action']=='technique' and e['index']>=3
     if e['action']=='ultimate':ult.append(f.copy())
    colors=None
    if mode=='map':
     rgb=np.clip(sheet[...,:3][sheet[...,3]>.5]*255+.5,0,255).astype(np.uint8)
     colors=len(np.unique(rgb,axis=0));assert colors<=12,(ident,colors)
     assert np.isin(sheet[...,3],[0,1]).all(),(ident,'map alpha must be crisp')
    else:
     assert np.array_equal(ult[-1],ult[-2]),(ident,'ultimate does not hold final two frames')
    if edge:report['warnings'].append(dict(id=ident,mode=mode,frame_edges=edge))
    for action in actions:
     p=folder/'5_render/preview'/f'{mode}_{action}.gif';assert p.stat().st_size>100
    entry['modes'][mode]={'frames':len(meta['frames']),'colors':colors,'edge_frames':edge,'intentional_speed_trails_at_left_border':trail_edges};counts[mode+'_frames']+=len(meta['frames'])
    del sheet
   for name in ['attack','skill','ultimate','opener','technique']+(['ultimate_blast'] if ident.startswith('traveler') else []):
    out=folder/'6_vfx'/name;meta=json.loads((out/(name+'.json')).read_text());assert meta['owner']==ident
    assert (out/('preview_'+name+'.gif')).stat().st_size>100
    if name in ('opener','technique'):
     assert meta['size']==[64,64] and meta['colors']<=6
     assert meta['hit_frame']==(2 if name=='opener' else None)
     for i in range(meta['frames']):assert png_size(out/f'mapvfx_{name}_{i:02d}.png')==(64,64);counts['vfx_frames']+=1
    else:
     assert meta['hit_frame']=={'attack':4,'skill':6,'ultimate':8,'ultimate_blast':8}[name]
     for layer,spec in meta['layers'].items():
      if layer=='hit':assert spec['start_frame']==meta['hit_frame']
      for i in range(spec['frames']):assert png_size(out/layer/f'{i:02d}.png')==tuple(spec['size']);counts['vfx_frames']+=1
     if name.startswith('ultimate'):
      assert meta['cutin']['size']==[1920,540]
      for i in range(meta['cutin']['frames']):assert png_size(out/'cutin'/f'{i:02d}.png')==(1920,540);counts['vfx_frames']+=1
    counts['skills']+=1
   if ident.startswith('traveler'):
    import zipfile,xml.etree.ElementTree as ET
    ora=folder/'2_sketch'/f'{ident}_sketch_v1.ora';kra=ora.with_suffix('.kra')
    with zipfile.ZipFile(ora) as z:
     xml=ET.fromstring(z.read('stack.xml'));assert xml.attrib['w']=='3840' and xml.attrib['h']=='2160'
     assert 'your_sketch' in [l.attrib['name'] for l in xml.findall('.//layer')]
    with zipfile.ZipFile(kra) as z:assert 'maindoc.xml' in z.namelist()
   entry['ok']=True
  except Exception as exc:
   entry['ok']=False;report['errors'].append({'id':ident,'error':str(exc)})
  report['characters'].append(entry);print(ident,'OK' if entry['ok'] else report['errors'][-1],flush=True)
 report['counts']=dict(counts);report['ok']=not report['errors']
 out=ROOT/'_reports/remaining_cast/validation.json';out.write_text(json.dumps(report,ensure_ascii=False,indent=2))
 print(json.dumps({'ok':report['ok'],'counts':report['counts'],'errors':report['errors'],'warnings':report['warnings']},ensure_ascii=False),flush=True)
 if not report['ok']:raise SystemExit(1)
if __name__=='__main__':main()
