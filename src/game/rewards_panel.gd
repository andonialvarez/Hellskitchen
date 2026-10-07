class_name RewardsPanel
extends FullPanel
## Recuento del turno a pantalla completa: lista agrupada por tipo de
## demonio. Clic en un grupo para revelar su botín (almas y/o objetos).

var _list: VBoxContainer
var _rows: Array = []


func _ready() -> void:
	var vb := _build_frame("Recuento del turno", 30, 12, 0.985)
	var allb := Button.new()
	allb.text = "Abrir todo"
	ThemeKit.style_button(allb, ThemeKit.BLOOD)
	allb.pressed.connect(func() -> void:
		Game.open_all_rewards()
		_rebuild())
	_add_to_head(allb)

	vb.add_child(_lbl("Clic en cada grupo para abrir su botín.", 12, ThemeKit.TEXT_DIM))

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 8)
	_add_scroll(vb, _list)


func _rebuild() -> void:
	_clear(_list)
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
