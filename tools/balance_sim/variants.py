"""Variantes de números para comparar con la simulación."""
import gd_data


def scale_mod(d, mod, f):
    for b in d["tree_def"]:
        for nd in [b["root"]] + b["a"]["nodes"] + b["b"]["nodes"]:
            m = nd.get("m", {})
            if mod in m:
                m[mod] = m[mod] * f
    for it in d["items"]:
        if mod in it["mods"]:
            it["mods"][mod] = it["mods"][mod] * f


def tree_costs(d, first=14.0, growth=4.0):
    d["sub_cost"] = [first * growth ** k for k in range(len(d["sub_cost"]))]


def finish(d):
    gd_data.build_tree(d)
    return d


def chain_costs(d, first=14.0, growth=2.67, n=28):
    d["sub_cost"] = [first * growth ** k for k in range(n)]
    d["chain_cost"] = True
