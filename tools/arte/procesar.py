"""Convierte las imágenes de ChatGPT (HellsKitchen_Arte/) en sprites del juego (assets/sprites/).

Uso: python3 -I process.py <carpeta HellsKitchen_Arte> <carpeta assets/sprites>
- Personajes: mismas escala y altura de pies en todas sus poses, lienzo cuadrado.
- Cabezas mini: recorte de la parte alta de idle.png.
- Resto: recorte del borde vacío y ajuste a su tamaño final.
"""
import glob
import os
import sys

from PIL import Image

SRC, DST = sys.argv[1], sys.argv[2]
A_MIN = 24  # alfa por debajo de esto cuenta como vacío al recortar


def bbox(im):
    return im.getchannel("A").point(lambda a: 255 if a >= A_MIN else 0).getbbox()


def save(im, rel):
    out = os.path.join(DST, rel)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    im.save(out, optimize=True)


def fit(im, box_w, box_h, pad=0.0, anchor_bottom=False):
    """Recorta el vacío y encaja la imagen en box_w x box_h sin deformarla."""
    im = im.crop(bbox(im))
    iw, ih = box_w * (1 - 2 * pad), box_h * (1 - 2 * pad)
    k = min(iw / im.width, ih / im.height)
    im = im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.LANCZOS)
    canvas = Image.new("RGBA", (box_w, box_h), (0, 0, 0, 0))
    x = (box_w - im.width) // 2
    y = box_h - round(box_h * pad) - im.height if anchor_bottom else (box_h - im.height) // 2
    canvas.alpha_composite(im, (x, y))
    return canvas


def scale_w(im, w):
    im = im.crop(bbox(im))
    return im.resize((w, max(1, round(im.height * w / im.width))), Image.LANCZOS)


def character(folder, rel_folder, size):
    """Todas las poses de un personaje con la misma escala y los pies a la misma altura."""
    poses = {os.path.basename(f)[:-4]: Image.open(f).convert("RGBA") for f in sorted(glob.glob(folder + "/*.png"))}
    boxes = {k: bbox(v) for k, v in poses.items()}
    bottom = max(b[3] for b in boxes.values())
    shifted = {}
    for k, im in poses.items():
        dy = bottom - boxes[k][3]
        c = Image.new("RGBA", im.size, (0, 0, 0, 0))
        c.alpha_composite(im, (0, dy))
        shifted[k] = c
    l = min(b[0] for b in boxes.values())
    r = max(b[2] for b in boxes.values())
    t = min(b[1] + bottom - b[3] for b in boxes.values())
    w, h = r - l, bottom - t
    side = round(max(w, h) * 1.04)
    cx = (l + r) / 2
    margin_b = round(side * 0.02)
    crop = (round(cx - side / 2), bottom + margin_b - side, round(cx + side / 2), bottom + margin_b)
    for k, im in shifted.items():
        save(im.crop(crop).resize((size, size), Image.LANCZOS), f"{rel_folder}/{k}.png")


# Cabezas que el recorte automático no encuentra bien: (centro x, centro y, lado), en fracción del bbox de idle.png
HEAD_FIX = {
    "sabueso": (0.70, 0.30, 0.55),
    "verdugo": (0.47, 0.40, 0.42),
}


def head(idle_path, rel, size=128):
    im = Image.open(idle_path).convert("RGBA")
    l, t, r, b = bbox(im)
    did = os.path.basename(os.path.dirname(idle_path))
    if did in HEAD_FIX:
        fx, fy, fs = HEAD_FIX[did]
        bw, bh = r - l, b - t
        side = fs * max(bw, bh)
        cx, cy = l + fx * bw, t + fy * bh
        crop = im.crop((round(cx - side / 2), round(cy - side / 2), round(cx + side / 2), round(cy + side / 2)))
        save(fit(crop, size, size, pad=0.02), rel)
        return
    band_h = round((b - t) * 0.48)
    band = im.crop((l, t, r, t + band_h))
    alpha = band.getchannel("A")
    # centro horizontal ponderado por el alfa de la franja de la cabeza
    cols = [0] * band.width
    px = alpha.load()
    for x in range(band.width):
        s = 0
        for y in range(0, band.height, 4):
            s += px[x, y]
        cols[x] = s
    tot = sum(cols) or 1
    cx = l + sum(i * c for i, c in enumerate(cols)) / tot
    side = band_h
    crop = im.crop((round(cx - side / 2), t - round(side * 0.04), round(cx + side / 2), t + side - round(side * 0.04)))
    save(fit(crop, size, size, pad=0.02), rel)


# --- personajes ---
for f in sorted(glob.glob(SRC + "/demons/*/")):
    did = os.path.basename(f.rstrip("/"))
    character(f.rstrip("/"), f"demons/{did}", 512)
    if os.path.exists(f + "idle.png"):
        head(f + "idle.png", f"demons/heads/{did}.png")
for f in sorted(glob.glob(SRC + "/cooks/*/")):
    character(f.rstrip("/"), f"cooks/{os.path.basename(f.rstrip('/'))}", 256)

# --- piezas sueltas: ruta -> función ---
SPECS = {
    "demons/_crown.png": lambda im: fit(im, 256, 256, 0.02),
    "demons/_unknown.png": lambda im: fit(im, 512, 512, 0.02, anchor_bottom=True),
    "kitchen/pan.png": lambda im: fit(im, 512, 512, 0.01),
    "kitchen/pentagram.png": lambda im: fit(im, 512, 512, 0.0),
    "kitchen/skull.png": lambda im: fit(im, 128, 128, 0.02),
    "kitchen/window.png": lambda im: scale_w(im, 640),
    "kitchen/counter.png": lambda im: scale_w(im, 1920),
    "kitchen/chain.png": lambda im: scale_w(im, 48),
    "ui/panel.png": lambda im: fit(im, 384, 384, 0.0),
    "ui/card.png": lambda im: fit(im, 256, 256, 0.0),
    "ui/button.png": lambda im: scale_w(im, 384),
    "ui/button_primary.png": lambda im: scale_w(im, 384),
    "ui/bar_frame.png": lambda im: scale_w(im, 768),
    "ui/bar_fill.png": lambda im: scale_w(im, 768),
    "ui/logo.png": lambda im: fit(im, 1200, 800, 0.0),
    "ui/cursor.png": lambda im: fit(im, 40, 40, 0.0),
    "slots/machine.png": lambda im: fit(im, 720, 960, 0.0),
    "slots/lever.png": lambda im: fit(im, 160, 480, 0.0, anchor_bottom=True),
    "tree/hearth.png": lambda im: fit(im, 256, 256, 0.02),
    "tree/node.png": lambda im: fit(im, 96, 96, 0.0),
}
SMALL = ("food/", "icons/", "items/", "decor/", "shop/", "fx/", "slots/", "tree/branches/")


def opaque_bg(im):
    """Fondos de pantalla: recorte a 16:9 centrado y 1920x1080."""
    im = im.convert("RGB")
    tw = im.width
    th = round(tw * 9 / 16)
    if th > im.height:
        th = im.height
        tw = round(th * 16 / 9)
    x = (im.width - tw) // 2
    y = (im.height - th) // 2
    return im.crop((x, y, x + tw, y + th)).resize((1920, 1080), Image.LANCZOS)


done = 0
for f in sorted(glob.glob(SRC + "/**/*.png", recursive=True)):
    rel = os.path.relpath(f, SRC).replace(os.sep, "/")
    if rel.startswith(("demons/", "cooks/")) and rel.count("/") == 2:
        continue  # ya hechas como personajes
    im = Image.open(f)
    if rel.startswith("bg/") or rel == "kitchen/wall.png":
        save(opaque_bg(im), rel)
    elif rel.startswith("ui/frame_"):
        save(fit(im.convert("RGBA"), 160, 160, 0.0), rel)
    elif rel in SPECS:
        save(SPECS[rel](im.convert("RGBA")), rel)
    elif rel.startswith(SMALL):
        save(fit(im.convert("RGBA"), 128, 128, 0.03), rel)
    else:
        print("SIN REGLA:", rel)
        continue
    done += 1
print("piezas sueltas:", done)

# --- versiones pequeñas de los marcos 9-slice (Godot pinta las esquinas a su tamaño real) ---
SLICE = {"panel": (128, 128), "card": (64, 64), "button": (96, 50), "button_primary": (96, 52),
         "bar_frame": (140, 24), "bar_fill": (140, 12)}
for name, (w, h) in SLICE.items():
    f = os.path.join(DST, "ui", name + ".png")
    if os.path.exists(f):
        save(Image.open(f).convert("RGBA").resize((w, h), Image.LANCZOS), f"ui/slice/{name}.png")
