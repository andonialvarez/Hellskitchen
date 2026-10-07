class_name FullPanel
extends Control
## Base de las pantallas completas que se abren entre turnos (Despensa,
## Inventario, Recompensas, Códice). Monta el fondo, los márgenes, la
## cabecera con título y botón "Cerrar", y gestiona abrir/cerrar.
## Cada panel solo construye su contenido y rellena `_rebuild()`.

var _head: HBoxContainer
var _close_btn: Button


## Construye el marco y devuelve la columna donde va el contenido.
func _build_frame(title: String, margin := 26, separation := 10, bg_alpha := 0.99,
		bg_col := Color(0.05, 0.03, 0.035)) -> VBoxContainer:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var bg := ColorRect.new()
	bg.color = Color(bg_col, bg_alpha)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var mc := MarginContainer.new()
	mc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for m in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mc.add_theme_constant_override(m, margin)
	add_child(mc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", separation)
	mc.add_child(vb)

	_head = HBoxContainer.new()
	vb.add_child(_head)
	var t := _lbl(title, 24, ThemeKit.TEXT)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_head.add_child(t)
	_close_btn = Button.new()
	_close_btn.text = "Cerrar"
	ThemeKit.style_button(_close_btn, ThemeKit.CARD)
	_close_btn.pressed.connect(close)
	_head.add_child(_close_btn)
	return vb


## Añade algo a la cabecera, justo antes del botón "Cerrar".
func _add_to_head(c: Control) -> void:
	_head.add_child(c)
	_head.move_child(c, _close_btn.get_index())


## Mete `content` en una zona con scroll vertical que ocupa el resto del panel.
func _add_scroll(parent: Control, content: Control) -> void:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)


func open() -> void:
	visible = true
	_rebuild()


func close() -> void:
	visible = false


## Cada panel vuelve a pintar su contenido aquí al abrirse.
func _rebuild() -> void:
	pass


func _clear(box: Node) -> void:
	for c in box.get_children():
		c.queue_free()


func _lbl(t: String, sz: int, col: Color) -> Label:
	return ThemeKit.label(t, sz, col)
