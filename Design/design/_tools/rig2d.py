"""Lõi dựng sprite trận bằng xương 2D: biến dạng ảnh concept 1a_battle.png theo xương có trọng số mềm
(giống cắt mảnh / lưới Live2D). Mỗi nhân vật chỉ khai báo xương + tư thế trong 4_rig2d/rig_battle.py rồi gọi run().

Khai báo (dict CONFIG):
    id        "mira"
    kind      "nhan_vat" (mặc định) hoặc "quai"
    bones     {tên: {"parent", "pivot": (x, y), "zone": [(ax, ay, bx, by, r), ...], "prio", "depth"}}
              toạ độ theo ảnh 1a gốc; cha khai báo trước con; zone rỗng + prio 0 = xương chỉ dùng cho lớp trên.
    top       [(xương, [zone...]), ...] lớp trên trọng số cứng (tay, vũ khí đè lên người); lớp sau đè lớp trước.
              Lớp nền dưới chúng được tô lấp.
    fill_under [xương lớp trên] tô lấp cả phần lớp đó chìa ra ngoài hình (mặc định để trống), ví dụ kính trên mũ
              kéo xuống mắt thì chỗ cũ thành mũ chứ không thành lỗ.
    erase     [zone...] vùng xoá khỏi ảnh (hiệu ứng vẽ sẵn trong concept); keep: [zone...] vùng giữ lại trong đó.
    clones    [(xương, [zone...]), ...] chép điểm ảnh trong zone thành lớp trên mới gắn vào xương (ảnh gốc giữ nguyên),
              ví dụ thanh kiếm thứ hai cho tay kia; ẩn bằng sx/sy ≈ 0 ở tư thế không dùng.
    strict_pockets  N: nền lọt chỉ là vùng trắng tuyệt đối (≥ 0.995) bị bao kín, rộng ≥ N px (tóc/áo trắng không bao
              giờ trắng tới mức đó); dùng thay white_holes khi nhân vật có tóc hoặc áo trắng tinh.
    poses     {action: hàm(i, n) -> {xương: {"rot", "dx", "dy", "sx", "sy"}}}
    pose_filter  hàm(pose) -> pose (tuỳ chọn, ví dụ tách "arms" thành tay + vũ khí)
    actions, hit_frames, loops (mặc định theo 00_CHUNG.md mục 6); soft (độ mềm mép vùng, px ảnh gốc)
    char_h (cao nhân vật trong khung, mặc định 400), frame (512), feet ((256, 430)), face_left (quái: lật ngang)

Chạy (từ gốc repo):  blender -b -P design/<kind>/<id>/4_rig2d/rig_battle.py [-- --only idle,attack]
Xuất: 5_render/battle_<id>.png + .json, 5_render/preview/battle_<action>.gif/.png, battle_all.png,
      4_rig2d/weights.png (vùng ảnh hưởng, để kiểm tra), 4_rig2d/grid.png (ảnh 1a có lưới toạ độ 50 px).
"""

import json
import math
from pathlib import Path
import sys

import bpy
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_gif import write_gif  # noqa: E402

DESIGN = Path(__file__).resolve().parents[1]
FPS = 12
SS = 2  # vẽ ×2 rồi thu nhỏ để mịn mép
ACTIONS = {"idle": 6, "attack": 8, "skill": 10, "ultimate": 12, "hit": 4, "down": 6, "victory": 8}
HIT_FRAMES = {"attack": 4, "skill": 6, "ultimate": 8}
LOOPS = ["idle", "victory"]


# ------------------------------------------------------------------ ảnh

def load_rgba(path):
    img = bpy.data.images.load(str(path), check_existing=False)
    w, h = img.size
    a = np.array(img.pixels[:], dtype=np.float32).reshape(h, w, 4)[::-1].copy()
    bpy.data.images.remove(img)
    return a


def save_png(path, rgba):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    h, w = rgba.shape[:2]
    img = bpy.data.images.new(path.stem, w, h, alpha=True)
    img.pixels.foreach_set(np.ascontiguousarray(rgba[::-1], dtype=np.float32).ravel())
    img.filepath_raw = str(path)
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)


def neighbours(m):
    g = m.copy()
    g[1:] |= m[:-1]
    g[:-1] |= m[1:]
    g[:, 1:] |= m[:, :-1]
    g[:, :-1] |= m[:, 1:]
    return g


def cutout(a, white_holes=0):
    """Bỏ nền trắng nối với mép ảnh (loang), giữ phần trắng của áo.

    white_holes > 0: bỏ thêm các vùng trắng tinh bị bao kín (nền lọt giữa lá, tóc…) rộng từ white_holes px trở lên.
    """
    white = a[..., :3].min(axis=2) > 0.9
    bg = np.zeros_like(white)
    bg[0, :] = bg[-1, :] = bg[:, 0] = bg[:, -1] = True
    bg &= white
    while True:
        grown = neighbours(bg) & white
        if (grown == bg).all():
            break
        bg = grown
    if white_holes:
        pure = (a[..., :3].min(axis=2) > 0.96) & ~bg
        bg |= _components(pure, white_holes)
    edge = neighbours(bg) & ~bg
    soft = np.clip((1.0 - a[..., :3].min(axis=2)) / 0.25, 0, 1)
    a[..., 3] = np.where(bg, 0.0, np.where(edge, soft, 1.0))
    return a


def strict_pockets(a, min_px, grow=4):
    """Đánh dấu nền lọt cho cutout(white_holes): vùng trắng tuyệt đối (≥ 0.995) bị bao kín, loang thêm tới nét viền,
    tô trắng tinh; mọi điểm trắng khác (≥ 0.96: tóc, áo) hạ xuống 0.95 để white_holes không khoét."""
    a = a.copy()
    mn = a[..., :3].min(axis=2)
    strict = mn > 0.995
    bg = np.zeros_like(strict)
    bg[0, :] = bg[-1, :] = bg[:, 0] = bg[:, -1] = True
    bg &= strict
    while True:
        grown = neighbours(bg) & strict
        if (grown == bg).all():
            break
        bg = grown
    pocket = _components(strict & ~bg, min_px)
    for _ in range(grow):
        pocket = neighbours(pocket) & (mn > 0.97) | pocket
    a[~pocket & ~bg & (mn > 0.96), :3] = 0.95
    a[pocket, :3] = 1.0
    return a


def _components(mask, min_px):
    """Các vùng liên thông của mask có ít nhất min_px điểm."""
    label = np.zeros(mask.shape, np.int32)
    out = np.zeros(mask.shape, bool)
    cur = 0
    for y0, x0 in zip(*np.nonzero(mask)):
        if label[y0, x0]:
            continue
        cur += 1
        stack, pts = [(y0, x0)], []
        label[y0, x0] = cur
        while stack:
            y, x = stack.pop()
            pts.append((y, x))
            for yy, xx in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                if 0 <= yy < mask.shape[0] and 0 <= xx < mask.shape[1] and mask[yy, xx] and not label[yy, xx]:
                    label[yy, xx] = cur
                    stack.append((yy, xx))
        if len(pts) >= min_px:
            ys, xs = zip(*pts)
            out[list(ys), list(xs)] = True
    return out


def inpaint(a, hole, iters=400):
    """Tô lấp vùng bị lớp trên che bằng cách loang dần màu từ mép vào (đủ dùng ở cỡ sprite)."""
    known = (a[..., 3] > 0.5) & ~hole
    hole = hole & (a[..., 3] > 0.02)
    ys, xs = np.nonzero(hole)
    if not len(ys):
        return a
    y0, y1, x0, x1 = max(0, ys.min() - 2), ys.max() + 3, max(0, xs.min() - 2), xs.max() + 3
    sub, kn, ho = a[y0:y1, x0:x1].copy(), known[y0:y1, x0:x1].copy(), hole[y0:y1, x0:x1].copy()
    for _ in range(iters):
        if not ho.any():
            break
        acc = np.zeros(sub.shape, np.float32)
        n = np.zeros(sub.shape[:2], np.float32)
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1)):
            acc += np.roll(np.roll(sub * kn[..., None], dy, 0), dx, 1)
            n += np.roll(np.roll(kn, dy, 0), dx, 1)
        new = ho & (n > 0)
        sub[new] = acc[new] / n[new][:, None]
        sub[new, 3] = 1.0
        kn |= new
        ho &= ~new
    a[y0:y1, x0:x1] = sub
    return a


def fill_holes(img, filled, close=5):
    """Lấp lỗ nhỏ bên trong hình do kéo giãn: đóng hình (giãn rồi co) rồi tô từ điểm kề."""
    m = filled.copy()
    for _ in range(close):
        m = neighbours(m)
    for _ in range(close):
        m = ~neighbours(~m)
    holes = m & ~filled
    known = filled.copy()
    for _ in range(close * 2):
        if not holes.any():
            break
        acc = np.zeros(img.shape, np.float32)
        n = np.zeros(img.shape[:2], np.float32)
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            sh = np.roll(np.roll(img, dy, 0), dx, 1)
            k = np.roll(np.roll(known, dy, 0), dx, 1)
            acc += sh * k[..., None]
            n += k
        new = holes & (n > 0)
        img[new] = acc[new] / n[new][:, None]
        known |= new
        holes &= ~new
    return img


def seg_dist(X, Y, ax, ay, bx, by):
    px, py, vx, vy = X - ax, Y - ay, bx - ax, by - ay
    h = np.clip((px * vx + py * vy) / (vx * vx + vy * vy + 1e-6), 0, 1)
    return np.hypot(px - vx * h, py - vy * h)


def zone_mask(shape, zones):
    H, W = shape
    gy, gx = np.mgrid[0:H, 0:W].astype(np.float32)
    m = np.zeros((H, W), bool)
    for ax, ay, bx, by, r in zones:
        x0, x1 = int(max(0, min(ax, bx) - r - 1)), int(min(W, max(ax, bx) + r + 2))
        y0, y1 = int(max(0, min(ay, by) - r - 1)), int(min(H, max(ay, by) + r + 2))
        m[y0:y1, x0:x1] |= seg_dist(gx[y0:y1, x0:x1], gy[y0:y1, x0:x1], ax, ay, bx, by) <= r
    return m


def grid_image(a, path, step=50):
    """Ảnh 1a có lưới toạ độ (đỏ đậm mỗi 100 px) để đặt pivot và vùng xương."""
    g = a.copy()
    rgb = g[..., :3] * g[..., 3:4] + (1 - g[..., 3:4])
    g[..., :3], g[..., 3] = rgb, 1
    for x in range(0, g.shape[1], step):
        g[:, x:x + (2 if x % 100 == 0 else 1), :3] = (1, 0, 0) if x % 100 == 0 else (1, .7, .7)
    for y in range(0, g.shape[0], step):
        g[y:y + (2 if y % 100 == 0 else 1), :, :3] = (0, 0, 1) if y % 100 == 0 else (.7, .7, 1)
    save_png(path, g)


# ------------------------------------------------------------------ xương

def mat(rot=0.0, dx=0.0, dy=0.0, sx=1.0, sy=1.0, pivot=(0, 0)):
    """Biến đổi quanh pivot: scale → xoay (độ, dương = theo chiều kim đồng hồ trên màn hình) → dời."""
    px, py = pivot
    c, s = math.cos(math.radians(rot)), math.sin(math.radians(rot))
    to = np.array([[1, 0, -px], [0, 1, -py], [0, 0, 1]], float)
    sc = np.array([[sx, 0, 0], [0, sy, 0], [0, 0, 1]], float)
    ro = np.array([[c, -s, 0], [s, c, 0], [0, 0, 1]], float)
    back = np.array([[1, 0, px + dx], [0, 1, py + dy], [0, 0, 1]], float)
    return back @ ro @ sc @ to


def bone_weights(bones, X, Y, soft):
    names = list(bones)
    raw = []
    for n in names:
        b = bones[n]
        if not b["zone"]:
            raw.append(np.full(X.shape, b["prio"], np.float32))
            continue
        d = None
        for ax, ay, bx, by, r in b["zone"]:
            s = seg_dist(X, Y, ax, ay, bx, by) - r
            d = s if d is None else np.minimum(d, s)
        raw.append((np.exp(-np.maximum(d, 0) ** 2 / (2 * soft ** 2)) * b["prio"]).astype(np.float32))
    W = np.stack(raw, axis=1)
    W /= W.sum(axis=1, keepdims=True)
    return names, W


class Rig:
    def __init__(self, cfg, folder):
        self.cfg = cfg
        self.bones = cfg["bones"]
        self.frame = cfg.get("frame", 512)
        self.feet = cfg.get("feet", (self.frame // 2, round(self.frame * 0.84)))
        a = load_rgba(folder / "1_concept" / cfg.get("concept", "1a_battle.png"))
        if cfg.get("strict_pockets"):
            a = strict_pockets(a, cfg["strict_pockets"])
        a = cutout(a, 30 if cfg.get("strict_pockets") else cfg.get("white_holes", 0))
        kill = np.zeros(a.shape[:2], bool)
        if cfg.get("erase"):
            kill |= zone_mask(a.shape[:2], cfg["erase"]) & ~zone_mask(a.shape[:2], cfg.get("keep", []))
        if cfg.get("shadow_below"):  # bóng đổ xám nhạt dưới chân trong concept
            rgb = a[..., :3]
            gray = (rgb.min(axis=2) > 0.62) & (rgb.max(axis=2) - rgb.min(axis=2) < 0.12)
            gray[:cfg["shadow_below"]] = False
            kill |= gray
        if kill.any():
            a[kill, 3] = 0
            a = drop_specks(a, kill)
        self.src = a
        ys, xs = np.nonzero(a[..., 3] > 0.02)
        self.top, self.bottom = ys.min(), ys.max()
        self.scale = cfg.get("char_h", 400) / (self.bottom - self.top + 1)
        self.foot_x = float(cfg.get("foot_x") or np.mean(xs[ys > self.bottom - 40]))
        # lớp trên trọng số cứng
        owner = np.full(a.shape[:2], -1, np.int32)
        names = list(self.bones)
        for bone, zones in cfg.get("top", []):
            owner[zone_mask(a.shape[:2], zones) & (a[..., 3] > 0.02)] = names.index(bone)
        top_m = owner >= 0
        base = a
        if top_m.any():
            # Chỉ tô lấp chỗ lớp trên che lên người (trong hình dáng cơ thể đã đóng kín);
            # phần lớp trên chìa ra ngoài nền (gậy giơ lên trời…) để trống, không vẽ ra "bóng" thứ hai.
            body = (a[..., 3] > 0.02) & ~top_m
            closed = body.copy()
            for _ in range(cfg.get("close", 30)):
                closed = neighbours(closed)
            for _ in range(cfg.get("close", 30)):
                closed = ~neighbours(~closed)
            under = np.zeros_like(top_m)
            for bone in cfg.get("fill_under", []):
                under |= owner == names.index(bone)
            base = inpaint(a.copy(), neighbours(neighbours(top_m)) & (closed | neighbours(neighbours(under))))
            base[top_m & ~closed & ~under, 3] = 0
        ys, xs = np.nonzero(base[..., 3] > 0.02)
        bx, by = xs.astype(np.float32), ys.astype(np.float32)
        names, Wb = bone_weights(self.bones, bx, by, cfg.get("soft", 22.0))
        ty, tx = np.nonzero(top_m)
        tb = owner[ty, tx]
        tcol = a[ty, tx]
        for bone, zones in cfg.get("clones", []):  # bản sao điểm ảnh (vũ khí thứ hai…), ảnh gốc giữ nguyên
            cy, cx = np.nonzero(zone_mask(a.shape[:2], zones) & (a[..., 3] > 0.02))
            ty, tx = np.concatenate([ty, cy]), np.concatenate([tx, cx])
            tb = np.concatenate([tb, np.full(len(cx), names.index(bone))])
            tcol = np.concatenate([tcol, a[cy, cx]])
        Wt = np.zeros((len(tx), len(names)), np.float32)
        Wt[np.arange(len(tx)), tb] = 1
        self.names = names
        self.X = np.concatenate([bx, tx.astype(np.float32)])
        self.Y = np.concatenate([by, ty.astype(np.float32)])
        self.col = np.concatenate([base[ys, xs], tcol])   # RGBA không premultiplied
        self.W = np.concatenate([Wb, Wt])
        depths = np.array([self.bones[n]["depth"] for n in names], np.float32)
        self.depth = np.concatenate([Wb @ depths, 10.0 + Wt @ depths * 0.01])
        self.n_base = len(bx)

    def world_mats(self, pose):
        if self.cfg.get("pose_filter"):
            pose = self.cfg["pose_filter"](pose)
        out = {}
        for name, b in self.bones.items():  # thứ tự khai báo: cha luôn đứng trước con
            local = mat(pivot=b["pivot"], **pose.get(name, {}))
            out[name] = local if b["parent"] is None else out[b["parent"]] @ local
        return out

    def render(self, pose):
        M = self.world_mats(pose)
        P = np.stack([self.X, self.Y, np.ones_like(self.X)], axis=0)
        x = np.zeros_like(self.X)
        y = np.zeros_like(self.Y)
        for k, n in enumerate(self.names):
            q = M[n] @ P
            x += self.W[:, k] * q[0]
            y += self.W[:, k] * q[1]
        # ảnh gốc → khung (×SS): chân giữa ở feet
        F = self.frame
        s = self.scale * SS
        ox = (x - self.foot_x) * s + self.feet[0] * SS
        oy = (y - self.bottom) * s + self.feet[1] * SS
        size = F * SS
        ix, iy = np.floor(ox).astype(np.int64), np.floor(oy).astype(np.int64)
        ok = (ix >= 0) & (ix < size) & (iy >= 0) & (iy < size)
        idx = iy[ok] * size + ix[ok]
        dep = self.depth[ok]
        col = self.col[ok]
        # điểm nào bị nhiều lớp đè: giữ lớp trước nhất
        top = np.full(size * size, -1.0, np.float32)
        np.maximum.at(top, idx, dep)
        keep = dep >= top[idx] - 0.35
        idx, col = idx[keep], col[keep]
        a = col[:, 3]
        acc = np.zeros((size * size, 4), np.float32)
        for c in range(3):
            acc[:, c] = np.bincount(idx, weights=col[:, c] * a, minlength=size * size)
        acc[:, 3] = np.bincount(idx, weights=a, minlength=size * size)
        cnt = np.bincount(idx, minlength=size * size).astype(np.float32)
        img = np.zeros((size * size, 4), np.float32)
        m = cnt > 0
        img[m, :3] = acc[m, :3] / np.maximum(acc[m, 3:4], 1e-6)
        img[m, 3] = acc[m, 3] / cnt[m]
        img = img.reshape(size, size, 4)
        img = fill_holes(img, cnt.reshape(size, size) > 0)
        pm = img.copy()
        pm[..., :3] *= pm[..., 3:4]
        pm = pm.reshape(F, SS, F, SS, 4).mean(axis=(1, 3))
        out = pm.copy()
        out[..., :3] = np.where(pm[..., 3:4] > 1e-4, pm[..., :3] / np.maximum(pm[..., 3:4], 1e-4), 0)
        out = np.clip(out, 0, 1)
        return out[:, ::-1].copy() if self.cfg.get("face_left") else out


def drop_specks(a, killed, reach=60):
    """Sau khi xoá: bỏ mọi mẩu không nối với thân chính nằm trong khoảng `reach` px quanh vùng vừa xoá
    (tàn lửa vụn, viền sót…). Thân chính = vùng liền mạch chứa điểm giữa đáy (chân)."""
    solid = a[..., 3] > 0.02
    ys, xs = np.nonzero(solid)
    bottom = ys.max()
    feet = np.nonzero(solid[bottom - 3])[0]
    main = np.zeros_like(solid)
    main[bottom - 3, feet] = True
    while True:  # loang theo điểm liền kề (vector hoá, kiểm tra hội tụ mỗi 25 bước)
        before = main.sum()
        for _ in range(25):
            main = neighbours(main) & solid
        if main.sum() == before:
            break
    near = killed.copy()
    for _ in range(reach):
        near = neighbours(near)
    a[solid & ~main & near, 3] = 0
    return a


# ------------------------------------------------------------------ tư thế

def lerp_keys(keys, t):
    """keys: [(khung, {xương: {kênh: giá trị}}), ...] → tư thế nội suy (ease in-out) tại khung t."""
    keys = sorted(keys, key=lambda k: k[0])
    if t <= keys[0][0]:
        return keys[0][1]
    for (t0, p0), (t1, p1) in zip(keys, keys[1:]):
        if t0 <= t <= t1:
            u = (t - t0) / max(t1 - t0, 1e-6)
            u = u * u * (3 - 2 * u)
            out = {}
            for bone in set(p0) | set(p1):
                a, b = p0.get(bone, {}), p1.get(bone, {})
                ch = {}
                for k in set(a) | set(b):
                    base = 1.0 if k in ("sx", "sy") else 0.0
                    ch[k] = a.get(k, base) + (b.get(k, base) - a.get(k, base)) * u
                out[bone] = ch
            return out
    return keys[-1][1]


def add(pose, extra):
    """Cộng thêm chuyển động phụ (xoay/dời cộng, co giãn nhân)."""
    out = {b: dict(v) for b, v in pose.items()}
    for b, ch in extra.items():
        cur = out.setdefault(b, {})
        for k, v in ch.items():
            if k in ("sx", "sy"):
                cur[k] = cur.get(k, 1.0) * v
            else:
                cur[k] = cur.get(k, 0.0) + v
    return out


# ------------------------------------------------------------------ xuất

def weights_preview(rig, path):
    rnd = np.random.default_rng(3)
    colors = rnd.uniform(0.2, 1.0, (len(rig.names), 3)).astype(np.float32)
    colors[0] = 0.3
    h, w = rig.src.shape[:2]
    out = np.zeros((h, w, 4), np.float32)
    mix = rig.W @ colors
    xi, yi = rig.X.astype(int), rig.Y.astype(int)
    out[yi, xi, :3] = mix * 0.6 + rig.col[:, :3] * 0.4
    top = np.arange(len(xi)) >= rig.n_base
    out[yi[top], xi[top], :3] = rig.col[top, :3] * 0.5 + np.array([1, 0.1, 0.1]) * 0.5
    out[yi, xi, 3] = 1
    for n in rig.names:
        px, py = (int(v) for v in rig.bones[n]["pivot"])
        out[max(0, py - 6):py + 6, max(0, px - 6):px + 6] = (0, 0, 0, 1)
    save_png(path, out)


def run(cfg):
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    only = set(argv[argv.index("--only") + 1].split(",")) if "--only" in argv else None
    ident = cfg["id"]
    folder = DESIGN / cfg.get("kind", "nhan_vat") / cfg.get("folder", ident)
    actions = cfg.get("actions", ACTIONS)
    hit_frames = cfg.get("hit_frames", HIT_FRAMES)
    rig = Rig(cfg, folder)
    grid_image(rig.src, folder / "4_rig2d" / "grid.png")
    weights_preview(rig, folder / "4_rig2d" / "weights.png")
    F = rig.frame
    out = folder / "5_render"
    prev = out / "preview"
    rendered = {}
    for action, n in actions.items():
        if only and action not in only:
            continue
        frames = [rig.render(cfg["poses"][action](i, n)) for i in range(n)]
        rendered[action] = frames
        gif = []
        for f in frames:
            bg = np.zeros((F, F, 4), np.float32)
            bg[..., :3] = f[..., :3] * f[..., 3:4] + np.array([0.17, 0.18, 0.23]) * (1 - f[..., 3:4])
            bg[..., 3] = 1
            gif.append(np.clip(bg[::2, ::2] * 255 + 0.5, 0, 255).astype(np.uint8))
        write_gif(prev / f"battle_{action}.gif", gif, FPS)
        save_png(prev / f"battle_{action}.png", np.concatenate(gif, axis=1).astype(np.float32) / 255)
        print(f"[{ident} rig] {action}: {n} khung")
    if only:
        return
    cols = max(actions.values())
    sheet = np.zeros((F * len(actions), F * cols, 4), np.float32)
    meta = {"asset_id": ident, "mode": "battle", "frame_size": [F, F],
            "anchor": [rig.feet[0] / F, round(rig.feet[1] / F, 4)], "fps": FPS,
            "source": f"design/{cfg.get('kind', 'nhan_vat')}/{cfg.get('folder', ident)}/4_rig2d/rig_battle.py "
                      f"(xương 2D trên {cfg.get('concept', '1a_battle.png')})",
            "loop": cfg.get("loops", LOOPS), "hit_frame": hit_frames, "frames": []}
    for r, (action, frames) in enumerate(rendered.items()):
        for i, f in enumerate(frames):
            sheet[r * F:(r + 1) * F, i * F:(i + 1) * F] = f
            entry = {"action": action, "dir": "", "index": i, "x": i * F, "y": r * F}
            if hit_frames.get(action) == i:
                entry["hit"] = True
            meta["frames"].append(entry)
    save_png(out / f"battle_{ident}.png", sheet)
    (out / f"battle_{ident}.json").write_text(json.dumps(meta, ensure_ascii=False, indent=1), encoding="utf-8")
    small = sheet.reshape(sheet.shape[0] // 4, 4, sheet.shape[1] // 4, 4, 4).mean(axis=(1, 3))
    bg = np.zeros_like(small)
    bg[..., :3] = (0.17, 0.18, 0.23)
    bg[..., 3] = 1
    a = small[..., 3:4]
    bg[..., :3] = np.where(a > 0, small[..., :3] / np.maximum(a, 1e-4), 0) * a + bg[..., :3] * (1 - a)
    bg[::F // 4, :, :3] = 0.4
    bg[:, ::F // 4, :3] = 0.4
    save_png(prev / "battle_all.png", bg)
    print(f"[{ident} rig] sheet {sheet.shape[1]}×{sheet.shape[0]} → {out / f'battle_{ident}.png'}")


def locate(cfg, queries):
    """Toạ độ trong khung sprite của các điểm trên ảnh gốc, để đặt điểm neo hiệu ứng.

    queries: [(action, khung, xương, (x, y) trên ảnh 1a), ...] → [(x, y) trong khung 512, ...]
    """
    folder = DESIGN / cfg.get("kind", "nhan_vat") / cfg.get("folder", cfg["id"])
    rig = Rig(cfg, folder)
    out = []
    actions = cfg.get("actions", ACTIONS)
    for action, i, bone, (px, py) in queries:
        M = rig.world_mats(cfg["poses"][action](i, actions[action]))[bone]
        x, y, _ = M @ np.array([px, py, 1.0])
        fx = (x - rig.foot_x) * rig.scale + rig.feet[0]
        fy = (y - rig.bottom) * rig.scale + rig.feet[1]
        if cfg.get("face_left"):
            fx = rig.frame - fx
        out.append((round(float(fx)), round(float(fy))))
    return out
