"""Run inside Krita Python to rebuild Garren's layered concept review board."""
from pathlib import Path
from PyQt6.QtGui import QImage, QPainter, QColor, QFont
from PyQt6.QtCore import Qt, QByteArray

W, H = 3840, 2160
root = Path('/home/linh/Game/Design/design/nhan_vat/garren')
board = krita.createDocument(W, H, 'Garren sketch v1', 'RGBA', 'U8', '', 120)
krita.activeWindow().addView(board)

def add(name, draw):
    image = QImage(W, H, QImage.Format.Format_ARGB32)
    image.fill(Qt.GlobalColor.transparent)
    painter = QPainter(image)
    painter.setRenderHint(QPainter.RenderHint.Antialiasing)
    draw(painter)
    painter.end()
    node = board.createNode(name, 'paintlayer')
    board.rootNode().addChildNode(node, None)
    node.setPixelData(QByteArray(image.bits().asstring(image.sizeInBytes())), 0, 0, W, H)
    return node

add('background', lambda p: p.fillRect(0, 0, W, H, QColor('#F7FAFD')))

def notes(p):
    p.setPen(QColor('#26354C'))
    def text(x, y, t, size=34):
        p.setFont(QFont('DejaVu Sans', size))
        p.drawText(x, y, t)
    text(100, 120, 'GARREN  |  4★  |  Mộc  |  Bảo Hộ', 48)
    text(100, 220, 'Concept trong trận', 30)
    text(1350, 220, 'Mặt trước · A-pose', 30)
    text(2580, 220, 'Mặt sau · A-pose', 30)
    text(100, 1720, 'Khiên gỗ và chùy đồng', 24)
    text(550, 1720, 'Pixel tham khảo', 26)
    text(1120, 1895, 'Nghiêm, ít nói, che chở; thỉnh thoảng kể chuyện cũ.', 23)
    text(1120, 1950, 'Nhận diện: vai giáp mọc cành lá, khiên tròn lớn bằng nửa người.', 23)
    text(1120, 2005, 'Kiểm tra: tỷ lệ 2,5 đầu, đường kính khiên, tay cầm chùy.', 23)
    text(1120, 2060, 'Giữ khối giáp gỗ / đồng rõ; cành lá nhất quán giữa các góc.', 23)
    text(1120, 2115, 'Pixel chỉ tham khảo · Vẽ đè trên your_sketch · Chờ duyệt B2.', 23)
add('notes', notes)

colors = [('Tóc, râu','#B8B8B0'),('Da','#E2B08E'),('Giáp gỗ','#7A5232'),('Đồng','#B8803A'),('Áo ngoài','#2E8B57'),('Lá','#6CC36A'),('Mắt','#3F8F4F')]
def palette(p):
    p.setFont(QFont('DejaVu Sans',22))
    for i,(name,color) in enumerate(colors):
        x = 1120 + (i % 4) * 660
        y = 1660 + (i // 4) * 100
        p.fillRect(x,y,64,64,QColor(color))
        p.setPen(QColor('#26354C'))
        p.drawText(x+80,y+43,name+': '+color)
add('palette',palette)

art = [('concept_battle','1a_battle.png',100,260,1145,1374),('concept_front','1b_front.png',1350,260,1144,1375),('concept_back','1b_back.png',2580,260,1144,1375),('weapon','1c_weapon.png',100,1750,345,410),('map_pixel','1d_pixel.png',550,1750,340,340)]
for name,file,x,y,w,h in art:
    img = QImage(str(root/'1_concept'/file))
    if img.isNull():
        raise RuntimeError('Missing image: '+file)
    mode = Qt.TransformationMode.FastTransformation if name=='map_pixel' else Qt.TransformationMode.SmoothTransformation
    img = img.scaled(w,h,Qt.AspectRatioMode.KeepAspectRatio,mode)
    xx = x + (w-img.width())//2
    yy = y + (h-img.height())//2
    add(name,lambda p,img=img,xx=xx,yy=yy:p.drawImage(xx,yy,img))

top = board.createNode('your_sketch','paintlayer')
board.rootNode().addChildNode(top,None)
board.setActiveNode(top)
board.refreshProjection()
result = {'layers':[n.name() for n in board.rootNode().childNodes()],'size':[W,H]}
