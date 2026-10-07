class_name Shop
extends RefCounted
## La Despensa: mejoras que se compran con almas (y que también sueltan los
## demonios como "vales"). Suben el valor por clic, las almas y la auto-cocción.
## Por niveles; coste = base · growth^nivel. Persisten y NO se resetean al firmar.
##  mods (por nivel): cook_add · click_mult · souls_pct · autocook_add · fire_add

const LIST := [
	# --- especias ---
	{"id": "sal_azufre",   "cat": "especias",   "name": "Sal de azufre",           "desc": "+10% almas",                   "base": 60.0,   "growth": 1.55, "max": 30, "icon": "ember", "mods": {"souls_pct": 0.10}},
	{"id": "pimienta",     "cat": "especias",   "name": "Pimienta del abismo",     "desc": "+1 de cocción por clic",       "base": 45.0,   "growth": 1.6,  "max": 40, "icon": "ember", "mods": {"cook_add": 1.0}},
	{"id": "guindilla",    "cat": "especias",   "name": "Guindilla infernal",      "desc": "+8% al valor por clic",        "base": 130.0,  "growth": 1.7,  "max": 25, "icon": "flame", "mods": {"click_mult": 0.08}},
	{"id": "polvo_hueso",  "cat": "especias",   "name": "Polvo de hueso",          "desc": "+6% almas",                    "base": 90.0,   "growth": 1.6,  "max": 30, "icon": "ember", "mods": {"souls_pct": 0.06}},
	# --- utensilios ---
	{"id": "sarten_hierro","cat": "utensilios", "name": "Sartén de hierro colado", "desc": "+2 de cocción por clic",       "base": 110.0,  "growth": 1.7,  "max": 20, "icon": "pan",   "mods": {"cook_add": 2.0}},
	{"id": "cuchillo_obs", "cat": "utensilios", "name": "Cuchillo de obsidiana",   "desc": "+12% al valor por clic",       "base": 260.0,  "growth": 1.8,  "max": 20, "icon": "sword", "mods": {"click_mult": 0.12}},
	{"id": "cazo_bronce",  "cat": "utensilios", "name": "Cazo de bronce maldito",  "desc": "+15% almas",                   "base": 320.0,  "growth": 1.75, "max": 20, "icon": "cup",   "mods": {"souls_pct": 0.15}},
	{"id": "fuelle",       "cat": "utensilios", "name": "Fuelle de dragón",        "desc": "+10 s de fuego",               "base": 360.0,  "growth": 1.8,  "max": 15, "icon": "flame", "mods": {"fire_add": 10.0}},
]

const CATS := ["especias", "utensilios"]
static var _map := {}


static func by_id(id: String) -> Dictionary:
	return DataIndex.by_id(_map, LIST, id)


static func cost(id: String, level: int) -> float:
	var u := by_id(id)
	if u.is_empty() or level >= int(u["max"]):
		return INF
	return ceilf(float(u["base"]) * pow(float(u["growth"]), level))


static func random_not_maxed(levels: Dictionary) -> String:
	var pool: Array = []
	for u in LIST:
		if int(levels.get(u["id"], 0)) < int(u["max"]):
			pool.append(u["id"])
	if pool.is_empty():
		return ""
	return pool[randi() % pool.size()]
