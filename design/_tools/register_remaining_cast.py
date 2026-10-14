"""Register the completed review drafts, without changing any approval status."""
from pathlib import Path
import json
import re
import hashlib
from build_remaining_cast import CAST
ROOT=Path(__file__).resolve().parents[1]
NAMES={'traveler_male':'Kael','traveler_female':'Kaela','fenna':'Fenna','kestrel':'Kestrel','neris':'Neris','pip':'Pip','ember':'Ember','selka':'Selka','vael':'Vael','wisp':'Wisp','echo':'Echo'}
SKILLS={
 'traveler_male':['Chém Rạn','Hồn Vỡ','Tâm Nhãn Khai Mở','Vết Chém Hồn','Bước Hư Ảnh'],
 'traveler_female':['Chém Rạn','Hồn Vỡ','Tâm Nhãn Khai Mở','Vết Chém Hồn','Bước Hư Ảnh'],
 'fenna':['Tên Nhanh','Mưa Tên','Mũi Tên Định Mệnh','Tên Rừng','Bẫy Dây'],
 'kestrel':['Chém Gió','Xoáy Liềm','Cuồng Phong','Liềm Gió','Lướt Gió'],
 'neris':['Đâm Giáo','Ba Chĩa Xoáy','Sóng Ngầm','Giáo Xuyên','Mắt Đáy Biển'],
 'pip':['Tia Điện Nhỏ','Sạc Nhanh','Quá Áp','Bolt Lao Tới','Sạc Đầy'],
 'ember':['Cầu Lửa Nhỏ','Biển Lửa','Sao Băng Lửa','Đốm Lửa','Mưa Tro'],
 'selka':['Trâm Hương','Hương Dũng Khí','Hội Tụ Hương','Khói Hương','Hương Đồng Điệu'],
 'vael':['Phi Bài Độc','Màn Sương Tím','Đêm Diễn Cuối','Màn Sương Ảo','Bom Độc'],
 'wisp':['Gió Rít','Lời Quên Lãng','Cơn Gió Câm','Hơi Thở Lạnh','Gió Hút'],
 'echo':['Lời Nhại','Lời Nguyền Vọng','Gương Ngàn Mặt','Gương Vỡ','Tiếng Vọng Về'],
}
NOTES={
 'fenna':'Cung và tay đỡ là lớp riêng; tai cáo, hai đoạn khăn có xương. Mũi tên trên concept còn hiện trong tư thế gốc; đạn và mưa tên vẽ riêng ở VFX. Bẫy 16×16 có hai trạng thái chờ/sập.',
 'kestrel':'Hai liềm có vùng tách riêng, bốn xương khăn và hai cánh mắt cá. Chuyển động xoáy mô phỏng bằng tư thế và vệt gió; chưa có hình vẽ quay lưng khi xoay tròn.',
 'neris':'Giáo + hai bàn tay là lớp riêng; thu nhân vật trong khung để giáo dài không chạm mép khi đâm/nhảy. Có hai xương tóc. Sóng ngầm dùng cột nước và dấu lóe vàng; chưa có chữ bạo kích vẽ tay.',
 'pip':'Bolt và mắt là lớp riêng, có chuyển động bay; Quá Áp phóng Bolt gấp 3 và có cần gạt ở VFX. Cờ lê tách theo đa giác sau khi kiểm tra để không rời lưỡi. Sprite map có Bolt nhún độc lập.',
 'ember':'Sách/tay đỡ tách riêng, ba xương tóc và bìa sách. Lửa lớn vẽ sẵn ngoài tay được xoá theo vùng; hoạ tiết lửa trên sách và áo giữ nguyên. Cầu lửa, biển lửa và sao băng làm thành lớp VFX.',
 'selka':'Dùng 1a_clean.png đã bỏ khói vẽ sẵn, giữ bản gốc. Gậy, xích và lư hương chuyển động riêng; tay áo có xương. Skill/ultimate đặt VFX lên đồng minh; vòng khói hồng-xanh và hoa hương.',
 'vael':'Dùng 1a_clean.png đã bỏ sương và bài bay, giữ quạt bài trong tay. Mũ và ba đoạn áo choàng có xương. Rèm, đèn sân khấu và bài bay thuộc VFX, không dính vào sprite.',
 'wisp':'Trôi lơ lửng, năm xương đuôi khói và hai xương tóc; sprite map trôi cả thân, không chạy bằng đuôi. Thổi gió, khói quên lãng và biểu tượng giảm tốc/giảm tấn công ở VFX.',
 'echo':'Dùng 1a_clean.png đã bỏ bản sao vẽ sẵn. Bóng được ghép ở 40% độ mờ, trễ hai khung và nhập lại khi victory. Tuyệt kỹ giữ cả thân lẫn bóng ở hai khung cuối. Technique map biến mất từ khung 3.',
 'traveler_male':'Concept mới: áo xanh đêm, kiếm dài, bốn xương vạt áo và hai xương mái tóc. Hai bản tuyệt kỹ: tập trung / lan hai bên. Tỷ lệ concept thanh hơn các chibi trước: cần bạn duyệt ở B2.',
 'traveler_female':'Concept mới: áo đỏ mận, tóc đuôi ngựa, cùng thiết kế kiếm và bộ skill của Kael. Có bản tuyệt kỹ tập trung / lan hai bên. Tỷ lệ concept thanh hơn các chibi trước: cần bạn duyệt ở B2.',
}
COMMON='Bản nháp 2D để duyệt. Chỉ hướng phải cho map. Mặt giữ từ concept, chưa tách hình dán để nhắm mắt/mở miệng trong trận. Down hiện khuỵu/gục; victory dùng cử chỉ gần ý brief, chưa đủ mọi thao tác cất vũ khí/tháo mặt nạ. Ánh sáng nhịp thở ở ngực/tóc chưa có lớp riêng cho idle. B2 cũ vẫn giữ trạng thái của bạn.'

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
 validation=json.loads((ROOT/'_reports/remaining_cast/validation.json').read_text())
 assert validation['ok'],validation['errors']
 rows=[];table=[]
 for ident in CAST:
  folder=ROOT/'nhan_vat'/ident;prefix='nhan_vat/'+ident
  if ident.startswith('traveler'):
   rows.append(f'| {ident} | B2 phác thảo | v1 | [Sketch]({prefix}/2_sketch/{ident}_sketch_v1.png) · [Krita]({prefix}/2_sketch/{ident}_sketch_v1.kra) | chờ duyệt | Concept mới; lớp your_sketch trống để vẽ sửa. Tỷ lệ thanh hơn mẫu chibi cũ, cần bạn duyệt. |')
   src=(folder/'ANIMATION_SPEC.md').read_text()
   prompts={name:re.findall(r'```text\n(.*?)```',part,re.S) for name,part in re.findall(r'### (1[a-e]).*?\n(.*?)(?=\n### |\n## Bước 2)',src,re.S)}
   meta={'tool':'image_gen built-in','date':'2026-10-15','reference':'1a_battle.png for remaining views','brief_prompts':prompts,'notes':'Lời gọi bổ sung ràng buộc bố cục, nền trắng và giữ nhân vật. Pixel 1d là lưới vẽ tay từ 4_rig2d/map_base.txt, không phải ảnh AI thu nhỏ. Hai skin dùng chung ảnh thiết kế kiếm.', 'files':{p.name:digest(p) for p in sorted((folder/'1_concept').glob('*.png'))}}
   (folder/'1_concept/PROMPTS.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2))
  if ident in ('echo','selka','vael'):
   (folder/'1_concept/CLEAN_SOURCE.json').write_text(json.dumps({'tool':'image_gen built-in','date':'2026-10-15','input':'1a_battle.png','output':'1a_clean.png','edit':NOTES[ident],'input_sha256':digest(folder/'1_concept/1a_battle.png'),'output_sha256':digest(folder/'1_concept/1a_clean.png')},ensure_ascii=False,indent=2))
  rows.append(f'| {ident} | B4 sprite trận (xương 2D) | v1 | [ảnh tổng]({prefix}/5_render/preview/battle_all.png) · [idle]({prefix}/5_render/preview/battle_idle.gif) · [attack]({prefix}/5_render/preview/battle_attack.gif) | chờ duyệt | {NOTES[ident]} Mặt chưa nhắm mắt; down khuỵu/gục. |')
  rows.append(f'| {ident} | B4 sprite map (pixel) | v1 | [run]({prefix}/5_render/preview/map_run.gif) · [technique]({prefix}/5_render/preview/map_technique.gif) | chờ duyệt | Lưới 32×32 vẽ tay, ≤12 màu, viền #141018, chỉ hướng e; có khoảng trống cho chuyển động. Sửa 4_rig2d/map_base.txt rồi chạy pixel_map.py. |')
  for action,name in zip(['attack','skill','ultimate','opener','technique'],SKILLS[ident]):
   hit={'attack':'4','skill':'6','ultimate':'8','opener':'2','technique':'–'}[action]
   notes=f'Trúng khung {hit}. '+('Pixel 64×64, ≤6 màu.' if action in ('opener','technique') else 'Cast + hit; tuyệt kỹ thêm cutin và screen. Xem VFX_NOTES.md để biết giới hạn bản nháp.')
   if ident=='fenna' and action=='technique':notes+=' Có trap_waiting.png và trap_sprung.png (16×16), GIF trap_states.gif.'
   rows.append(f'| {ident} | B5 skill {action} – {name} | v1 | [GIF]({prefix}/6_vfx/{action}/preview_{action}.gif) · [ảnh tổng]({prefix}/6_vfx/{action}/preview_{action}.png) | chờ duyệt | {notes} |')
  if ident.startswith('traveler'):
   rows.append(f'| {ident} | B5 skill ultimate_blast – Tâm Nhãn Khai Mở (lan) | v1 | [GIF]({prefix}/6_vfx/ultimate_blast/preview_ultimate_blast.gif) | chờ duyệt | Bản lan: thêm hai đường chém ở mép khung hit; dùng cùng hoạt ảnh ultimate. Trúng khung 8. |')
  (folder/'VFX_NOTES.md').write_text('# '+NAMES[ident]+' – bản nháp hoạt ảnh v1\n\n'+NOTES[ident]+'\n\n'+COMMON+'\n\nNguồn yêu cầu đầy đủ: [ANIMATION_SPEC.md](ANIMATION_SPEC.md). Các PNG 1a_clean là bản dẫn xuất; không ghi đè 1a gốc.\n\nChạy từ gốc repo:\n\n```bash\nblender -b -noaudio -t 2 -P design/nhan_vat/'+ident+'/4_rig2d/rig_battle.py\nblender -b -noaudio -t 2 -P design/nhan_vat/'+ident+'/4_rig2d/pixel_map.py\nblender -b -noaudio -t 2 -P design/nhan_vat/'+ident+'/6_vfx/make_'+ident+'_vfx.py\n```\n\nRender lại sprite trước VFX để GIF ghép đúng bản. Không chép vào assets/.\n')
  table.append(f'| {NAMES[ident]} | [idle]({prefix}/5_render/preview/battle_idle.gif) · [attack]({prefix}/5_render/preview/battle_attack.gif) · [tổng]({prefix}/5_render/preview/battle_all.png) | [run]({prefix}/5_render/preview/map_run.gif) | [Tuyệt kỹ]({prefix}/6_vfx/ultimate/preview_ultimate.gif) |')
 review=ROOT/'REVIEW.md';existing=review.read_text();added=[]
 for row in rows:
  cells=row.split('|');key='|'+cells[1]+'|'+cells[2]+'|'+cells[3]+'|'
  if key not in existing:added.append(row)
 if added:review.write_text(existing.rstrip()+'\n\n'+'\n'.join(added)+'\n')
 counts=validation['counts']
 body='# Nhân vật còn lại – bản nháp v1, 15/10/2026\n\nĐã bổ sung B4/B5 cho 11 nhân vật/skin còn thiếu. Tất cả bản mới ở trạng thái **chờ duyệt**. [Bảng duyệt đầy đủ](REVIEW.md).\n\n![Tổng quan](\u005freports/remaining_cast/cast_overview.png)\n\n[GIF idle cả nhóm](_reports/remaining_cast/cast_idle.gif)\n\n| Nhân vật | Trong trận | Pixel map | Hiệu ứng |\n| --- | --- | --- | --- |\n'+'\n'.join(table)+'\n\n## File Krita mới\n\n- [Kael](nhan_vat/traveler_male/2_sketch/traveler_male_sketch_v1.kra) · [ảnh xem](nhan_vat/traveler_male/2_sketch/traveler_male_sketch_v1.png)\n- [Kaela](nhan_vat/traveler_female/2_sketch/traveler_female_sketch_v1.kra) · [ảnh xem](nhan_vat/traveler_female/2_sketch/traveler_female_sketch_v1.png)\n\nHai file 3840×2160, RGBA U8, có lớp trống your_sketch; đã mở và lưu bằng Krita 6.0.4. Giữ bản .ora làm nguồn dựng lại.\n\n## Kiểm tra\n\n'+f"{counts['battle_frames']} khung trận 512×512; {counts['map_frames']} khung map 32×32; {counts['skills']} bản kỹ năng (gồm hai bản tuyệt kỹ lan); {counts['vfx_frames']} khung VFX/cutin. "+'Đã kiểm tra số khung, fps, hit_frame, PNG RGBA8, màu map ≤12, màu VFX pixel ≤6, hai khung cuối tuyệt kỹ và file xem thử. [Chi tiết kiểm tra](_reports/remaining_cast/validation.json).\n\n'+COMMON+'\n\nMọi thay đổi của đợt này nằm trong design/. Không đưa bản nháp vào game.\n\n## Chạy lại\n\n```bash\npython3 design/_tools/render_remaining_cast.py\nblender -b -P design/_tools/validate_remaining_cast.py\nblender -b -P design/_tools/cast_review_artifacts.py -- --overview\n```\n\nLog và thời gian từng bước trong `_reports/remaining_cast/*_results.json` và các file `.log`. Trên máy này, một nhân vật thường mất khoảng 2–3 giây cho map, 40–100 giây cho rig trận và 35–50 giây cho VFX (hai worker cùng chạy).\n'
 (ROOT/'REMAINING_CHARACTERS.md').write_text(body)
 print('Added',len(added),'review rows; generated remaining-character index.')
if __name__=='__main__':main()
