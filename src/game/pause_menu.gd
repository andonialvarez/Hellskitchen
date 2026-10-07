class_name PauseMenu
extends Control
## Pausa durante el turno (Esc o P, el botón de pausa o al perder el foco).
## Congela todo el árbol de escenas: el motor (`Game`), el fuego, la paciencia
## y la auto-cocción se detienen. Este nodo sigue vivo con PROCESS_MODE_ALWAYS
## para poder reanudar.

## Cerrar el turno y volver al menú lo hace main.gd al recibir esta señal.
signal leave_to_menu

var _mute: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", ThemeKit.panel_style(ThemeKit.STONE_2, 14))
	panel.anchor_left = 0.5; panel.anchor_top = 0.5
	panel.anchor_right = 0.5; panel.anchor_bottom = 0.5
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(320, 0)
	add_child(panel)
	var mc := MarginContainer.new()
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mc.add_theme_constant_override(m, 22)
	panel.add_child(mc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	mc.add_child(vb)

	var title := _lbl("PAUSA", 26, ThemeKit.BLOOD_BRIGHT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)
	var sub := _lbl("Esc o P para continuar", 12, ThemeKit.TEXT_DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(sub)

	vb.add_child(_btn("Continuar", ThemeKit.BLOOD_BRIGHT, resume))
	_mute = _btn("", ThemeKit.CARD, func() -> void:
		Audio.set_muted(not Audio.muted)
		_refresh_mute())
	vb.add_child(_mute)
	vb.add_child(HSeparator.new())
	vb.add_child(_btn("Cerrar turno", ThemeKit.BLOOD, func() -> void:
		resume()
		Game.end_shift("abandono")))
	vb.add_child(_btn("Menú principal", ThemeKit.CARD, func() -> void:
		resume()
		leave_to_menu.emit()))


func _unhandled_input(e: InputEvent) -> void:
	if not (e is InputEventKey and e.pressed and not e.echo):
		return
	if e.keycode != KEY_ESCAPE and e.keycode != KEY_P:
		return
	if visible:
		resume()
		get_viewport().set_input_as_handled()
	elif Game.shift_active:
		pause()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and Game.shift_active:
		pause()


func pause() -> void:
	if visible or not Game.shift_active:
		return
	_refresh_mute()
	visible = true
	get_tree().paused = true


func resume() -> void:
	visible = false
	get_tree().paused = false


func _refresh_mute() -> void:
	_mute.text = "Sonido: Mudo" if Audio.muted else "Sonido: ON"


func _btn(text: String, col: Color, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 40)
	b.add_theme_font_size_override("font_size", 15)
	ThemeKit.style_button(b, col)
	b.pressed.connect(cb)
	return b


func _lbl(t: String, sz: int, col: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	return l
