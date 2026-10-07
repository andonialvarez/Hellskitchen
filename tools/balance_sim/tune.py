import sys, exp, sim, gd_data, variants as V
from copy import deepcopy
H = float(sys.argv[1]) if len(sys.argv) > 1 else 9
def mk(tg=None, first=14.0, extra=None):
    def patch(d):
        if tg: V.tree_costs(d, first=first, growth=tg)
        if extra: extra(d)
        return V.finish(d)
    return patch
def detail(name, kn, patch, seed=1, cps=5.0):
    d = patch(deepcopy(gd_data.load()))
    k = dict(sim.KNOBS); k.update(kn)
    res = sim.run(d, k, cps=cps, hours=H, seed=seed)
    print(f"\n=== {name} (semilla {seed}, {cps} clics/s) ===")
    prev = 0
    for r in res["runs"]:
        print(f"  pacto {r['pacts'][1]:>2} a {sim.hms(r['t']):>7} (+{sim.hms(r['t']-prev):>7}, {r['shifts']:>3} turnos, "
              f"turno medio {r['avg_shift']:5.0f}s, muertes {r['deaths']:>2}) árbol {r['tree']:>3} obj {r['items']:>2} ★{r['stars']:.0f}")
        prev = r["t"]
    g = res["game"]
    print(f"  final {sim.hms(res['clock'])}: pactos {g.pacts}, árbol {len(g.tree)}, almas/turno último ~{sim.fmt(g.souls_life/max(1,res['shifts']-sum(r['shifts'] for r in res['runs'])))}")
    return res


def nice(x):
    """Redondea a 2 cifras significativas."""
    import math
    e = math.floor(math.log10(x)) - 1
    return round(x / 10 ** e) * 10 ** e


def calibrate(kn, patch, targets_min, seeds=(1, 2, 3), cps=5.0):
    """Busca la tabla de umbrales para que el pacto P llegue en targets_min[P-1] minutos."""
    import statistics as st
    th = []
    for P in range(len(targets_min)):
        tgt = targets_min[P] * 60
        vals = []
        for sd in seeds:
            d = patch(deepcopy(gd_data.load()))
            k = dict(sim.KNOBS); k.update(kn)
            k["thresholds"] = th + [1e300]
            res = sim.run(d, k, cps=cps, hours=tgt / 3600 + 0.01, seed=sd)
            rows = [x for x in res["trace"] if x[1] == P]
            if not rows:
                vals.append(float("nan")); continue
            # almas de la run en el turno que cruza el objetivo
            hit = [x for x in rows if x[0] >= tgt]
            vals.append((hit[0] if hit else rows[-1])[2])
        # el umbral real del juego es el de la tabla: si pact_gain_pct lo abarata,
        # la tabla se escribe "sin descuento" (multiplicamos de vuelta luego)
        th.append(nice(st.median(vals)))
        print(f"  pacto {P}->{P+1}: objetivo {targets_min[P]} min -> umbral {th[-1]:.3g}  (semillas: {[f'{v:.2g}' for v in vals]})", flush=True)
    return th
