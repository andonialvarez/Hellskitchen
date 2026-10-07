"""Lee las tablas de datos directamente de los .gd del juego.

Así la simulación usa SIEMPRE los números reales: si cambias un valor en
src/data/*.gd o en game_state.gd y vuelves a ejecutar sim.py, ves el efecto.
"""
import ast
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def _block(text: str, name: str) -> str:
    m = re.search(r"const\s+" + name + r"\s*:?=\s*", text)
    if not m:
        raise KeyError(name)
    i = m.end()
    open_c = text[i]
    close_c = {"[": "]", "{": "}"}[open_c]
    depth, j, in_str = 0, i, False
    while True:
        c = text[j]
        if in_str:
            if c == "\\":
                j += 1
            elif c == '"':
                in_str = False
        elif c == '"':
            in_str = True
        elif c == "#":
            j = text.index("\n", j)
            continue
        elif c == open_c:
            depth += 1
        elif c == close_c:
            depth -= 1
            if depth == 0:
                return text[i:j + 1]
        j += 1


def _strip_comments(src: str) -> str:
    out = []
    for line in src.splitlines():
        in_str = False
        for k, c in enumerate(line):
            if c == '"':
                in_str = not in_str
            elif c == "#" and not in_str:
                line = line[:k]
                break
        out.append(line)
    return "\n".join(out)


def const(path: str, name: str):
    text = (ROOT / path).read_text(encoding="utf-8")
    return ast.literal_eval(_strip_comments(_block(text, name)))


def scalar(path: str, name: str) -> float:
    text = (ROOT / path).read_text(encoding="utf-8")
    m = re.search(r"const\s+" + name + r"\s*:?=\s*([-0-9.e]+)", text)
    return float(m.group(1))


def load():
    gs = "src/autoload/game_state.gd"
    d = {
        "demons": const("src/data/demons.gd", "LIST"),
        "items": const("src/data/items.gd", "LIST"),
        "shop": const("src/data/shop.gd", "LIST"),
        "decor": const("src/data/decor.gd", "LIST"),
        "star_cap": scalar("src/data/decor.gd", "STAR_CAP"),
        "tree_def": const("src/data/tree.gd", "DEF"),
        "root_cost": scalar("src/data/tree.gd", "ROOT_COST"),
        "sub_cost": const("src/data/tree.gd", "SUB_COST"),
        "cook_rate": const(gs, "COOK_RATE"),
    }
    for k in ["BASE_FIRE", "BASE_HP", "DMG_TICK", "PRESTIGE_K", "PRESTIGE_MIN",
              "CROWN_CHANCE", "COOK_BUY_BASE", "COOK_BUY_GROWTH", "MAX_COOKS"]:
        d[k] = scalar(gs, k)
    build_tree(d)
    return d


def build_tree(d):
    """Nodos del árbol, igual que SkillTree._build()."""
    nodes = []
    for b in d["tree_def"]:
        key = b["key"]
        rid = f"{key}_r"
        nodes.append({"id": rid, "name": b["root"]["n"], "cost": d["root_cost"],
                      "mods": b["root"]["m"], "parent": "hub"})
        prev = rid
        for side in ["a", "b"]:
            for k, nd in enumerate(b[side]["nodes"]):
                nid = f"{key}_{side}_{k}"
                # chain_cost: el coste sigue la posición en la cadena (a0..a13, b0..b13)
                ci = k + (len(b["a"]["nodes"]) if side == "b" and d.get("chain_cost") else 0)
                nodes.append({"id": nid, "name": nd["n"],
                              "cost": d["sub_cost"][min(ci, len(d["sub_cost"]) - 1)],
                              "mods": nd["m"], "parent": prev})
                prev = nid
    d["tree"] = nodes


if __name__ == "__main__":
    d = load()
    print({k: (len(v) if isinstance(v, list) else v) for k, v in d.items()})
