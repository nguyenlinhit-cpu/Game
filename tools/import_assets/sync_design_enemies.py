"""Validate every production enemy and copy its rendered assets into Godot."""
from collections import Counter
import json
from pathlib import Path
import re
import shutil
import struct

ROOT=Path(__file__).resolve().parents[2]
COUNTS={'idle':6,'attack':8,'skill':10,'hit':4,'down':6}


def validate_sheet(path,mode,ident,phase=1):
    data=json.loads(path.read_text());png=path.with_suffix('.png');header=png.read_bytes()[:26]
    assert header[:8]==b'\x89PNG\r\n\x1a\n' and header[24:26]==bytes([8,6]), png
    width,height=struct.unpack('>II',header[16:24]);fw,fh=data['frame_size']
    assert max(width,height)<=16384 and data['fps']>0, path
    counts=Counter();indices={}
    for frame in data['frames']:
        assert 0<=frame['x']<=width-fw and 0<=frame['y']<=height-fh,path
        name=frame['action'];counts[name]+=1
        indices.setdefault(name,[]).append(frame['index'])
    for name,values in indices.items():assert sorted(values)==list(range(len(values))), (path,name)
    if mode=='battle':
        for action,count in COUNTS.items():
            action=action if phase==1 else f'{action}-p{phase}'
            assert counts[action]==count,(path,action,counts[action])
    if mode=='map':
        assert counts['idle']==4 and counts['run']==6 and counts['windup']==3,path
    return data,png


def main():
    copies=[];results=[]
    for file in sorted((ROOT/'data/enemies').glob('*.tres')):
        text=file.read_text();match=re.search(r'^family = &"(.*?)"',text,re.M)
        if not match:continue
        family=match[1];ident=re.search(r'^id = &"(.*?)"',text,re.M)[1]
        kind=int(re.search(r'^kind = (\d+)',text,re.M)[1])
        phases=1+len(re.findall(r'\[sub_resource type="Resource" id="Phase_\d+"\]',text))
        source=ROOT/'design/quai'/family/'5_render'/ident
        target=ROOT/'assets/enemies'/ident
        for phase in range(1,phases+1):
            suffix='' if phase==1 else f'-p{phase}'
            path=source/f'battle_{ident}{suffix}.json';data,png=validate_sheet(path,'battle',ident,phase)
            assert data['frame_size']==[{0:256,1:384,2:768}[kind]]*2,path
            for f in (path,png):copies.append((f,target/'battle'/f.name))
        path=source/f'map_{ident}.json';data,png=validate_sheet(path,'map',ident)
        assert data['frame_size']==[48 if kind==2 else 32]*2,path
        for f in (path,png):copies.append((f,target/'map'/f.name))
        if phases>1:
            path=source.parent/f'battle_{family}-transitions.json'
            data,png=validate_sheet(path,'transition',ident)
            for phase in range(2,phases+1):assert sum(fr['action']==f'phase{phase}' for fr in data['frames'])==12,path
            for f in (path,png):copies.append((f,target/'battle'/f.name))
        effects=ROOT/'design/quai'/family/'6_vfx'/ident
        skill_meta=json.loads((effects/'skills.json').read_text())
        required=set(re.findall(r'path="res://data/skills/(en_.*?)\.tres"',text))
        assert required<=skill_meta.keys(),(ident,required-skill_meta.keys())
        counts=Counter()
        for path in sorted(effects.glob('vfx_*.json')):
            data,png=validate_sheet(path,'vfx',ident)
            counts.update(fr['action'] for fr in data['frames'])
            for f in (path,png):copies.append((f,target/'vfx'/f.name))
        for skill in required:
            assert counts[skill]==8 and counts[skill+'-cast']==8,(ident,skill)
            if skill_meta[skill]['screen']:assert counts[skill+'-screen']==8,(ident,skill)
        copies.append((effects/'skills.json',target/'vfx/skills.json'))
        results.append(dict(id=ident,family=family,phases=phases,skills=len(required)))
    assert len(results)==33,len(results)
    changed=0
    for source,target in copies:
        if target.exists() and target.read_bytes()==source.read_bytes():continue
        target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target);changed+=1
    report=ROOT/'design/_reports/enemy_cast/import_validation.json'
    report.parent.mkdir(parents=True,exist_ok=True)
    report.write_text(json.dumps(dict(enemies=results,files=len(copies),changed=changed),indent=2))
    print(f'Validated {len(results)} enemies in {len(set(r["family"] for r in results))} families; {changed}/{len(copies)} files updated.')


if __name__=='__main__':main()
