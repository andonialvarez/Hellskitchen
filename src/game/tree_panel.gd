class_name TreePanel
extends Control
## Árbol de habilidades a pantalla completa. Se abre entre turnos.
## 6 raíces que se bifurcan en sub-ramas de 8 nodos. Pan con arrastrar,
## zoom con la rueda.

const BRANCH_COL := {
	"llama": "#ff6a2c", "carne": "#c94b4b", "piel": "#9aa7b3", "hambre": "#c9bf3e",
	"alma": "#b455d6", "gula": "#5fae52",
}

var _pan := Vector2.ZERO
var _zoom := 1.0
var _center := Vector2.ZERO
var _hover := ""
var _drag := false
var _t := 0.0
var _close_rect := Rect2()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	set_process(false)


func open() -> void:
	visible = true
	set_process(true)
	_pan = Vector2.ZERO
	_zoom = 0.5
	queue_redraw()


func close() -> void:
	visible = false
	set_process(false)


func _process(dt: float) -> void:
	_t += dt
	queue_redraw()


func _npos(nd: Dictionary) -> Vector2:
	return _center + _pan + Vector2(nd["p"]) * _zoom


func _pick(p: Vector2) -> String:
	for nd in SkillTree.all():
		if p.distance_to(_npos(nd)) <= 17.0 * _zoom + 6.0:
			return nd["id"]
	return ""


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_WHEEL_UP and e.pressed:
			_zoom = clampf(_zoom * 1.1, 0.22, 1.8); accept_event()
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN and e.pressed:
			_zoom = clampf(_zoom * 0.9, 0.22, 1.8); accept_event()
		elif e.button_index == MOUSE_BUTTON_LEFT:
			if e.pressed:
				if _close_rect.has_point(e.position):
					close(); accept_event(); return
				var id := _pick(e.position)
				if id != "" and Game.node_state(id) == "afford":
					Game.buy_node(id); accept_event()
				else:
					_drag = true
			else:
				_drag = false
	elif e is InputEventMouseMotion:
		if _drag:
			_pan += e.relative
		_hover = _pick(e.position)


func _unhandled_input(e: InputEvent) -> void:
	if visible and e is InputEventKey and e.pressed and e.keycode == KEY_ESCAPE:
		close(); accept_event()


func _draw() -> void:
	var s := size
	draw_rect(Rect2(0, 0, s.x, s.y), Color(0.05, 0.03, 0.035, 0.985))
	_center = Vector2(s.x * 0.5, s.y * 0.55)
	var f := ThemeKit.font()
	draw_string(f, Vector2(28, 40), "Árbol de habilidades", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, ThemeKit.TEXT)
	draw_string(f, Vector2(28, 64), "%s almas   ·   rueda: zoom   ·   arrastra: mover" % Nums.fmt(Game.souls),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ThemeKit.TEXT_DIM)
	_close_rect = Rect2(s.x - 52, 20, 32, 32)
	ThemeKit.fill_round_rect(self, _close_rect, 8, ThemeKit.CARD)
	draw_string(f, _close_rect.position + Vector2(10, 22), "X", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ThemeKit.TEXT)

	_draw_infernal_frame()

	# conexiones — estas líneas SON el pentagrama: cada cadena de nodos recorre
	# una línea de la estrella, y la 6ª rama ("alma") rodea el pentágono.
	var dim := Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, 0.22)
	for nd in SkillTree.all():
		var col := Color(BRANCH_COL.get(nd["branch"], "#ffffff"))
		var owned: bool = Game.tree_nodes.has(nd["id"])
		var a := _center + _pan if nd["parent"] == "hub" else _npos(SkillTree.node(nd["parent"]))
		draw_line(a, _npos(nd), col if owned else dim, 3.5 if owned else 2.0)

	# hub
	draw_circle(_center + _pan, 24.0 * _zoom, ThemeKit.CARD)
	draw_arc(_center + _pan, 24.0 * _zoom, 0, TAU, 28, ThemeKit.EMBER, 3.0)
	draw_string(f, _center + _pan + Vector2(-16, 5), "FOGÓN", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, ThemeKit.EMBER)

	# nodos
	for nd in SkillTree.all():
		var col := Color(BRANCH_COL.get(nd["branch"], "#ffffff"))
		var p := _npos(nd)
		var st := Game.node_state(nd["id"])
		var r := 16.0 * _zoom
		match st:
			"owned":
				draw_circle(p, r, col)
				draw_arc(p, r, 0, TAU, 24, Color(1, 1, 1, 0.5), 2.0)
			"afford":
				var pulse := 0.5 + 0.5 * sin(_t * 4.0)
				draw_circle(p, r + 4.0 * pulse * _zoom, Color(col.r, col.g, col.b, 0.25))
				draw_circle(p, r, ThemeKit.CARD)
				draw_arc(p, r, 0, TAU, 24, col, 3.0)
			"avail":
				draw_circle(p, r, ThemeKit.CARD)
				draw_arc(p, r, 0, TAU, 24, ThemeKit.TEXT_DIM, 2.0)
			_:
				draw_circle(p, r * 0.66, ThemeKit.LINE)

	# etiquetas de rama
	for b in SkillTree.DEF:
		var rn := SkillTree.node("%s_r" % b["key"])
		if not rn.is_empty():
			var lp := _npos(rn)
			draw_string(f, lp + Vector2(-40, -24), String(b["title"]),
				HORIZONTAL_ALIGNMENT_CENTER, 80, 13, Color(BRANCH_COL.get(b["key"], "#fff")))

	# info del nodo bajo el cursor
	if _hover != "":
		var nd := SkillTree.node(_hover)
		var box := Rect2(24, s.y - 120, minf(440.0, s.x - 48), 96)
		ThemeKit.fill_round_rect(self, box, 10, ThemeKit.PANEL)
		var stt: String = Game.node_state(_hover)
		var stxt: String = {"owned": "Ya lo tienes", "afford": "Clic para comprar", "avail": "Faltan almas", "locked": "Bloqueado (compra el anterior)"}[stt]
		draw_string(f, box.position + Vector2(14, 24), String(nd["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ThemeKit.TEXT)
		draw_string(f, box.position + Vector2(14, 46), String(nd["desc"]), HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 28, 12, ThemeKit.TEXT_DIM)
		draw_string(f, box.position + Vector2(14, 76), "Coste: %s almas   ·   %s" % [Nums.fmt(Game.tree_node_cost(_hover)), stxt],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ThemeKit.EMBER)


## Círculo de fuego que rodea el pentagrama de nodos (la forma la hacen las
## propias ramas; esto sólo es el aro de fuego alrededor).
func _draw_infernal_frame() -> void:
	var oc := _center + _pan
	var rad := SkillTree.TIP_R * 1.14 * _zoom

	draw_circle(oc, rad * 1.1, Color(ThemeKit.LAVA.r, ThemeKit.LAVA.g, ThemeKit.LAVA.b, 0.05))
	draw_circle(oc, rad * 0.92, Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, 0.03))

	var n := 78
	for i in n:
		var ang := TAU * float(i) / float(n) + _t * 0.12
		var dir := Vector2(cos(ang), sin(ang))
		var perp := Vector2(-dir.y, dir.x)
		var flick := 0.55 + 0.45 * sin(_t * 6.0 + float(i) * 1.7)
		var fh := (30.0 + 16.0 * flick) * _zoom
		var fw := 15.0 * _zoom
		var base_p := oc + dir * rad
		draw_colored_polygon(PackedVector2Array([
			base_p - perp * fw * 0.5,
			base_p + dir * fh * 0.4 - perp * fw * 0.28,
			base_p + dir * fh,
			base_p + dir * fh * 0.4 + perp * fw * 0.28,
			base_p + perp * fw * 0.5,
		]), Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, 0.45 * flick))
		draw_colored_polygon(PackedVector2Array([
			base_p - perp * fw * 0.24,
			base_p + dir * fh * 0.6,
			base_p + perp * fw * 0.24,
		]), Color(ThemeKit.EMBER_HOT.r, ThemeKit.EMBER_HOT.g, ThemeKit.EMBER_HOT.b, 0.6 * flick))
	draw_arc(oc, rad, 0, TAU, 96, Color(ThemeKit.LAVA.r, ThemeKit.LAVA.g, ThemeKit.LAVA.b, 0.55), 3.0 * _zoom)
