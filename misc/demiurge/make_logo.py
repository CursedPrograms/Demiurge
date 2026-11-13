# Demiurge's logo, icons and splash, drawn from one design: a world being made. Its lower half is finished (solid
# Atelier blue), its upper half is still wireframe, and the line between them is where the making happens.
# Writes the editor's SVG icons, the boot splash, the app icon and the Windows .ico files.
# Needs: pillow, fonttools, brotli (for the Inter font in Godot's thirdparty/fonts, OFL).
import io, math, os
from PIL import Image, ImageDraw, ImageFont
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
BG, LINE, GREY, WHITE = '#1a1a1a', '#3a3a3a', '#9a9a9a', '#e6e6e6'
BLUE, DEEP, LIGHT = '#007bb7', '#005184', '#34a9e3'
NAME = 'Demiurge'

# ---------- the mark, in a 128 x 128 box
C, R = 64.0, 38.0
def chord(d):  # half the width of the globe at d above / below the equator
    return math.sqrt(max(R * R - d * d, 0))

def mark_svg(bg=True):
    s = []
    if bg: s.append(f'<rect width="124" height="124" x="2" y="2" rx="24" fill="{BG}"/>')
    # the finished half: solid blue, with deep blue lines on it
    s.append(f'<path d="M{C - R} {C} A{R} {R} 0 0 0 {C + R} {C} Z" fill="{BLUE}"/>')
    s.append(f'<path d="M{C} {C} V{C + R} M{C - chord(19)} {C + 19} H{C + chord(19)}" stroke="{DEEP}" stroke-width="3" fill="none"/>')
    s.append(f'<path d="M{C - 19} {C} A19 {R} 0 0 0 {C + 19} {C}" stroke="{DEEP}" stroke-width="3" fill="none"/>')
    # the unfinished half: wireframe
    w = 'stroke-width="3" fill="none" stroke-linecap="round"'
    s.append(f'<path d="M{C - R} {C} A{R} {R} 0 0 1 {C + R} {C}" stroke="{GREY}" {w}/>')
    s.append(f'<path d="M{C - 19} {C} A19 {R} 0 0 1 {C + 19} {C} M{C} {C} V{C - R}" stroke="{GREY}" {w}/>')
    s.append(f'<path d="M{C - chord(19):.2f} {C - 19} H{C + chord(19):.2f}" stroke="{GREY}" {w}/>')
    # where it's being made: the line across, wider than the world
    s.append(f'<path d="M{C - R - 14} {C} H{C + R + 14}" stroke="{LIGHT}" stroke-width="4" stroke-linecap="round"/>')
    # the spark
    x, y, a, b = 101, 27, 9, 2.6
    s.append(f'<path d="M{x} {y - a} L{x + b} {y - b} L{x + a} {y} L{x + b} {y + b} L{x} {y + a} L{x - b} {y + b} L{x - a} {y} L{x - b} {y - b} Z" fill="{LIGHT}"/>')
    return '\n'.join(s)

def draw_mark(size, bg=True):
    """the same mark drawn with Pillow (no SVG renderer needed), 8x supersampled"""
    k = size * 8 / 128.0
    im = Image.new('RGBA', (size * 8, size * 8), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    P = lambda v: v * k
    W = lambda v: max(1, int(round(v * k)))
    if bg: d.rounded_rectangle([P(2), P(2), P(126), P(126)], radius=P(24), fill=BG)
    box = [P(C - R), P(C - R), P(C + R), P(C + R)]
    d.pieslice(box, 0, 180, fill=BLUE)
    d.line([P(C), P(C), P(C), P(C + R)], fill=DEEP, width=W(3))
    d.line([P(C - chord(19)), P(C + 19), P(C + chord(19)), P(C + 19)], fill=DEEP, width=W(3))
    d.arc([P(C - 19), P(C - R), P(C + 19), P(C + R)], 0, 180, fill=DEEP, width=W(3))
    d.arc(box, 180, 360, fill=GREY, width=W(3))
    d.arc([P(C - 19), P(C - R), P(C + 19), P(C + R)], 180, 360, fill=GREY, width=W(3))
    d.line([P(C), P(C - R), P(C), P(C)], fill=GREY, width=W(3))
    d.line([P(C - chord(19)), P(C - 19), P(C + chord(19)), P(C - 19)], fill=GREY, width=W(3))
    d.line([P(C - R - 14), P(C), P(C + R + 14), P(C)], fill=LIGHT, width=W(4))
    for xx in (C - R - 14, C + R + 14): d.ellipse([P(xx - 2), P(C - 2), P(xx + 2), P(C + 2)], fill=LIGHT)
    x, y, a, b = 101, 27, 9, 2.6
    d.polygon([(P(x), P(y - a)), (P(x + b), P(y - b)), (P(x + a), P(y)), (P(x + b), P(y + b)), (P(x), P(y + a)), (P(x - b), P(y + b)), (P(x - a), P(y)), (P(x - b), P(y - b))], fill=LIGHT)
    return im.resize((size, size), Image.LANCZOS)

# ---------- the name, as outlines from Inter Bold (so the SVGs need no font)
font_path = os.path.join(ROOT, 'thirdparty', 'fonts', 'Inter_Bold.woff2')
tt = TTFont(font_path)
ttf_bytes = io.BytesIO(); tt.flavor = None; tt.save(ttf_bytes)
upm = tt['head'].unitsPerEm
def text_path(text, x, baseline, size):
    gs = tt.getGlyphSet(); cmap = tt.getBestCmap(); scale = size / upm
    out = []; pen_x = 0
    for ch in text:
        g = cmap[ord(ch)]
        sp = SVGPathPen(gs)
        gs[g].draw(TransformPen(sp, (scale, 0, 0, -scale, x + pen_x * scale, baseline)))
        out.append(sp.getCommands())
        pen_x += tt['hmtx'][g][0]
    return ' '.join(out), pen_x * scale

def wordmark(w, h, text_fill, text_size):
    mark = mark_svg(bg=False)
    t, tw = text_path(NAME, h * 1.02, h * 0.5 + text_size * 0.36, text_size)
    s = h / 128.0
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">'
            f'<g transform="scale({s:.5f})">{mark}</g><path fill="{text_fill}" d="{t}"/></svg>'), h * 1.02 + tw

def write(rel, data, mode='w'):
    p = os.path.join(ROOT, rel)
    with open(p, mode, **({} if 'b' in mode else {'encoding': 'utf-8', 'newline': '\n'})) as f: f.write(data)
    print('wrote', rel)

# the editor: About / project manager logo (white name), the title bar logo, a new project's icon
svg, used = wordmark(0, 69, '#fff', 34)
write('editor/icons/Logo.svg', svg.replace('width="0"', f'width="{math.ceil(used)}"'))
svg, used = wordmark(0, 24, '#e0e0e0', 13)
write('editor/icons/TitleBarLogo.svg', svg.replace('width="0"', f'width="{math.ceil(used)}"'))
write('editor/icons/DefaultProjectIcon.svg', f'<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128">{mark_svg()}</svg>')
write('misc/demiurge/logo.svg', f'<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128">{mark_svg()}</svg>')

# the app icon, the boot splash, the Windows icons
draw_mark(128).save(os.path.join(ROOT, 'main', 'app_icon.png')); print('wrote main/app_icon.png')
draw_mark(512).save(os.path.join(ROOT, 'misc', 'demiurge', 'logo.png')); print('wrote misc/demiurge/logo.png')
splash = Image.new('RGBA', (800, 600), (0, 0, 0, 0))
m = draw_mark(220, bg=False); splash.alpha_composite(m, ((800 - 220) // 2, 150))
f = ImageFont.truetype(io.BytesIO(ttf_bytes.getvalue()), 54)
d = ImageDraw.Draw(splash); tw = d.textlength(NAME, font=f)
d.text(((800 - tw) / 2, 385), NAME, font=f, fill=WHITE)
splash.save(os.path.join(ROOT, 'main', 'splash.png')); print('wrote main/splash.png')
sizes = [(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)]
big = draw_mark(256)
for ico in ('platform/windows/godot.ico', 'platform/windows/godot_console.ico'):
    big.save(os.path.join(ROOT, ico), format='ICO', sizes=sizes); print('wrote', ico)
