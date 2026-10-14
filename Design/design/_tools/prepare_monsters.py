from pathlib import Path
import re,json
jobs=[]
for src in sorted(Path('Prompt 3/quai').glob('Q*.md')):
 t=src.read_text();ident=src.stem[4:];folder=Path('design/quai')/ident
 (folder/'1_concept/variants').mkdir(parents=True,exist_ok=True);(folder/'2_sketch').mkdir(exist_ok=True)
 intro=t.split('## Bước 1')[0];variants=[{'id':a,'element':b.strip(),'color':c} for a,b,c in re.findall(r'\| `([^`]+)` \| ([^|]+) \| `?(#[0-9A-Fa-f]{6})`? \|',intro)]
 sec=t.split('## Bước 1')[1].split('## Bước 2')[0];blocks=[b.strip() for b in re.findall(r'```text\n(.*?)```',sec,re.S) if not b.startswith('realistic,')]
 has_pixel=blocks[-1].startswith('Pixel art');phase_count=len(blocks)-(4 if has_pixel else 3)
 filenames=['1a_battle.png']+[f'1a_battle_p{k}.png' for k in range(2,2+phase_count)]+['1b_front.png','1b_side.png']+(['1c_pixel.png'] if has_pixel else [])
 palette=re.findall(r'\| ([^|]+?) \| `?(#[0-9A-Fa-f]{6})`? \|',t.split('Bảng màu gốc:')[1].split('```text')[0])
 scale=re.search(r'Khung trận (.*?)\n',intro).group(0).strip();phases=re.findall(r'^- GĐ.*',intro,re.M)
 desc=blocks[0].split('Three-quarter view')[0]
 meta={'id':ident,'title':t.splitlines()[0][2:],'palette':palette,'variants':variants,'scale':scale,'phases':phases,'identity':desc,'category':t.splitlines()[0].split('–')[-1].strip(),'has_pixel':has_pixel}
 prompts=[]
 for asset,prompt in zip(filenames,blocks):
  prompt=prompt.replace('character turnaround reference.','individual pose reference.').replace('; the worker bee drone version is 30 percent smaller','')
  if asset=='1b_side.png':prompt+=' Side profile FACING LEFT. Identity: '+desc
  if asset=='1a_battle.png':prompt+=' Accent glow '+variants[0]['color']+'. Material palette: '+', '.join(a.strip()+' '+b for a,b in palette)+'.'
  prompt+='\nONE individual creature ONLY centered, full body all appendages and props visible with generous margins. Never a reference sheet, collage, inset, multiple angles or duplicate poses. Compact chibi cel-shaded game design. No text or watermark.'
  prompts.append({'asset':asset,'prompt':prompt,'transparent_background':asset=='1c_pixel.png'})
 for v in variants:
  alias=v['color']==variants[0]['color'] and 'drone' not in v['id']
  prompt='Use case: precise-object-edit. Create '+v['id']+' variant of EXACTLY the same creature. Preserve all anatomy silhouette pose materials props markings. Change ONLY elemental accent/glow to '+v['color']+' ('+v['element']+'). Keep non-element colors unchanged. ONE creature three-quarter facing LEFT on white, fully visible same generous margins. No sheet extra views duplicates text or watermark.'
  if 'drone' in v['id']:prompt+=' Worker drone: physically 30 percent smaller than parent on SAME size canvas; four wings stinger fuzzy striped body unchanged. Do not show parent.'
  prompts.append({'asset':'variants/'+v['id']+'.png','prompt':prompt,'transparent_background':False,'copy_base':alias})
 data={'tool':'image_gen built-in','reference':'1a_battle.png for views phases variants','metadata':meta,'prompts':prompts}
 p=folder/'1_concept/PROMPTS.json'
 p.write_text(json.dumps(data,ensure_ascii=False,indent=2))
 (folder/'BRIEF.md').write_text(t.split('## Bước 3')[0]+'\n## Phạm vi thực hiện\nChỉ concept và sketch. Kèm biến thể nguyên tố và giai đoạn boss để duyệt. Pixel AI là tham khảo thị giác, chưa phải sprite chuẩn.\n')
 jobs.append(data)
Path('design/_tools/monster_concepts.json').write_text(json.dumps(jobs,ensure_ascii=False,indent=2))
print('Families:',len(jobs),'variants:',sum(len(j['metadata']['variants']) for j in jobs),'extra phases:',sum(len(j['metadata']['phases'])-1 for j in jobs if j['metadata']['phases']),'imagegen calls:',sum(not p.get('copy_base') for j in jobs for p in j['prompts']))
