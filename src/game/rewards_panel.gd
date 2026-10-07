class_name RewardsPanel
extends Control
## Recuento del turno a pantalla completa: lista agrupada por tipo de
## demonio. Clic en un grupo para revelar su botín (almas y/o objetos).

var _list: VBoxContainer
var _rows: Array = []


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
		mc.add_theme_constant_override(m, 30)
	add_child(mc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	mc.add_child(vb)

	var head := HBoxContainer.new()
	vb.add_child(head)
	var title := _lbl("Recuento del turno", 24, ThemeKit.TEXT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var allb := Button.new()
	allb.text = "Abrir todo"
	ThemeKit.style_button(allb, ThemeKit.BLOOD)
	allb.pressed.connect(func() -> void:
		Game.open_all_rewards()
		_rebuild())
	head.add_child(allb)
	var cb := Button.new()
	cb.text = "Cerrar"
	ThemeKit.style_button(cb, ThemeKit.CARD)
	cb.pressed.connect(close)
	head.add_child(cb)

	vb.add_child(_lbl("Clic en cada grupo para abrir su botín.", 12, ThemeKit.TEXT_DIM))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_list)


func open() -> void:
	visible = true
	_rebuild()


func close() -> void:
	visible = false


func _rebuild() -> void:
	for c in _list.get_children():
		c.queue_free()
	_rows.clear()
	if Game.pending_rewards.is_empty():
		_list.add_child(_lbl("No serviste a ningún demonio este turno.", 13, ThemeKit.TEXT_DIM))
		return
	for i in Game.pending_rewards.size():
		_add_row(i)


func _add_row(index: int) -> void:
	var r: Dictionary = Game.pending_rewards[index]
	var demon := Demons.by_id(r["demon_id"])
	var rc := Demons.color(String(demon["rarity"]))
	var opened: bool = r["opened"]

	var card := Button.new()
	card.custom_minimum_size = Vector2(0, 46)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.disabled = opened
	card.clip_text = true
	card.alignment = HORIZONTAL_ALIGNMENT_LEFT
	card.add_theme_stylebox_override("normal", ThemeKit.panel_style(ThemeKit.CARD, 10))
	card.add_theme_stylebox_override("hover", ThemeKit.panel_style(ThemeKit.STONE_2, 10))
	var db := ThemeKit.panel_style(Color(rc.r, rc.g, rc.b, 0.14), 10)
	db.border_color = rc
	db.set_border_width_all(1)
	card.add_theme_stylebox_override("disabled", db)
	card.add_theme_color_override("font_color", ThemeKit.TEXT)
	card.add_theme_color_override("font_disabled_color", ThemeKit.TEXT)
	card.add_theme_font_size_override("font_size", 14)

	if opened:
		var loot: Dictionary = r["loot"]
		var parts := ["+%s almas" % Nums.fmt(float(loot.get("souls", 0.0)))]
		for iid in loot.get("items", []):
			parts.append("OBJETO: " + String(Items.by_id(iid)["name"]))
		for tid in loot.get("tokens", []):
			parts.append("MEJORA: " + String(Shop.by_id(tid)["name"]))
		for did in loot.get("decor", []):
			parts.append("DECORACIÓN: " + String(Decor.by_id(did)["name"]))
		card.text = "  %d × %s        %s" % [int(r["count"]), String(demon["name"]), "   ·   ".join(parts)]
	else:
		card.text = "  %d × %s        ▸ abrir botín" % [int(r["count"]), String(demon["name"])]
		card.pressed.connect(func() -> void:
			Game.open_reward(index)
			_rebuild())
	_list.add_child(card)


func _lbl(t: String, sz: int, col: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	return l
