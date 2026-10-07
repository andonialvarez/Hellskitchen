extends Node
## ==================================================================
##  Hell's Kitchen — motor (autoload "Game").
##
##  Cada TURNO tienes dos barras: FUEGO INFERNAL (tiempo) y tu VIDA.
##  Los demonios de la ventana esperan; si se impacientan te hacen daño
##  físico o mágico. A 0 de fuego o de vida, se acaba el turno.
##  Clicas la sartén para cocinar y SERVIR al demonio (se apunta en el
##  recuento). Con ataque >= `power` puedes DESPACHARLO (almas menores).
##  Al terminar el turno se abre el RECUENTO: por cada grupo de demonios
##  revelas su botín (almas y/o OBJETOS equipables).
##  Entre turnos: ÁRBOL de habilidades, INVENTARIO, RECOMPENSAS, CONTRATO.
## ==================================================================

signal changed
signal shift_started
signal shift_ended(reason: String, served: int, dispatched: int)
signal demon_served(demon: Dictionary)
signal demon_dispatched(demon: Dictionary)
signal damaged(amount: float, dtype: String)
signal reward_opened(index: int, loot: Dictionary)
signal pact_signed(gain: int)
signal toast(text: String)
signal slot_pulled(result: Dictionary)

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 2
const BASE_FIRE := 10.0
const BASE_HP := 10.0
const DMG_TICK := 0.5
const PRESTIGE_K := 1.0e4
const PRESTIGE_MIN := 1.0e4
const AUTOSAVE_EVERY := 6.0
const QUEUE_LEN := 6

## Demonio CORONADO: cualquiera puede salir con corona. Cuesta el DOBLE de
## cocción, pero al servirlo da una moneda para la Tragaperras del Infierno.
const CROWN_CHANCE := 0.06
## Monedas de tragaperras al empezar una partida nueva (para poder probar
## la tragaperras sin depender de que salgan demonios coronados).
const SLOT_START_COINS := 10

## Cocineros contratados: cada uno tiene un rango (0..6). Producen cocción/s
## y aparecen junto a la sartén. Se pueden ASCENDER a demonios mayores.
const COOK_TIERS := ["diablillo", "sabueso", "gargola", "incubo", "verdugo", "behemot", "belfegor"]
const COOK_RATE := [0.5, 1.6, 4.4, 12.0, 33.0, 90.0, 250.0]
const COOK_BUY_BASE := 55.0
const COOK_BUY_GROWTH := 1.85
const MAX_COOKS := 10

# ---------- persistente ----------
var souls := 0.0
var souls_life := 0.0
var souls_total := 0.0
var pacts := 0
var tree_nodes := {}
var items_owned := {}
var items_equipped := {}
var shop_lvl := {}           ## shop_id -> nivel
var decor_owned := {}        ## decor_id -> true
var cooks := []              ## [tier:int, ...]  cocineros contratados
var discovered_demons := {}  ## demon_id -> true (para el bestiario)
var slot_coins := SLOT_START_COINS   ## monedas para la Tragaperras del Infierno
var slot_boon := ""          ## bendición pendiente para la PRÓXIMA run
var slot_cursed := false     ## la PRÓXIMA tirada saldrá maldita (nada)
var stats := {
	"shifts": 0.0, "served": 0.0, "dispatched": 0.0, "clicks": 0.0,
	"best_shift": 0.0, "deaths": 0.0, "pacts_signed": 0.0, "items_found": 0.0,
}

# ---------- turno (no se guarda) ----------
var shift_active := false
var fire_left := 0.0
var hp := BASE_HP
var current_demon := {}
var demon_queue := []         ## próximos demonios (cola visible)
var cook_progress := 0.0
var demon_wait := 0.0
var served_tally := {}       ## demon_id -> count
var demons_fed_run := []     ## rarezas servidas este turno (para el recuento lateral)
var dispatched := 0
var shift_souls := 0.0       ## almas ganadas al despachar durante el turno
var _dmg_t := 0.0
var _autosave_t := 0.0
var _first_of_shift := true
var _active_boon := ""       ## bendición de tragaperras aplicada a la run en curso

# ---------- entre turnos ----------
var pending_rewards := []    ## [{demon_id, count, opened, loot}]

# ---------- cachés ----------
var _m := {}                 ## suma de mods de nodos + objetos equipados


func _ready() -> void:
	load_game()
	_recalc()


func _process(delta: float) -> void:
	if not shift_active:
		return
	fire_left -= delta
	demon_wait += delta

	var auto := autocook_rate()
	if auto > 0.0 and not current_demon.is_empty():
		_add_cook(auto * delta)

	# daño del demonio impaciente
	if not current_demon.is_empty():
		var pat := float(current_demon["patience"]) + float(_m.get("patience_add", 0.0))
		if demon_wait > pat:
			_dmg_t += delta
			while _dmg_t >= DMG_TICK:
				_dmg_t -= DMG_TICK
				_take_damage()

	if fire_left <= 0.0:
		fire_left = 0.0
		end_shift("fuego")
		return
	if hp <= 0.0:
		hp = 0.0
		stats["deaths"] += 1.0
		end_shift("muerte")
		return

	_autosave_t += delta
	if _autosave_t >= AUTOSAVE_EVERY:
		_autosave_t = 0.0
		save_game()


# ==================================================================
#  ESTADÍSTICAS DERIVADAS
# ==================================================================
func _recalc() -> void:
	_m = {}
	for id in tree_nodes:
		_merge(SkillTree.node(id).get("mods", {}))
	for id in items_equipped:
		if items_owned.has(id):
			_merge(Items.by_id(id).get("mods", {}))
	for id in shop_lvl:
		var sd := Shop.by_id(id)
		var lvl := int(shop_lvl[id])
		for k in sd.get("mods", {}):
			_m[k] = float(_m.get(k, 0.0)) + float(sd["mods"][k]) * float(lvl)
	if _active_boon != "":
		_merge(Slots.boon(_active_boon).get("mods", {}))


func _merge(mods: Dictionary) -> void:
	for k in mods:
		_m[k] = float(_m.get(k, 0.0)) + float(mods[k])


func max_hp() -> float: return BASE_HP + float(_m.get("max_hp", 0.0))
func armor_phys() -> float: return float(_m.get("armor_phys", 0.0))
func armor_magic() -> float: return float(_m.get("armor_magic", 0.0))
func attack() -> float: return float(_m.get("attack", 0.0))
func fire_time_max() -> float: return BASE_FIRE + float(_m.get("fire_add", 0.0))
func cook_per_click() -> float: return (1.0 + float(_m.get("cook_add", 0.0))) * (1.0 + float(_m.get("click_mult", 0.0)))
func autocook_rate() -> float: return float(_m.get("autocook_add", 0.0)) + cooks_autocook()
func cooks_autocook() -> float:
	var t := 0.0
	for tier in cooks:
		t += COOK_RATE[clampi(int(tier), 0, COOK_RATE.size() - 1)]
	return t * (1.0 + float(_m.get("cook_rate_pct", 0.0)))
func favor() -> float: return float(_m.get("favor_add", 0.0)) + stars() * (1.5 + float(_m.get("star_favor_mult", 0.0)) * 1.5)
func stars() -> float: return Decor.total_stars(decor_owned)
func effective_pacts() -> int: return pacts + int(stars() / 2.5)
func max_cooks() -> int: return MAX_COOKS + int(_m.get("max_cooks_add", 0.0))
func queue_len() -> int: return QUEUE_LEN + int(_m.get("queue_add", 0.0))
func cost_discount(kind: String) -> float: return maxf(0.25, 1.0 - float(_m.get(kind, 0.0)))
func souls_mult() -> float: return 1.0 + float(_m.get("souls_pct", 0.0)) + 0.20 * float(pacts)
func double_chance() -> float: return minf(0.6, float(_m.get("double_pct", 0.0)))
func item_bonus() -> float: return float(_m.get("item_pct", 0.0))
func impatient_reduce() -> float: return minf(0.8, float(_m.get("impatient_reduce", 0.0)))
func dispatch_bonus() -> float: return float(_m.get("dispatch_pct", 0.0))
func stat_summary() -> Dictionary:
	return {"hp": max_hp(), "ap": armor_phys(), "am": armor_magic(), "atk": attack()}


# ==================================================================
#  TURNO
# ==================================================================
func start_shift() -> void:
	if shift_active:
		return
	_active_boon = slot_boon
	slot_boon = ""
	_recalc()
	if _active_boon != "":
		toast.emit("Bendición activa: " + String(Slots.boon(_active_boon).get("name", "")))
	pending_rewards.clear()
	shift_active = true
	fire_left = fire_time_max()
	hp = max_hp()
	cook_progress = 0.0
	demon_wait = 0.0
	served_tally = {}
	demons_fed_run.clear()
	dispatched = 0
	shift_souls = 0.0
	_dmg_t = 0.0
	_first_of_shift = true
	demon_queue.clear()
	_refill_queue()
	_spawn_demon()
	stats["shifts"] += 1.0
	shift_started.emit()
	changed.emit()


func end_shift(reason: String) -> void:
	if not shift_active:
		return
	shift_active = false
	var served := 0
	pending_rewards.clear()
	var order := {}
	for i in Demons.LIST.size():
		order[Demons.LIST[i]["id"]] = i
	var ids := served_tally.keys()
	ids.sort_custom(func(a, b): return order[a] < order[b])
	for id in ids:
		var c := int(served_tally[id])
		served += c
		pending_rewards.append({"demon_id": id, "count": c, "opened": false, "loot": {}})
	if shift_souls > stats["best_shift"]:
		stats["best_shift"] = shift_souls
	current_demon = {}
	demon_queue.clear()
	_active_boon = ""
	_recalc()
	shift_ended.emit(reason, served, dispatched)
	changed.emit()
	save_game()


func _refill_queue() -> void:
	while demon_queue.size() < queue_len():
		demon_queue.append(Demons.roll(favor(), effective_pacts()))


func _spawn_demon() -> void:
	var force_min := 0
	if _first_of_shift and float(_m.get("first_rare", 0.0)) > 0.0:
		force_min = 3
	_first_of_shift = false
	if demon_queue.is_empty():
		_refill_queue()
	current_demon = demon_queue.pop_front()
	if force_min > 0 and Demons.index_of(String(current_demon.get("id", ""))) < force_min:
		current_demon = Demons.roll(favor(), effective_pacts(), force_min)
	# instancia propia (no tocar la tabla compartida Demons.LIST) + tirada de corona
	current_demon = (current_demon as Dictionary).duplicate()
	current_demon["crowned"] = randf() < CROWN_CHANCE
	_refill_queue()
	discovered_demons[String(current_demon.get("id", ""))] = true
	cook_progress = 0.0
	demon_wait = 0.0
	_dmg_t = 0.0


func cook_click() -> void:
	if not shift_active or current_demon.is_empty():
		return
	stats["clicks"] += 1.0
	_add_cook(cook_per_click())


func _need() -> float:
	var discount := minf(0.7, float(_m.get("cook_need_pct", 0.0)))
	var n := float(current_demon.get("cook", 1.0)) * (1.0 - discount)
	if current_demon.get("crowned", false):
		n *= 2.0
	return n


func demon_progress() -> float:
	if current_demon.is_empty():
		return 0.0
	return clampf(cook_progress / _need(), 0.0, 1.0)


func patience_left() -> float:
	if current_demon.is_empty():
		return 1.0
	var pat := float(current_demon["patience"]) + float(_m.get("patience_add", 0.0))
	return clampf(1.0 - demon_wait / pat, 0.0, 1.0)


func _add_cook(amount: float) -> void:
	if current_demon.is_empty():
		return
	cook_progress += amount
	var guard := 0
	while not current_demon.is_empty() and cook_progress >= _need() and guard < 8:
		guard += 1
		cook_progress -= _need()
		var served := current_demon
		_tally(served)
		if served.get("crowned", false):
			slot_coins += 1
			toast.emit("¡Moneda del infierno!  (%d monedas)" % slot_coins)
		if randf() < double_chance():
			_tally(Demons.roll(favor(), effective_pacts()))
		_spawn_demon()
		demon_served.emit(served)


func _tally(demon: Dictionary) -> void:
	var id: String = demon["id"]
	served_tally[id] = int(served_tally.get(id, 0)) + 1
	demons_fed_run.append(String(demon["rarity"]))
	stats["served"] += 1.0


func can_dispatch() -> bool:
	return shift_active and not current_demon.is_empty() and attack() >= float(current_demon["power"])


func dispatch() -> void:
	if not can_dispatch():
		return
	var d := current_demon
	var pay := float(d["souls"]) * 0.15 * (1.0 + dispatch_bonus()) * souls_mult()
	souls += pay
	souls_life += pay
	souls_total += pay
	shift_souls += pay
	dispatched += 1
	stats["dispatched"] += 1.0
	_spawn_demon()
	demon_dispatched.emit(d)
	changed.emit()


func _take_damage() -> void:
	if current_demon.is_empty():
		return
	var dtype := String(current_demon["dtype"])
	var armor := armor_phys() if dtype == "phys" else armor_magic()
	var taken := float(current_demon["dmg"]) * (100.0 / (100.0 + armor)) * (1.0 - impatient_reduce())
	hp = maxf(0.0, hp - taken)
	damaged.emit(taken, dtype)


# ==================================================================
#  RECOMPENSAS (al terminar el turno)
# ==================================================================
func open_reward(index: int) -> void:
	if index < 0 or index >= pending_rewards.size():
		return
	var r: Dictionary = pending_rewards[index]
	if r["opened"]:
		return
	var demon := Demons.by_id(r["demon_id"])
	var tier := 0
	for i in Demons.LIST.size():
		if Demons.LIST[i]["id"] == demon["id"]:
			tier = i
	var gained := 0.0
	var got_items: Array = []
	var got_tokens: Array = []
	var got_decor: Array = []
	for i in int(r["count"]):
		gained += float(demon["souls"]) * souls_mult() * randf_range(0.85, 1.18)
		var chance := float(demon["item"]) + item_bonus()
		if randf() >= chance:
			continue
		# tipo de botín especial: objeto / vale de despensa / decoración
		var roll := randf()
		var decor_w := 0.12 + float(tier) * 0.05
		if roll < decor_w:
			var did := Decor.random_undropped(decor_owned)
			if did != "":
				decor_owned[did] = true
				got_decor.append(did)
			else:
				gained += float(demon["souls"]) * souls_mult() * 0.6
		elif roll < decor_w + 0.32:
			var tid := Shop.random_not_maxed(shop_lvl)
			if tid != "":
				shop_lvl[tid] = int(shop_lvl.get(tid, 0)) + 1
				got_tokens.append(tid)
			else:
				gained += float(demon["souls"]) * souls_mult() * 0.6
		else:
			var iid := Items.roll_drop(demon["rarity"], items_owned)
			if iid != "":
				items_owned[iid] = true
				items_equipped[iid] = true
				stats["items_found"] += 1.0
				got_items.append(iid)
			else:
				gained += float(demon["souls"]) * souls_mult() * 0.5
	souls += gained
	souls_life += gained
	souls_total += gained
	r["opened"] = true
	r["loot"] = {"souls": gained, "items": got_items, "tokens": got_tokens, "decor": got_decor}
	if not got_items.is_empty() or not got_tokens.is_empty() or not got_decor.is_empty():
		_recalc()
	reward_opened.emit(index, r["loot"])
	changed.emit()
	save_game()


func open_all_rewards() -> void:
	for i in pending_rewards.size():
		open_reward(i)


func rewards_left() -> int:
	var n := 0
	for r in pending_rewards:
		if not r["opened"]:
			n += 1
	return n


# ==================================================================
#  ÁRBOL
# ==================================================================
func node_available(id: String) -> bool:
	if tree_nodes.has(id):
		return false
	var nd := SkillTree.node(id)
	if nd.is_empty():
		return false
	return nd["parent"] == "hub" or tree_nodes.has(nd["parent"])


func tree_node_cost(id: String) -> float:
	return ceilf(float(SkillTree.node(id).get("cost", INF)) * cost_discount("tree_cost_pct"))


func node_state(id: String) -> String:
	if tree_nodes.has(id):
		return "owned"
	if node_available(id):
		return "afford" if souls >= tree_node_cost(id) else "avail"
	return "locked"


func buy_node(id: String) -> void:
	if not node_available(id):
		return
	var c := tree_node_cost(id)
	if souls < c:
		return
	souls -= c
	tree_nodes[id] = true
	_recalc()
	toast.emit("Árbol: " + str(SkillTree.node(id)["name"]))
	changed.emit()
	save_game()


# ==================================================================
#  INVENTARIO
# ==================================================================
func toggle_item(id: String) -> void:
	if not items_owned.has(id):
		return
	if items_equipped.has(id):
		items_equipped.erase(id)
	else:
		items_equipped[id] = true
	_recalc()
	changed.emit()
	save_game()


# ==================================================================
#  LA DESPENSA (tienda)
# ==================================================================
func shop_cost(id: String) -> float:
	return ceilf(Shop.cost(id, int(shop_lvl.get(id, 0))) * cost_discount("shop_cost_pct"))


func can_buy_shop(id: String) -> bool:
	return souls >= shop_cost(id)


func buy_shop(id: String) -> void:
	var c := shop_cost(id)
	if souls < c or is_inf(c):
		return
	souls -= c
	shop_lvl[id] = int(shop_lvl.get(id, 0)) + 1
	_recalc()
	changed.emit()
	save_game()


# ---- cocineros ----
func cook_buy_cost() -> float:
	if cooks.size() >= max_cooks():
		return INF
	return ceilf(COOK_BUY_BASE * pow(COOK_BUY_GROWTH, float(cooks.size())) * cost_discount("cook_cost_pct"))


func can_buy_cook() -> bool:
	return cooks.size() < max_cooks() and souls >= cook_buy_cost()


func buy_cook() -> void:
	if not can_buy_cook():
		return
	souls -= cook_buy_cost()
	cooks.append(0)
	_recalc()
	changed.emit()
	save_game()


func cook_upgrade_cost(i: int) -> float:
	if i < 0 or i >= cooks.size():
		return INF
	var t := int(cooks[i])
	if t >= COOK_TIERS.size() - 1:
		return INF
	return ceilf(140.0 * pow(4.3, float(t + 1)) * cost_discount("cook_cost_pct"))


func can_upgrade_cook(i: int) -> bool:
	return souls >= cook_upgrade_cost(i)


func upgrade_cook(i: int) -> void:
	if not can_upgrade_cook(i):
		return
	souls -= cook_upgrade_cost(i)
	cooks[i] = int(cooks[i]) + 1
	_recalc()
	toast.emit("Cocinero ascendido a " + str(Demons.by_id(COOK_TIERS[int(cooks[i])])["name"]))
	changed.emit()
	save_game()


func can_buy_decor(id: String) -> bool:
	var d := Decor.by_id(id)
	return not decor_owned.has(id) and float(d.get("cost", 0.0)) > 0.0 and souls >= float(d["cost"])


func buy_decor(id: String) -> void:
	if not can_buy_decor(id):
		return
	souls -= float(Decor.by_id(id)["cost"])
	decor_owned[id] = true
	_recalc()
	toast.emit("Decoración: " + str(Decor.by_id(id)["name"]) + "  (+%.1f ★)" % float(Decor.by_id(id)["stars"]))
	changed.emit()
	save_game()


# ==================================================================
#  CONTRATO (prestigio)
# ==================================================================
func prestige_threshold() -> float:
	return PRESTIGE_MIN * pow(2.5, float(pacts))


func can_prestige() -> bool:
	return souls_life >= prestige_threshold()


func pacts_gain() -> int:
	if souls_life < PRESTIGE_MIN:
		return 0
	var g := pow(souls_life / PRESTIGE_K, 0.4) * (1.0 + float(_m.get("pact_gain_pct", 0.0)))
	return maxi(0, int(floorf(g)))


func prestige() -> void:
	if not can_prestige():
		return
	var g := pacts_gain()
	pacts += g
	stats["pacts_signed"] += 1.0
	souls = 0.0
	souls_life = 0.0
	if shift_active:
		end_shift("contrato")
	_recalc()
	pact_signed.emit(g)
	changed.emit()
	save_game()


# ==================================================================
#  TRAGAPERRAS DEL INFIERNO
# ==================================================================
func slot_can_pull() -> bool:
	return slot_coins > 0


## Gasta una moneda y devuelve {kind, reels, ...}. kind:
##   benefit  → bendición para la próxima run (slot_boon)
##   souls    → almas al momento (mult 1.0 ó 0.25)
##   item     → objeto al momento (item_id)
##   drawback → maldice la próxima tirada (slot_cursed)
##   cursed   → esta tirada estaba maldita: nada
##   nada     → nada
func slot_pull() -> Dictionary:
	if slot_coins <= 0:
		return {}
	slot_coins -= 1
	var reels: Array
	var result: Dictionary
	if slot_cursed:
		reels = Slots.cursed_reels()
		result = {"kind": "cursed"}
		slot_cursed = false
	else:
		reels = Slots.spin()
		result = Slots.evaluate(reels)
	result["reels"] = reels
	_apply_slot_result(result)
	changed.emit()
	save_game()
	slot_pulled.emit(result)
	return result


func _apply_slot_result(r: Dictionary) -> void:
	match String(r.get("kind", "nada")):
		"benefit":
			slot_boon = String(r["boon"])
			toast.emit("Bendición para tu próxima run: " + String(Slots.boon(slot_boon).get("name", "")))
		"souls":
			var amt := maxf(200.0, souls_total * 0.03) * float(r.get("mult", 1.0))
			souls += amt
			souls_life += amt
			souls_total += amt
			r["amount"] = amt
			toast.emit("La tragaperras escupe %s almas" % Nums.fmt(amt))
		"item":
			var rar: String = ["raro", "epico", "epico", "legendario", "legendario", "mitico"][clampi(pacts, 0, 5)]
			var iid := Items.roll_drop(rar, items_owned)
			if iid != "":
				items_owned[iid] = true
				items_equipped[iid] = true
				stats["items_found"] += 1.0
				_recalc()
				r["item_id"] = iid
				toast.emit("Objeto: " + String(Items.by_id(iid)["name"]))
			else:
				var amt2 := maxf(200.0, souls_total * 0.03)
				souls += amt2
				souls_life += amt2
				souls_total += amt2
				r["kind"] = "souls"
				r["amount"] = amt2
				toast.emit("Ya tienes todos los objetos: %s almas" % Nums.fmt(amt2))
		"drawback":
			slot_cursed = true
			toast.emit("Un diablillo maldice tu próxima tirada…")
		"cursed":
			toast.emit("La moneda estaba maldita. Nada.")
		_:
			toast.emit("Nada. Otra vez será.")


# ==================================================================
#  GUARDADO
# ==================================================================
func save_game() -> void:
	var data := {
		"v": SAVE_VERSION,
		"souls": souls, "souls_life": souls_life, "souls_total": souls_total, "pacts": pacts,
		"tree_nodes": tree_nodes.keys(),
		"items_owned": items_owned.keys(),
		"items_equipped": items_equipped.keys(),
		"shop_lvl": shop_lvl.duplicate(),
		"decor_owned": decor_owned.keys(),
		"cooks": cooks.duplicate(),
		"discovered_demons": discovered_demons.keys(),
		"slot_coins": slot_coins,
		"slot_boon": slot_boon,
		"slot_cursed": slot_cursed,
		"stats": stats.duplicate(),
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
		f.close()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var d: Dictionary = parsed
	souls = float(d.get("souls", 0.0))
	souls_life = float(d.get("souls_life", 0.0))
	souls_total = float(d.get("souls_total", 0.0))
	pacts = int(d.get("pacts", 0))
	for id in d.get("tree_nodes", []):
		tree_nodes[id] = true
	for id in d.get("items_owned", []):
		items_owned[id] = true
	for id in d.get("items_equipped", []):
		items_equipped[id] = true
	var sl: Dictionary = d.get("shop_lvl", {})
	for id in sl:
		shop_lvl[id] = int(sl[id])
	for id in d.get("decor_owned", []):
		decor_owned[id] = true
	for tier in d.get("cooks", []):
		cooks.append(int(tier))
	for id in d.get("discovered_demons", []):
		discovered_demons[id] = true
	slot_coins = int(d.get("slot_coins", SLOT_START_COINS))
	slot_boon = String(d.get("slot_boon", ""))
	slot_cursed = bool(d.get("slot_cursed", false))
	var s: Dictionary = d.get("stats", {})
	for k in stats:
		if s.has(k):
			stats[k] = float(s[k])


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func _reset_everything() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	souls = 0.0
	souls_life = 0.0
	souls_total = 0.0
	pacts = 0
	tree_nodes.clear()
	items_owned.clear()
	items_equipped.clear()
	shop_lvl.clear()
	decor_owned.clear()
	cooks.clear()
	discovered_demons.clear()
	demon_queue.clear()
	pending_rewards.clear()
	demons_fed_run.clear()
	slot_coins = SLOT_START_COINS
	slot_boon = ""
	slot_cursed = false
	_active_boon = ""
	for k in stats:
		stats[k] = 0.0
	shift_active = false
	current_demon = {}
	_recalc()
	changed.emit()


## Nueva partida desde el menú principal: resetea todo, sin recargar escena
## (el menú es quien cambia a la escena de juego después).
func new_game() -> void:
	_reset_everything()


## Ctrl+F9 durante la partida: reset de desarrollo con recarga de escena.
func debug_wipe() -> void:
	_reset_everything()
	get_tree().reload_current_scene.call_deferred()
