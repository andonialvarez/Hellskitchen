"""Simulación de la progresión de Hell's Kitchen, pacto a pacto.

Reproduce las fórmulas de src/autoload/game_state.gd con un jugador
automático (clica a ritmo fijo, despacha cuando le compensa, compra lo más
barato entre turnos y firma el contrato en cuanto puede).

Uso:
    python3 tools/balance_sim/sim.py                 # números actuales
    python3 tools/balance_sim/sim.py --cps 4 --hours 10 --seeds 5
    python3 tools/balance_sim/sim.py --variant antes   # números de antes del ajuste

Las tablas (demonios, objetos, árbol, despensa, decoración) se leen de los
.gd; las constantes escritas a mano dentro de funciones de game_state.gd
están en KNOBS (mismo valor que en el código).
"""
import argparse
import bisect
import math
import random
import statistics as st
from copy import deepcopy

import gd_data

# Constantes que en game_state.gd están dentro de funciones, no como const.
KNOBS = {
    # --- como está ahora game_state.gd ---
    "pact_souls": 0.20,         # souls_mult: +20% almas por pacto
    "dispatch_frac": 0.15,      # dispatch: 15% de las almas del demonio
    "favor_slope": 0.14,        # Demons.roll: peso * (1 + favor * i * slope)
    "star_favor": 1.5,          # favor: stars * 1.5
    "cook_up_base": 140.0,      # cook_upgrade_cost: 140 * 6^(t+1)
    "cook_up_growth": 6.0,
    "stars_unlock": False,      # effective_pacts: las estrellas NO suman pactos
    "stars_per_pact": 2.5,      #   (antes: pacts + stars / 2.5)
    "one_pact": True,           # cada contrato da 1 pacto; pact_gain_pct abarata el umbral
    "thresholds": gd_data.const("src/autoload/game_state.gd", "PACT_THRESHOLDS"),
    "decor_w": (0.06, 0.006, 0.15),  # open_reward: min(cap, base + tier*slope) es decoración
    "decor_by_rarity": True,    # la decoración cae por rareza, como los objetos
    "serve_cap": 1.0 / gd_data.scalar("src/autoload/game_state.gd", "SERVE_GAP"),  # platos/s
    # --- solo para comparar con la versión anterior (variante "antes") ---
    "prestige_base": 2.5,       # umbral antiguo: 10K * base^pacts
    "prestige_exp": 0.4,        # ganancia antigua: (almas / 10K)^exp
    "gain_vs_threshold": False,
    "prestige_resets": [],      # qué más resetea el contrato (además de almas)
}


class Game:
    def __init__(self, data, knobs, rng):
        self.D, self.K, self.rng = data, knobs, rng
        self.souls = self.souls_life = self.souls_total = 0.0
        self.pacts = 0
        self.tree = set()
        self.items = set()
        self.shop = {}
        self.decor = set()
        self.cooks = []
        self.tree_by_id = {n["id"]: n for n in data["tree"]}
        self.items_by_id = {i["id"]: i for i in data["items"]}
        self.decor_by_id = {x["id"]: x for x in data["decor"]}
        self.shop_by_id = {x["id"]: x for x in data["shop"]}
        self.recalc()

    # ---------- estadísticas derivadas ----------
    def recalc(self):
        m = {}

        def merge(mods, mult=1.0):
            for k, v in mods.items():
                m[k] = m.get(k, 0.0) + float(v) * mult
        for nid in self.tree:
            merge(self.tree_by_id[nid]["mods"])
        for iid in self.items:
            merge(self.items_by_id[iid]["mods"])
        for sid, lvl in self.shop.items():
            merge(self.shop_by_id[sid]["mods"], lvl)
        self.m = m
        self._stars = min(self.D["star_cap"], sum(self.decor_by_id[i]["stars"] for i in self.decor))

    def g(self, k):
        return self.m.get(k, 0.0)

    def max_hp(self): return self.D["BASE_HP"] + self.g("max_hp")
    def attack(self): return self.g("attack")
    def fire_max(self): return self.D["BASE_FIRE"] + self.g("fire_add")
    def cpc(self): return (1 + self.g("cook_add")) * (1 + self.g("click_mult"))

    def cooks_auto(self):
        return sum(self.D["cook_rate"][min(t, 6)] for t in self.cooks) * (1 + self.g("cook_rate_pct"))

    def auto(self): return self.g("autocook_add") + self.cooks_auto()

    def stars(self):
        return self._stars

    def favor(self):
        return self.g("favor_add") + self.stars() * (self.K["star_favor"] + self.g("star_favor_mult") * 1.5)

    def eff_pacts(self):
        if not self.K["stars_unlock"]:
            return self.pacts
        return self.pacts + int(self.stars() / self.K["stars_per_pact"])
    def max_cooks(self): return int(self.D["MAX_COOKS"] + self.g("max_cooks_add"))
    def disc(self, k): return max(0.25, 1 - self.g(k))
    def souls_mult(self): return 1 + self.g("souls_pct") + self.K["pact_souls"] * self.pacts
    def double(self): return min(0.6, self.g("double_pct"))
    def imp_reduce(self): return min(0.8, self.g("impatient_reduce"))

    # ---------- demonios ----------
    def roll(self, force_min=0):
        key = (self.favor(), self.eff_pacts(), force_min)
        if getattr(self, "_roll_key", None) != key:
            fav, ep = key[0], key[1]
            acc, cum = 0.0, []
            for i, d in enumerate(self.D["demons"]):
                if d["pact"] <= ep and i >= force_min:
                    acc += d["weight"] * (1 + fav * i * self.K["favor_slope"])
                cum.append(acc)
            self._roll_key, self._cum = key, cum
        cum = self._cum
        return min(bisect.bisect_left(cum, self.rng.random() * cum[-1]), len(cum) - 1)

    def need(self, d, crowned):
        n = d["cook"] * (1 - min(0.7, self.g("cook_need_pct")))
        return n * (2 if crowned else 1)

    # ---------- turno ----------
    def shift(self, cps, dt=0.05):
        """Juega un turno. Devuelve (duración, motivo, tally, almas_despacho, despachados)."""
        D = self.D["demons"]
        fire, hp = self.fire_max(), self.max_hp()
        atk, cpc, auto = self.attack(), self.cpc(), self.auto()
        rate = cps * cpc + auto
        pat_add = self.g("patience_add")
        arm = {"phys": self.g("armor_phys"), "magic": self.g("armor_magic")}
        red = self.imp_reduce()
        disp_bonus = self.g("dispatch_pct")
        smult = self.souls_mult()
        tally, disp_souls, n_disp = {}, 0.0, 0
        t = 0.0
        first = True

        def spawn():
            nonlocal first
            fm = 3 if (first and self.g("first_rare") > 0) else 0
            first = False
            i = self.roll(fm)
            return i, self.rng.random() < self.D["CROWN_CHANCE"]

        cur, crowned = spawn()
        prog = wait = dmg_t = 0.0
        budget = 1.0
        while True:
            d = D[cur]
            need = self.need(d, crowned)
            pat = d["patience"] + pat_add
            # ¿despachar? si cocinarlo tarda más que su paciencia o si
            # despachar da más almas por segundo que servirlo.
            if atk >= d["power"] and wait == 0.0:
                t_serve = need / rate
                if t_serve > pat or t_serve > 0.3 / (self.K["dispatch_frac"] * (1 + disp_bonus)):
                    pay = d["souls"] * self.K["dispatch_frac"] * (1 + disp_bonus) * smult
                    disp_souls += pay
                    n_disp += 1
                    cur, crowned = spawn()
                    t += 0.3  # tiempo de reacción
                    fire -= 0.3
                    if fire <= 0:
                        return t, "fuego", tally, disp_souls, n_disp
                    continue
            # cocinar un tic
            prog += rate * dt
            wait += dt
            fire -= dt
            t += dt
            if wait > pat:
                dmg_t += dt
                while dmg_t >= self.D["DMG_TICK"]:
                    dmg_t -= self.D["DMG_TICK"]
                    a = arm[d["dtype"]]
                    hp -= d["dmg"] * (100 / (100 + a)) * (1 - red)
            guard = 0
            cap = self.K["serve_cap"]
            if cap:
                budget = min(1.0, budget + cap * dt)
            while prog >= need and guard < 8 * dt * 60:
                if cap:
                    if budget < 1.0:
                        prog = need   # emplatando: la cocción de más se pierde
                        break
                    budget -= 1.0
                guard += 1
                prog -= need
                tally[cur] = tally.get(cur, 0) + 1
                if self.rng.random() < self.double():
                    j = self.roll()
                    tally[j] = tally.get(j, 0) + 1
                cur, crowned = spawn()
                d = D[cur]
                need = self.need(d, crowned)
                wait = dmg_t = 0.0
            if fire <= 0:
                return t, "fuego", tally, disp_souls, n_disp
            if hp <= 0:
                return t, "muerte", tally, disp_souls, n_disp

    def add_souls(self, x):
        self.souls += x
        self.souls_life += x
        self.souls_total += x

    def open_rewards(self, tally):
        R = ["comun", "raro", "epico", "legendario", "mitico", "infernal"]
        smult = self.souls_mult()
        new_stuff = False
        for tier, cnt in tally.items():
            d = self.D["demons"][tier]
            p = min(1.0, d["item"] + self.g("item_pct"))
            ri = R.index(d["rarity"])
            if cnt > 100:   # aproximación normal para no tirar 200.000 dados
                self.add_souls(d["souls"] * smult * 1.015 * cnt)
                mu, sd = cnt * p, math.sqrt(cnt * p * (1 - p))
                hits = max(0, min(cnt, int(round(self.rng.gauss(mu, sd)))))
            else:
                hits = 0
                for _ in range(cnt):
                    self.add_souls(d["souls"] * smult * self.rng.uniform(0.85, 1.18))
                    hits += self.rng.random() < p
            dw = min(self.K["decor_w"][2], self.K["decor_w"][0] + tier * self.K["decor_w"][1])
            decor_pool = [x["id"] for x in self.D["decor"] if x["id"] not in self.decor
                          and (not self.K["decor_by_rarity"] or R.index(x["rarity"]) <= ri)]
            item_pool = [x["id"] for x in self.D["items"]
                         if max(0, ri - 1) <= R.index(x["rarity"]) <= ri and x["id"] not in self.items]
            fallback = 0.0
            for _ in range(hits):
                shop_pool = [x["id"] for x in self.D["shop"] if self.shop.get(x["id"], 0) < x["max"]]
                if not (decor_pool or item_pool or shop_pool):
                    # todo agotado: el resto del botín se paga en almas
                    rest = hits - _
                    fallback += rest * (dw * 0.6 + 0.32 * 0.6 + max(0.0, 1 - dw - 0.32) * 0.5)
                    break
                r = self.rng.random()
                if r < dw:
                    if decor_pool:
                        x = decor_pool.pop(self.rng.randrange(len(decor_pool)))
                        self.decor.add(x); new_stuff = True
                    else:
                        fallback += 0.6
                elif r < dw + 0.32:
                    if shop_pool:
                        x = self.rng.choice(shop_pool)
                        self.shop[x] = self.shop.get(x, 0) + 1; new_stuff = True
                    else:
                        fallback += 0.6
                else:
                    if item_pool:
                        x = item_pool.pop(self.rng.randrange(len(item_pool)))
                        self.items.add(x); new_stuff = True
                    else:
                        fallback += 0.5
            self.add_souls(d["souls"] * smult * fallback)
        if new_stuff:
            self.recalc()

    # ---------- compras ----------
    def offers(self):
        out = []
        for n in self.D["tree"]:
            if n["id"] not in self.tree and (n["parent"] == "hub" or n["parent"] in self.tree):
                out.append((math.ceil(n["cost"] * self.disc("tree_cost_pct")), "tree", n["id"]))
        for s in self.D["shop"]:
            lvl = self.shop.get(s["id"], 0)
            if lvl < s["max"]:
                out.append((math.ceil(math.ceil(s["base"] * s["growth"] ** lvl) * self.disc("shop_cost_pct")), "shop", s["id"]))
        if len(self.cooks) < self.max_cooks():
            out.append((math.ceil(self.D["COOK_BUY_BASE"] * self.D["COOK_BUY_GROWTH"] ** len(self.cooks) * self.disc("cook_cost_pct")), "cook", None))
        for i, t in enumerate(self.cooks):
            if t < 6:
                out.append((math.ceil(self.K["cook_up_base"] * self.K["cook_up_growth"] ** (t + 1) * self.disc("cook_cost_pct")), "cookup", i))
        for x in self.D["decor"]:
            if x["cost"] > 0 and x["id"] not in self.decor:
                out.append((x["cost"], "decor", x["id"]))
        return out

    def spend(self):
        while True:
            offers = [o for o in self.offers() if o[0] <= self.souls]
            if not offers:
                return
            c, kind, ref = min(offers, key=lambda o: o[0])
            self.souls -= c
            if kind == "tree": self.tree.add(ref)
            elif kind == "shop": self.shop[ref] = self.shop.get(ref, 0) + 1
            elif kind == "cook": self.cooks.append(0)
            elif kind == "cookup": self.cooks[ref] += 1
            elif kind == "decor": self.decor.add(ref)
            self.recalc()

    # ---------- contrato ----------
    def threshold(self):
        if self.K["thresholds"]:
            t = self.K["thresholds"]
            base = t[min(self.pacts, len(t) - 1)] * (10 ** max(0, self.pacts - len(t) + 1))
            return base / (1 + self.g("pact_gain_pct")) if self.K["one_pact"] else base
        try:
            return self.D["PRESTIGE_MIN"] * self.K["prestige_base"] ** self.pacts
        except OverflowError:
            return math.inf

    def pact_gain(self):
        if self.K["one_pact"]:
            return 1 if self.souls_life >= self.threshold() else 0
        if self.souls_life < self.D["PRESTIGE_MIN"]:
            return 0
        k = self.threshold() if self.K["gain_vs_threshold"] else self.D["PRESTIGE_K"]
        g = (self.souls_life / k) ** self.K["prestige_exp"] * (1 + self.g("pact_gain_pct"))
        return int(math.floor(g))

    def prestige(self):
        g = self.pact_gain()
        self.pacts += g
        self.souls = self.souls_life = 0.0
        for what in self.K["prestige_resets"]:
            if what == "cooks": self.cooks = []
            elif what == "shop": self.shop = {}
            elif what == "tree": self.tree = set()
        self.recalc()
        return g


def run(data, knobs, cps=6.0, hours=8.0, seed=1, overhead=6.0, verbose=False, stop_pacts=None):
    rng = random.Random(seed)
    g = Game(data, knobs, rng)
    clock, shifts, deaths = 0.0, 0, 0
    run_log = []          # una fila por contrato
    trace = []            # (reloj, pactos, almas de la run) tras cada turno
    unlock = {}           # demonio -> segundo en que se sirvió por primera vez
    cur = {"shifts": 0, "deaths": 0, "t0": 0.0, "dur": 0.0}
    limit = hours * 3600
    while clock < limit and (stop_pacts is None or g.pacts < stop_pacts):
        dur, why, tally, dsouls, ndisp = g.shift(cps)
        clock += dur + overhead
        shifts += 1
        cur["shifts"] += 1
        cur["dur"] += dur
        if why == "muerte":
            deaths += 1
            cur["deaths"] += 1
        g.add_souls(dsouls)
        for i in tally:
            unlock.setdefault(i, clock)
        g.open_rewards(tally)
        g.spend()
        trace.append((clock, g.pacts, g.souls_life * (1 + g.g("pact_gain_pct") if g.K["one_pact"] else 1)))
        if verbose and shifts <= verbose:
            top = max(tally) if tally else -1
            print(f"  turno {shifts:>3} {hms(clock):>7} {why:<6} {dur:5.1f}s servidos {sum(tally.values()):>4} "
                  f"despachados {ndisp:>3} mejor={data['demons'][top]['name'] if top >= 0 else '-':<22} "
                  f"almas_run {fmt(g.souls_life):>7} p.efect {g.eff_pacts()} ★{g.stars():.1f} "
                  f"árbol {len(g.tree)} auto {g.auto():.0f}/s clic {g.cpc():.0f}")
        if g.souls_life >= g.threshold():
            before = g.pacts
            sl = g.souls_life
            gain = g.prestige()
            run_log.append({
                "n": len(run_log) + 1, "t": clock, "pacts": (before, g.pacts),
                "souls_life": sl, "shifts": cur["shifts"], "deaths": cur["deaths"],
                "avg_shift": cur["dur"] / cur["shifts"], "eff_pacts": g.eff_pacts(),
                "stars": g.stars(), "items": len(g.items), "tree": len(g.tree),
            })
            cur = {"shifts": 0, "deaths": 0, "t0": clock, "dur": 0.0}
    return {"game": g, "runs": run_log, "unlock": unlock, "shifts": shifts,
            "deaths": deaths, "clock": clock, "trace": trace}


def hms(s):
    s = int(s)
    return f"{s // 3600}h{(s % 3600) // 60:02d}m" if s >= 3600 else f"{s // 60}m{s % 60:02d}s"


def fmt(n):
    if n < 1000:
        return f"{n:.0f}"
    suf = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx"]
    i = min(int(math.log10(n) // 3), len(suf) - 1)
    return f"{n / 10 ** (3 * i):.1f}{suf[i]}"


def report(data, res):
    g = res["game"]
    print(f"Tiempo jugado: {hms(res['clock'])} · turnos: {res['shifts']} · muertes: {res['deaths']}")
    print(f"Final: pactos {g.pacts} · pactos efectivos {g.eff_pacts()} · estrellas {g.stars():.1f} · "
          f"árbol {len(g.tree)}/{len(data['tree'])} · objetos {len(g.items)}/{len(data['items'])} · "
          f"cocineros {g.cooks} · almas totales {fmt(g.souls_total)}")
    print(f"Stats: ataque {g.attack():.0f} · vida {g.max_hp():.0f} · fuego {g.fire_max():.0f}s · "
          f"cocción/clic {g.cpc():.1f} · auto {g.auto():.1f}/s · mult almas x{g.souls_mult():.1f}")
    print("\nContratos firmados:")
    print(f"{'#':>3} {'cuándo':>8} {'pactos':>9} {'almas run':>10} {'turnos':>6} {'muertes':>7} "
          f"{'turno medio':>11} {'p.efect':>7} {'★':>5} {'obj':>4} {'árbol':>5}")
    for r in res["runs"][:40]:
        print(f"{r['n']:>3} {hms(r['t']):>8} {r['pacts'][0]:>4}→{r['pacts'][1]:<4} {fmt(r['souls_life']):>10} "
              f"{r['shifts']:>6} {r['deaths']:>7} {r['avg_shift']:>10.1f}s {r['eff_pacts']:>7} "
              f"{r['stars']:>5.1f} {r['items']:>4} {r['tree']:>5}")
    if len(res["runs"]) > 40:
        print(f"    … {len(res['runs']) - 40} contratos más")
    print("\nPrimera vez que se sirve cada demonio:")
    for i, d in enumerate(data["demons"]):
        t = res["unlock"].get(i)
        print(f"  {d['name']:<30} (pacto {d['pact']}) {hms(t) if t is not None else '—':>8}")


def _antes_patch(d):
    # costes del árbol del primer commit: 14 valores por sub-rama, la B vuelve a empezar
    d["sub_cost"] = [14.0, 34.0, 82.0, 200.0, 480.0, 1150.0, 2750.0, 6600.0,
                     15800.0, 38000.0, 91000.0, 218000.0, 524000.0, 1260000.0]
    d["chain_cost"] = False
    gd_data.build_tree(d)
    return d


# Números del primer commit (antes del ajuste de equilibrio), para comparar.
ANTES = {
    "cook_up_growth": 4.3, "stars_unlock": True, "one_pact": False, "thresholds": None,
    "decor_w": (0.12, 0.05, 9.0), "decor_by_rarity": False, "serve_cap": None,
}

VARIANTS = {"actual": ({}, None), "antes": (ANTES, _antes_patch)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cps", type=float, default=6.0, help="clics por segundo del jugador")
    ap.add_argument("--hours", type=float, default=8.0)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--trace", type=int, default=0, help="imprime los N primeros turnos")
    ap.add_argument("--variant", default="actual", choices=sorted(VARIANTS))
    a = ap.parse_args()
    data = gd_data.load()
    knobs = dict(KNOBS)
    kn, patch = VARIANTS[a.variant]
    knobs.update(kn)
    if patch:
        data = patch(deepcopy(data))
    res = run(data, knobs, cps=a.cps, hours=a.hours, seed=a.seed, verbose=a.trace)
    report(data, res)


if __name__ == "__main__":
    main()
