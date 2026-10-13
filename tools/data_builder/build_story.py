#!/usr/bin/env python3
"""Sinh dữ liệu cốt truyện Phase 12 (mục 3, 4):
- data/dialogue/<id>.json   (mỗi cảnh hội thoại một file: người nói, biểu cảm, câu thoại, lựa chọn, sự kiện)
- data/story/story.json      (người nói, khu, NPC, điểm kích hoạt, nhiệm vụ chính / phụ, móc sau trận boss)
- localization/story.csv     (chữ; cột tiếng Anh tạm dùng lại tiếng Việt như roster)
Chạy: python3 tools/data_builder/build_story.py   (từ thư mục dự án). Ghi đè file cũ.

Câu thoại viết "{player}" để chèn tên nhân vật chính lúc chạy.
"""
import csv, json, os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
os.chdir(ROOT)

TEXT = {}
DIALOGUES = {}


def text(key, vi, en=None):
    if key in TEXT and TEXT[key][0] != vi:
        raise SystemExit("Trùng khóa dịch %s" % key)
    TEXT[key] = (vi, en or vi)
    return key


# ---------------- DSL viết hội thoại ----------------
# S(người nói, biểu cảm, câu) · N(câu dẫn) · C([(câu chọn, nhãn), ...]) · L(nhãn) gắn cho câu sau ·
# J(nhãn) nhảy sau câu trước · E(sự kiện...) gắn vào câu trước · END() kết thúc sau câu trước.

class S:
    def __init__(self, speaker, expression, line):
        self.speaker, self.expression, self.line = speaker, expression, line


def N(line):
    return S("narrator", "neutral", line)


class C:
    def __init__(self, options):
        self.options = options


class L:
    def __init__(self, label):
        self.label = label


class J:
    def __init__(self, label):
        self.label = label


class E:
    def __init__(self, *events):
        self.events = list(events)


class END:
    pass


def flag(name):
    return {"type": "set_flag", "flag": name}


def join(char_id):
    return {"type": "give_character", "id": char_id}


def shard(n):
    return {"type": "set_flag", "flag": "soul_shard_%d" % n}


def D(did, items):
    key_base = "DLG_" + did.upper()
    lines = []
    pending_label = None
    n = 0
    for item in items:
        if isinstance(item, L):
            pending_label = item.label
        elif isinstance(item, J):
            lines[-1]["goto"] = item.label
        elif isinstance(item, E):
            lines[-1].setdefault("events", []).extend(item.events)
        elif isinstance(item, END):
            lines[-1]["end"] = True
        elif isinstance(item, C):
            choices = []
            for i, option in enumerate(item.options):
                choice = {"text": text("%s_C%d_%d" % (key_base, n, i + 1), option[0])}
                if option[1]:
                    choice["goto"] = option[1]
                else:
                    choice["end"] = True
                if len(option) > 2:
                    choice["events"] = option[2]
                choices.append(choice)
            lines[-1]["choices"] = choices
        else:
            n += 1
            line = {"speaker": item.speaker, "expression": item.expression,
                    "text": text("%s_%02d" % (key_base, n), item.line)}
            if pending_label:
                line["label"] = pending_label
                pending_label = None
            lines.append(line)
    labels = {l.get("label") for l in lines}
    for l in lines:
        for target in [l.get("goto")] + [c.get("goto") for c in l.get("choices", [])]:
            if target and target not in labels:
                raise SystemExit("%s: nhãn '%s' không tồn tại" % (did, target))
    DIALOGUES[did] = {"id": did, "lines": lines}


# ======================= MỞ ĐẦU – SẢNH TRUNG TÂM =======================

D("p0_wake", [
    N("Bóng tối. Rồi một nhịp đập – không phải của tim, mà của thứ gì đó sáng rực nằm trong lồng ngực."),
    S("traveler", "surprised", "…Ánh sáng này… là gì vậy?"),
    S("mira", "worried", "Cậu tỉnh rồi! Đừng ngồi dậy vội, vết thương Ma Biến trên vai cậu vừa mới khép lại thôi."),
    S("mira", "smile", "Mình là Mira, thực tập sinh dược sĩ ở trạm y tế này. Mình tìm thấy cậu nằm bất tỉnh dưới bể sao hai ngày trước."),
    C([("Đây là đâu?", "where"), ("Tôi… không nhớ gì cả.", "who")]),
    L("where"), S("mira", "neutral", "Pháo Đài Vọng Tinh – trạm quan sát sao trôi giữa hư vô. Đây là Sảnh Trung Tâm, nơi duy nhất Ma Biến chưa tràn vào."),
    J("after"),
    L("who"), S("mira", "worried", "Không nhớ gì sao? Nhưng cậu nhớ tên mình chứ? …{player}. Ừm, ít ra vẫn còn cái tên."),
    L("after"), S("mira", "serious", "Từ đêm Tâm Thần Nhãn vỡ, Ma Biến biến sách, máy móc, cả băng tuyết thành quái vật. Mọi người kẹt lại khắp pháo đài."),
    S("mira", "surprised", "Khoan… ngực cậu đang phát sáng. Đó là… một Mảnh Hồn? Mảnh vỡ của chính Tâm Thần Nhãn?"),
    S("traveler", "neutral", "Nó đập như một trái tim thứ hai."),
    S("mira", "worried", "Ông Orwen phải biết chuyện này. Nhưng trước tiên – có tiếng động ở Sân Tập phía Đông. Lại một con Mầm Ma Biến lọt vào rồi."),
    S("mira", "smile", "Mình đi cùng cậu. Mình không giỏi đánh nhau, nhưng nước tinh lọc của mình chữa được vết thương Ma Biến!"),
    E(join("mira"), flag("prologue_awake")),
    N("Mira gia nhập đội. Dùng phím di chuyển để đi, Shift để lướt. Đi về phía Đông tới Sân Tập."),
])

D("p0_training", [
    S("mira", "worried", "Kia rồi! Mầm Ma Biến – nhỏ nhưng nổ được đấy."),
    S("mira", "serious", "Nghe này: chém trúng nó trước bằng Đòn Mở Màn (phím J hoặc chuột trái) thì mình sẽ ra tay trước trong trận."),
    S("mira", "neutral", "Còn nếu để nó vồ trúng, nó sẽ tấn công trước. Cẩn thận nhé, {player}!"),
    E(flag("training_seen")),
])

D("p0_after_battle", [
    S("mira", "surprised", "Cậu… chém một nhát mà ánh sáng trong ngực bùng lên như sao băng. Đó là nguyên tố Hồn sao?"),
    S("traveler", "neutral", "Tôi không biết. Cơ thể tôi tự cử động."),
    S("mira", "smile", "Trong trận, cậu dùng Đánh thường để tích Điểm Chiến Kỹ, rồi tiêu nó cho Chiến kỹ. Khi đủ năng lượng thì tung Tuyệt kỹ bất cứ lúc nào!"),
    S("mira", "neutral", "Đánh đúng điểm yếu nguyên tố sẽ phá khiên quái, làm nó chậm lại. Nhớ nhìn biểu tượng dưới thanh máu của nó."),
    S("mira", "serious", "Giờ đi gặp ông Orwen ở bàn chỉ huy giữa sảnh. Ông ấy là người giữ sảnh – và biết về Tâm Thần Nhãn nhiều hơn ai hết."),
    E(flag("prologue_done")),
])

D("p0_orwen", [
    S("orwen", "serious", "Vậy ra cậu là người mang Mảnh Hồn trong tim. Ta đã nghe tiếng nó đập từ tận bên kia sảnh."),
    S("orwen", "neutral", "Ta là Orwen, người giữ sảnh, kẻ ngắm sao già nhất còn sót lại ở pháo đài này."),
    S("orwen", "sad", "Đêm Tâm Thần Nhãn vỡ, sức mạnh của chính nó hóa thành nguyên tố thứ bảy – Hồn. Chỉ người có Mảnh Hồn hòa vào thân mới dùng được."),
    S("orwen", "serious", "Mỗi Mảnh Hồn cậu thu hồi sẽ trả lại một đoạn ký ức. Có lẽ cũng trả lại cho Aethelgard một chút ánh sáng."),
    C([("Tôi phải bắt đầu từ đâu?", "start"), ("Tại sao lại là tôi?", "why")]),
    L("why"), S("orwen", "smile", "Vì Mảnh Hồn đã chọn cậu. Thứ ánh sáng ấy không chui vào trái tim của kẻ bỏ chạy."),
    L("start"), S("orwen", "neutral", "Sơ đồ pháo đài nằm trong Thư Viện Câm Lặng. Không có nó, chúng ta mù giữa các tầng bị xé vụn."),
    S("orwen", "serious", "Cổng Dịch Chuyển ở phòng phía Tây sẽ đưa cậu tới đó. Trên đường, mỗi phòng nghỉ có tinh thể sao – chạm vào để hồi sức, lưu lại và dịch chuyển nhanh."),
    S("mira", "worried", "Thư Viện… đêm đó có người vào tìm sách rồi không thấy ra nữa."),
    S("orwen", "neutral", "Vậy thì càng phải đi. Bàn Ước Nguyện, bảng nhiệm vụ và bàn nâng cấp trong sảnh sẽ sẵn sàng khi cậu cần."),
    E(flag("ch1_briefed"), flag("zone_library_open")),
])

D("p0_orwen_idle", [
    S("orwen", "smile", "Sao trên vòm trời vẫn chưa sáng lại hết. Đi đi, {player}, ta sẽ giữ sảnh này cho tới khi cậu trở về."),
])

# ======================= CHƯƠNG 1 – THƯ VIỆN CÂM LẶNG =======================

D("c1_entry", [
    N("Thư Viện Câm Lặng. Hàng vạn cuốn sách trôi lơ lửng, trang giấy lật mà không gây một tiếng động."),
    S("mira", "worried", "Lạnh sống lưng quá… Ở đây đến tiếng bước chân cũng bị nuốt mất."),
    S("traveler", "serious", "Có tiếng gì đó. Phía trước – như pháo nổ."),
    S("mira", "surprised", "Pháo nổ? Trong thư viện? Ai lại… À, mình đoán được là ai rồi."),
    S("mira", "neutral", "Bức tường lửa phía trước chặn đường. Nước của mình dập được – đổi mình lên dẫn đầu (phím 2) rồi chém vào nó nhé!"),
    E(flag("library_entered")),
])

D("c1_kiri_join", [
    S("kiri", "angry", "Lùi lại! Còn một bước nữa là tôi cho nổ tung cả kệ sách này đấy, lũ sách bay chết tiệt!"),
    S("mira", "surprised", "Kiri! Là cậu thật à? Cả pháo đài đang tìm cậu đấy!"),
    S("kiri", "surprised", "Mira-giọt-nước?! Ơ… thế cái người phát sáng bên cạnh cậu là ai thế?"),
    S("traveler", "neutral", "{player}. Tôi mới tỉnh dậy hôm qua."),
    S("kiri", "smile", "Ngực cậu sáng như pháo sao băng loại xịn nhất của tôi! Từ giờ tôi gọi cậu là… Đèn Lồng!"),
    C([("Đừng gọi tôi như thế.", "no"), ("…Cũng được.", "ok")]),
    L("no"), S("kiri", "smug", "Muộn rồi, Đèn Lồng. Tên đã đặt là không đổi!"),
    J("story"),
    L("ok"), S("kiri", "smile", "Thấy chưa, Mira-giọt-nước? Người này hiểu chuyện ghê!"),
    L("story"), S("kiri", "serious", "Tôi vào tìm sách công thức pháo cho lễ ngắm sao. Rồi đêm đó… sách tự bay lên, đóng sầm mọi lối ra."),
    S("kiri", "neutral", "Ánh sáng xua được Ma Biến – tôi tin chắc thế. Nên tôi đi cùng hai người. Pháo của tôi đốt được cả đống dây leo chắn lối phía Đông!"),
    E(join("kiri"), flag("kiri_joined")),
    N("Kiri gia nhập đội. Đòn Mở Màn của Kiri (Lửa) đốt được dây leo."),
])

D("c1_map_found", [
    N("Phòng đọc sâu nhất của Thư Viện. Trên bàn đá, những mảnh giấy da vẽ hình pháo đài ghép lại thành một tấm sơ đồ."),
    S("kiri", "surprised", "Sơ đồ pháo đài! Ê, nó vẽ cả Kho Chứa, Lò Năng Lượng, Đỉnh Tháp nữa này!"),
    S("mira", "worried", "Có chỗ bị cào rách… như thể ai đó đã cố xé đi đường lên Đỉnh Tháp."),
    S("traveler", "serious", "Sau cánh cửa kia có thứ gì đó đang canh. Tôi nghe tiếng giấy sột soạt."),
    S("kiri", "smile", "Thì ta cho nó một tràng pháo chào mừng! Nhớ ghé tinh thể sao nghỉ một chút đã nhé, Đèn Lồng."),
    E(flag("library_map_found")),
])

D("c1_boss_pre", [
    N("Giữa phòng, một bóng người khoác áo choàng bằng giấy đứng bất động. Hàng trăm cuốn sách xoay quanh nó như vệ tinh."),
    S("narrator", "neutral", "\"…Im lặng. Thư viện… phải… im lặng.\""),
    S("mira", "worried", "Đó từng là người gác thư viện… Ma Biến đã nuốt cả ông ấy."),
    S("kiri", "angry", "Thế thì ồn ào chút cho ông ấy tỉnh lại nào!"),
])

D("c1_boss_post", [
    N("Người Gác Thư Viện tan thành những trang giấy trắng. Giữa đống giấy, một Mảnh Hồn nhỏ lơ lửng, đập nhẹ như đáp lại trái tim {player}."),
    S("traveler", "surprised", "Nó… đang gọi tôi."),
    N("Mảnh Hồn hòa vào lồng ngực. Một ký ức vụt qua: bầu trời đầy sao, một bàn tay đeo găng bạc đẩy {player} ra khỏi ánh sáng đang vỡ."),
    E(shard(1)),
    N("Rồi tất cả trắng xóa. Một vầng sáng hình con mắt mở ra trên trần thư viện."),
    S("celestine", "serious", "Người mang Mảnh Hồn trong tim. Cuối cùng ta cũng tìm thấy ngươi."),
    S("traveler", "surprised", "Cô là ai?"),
    S("celestine", "neutral", "Celestine. Người Gác Nhãn cuối cùng. Ta chỉ còn là một ảo ảnh trong những mảnh vỡ của Nhãn."),
    S("celestine", "serious", "Có kẻ đang nuốt các Mảnh Hồn. Nếu nó nuốt đủ, sẽ không còn Aethelgard nào để cứu."),
    S("celestine", "neutral", "Hãy dùng Bàn Ước Nguyện ở sảnh. Lời ước của người mang Mảnh Hồn có thể gọi những linh hồn lạc lối tới bên ngươi – và gọi cả ta."),
    N("Ảo ảnh tan biến. Bàn Ước Nguyện và nhiệm vụ hằng ngày đã mở."),
    S("kiri", "surprised", "…Đèn Lồng, cậu vừa nói chuyện với không khí đấy à?"),
    S("mira", "serious", "Mình cũng thấy cô ấy. Mau về báo cho ông Orwen thôi."),
    E(flag("chapter_1_complete")),
])

# ======================= CHƯƠNG 2 – KHO CHỨA BĂNG GIÁ =======================

D("c2_orwen", [
    S("orwen", "surprised", "Celestine… Người Gác Nhãn vẫn còn đó, dù chỉ là ảo ảnh. Vậy là hy vọng chưa tắt."),
    S("orwen", "serious", "Sơ đồ cho thấy Kho Chứa Băng Giá ở tầng dưới. Đội cận vệ của Garren đã xuống đó giữ chân một con quái khổng lồ đêm Nhãn vỡ."),
    S("orwen", "sad", "Từ đó không một ai trở về."),
    S("kiri", "serious", "Ông Garren? Cái ông râu rậm hay kể chuyện chiến trận cả buổi ấy hả? Ông ấy cứng lắm, chắc chắn còn sống!"),
    S("orwen", "neutral", "Cổng Dịch Chuyển đã nhận tọa độ Kho Chứa. Mang họ về, {player}."),
    E(flag("ch2_briefed"), flag("zone_vault_open")),
])

D("c2_entry", [
    N("Kho Chứa Băng Giá. Những thùng hàng đóng băng thành từng khối, hơi thở hóa khói trắng."),
    S("mira", "worried", "Nhiệt độ ở đây… nước của mình sắp đông cứng rồi."),
    S("kiri", "smile", "Có tôi đây! Pháo sưởi miễn phí cho cả đội!"),
    S("traveler", "serious", "Có dấu chân. Rất nhiều, và tất cả đều đi vào trong."),
])

D("c2_garren_join", [
    N("Giữa phòng, một khối băng lớn giam một người đàn ông râu rậm, khiên gỗ giơ cao như vẫn đang đỡ đòn."),
    S("kiri", "serious", "Ông Garren! Mira, giúp tôi – lửa của tôi làm tan băng, nước của cậu giữ cho ông ấy khỏi bị bỏng!"),
    N("Băng nứt ra. Garren khuỵu xuống, rồi lập tức đứng dậy, khiên đã chắn trước cả đội."),
    S("garren", "angry", "Lùi lại! Cự Thú vẫn còn… Hửm? Các cháu là ai?"),
    S("mira", "smile", "Là tụi cháu đây, chú Garren! Chú bị đóng băng ở đây từ đêm Nhãn vỡ đấy ạ."),
    S("garren", "serious", "Hừm. Vậy là ta đã ngủ quên trong ca trực. Năm mươi năm cầm khiên, lần đầu tiên đấy."),
    S("garren", "neutral", "Còn cậu – cái ánh sáng trong ngực kia. Ta từng thấy nó một lần, trên ngực Người Gác Nhãn."),
    C([("Ông biết về Celestine?", "celes"), ("Đội cận vệ của ông đâu?", "guards")]),
    L("celes"), S("garren", "sad", "Ta từng đứng gác dưới chân cô ấy suốt ba mươi năm. Chuyện đó để sau – giờ còn lính của ta."),
    L("guards"), S("garren", "serious", "Lính của ta bị lũ quái lôi vào sâu bên trong, gần hang Cự Thú."),
    S("garren", "neutral", "Từ giờ cậu là lính mới của ta, {player}. Ta đi trước, cậu theo sau. Khiên của ta mọc rễ, bắc cầu qua khe vực được."),
    E(join("garren"), flag("garren_joined")),
    N("Garren gia nhập đội. Đội đã đủ 4 người. Đòn Mở Màn của Garren (Mộc) bắc cầu qua khe vực."),
])

D("c2_boss_pre", [
    N("Hang băng rung chuyển. Từ lớp băng dày, một con thú khổng lồ chui ra, lưng mọc đầy thùng hàng đóng băng."),
    S("garren", "angry", "Lại là mày! Lần trước tao chưa kịp nói hết câu chào hỏi."),
    S("kiri", "surprised", "Nó to gấp mười lần cái kho này luôn ấy!"),
    S("garren", "serious", "Đứng sau khiên của ta. Lính mới, đánh vào chỗ băng nứt!"),
])

D("c2_boss_post", [
    N("Cự Thú gục xuống, lớp băng trên lưng vỡ vụn. Bên trong, đội cận vệ còn sống – lạnh cóng nhưng còn thở."),
    S("garren", "smile", "…Đủ cả. Không thiếu một ai. Hừm. Giỏi lắm, lính mới."),
    N("Một Mảnh Hồn trồi lên từ tim băng của Cự Thú và hòa vào ngực {player}."),
    N("Ký ức thứ hai: một căn phòng trên cao, bản đồ sao trải khắp tường. {player} đang tranh cãi với ai đó về một vết nứt trên bầu trời."),
    E(shard(2)),
    S("traveler", "serious", "Tôi từng ở Đỉnh Tháp. Tôi đã biết trước vết nứt sẽ mở ra."),
    S("mira", "worried", "Vậy cậu là… người của đài quan sát sao?"),
    S("garren", "neutral", "Chuyện ký ức để sau. Đưa lính của ta về sảnh trước đã."),
    E(flag("chapter_2_complete")),
])

# ======================= CHƯƠNG 3 – LÒ NĂNG LƯỢNG =======================

D("c3_orwen", [
    S("orwen", "smile", "Garren, lão già cứng đầu, ông vẫn còn sống!"),
    S("garren", "smug", "Ông cũng chưa chết, Orwen. Ta coi như hòa."),
    S("orwen", "serious", "Nhưng tin xấu: Lò Năng Lượng đang tắt dần. Không có lò, Sảnh Trung Tâm sẽ mất kết giới trong vài ngày nữa."),
    S("orwen", "neutral", "Người trực lò là một kỹ sư trẻ tên Nyx. Tín hiệu từ ống dẫn vẫn còn nhấp nháy – có thể cô bé còn sống."),
    S("kiri", "smile", "Nyx? Cái cô hay cau mày với mọi người ấy hả? Tôi thích cô ấy!"),
    E(flag("ch3_briefed"), flag("zone_furnace_open")),
])

D("c3_entry", [
    N("Lò Năng Lượng. Ống dẫn chằng chịt như mạch máu, lửa Ma Biến chập chờn màu tím."),
    S("garren", "serious", "Nóng như lò rèn. Áo giáp của ta bắt đầu rụng lá rồi."),
    S("traveler", "neutral", "Có tiếng gõ trong ống dẫn. Ba nhịp ngắn, ba nhịp dài."),
    S("mira", "surprised", "Là tín hiệu cầu cứu! Ai đó trong ống!"),
])

D("c3_nyx_join", [
    N("Một tấm lưới ống dẫn bật ra. Một cô gái đeo kính bảo hộ trượt xuống, găng tay còn tóe tia điện."),
    S("nyx", "angry", "Mất bốn ngày. Bốn ngày gõ tín hiệu. Các người đi bộ từ bên kia vũ trụ tới à?"),
    S("kiri", "smile", "Nyx! Tụi mình tới cứu cậu đây, nhóc!"),
    S("nyx", "angry", "Gọi ai là nhóc? Tôi biết mọi đường dây trong pháo đài này. Còn cậu biết mỗi châm ngòi."),
    S("nyx", "serious", "Nghe đây. Lò không tự hỏng. Có kẻ đã moi Mảnh Hồn ra khỏi lõi – tôi ghi lại được."),
    N("Nyx bật một màn chiếu nhỏ: một bóng người mờ ảo, cái miệng mở rộng như vết nứt, hút một mảnh sáng vào trong."),
    S("garren", "angry", "Thứ đó… ta đã thấy nó ở rìa Kho Chứa. Nó đứng nhìn bọn ta bị đóng băng."),
    C([("Nó đang ở đâu?", "where"), ("Cô đi cùng chúng tôi chứ?", "join")]),
    L("where"), S("nyx", "serious", "Tín hiệu của nó dẫn lên Đỉnh Tháp. Nhưng trước hết phải khởi động lại lò, nếu không cả sảnh sẽ tắt."),
    L("join"), S("nyx", "smug", "Không có tôi thì các người còn chẳng mở nổi một cánh cửa máy. Đi thôi. Và đừng có gọi tôi là nhóc."),
    E(join("nyx"), flag("nyx_joined")),
    N("Nyx gia nhập đội. Đòn Mở Màn của Nyx (Sét) mở được cửa máy. Đổi đội hình ở menu khi cần."),
])

D("c3_boss_pre", [
    N("Lõi lò khổng lồ quay chậm, hai cánh tay máy cắm sâu vào tường. Mỗi nhịp quay phả ra một luồng nhiệt tím."),
    S("nyx", "serious", "Lõi Lò đã biến dạng. Nhiệt tích đủ năm tầng là nó nổ – phá khiên để xả nhiệt ra!"),
    S("garren", "neutral", "Nghe cô bé nói chưa, lính mới."),
    S("nyx", "angry", "Đừng có—! …Thôi, đánh đi."),
])

D("c3_boss_post", [
    N("Lõi Lò rên lên rồi quay đều trở lại, ánh lửa chuyển từ tím sang vàng ấm. Khắp pháo đài, đèn bật sáng."),
    S("nyx", "smile", "…Lò chạy lại rồi. Ổn định. Hừ, cũng không tệ lắm."),
    N("Từ khe tản nhiệt, một Mảnh Hồn rơi xuống tay {player}."),
    N("Ký ức thứ ba: Đỉnh Tháp, đêm Nhãn vỡ. Một người đồng hành của {player} quỳ trước vết nứt, há miệng nuốt lấy ánh sáng đang rơi."),
    E(shard(3)),
    S("traveler", "sad", "Kẻ nuốt Mảnh Hồn… từng là bạn của tôi."),
    S("mira", "worried", "{player}…"),
    S("nyx", "serious", "Bạn hay không thì nó cũng đang ngồi trên Đỉnh Tháp, ôm cả đống Mảnh Hồn. Tôi mở được thang máy lên đó."),
    E(flag("chapter_3_complete")),
])

# ======================= CHƯƠNG 4 – ĐỈNH THÁP QUAN SÁT =======================

D("c4_orwen", [
    S("orwen", "serious", "Kẻ Nuốt Mảnh Hồn. Ta đã nghe truyền thuyết về thứ đó, nhưng không ngờ nó là người."),
    S("traveler", "neutral", "Tôi phải lên đó. Không chỉ vì Mảnh Hồn – tôi phải biết vì sao."),
    S("garren", "serious", "Cả đội đi cùng. Khiên của ta chưa bao giờ bỏ lính lại phía sau."),
    S("kiri", "smile", "Tôi để dành tràng pháo to nhất cho trận này đấy!"),
    S("orwen", "smile", "Vậy thì đi đi, những ngôi sao của ta. Cổng Dịch Chuyển đã mở đường lên Đỉnh Tháp."),
    E(flag("ch4_briefed"), flag("zone_tower_open")),
])

D("c4_entry", [
    N("Đỉnh Tháp Quan Sát. Vòm kính vỡ, bầu trời bên ngoài không có sao – chỉ có một vết nứt chạy dài như vết sẹo."),
    S("nyx", "serious", "Tín hiệu Mảnh Hồn đậm đặc ở tầng trên cùng. Nó đang chờ chúng ta."),
    S("mira", "worried", "Mọi người… hứa với mình là tất cả cùng quay về nhé."),
    S("garren", "neutral", "Hứa."),
])

D("c4_summit", [
    N("Phòng nghỉ cuối cùng trước đỉnh tháp. Tinh thể sao rung lên khi {player} lại gần."),
    S("celestine", "serious", "Người mang Mảnh Hồn. Phía trên là kẻ từng là đồng đội của ngươi."),
    S("celestine", "sad", "Hắn tin rằng nuốt hết Mảnh Hồn sẽ hàn được vết nứt. Hắn đã sai. Vết nứt chỉ đói thêm."),
    S("traveler", "serious", "Nếu tôi đánh bại hắn, tôi có cứu được hắn không?"),
    S("celestine", "neutral", "Ta không biết. Nhưng ngươi sẽ cứu được những người đứng sau lưng ngươi."),
    E(flag("tower_summit_seen")),
])

D("c4_boss_pre", [
    N("Trên đỉnh tháp, một bóng người ngồi giữa vòng tròn Mảnh Hồn trôi nổi. Miệng hắn là một vết nứt nhỏ đang mở rộng."),
    S("devourer", "smug", "{player}. Ngươi còn sống. Ta đã đẩy ngươi ra khỏi ánh sáng đêm đó – để ngươi không phải thấy cảnh này."),
    S("traveler", "angry", "Ngươi nuốt Mảnh Hồn của cả pháo đài."),
    S("devourer", "serious", "Ta giữ chúng. Để vết nứt không nuốt chúng trước. Đưa nốt Mảnh Hồn trong tim ngươi đây – rồi mọi thứ sẽ yên."),
    C([("Không bao giờ.", "no"), ("Ngươi đã sai.", "wrong")]),
    L("no"), S("devourer", "angry", "Vậy thì ta sẽ lấy nó."),
    J("end"),
    L("wrong"), S("devourer", "sad", "Có lẽ. Nhưng đã quá muộn để quay lại."),
    L("end"), S("garren", "serious", "Đội hình! Lính mới, lần này ngươi dẫn đầu."),
])

D("c4_ending", [
    N("Kẻ Nuốt Mảnh Hồn quỵ xuống. Những Mảnh Hồn hắn giữ bay lên như đàn đom đóm, rồi một mảnh sáng nhất tìm về ngực {player}."),
    E(shard(4)),
    N("Ký ức thứ tư: hai người trẻ trên Đỉnh Tháp, chỉ lên trời đặt tên cho từng vì sao. Một trong hai người là {player}."),
    S("devourer", "sad", "…Ta chỉ muốn giữ cho ánh sáng khỏi rơi mất."),
    S("traveler", "sad", "Tôi biết. Giờ để chúng tôi giữ nó."),
    N("Bóng người tan thành bụi sao. Nhưng vết nứt trên bầu trời không khép lại – nó rung lên, rồi mở toang."),
    S("nyx", "surprised", "Khoan đã… bên kia vết nứt có tín hiệu. Một vùng đất. Một vùng đất hoàn toàn mới!"),
    S("celestine", "serious", "Những Mảnh Hồn còn lại đã rơi qua đó. Hành trình của ngươi chưa kết thúc, người mang Mảnh Hồn."),
    S("kiri", "smile", "Thế thì đi thôi, Đèn Lồng! Tôi còn cả đống pháo chưa bắn!"),
    S("garren", "smile", "Lính mới… làm tốt lắm."),
    S("mira", "smile", "Lần này cũng hứa cùng quay về nhé, {player}."),
    N("Hết Chương 4. Vết nứt đã mở ra vùng đất mới – còn tiếp…"),
    E(flag("chapter_4_complete"), flag("story_complete")),
])

D("orwen_ending", [
    S("orwen", "smile", "Vết nứt mở ra một chân trời mới. Khi cậu sẵn sàng, Aethelgard sẽ chờ."),
])

# ======================= NHIỆM VỤ PHỤ =======================

D("sq1_offer", [
    S("lio", "worried", "Anh… chị {player}! Xin lỗi, em là Lio, thủ thư tập sự của ông Orwen."),
    S("lio", "sad", "Người Gác Thư Viện – thầy em – có giữ một cuốn nhật ký. Thầy giấu nó sau bức tường nứt trong phòng lưu trữ."),
    S("lio", "neutral", "Bức tường đó chỉ mở bằng ánh sáng Hồn. Anh chị mang nó về giúp em được không?"),
    S("traveler", "neutral", "Được. Tôi sẽ tìm."),
    E(flag("sq1_started")),
])

D("sq1_wait", [
    S("lio", "neutral", "Phòng lưu trữ ở phía Bắc phòng chiến đấu thứ ba trong Thư Viện. Bức tường nứt… để người dẫn đầu là anh chị mới mở được."),
])

D("sq1_item", [
    N("Sau bức tường nứt, một cuốn sổ bìa da nằm trên giá. Trang cuối viết dở: \"Nếu ai mang Mảnh Hồn đọc được dòng này…\""),
    S("traveler", "neutral", "Mang về cho Lio thôi."),
    E(flag("sq1_item")),
])

D("sq1_turnin", [
    S("lio", "sad", "Đây là chữ của thầy… \"Nếu ai mang Mảnh Hồn đọc được dòng này, hãy nhận lấy thứ ta giấu trong gáy sách.\""),
    N("Trong gáy cuốn nhật ký, một Mảnh Hồn nhỏ xíu lóe sáng rồi hòa vào ngực {player}."),
    N("Ký ức thứ năm: Người Gác Thư Viện cười hiền, đưa cho {player} một cuốn sách về các vì sao."),
    E(shard(5), flag("sq1_done")),
    S("lio", "smile", "Thầy vẫn luôn tin vào anh chị. Cảm ơn… thật nhiều."),
])

D("sq2_offer", [
    S("bram", "serious", "Này, người mang Mảnh Hồn. Bram đây, thợ máy kiêm chủ quầy hàng."),
    S("bram", "neutral", "Từ lúc lò chạy lại, máy đo của tôi bắt được một tiếng vọng lạ ở phòng tinh anh phía Nam của Lò."),
    S("bram", "smile", "Tôi đoán là một Lõi Tiếng Vọng – mảnh lõi cũ còn giữ năng lượng Hồn. Mang về đây, tôi trả công xứng đáng."),
    E(flag("sq2_started")),
])

D("sq2_wait", [
    S("bram", "neutral", "Lõi Tiếng Vọng ở phòng tinh anh, nhánh phía Nam gần cuối Lò Năng Lượng. Cẩn thận Mẫu Thể Ma Biến đấy."),
])

D("sq2_item", [
    N("Giữa đống mảnh máy vỡ, một khối lõi nhỏ ngân lên một giai điệu quen thuộc."),
    S("traveler", "surprised", "Giai điệu này… tôi từng nghe ở Đỉnh Tháp."),
    E(flag("sq2_item")),
])

D("sq2_turnin", [
    S("bram", "surprised", "Đúng là nó! Nhưng… nó đang hát theo nhịp tim của cậu kìa."),
    N("Lõi Tiếng Vọng vỡ ra, để lại một Mảnh Hồn. Mảnh Hồn hòa vào ngực {player}."),
    N("Ký ức thứ sáu: Celestine trao cho {player} một nửa ánh sáng của mình, nói \"Hãy sống, và nhớ\"."),
    E(shard(6), flag("sq2_done")),
    S("bram", "smile", "Coi như tôi trả công bằng một ký ức vậy. Quầy hàng luôn mở cho cậu."),
])

D("bram_idle", [
    S("bram", "smile", "Cần Ký Ức hay Hộp Bí Kỹ thì ghé quầy bên cạnh nhé. Giá hữu nghị!"),
])

D("lio_idle", [
    S("lio", "smile", "Em đang chép lại sơ đồ pháo đài. Anh chị đi đâu cũng cẩn thận nhé!"),
])

# ---------------- Hội thoại hệ thống ----------------
D("boss_difficulty", [
    N("Kẻ địch này đã bị đánh bại trước đây. Chọn mức độ khiêu chiến."),
    C([("Thường", None, [{"type": "result", "value": "normal"}]),
       ("Khó (thưởng nguyên liệu ×2, thêm Lõi Ma Biến)", None, [{"type": "result", "value": "hard"}]),
       ("Để sau", None, [{"type": "result", "value": "cancel"}])]),
])

# ======================= Cấu hình cốt truyện =======================

SPEAKERS = {
    "narrator": {"name": "", "color": "#c9c3e6"},
    "traveler": {"name": "{player}", "character": "traveler"},
    "mira": {"name": "Mira", "character": "mira"},
    "kiri": {"name": "Kiri", "character": "kiri"},
    "garren": {"name": "Garren", "character": "garren"},
    "nyx": {"name": "Nyx", "character": "nyx"},
    "celestine": {"name": "Celestine", "character": "celestine"},
    "orwen": {"name": text("SPEAKER_ORWEN", "Ông Orwen", "Elder Orwen"), "color": "#8fa7d9"},
    "lio": {"name": text("SPEAKER_LIO", "Lio", "Lio"), "color": "#d9b38f"},
    "bram": {"name": text("SPEAKER_BRAM", "Bram", "Bram"), "color": "#b07a4a"},
    "devourer": {"name": text("SPEAKER_DEVOURER", "Kẻ Nuốt Mảnh Hồn", "Shard Devourer"), "color": "#5a3a7a"},
}
EXPRESSIONS = {
    "neutral": ("Bình thường", "Neutral"), "smile": ("Mỉm cười", "Smiling"), "worried": ("Lo lắng", "Worried"),
    "surprised": ("Ngạc nhiên", "Surprised"), "serious": ("Nghiêm túc", "Serious"), "angry": ("Giận", "Angry"),
    "sad": ("Buồn", "Sad"), "smug": ("Đắc ý", "Smug"),
}
for exp, (vi, en) in EXPRESSIONS.items():
    text("EXPRESSION_" + exp.upper(), vi, en)

HUB = "res://scenes/overworld/world/hub.tscn"
ZONE_SCENES = {
    "hub": HUB,
    "library": "res://scenes/overworld/world/library.tscn",
    "vault": "res://scenes/overworld/world/vault.tscn",
    "furnace": "res://scenes/overworld/world/furnace.tscn",
    "tower": "res://scenes/overworld/world/tower.tscn",
}
# Khu đi tới bằng Cổng Dịch Chuyển: (id, cờ mở, phòng xuất hiện).
GATE_ZONES = [
    ("library", "zone_library_open", "L01"),
    ("vault", "zone_vault_open", "V01"),
    ("furnace", "zone_furnace_open", "F01"),
    ("tower", "zone_tower_open", "T01"),
]
text("ZONE_HUB", "Sảnh Trung Tâm", "Central Hall")

# NPC: danh sách cảnh, chọn cảnh đầu tiên thỏa điều kiện (if: mọi cờ bật, unless: mọi cờ tắt).
def opt(dialogue, if_=(), unless=()):
    return {"dialogue": dialogue, "if": list(if_), "unless": list(unless)}

NPCS = {
    "orwen": {"speaker": "orwen", "options": [
        opt("p0_orwen", ["prologue_done"], ["ch1_briefed"]),
        opt("c2_orwen", ["chapter_1_complete"], ["ch2_briefed"]),
        opt("c3_orwen", ["chapter_2_complete"], ["ch3_briefed"]),
        opt("c4_orwen", ["chapter_3_complete"], ["ch4_briefed"]),
        opt("orwen_ending", ["story_complete"]),
        opt("p0_orwen_idle"),
    ]},
    "lio": {"speaker": "lio", "options": [
        opt("sq1_offer", ["chapter_2_complete"], ["sq1_started"]),
        opt("sq1_turnin", ["sq1_item"], ["sq1_done"]),
        opt("sq1_wait", ["sq1_started"], ["sq1_done"]),
        opt("lio_idle"),
    ]},
    "bram": {"speaker": "bram", "options": [
        opt("sq2_offer", ["chapter_3_complete"], ["sq2_started"]),
        opt("sq2_turnin", ["sq2_item"], ["sq2_done"]),
        opt("sq2_wait", ["sq2_started"], ["sq2_done"]),
        opt("bram_idle"),
    ]},
    "kiri": {"speaker": "kiri", "options": [opt("c1_kiri_join", [], ["kiri_joined"])]},
    "garren": {"speaker": "garren", "options": [opt("c2_garren_join", [], ["garren_joined"])]},
    "nyx": {"speaker": "nyx", "options": [opt("c3_nyx_join", [], ["nyx_joined"])]},
}

# Điểm kích hoạt: "map" = khi nạp map (theo khu), "area" = người chơi đi vào vùng StoryTrigger có id này,
# "item" = vật cốt truyện (StoryItem) có id này. Mỗi cái chạy 1 lần nhờ cờ "unless".
TRIGGERS = {
    "hub_wake": {"kind": "map", "zone": "hub", "dialogue": "p0_wake", "if": [], "unless": ["prologue_awake"]},
    "hub_training": {"kind": "area", "dialogue": "p0_training", "if": ["prologue_awake"], "unless": ["training_seen", "prologue_done"]},
    "library_entry": {"kind": "map", "zone": "library", "dialogue": "c1_entry", "if": [], "unless": ["library_entered"]},
    "library_map": {"kind": "area", "dialogue": "c1_map_found", "if": [], "unless": ["library_map_found"]},
    "library_boss": {"kind": "area", "dialogue": "c1_boss_pre", "if": [], "unless": ["boss_library_seen", "chapter_1_complete"],
                     "set": "boss_library_seen"},
    "vault_entry": {"kind": "map", "zone": "vault", "dialogue": "c2_entry", "if": [], "unless": ["vault_entered"], "set": "vault_entered"},
    "vault_boss": {"kind": "area", "dialogue": "c2_boss_pre", "if": [], "unless": ["boss_vault_seen", "chapter_2_complete"],
                   "set": "boss_vault_seen"},
    "furnace_entry": {"kind": "map", "zone": "furnace", "dialogue": "c3_entry", "if": [], "unless": ["furnace_entered"],
                      "set": "furnace_entered"},
    "furnace_boss": {"kind": "area", "dialogue": "c3_boss_pre", "if": [], "unless": ["boss_furnace_seen", "chapter_3_complete"],
                     "set": "boss_furnace_seen"},
    "tower_entry": {"kind": "map", "zone": "tower", "dialogue": "c4_entry", "if": [], "unless": ["tower_entered"], "set": "tower_entered"},
    "tower_summit": {"kind": "area", "dialogue": "c4_summit", "if": [], "unless": ["tower_summit_seen"]},
    "tower_boss": {"kind": "area", "dialogue": "c4_boss_pre", "if": [], "unless": ["boss_tower_seen", "chapter_4_complete"],
                   "set": "boss_tower_seen"},
    "sq1_diary": {"kind": "item", "dialogue": "sq1_item", "if": ["sq1_started"], "unless": ["sq1_item"]},
    "sq2_core": {"kind": "item", "dialogue": "sq2_item", "if": ["sq2_started"], "unless": ["sq2_item"]},
}

# Thắng trận (EncounterData.id) → cờ + cảnh chạy khi quay về map (chỉ lần đầu: "unless").
BATTLE_HOOKS = {
    "prologue_tutorial": {"flag": "prologue_battle_won", "dialogue": "p0_after_battle", "unless": ["prologue_done"]},
    "library_boss_warden": {"flag": "boss_library_defeated", "dialogue": "c1_boss_post", "unless": ["chapter_1_complete"]},
    "vault_boss_behemoth": {"flag": "boss_vault_defeated", "dialogue": "c2_boss_post", "unless": ["chapter_2_complete"]},
    "furnace_boss_core": {"flag": "boss_furnace_defeated", "dialogue": "c3_boss_post", "unless": ["chapter_3_complete"]},
    "tower_boss_devourer": {"flag": "boss_tower_defeated", "dialogue": "c4_ending", "unless": ["chapter_4_complete"]},
}

# Nhiệm vụ: các bước theo thứ tự, bước hiện tại = bước đầu tiên chưa bật cờ "done".
# target: {"zone": khu, "room": id phòng, "node": tên node (tùy chọn)}.
def step(sid, title, done, zone, room, node=""):
    target = {"zone": zone, "room": room}
    if node:
        target["node"] = node
    return {"id": sid, "title": text("QUEST_MAIN_" + sid.upper(), title), "done": done, "target": target}

MAIN_QUEST = [
    step("tutorial", "Dẹp con Mầm Ma Biến ở Sân Tập", "prologue_done", "hub", "H02"),
    step("orwen1", "Gặp ông Orwen ở Sảnh Trung Tâm", "ch1_briefed", "hub", "H01", "NpcOrwen"),
    step("library", "Tới Thư Viện Câm Lặng qua Cổng Dịch Chuyển", "library_entered", "library", "L01"),
    step("kiri", "Tìm nguồn tiếng nổ trong Thư Viện", "kiri_joined", "library", "L04", "NpcKiri"),
    step("map", "Tìm sơ đồ pháo đài ở phòng đọc sâu trong Thư Viện", "library_map_found", "library", "L10"),
    step("boss1", "Hạ Người Gác Thư Viện", "chapter_1_complete", "library", "L11"),
    step("orwen2", "Về Sảnh báo tin cho ông Orwen", "ch2_briefed", "hub", "H01", "NpcOrwen"),
    step("vault", "Tới Kho Chứa Băng Giá", "vault_entered", "vault", "V01"),
    step("garren", "Tìm đội cận vệ bị đóng băng", "garren_joined", "vault", "V04", "NpcGarren"),
    step("boss2", "Hạ Cự Thú Kho Chứa", "chapter_2_complete", "vault", "V10"),
    step("orwen3", "Về Sảnh gặp ông Orwen", "ch3_briefed", "hub", "H01", "NpcOrwen"),
    step("furnace", "Tới Lò Năng Lượng", "furnace_entered", "furnace", "F01"),
    step("nyx", "Lần theo tín hiệu cầu cứu trong ống dẫn", "nyx_joined", "furnace", "F04", "NpcNyx"),
    step("boss3", "Khởi động lại lò: hạ Lõi Lò Biến Dạng", "chapter_3_complete", "furnace", "F10"),
    step("orwen4", "Về Sảnh gặp ông Orwen", "ch4_briefed", "hub", "H01", "NpcOrwen"),
    step("tower", "Tới Đỉnh Tháp Quan Sát", "tower_entered", "tower", "T01"),
    step("summit", "Leo tới phòng nghỉ cuối cùng của Đỉnh Tháp", "tower_summit_seen", "tower", "T11"),
    step("boss4", "Đối đầu Kẻ Nuốt Mảnh Hồn", "chapter_4_complete", "tower", "T12"),
]
text("QUEST_MAIN_DONE", "Hết Chương 4 – vết nứt đã mở ra vùng đất mới (còn tiếp…)", "End of Chapter 4 – the rift has opened (to be continued…)")

SIDE_QUESTS = [
    {"id": "sq1", "title": text("QUEST_SIDE_SQ1", "Nhật Ký Người Gác", "The Warden's Diary"), "unlock": "chapter_2_complete",
     "reward_key": text("QUEST_SIDE_SQ1_REWARD", "Tinh Mệnh 5 của nhân vật chính", "Protagonist Eidolon 5"),
     "steps": [
         step("sq1_talk", "Gặp Lio ở Sảnh Trung Tâm", "sq1_started", "hub", "H01", "NpcLio"),
         step("sq1_find", "Tìm nhật ký sau bức tường nứt trong Thư Viện (người dẫn đầu: nhân vật chính)", "sq1_item", "library", "L07", "StoryItemDiary"),
         step("sq1_return", "Mang nhật ký về cho Lio", "sq1_done", "hub", "H01", "NpcLio"),
     ]},
    {"id": "sq2", "title": text("QUEST_SIDE_SQ2", "Tiếng Vọng Trong Lò", "Echo in the Furnace"), "unlock": "chapter_3_complete",
     "reward_key": text("QUEST_SIDE_SQ2_REWARD", "Tinh Mệnh 6 của nhân vật chính", "Protagonist Eidolon 6"),
     "steps": [
         step("sq2_talk", "Gặp Bram ở Sảnh Trung Tâm", "sq2_started", "hub", "H01", "NpcBram"),
         step("sq2_find", "Tìm Lõi Tiếng Vọng ở phòng tinh anh của Lò Năng Lượng", "sq2_item", "furnace", "F08", "StoryItemCore"),
         step("sq2_return", "Mang Lõi Tiếng Vọng về cho Bram", "sq2_done", "hub", "H01", "NpcBram"),
     ]},
]

# Nhân vật miễn phí: nhận ở chương nào (để test và báo cáo).
FREE_CHARACTERS = {"mira": 0, "kiri": 1, "garren": 2, "nyx": 3}


def build():
    os.makedirs("data/dialogue", exist_ok=True)
    os.makedirs("data/story", exist_ok=True)
    for did, data in DIALOGUES.items():
        with open("data/dialogue/%s.json" % did, "w", encoding="utf-8") as fh:
            json.dump(data, fh, ensure_ascii=False, indent="\t")
            fh.write("\n")
    story = {
        "speakers": SPEAKERS,
        "zones": ZONE_SCENES,
        "gate_zones": [{"zone": z, "flag": f, "room": r} for z, f, r in GATE_ZONES],
        "npcs": NPCS,
        "triggers": TRIGGERS,
        "battle_hooks": BATTLE_HOOKS,
        "main_quest": MAIN_QUEST,
        "main_quest_done": "QUEST_MAIN_DONE",
        "side_quests": SIDE_QUESTS,
        "free_characters": FREE_CHARACTERS,
    }
    with open("data/story/story.json", "w", encoding="utf-8") as fh:
        json.dump(story, fh, ensure_ascii=False, indent="\t")
        fh.write("\n")
    check()
    with open("localization/story.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["keys", "vi", "en"])
        for key, (vi, en) in TEXT.items():
            w.writerow([key, vi, en])
    lines = sum(len(d["lines"]) for d in DIALOGUES.values())
    print("Xong: %d cảnh hội thoại (%d câu), %d khóa dịch." % (len(DIALOGUES), lines, len(TEXT)))


def check():
    for npc in NPCS.values():
        for o in npc["options"]:
            assert o["dialogue"] in DIALOGUES, o
    for tid, t in TRIGGERS.items():
        assert t["dialogue"] in DIALOGUES, tid
    for h in BATTLE_HOOKS.values():
        assert h["dialogue"] in DIALOGUES, h
    for d in DIALOGUES.values():
        for l in d["lines"]:
            assert l["speaker"] in SPEAKERS, (d["id"], l["speaker"])
            assert l["expression"] in EXPRESSIONS, (d["id"], l["expression"])
    # Mọi cờ "done" của nhiệm vụ phải có ai đó bật.
    set_flags = set()
    for d in DIALOGUES.values():
        for l in d["lines"]:
            for e in l.get("events", []):
                if e["type"] == "set_flag":
                    set_flags.add(e["flag"])
    for t in TRIGGERS.values():
        if "set" in t:
            set_flags.add(t["set"])
    for s in MAIN_QUEST + [s for q in SIDE_QUESTS for s in q["steps"]]:
        assert s["done"] in set_flags, s


if __name__ == "__main__":
    build()
