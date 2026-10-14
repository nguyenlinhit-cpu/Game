"""Editable SVG sprite atlases for the practice enemies omitted from the main roster.

python3 tools/import_assets/build_practice_enemies.py
The wooden training figures and stone sparring golem have distinct silhouettes.
"""
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
COUNTS = {"idle": 6, "attack": 8, "skill": 10, "hit": 4, "down": 6}


def dummy(fire, arm_angle):
    cloth = "#A94436" if fire else "#476C85"
    light = "#DB7960" if fire else "#7BA7B2"
    # Straw-filled linen head, crossbar arms, padded target and wooden trestle.
    return f'''<g stroke="#292333" stroke-width="4" stroke-linejoin="round">
      <path d="M119 151 L113 214 L91 224 L133 224 L139 158Z" fill="#795034"/>
      <path d="M116 187 L82 219 M131 187 L159 219" fill="none" stroke="#B58450" stroke-width="9"/>
      <path d="M112 71 L103 52 L114 57 L118 43 L126 57 L137 46 L139 65" fill="#D8B66C" stroke-width="2"/>
      <path d="M103 75 Q124 61 145 76 L141 103 Q124 114 106 101Z" fill="#CFAF79"/>
      <path d="M109 78 Q124 70 139 79 L137 94 Q123 101 111 94Z" fill="#E8CC96" stroke="none"/>
      <path d="M110 84 L117 88 M119 82 L112 89 M132 84 L139 88 M140 82 L133 90" stroke="#403038" stroke-width="2.5"/>
      <path d="M116 98 L135 98 M120 95 L120 102 M128 95 L128 102" stroke="#7B513B" stroke-width="2"/>
      <g transform="rotate({arm_angle:.2f} 120 117)">
        <path d="M66 120 L179 120" stroke="#795034" stroke-width="13"/>
        <path d="M71 117 L174 117" stroke="#C18A53" stroke-width="5"/>
        <path d="M67 108 L81 109 L80 133 L66 131Z M165 108 L181 108 L181 133 L167 133Z" fill="#B89967"/>
        <path d="M63 115 L56 111 M64 123 L53 124 M184 114 L194 111 M183 124 L194 127" stroke="#D8B66C" stroke-width="3"/>
      </g>
      <path d="M99 105 Q124 99 150 106 L145 163 Q124 174 102 161Z" fill="{cloth}"/>
      <path d="M105 109 L115 109 L110 154 L104 153Z" fill="{light}" stroke="none"/>
      <circle cx="126" cy="135" r="22" fill="#C2A476" stroke="#E6CFA1" stroke-width="3"/>
      <circle cx="126" cy="135" r="13" fill="{cloth}" stroke="#674C3C" stroke-width="2"/>
      <circle cx="126" cy="135" r="5" fill="#EED7A4" stroke="none"/>
      <path d="M99 157 Q125 167 147 157" fill="none" stroke="#D9BA7F" stroke-width="6"/>
      <path d="M144 157 L151 171 L141 167" fill="none" stroke="#D9BA7F" stroke-width="3"/>
    </g>'''


def golem(arm_angle):
    return f'''<g stroke="#252332" stroke-width="4" stroke-linejoin="round">
      <path d="M77 164 L101 164 L102 205 L109 218 L67 218 L72 198Z" fill="#68647B"/>
      <path d="M143 165 L169 164 L175 203 L187 220 L143 220 L139 201Z" fill="#55546B"/>
      <path d="M77 195 L97 195 L96 209 L75 209Z M148 195 L170 195 L174 210 L149 210Z" fill="#A09BAF" stroke-width="2"/>
      <path d="M86 85 L157 81 L174 123 L157 173 L96 176 L77 141Z" fill="#77718A"/>
      <path d="M86 88 L108 97 L100 145 L86 147 L82 118Z" fill="#ADA4B5" stroke="none"/>
      <path d="M112 104 L139 100 L154 126 L137 151 L109 146 L98 124Z" fill="#353346"/>
      <path d="M121 111 L137 119 L138 134 L122 143 L112 128Z" fill="#F2D58A" stroke="#AF874E" stroke-width="2"/>
      <path d="M124 115 L132 121 L124 131 L117 127Z" fill="#FFF0BD" stroke="none"/>
      <g transform="rotate({arm_angle:.2f} 84 100)">
        <path d="M59 90 L89 96 L83 130 L68 147 L44 139 L42 114Z" fill="#91889B"/>
        <path d="M43 132 L65 132 L74 159 L67 181 L41 179 L32 161Z" fill="#666178"/>
        <path d="M39 147 L61 147 M37 158 L63 158" stroke="#B5ACBA" stroke-width="3"/>
      </g>
      <g transform="rotate({-arm_angle*.7:.2f} 164 100)">
        <path d="M161 88 L186 91 L200 117 L193 142 L171 144 L157 118Z" fill="#645D76"/>
        <path d="M175 138 L197 137 L208 160 L200 183 L174 180 L165 160Z" fill="#575267"/>
        <path d="M175 153 L198 152 M177 164 L199 164" stroke="#A49BAE" stroke-width="3"/>
      </g>
      <path d="M99 48 L140 43 L157 61 L150 91 L131 103 L105 91 L92 69Z" fill="#93889C"/>
      <path d="M101 51 L114 49 L109 70 L97 68Z" fill="#C5BAC5" stroke="none"/>
      <path d="M102 69 L148 66 L143 80 L108 83Z" fill="#343143"/>
      <path d="M108 74 L121 75 M131 72 L141 71" stroke="#F2D58A" stroke-width="4"/>
      <path d="M122 49 L119 61 L126 66 M145 96 L151 112 L146 117 M94 144 L106 155 L105 169" fill="none" stroke="#D7C295" stroke-width="2"/>
    </g>'''


def write_sheet(ident, mode, fire=False, heavy=False):
    size = 256 if mode == "battle" else 32
    counts = COUNTS if mode == "battle" else {"idle": 4, "run": 6, "windup": 3}
    cols = max(counts.values())
    shapes, frames = [], []
    for row, (action, count) in enumerate(counts.items()):
        for i in range(count):
            t = i / max(count-1, 1)
            wave = math.sin(math.tau*i/count)
            dx, dy, rot, sy, arm = 0, 1.2*wave, .6*wave, 1, 2*wave
            if action in ("attack", "skill"):
                punch = math.exp(-((t-.58)/.19)**2)
                dx, rot, arm = -15*punch, -6*punch, -32*punch
            elif action == "hit":
                dx, rot = 12*(1-t), 9*(1-t)
            elif action == "down":
                sy, rot, arm = 1-.48*t, 18*t, 24*t
            elif action == "run":
                dx, dy, rot = wave, -abs(wave)*2, 2*wave
            elif action == "windup":
                sy, rot, arm = .96, 2, -6
            if mode == "battle":
                body = golem(arm) if heavy else dummy(fire, arm)
                content = f'<g transform="translate({dx:.2f} {dy:.2f}) translate(128 220) rotate({rot:.2f}) scale(1 {sy:.3f}) translate(-128 -220)">{body}</g>'
            else:
                base = '#83788F' if heavy else '#BE945D'
                shade = '#494455' if heavy else '#795034'
                accent = '#DB7960' if fire else ('#F2D58A' if heavy else '#7BA7B2')
                content = f'''<g shape-rendering="crispEdges" transform="translate({round(dx/3)} {round(dy/2)})" fill="{base}" stroke="#252332" stroke-width="1">
                  <path d="M12 20H15V28H10V26H12Z M18 20H21V26H23V28H18Z" fill="{shade}"/>
                  <path d="M8 12H23V17H8Z M11 14H21V23H11Z"/>
                  <path d="M11 6H20V13H11Z"/>
                  <path d="M13 9H15 M17 9H19" stroke="{accent}"/>
                  <circle cx="16" cy="18" r="3" fill="{accent}"/>
                  <path d="M6 14H10V20H6Z M22 14H26V20H22Z" fill="{shade}"/>
                </g>'''
            x, y = i*size, row*size
            shapes.append(f'<g transform="translate({x} {y})">{content}</g>')
            frames.append(dict(action=action, dir="e" if mode == "map" else "", index=i, x=x, y=y))
    folder = ROOT / "assets/enemies" / ident / mode
    folder.mkdir(parents=True, exist_ok=True)
    name = f'{mode}_{ident}'
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{cols*size}" height="{len(counts)*size}" viewBox="0 0 {cols*size} {len(counts)*size}">{"".join(shapes)}</svg>'
    (folder / f'{name}.svg').write_text(svg)
    (folder / f'{name}.json').write_text(json.dumps(dict(asset_id=ident, mode=mode, frame_size=[size, size],
        anchor=[.5, .875 if mode == 'map' else .859375], fps=12,
        loop=['idle','run'] if mode == 'map' else ['idle'], hit_frame={'attack':4,'skill':6}, frames=frames), indent=1))


if __name__ == '__main__':
    for ident in ('training_dummy', 'training_dummy_fire', 'balance_brute'):
        for mode in ('map','battle'):
            write_sheet(ident, mode, fire=ident.endswith('_fire'), heavy=ident=='balance_brute')
    print('Generated map/battle SVG atlases for both training dummies and the sparring golem.')
