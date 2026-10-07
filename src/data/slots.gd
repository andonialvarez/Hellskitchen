class_name Slots
extends RefCounted
## La Tragaperras del Infierno. 3 rodillos con símbolos ponderados.
## 3 símbolos iguales = premio; el resto = nada (salvo 2 almas = consolación).
##
##  SÍMBOLOS
##   skull  · calavera de relleno ....................... nada
##   imp    · diablillo riéndose con tridente ........... MALDICE tu próxima tirada
##   soul   · cofre resplandeciente con aura azul ....... ALMAS
##   loot   · cofre lleno de abalorios ................. OBJETO
##   sigil  · sello pentagrama ......................... BENDICIÓN para tu próxima run

const SYMBOLS := ["skull", "imp", "soul", "loot", "sigil"]
const WEIGHTS := {"skull": 30, "imp": 15, "soul": 24, "loot": 13, "sigil": 18}
## Probabilidad de que un rodillo COPIE al primero. Sube este número para que
## la máquina reparta más premios; bájalo para hacerla más tacaña. Con 0.0 los
## 3 rodillos son totalmente independientes.
const MATCH_BIAS := 0.34

## Bendiciones: buffs que duran SÓLO la siguiente run (se aplican en start_shift
## y se retiran en end_shift). Usan claves de mod que el motor ya entiende.
const BOONS := [
	{"id": "llama_bendita",  "name": "Llama bendita",    "desc": "+30 s de fuego la próxima run",           "mods": {"fire_add": 30}},
	{"id": "manos_diablo",   "name": "Manos del diablo", "desc": "+4 de cocción por clic la próxima run",   "mods": {"cook_add": 4}},
	{"id": "favor_infernal", "name": "Favor infernal",   "desc": "+5 de favor la próxima run",              "mods": {"favor_add": 5}},
	{"id": "piel_azufre",    "name": "Piel de azufre",   "desc": "+80 de vida la próxima run",              "mods": {"max_hp": 80}},
	{"id": "cosecha_rica",   "name": "Cosecha rica",     "desc": "+50% almas la próxima run",               "mods": {"souls_pct": 0.5}},
	{"id": "mano_espectral", "name": "Mano espectral",   "desc": "Auto-cocción +4 / s la próxima run",      "mods": {"autocook_add": 4.0}},
]

static var _bmap := {}


static func boon(id: String) -> Dictionary:
	if _bmap.is_empty():
		for b in BOONS:
			_bmap[b["id"]] = b
	return _bmap.get(id, {})


static func random_boon() -> String:
	return String(BOONS[randi() % BOONS.size()]["id"])


static func _roll_symbol() -> String:
	var total := 0
	for s in SYMBOLS:
		total += int(WEIGHTS[s])
	var r := randi() % total
	for s in SYMBOLS:
		r -= int(WEIGHTS[s])
		if r < 0:
			return String(s)
	return "skull"


static func spin() -> Array:
	var a := _roll_symbol()
	var b := a if randf() < MATCH_BIAS else _roll_symbol()
	var c := a if randf() < MATCH_BIAS else _roll_symbol()
	return [a, b, c]


## Tirada maldita: rodillos amañados para que NUNCA salgan 3 iguales.
static func cursed_reels() -> Array:
	return ["imp", "skull", "imp"]


## Devuelve {kind, ...}. kind ∈ benefit | souls | item | drawback | nada
static func evaluate(reels: Array) -> Dictionary:
	if reels[0] == reels[1] and reels[1] == reels[2]:
		match String(reels[0]):
			"sigil": return {"kind": "benefit", "boon": random_boon()}
			"soul":  return {"kind": "souls", "mult": 1.0}
			"loot":  return {"kind": "item"}
			"imp":   return {"kind": "drawback"}
			_:       return {"kind": "nada"}
	var soul_count := 0
	for x in reels:
		if x == "soul":
			soul_count += 1
	if soul_count == 2:
		return {"kind": "souls", "mult": 0.25}
	return {"kind": "nada"}
