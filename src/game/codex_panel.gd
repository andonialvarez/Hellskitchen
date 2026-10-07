class_name CodexPanel
extends Control
## El Códice: todo lo que has descubierto. Lo no descubierto se ve como
## una silueta gris sin nombre ni datos.


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.03, 0.035, 0.99)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var mc := MarginContainer.new()
	mc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mc.add_theme_constant_override(m, 26)
	add_child(mc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	mc.add_child(vb)

	var head := HBoxContainer.new()
	vb.add_child(head)
	var title := _lbl("El Códice", 24, ThemeKit.TEXT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var cb := Button.new()
	cb.text = "Cerrar"
	ThemeKit.style_button(cb, ThemeKit.CARD)
	cb.pressed.connect(close)
	head.add_child(cb)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)
	var inner := VBoxContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_theme_constant_override("separation", 12)
	scroll.add_child(inner)

	inner.add_child(_section_demons())
	inner.add_child(_section("Objetos"))
	inner.add_child(_grid_items())
	inner.add_child(_section("Decoración"))
	inner.add_child(_grid_decor())


func open() -> void:
	visible = true
	_rebuild()


func close() -> void:
	visible = false


var _demon_count_lbl: Label
var _demon_grid: GridContainer
var _item_grid: GridContainer
var _decor_grid: GridContainer


func _section_demons() -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	var head := HBoxContainer.new()
	v.add_child(head)
	var l := _lbl("Demonios", 15, ThemeKit.SULFUR)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(l)
	_demon_count_lbl = _lbl("", 12, ThemeKit.TEXT_DIM)
	head.add_child(_demon_count_lbl)
	var line := ColorRect.new()
	line.color = ThemeKit.LINE
	line.custom_minimum_size = Vector2(0, 2)
	v.add_child(line)
	_demon_grid = GridContainer.new()
	_demon_grid.columns = 5
	_demon_grid.add_theme_constant_override("h_separation", 8)
	_demon_grid.add_theme_constant_override("v_separation", 8)
	v.add_child(_demon_grid)
	return v


func _grid_items() -> Control:
	_item_grid = GridContainer.new()
	_item_grid.columns = 3
	_item_grid.add_theme_constant_override("h_separation", 8)
	_item_grid.add_theme_constant_override("v_separation", 8)
	return _item_grid


func _grid_decor() -> Control:
	_decor_grid = GridContainer.new()
	_decor_grid.columns = 3
	_decor_grid.add_theme_constant_override("h_separation", 8)
	_decor_grid.add_theme_constant_override("v_separation", 8)
	return _decor_grid


func _rebuild() -> void:
	var found := Game.discovered_demons.size()
	_demon_count_lbl.text = "%d / %d descubiertos" % [found, Demons.LIST.size()]
	for c in _demon_grid.get_children():
		c.queue_free()
	for d in Demons.LIST:
		_demon_grid.add_child(_demon_card(d))

	for c in _item_grid.get_children():
		c.queue_free()
	for it in Items.LIST:
		_item_grid.add_child(_item_card(it, Game.items_owned.has(it["id"])))

	for c in _decor_grid.get_children():
		c.queue_free()
	for d in Decor.LIST:
		_decor_grid.add_child(_item_card(d, Game.decor_owned.has(d["id"]), true))


func _demon_card(d: Dictionary) -> Control:
	var known: bool = Game.discovered_demons.has(d["id"])
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", ThemeKit.panel_style(ThemeKit.CARD if known else ThemeKit.STONE, 9))
	var mc := MarginContainer.new()
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mc.add_theme_constant_override(m, 8)
	card.add_child(mc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	mc.add_child(v)

	var icon := _DemonIcon.new()
	icon.known = known
	icon.rarity = String(d.get("rarity", "comun"))
	icon.custom_minimum_size = Vector2(48, 48)
	var wrap := CenterContainer.new()
	wrap.add_child(icon)
	v.add_child(wrap)

	if known:
		var nm := _lbl(String(d["name"]), 12, Demons.color(String(d["rarity"])))
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(nm)
		var dt := "Físico" if d["dtype"] == "phys" else "Mágico"
		var st := _lbl("%s · %s almas · %s daño" % [dt, Nums.fmt(float(d["souls"])), Nums.fmt(float(d["dmg"]))], 10, ThemeKit.TEXT_DIM)
		st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		st.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(st)
	else:
		var q := _lbl("???", 13, ThemeKit.TEXT_DIM.darkened(0.3))
		q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(q)
	return card


func _item_card(it: Dictionary, known: bool, is_decor := false) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 64)
	card.add_theme_stylebox_override("panel", ThemeKit.panel_style(ThemeKit.CARD if known else ThemeKit.STONE, 9))
	var mc := MarginContainer.new()
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mc.add_theme_constant_override(m, 8)
	card.add_child(mc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	mc.add_child(v)
	if known:
		var col := Demons.color(String(it.get("rarity", "comun")))
		v.add_child(_lbl(String(it["name"]), 13, col))
		if is_decor:
			v.add_child(_lbl("+%.1f ★  ·  %s" % [float(it.get("stars", 0.0)), String(it.get("rarity", ""))], 11, ThemeKit.TEXT_DIM))
		else:
			var d := _lbl(Items.describe(it), 11, ThemeKit.TEXT_DIM)
			d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			v.add_child(d)
	else:
		v.add_child(_lbl("???", 13, ThemeKit.TEXT_DIM.darkened(0.3)))
		v.add_child(_lbl("aún no descubierto", 11, ThemeKit.TEXT_DIM.darkened(0.4)))
	return card


func _section(text: String) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	v.add_child(_lbl(text, 15, ThemeKit.SULFUR))
	var line := ColorRect.new()
	line.color = ThemeKit.LINE
	line.custom_minimum_size = Vector2(0, 2)
	v.add_child(line)
	return v


func _lbl(t: String, sz: int, col: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	return l


## Icono pequeño: cabeza coloreada si se conoce, silueta gris plana si no.
class _DemonIcon extends Control:
	var known := false
	var rarity := "comun"
	func _draw() -> void:
		var c := size * 0.5
		if known:
			DemonNode.draw_mini_head(self, c, size.x * 0.4, rarity)
		else:
			DemonNode.draw_silhouette(self, c, size.x * 0.4)
