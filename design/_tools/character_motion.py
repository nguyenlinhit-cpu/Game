"""Reusable keyframe curves for the remaining cast; geometry stays in each rig.

All distances are source-image pixels. These are review drafts, not game imports.
"""
import math
from rig2d import lerp_keys


def poses_for(style, extras=()):
    def idle(i, n):
        t = math.tau * i / n
        p = {'chest': {'sy': 1 + .012 * math.sin(t)},
             'head': {'rot': 1.2 * math.sin(t + .4)}}
        if style == 'ghost':
            p['root'] = {'dy': -20 - 16 * math.sin(t)}
        if style == 'dual':
            p['root'] = {'dy': -9 * (1 - math.cos(t))}
            p['weapon'] = {'rot': 6 * math.sin(t)}
            p['weapon_l'] = {'rot': -6 * math.sin(t)}
        if style == 'robot':
            p['robot'] = {'dx': 18 * math.sin(t), 'dy': -18 * math.cos(t)}
            p['robot_eye'] = {'dx': 4 * math.sin(t)}
        for k, name in enumerate(extras):
            p[name] = {'rot': (3 if 'ear' in name else 2) * math.sin(t - k * .6)}
        return p

    def active(action, i, n):
        if action == 'ultimate':
            i = min(i, n - 2)  # Hold the full pose, including hair and cloth, for two frames.
        hit = {'attack': 4, 'skill': 6, 'ultimate': 8}[action]
        power = {'attack': 1, 'skill': 1.25, 'ultimate': 1.6}[action]
        wind = {'chest': {'rot': -5}, 'head': {'rot': -3}, 'hips': {'dx': -20}}
        strike = {'chest': {'rot': 7}, 'hips': {'dx': 45}, 'arm_r': {'rot': -10}}
        end = {}
        if style == 'bow':
            wind.update(arm_l={'dx': -48 * power, 'rot': -5}, weapon={'rot': -4 if action == 'attack' else -24})
            strike.update(arm_l={'dx': 8}, weapon={'rot': -1 if action == 'attack' else -16})
            if action == 'ultimate':
                wind['root'] = {'sy': .96}
                end = {'root': {'sy': .96}, 'weapon': {'rot': -3}}
        elif style == 'spear':
            wind.update(weapon={'dx': -65, 'rot': -5 if action == 'attack' else -22})
            strike.update(weapon={'dx': 125 * power, 'rot': 18}, arm_l={'dx': 30})
            if action == 'ultimate':
                wind['root'] = {'dy': 65, 'sy': .9}
                strike['root'] = {'dy': -85}
                end = {'weapon': {'rot': -10}, 'root': {'sy': .95}}
        elif style in ('dual', 'sword'):
            wind['weapon'] = {'rot': -38, 'dx': -15}
            strike['weapon'] = {'rot': 65 * power}
            if style == 'dual':
                wind['weapon_l'] = {'rot': 42}
                strike['weapon_l'] = {'rot': -70 * power}
            if action == 'ultimate':
                wind['root'] = {'dy': -95}
                strike['root'] = {'dy': -35}
                end = {'root': {'sy': .9}, 'head': {'rot': 5}}
        elif style == 'robot':
            wind.update(weapon={'rot': -12}, robot={'dy': -35, 'dx': 30})
            strike.update(weapon={'rot': 7}, robot={'dx': 200, 'dy': -40})
            if action == 'ultimate':
                wind['arm_l'] = {'rot': -35}
                strike['robot'] = {'dx': 430, 'dy': 40, 'sx': 3, 'sy': 3}
                end = {'root': {'sy': .87}, 'head': {'rot': -5}}
        elif style == 'incense':
            wind.update(weapon={'rot': -12}, arm_l={'rot': -15})
            strike.update(weapon={'rot': 12 * power}, censer={'rot': -20 * power})
            end = {'head': {'rot': 4}, 'arm_l': {'rot': -8}}
        elif style == 'cards':
            wind.update(arm_l={'rot': 12}, hat={'dy': -45 if action != 'attack' else 0})
            strike.update(arm_l={'rot': -20}, hat={'dy': -70 if action == 'skill' else 0})
            if action == 'ultimate':
                strike.update(chest={'rot': 16}, head={'rot': 10}, arm_r={'rot': 12})
                end = {'arm_l': {'rot': -20}, 'arm_r': {'rot': 8}}
        elif style == 'book':
            wind.update(weapon={'rot': -10, 'dy': -20}, arm_r={'rot': -10})
            strike.update(weapon={'rot': 7}, arm_r={'rot': 16})
            if action == 'ultimate':
                wind['weapon'] = {'dy': -80, 'rot': -18}
                strike['weapon'] = {'dy': -60, 'rot': -12}
                end = {'chest': {'rot': 8}, 'head': {'rot': 9}}
        else:  # mirror / whisper
            wind.update(arm_r={'rot': -6}, chest={'sy': 1.025})
            strike.update(arm_r={'rot': 8 * power}, weapon={'rot': 6 * power})
            if style == 'ghost':
                wind['root'] = {'dy': -40}
                strike['root'] = {'dy': -20}
                end = {'root': {'dy': -20}}
        p = lerp_keys([(0, {}), (hit - 2, wind), (hit, strike), (hit + 1, strike), (n - 1, end)], i)
        if action == 'ultimate' and i >= n - 2:
            p = end
        for k, name in enumerate(extras):
            transform = p.setdefault(name, {})
            transform['rot'] = transform.get('rot', 0) + 4 * math.sin(i * .65 - k * .5)
        return p

    def hit(i, n):
        return lerp_keys([(0, {'chest': {'rot': -8}, 'head': {'rot': -8}, 'hips': {'dx': -25}}),
                          (1, {'chest': {'rot': -12}, 'head': {'rot': -10}, 'hips': {'dx': -35}}), (n - 1, {})], i)

    def down(i, n):
        end = {'root': {'sy': .72}, 'hips': {'dy': 80}, 'chest': {'rot': 18}, 'head': {'rot': 20}}
        if style == 'ghost':
            end = {'root': {'sy': .65, 'dy': 25}, 'head': {'rot': 15}}
        return lerp_keys([(0, {}), (n - 2, end), (n - 1, end)], i)

    def victory(i, n):
        t = math.tau * i / n
        p = idle(i, n)
        p['head'] = {'rot': 4 * math.sin(t)}
        if style == 'cards':
            p.update(chest={'rot': 9 * (1 - math.cos(t))}, hat={'dy': -55 * (1 - math.cos(t))})
        elif style == 'robot':
            p.update(robot={'dx': 110 * (1 - math.cos(t)), 'dy': -20}, arm_l={'rot': -28 * (1 - math.cos(t))})
        elif style == 'dual':
            p.update(weapon={'rot': 35 * math.sin(t)}, weapon_l={'rot': -35 * math.sin(t)})
        elif style == 'incense':
            p['chest'] = {'rot': 5 * (1 - math.cos(t))}
        elif style == 'book':
            p['arm_r'] = {'rot': -16 * (1 - math.cos(t))}
        else:
            p['arm_l'] = {'rot': -8 * math.sin(t)}
        return p

    return {'idle': idle, 'attack': lambda i, n: active('attack', i, n),
            'skill': lambda i, n: active('skill', i, n), 'ultimate': lambda i, n: active('ultimate', i, n),
            'hit': hit, 'down': down, 'victory': victory}


def run_echo(config):
    """Render the delayed 40% shadow behind Echo without changing the shared rig."""
    import rig2d
    import numpy as np
    from vfx2d import over
    original_class = rig2d.Rig
    original_poses = config['poses'].copy()

    class EchoRig(original_class):
        def render(self, pose):
            action, i, n = pose['_action'], pose['_index'], pose['_count']
            if action == 'ultimate':
                i = min(i, n - 2)
            current = super().render(pose)
            lag = (i - 2) % n if action in ('idle', 'victory') else max(0, i - 2)
            old = super().render(original_poses[action](lag, n))
            old[..., :3] = old[..., :3] * .5 + np.array([.45, .37, .67]) * .5
            alpha = .4 * (1 - i / (n - 1)) if action == 'victory' else .4
            out = np.zeros_like(current)
            over(out, old, -65, -5, alpha)
            over(out, current, 0, 0)
            return out

    for action, fn in original_poses.items():
        config['poses'][action] = lambda i, n, a=action, f=fn: dict(f(i, n), _action=a, _index=i, _count=n)
    rig2d.Rig = EchoRig
    try:
        rig2d.run(config)
    finally:
        rig2d.Rig = original_class
        config['poses'] = original_poses
