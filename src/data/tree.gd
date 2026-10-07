class_name SkillTree
extends RefCounted
## Árbol de habilidades con forma de PENTAGRAMA. Las propias cadenas de nodos
## trazan la estrella de 5 puntas: 5 ramas recorren las 5 líneas del pentagrama
## (de punta a punta), y la 6ª rama ("alma") rodea el pentágono exterior. Se
## compra con almas y es PERMANENTE. Pantalla completa entre runs.
##  Cada nodo: id, name, desc, cost, mods (misma forma que los objetos),
##             parent, p (posición en el lienzo del árbol).

const ROOT_COST := 6.0
## Coste de cada nodo según su POSICIÓN en la cadena de la rama (sub-rama A
## y luego B, 28 nodos): 14 · 2,67^i. La B cuelga del último nodo de la A, así
## que sigue encareciéndose en vez de volver a empezar barata.
const SUB_COST := [
	14.0, 37.0, 100.0, 270.0, 710.0, 1900.0, 5100.0,
	14000.0, 36000.0, 97000.0, 260000.0, 690000.0, 1.8e6, 4.9e6,
	1.3e7, 3.5e7, 9.3e7, 2.5e8, 6.7e8, 1.8e9, 4.7e9,
	1.3e10, 3.4e10, 9e10, 2.4e11, 6.4e11, 1.7e12, 4.6e12,
]

## Radio de las 5 puntas del pentagrama (desde el fogón central).
const TIP_R := 560.0
## Qué línea recorre cada rama: [puntaA, puntaB] para las 5 líneas de la
## estrella, o "ring" para la rama que rodea el pentágono exterior. Las 5
## líneas comparten puntas, así que las cadenas de nodos cierran la estrella.
const LAYOUT := {
	"llama":  [0, 2],
	"piel":   [2, 4],
	"gula":   [4, 1],
	"carne":  [1, 3],
	"hambre": [3, 0],
	"alma":   "ring",
}

const DEF := [
	{
		"key": "llama", "title": "Llama",
		"root": {"n": "Fuego vivo", "d": "+10 s de fuego · +5% almas", "m": {"fire_add": 10, "souls_pct": 0.05}},
		"a": {"title": "Brasas", "nodes": [
			{"n": "Rescoldos",        "d": "Auto-cocción +0,5 / s",     "m": {"autocook_add": 0.5}},
			{"n": "Ascuas",           "d": "+2 de cocción por clic",    "m": {"cook_add": 2}},
			{"n": "Horno perpetuo",   "d": "Auto-cocción +1,5 / s",     "m": {"autocook_add": 1.5}},
			{"n": "Infierno portátil","d": "+16 s de fuego",            "m": {"fire_add": 16}},
			{"n": "Forja viva",       "d": "Auto-cocción +3 / s",       "m": {"autocook_add": 3.0}},
			{"n": "Núcleo de magma",  "d": "+4 de cocción por clic",    "m": {"cook_add": 4}},
			{"n": "Volcán de bolsillo","d": "Auto-cocción +5 / s",      "m": {"autocook_add": 5.0}},
			{"n": "Corazón del abismo","d": "+7 de cocción por clic",   "m": {"cook_add": 7}},
			{"n": "Rescoldo eterno",  "d": "Auto-cocción +9 / s",       "m": {"autocook_add": 9.0}},
			{"n": "Núcleo ardiente",  "d": "+10 de cocción por clic",   "m": {"cook_add": 10}},
			{"n": "Forja del abismo", "d": "Auto-cocción +14 / s",      "m": {"autocook_add": 14.0}},
			{"n": "Corona de fuego",  "d": "+24 s de fuego",            "m": {"fire_add": 24}},
			{"n": "Motor infernal",   "d": "Auto-cocción +20 / s",      "m": {"autocook_add": 20.0}},
			{"n": "Yunque de brasas", "d": "+16 de cocción por clic",   "m": {"cook_add": 16}},
		]},
		"b": {"title": "Codicia", "nodes": [
			{"n": "Diezmo",           "d": "+15% almas",                "m": {"souls_pct": 0.15}},
			{"n": "Usura",            "d": "+25% almas",                "m": {"souls_pct": 0.25}},
			{"n": "Ojo del avaro",    "d": "Favor +2",                  "m": {"favor_add": 2}},
			{"n": "Arcas del abismo", "d": "+45% almas",                "m": {"souls_pct": 0.45}},
			{"n": "Diezmo del rey",   "d": "+40% almas",                "m": {"souls_pct": 0.40}},
			{"n": "Sed insaciable",   "d": "Favor +3",                  "m": {"favor_add": 3}},
			{"n": "Tesoro maldito",   "d": "+60% almas",                "m": {"souls_pct": 0.60}},
			{"n": "Rey Midas infernal","d": "+80% almas",               "m": {"souls_pct": 0.80}},
			{"n": "Tesorero infernal","d": "+100% almas",               "m": {"souls_pct": 1.00}},
			{"n": "Pacto de Mammón",  "d": "Favor +4",                  "m": {"favor_add": 4}},
			{"n": "Avaricia eterna",  "d": "+130% almas",               "m": {"souls_pct": 1.30}},
			{"n": "Corona de oro negro","d": "Favor +5",                "m": {"favor_add": 5}},
			{"n": "Imperio de la codicia","d": "+170% almas",           "m": {"souls_pct": 1.70}},
			{"n": "El Banquero del Abismo","d": "+220% almas",          "m": {"souls_pct": 2.20}},
		]},
	},
	{
		"key": "carne", "title": "Carne",
		"root": {"n": "Filo", "d": "+6 de ataque", "m": {"attack": 6}},
		"a": {"title": "Verdugo", "nodes": [
			{"n": "Tajo limpio",      "d": "+12 de ataque",             "m": {"attack": 12}},
			{"n": "Despacho exprés",  "d": "+15% almas al despachar",   "m": {"dispatch_pct": 0.15}},
			{"n": "Verdugo",          "d": "+32 de ataque",             "m": {"attack": 32}},
			{"n": "Sin piedad",       "d": "+40% almas al despachar",   "m": {"dispatch_pct": 0.40}},
			{"n": "Decapitación",     "d": "+60 de ataque",             "m": {"attack": 60}},
			{"n": "Cosecha de almas", "d": "+60% almas al despachar",   "m": {"dispatch_pct": 0.60}},
			{"n": "Ejecución sumaria","d": "+110 de ataque",            "m": {"attack": 110}},
			{"n": "Recolector de almas","d": "+90% almas al despachar", "m": {"dispatch_pct": 0.90}},
			{"n": "Guillotina",       "d": "+170 de ataque",            "m": {"attack": 170}},
			{"n": "Purga total",      "d": "+120% almas al despachar",  "m": {"dispatch_pct": 1.20}},
			{"n": "Hacha bendita por el mal","d": "+260 de ataque",     "m": {"attack": 260}},
			{"n": "Condena eterna",   "d": "+160% almas al despachar",  "m": {"dispatch_pct": 1.60}},
			{"n": "Filo del juicio final","d": "+400 de ataque",        "m": {"attack": 400}},
			{"n": "El Verdugo Supremo","d": "+220% almas al despachar", "m": {"dispatch_pct": 2.20}},
		]},
		"b": {"title": "Carnicero", "nodes": [
			{"n": "Machete",          "d": "+10 de ataque",             "m": {"attack": 10}},
			{"n": "Descuartizar",     "d": "+18 de ataque · +2 cocción","m": {"attack": 18, "cook_add": 2}},
			{"n": "Gancho",           "d": "+48 de ataque",             "m": {"attack": 48}},
			{"n": "Matarife",         "d": "+90 de ataque",             "m": {"attack": 90}},
			{"n": "Sierra de huesos", "d": "+70 de ataque",             "m": {"attack": 70}},
			{"n": "Jefe de matadero", "d": "+140 de ataque",            "m": {"attack": 140}},
			{"n": "Descuartizador supremo","d": "+220 de ataque",       "m": {"attack": 220}},
			{"n": "Carnicero real",   "d": "+380 de ataque",            "m": {"attack": 380}},
			{"n": "Cuchilla ritual",  "d": "+260 de ataque",            "m": {"attack": 260}},
			{"n": "Trinchador",       "d": "+320 de ataque · +5 cocción","m": {"attack": 320, "cook_add": 5}},
			{"n": "Sierra infernal",  "d": "+420 de ataque",            "m": {"attack": 420}},
			{"n": "Maestro carnicero","d": "+600 de ataque",            "m": {"attack": 600}},
			{"n": "Fauces de hierro", "d": "+820 de ataque",            "m": {"attack": 820}},
			{"n": "El Carnicero Eterno","d": "+1150 de ataque",         "m": {"attack": 1150}},
		]},
	},
	{
		"key": "piel", "title": "Piel",
		"root": {"n": "Callo", "d": "+30 de vida", "m": {"max_hp": 30}},
		"a": {"title": "Placa", "nodes": [
			{"n": "Peto",             "d": "+15 armadura física",       "m": {"armor_phys": 15}},
			{"n": "Yelmo",            "d": "+45 vida · +10 arm. física","m": {"max_hp": 45, "armor_phys": 10}},
			{"n": "Muro de acero",    "d": "+38 armadura física",       "m": {"armor_phys": 38}},
			{"n": "Fortaleza",        "d": "+140 de vida",              "m": {"max_hp": 140}},
			{"n": "Bastión",          "d": "+55 armadura física",       "m": {"armor_phys": 55}},
			{"n": "Coloso",           "d": "+240 de vida",              "m": {"max_hp": 240}},
			{"n": "Baluarte",         "d": "+85 armadura física",       "m": {"armor_phys": 85}},
			{"n": "Titán de hierro",  "d": "+380 de vida",              "m": {"max_hp": 380}},
			{"n": "Coraza sellada",   "d": "+120 armadura física",      "m": {"armor_phys": 120}},
			{"n": "Muralla viviente", "d": "+520 de vida",              "m": {"max_hp": 520}},
			{"n": "Escama de dragón", "d": "+170 armadura física",      "m": {"armor_phys": 170}},
			{"n": "Gigante de piedra","d": "+820 de vida",              "m": {"max_hp": 820}},
			{"n": "Bastión inquebrantable","d": "+230 armadura física", "m": {"armor_phys": 230}},
			{"n": "El Titán Eterno",  "d": "+1300 de vida",             "m": {"max_hp": 1300}},
		]},
		"b": {"title": "Velo", "nodes": [
			{"n": "Runa",             "d": "+18 armadura mágica",       "m": {"armor_magic": 18}},
			{"n": "Amuleto",          "d": "+45 vida · +12 arm. mágica","m": {"max_hp": 45, "armor_magic": 12}},
			{"n": "Velo de sombra",   "d": "+42 armadura mágica",       "m": {"armor_magic": 42}},
			{"n": "Bendición impía",  "d": "+30 a ambas armaduras",     "m": {"armor_phys": 30, "armor_magic": 30}},
			{"n": "Manto arcano",     "d": "+58 armadura mágica",       "m": {"armor_magic": 58}},
			{"n": "Égida impía",      "d": "+48 a ambas armaduras",     "m": {"armor_phys": 48, "armor_magic": 48}},
			{"n": "Sello arcano",     "d": "+90 armadura mágica",       "m": {"armor_magic": 90}},
			{"n": "Aura suprema",     "d": "+75 a ambas armaduras",     "m": {"armor_phys": 75, "armor_magic": 75}},
			{"n": "Runa mayor",       "d": "+130 armadura mágica",      "m": {"armor_magic": 130}},
			{"n": "Talismán eterno",  "d": "+180 vida · +40 arm. mágica","m": {"max_hp": 180, "armor_magic": 40}},
			{"n": "Velo del vacío",   "d": "+190 armadura mágica",      "m": {"armor_magic": 190}},
			{"n": "Bendición suprema","d": "+110 a ambas armaduras",    "m": {"armor_phys": 110, "armor_magic": 110}},
			{"n": "Manto del abismo", "d": "+260 armadura mágica",      "m": {"armor_magic": 260}},
			{"n": "La Égida Final",   "d": "+180 a ambas armaduras",    "m": {"armor_phys": 180, "armor_magic": 180}},
		]},
	},
	{
		"key": "hambre", "title": "Hambre",
		"root": {"n": "Anfitrión", "d": "+1,5 s de paciencia", "m": {"patience_add": 1.5}},
		"a": {"title": "Paciencia", "nodes": [
			{"n": "Sala de espera",   "d": "+2 s de paciencia",         "m": {"patience_add": 2.0}},
			{"n": "Modales",          "d": "Los impacientes pegan −25%","m": {"impatient_reduce": 0.25}},
			{"n": "Zen infernal",     "d": "+3 s de paciencia",         "m": {"patience_add": 3.0}},
			{"n": "Purgatorio",       "d": "Los impacientes pegan −40%","m": {"impatient_reduce": 0.40}},
			{"n": "Limbo",            "d": "+4 s de paciencia",         "m": {"patience_add": 4.0}},
			{"n": "Serenidad",        "d": "Los impacientes pegan −55%","m": {"impatient_reduce": 0.55}},
			{"n": "Eternidad",        "d": "+5 s de paciencia",         "m": {"patience_add": 5.0}},
			{"n": "Nirvana infernal", "d": "Los impacientes pegan −70%","m": {"impatient_reduce": 0.70}},
			{"n": "Calma absoluta",   "d": "+6 s de paciencia",         "m": {"patience_add": 6.0}},
			{"n": "Último resquicio de piedad","d": "Los impacientes pegan −80% (máximo)","m": {"impatient_reduce": 0.10}},
			{"n": "Paz eterna",       "d": "+7 s de paciencia",         "m": {"patience_add": 7.0}},
			{"n": "Meditación abismal","d": "+8 s de paciencia",        "m": {"patience_add": 8.0}},
			{"n": "Trance infernal",  "d": "+9 s de paciencia",         "m": {"patience_add": 9.0}},
			{"n": "El Silencio Final","d": "+10 s de paciencia",        "m": {"patience_add": 10.0}},
		]},
		"b": {"title": "Festín", "nodes": [
			{"n": "Ración doble",     "d": "+8% de servir a dos",       "m": {"double_pct": 0.08}},
			{"n": "Banquete",         "d": "+12% doble · +10% objeto",  "m": {"double_pct": 0.12, "item_pct": 0.10}},
			{"n": "Mano rápida",      "d": "+15% de servir a dos",      "m": {"double_pct": 0.15}},
			{"n": "Cornucopia impía", "d": "+20% objeto · +15% almas",  "m": {"item_pct": 0.20, "souls_pct": 0.15}},
			{"n": "Bacanal",          "d": "+18% de servir a dos",      "m": {"double_pct": 0.18}},
			{"n": "Cuerno de abundancia","d": "+30% objeto · +25% almas","m": {"item_pct": 0.30, "souls_pct": 0.25}},
			{"n": "Festín eterno",    "d": "+25% de servir a dos",      "m": {"double_pct": 0.25}},
			{"n": "Abundancia total", "d": "+45% objeto · +40% almas",  "m": {"item_pct": 0.45, "souls_pct": 0.40}},
			{"n": "Cornucopia eterna","d": "+35% objeto · +30% almas",  "m": {"item_pct": 0.35, "souls_pct": 0.30}},
			{"n": "Última ración",    "d": "+5% de servir a dos",       "m": {"double_pct": 0.05}},
			{"n": "Festín interminable","d": "+50% objeto · +45% almas","m": {"item_pct": 0.50, "souls_pct": 0.45}},
			{"n": "Saciedad imposible","d": "+65% objeto",              "m": {"item_pct": 0.65}},
			{"n": "El Banquete Eterno","d": "+70% almas",               "m": {"souls_pct": 0.70}},
			{"n": "Hambre Insaciable del Abismo","d": "+90% objeto · +90% almas","m": {"item_pct": 0.90, "souls_pct": 0.90}},
		]},
	},
	{
		"key": "alma", "title": "Alma",
		"root": {"n": "Chispa de alma", "d": "+10% poder de firma (contrato más barato)", "m": {"pact_gain_pct": 0.10}},
		"a": {"title": "Contrato eterno", "nodes": [
			{"n": "Letra pequeña",    "d": "−5% coste del árbol",       "m": {"tree_cost_pct": 0.05}},
			{"n": "Cláusula oscura",  "d": "+15% poder de firma (contrato más barato)",       "m": {"pact_gain_pct": 0.15}},
			{"n": "Notario del abismo","d": "−8% coste del árbol",      "m": {"tree_cost_pct": 0.08}},
			{"n": "Pacto de sangre",  "d": "+25% poder de firma (contrato más barato)",       "m": {"pact_gain_pct": 0.25}},
			{"n": "Sello infernal",   "d": "−12% coste del árbol",      "m": {"tree_cost_pct": 0.12}},
			{"n": "Contrato eterno",  "d": "+40% poder de firma (contrato más barato)",       "m": {"pact_gain_pct": 0.40}},
			{"n": "Abogado del diablo","d": "−18% coste del árbol",     "m": {"tree_cost_pct": 0.18}},
			{"n": "Pacto supremo",    "d": "+60% poder de firma (contrato más barato)",       "m": {"pact_gain_pct": 0.60}},
			{"n": "Cláusula final",   "d": "−10% coste del árbol",      "m": {"tree_cost_pct": 0.10}},
			{"n": "Pacto de sangre eterna","d": "+80% poder de firma (contrato más barato)",  "m": {"pact_gain_pct": 0.80}},
			{"n": "Sello del abismo", "d": "−8% coste del árbol",       "m": {"tree_cost_pct": 0.08}},
			{"n": "Contrato irrevocable","d": "+120% poder de firma (contrato más barato)",   "m": {"pact_gain_pct": 1.20}},
			{"n": "Última firma",     "d": "−10% coste del árbol",      "m": {"tree_cost_pct": 0.10}},
			{"n": "El Pacto Definitivo","d": "+180% poder de firma (contrato más barato)",    "m": {"pact_gain_pct": 1.80}},
		]},
		"b": {"title": "Favor real", "nodes": [
			{"n": "Encanto",          "d": "+20% favor por estrella",   "m": {"star_favor_mult": 0.20}},
			{"n": "Carisma infernal", "d": "−10% coste de la Despensa", "m": {"shop_cost_pct": 0.10}},
			{"n": "Prestigio",        "d": "+30% favor por estrella",   "m": {"star_favor_mult": 0.30}},
			{"n": "Renombre",        "d": "−15% coste de cocineros",    "m": {"cook_cost_pct": 0.15}},
			{"n": "Leyenda viva",     "d": "+45% favor por estrella",   "m": {"star_favor_mult": 0.45}},
			{"n": "Culto personal",   "d": "−20% coste de la Despensa", "m": {"shop_cost_pct": 0.20}},
			{"n": "Ídolo del abismo", "d": "+65% favor por estrella",   "m": {"star_favor_mult": 0.65}},
			{"n": "Emperador del inframundo","d": "−25% coste de cocineros","m": {"cook_cost_pct": 0.25}},
			{"n": "Encanto supremo",  "d": "+90% favor por estrella",   "m": {"star_favor_mult": 0.90}},
			{"n": "Monopolio infernal","d": "−15% coste de la Despensa","m": {"shop_cost_pct": 0.15}},
			{"n": "Aura de leyenda",  "d": "+120% favor por estrella",  "m": {"star_favor_mult": 1.20}},
			{"n": "Servidumbre eterna","d": "−20% coste de cocineros",  "m": {"cook_cost_pct": 0.20}},
			{"n": "El Ídolo Eterno",  "d": "+160% favor por estrella",  "m": {"star_favor_mult": 1.60}},
			{"n": "Emperador Supremo del Abismo","d": "−15% Despensa · −10% cocineros","m": {"shop_cost_pct": 0.15, "cook_cost_pct": 0.10}},
		]},
	},
	{
		"key": "gula", "title": "Gula",
		"root": {"n": "Apetito", "d": "+1 cocinero máximo", "m": {"max_cooks_add": 1}},
		"a": {"title": "Banquete sin fin", "nodes": [
			{"n": "Segundo plato",    "d": "+1 cocinero máximo",        "m": {"max_cooks_add": 1}},
			{"n": "Ración extra",     "d": "+15% producción de cocineros","m": {"cook_rate_pct": 0.15}},
			{"n": "Tercer plato",     "d": "+1 cocinero máximo",        "m": {"max_cooks_add": 1}},
			{"n": "Mesa larga",       "d": "+25% producción de cocineros","m": {"cook_rate_pct": 0.25}},
			{"n": "Cuarto plato",     "d": "+2 cocineros máximo",       "m": {"max_cooks_add": 2}},
			{"n": "Atracón",          "d": "+40% producción de cocineros","m": {"cook_rate_pct": 0.40}},
			{"n": "Banquete sin fin", "d": "+2 cocineros máximo",       "m": {"max_cooks_add": 2}},
			{"n": "Glotonería suprema","d": "+70% producción de cocineros","m": {"cook_rate_pct": 0.70}},
			{"n": "Quinto plato",     "d": "+2 cocineros máximo",       "m": {"max_cooks_add": 2}},
			{"n": "Ración divina",    "d": "+50% producción de cocineros","m": {"cook_rate_pct": 0.50}},
			{"n": "Sexto plato",      "d": "+2 cocineros máximo",       "m": {"max_cooks_add": 2}},
			{"n": "Manjar infinito",  "d": "+80% producción de cocineros","m": {"cook_rate_pct": 0.80}},
			{"n": "Séptimo plato",    "d": "+3 cocineros máximo",       "m": {"max_cooks_add": 3}},
			{"n": "El Banquete Sin Fin Eterno","d": "+120% producción de cocineros","m": {"cook_rate_pct": 1.20}},
		]},
		"b": {"title": "Ojo que todo ve", "nodes": [
			{"n": "Vistazo",          "d": "+1 a la cola visible",      "m": {"queue_add": 1}},
			{"n": "Presagio",         "d": "El primer demonio del turno es raro o mejor", "m": {"first_rare": 1}},
			{"n": "Ojo que todo ve",  "d": "+1 a la cola visible",      "m": {"queue_add": 1}},
			{"n": "Oráculo",          "d": "−10% cocción necesaria",    "m": {"cook_need_pct": 0.10}},
			{"n": "Clarividencia",    "d": "+1 a la cola visible",      "m": {"queue_add": 1}},
			{"n": "Premonición",      "d": "−18% cocción necesaria",    "m": {"cook_need_pct": 0.18}},
			{"n": "Visión total",     "d": "+2 a la cola visible",      "m": {"queue_add": 2}},
			{"n": "Omnisciencia",     "d": "−28% cocción necesaria",    "m": {"cook_need_pct": 0.28}},
			{"n": "Presciencia",      "d": "+2 a la cola visible",      "m": {"queue_add": 2}},
			{"n": "Visión absoluta",  "d": "−14% cocción necesaria (máximo)","m": {"cook_need_pct": 0.14}},
			{"n": "El Ojo Final",     "d": "+2 a la cola visible",      "m": {"queue_add": 2}},
			{"n": "Ojo del abismo",   "d": "+2 a la cola visible",      "m": {"queue_add": 2}},
			{"n": "Vidente eterno",   "d": "+3 a la cola visible",      "m": {"queue_add": 3}},
			{"n": "La Omnisciencia Total","d": "+3 a la cola visible",  "m": {"queue_add": 3}},
		]},
	},
]

const ORDER := ["llama", "carne", "piel", "hambre", "alma", "gula"]

static var _nodes := []
static var _by_id := {}
static var _built := false


static func _polar(deg: float, rad: float) -> Vector2:
	var a := deg_to_rad(deg)
	return Vector2(cos(a), sin(a)) * rad


## Punta i (0..4) del pentagrama. Punta 0 arriba, luego en sentido horario.
static func _tip(i: int) -> Vector2:
	return _polar(-90.0 + 72.0 * float(((i % 5) + 5) % 5), TIP_R)


## Punto p (0..1) recorriendo el perímetro del pentágono: tip0→tip1→…→tip4→tip0.
static func _point_on_ring(p: float) -> Vector2:
	var seg := fposmod(p, 1.0) * 5.0
	var i := int(floor(seg))
	var f := seg - float(i)
	return _tip(i).lerp(_tip(i + 1), f)


static func _build() -> void:
	if _built:
		return
	_built = true
	for ri in DEF.size():
		var b: Dictionary = DEF[ri]
		var key := String(b["key"])
		var lay: Variant = LAYOUT.get(key, [0, 2])
		var is_ring := (typeof(lay) == TYPE_STRING)
		var pa := 0
		var pb := 0
		if not is_ring:
			pa = int((lay as Array)[0])
			pb = int((lay as Array)[1])
		var total := int(b["a"]["nodes"].size()) + int(b["b"]["nodes"].size())

		var root_pos := _point_on_ring(0.02) if is_ring else _tip(pa).lerp(_tip(pb), 0.05)
		var rid := "%s_r" % key
		_push({"id": rid, "branch": key, "name": b["root"]["n"], "desc": b["root"]["d"],
			"cost": ROOT_COST, "mods": b["root"]["m"], "parent": "hub", "p": root_pos})

		var idx := 0
		var prev := rid
		for side in ["a", "b"]:
			var sb: Dictionary = b[side]
			for k in sb["nodes"].size():
				idx += 1
				var t := float(idx) / float(total + 1)
				var pos := _point_on_ring(0.02 + t * 0.96) if is_ring else _tip(pa).lerp(_tip(pb), 0.09 + t * 0.86)
				var nd: Dictionary = sb["nodes"][k]
				var nid := "%s_%s_%d" % [key, side, k]
				_push({"id": nid, "branch": key, "sub": sb["title"],
					"name": nd["n"], "desc": nd["d"], "cost": SUB_COST[mini(idx - 1, SUB_COST.size() - 1)],
					"mods": nd["m"], "parent": prev, "p": pos})
				prev = nid


static func _push(n: Dictionary) -> void:
	_nodes.append(n)
	_by_id[n["id"]] = n


static func all() -> Array:
	_build()
	return _nodes


static func node(id: String) -> Dictionary:
	_build()
	return _by_id.get(id, {})
