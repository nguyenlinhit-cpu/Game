"""Character-specific additions to the shared 32px pixel animation curves."""
import math
import numpy as np
from pixel2d import default_frames, shift, outline, strip_outline, speed_lines


def character_frames(p, cfg):
    ident = cfg['id']
    seq = default_frames(p, cfg)
    if ident == 'wisp':
        # Ghosts float as one body; never run on the tail as though it were feet.
        for name, n in [('idle', 4), ('run', 6), ('dash', 3), ('opener', 5), ('technique', 6)]:
            frames = []
            for i in range(n):
                f = shift(p.base, round(-1 - math.sin(math.tau * i / n)), 0)
                if name in ('run', 'dash'):
                    # Soft tail sway, without breaking the head/body connection.
                    tail = f[25:].copy()
                    f[25:] = shift(tail, 0, round(math.sin(math.tau * i / n)))
                frames.append(outline(f))
            seq[name] = frames
    if ident == 'pip':
        # Detach Bolt from the head group so that it bobs independently.
        yy, xx = np.indices((32, 32))
        def robot_mask(f):
            colors = [cfg['keys'][key] for key in ('W', 'E', 'L')]
            colored = np.zeros((32, 32), bool)
            for value in colors:
                rgb = np.array([int(value[k:k+2], 16) / 255 for k in (1, 3, 5)])
                colored |= np.abs(f[..., :3] - rgb).sum(axis=2) < .04
            return colored & (xx < 10) & (yy >= 11) & (yy < 21) & (f[..., 3] > .5)
        robot = p.base.copy()
        robot[~robot_mask(robot)] = 0
        for name, frames in seq.items():
            for i, old in enumerate(frames):
                f = strip_outline(old)
                f[robot_mask(f)] = 0
                dx = (0, 2, 6, 3, 0)[i] if name == 'opener' else round(math.sin(i * 1.2))
                rob = shift(robot, -int(i % 3 == 1), dx)
                m = rob[..., 3] > .5
                f[m] = rob[m]
                frames[i] = outline(f)
    if ident in ('fenna', 'selka'):
        # Kneel to place a trap; incense uses a soft bow instead.
        seq['technique'] = [p.compose(head=(0, d), body=(0, d), lean=1 if d else 0)
                            for d in (0, 1, 2, 2, 1, 0)]
    if ident in ('kestrel', 'traveler_male', 'traveler_female'):
        seq['technique'] = [p.compose(lean=l, head=(dx, dy), body=(dx, dy), flaps=-1)
                            for l, dx, dy in [(0, 0, 0), (1, 1, -1), (2, 2, -1),
                                              (2, 3, -1), (1, 2, -1), (0, 0, 0)]]
        for i in range(1, 5):
            speed_lines(seq['technique'][i], cfg['spark'])
            if ident.startswith('traveler'):
                # Pixel checker fade uses no extra palette colors.
                yy, xx = np.indices((32, 32))
                seq['technique'][i][(yy + xx + i) % 2 == 0, 3] = 0
    if ident == 'neris':
        # The two blue lenses slide down from the forehead to the eyes.
        for i, f in enumerate(seq['technique']):
            if i >= 2:
                col = np.array([int(cfg['keys']['E'][k:k+2], 16) / 255 for k in (1, 3, 5)])
                f[12:14, 19:23, :3] = col
                f[12:14, 19:23, 3] = 1
    if ident == 'echo':
        for i, f in enumerate(seq['technique']):
            if i >= 3:
                f[..., 3] = 0  # Step into mirror, then disappear.
    return seq
