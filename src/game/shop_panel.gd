class_name ShopPanel
extends FullPanel
## La Despensa: cocineros (aparecen junto a la sartén y se pueden ascender a
## demonios mayores), especias y utensilios (suben el valor por clic / almas),
## decoración (sube las estrellas) y quién viene a comer (% por rareza).

var _cols: Dictionary = {}
var _cooks_box: VBoxContainer
var _decor_box: VBoxContainer
var _clientela_box: VBoxContainer
var _stars_lbl: Label
var _shop_rows: Array = []


func _ready() -> void:
	var vb := _build_frame("La Despensa", 26, 10, 0.99, Color(0.055, 0.032, 0.038))
	_stars_lbl = _lbl("", 16, ThemeKit.SULFUR)
	_stars_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_add_to_head(_stars_lbl)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 12)
	_add_scroll(vb, inner)

	# --- cocineros ---
	inner.add_child(_section("Cocineros  ·  cocinan solos junto a la sartén y se ascienden a demonios mayores"))
	_cooks_box = VBoxContainer.new()
	_cooks_box.add_theme_constant_override("separation", 5)
	inner.add_child(_cooks_box)

	# --- especias / utensilios ---
	var cats := HBoxContainer.new()
	cats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cats.add_theme_constant_override("separation", 14)
	inner.add_child(cats)
	var titles := {"especias": "Especias", "utensilios": "Utensilios"}
	for cat in Shop.CATS:
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_theme_constant_override("separation", 6)
		cats.add_child(col)
		col.add_child(_lbl(titles[cat], 15, ThemeKit.EMBER_HOT))
		_cols[cat] = col
	for u in Shop.LIST:
		_add_shop_card(u)

	# --- clientela (odds) ---
	inner.add_child(_section("Quién viene a comer  ·  según tus estrellas y tu favor"))
	_clientela_box = VBoxContainer.new()
	_clientela_box.add_theme_constant_override("separation", 3)
	inner.add_child(_clientela_box)

	# --- decoración ---
	inner.add_child(_section("Decoración del local  ·  más estrellas → demonios de mayor rango"))
	_decor_box = VBoxContainer.new()
	_decor_box.add_theme_constant_override("separation", 5)
	inner.add_child(_decor_box)


func _add_shop_card(u: Dictionary) -> void:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", ThemeKit.panel_style(ThemeKit.CARD, 9))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cols[u["cat"]].add_child(card)
	var mc := MarginContainer.new()
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mc.add_theme_constant_override(m, 8)
	card.add_child(mc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	mc.add_child(v)
	v.add_child(_lbl(String(u["name"]), 13, ThemeKit.TEXT))
	var dl := _lbl(String(u["desc"]), 11, ThemeKit.TEXT_DIM)
	dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(dl)
	var btn := Button.new()
	btn.clip_text = true
	ThemeKit.style_button(btn, ThemeKit.SOUL_DIM)
	btn.pressed.connect(func() -> void:
		Audio.play("sizzle", 0.1)
		Game.buy_shop(String(u["id"])))
	v.add_child(btn)
	_shop_rows.append({"id": String(u["id"]), "btn": btn})


func _rebuild() -> void:
	var st := Game.stars()
	var pips := Decor.star_pips(st)
	_stars_lbl.text = "%s%s   (%.1f)" % ["★".repeat(pips), "☆".repeat(5 - pips), st]

	for r in _shop_rows:
		var id: String = r["id"]
		var lvl := int(Game.shop_lvl.get(id, 0))
		var mx := int(Shop.by_id(id)["max"])
		r["btn"].disabled = not Game.can_buy_shop(id) or lvl >= mx
		r["btn"].text = ("Máx  (niv %d)" % lvl) if lvl >= mx else ("%s almas  ·  niv %d" % [Nums.fmt(Game.shop_cost(id)), lvl])

	_rebuild_cooks()
	_rebuild_clientela()
	_rebuild_decor()


func _rebuild_cooks() -> void:
	_clear(_cooks_box)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_cooks_box.add_child(row)
	var info := _lbl("Tienes %d / %d cocineros  ·  cocinan %s / s en total" % [
		Game.cooks.size(), Game.max_cooks(), Nums.fmt(Game.cooks_autocook())], 13, ThemeKit.TEXT)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	var hire := Button.new()
	ThemeKit.style_button(hire, ThemeKit.BLOOD)
	hire.disabled = not Game.can_buy_cook()
	hire.text = "Contratar pinche" if Game.cooks.size() >= Game.max_cooks() else "Contratar pinche  ·  %s almas" % Nums.fmt(Game.cook_buy_cost())
	hire.pressed.connect(func() -> void:
		Game.buy_cook()
		_rebuild())
	row.add_child(hire)

	for i in Game.cooks.size():
		var tier := int(Game.cooks[i])
		var did: String = Game.COOK_TIERS[tier]
		var rc := Demons.color(Demons.by_id(did).get("rarity", "comun"))
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", ThemeKit.panel_style(ThemeKit.CARD, 8))
		_cooks_box.add_child(card)
		var m := MarginContainer.new()
		for mm in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
			m.add_theme_constant_override(mm, 7)
		card.add_child(m)
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 8)
		m.add_child(hb)
		var nm := _lbl("Cocinero %d  —  %s  (%s / s)" % [i + 1, String(Demons.by_id(did)["name"]), Nums.fmt(Game.COOK_RATE[tier])], 12, rc)
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hb.add_child(nm)
		var up := Button.new()
		up.add_theme_font_size_override("font_size", 12)
		ThemeKit.style_button(up, ThemeKit.SOUL_DIM)
		if tier >= Game.COOK_TIERS.size() - 1:
			up.text = "Rango máximo"
			up.disabled = true
		else:
			var nxt: String = Demons.by_id(Game.COOK_TIERS[tier + 1])["name"]
			up.text = "Ascender a %s  ·  %s almas" % [nxt, Nums.fmt(Game.cook_upgrade_cost(i))]
			up.disabled = not Game.can_upgrade_cook(i)
		up.pressed.connect(func() -> void:
			Game.upgrade_cook(i)
			_rebuild())
		hb.add_child(up)


func _rebuild_clientela() -> void:
	_clear(_clientela_box)
	for e in Demons.odds(Game.favor(), Game.effective_pacts()):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_clientela_box.add_child(row)
		var nm := _lbl(String(e["name"]), 12, Demons.color(String(e["rarity"])))
		nm.custom_minimum_size = Vector2(210, 0)
		row.add_child(nm)
		var barrow := HBoxContainer.new()
		barrow.custom_minimum_size = Vector2(0, 12)
		barrow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(barrow)
		var pct: float = maxf(0.4, float(e["pct"]))
		var fill := ColorRect.new()
		fill.color = Demons.color(String(e["rarity"]))
		fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fill.size_flags_stretch_ratio = pct
		barrow.add_child(fill)
		var rest := Control.new()
		rest.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rest.size_flags_stretch_ratio = maxf(0.4, 100.0 - pct)
		barrow.add_child(rest)
		var pl := _lbl("%.1f%%" % float(e["pct"]), 12, ThemeKit.TEXT_DIM)
		pl.custom_minimum_size = Vector2(56, 0)
		row.add_child(pl)


func _rebuild_decor() -> void:
	_clear(_decor_box)
	for d in Decor.LIST:
		var owned: bool = Game.decor_owned.has(d["id"])
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_decor_box.add_child(row)
		var nm := _lbl("%s  (+%.1f ★)" % [String(d["name"]), float(d["stars"])], 12,
			Demons.color(String(d["rarity"])) if owned else ThemeKit.TEXT_DIM)
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(nm)
		if owned:
			row.add_child(_lbl("EN EL LOCAL", 11, ThemeKit.SOUL))
		elif float(d.get("cost", 0.0)) > 0.0:
			var b := Button.new()
			b.text = "%s almas" % Nums.fmt(float(d["cost"]))
			b.add_theme_font_size_override("font_size", 12)
			ThemeKit.style_button(b, ThemeKit.SOUL_DIM)
			b.disabled = not Game.can_buy_decor(String(d["id"]))
			b.pressed.connect(func() -> void:
				Game.buy_decor(String(d["id"]))
				_rebuild())
			row.add_child(b)
		else:
			row.add_child(_lbl("sólo botín", 11, ThemeKit.TEXT_DIM))


func _section(text: String) -> Control:
	return ThemeKit.section(text, 13)
