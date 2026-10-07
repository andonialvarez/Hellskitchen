import sys, tune, variants as V
kn = {'stars_unlock': False, 'one_pact': True, 'cook_up_growth': 6.0,
      'decor_w': (0.06, 0.006, 0.15), 'serve_cap': 4.0, 'decor_by_rarity': True}
g = float(sys.argv[2])
patch = tune.mk(extra=lambda d: V.chain_costs(d, growth=g))
targets = [8, 20, 40, 65, 100, 140, 190, 250]
th = tune.calibrate(kn, patch, targets)
print("TABLA", th, flush=True)
kn["thresholds"] = th
for sd in (1, 2, 3):
    tune.detail(f"comprobación cadena x{g}", kn, patch, seed=sd)
for sd in (1,):
    tune.detail(f"jugador tranquilo 3 clics/s", kn, patch, seed=sd, cps=3.0)
    tune.detail(f"jugador rápido 8 clics/s", kn, patch, seed=sd, cps=8.0)
