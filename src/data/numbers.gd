class_name Nums
extends RefCounted
## Formato de números grandes y compra en bloque (forma cerrada).

const SUFFIXES := ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]


static func fmt(n: float) -> String:
	if is_nan(n):
		return "0"
	if is_inf(n):
		return "∞"
	var neg := n < 0.0
	n = absf(n)
	if n < 1000.0:
		if n < 10.0 and absf(n - floorf(n)) > 0.05:
			return ("-" if neg else "") + ("%.1f" % n)
		return ("-" if neg else "") + str(int(roundf(n)))
	var i := 0
	while n >= 1000.0 and i < SUFFIXES.size() - 1:
		n /= 1000.0
		i += 1
	if n >= 1000.0:
		return ("-" if neg else "") + ("%.2e" % (n * pow(1000.0, i)))
	var body := ("%.2f" % n) if n < 100.0 else ("%.1f" % n)
	return ("-" if neg else "") + body + SUFFIXES[i]


static func time_fmt(secs: float) -> String:
	secs = maxf(0.0, secs)
	var m := int(secs) / 60
	var s := int(secs) % 60
	if m > 0:
		return "%d:%02d" % [m, s]
	return "%.1f s" % secs


static func bulk_cost(base: float, r: float, owned: int, count: int) -> float:
	if count <= 0:
		return 0.0
	if absf(r - 1.0) < 0.0001:
		return base * float(count)
	return base * pow(r, owned) * (pow(r, count) - 1.0) / (r - 1.0)
