class_name ComicViewer
extends Control
## Visor de la novela gráfica.
##  - play([n, ...]): escena de historia. Muestra esas páginas seguidas y
##    pausa el juego mientras tanto (también en mitad de un turno).
##  - open_gallery(): "Novela" del menú de abajo. Relees las páginas que ya
##    has visto; las demás salen bloqueadas con una pista.
## Controles: clic en la página, → o Espacio = siguiente · ← = anterior · Esc = cerrar.

signal closed

var _queue: Array = []        ## páginas que se pueden recorrer ahora
var _idx := 0
var _gallery := false
var _was_paused := false

var _page: TextureRect
var _locked: Label
var _lbl_part: Label
var _lbl_title: Label
var _lbl_count: Label
var _btn_prev: Button
var _btn_next: Button
var _thumbs: GridContainer
var _left: VBoxContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.02, 0.025, 0.96)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# --- la página, centrada y a toda la altura ---
	_page = TextureRect.new()
	_page.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_page.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_page.mouse_filter = Control.MOUSE_FILTER_STOP
	_page.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_next())
	add_child(_page)

	_locked = Label.new()
	_locked.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_locked.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_locked.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_locked.add_theme_font_size_override("font_size", 18)
	_locked.add_theme_color_override("font_color", ThemeKit.TEXT_DIM)
	_locked.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_locked)

	# --- columna derecha: título y botones ---
	var right := VBoxContainer.new()
	right.name = "right"
	right.add_theme_constant_override("separation", 10)
	add_child(right)
	var cap := Label.new()
	cap.text = "EL PRECIO DE UNA ESTRELLA"
	cap.add_theme_font_size_override("font_size", 12)
	cap.add_theme_color_override("font_color", ThemeKit.EMBER)
	right.add_child(cap)
	_lbl_part = _lbl("", 13, ThemeKit.TEXT_DIM)
	right.add_child(_lbl_part)
	_lbl_title = _lbl("", 24, ThemeKit.BONE)
	_lbl_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_lbl_title)
	_lbl_count = _lbl("", 14, ThemeKit.TEXT_DIM)
	right.add_child(_lbl_count)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 10)
	right.add_child(gap)
	_btn_next = _btn("Siguiente", ThemeKit.BLOOD_BRIGHT, _next)
	right.add_child(_btn_next)
	_btn_prev = _btn("Anterior", ThemeKit.CARD, _prev)
	right.add_child(_btn_prev)
	right.add_child(_btn("Cerrar", ThemeKit.CARD, close))
	var help := _lbl("Clic en la página o → para pasar\n← para volver · Esc para cerrar", 11, ThemeKit.TEXT_DIM)
	right.add_child(help)

	# --- columna izquierda: índice de páginas (solo en la galería) ---
	_left = VBoxContainer.new()
	_left.add_theme_constant_override("separation", 10)
	add_child(_left)
	_left.add_child(_lbl("Páginas", 16, ThemeKit.BONE))
	_thumbs = GridContainer.new()
	_thumbs.columns = 4
	_thumbs.add_theme_constant_override("h_separation", 6)
	_thumbs.add_theme_constant_override("v_separation", 6)
	_left.add_child(_thumbs)
	for n in range(1, Story.count() + 1):
		var b := Button.new()
		b.text = str(n)
		b.custom_minimum_size = Vector2(44, 34)
		ThemeKit.style_button(b, ThemeKit.CARD)
		b.pressed.connect(func() -> void: _go(n - 1))
		_thumbs.add_child(b)

	resized.connect(_relayout)


func _relayout() -> void:
	var s := size
	var ph := s.y - 24.0
	var pw := ph * 1137.0 / 1800.0
	var side := (s.x - pw) * 0.5
	if side < 200.0:
		# ventana estrecha: la página se encoge para dejar sitio a los botones
		pw = maxf(200.0, s.x - 400.0)
		ph = pw * 1800.0 / 1137.0
		side = (s.x - pw) * 0.5
	var r := Rect2(side, (s.y - ph) * 0.5, pw, ph)
	_page.position = r.position
	_page.size = r.size
	_locked.position = r.position + Vector2(30, 0)
	_locked.size = r.size - Vector2(60, 0)
	var right: Control = get_node("right")
	right.position = Vector2(r.end.x + 28.0, s.y * 0.30)
	right.size = Vector2(maxf(160.0, side - 56.0), 0)
	_left.position = Vector2(28.0, s.y * 0.30)
	_left.size = Vector2(maxf(160.0, side - 56.0), 0)


# ==================================================================
#  ABRIR / CERRAR
# ==================================================================
func play(pages: Array) -> void:
	if pages.is_empty():
		return
	if visible and not _gallery:
		for n in pages:
			if not _queue.has(n):
				_queue.append(n)
		_update()
		return
	_gallery = false
	_queue = pages.duplicate()
	_queue.sort()
	_idx = 0
	_open()


func open_gallery() -> void:
	_gallery = true
	_queue = range(1, Story.count() + 1)
	# empieza en la última página que has visto
	_idx = 0
	for n in _queue:
		if Game.story_seen.has(n):
			_idx = n - 1
	_open()


func _open() -> void:
	if not visible:
		_was_paused = get_tree().paused
		get_tree().paused = true
		visible = true
		modulate.a = 0.0
		create_tween().tween_property(self, "modulate:a", 1.0, 0.25)
	_left.visible = _gallery
	_relayout()
	_update()


func close() -> void:
	if not visible:
		return
	visible = false
	get_tree().paused = _was_paused
	_queue.clear()
	closed.emit()


# ==================================================================
#  NAVEGACIÓN
# ==================================================================
func _next() -> void:
	if _idx >= _queue.size() - 1:
		close()
		return
	_go(_idx + 1)


func _prev() -> void:
	if _idx > 0:
		_go(_idx - 1)


func _go(i: int) -> void:
	_idx = clampi(i, 0, _queue.size() - 1)
	_page.modulate.a = 0.0
	_update()
	create_tween().tween_property(_page, "modulate:a", 1.0, 0.18)


func _update() -> void:
	if _queue.is_empty():
		return
	var n: int = _queue[_idx]
	var p := Story.page(n)
	var seen := Game.story_seen.has(n) or not _gallery
	_page.texture = Story.texture(n) if seen else null
	_locked.visible = not seen
	_locked.text = "Página bloqueada\n\n%s" % p.get("hint", "")
	_lbl_part.text = String(p.get("part", "")).to_upper()
	_lbl_title.text = String(p.get("title", "")) if seen else "???"
	_lbl_count.text = "Página %d de %d" % [n, Story.count()]
	_btn_prev.disabled = _idx == 0
	var last := _idx >= _queue.size() - 1
	_btn_next.text = ("Cerrar" if _gallery else "Continuar") if last else "Siguiente"
	for c in _thumbs.get_children():
		var b := c as Button
		var k := int(b.text)
		b.modulate = Color.WHITE if Game.story_seen.has(k) else Color(1, 1, 1, 0.35)
		ThemeKit.style_button(b, ThemeKit.BLOOD_BRIGHT if k == n else ThemeKit.CARD)


func _input(e: InputEvent) -> void:
	if not visible:
		return
	if e is InputEventKey and e.pressed and not e.echo:
		match e.keycode:
			KEY_RIGHT, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_D:
				_next()
			KEY_LEFT, KEY_A:
				_prev()
			KEY_ESCAPE:
				close()
			_:
				return
		get_viewport().set_input_as_handled()
	elif e is InputEventMouseButton and e.pressed:
		if e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if _idx < _queue.size() - 1:
				_go(_idx + 1)
			get_viewport().set_input_as_handled()
		elif e.button_index == MOUSE_BUTTON_WHEEL_UP:
			_prev()
			get_viewport().set_input_as_handled()


func _lbl(t: String, sz: int, col: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	return l


func _btn(t: String, col: Color, cb: Callable) -> Button:
	var b := Button.new()
	b.text = t
	b.custom_minimum_size = Vector2(170, 40)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	ThemeKit.style_button(b, col)
	b.pressed.connect(cb)
	return b
