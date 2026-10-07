class_name Items
extends RefCounted
## Objetos equipables por el cocinero. Se consiguen en el botín de los
## demonios. ACUMULATIVOS: te equipas todos los que quieras y las
## estadísticas se suman. Persisten al firmar contratos.
##  mods: max_hp · armor_phys · armor_magic · attack                    (combate)
##        souls_pct · fire_add · cook_add · favor_add · autocook_add
##        item_pct · patience_add · double_pct · dispatch_pct           (economía/gestión)
##        pact_gain_pct · tree_cost_pct · shop_cost_pct · cook_cost_pct
##        cook_rate_pct · max_cooks_add · queue_add                     (contrato/despensa/cocineros)

const LIST := [
	# --- común ---
	{"id": "delantal_cuero",  "name": "Delantal de cuero",       "rarity": "comun", "mods": {"max_hp": 20, "armor_phys": 5}},
	{"id": "manopla_hierro",  "name": "Manopla de hierro",       "rarity": "comun", "mods": {"attack": 4, "armor_phys": 3}},
	{"id": "gorro_lana",      "name": "Gorro de lana raída",     "rarity": "comun", "mods": {"max_hp": 12, "armor_magic": 4}},
	{"id": "cucharon_madera", "name": "Cucharón de madera",      "rarity": "comun", "mods": {"attack": 3, "cook_add": 1}},
	{"id": "botines_hollin",  "name": "Botines de hollín",       "rarity": "comun", "mods": {"max_hp": 15, "patience_add": 1.0}},
	{"id": "panuelo_ceniza",  "name": "Pañuelo de ceniza",       "rarity": "comun", "mods": {"max_hp": 10, "favor_add": 0.5}},
	# --- raro ---
	{"id": "peto_escamas",    "name": "Peto de escamas",         "rarity": "raro", "mods": {"max_hp": 45, "armor_phys": 14}},
	{"id": "guante_amianto",  "name": "Guante de amianto",       "rarity": "raro", "mods": {"attack": 9, "cook_add": 2}},
	{"id": "amuleto_sal",     "name": "Amuleto de sal negra",    "rarity": "raro", "mods": {"armor_magic": 16, "favor_add": 1}},
	{"id": "reloj_roto",      "name": "Reloj de arena roto",     "rarity": "raro", "mods": {"fire_add": 8, "souls_pct": 0.08}},
	{"id": "campana_animas",  "name": "Campana de ánimas",       "rarity": "raro", "mods": {"item_pct": 0.12, "souls_pct": 0.05}},
	{"id": "brasero_bolsillo","name": "Brasero de bolsillo",     "rarity": "raro", "mods": {"autocook_add": 0.8}},
	{"id": "cinturon_cond",   "name": "Cinturón de condenado",   "rarity": "raro", "mods": {"max_hp": 35, "attack": 6}},
	# --- épico ---
	{"id": "coraza_obsidiana","name": "Coraza de obsidiana",     "rarity": "epico", "mods": {"max_hp": 90, "armor_phys": 30, "armor_magic": 12}},
	{"id": "punal_femur",     "name": "Puñal de fémur",          "rarity": "epico", "mods": {"attack": 24, "dispatch_pct": 0.15}},
	{"id": "capa_sombra",     "name": "Capa de sombra",          "rarity": "epico", "mods": {"armor_magic": 34, "max_hp": 30}},
	{"id": "cucharon_femur",  "name": "Cucharón de fémur",       "rarity": "epico", "mods": {"souls_pct": 0.22, "attack": 10}},
	{"id": "corazon_brasa",   "name": "Corazón de brasa",        "rarity": "epico", "mods": {"autocook_add": 1.5, "fire_add": 6}},
	{"id": "libro_contratos", "name": "Libro de contratos menores","rarity": "epico", "mods": {"pact_gain_pct": 0.10}},
	{"id": "campana_grande",  "name": "Campana grande de latón", "rarity": "epico", "mods": {"queue_add": 1}},
	# --- legendario ---
	{"id": "yelmo_cornudo",   "name": "Yelmo cornudo",           "rarity": "legendario", "mods": {"max_hp": 160, "armor_phys": 42, "armor_magic": 42, "attack": 16}},
	{"id": "guantelete_belial","name": "Guantelete de Belial",  "rarity": "legendario", "mods": {"attack": 65, "dispatch_pct": 0.30}},
	{"id": "manto_mammon",    "name": "Manto de Mammón",         "rarity": "legendario", "mods": {"souls_pct": 0.55, "max_hp": 60}},
	{"id": "reloj_asmodeo",   "name": "Reloj de Asmodeo",        "rarity": "legendario", "mods": {"fire_add": 40, "patience_add": 3.0}},
	{"id": "corona_menor",    "name": "Corona menor de Belfegor","rarity": "legendario", "mods": {"souls_pct": 0.35, "favor_add": 2}},
	{"id": "guante_maestro",  "name": "Guante de cocinero maestro","rarity": "legendario", "mods": {"cook_rate_pct": 0.30, "max_cooks_add": 1}},
	{"id": "escudo_animas",   "name": "Escudo de ánimas atrapadas","rarity": "legendario", "mods": {"armor_phys": 60, "armor_magic": 60}},
	# --- mítico ---
	{"id": "ojo_astaroth",    "name": "Ojo de Astaroth",         "rarity": "mitico", "mods": {"favor_add": 5, "item_pct": 0.15}},
	{"id": "espada_moloch",   "name": "Espada de Moloch",        "rarity": "mitico", "mods": {"attack": 200, "dispatch_pct": 0.50}},
	{"id": "manto_belcebu",   "name": "Manto de Belcebú",        "rarity": "mitico", "mods": {"max_hp": 300, "armor_magic": 90}},
	{"id": "corazon_leviatan","name": "Corazón de Leviatán",     "rarity": "mitico", "mods": {"max_hp": 250, "armor_phys": 90}},
	{"id": "reloj_infinito",  "name": "Reloj infinito",          "rarity": "mitico", "mods": {"fire_add": 60, "patience_add": 4.0}},
	{"id": "grimorio_pactos", "name": "Grimorio de pactos",      "rarity": "mitico", "mods": {"pact_gain_pct": 0.30, "tree_cost_pct": 0.10}},
	{"id": "cetro_avaricia",  "name": "Cetro de la avaricia",    "rarity": "mitico", "mods": {"souls_pct": 0.90, "shop_cost_pct": 0.15}},
	# --- infernal ---
	{"id": "corona_cocinero", "name": "Corona del Cocinero",     "rarity": "infernal", "mods": {"max_hp": 450, "armor_phys": 85, "armor_magic": 85, "attack": 130, "souls_pct": 1.0}},
	{"id": "corazon_lucifer", "name": "Corazón de Lucifer",      "rarity": "infernal", "mods": {"souls_pct": 1.5, "attack": 300, "max_hp": 500}},
	{"id": "llave_abismo",    "name": "Llave del abismo",        "rarity": "infernal", "mods": {"max_cooks_add": 3, "cook_rate_pct": 0.50}},
	{"id": "sello_supremo",   "name": "Sello supremo del pacto", "rarity": "infernal", "mods": {"pact_gain_pct": 0.75, "tree_cost_pct": 0.20, "shop_cost_pct": 0.20, "cook_cost_pct": 0.20}},
]

const _R := ["comun", "raro", "epico", "legendario", "mitico", "infernal"]
static var _map := {}


static func by_id(id: String) -> Dictionary:
	if _map.is_empty():
		for it in LIST:
			_map[it["id"]] = it
	return _map.get(id, {})


static func describe(it: Dictionary) -> String:
	var parts: Array = []
	var names := {
		"max_hp": "+%s vida", "armor_phys": "+%s arm. física", "armor_magic": "+%s arm. mágica",
		"attack": "+%s ataque", "cook_add": "+%s cocción/clic", "fire_add": "+%s s fuego",
		"autocook_add": "+%s auto-cocción/s", "favor_add": "+%s favor", "patience_add": "+%s s paciencia",
		"queue_add": "+%s a la cola visible", "max_cooks_add": "+%s cocineros máximo",
	}
	var pcts := {
		"souls_pct": "almas", "item_pct": "prob. objeto", "double_pct": "ración doble",
		"dispatch_pct": "almas al despachar", "pact_gain_pct": "poder de firma",
		"tree_cost_pct": "coste del árbol", "shop_cost_pct": "coste de la Despensa",
		"cook_cost_pct": "coste de cocineros", "cook_rate_pct": "producción de cocineros",
	}
	for k in it.get("mods", {}):
		var v = it["mods"][k]
		if names.has(k):
			parts.append(names[k] % Nums.fmt(float(v)))
		elif pcts.has(k):
			parts.append("+%d%% %s" % [int(round(float(v) * 100.0)), pcts[k]])
	return "  ·  ".join(parts)


## Rangos de objeto que puede soltar un demonio de rareza `dr`.
static func _pool_for(dr: String) -> Array:
	var i: int = _R.find(dr)
	if i < 0:
		i = 0
	var lo: int = maxi(0, i - 1)
	var out: Array = []
	for it in LIST:
		var ri: int = _R.find(it["rarity"])
		if ri >= lo and ri <= i:
			out.append(it["id"])
	return out


static func roll_drop(demon_rarity: String, owned: Dictionary) -> String:
	var pool := _pool_for(demon_rarity)
	pool.shuffle()
	for id in pool:
		if not owned.has(id):
			return id
	return ""   # ya los tienes todos de ese rango
