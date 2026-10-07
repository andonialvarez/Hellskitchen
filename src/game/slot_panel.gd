class_name SlotPanel
extends Control
## La Tragaperras del Infierno. Cada moneda = una tirada. Se abre entre runs.
## Tira de la PALANCA (a la derecha) para girar. Arriba se ve cuántas monedas
## te quedan. El resultado: bendición para la próxima run, almas, un objeto,
## una maldición para tu próxima tirada, o nada.

const REEL_STOPS := [0.9, 1.35, 1.85]   ## cuándo empieza a frenar cada rodillo
const SPIN_SPEED := 24.0                 ## símbolos/segundo durante el giro
const LOCK_TIME := 0.45                  ## duración del frenado de cada rodillo

var _t := 0.0
var _spinning := false
var _spin_t := 0.0
var _final_syms := ["skull", "skull", "skull"]
## posición (float) de cada rodillo sobre una cinta virtual de símbolos:
## el símbolo de índice round(pos) queda centrado, el anterior arriba, el
## siguiente abajo (como una tragaperras real).
var _reel_pos := [0.0, 2.0, 4.0]
var _reel_target := [-1.0, -1.0, -1.0]
var _reel_locked := [true, true, true]
var _reel_from := [0.0, 0.0, 0.0]
var _reel_lt := [0.0, 0.0, 0.0]
var _result := {}
var _pending := {}
var _result_t := 0.0
var _lever := 0.0
var _mouse := Vector2.ZERO
var _hot: Array = []          ## [{rect, tip}] regiones con descripción al pasar el ratón
var _lever_rect := Rect2()
var _close_rect := Rect2()
var _cab := Rect2()


## Símbolo en el índice i de la cinta virtual (orden fijo, se repite).
func _strip_sym(i: int) -> String:
	return String(Slots.SYMBOLS[((i % Slots.SYMBOLS.size()) + Slots.SYMBOLS.size()) % Slots.SYMBOLS.size()])


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	set_process(false)


func open() -> void:
	visible = true
	set_process(true)
	_spinning = false
	_result = {}
	_result_t = 0.0
	_reel_locked = [true, true, true]
	queue_redraw()


func close() -> void:
	visible = false
	set_process(false)


func _process(dt: float) -> void:
	_t += dt
	_mouse = get_local_mouse_position()
	if _lever > 0.0 and not _spinning:
		_lever = maxf(0.0, _lever - dt * 3.5)
	if _spinning:
		_spin_t += dt
		for i in 3:
			if _reel_locked[i]:
				continue
			if _spin_t < REEL_STOPS[i]:
				_reel_pos[i] = float(_reel_pos[i]) + dt * SPIN_SPEED
			else:
				if float(_reel_target[i]) < 0.0:
					var want: int = Slots.SYMBOLS.find(_final_syms[i])
					var basep: float = ceil(float(_reel_pos[i])) + 3.0
					var n: int = Slots.SYMBOLS.size()
					while ((int(basep) % n) + n) % n != want:
						basep += 1.0
					_reel_target[i] = basep
					_reel_from[i] = float(_reel_pos[i])
					_reel_lt[i] = 0.0
				_reel_lt[i] = float(_reel_lt[i]) + dt
				var p := clampf(float(_reel_lt[i]) / LOCK_TIME, 0.0, 1.0)
				var e := 1.0 - pow(1.0 - p, 3.0)
				_reel_pos[i] = lerpf(float(_reel_from[i]), float(_reel_target[i]), e)
				if p >= 1.0:
					_reel_pos[i] = float(_reel_target[i])
					_reel_locked[i] = true
		if _reel_locked[0] and _reel_locked[1] and _reel_locked[2]:
			_spinning = false
			_result = _pending
			_result_t = 0.0
			Audio.play("gong", 0.08)
	if not _result.is_empty():
		_result_t += dt
	queue_redraw()


func _pull() -> void:
	if _spinning or not Game.slot_can_pull():
		return
	_lever = 1.0
	var res: Dictionary = Game.slot_pull()
	if res.is_empty():
		return
	_pending = res
	var rl: Array = res.get("reels", ["skull", "skull", "skull"])
	_final_syms = [String(rl[0]), String(rl[1]), String(rl[2])]
	_spinning = true
	_spin_t = 0.0
	_result = {}
	_result_t = 0.0
	_reel_target = [-1.0, -1.0, -1.0]
	_reel_locked = [false, false, false]
	_reel_lt = [0.0, 0.0, 0.0]
	Audio.play("dispatch", 0.15)


func _unhandled_input(e: InputEvent) -> void:
	if visible and e is InputEventKey and e.pressed and e.keycode == KEY_ESCAPE:
		close()
		accept_event()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		if _close_rect.has_point(e.position):
			close()
			accept_event()
			return
		if _lever_rect.has_point(e.position):
			_pull()
			accept_event()


# ====================================================================
func _draw() -> void:
	var s := size
	var f := ThemeKit.font()
	draw_rect(Rect2(0, 0, s.x, s.y), Color(0.05, 0.028, 0.033, 0.99))

	# grieta de lava de fondo
	var gx := s.x * 0.5
	for i in 9:
		var yy := s.y * float(i) / 8.0
		var off := sin(yy * 0.02 + _t * 0.3) * 40.0
		draw_circle(Vector2(gx + off, yy), 66.0, Color(ThemeKit.LAVA.r, ThemeKit.LAVA.g, ThemeKit.LAVA.b, 0.04))

	draw_string(f, Vector2(28, 42), "La Tragaperras del Infierno", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, ThemeKit.TEXT)
	draw_string(f, Vector2(28, 66), "cada moneda es una tirada  ·  tira de la palanca", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ThemeKit.TEXT_DIM)

	_close_rect = Rect2(s.x - 52, 20, 32, 32)
	ThemeKit.fill_round_rect(self, _close_rect, 8, ThemeKit.CARD)
	draw_string(f, _close_rect.position + Vector2(10, 22), "X", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ThemeKit.TEXT)

	# ---- contador de monedas ----
	var coin_c := Vector2(s.x * 0.5, 108.0)
	_draw_coin(coin_c + Vector2(-72, 0), 16.0)
	draw_string(f, coin_c + Vector2(-48, 7), "%d  monedas del infierno" % Game.slot_coins,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 20, ThemeKit.SULFUR)

	# ---- gabinete de la máquina ----
	var cw := minf(560.0, s.x - 120.0)
	var ch := 330.0
	_cab = Rect2(Vector2(s.x * 0.5 - cw * 0.5 - 30.0, s.y * 0.5 - ch * 0.5), Vector2(cw, ch))
	draw_rect(_cab.grow(10), Color("#0b0709"))
	ThemeKit.fill_round_rect(self, _cab, 18, ThemeKit.STONE_2)
	draw_rect(_cab, Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, 0.12 + 0.06 * sin(_t * 3.0)), false, 2.0)
	# frontón
	draw_string(f, _cab.position + Vector2(0, -18), "★  PACTO DE LA FORTUNA  ★",
		HORIZONTAL_ALIGNMENT_CENTER, cw, 15, ThemeKit.EMBER_HOT)

	# ---- 3 rodillos, cada uno mostrando símbolo anterior / centro / siguiente ----
	_hot.clear()
	var rn := 3
	var rw := 110.0
	var gap := 14.0
	var rh := 240.0                      # 3 celdas visibles
	var cell := rh / 3.0
	var total := rn * rw + (rn - 1) * gap
	var x0 := _cab.position.x + (cw - total) * 0.5
	var ry := _cab.position.y + 44.0
	for i in rn:
		var rr := Rect2(Vector2(x0 + i * (rw + gap), ry), Vector2(rw, rh))
		draw_rect(rr.grow(4), Color("#050304"))
		ThemeKit.fill_round_rect(self, rr, 10, Color("#141013"))
		var pos: float = float(_reel_pos[i])
		var cy := rr.position.y + rh * 0.5
		var basei := int(floor(pos))
		for k in range(basei - 1, basei + 2):
			var y := cy + (float(k) - pos) * cell
			var srect := Rect2(rr.position.x + 12.0, y - cell * 0.5 + 6.0, rw - 24.0, cell - 12.0)
			_draw_sym(_strip_sym(k), srect)
		# sombras arriba/abajo: dejan brillante sólo la fila del centro
		draw_rect(Rect2(rr.position, Vector2(rw, cell)), Color(0.02, 0.01, 0.015, 0.62))
		draw_rect(Rect2(Vector2(rr.position.x, rr.end.y - cell), Vector2(rw, cell)), Color(0.02, 0.01, 0.015, 0.62))
		# línea de premio (celda del centro)
		var em := Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, 0.5)
		draw_line(Vector2(rr.position.x, cy - cell * 0.5), Vector2(rr.end.x, cy - cell * 0.5), em, 1.5)
		draw_line(Vector2(rr.position.x, cy + cell * 0.5), Vector2(rr.end.x, cy + cell * 0.5), em, 1.5)
		# marco (tapa cualquier símbolo que asome por los bordes)
		draw_rect(rr, Color("#141013"), false, 8.0)
		ThemeKit.fill_round_rect(self, Rect2(rr.position - Vector2(3, 3), Vector2(rw + 6, 3)), 0, Color("#050304"))
		draw_rect(rr.grow(-1), Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, 0.25), false, 2.0)

	# ---- palanca (a la derecha del gabinete) ----
	var lx := _cab.end.x + 40.0
	var lbase := Vector2(lx, _cab.position.y + ch * 0.62)
	var pull := _lever
	var knob := lbase + Vector2(0, -84.0 + pull * 46.0)
	draw_circle(lbase, 14.0, ThemeKit.STONE_2)
	draw_circle(lbase, 14.0, ThemeKit.LINE, false, 2.0)
	draw_line(lbase, knob, Color("#5a4f56"), 9.0)
	draw_line(lbase, knob, Color("#3c343a"), 5.0)
	draw_circle(knob, 16.0, ThemeKit.BLOOD_BRIGHT)
	draw_circle(knob, 16.0, ThemeKit.EMBER_HOT, false, 2.0)
	draw_circle(knob + Vector2(-5, -5), 4.0, Color(1, 1, 1, 0.35))
	_lever_rect = Rect2(lx - 30.0, lbase.y - 110.0, 60.0, 150.0)
	var hint := "TIRA" if Game.slot_can_pull() and not _spinning else ("GIRANDO…" if _spinning else "sin monedas")
	draw_string(f, Vector2(lx - 34.0, lbase.y + 40.0), hint, HORIZONTAL_ALIGNMENT_LEFT, 90, 12, ThemeKit.TEXT_DIM)

	# ---- banner de resultado ----
	var by := _cab.end.y + 26.0
	if not _result.is_empty() and _result_t < 8.0:
		var info := _result_text(_result)
		var bcol: Color = info["col"]
		var br := Rect2(Vector2(_cab.position.x, by), Vector2(cw, 58.0))
		ThemeKit.fill_round_rect(self, br, 10, Color(bcol.r, bcol.g, bcol.b, 0.16))
		draw_rect(br, bcol, false, 1.5)
		draw_string(f, br.position + Vector2(14, 24), String(info["title"]), HORIZONTAL_ALIGNMENT_LEFT, cw - 28, 16, bcol)
		draw_string(f, br.position + Vector2(14, 46), String(info["sub"]), HORIZONTAL_ALIGNMENT_LEFT, cw - 28, 12, ThemeKit.TEXT_DIM)
		_hot.append({"rect": br, "tip": _result_tip(_result)})

	# ---- estado pendiente (bendición / maldición) ----
	var stt := by + 76.0
	if Game.slot_boon != "":
		var bn := String(Slots.boon(Game.slot_boon).get("name", ""))
		draw_string(f, Vector2(_cab.position.x, stt), "Bendición lista para tu próxima run:  " + bn + "   (pasa el ratón)",
			HORIZONTAL_ALIGNMENT_LEFT, cw + 160, 13, ThemeKit.SULFUR)
		_hot.append({"rect": Rect2(Vector2(_cab.position.x, stt - 14), Vector2(cw + 160, 20)),
			"tip": bn + " — " + String(Slots.boon(Game.slot_boon).get("desc", ""))})
		stt += 20.0
	if Game.slot_cursed:
		draw_string(f, Vector2(_cab.position.x, stt), "Tu próxima tirada está maldita   (pasa el ratón)",
			HORIZONTAL_ALIGNMENT_LEFT, cw + 160, 13, ThemeKit.HP)
		_hot.append({"rect": Rect2(Vector2(_cab.position.x, stt - 14), Vector2(cw + 160, 20)),
			"tip": "Un diablillo amañó la máquina: tu próxima tirada saldrá vacía pase lo que pase, y luego se levanta la maldición."})

	# ---- leyenda de símbolos (con descripción al pasar el ratón) ----
	var leg := s.y - 108.0
	var items := [
		["sigil", "3 sellos → BENDICIÓN para tu próxima run",
			"Bendiciones posibles: +30 s de fuego · +4 cocción por clic · +5 favor · +80 vida · +50% almas · +4 autococción/s. Sale una al azar y se activa sola al empezar tu siguiente run."],
		["soul", "3 cofres azules → ALMAS   (2 cofres → algunas almas)",
			"Con 3 cofres iguales, un buen puñado de almas directas a tu bolsa. Con sólo 2, una cuarta parte."],
		["loot", "3 cofres de abalorios → un OBJETO",
			"Un objeto al azar que aún no tengas, equipado automáticamente. Si ya los tienes todos, se convierte en almas."],
		["imp", "3 diablillos → MALDICEN tu próxima tirada",
			"Tu siguiente tirada saldrá vacía pase lo que pase. Después, la maldición desaparece."],
	]
	for i in items.size():
		var iy := leg + i * 24.0
		_draw_sym(String(items[i][0]), Rect2(Vector2(28, iy - 8), Vector2(17, 17)))
		draw_string(f, Vector2(56, iy + 5), String(items[i][1]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ThemeKit.TEXT_DIM)
		_hot.append({"rect": Rect2(Vector2(24, iy - 11), Vector2(s.x - 48, 22)), "tip": String(items[i][2])})

	# ---- tooltip flotante ----
	for h in _hot:
		if (h["rect"] as Rect2).has_point(_mouse):
			_draw_tooltip(String(h["tip"]))
			break


func _result_text(r: Dictionary) -> Dictionary:
	match String(r.get("kind", "nada")):
		"benefit":
			var b := Slots.boon(String(r.get("boon", "")))
			return {"title": "BENDICIÓN — " + String(b.get("name", "")), "sub": String(b.get("desc", "")), "col": ThemeKit.SULFUR}
		"souls":
			return {"title": "ALMAS — +" + Nums.fmt(float(r.get("amount", 0.0))), "sub": "van directas a tu bolsa", "col": ThemeKit.SOUL}
		"item":
			var nm := ""
			if r.has("item_id"):
				nm = String(Items.by_id(String(r["item_id"])).get("name", ""))
			return {"title": "OBJETO — " + nm, "sub": "equipado automáticamente", "col": ThemeKit.EMBER}
		"drawback":
			return {"title": "MALDICIÓN", "sub": "un diablillo amaña tu próxima tirada: saldrá vacía", "col": ThemeKit.HP}
		"cursed":
			return {"title": "NADA", "sub": "la moneda estaba maldita", "col": ThemeKit.TEXT_DIM}
		_:
			return {"title": "NADA", "sub": "otra vez será", "col": ThemeKit.TEXT_DIM}


## Texto largo del resultado, para el tooltip al pasar el ratón por el banner.
func _result_tip(r: Dictionary) -> String:
	match String(r.get("kind", "nada")):
		"benefit":
			var b := Slots.boon(String(r.get("boon", "")))
			return String(b.get("name", "")) + " - " + String(b.get("desc", "")) + ". Se activa sola al empezar tu proxima run, y solo dura esa run."
		"souls":
			return "+" + Nums.fmt(float(r.get("amount", 0.0))) + " almas, sumadas ya a tu bolsa. Escala con las almas totales de la partida."
		"item":
			if r.has("item_id"):
				var it := Items.by_id(String(r["item_id"]))
				return String(it.get("name", "")) + " - " + Items.describe(it) + ". Ya equipado; los objetos son acumulativos."
			return "Un objeto al azar, equipado automaticamente."
		"drawback":
			return "Tu proxima tirada saldra vacia pase lo que pase. Despues, la maldicion desaparece."
		_:
			return "Esta tirada no dio nada. Sube MATCH_BIAS en slots.gd para que la maquina reparta mas."


## Cajita de descripcion flotante junto al raton.
func _draw_tooltip(text: String) -> void:
	if text.is_empty():
		return
	var f := ThemeKit.font()
	var maxw := 320.0
	var words := text.split(" ")
	var lines: Array = []
	var cur := ""
	for w in words:
		var test: String = w if cur.is_empty() else cur + " " + w
		if f.get_string_size(test, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x > maxw and not cur.is_empty():
			lines.append(cur)
			cur = w
		else:
			cur = test
	if not cur.is_empty():
		lines.append(cur)
	var lh := 16.0
	var bw := maxw + 20.0
	var bh := float(lines.size()) * lh + 16.0
	var p := _mouse + Vector2(16, 18)
	p.x = clampf(p.x, 8.0, size.x - bw - 8.0)
	p.y = clampf(p.y, 8.0, size.y - bh - 8.0)
	var box := Rect2(p, Vector2(bw, bh))
	ThemeKit.fill_round_rect(self, box, 8, ThemeKit.PANEL)
	draw_rect(box, Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, 0.4), false, 1.5)
	for i in lines.size():
		draw_string(f, p + Vector2(10, 14 + i * lh), String(lines[i]), HORIZONTAL_ALIGNMENT_LEFT, bw - 20, 12, ThemeKit.TEXT)


# ---- dibujo de los símbolos ----
func _draw_sym(sym: String, rect: Rect2) -> void:
	var c := rect.position + rect.size * 0.5
	var u := minf(rect.size.x, rect.size.y)
	match sym:
		"imp":
			var red := ThemeKit.BLOOD_BRIGHT
			draw_circle(c + Vector2(0, u * 0.05), u * 0.3, red)
			draw_line(c + Vector2(-u * 0.18, -u * 0.2), c + Vector2(-u * 0.34, -u * 0.42), red.darkened(0.2), 3.0)
			draw_line(c + Vector2(u * 0.18, -u * 0.2), c + Vector2(u * 0.34, -u * 0.42), red.darkened(0.2), 3.0)
			draw_circle(c + Vector2(-u * 0.1, 0), u * 0.05, ThemeKit.EMBER_HOT)
			draw_circle(c + Vector2(u * 0.1, 0), u * 0.05, ThemeKit.EMBER_HOT)
			draw_arc(c + Vector2(0, u * 0.12), u * 0.12, 0.2, PI - 0.2, 10, Color.BLACK, 2.0)
			# tridente
			draw_line(c + Vector2(u * 0.4, u * 0.4), c + Vector2(u * 0.4, -u * 0.28), ThemeKit.SULFUR, 2.5)
			for dx in [-0.08, 0.0, 0.08]:
				draw_line(c + Vector2(u * 0.4 + dx * u, -u * 0.1), c + Vector2(u * 0.4 + dx * u, -u * 0.32), ThemeKit.SULFUR, 2.5)
		"soul":
			draw_circle(c, u * 0.42, Color(ThemeKit.ARM_M.r, ThemeKit.ARM_M.g, ThemeKit.ARM_M.b, 0.35))
			draw_circle(c, u * 0.3, Color(ThemeKit.ARM_M.r, ThemeKit.ARM_M.g, ThemeKit.ARM_M.b, 0.5))
			var chest := Color("#6a4a2e")
			ThemeKit.fill_round_rect(self, Rect2(c + Vector2(-u * 0.28, -u * 0.04), Vector2(u * 0.56, u * 0.32)), u * 0.05, chest)
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(-u * 0.3, -u * 0.04), c + Vector2(u * 0.3, -u * 0.04),
				c + Vector2(u * 0.24, -u * 0.24), c + Vector2(-u * 0.24, -u * 0.24)]), chest.lightened(0.1))
			draw_rect(Rect2(c + Vector2(-u * 0.05, -u * 0.02), Vector2(u * 0.1, u * 0.12)), ThemeKit.SULFUR)
		"loot":
			var chest2 := Color("#5a3a22")
			ThemeKit.fill_round_rect(self, Rect2(c + Vector2(-u * 0.3, -u * 0.02), Vector2(u * 0.6, u * 0.34)), u * 0.05, chest2)
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(-u * 0.32, -u * 0.02), c + Vector2(u * 0.32, -u * 0.02),
				c + Vector2(u * 0.26, -u * 0.26), c + Vector2(-u * 0.26, -u * 0.26)]), chest2.lightened(0.12))
			var gems: Array[Color] = [ThemeKit.SULFUR, ThemeKit.SOUL, ThemeKit.HP, ThemeKit.ARM_M]
			var gpos: Array[Vector2] = [Vector2(-0.14, 0.12), Vector2(0.06, 0.06), Vector2(0.18, 0.16), Vector2(-0.02, 0.2)]
			for gi in gpos.size():
				draw_circle(c + gpos[gi] * u, u * 0.05, gems[gi])
			draw_circle(c + Vector2(u * 0.28, -u * 0.3), u * 0.04, ThemeKit.EMBER_HOT)
		"sigil":
			var em := ThemeKit.EMBER
			draw_arc(c, u * 0.42, 0, TAU, 28, Color(em.r, em.g, em.b, 0.5), 2.0)
			var pts := PackedVector2Array()
			for i in 5:
				var a := -PI / 2 + TAU * float(i) / 5.0
				pts.append(c + Vector2(cos(a), sin(a)) * u * 0.4)
			var order := PackedInt32Array([0, 2, 4, 1, 3, 0])
			for i in 5:
				draw_line(pts[order[i]], pts[order[i + 1]], em, 2.0)
		_:
			# skull
			draw_circle(c + Vector2(0, -u * 0.05), u * 0.32, ThemeKit.BONE_DIM)
			draw_rect(Rect2(c + Vector2(-u * 0.18, u * 0.18), Vector2(u * 0.36, u * 0.16)), ThemeKit.BONE_DIM)
			draw_circle(c + Vector2(-u * 0.13, -u * 0.04), u * 0.07, Color.BLACK)
			draw_circle(c + Vector2(u * 0.13, -u * 0.04), u * 0.07, Color.BLACK)


func _draw_coin(pos: Vector2, r: float) -> void:
	draw_circle(pos, r, ThemeKit.SULFUR)
	draw_circle(pos, r, ThemeKit.SULFUR.darkened(0.3), false, 2.0)
	var pts := PackedVector2Array()
	for i in 5:
		var a := -PI / 2 + TAU * float(i) / 5.0
		pts.append(pos + Vector2(cos(a), sin(a)) * r * 0.62)
	var order := PackedInt32Array([0, 2, 4, 1, 3, 0])
	for i in 5:
		draw_line(pts[order[i]], pts[order[i + 1]], Color("#5a4410"), 1.5)
