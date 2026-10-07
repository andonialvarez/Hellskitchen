class_name InventoryPanel
extends Control
## Inventario a pantalla completa. Clic en un objeto para equipar/quitar.
## Los objetos son ACUMULATIVOS: puedes llevarlos todos, las estadísticas
## se suman. Se abre entre turnos.

var _scroll: ScrollContainer
var _grid: GridContainer
var _stat_lbl: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.03, 0.035, 0.985)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var mc := MarginContainer.new()
	mc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mc.add_theme_constant_override(m, 28)
	add_child(mc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	mc.add_child(vb)

	var head := HBoxContainer.new()
	vb.add_child(head)
	var title := _lbl("Inventario del cocinero", 24, ThemeKit.TEXT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var cb := Button.new()
	cb.text = "Cerrar"
	ThemeKit.style_button(cb, ThemeKit.CARD)
	cb.pressed.connect(close)
	head.add_child(cb)

	_stat_lbl = _lbl("", 14, ThemeKit.EMBER_HOT)
	vb.add_child(_stat_lbl)
	vb.add_child(_lbl("Todos los objetos suman. Clic para equipar o quitar.", 12, ThemeKit.TEXT_DIM))

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(_scroll)
	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	_scroll.add_child(_grid)


func open() -> void:
	visible = true
	_rebuild()


func close() -> void:
	visible = false


func _rebuild() -> void:
	for c in _grid.get_children():
		c.queue_free()
	var ss := Game.stat_summary()
	_stat_lbl.text = "VIDA %s    ·    ARM. FÍSICA %s    ·    ARM. MÁGICA %s    ·    ATAQUE %s" % [
		Nums.fmt(ss["hp"]), Nums.fmt(ss["ap"]), Nums.fmt(ss["am"]), Nums.fmt(ss["atk"])]

	if Game.items_owned.is_empty():
		_grid.add_child(_lbl("Aún no tienes objetos. Salen en el botín de los demonios.", 13, ThemeKit.TEXT_DIM))
		return

	for it in Items.LIST:
		if not Game.items_owned.has(it["id"]):
			continue
		var eq: bool = Game.items_equipped.has(it["id"])
		var card := Button.new()
		card.custom_minimum_size = Vector2(0, 92)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.toggle_mode = true
		card.button_pressed = eq
		card.clip_text = true
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var rc := Demons.color(String(it["rarity"]))
		card.add_theme_stylebox_override("normal", ThemeKit.panel_style(ThemeKit.CARD, 10))
		card.add_theme_stylebox_override("hover", ThemeKit.panel_style(ThemeKit.STONE_2, 10))
		var eqbox := ThemeKit.panel_style(Color(rc.r, rc.g, rc.b, 0.22), 10)
		eqbox.border_color = rc
		eqbox.set_border_width_all(2)
		card.add_theme_stylebox_override("pressed", eqbox)
		card.add_theme_color_override("font_color", ThemeKit.TEXT)
		card.add_theme_font_size_override("font_size", 12)
		card.text = "%s\n%s\n%s" % [String(it["name"]), ("[EQUIPADO]" if eq else "[guardado]"), Items.describe(it)]
		card.pressed.connect(Game.toggle_item.bind(String(it["id"])))
		_grid.add_child(card)


func _lbl(t: String, sz: int, col: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	return l
