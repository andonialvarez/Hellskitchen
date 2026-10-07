extends Control
## Hell's Kitchen — orquesta la escena. Solo la cocina y una barra de
## botones ocupan la ventana de juego; el árbol, el inventario y el
## recuento son pantallas aparte.

var _kitchen: KitchenView
var _fx: Control
var _hud: PanelContainer
var _btnbar: HBoxContainer
var _start_btn: Button
var _dispatch_btn: Button
var _overlay: ColorRect
var _ov_title: Label
var _ov_sub: Label
var _toast_box: VBoxContainer
var _tree: TreePanel
var _inv: InventoryPanel
var _rewards: RewardsPanel
var _shop: ShopPanel
var _codex: CodexPanel
var _slot: SlotPanel

var lbl_souls: Label
var lbl_pacts: Label
var lbl_stats: Label
var lbl_stars: Label
var _contra_btn: Button
var _rewards_btn: Button
var _hud_souls := -1.0
var _kitchen_hidden := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_kitchen = KitchenView.new()
	add_child(_kitchen)
	_kitchen.cook_requested.connect(_on_cook)

	_build_hud()
	_build_btnbar()

	_fx = Control.new()
	_fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fx)

	_dispatch_btn = Button.new()
	_dispatch_btn.text = "  DESPACHAR  "
	_dispatch_btn.add_theme_font_size_override("font_size", 15)
	ThemeKit.style_button(_dispatch_btn, ThemeKit.ATK.darkened(0.15))
	_dispatch_btn.pressed.connect(func() -> void: Game.dispatch())
	_dispatch_btn.visible = false
	add_child(_dispatch_btn)

	_start_btn = Button.new()
	_start_btn.text = "  ENCENDER EL FUEGO INFERNAL  "
	_start_btn.add_theme_font_size_override("font_size", 20)
	ThemeKit.style_button(_start_btn, ThemeKit.BLOOD_BRIGHT)
	_start_btn.pressed.connect(func() -> void:
		Game.start_shift()
		_close_panels())
	add_child(_start_btn)

	_toast_box = VBoxContainer.new()
	_toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_box.add_theme_constant_override("separation", 4)
	add_child(_toast_box)

	_build_overlay()

	_tree = TreePanel.new(); add_child(_tree)
	_inv = InventoryPanel.new(); add_child(_inv)
	_rewards = RewardsPanel.new(); add_child(_rewards)
	_shop = ShopPanel.new(); add_child(_shop)
	_codex = CodexPanel.new(); add_child(_codex)
	_slot = SlotPanel.new(); add_child(_slot)

	Game.changed.connect(_refresh)
	Game.shift_started.connect(_on_shift_started)
	Game.shift_ended.connect(_on_shift_ended)
	Game.demon_served.connect(_on_served)
	Game.demon_dispatched.connect(_on_dispatched)
	Game.pact_signed.connect(_on_pact)
	Game.toast.connect(_show_toast)
	resized.connect(_relayout)

	await get_tree().process_frame
	_relayout()
	_refresh()


func _process(_delta: float) -> void:
	# Las almas cambian en cada plato servido sin avisar con `changed`; el
	# resto del HUD solo cambia con `changed` (ver _refresh).
	if Game.souls != _hud_souls:
		_hud_souls = Game.souls
		lbl_souls.text = "%s almas" % Nums.fmt(Game.souls)
	_dispatch_btn.visible = Game.can_dispatch()
	if _dispatch_btn.visible:
		_dispatch_btn.reset_size()
		_dispatch_btn.position = _kitchen.pan_screen_pos() + Vector2(-_dispatch_btn.size.x * 0.5, 90)
	_update_kitchen_visibility()


## Con un panel a pantalla completa encima, la cocina no se ve: se deja de
## dibujar y de animar (demonio y brasas incluidos) hasta que se cierre.
func _update_kitchen_visibility() -> void:
	var covered := _tree.visible or _inv.visible or _rewards.visible \
		or _shop.visible or _codex.visible or _slot.visible
	if covered == _kitchen_hidden:
		return
	_kitchen_hidden = covered
	_kitchen.visible = not covered
	_kitchen.process_mode = Node.PROCESS_MODE_DISABLED if covered else Node.PROCESS_MODE_INHERIT


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_F9 and e.ctrl_pressed:
		Game.debug_wipe()


func _close_panels() -> void:
	_tree.close()
	_inv.close()
	_rewards.close()
	_shop.close()
	_codex.close()
	_slot.close()


# ==================================================================
#  LAYOUT
# ==================================================================
func _relayout() -> void:
	var s := size
	_hud.position = Vector2(14, 66)
	_start_btn.reset_size()
	_start_btn.position = Vector2((s.x - _start_btn.size.x) * 0.5, s.y * 0.42)
	_btnbar.position = Vector2(14, s.y - 52)
	_toast_box.position = Vector2(14, s.y - 200.0)
	_toast_box.size = Vector2(320, 0)
	if _overlay:
		_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


# ==================================================================
#  HUD
# ==================================================================
func _build_hud() -> void:
	_hud = PanelContainer.new()
	_hud.add_theme_stylebox_override("panel", ThemeKit.panel_style(ThemeKit.PANEL, 12))
	add_child(_hud)
	var mc := MarginContainer.new()
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mc.add_theme_constant_override(m, 10)
	_hud.add_child(mc)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	mc.add_child(hb)
	hb.add_child(_icon("soul", 24))
	lbl_souls = _mk("", 22, ThemeKit.SOUL)
	hb.add_child(lbl_souls)
	hb.add_child(VSeparator.new())
	hb.add_child(_icon("skull", 20))
	lbl_pacts = _mk("", 16, ThemeKit.SULFUR)
	hb.add_child(lbl_pacts)
	hb.add_child(VSeparator.new())
	lbl_stars = _mk("", 15, ThemeKit.SULFUR)
	lbl_stars.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(lbl_stars)
	hb.add_child(VSeparator.new())
	lbl_stats = _mk("", 13, ThemeKit.TEXT_DIM)
	lbl_stats.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(lbl_stats)


func _update_hud() -> void:
	_hud_souls = Game.souls
	lbl_souls.text = "%s almas" % Nums.fmt(Game.souls)
	lbl_pacts.text = "%d pactos" % Game.pacts
	var pips := Decor.star_pips(Game.stars())
	lbl_stars.text = "%s%s" % ["★".repeat(pips), "☆".repeat(5 - pips)]
	var ss := Game.stat_summary()
	lbl_stats.text = "VIDA %s   ARM %s/%s   ATK %s   CLIC %s" % [
		Nums.fmt(ss["hp"]), Nums.fmt(ss["ap"]), Nums.fmt(ss["am"]), Nums.fmt(ss["atk"]), Nums.fmt(Game.cook_per_click())]


# ==================================================================
#  BARRA DE BOTONES (entre turnos)
# ==================================================================
func _build_btnbar() -> void:
	_btnbar = HBoxContainer.new()
	_btnbar.add_theme_constant_override("separation", 8)
	add_child(_btnbar)
	_mk_barbtn("Árbol", func() -> void: _open_only(_tree))
	_mk_barbtn("Despensa", func() -> void: _open_only(_shop))
	_mk_barbtn("Inventario", func() -> void: _open_only(_inv))
	_rewards_btn = _mk_barbtn("Recompensas", func() -> void: _open_only(_rewards))
	_mk_barbtn("Códice", func() -> void: _open_only(_codex))
	_mk_barbtn("Tragaperras", func() -> void: _open_only(_slot))
	_contra_btn = _mk_barbtn("Contrato", func() -> void: Game.prestige())
	_mk_barbtn("Menú", func() -> void: get_tree().change_scene_to_file("res://src/game/menu.tscn"))
	var mute := _mk_barbtn("Mudo" if Audio.muted else "Sonido", func() -> void: pass)
	mute.name = "mute"
	mute.pressed.connect(func() -> void:
		Audio.set_muted(not Audio.muted)
		mute.text = "Mudo" if Audio.muted else "Sonido")


func _mk_barbtn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 13)
	ThemeKit.style_button(b, ThemeKit.CARD)
	b.pressed.connect(cb)
	_btnbar.add_child(b)
	return b


func _open_only(panel: Control) -> void:
	_close_panels()
	panel.open()


func _refresh_btnbar() -> void:
	_btnbar.visible = not Game.shift_active
	if Game.shift_active:
		return
	if Game.can_prestige():
		_contra_btn.text = "Contrato  +%d" % Game.pacts_gain()
		_contra_btn.disabled = false
	else:
		_contra_btn.text = "Contrato"
		_contra_btn.disabled = true
	var n := Game.rewards_left()
	_rewards_btn.text = "Recompensas (%d)" % n if n > 0 else "Recompensas"


# ==================================================================
#  EVENTOS
# ==================================================================
func _on_cook() -> void:
	Game.cook_click()
	Audio.play("sizzle", 0.16)


func _on_served(d: Dictionary) -> void:
	var next := Game.current_demon
	_kitchen.spawn_food_fly(FoodProps.random_kind())
	_spawn_float("Tasty", _kitchen.demon_screen_pos(), Demons.color(d.get("rarity", "comun")))
	var t := get_tree().create_timer(0.24)
	t.timeout.connect(func() -> void:
		_kitchen.demon_react()
		_kitchen.feed_transition(next))


func _on_dispatched(d: Dictionary) -> void:
	_kitchen.dispatch_transition(Game.current_demon)
	_spawn_float("¡despachado!", _kitchen.pan_screen_pos(), ThemeKit.ATK)


func _on_shift_started() -> void:
	_kitchen.set_demon(Game.current_demon)
	_start_btn.visible = false
	_hide_overlay()


func _on_shift_ended(reason: String, served: int, disp: int) -> void:
	_kitchen.set_demon({})
	_start_btn.visible = true
	var t := "SE APAGÓ EL FUEGO" if reason == "fuego" else ("TE HAN MATADO" if reason == "muerte" else "TURNO CERRADO")
	_show_overlay(t, "%d servidos  ·  %d despachados  ·  abre el recuento" % [served, disp], 2.4)
	await get_tree().create_timer(2.7).timeout
	if Game.rewards_left() > 0:
		_open_only(_rewards)


func _on_pact(gain: int) -> void:
	_show_overlay("CONTRATO FIRMADO", "+%d pactos  ·  demonios de mayor rango" % gain, 2.4)


# ==================================================================
#  FX / OVERLAY
# ==================================================================
func _spawn_float(text: String, pos: Vector2, col: Color) -> void:
	var l := _mk(text, 20, col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.position = pos + Vector2(randf_range(-40, 40), randf_range(-10, 10))
	_fx.add_child(l)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 70.0, 0.7)
	tw.tween_property(l, "modulate:a", 0.0, 0.7)
	tw.chain().tween_callback(l.queue_free)


func _build_overlay() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	var vb := VBoxContainer.new()
	vb.anchor_left = 0.5; vb.anchor_top = 0.5; vb.anchor_right = 0.5; vb.anchor_bottom = 0.5
	vb.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vb.grow_vertical = Control.GROW_DIRECTION_BOTH
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 8)
	_overlay.add_child(vb)
	_ov_title = _mk("", 40, ThemeKit.BLOOD_BRIGHT)
	_ov_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(_ov_title)
	_ov_sub = _mk("", 17, ThemeKit.TEXT)
	_ov_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(_ov_sub)
	_overlay.modulate.a = 0.0


func _show_overlay(title: String, sub: String, secs: float) -> void:
	_ov_title.text = title
	_ov_sub.text = sub
	_overlay.color = Color(0, 0, 0, 0.6)
	var tw := create_tween()
	tw.tween_property(_overlay, "modulate:a", 1.0, 0.25)
	tw.tween_interval(secs)
	tw.tween_property(_overlay, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func() -> void: _overlay.color = Color(0, 0, 0, 0))


func _hide_overlay() -> void:
	_overlay.modulate.a = 0.0
	_overlay.color = Color(0, 0, 0, 0)


func _show_toast(text: String) -> void:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", ThemeKit.panel_style(ThemeKit.STONE_2, 8))
	p.modulate.a = 0.0
	var mc := MarginContainer.new()
	mc.add_theme_constant_override("margin_left", 10)
	mc.add_theme_constant_override("margin_right", 10)
	mc.add_theme_constant_override("margin_top", 4)
	mc.add_theme_constant_override("margin_bottom", 4)
	p.add_child(mc)
	mc.add_child(_mk(text, 12, ThemeKit.SULFUR))
	_toast_box.add_child(p)
	while _toast_box.get_child_count() > 4:
		var old := _toast_box.get_child(0)
		_toast_box.remove_child(old)
		old.queue_free()
	var tw := create_tween()
	tw.tween_property(p, "modulate:a", 1.0, 0.2)
	tw.tween_interval(2.2)
	tw.tween_property(p, "modulate:a", 0.0, 0.4)
	tw.tween_callback(p.queue_free)


func _refresh() -> void:
	_update_hud()
	_refresh_btnbar()
	_start_btn.visible = not Game.shift_active


# ==================================================================
func _icon(kind: String, px: float) -> Control:
	var c := _IconBox.new()
	c.kind = kind
	c.custom_minimum_size = Vector2(px, px)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


func _mk(text: String, fsize: int, col: Color) -> Label:
	return ThemeKit.label(text, fsize, col)


class _IconBox extends Control:
	var kind := "soul"
	func _draw() -> void:
		ThemeKit.draw_icon(self, kind, Rect2(Vector2.ZERO, size))
