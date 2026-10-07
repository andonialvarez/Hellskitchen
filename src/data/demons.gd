class_name Demons
extends RefCounted
## Demonios de rango creciente. Sirviéndolos se apuntan en el recuento del
## turno (el botín se abre al terminar). Si tienes ataque >= `power` puedes
## DESPACHARLOS al instante (almas menores, sin objeto).
##  weight   probabilidad relativa de aparición
##  cook     progreso de cocción para servirle
##  souls    almas base del botín
##  item     probabilidad base de que su botín sea un objeto
##  power    ataque necesario para despacharlo
##  dmg      daño por tic (0,5 s) cuando se impacienta
##  dtype    "phys" | "magic"
##  patience segundos que espera antes de empezar a hacerte daño
##  pact     pactos necesarios para que aparezca
##
## Los 6 primeros (pact 0-1) son EXACTAMENTE los del principio del juego:
## el arranque no cambia. Todo lo demás (pact 2 en adelante) es contenido
## nuevo para que la partida dure mucho más.

const RARITY_COLORS := {
	"comun": "#9a8d84", "raro": "#4bb0c9", "epico": "#c9622e",
	"legendario": "#e0b23a", "mitico": "#b455d6", "infernal": "#e23b3b",
}
const RARITY_ORDER := ["comun", "raro", "epico", "legendario", "mitico", "infernal"]

const LIST := [
	# --- pact 0-1: idéntico al arranque original, no se toca ---
	{"id": "diablillo", "name": "Federico",              "rarity": "comun", "weight": 100.0, "cook": 4.0,  "souls": 4.0,   "item": 0.02, "power": 3.0,    "dmg": 2.0,   "dtype": "phys",  "patience": 9.0, "pact": 0},
	{"id": "sabueso",   "name": "Sabueso de brasas",      "rarity": "comun", "weight": 62.0,  "cook": 7.0,  "souls": 12.0,  "item": 0.03, "power": 8.0,    "dmg": 3.0,   "dtype": "phys",  "patience": 8.0, "pact": 0},
	{"id": "gargola",   "name": "Gárgola glotona",        "rarity": "comun", "weight": 34.0,  "cook": 12.0, "souls": 40.0,  "item": 0.04, "power": 20.0,   "dmg": 5.0,   "dtype": "phys",  "patience": 8.0, "pact": 0},
	{"id": "incubo",    "name": "Íncubo goloso",          "rarity": "raro",  "weight": 19.0,  "cook": 21.0, "souls": 130.0, "item": 0.07, "power": 55.0,   "dmg": 8.0,   "dtype": "magic", "patience": 7.0, "pact": 1},
	{"id": "verdugo",   "name": "Verdugo de ceniza",      "rarity": "raro",  "weight": 11.0,  "cook": 35.0, "souls": 440.0, "item": 0.10, "power": 150.0,  "dmg": 13.0,  "dtype": "phys",  "patience": 6.5, "pact": 1},
	{"id": "behemot",   "name": "Behemot de sebo",        "rarity": "raro",  "weight": 6.5,   "cook": 60.0, "souls": 1500.0,"item": 0.14, "power": 420.0,  "dmg": 20.0,  "dtype": "phys",  "patience": 6.0, "pact": 1},
	# --- pact 2: primer tramo nuevo ---
	{"id": "belfegor",  "name": "Barón Belfegor",         "rarity": "epico", "weight": 3.6,   "cook": 100.0, "souls": 5200.0,   "item": 0.20, "power": 1200.0,  "dmg": 32.0,  "dtype": "magic", "patience": 5.5, "pact": 2},
	{"id": "mammon",    "name": "Condesa Mammón",         "rarity": "epico", "weight": 2.1,   "cook": 170.0, "souls": 18000.0,  "item": 0.28, "power": 3400.0,  "dmg": 52.0,  "dtype": "magic", "patience": 5.0, "pact": 2},
	{"id": "sucubo",    "name": "Súcubo susurrante",      "rarity": "epico", "weight": 1.3,   "cook": 230.0, "souls": 42000.0,  "item": 0.34, "power": 7000.0,  "dmg": 70.0,  "dtype": "magic", "patience": 4.8, "pact": 2},
	# --- pact 3 ---
	{"id": "belial",    "name": "Conde Belial",           "rarity": "legendario", "weight": 0.85, "cook": 320.0, "souls": 100000.0, "item": 0.42, "power": 18000.0,  "dmg": 110.0, "dtype": "phys",  "patience": 4.5, "pact": 3},
	{"id": "fenrix",    "name": "Duque Fenrix",           "rarity": "legendario", "weight": 0.55, "cook": 440.0, "souls": 240000.0, "item": 0.48, "power": 42000.0,  "dmg": 160.0, "dtype": "phys",  "patience": 4.3, "pact": 3},
	{"id": "lilith_m",  "name": "Marquesa Lilith",        "rarity": "legendario", "weight": 0.35, "cook": 600.0, "souls": 560000.0, "item": 0.54, "power": 95000.0,  "dmg": 230.0, "dtype": "magic", "patience": 4.0, "pact": 3},
	# --- pact 4 ---
	{"id": "asmodeo",   "name": "Asmodeo, Rey de la Ira", "rarity": "mitico", "weight": 0.22, "cook": 820.0,  "souls": 1.3e6, "item": 0.60, "power": 210000.0, "dmg": 330.0, "dtype": "magic", "patience": 3.8, "pact": 4},
	{"id": "leviatan",  "name": "Leviatán Menor",         "rarity": "mitico", "weight": 0.14, "cook": 1100.0, "souls": 3.0e6, "item": 0.65, "power": 470000.0, "dmg": 470.0, "dtype": "phys",  "patience": 3.6, "pact": 4},
	{"id": "behemot_m", "name": "Behemot Mayor",          "rarity": "mitico", "weight": 0.09, "cook": 1500.0, "souls": 6.9e6, "item": 0.70, "power": 1.0e6,    "dmg": 670.0, "dtype": "phys",  "patience": 3.4, "pact": 4},
	# --- pact 5 ---
	{"id": "astaroth",  "name": "Astaroth el Cornudo",         "rarity": "mitico", "weight": 0.060, "cook": 2050.0, "souls": 1.6e7, "item": 0.74, "power": 2.3e6, "dmg": 950.0,  "dtype": "magic", "patience": 3.2, "pact": 5},
	{"id": "belcebu",   "name": "Belcebú, Señor de las Moscas","rarity": "mitico", "weight": 0.038, "cook": 2800.0, "souls": 3.7e7, "item": 0.78, "power": 5.1e6, "dmg": 1350.0, "dtype": "magic", "patience": 3.0, "pact": 5},
	{"id": "moloch",    "name": "Moloch el Devorador",         "rarity": "mitico", "weight": 0.024, "cook": 3800.0, "souls": 8.5e7, "item": 0.81, "power": 1.1e7, "dmg": 1900.0, "dtype": "phys",  "patience": 2.9, "pact": 5},
	# --- pact 6 ---
	{"id": "mefisto",   "name": "Mefistófeles",                "rarity": "infernal", "weight": 0.0150, "cook": 5200.0,  "souls": 2.0e8, "item": 0.85, "power": 2.5e7, "dmg": 2700.0, "dtype": "magic", "patience": 2.8, "pact": 6},
	{"id": "baal",      "name": "Baal Supremo",                "rarity": "infernal", "weight": 0.0100, "cook": 7100.0,  "souls": 4.5e8, "item": 0.88, "power": 5.6e7, "dmg": 3800.0, "dtype": "magic", "patience": 2.7, "pact": 6},
	{"id": "dagon",     "name": "Dagon de las Profundidades",  "rarity": "infernal", "weight": 0.0065, "cook": 9700.0,  "souls": 1.05e9,"item": 0.91, "power": 1.3e8, "dmg": 5300.0, "dtype": "phys",  "patience": 2.6, "pact": 6},
	# --- pact 7 ---
	{"id": "abaddon",   "name": "Abaddon el Destructor",       "rarity": "infernal", "weight": 0.0042, "cook": 13300.0, "souls": 2.4e9, "item": 0.93, "power": 2.9e8, "dmg": 7500.0,  "dtype": "phys",  "patience": 2.5, "pact": 7},
	{"id": "samael",    "name": "Samael, Portador de Muerte",  "rarity": "infernal", "weight": 0.0027, "cook": 18200.0, "souls": 5.5e9, "item": 0.95, "power": 6.6e8, "dmg": 10500.0, "dtype": "magic", "patience": 2.4, "pact": 7},
	{"id": "lilith_s",  "name": "Lilith Suprema",              "rarity": "infernal", "weight": 0.0018, "cook": 24900.0, "souls": 1.3e10,"item": 0.97, "power": 1.5e9, "dmg": 14700.0, "dtype": "magic", "patience": 2.3, "pact": 7},
	# --- pact 8: el final, secreto ---
	{"id": "lucifer",   "name": "El Cocinero Original",        "rarity": "infernal", "weight": 0.0007, "cook": 34000.0, "souls": 3.0e10,"item": 1.00, "power": 3.5e9, "dmg": 21000.0, "dtype": "magic", "patience": 2.2, "pact": 8},
]

static var _map := {}


static func by_id(id: String) -> Dictionary:
	if _map.is_empty():
		for d in LIST:
			_map[d["id"]] = d
	return _map.get(id, {})


static func index_of(id: String) -> int:
	for i in LIST.size():
		if LIST[i]["id"] == id:
			return i
	return -1


static func color(rarity: String) -> Color:
	return Color(RARITY_COLORS.get(rarity, "#9a8d84"))


## % de aparición de cada demonio posible ahora mismo (según favor/pactos).
static func odds(favor: float, pacts: int) -> Array:
	var total := 0.0
	var ws := []
	for i in LIST.size():
		var d: Dictionary = LIST[i]
		var w := 0.0
		if d["pact"] <= pacts:
			w = float(d["weight"]) * (1.0 + favor * float(i) * 0.14)
		ws.append(w)
		total += w
	var out: Array = []
	if total <= 0.0:
		return out
	for i in LIST.size():
		if ws[i] > 0.0:
			out.append({
				"id": LIST[i]["id"], "name": LIST[i]["name"],
				"rarity": LIST[i]["rarity"], "pct": ws[i] / total * 100.0,
			})
	return out


static func roll(favor: float, pacts: int, force_min_index := 0) -> Dictionary:
	var total := 0.0
	var weights := []
	for i in LIST.size():
		var d: Dictionary = LIST[i]
		var w := 0.0
		if d["pact"] <= pacts and i >= force_min_index:
			w = float(d["weight"]) * (1.0 + favor * float(i) * 0.14)
		weights.append(w)
		total += w
	if total <= 0.0:
		return LIST[0]
	var r := randf() * total
	for i in LIST.size():
		r -= weights[i]
		if r <= 0.0:
			return LIST[i]
	return LIST[0]
