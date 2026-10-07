"""Banco de pruebas: compara variantes de números en varias semillas."""
import sys
import statistics as st
from copy import deepcopy
import gd_data
import sim


def milestones(res, data):
    t_pact = {}
    for r in res["runs"]:
        for p in range(r["pacts"][0] + 1, r["pacts"][1] + 1):
            t_pact.setdefault(p, r["t"])
    t_demon = res["unlock"]
    return t_pact, t_demon


def compare(name, knobs_upd, patch, cps=5.0, hours=8.0, seeds=(1, 2, 3)):
    base = gd_data.load()
    rows = []
    for sd in seeds:
        data = patch(deepcopy(base)) if patch else deepcopy(base)
        k = dict(sim.KNOBS); k.update(knobs_upd)
        res = sim.run(data, k, cps=cps, hours=hours, seed=sd)
        rows.append((res, data))
    print(f"\n=== {name} · {cps} clics/s · {hours} h · semillas {list(seeds)} ===")
    D = rows[0][1]["demons"]
    # pacto efectivo en que entra cada tramo -> cuándo se sirve su primer demonio
    tiers = sorted(set(d["pact"] for d in D))
    line = "tramo de demonios (1º servido): "
    for t in tiers:
        idx = [i for i, d in enumerate(D) if d["pact"] == t][0]
        ts = [r[0]["unlock"].get(idx) for r in rows]
        ts = [x for x in ts if x is not None]
        line += f" p{t}={sim.hms(st.median(ts)) if len(ts) == len(rows) else ('—' if not ts else sim.hms(st.median(ts)) + '*')}"
    print(line)
    line = "pactos alcanzados:              "
    for p in [1, 2, 3, 4, 5, 6, 7, 8, 10, 15]:
        ts = [milestones(r[0], r[1])[0].get(p) for r in rows]
        ts = [x for x in ts if x is not None]
        if ts:
            line += f" {p}={sim.hms(st.median(ts))}{'*' if len(ts) < len(rows) else ''}"
    print(line)
    g = [r[0]["game"] for r in rows]
    print(f"final: pactos {[x.pacts for x in g]} · árbol {[len(x.tree) for x in g]} · "
          f"contratos {[len(r[0]['runs']) for r in rows]} · muertes {[r[0]['deaths'] for r in rows]} "
          f"de {[r[0]['shifts'] for r in rows]} turnos")
    return rows
