class_name Decor
extends RefCounted
## Objetos decorativos del local. Suben las ESTRELLAS del restaurante.
## A más estrellas, vienen demonios de mayor rango y con más favor.
## Se consiguen comprándolos en la Despensa (los baratos) o en el botín
## (los buenos, cuanto más raro el demonio más probable).

const LIST := [
	{"id": "velas",       "name": "Velas negras",                    "stars": 0.3, "rarity": "comun",      "cost": 200.0},
	{"id": "alfombra",    "name": "Alfombra de piel roja",            "stars": 0.5, "rarity": "comun",      "cost": 550.0},
	{"id": "manteles",    "name": "Manteles de arpillera",            "stars": 0.4, "rarity": "comun",      "cost": 380.0},
	{"id": "farolillos",  "name": "Farolillos de hueso",              "stars": 0.6, "rarity": "comun",      "cost": 900.0},
	{"id": "arana",       "name": "Araña de huesos",                  "stars": 0.7, "rarity": "raro",       "cost": 2200.0},
	{"id": "retrato",     "name": "Retrato del propietario",          "stars": 0.9, "rarity": "raro",       "cost": 6500.0},
	{"id": "brasero_dec", "name": "Brasero decorativo",               "stars": 0.8, "rarity": "raro",       "cost": 4200.0},
	{"id": "tapiz",       "name": "Tapiz de piel de sabueso",         "stars": 1.0, "rarity": "raro",       "cost": 9000.0},
	{"id": "candelabro",  "name": "Candelabro de fémures",            "stars": 1.2, "rarity": "epico",      "cost": 0.0},
	{"id": "vitrina",     "name": "Vitrina de cabezas",               "stars": 1.4, "rarity": "epico",      "cost": 0.0},
	{"id": "mantel",      "name": "Mantelería de seda de araña",      "stars": 1.2, "rarity": "epico",      "cost": 0.0},
	{"id": "acuario",     "name": "Acuario de almas en pena",         "stars": 1.5, "rarity": "epico",      "cost": 0.0},
	{"id": "reloj_grande","name": "Reloj de pie infernal",            "stars": 1.6, "rarity": "epico",      "cost": 0.0},
	{"id": "fuente",      "name": "Fuente de sangre",                 "stars": 1.8, "rarity": "legendario", "cost": 0.0},
	{"id": "estrella",    "name": "Estrella robada de una guía",      "stars": 2.2, "rarity": "legendario", "cost": 0.0},
	{"id": "organo",      "name": "Órgano de tubos de hueso",         "stars": 2.0, "rarity": "legendario", "cost": 0.0},
	{"id": "jardin",      "name": "Jardín de brasas colgantes",       "stars": 2.4, "rarity": "legendario", "cost": 0.0},
	{"id": "cripta",      "name": "Cripta VIP con reservas",          "stars": 2.8, "rarity": "mitico",     "cost": 0.0},
	{"id": "estatua",     "name": "Estatua viviente de un cliente",   "stars": 3.0, "rarity": "mitico",     "cost": 0.0},
	{"id": "lampara_alma","name": "Lámpara de mil almas",             "stars": 3.2, "rarity": "mitico",     "cost": 0.0},
	{"id": "puerta_abismo","name": "Puerta al abismo (decorativa)",   "stars": 3.5, "rarity": "mitico",     "cost": 0.0},
	{"id": "trono",       "name": "Trono de cráneos",                 "stars": 4.0, "rarity": "infernal",   "cost": 0.0},
	{"id": "reliquia_neg","name": "Reliquia negra sin nombre",        "stars": 4.5, "rarity": "infernal",   "cost": 0.0},
	{"id": "corona_local","name": "Corona colgada del techo",         "stars": 5.0, "rarity": "infernal",   "cost": 0.0},
	# --- ampliación ---
	{"id": "cortinas_negras",  "name": "Cortinas de tela negra",             "stars": 0.4, "rarity": "comun",      "cost": 300.0},
	{"id": "cadenas_pared",    "name": "Cadenas colgadas de la pared",       "stars": 0.5, "rarity": "comun",      "cost": 420.0},
	{"id": "cartel_neon",      "name": "Cartel de neón infernal",            "stars": 0.6, "rarity": "raro",       "cost": 1600.0},
	{"id": "incensario",       "name": "Incensario de azufre",               "stars": 0.7, "rarity": "raro",       "cost": 2600.0},
	{"id": "gong_entrada",     "name": "Gong de entrada",                    "stars": 0.9, "rarity": "raro",       "cost": 5200.0},
	{"id": "libreria_prohibida","name": "Librería de grimorios prohibidos",  "stars": 1.3, "rarity": "epico",      "cost": 0.0},
	{"id": "pecera_almas",     "name": "Pecera de almas nadadoras",          "stars": 1.5, "rarity": "epico",      "cost": 0.0},
	{"id": "chimenea_negra",   "name": "Chimenea de fuego negro",            "stars": 1.7, "rarity": "epico",      "cost": 0.0},
	{"id": "cabeza_disecada",  "name": "Cabeza de demonio disecada",         "stars": 1.6, "rarity": "epico",      "cost": 0.0},
	{"id": "escaleras_talladas","name": "Escaleras talladas en hueso",       "stars": 1.9, "rarity": "epico",      "cost": 0.0},
	{"id": "mural_pecados",    "name": "Mural de los siete pecados",         "stars": 2.1, "rarity": "epico",      "cost": 0.0},
	{"id": "lampara_eterna",   "name": "Lámpara de fuego eterno",            "stars": 2.3, "rarity": "legendario", "cost": 0.0},
	{"id": "foso_lava",        "name": "Foso de lava decorativo",            "stars": 2.5, "rarity": "legendario", "cost": 0.0},
	{"id": "campana_condenados","name": "Campana de los condenados",        "stars": 2.7, "rarity": "legendario", "cost": 0.0},
	{"id": "vidriera_infernal","name": "Vidriera con escenas infernales",    "stars": 2.9, "rarity": "legendario", "cost": 0.0},
	{"id": "reloj_arena_alma", "name": "Reloj de arena de almas",            "stars": 3.1, "rarity": "legendario", "cost": 0.0},
	{"id": "trono_menor",      "name": "Trono menor de un archiduque",       "stars": 3.3, "rarity": "mitico",     "cost": 0.0},
	{"id": "portal_diminuto",  "name": "Portal diminuto siempre abierto",    "stars": 3.6, "rarity": "mitico",     "cost": 0.0},
	{"id": "orbe_profecia",    "name": "Orbe de la profecía",                "stars": 3.8, "rarity": "mitico",     "cost": 0.0},
	{"id": "jaula_alma_mayor", "name": "Jaula de un alma mayor",             "stars": 4.0, "rarity": "mitico",     "cost": 0.0},
	{"id": "espejo_verdad",    "name": "Espejo que muestra la verdad",       "stars": 4.3, "rarity": "mitico",     "cost": 0.0},
	{"id": "ala_caida",        "name": "Ala de un ángel caído",              "stars": 5.4, "rarity": "infernal",   "cost": 0.0},
	{"id": "sello_salomon",    "name": "Sello roto de Salomón",              "stars": 6.0, "rarity": "infernal",   "cost": 0.0},
	{"id": "llave_abismo",     "name": "Llave que abre el abismo",           "stars": 6.8, "rarity": "infernal",   "cost": 0.0},
	{"id": "corazon_forjado",  "name": "Corazón forjado en pecado",          "stars": 7.6, "rarity": "infernal",   "cost": 0.0},
	{"id": "cetro_roto",       "name": "Cetro roto de un rey caído",         "stars": 8.5, "rarity": "infernal",   "cost": 0.0},
	{"id": "trono_definitivo", "name": "El Trono Definitivo",                "stars": 9.5, "rarity": "infernal",   "cost": 0.0},
]

const STAR_CAP := 110.0
static var _map := {}


static func by_id(id: String) -> Dictionary:
	if _map.is_empty():
		for d in LIST:
			_map[d["id"]] = d
	return _map.get(id, {})


static func total_stars(owned: Dictionary) -> float:
	var t := 0.0
	for id in owned:
		t += float(by_id(id).get("stars", 0.0))
	return minf(STAR_CAP, t)


## Reparte estrellas en 0..5 llenas (para pintar ★).
static func star_pips(stars: float) -> int:
	return int(clampf(round(stars / STAR_CAP * 5.0), 0.0, 5.0))


## Decoración que aún no tienes, de rareza `max_rarity` o menor (los demonios
## pequeños no sueltan las piezas grandes). Sin rareza: cualquiera.
static func random_undropped(owned: Dictionary, max_rarity := "") -> String:
	var top := Demons.RARITY_ORDER.find(max_rarity) if max_rarity != "" else 99
	var pool: Array = []
	for d in LIST:
		if not owned.has(d["id"]) and Demons.RARITY_ORDER.find(d["rarity"]) <= top:
			pool.append(d["id"])
	if pool.is_empty():
		return ""
	return pool[randi() % pool.size()]
