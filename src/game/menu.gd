extends Control
## Pantalla principal: Continuar / Nueva partida / Ajustes / Salir.

var _embers: CPUParticles2D
var _t := 0.0
var _confirm: Control
var _settings: Control
var _continue_btn: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = ThemeKit.OBSIDIAN
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_embers = CPUParticles2D.new()
	_embers.amount = 60
	_embers.lifetime = 5.0
	_embers.direction = Vector2(0, -1)
	_embers.spread = 20.0
	_embers.gravity = Vector2(0, -18)
	_embers.initial_velocity_min = 10.0
	_embers.initial_velocity_max = 40.0
	_embers.scale_amount_min = 1.5
	_embers.scale_amount_max = 4.0
	_embers.color = ThemeKit.EMBER
	_embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_embers.emitting = true
	add_child(_embers)
	resized.connect(_relayout)

	var center := VBoxContainer.new()
	center.anchor_left = 0.5; center.anchor_top = 0.5
	center.anchor_right = 0.5; center.anchor_bottom = 0.5
	center.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center.grow_vertical = Control.GROW_DIRECTION_BOTH
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 14)
	add_child(center)

	var title := _lbl("HELL'S KITCHEN", 44, ThemeKit.BLOOD_BRIGHT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title)
	var sub := _lbl("cocina para el infierno, sirve o despacha, firma tu contrato", 14, ThemeKit.TEXT_DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(sub)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 18)
	center.add_child(spacer)

	_continue_btn = _menu_btn("Continuar", ThemeKit.BLOOD_BRIGHT, func() -> void: _go_play())
	center.add_child(_continue_btn)
	center.add_child(_menu_btn("Nueva partida", ThemeKit.BLOOD, func() -> void: _ask_new_game()))
	center.add_child(_menu_btn("Ajustes", ThemeKit.CARD, func() -> void: _open_settings()))
	center.add_child(_menu_btn("Salir", ThemeKit.CARD, func() -> void: get_tree().quit()))

	_build_confirm()
	_build_settings()
	_refresh()
	call_deferred("_relayout")


func _relayout() -> void:
	_embers.position = Vector2(size.x * 0.5, size.y + 10.0)
	_embers.emission_rect_extents = Vector2(size.x * 0.5, 4.0)


func _refresh() -> void:
	_continue_btn.disabled = not Game.has_save()
	_continue_btn.text = "Continuar" if Game.has_save() else "Continuar  (sin partida)"


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var s := size
	var f := ThemeKit.font()
	# grieta de lava decorativa de fondo
	var gx := s.x * 0.5
	var glow := 0.5 + 0.1 * sin(_t * 1.4)
	for i in 9:
		var yy := s.y * float(i) / 8.0
		var off := sin(yy * 0.02 + _t * 0.3) * 40.0
		draw_circle(Vector2(gx + off, yy), 70.0, Color(ThemeKit.LAVA.r, ThemeKit.LAVA.g, ThemeKit.LAVA.b, 0.04 * glow))
	draw_string(f, Vector2(16, s.y - 14), "v0.6 · construido en el infierno con Godot", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, ThemeKit.TEXT_DIM)


func _go_play() -> void:
	get_tree().change_scene_to_file("res://src/game/main.tscn")


func _menu_btn(text: String, col: Color, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(260, 44)
	b.add_theme_font_size_override("font_size", 16)
	ThemeKit.style_button(b, col)
	b.pressed.connect(cb)
	return b


# ==================================================================
#  CONFIRMAR NUEVA PARTIDA
# ==================================================================
func _build_confirm() -> void:
	_confirm = ColorRect.new()
	_confirm.color = Color(0, 0, 0, 0.7)
	_confirm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_confirm.visible = false
	add_child(_confirm)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", ThemeKit.panel_style(ThemeKit.STONE_2, 14))
	panel.anchor_left = 0.5; panel.anchor_top = 0.5
	panel.anchor_right = 0.5; panel.anchor_bottom = 0.5
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_confirm.add_child(panel)
	var mc := MarginContainer.new()
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mc.add_theme_constant_override(m, 22)
	panel.add_child(mc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	mc.add_child(vb)
	vb.add_child(_lbl("¿Empezar una partida nueva?", 18, ThemeKit.TEXT))
	vb.add_child(_lbl("Se borrará tu progreso: almas, árbol, objetos, cocineros y decoración.", 12, ThemeKit.TEXT_DIM))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	vb.add_child(row)
	var yes := Button.new()
	yes.text = "Sí, borrar y empezar"
	ThemeKit.style_button(yes, ThemeKit.BLOOD_BRIGHT)
	yes.pressed.connect(func() -> void:
		Game.new_game()
		_go_play())
	row.add_child(yes)
	var no := Button.new()
	no.text = "Cancelar"
	ThemeKit.style_button(no, ThemeKit.CARD)
	no.pressed.connect(func() -> void: _confirm.visible = false)
	row.add_child(no)


func _ask_new_game() -> void:
	if not Game.has_save():
		Game.new_game()
		_go_play()
		return
	_confirm.visible = true


# ==================================================================
#  AJUSTES
# ==================================================================
func _build_settings() -> void:
	_settings = ColorRect.new()
	_settings.color = Color(0, 0, 0, 0.7)
	_settings.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings.visible = false
	add_child(_settings)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", ThemeKit.panel_style(ThemeKit.STONE_2, 14))
	panel.anchor_left = 0.5; panel.anchor_top = 0.5
	panel.anchor_right = 0.5; panel.anchor_bottom = 0.5
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(360, 0)
	_settings.add_child(panel)
	var mc := MarginContainer.new()
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mc.add_theme_constant_override(m, 22)
	panel.add_child(mc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	mc.add_child(vb)
	vb.add_child(_lbl("Ajustes", 20, ThemeKit.TEXT))

	var mute := Button.new()
	mute.text = "Sonido: Mudo" if Audio.muted else "Sonido: ON"
	ThemeKit.style_button(mute, ThemeKit.CARD)
	mute.pressed.connect(func() -> void:
		Audio.set_muted(not Audio.muted)
		mute.text = "Sonido: Mudo" if Audio.muted else "Sonido: ON")
	vb.add_child(mute)

	vb.add_child(HSeparator.new())
	var del := Button.new()
	del.text = "Borrar partida"
	ThemeKit.style_button(del, ThemeKit.BLOOD)
	del.pressed.connect(func() -> void:
		_settings.visible = false
		_ask_new_game())
	vb.add_child(del)

	var back := Button.new()
	back.text = "Volver"
	ThemeKit.style_button(back, ThemeKit.CARD)
	back.pressed.connect(func() -> void: _settings.visible = false)
	vb.add_child(back)


func _open_settings() -> void:
	_settings.visible = true


func _lbl(t: String, sz: int, col: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	return l
