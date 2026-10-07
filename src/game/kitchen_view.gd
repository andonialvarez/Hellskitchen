class_name KitchenView
extends Control
## Cocina en el infierno. Gruta de obsidiana, grieta de lava, ventana de
## servicio de hueso, sartén sobre una fumarola. Dos medidores arriba:
## FUEGO INFERNAL y tu VIDA. Clic en la sartén = cocinar.

signal cook_requested

var _demon: DemonNode
var _embers: CPUParticles2D
var _t := 0.0
var _punch := 0.0
var _flash := 0.0
var _fire_ratio := 0.0
var _pan_c := Vector2.ZERO
var _pan_r := 92.0
var _win_c := Vector2.ZERO

var _food_slots: Array = []
var _food_reroll_t := 0.0
var _food_fly: Array = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_demon = DemonNode.new()
	add_child(_demon)

	for i in 3:
		_food_slots.append({"kind": FoodProps.random_kind(), "seed": randf() * TAU})
	_food_reroll_t = randf_range(3.0, 6.0)

	_embers = CPUParticles2D.new()
	_embers.amount = 40
	_embers.lifetime = 2.4
	_embers.direction = Vector2(0, -1)
	_embers.spread = 25.0
	_embers.gravity = Vector2(0, -40)
	_embers.initial_velocity_min = 30.0
	_embers.initial_velocity_max = 90.0
	_embers.scale_amount_min = 1.5
	_embers.scale_amount_max = 4.0
	_embers.color = ThemeKit.EMBER
	_embers.emitting = true
	add_child(_embers)

	Game.damaged.connect(func(_a, _t2): _flash = 1.0)
	resized.connect(_relayout)
	_relayout()


func _process(delta: float) -> void:
	_t += delta
	if _punch > 0.0:
		_punch = maxf(0.0, _punch - delta * 4.0)
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 3.0)
	_fire_ratio = clampf(Game.fire_left / maxf(1.0, Game.fire_time_max()), 0.0, 1.0) if Game.shift_active else 0.0

	_food_reroll_t -= delta
	if _food_reroll_t <= 0.0:
		_food_reroll_t = randf_range(3.5, 7.0)
		_reroll_food()

	for i in range(_food_fly.size() - 1, -1, -1):
		_food_fly[i]["t"] += delta
		if _food_fly[i]["t"] >= _food_fly[i]["dur"]:
			_food_fly.remove_at(i)

	queue_redraw()


## Cambia al azar la comida de una de las posiciones de la sartén.
func _reroll_food() -> void:
	if _food_slots.is_empty():
		return
	var i := randi() % _food_slots.size()
	_food_slots[i]["kind"] = FoodProps.random_kind()
	_food_slots[i]["seed"] = randf() * TAU


## Lanza un trocito de comida desde la sartén hacia la boca del demonio.
func spawn_food_fly(kind: String) -> void:
	_food_fly.append({
		"from": _pan_c + Vector2(0, -_pan_r * 0.35),
		"to": _win_c + Vector2(0, -30),
		"t": 0.0, "dur": 0.28, "kind": kind,
	})
	_reroll_food()


func _relayout() -> void:
	var s := size
	var kw := s.x
	_win_c = Vector2(kw * 0.5, s.y * 0.40)
	_pan_c = Vector2(kw * 0.5, s.y * 0.80)
	_pan_r = clampf(s.y * 0.13, 70.0, 110.0)
	_demon.set_home(_win_c + Vector2(0, 6))
	_embers.position = _pan_c + Vector2(0, 10)
	_embers.emission_rect_extents = Vector2(_pan_r * 0.7, 6)
	_embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	queue_redraw()


func set_demon(d: Dictionary) -> void:
	_demon.visible = not d.is_empty()
	if not d.is_empty():
		_demon.set_demon(d)


## Al servir a un demonio: el actual se va deslizando hacia la derecha,
## y el nuevo entra desde la izquierda.
func feed_transition(new_d: Dictionary) -> void:
	if not _demon.visible:
		set_demon(new_d)
		return
	_demon.exit_right(func() -> void: set_demon(new_d))


## Al despachar a un demonio: sale disparado por una esquina al azar
## de la sala, y el nuevo entra desde la izquierda.
func dispatch_transition(new_d: Dictionary) -> void:
	if not _demon.visible:
		set_demon(new_d)
		return
	var corners := [
		Vector2(-70, -70), Vector2(size.x + 70, -70),
		Vector2(-70, size.y + 70), Vector2(size.x + 70, size.y + 70)]
	var corner: Vector2 = corners[randi() % corners.size()]
	_demon.exit_corner(corner, func() -> void: set_demon(new_d))


func demon_react() -> void:
	if _demon.visible:
		_demon.react()


func pan_screen_pos() -> Vector2:
	return _pan_c + Vector2(0, -_pan_r * 0.8)


## Justo al lado del demonio de la ventana de servicio (para el "Tasty").
func demon_screen_pos() -> Vector2:
	return _win_c + Vector2(120, -28)


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		if e.position.distance_to(_pan_c) <= _pan_r * 1.15:
			_punch = 1.0
			cook_requested.emit()
			accept_event()


# ====================================================================
func _draw() -> void:
	var s := size
	var kw := s.x

	draw_rect(Rect2(0, 0, s.x, s.y), ThemeKit.OBSIDIAN)
	for i in 9:
		var y := s.y * (0.06 + 0.1 * float(i))
		draw_line(Vector2(0, y), Vector2(kw, y + sin(float(i)) * 12.0), ThemeKit.OBSIDIAN_2, 3.0)

	# medidores: fuego y vida
	var f := ThemeKit.font()
	var bar_w := (kw - 60.0) * 0.5
	var fb := Rect2(24, 18, bar_w, 18)
	draw_rect(fb, Color("#0c0809"))
	draw_rect(Rect2(fb.position, Vector2(fb.size.x * _fire_ratio, fb.size.y)),
		ThemeKit.EMBER if _fire_ratio > 0.25 else ThemeKit.BLOOD_BRIGHT)
	draw_rect(fb, ThemeKit.LINE, false, 1.5)
	draw_string(f, fb.position + Vector2(9, 13),
		("FUEGO  " + Nums.time_fmt(Game.fire_left)) if Game.shift_active else "FUEGO APAGADO",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 11, ThemeKit.OBSIDIAN)
	var hb := Rect2(24 + bar_w + 12, 18, bar_w, 18)
	var hr: float = clampf(Game.hp / maxf(1.0, Game.max_hp()), 0.0, 1.0)
	draw_rect(hb, Color("#0c0809"))
	draw_rect(Rect2(hb.position, Vector2(hb.size.x * hr, hb.size.y)), ThemeKit.HP)
	draw_rect(hb, ThemeKit.LINE, false, 1.5)
	draw_string(f, hb.position + Vector2(9, 13),
		"VIDA  %s / %s" % [Nums.fmt(Game.hp), Nums.fmt(Game.max_hp())],
		HORIZONTAL_ALIGNMENT_LEFT, -1, 11, ThemeKit.TEXT)

	# grieta de lava tras la ventana
	var glow: float = 0.28 + 0.72 * _fire_ratio + 0.06 * sin(_t * 4.0)
	var gx := kw * 0.5
	var pts := PackedVector2Array()
	for i in 11:
		var yy := s.y * float(i) / 10.0
		var off := sin(yy * 0.045 + _t * 0.6) * 24.0 + (14.0 if i % 2 else -14.0)
		pts.append(Vector2(gx + off, yy))
	for p in pts:
		draw_circle(p, 60.0, Color(ThemeKit.LAVA.r, ThemeKit.LAVA.g, ThemeKit.LAVA.b, 0.05 * glow))
		draw_circle(p, 26.0, Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, 0.07 * glow))
	for i in pts.size() - 1:
		draw_line(pts[i], pts[i + 1], Color(ThemeKit.LAVA.r, ThemeKit.LAVA.g, ThemeKit.LAVA.b, 0.55 * glow), 8.0)
		draw_line(pts[i], pts[i + 1], Color(ThemeKit.EMBER_HOT.r, ThemeKit.EMBER_HOT.g, ThemeKit.EMBER_HOT.b, 0.7 * glow), 3.0)

	# runas en la pared
	for i in 5:
		var rp := Vector2(kw * (0.16 + 0.17 * float(i)), 70.0 + (i % 2) * 10.0)
		_rune(rp, 10.0, 0.10 + 0.06 * sin(_t * 2.0 + float(i)))

	# columnas laterales: cadena + demonios servidos (rellenan el hueco)
	_draw_served_columns(s)

	# ventana de servicio (arco de hueso)
	var wr := Vector2(150, 120)
	var win := Rect2(_win_c - wr, wr * 2.0)
	draw_rect(win.grow(14), Color("#0b0709"))
	ThemeKit.fill_round_rect(self, win.grow(10), 20, ThemeKit.BONE_DIM)
	draw_rect(win, Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, 0.05 + 0.08 * glow))
	for i in 9:
		var ax := win.position.x + win.size.x * (float(i) + 0.5) / 9.0
		draw_circle(Vector2(ax, win.position.y - 6), 7, ThemeKit.BONE)
	_skull(Vector2(win.position.x - 40, win.end.y - 10), 22)
	_skull(Vector2(win.end.x + 40, win.end.y - 10), 22)

	# cola de los siguientes demonios
	_draw_queue(s, win)

	# barras del demonio actual (cocción + paciencia)
	if Game.shift_active and not Game.current_demon.is_empty():
		var bw := 280.0
		var bx := _win_c + Vector2(-bw * 0.5, 150)
		draw_rect(Rect2(bx, Vector2(bw, 14)), Color("#0c0809"))
		var rat: float = Game.demon_progress()
		draw_rect(Rect2(bx, Vector2(bw * rat, 14)), Demons.color(Game.current_demon.get("rarity", "comun")))
		draw_rect(Rect2(bx, Vector2(bw, 14)), ThemeKit.LINE, false, 1.5)
		var pat: float = Game.patience_left()
		var pcol := ThemeKit.SOUL if pat > 0.4 else ThemeKit.HP
		draw_rect(Rect2(bx + Vector2(0, 18), Vector2(bw, 6)), Color("#0c0809"))
		draw_rect(Rect2(bx + Vector2(0, 18), Vector2(bw * pat, 6)), pcol)
		if pat <= 0.0:
			draw_string(f, bx + Vector2(0, 46), "¡SE HA CANSADO DE ESPERAR!", HORIZONTAL_ALIGNMENT_LEFT, bw, 13, ThemeKit.HP)
	elif not Game.shift_active:
		var msg := "Enciende el fuego para empezar el turno"
		var mw := f.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		draw_string(f, _pan_c + Vector2(-mw * 0.5, -_pan_r - 26), msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, ThemeKit.TEXT_DIM)

	# encimera + fumarola + sartén
	var ctop := s.y * 0.64
	draw_rect(Rect2(0, ctop, kw, s.y - ctop), ThemeKit.OBSIDIAN_2)
	draw_line(Vector2(0, ctop), Vector2(kw, ctop), Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, 0.18), 3.0)
	# pentagrama grabado en la encimera bajo la sartén
	draw_set_transform(_pan_c + Vector2(0, 16), _t * 0.05, Vector2(1, 0.42))
	var pentcol := Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, 0.10 + 0.06 * _fire_ratio)
	draw_arc(Vector2.ZERO, _pan_r * 1.7, 0, TAU, 40, pentcol, 2.0)
	var pp := PackedVector2Array()
	for i in 5:
		pp.append(Vector2(cos(-PI / 2 + i * TAU * 2.0 / 5.0), sin(-PI / 2 + i * TAU * 2.0 / 5.0)) * _pan_r * 1.6)
	for i in 5:
		draw_line(pp[i], pp[(i + 1) % 5], pentcol, 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	draw_set_transform(_pan_c + Vector2(0, 14), 0.0, Vector2(1, 0.4))
	draw_circle(Vector2.ZERO, _pan_r * 1.35, Color("#241013"))
	draw_circle(Vector2.ZERO, _pan_r * 0.9, Color(ThemeKit.LAVA.r, ThemeKit.LAVA.g, ThemeKit.LAVA.b, 0.5 + 0.3 * _fire_ratio))
	draw_circle(Vector2.ZERO, _pan_r * 0.55, Color(ThemeKit.EMBER_HOT.r, ThemeKit.EMBER_HOT.g, ThemeKit.EMBER_HOT.b, 0.5 * _fire_ratio))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var pr := _pan_r * (1.0 - 0.06 * _punch)
	draw_line(_pan_c + Vector2(pr * 0.75, -6), _pan_c + Vector2(pr * 1.9, -pr * 0.5), Color("#3c343a"), 16.0)
	draw_line(_pan_c + Vector2(pr * 0.75, -8), _pan_c + Vector2(pr * 1.9, -pr * 0.5 - 2), Color("#5a4f56"), 8.0)
	draw_set_transform(_pan_c, 0.0, Vector2(1, 0.6))
	draw_circle(Vector2.ZERO, pr, Color("#241c1f"))
	draw_circle(Vector2.ZERO, pr * 0.92, Color("#140f12"))
	draw_circle(Vector2.ZERO, pr * 0.86, Color("#0c090b"))
	draw_circle(Vector2(-pr * 0.28, -pr * 0.22), pr * 0.3, Color(1, 1, 1, 0.03))
	# unas ascuas dentro de la sartén
	for i in 5:
		var ea := _t * 0.7 + float(i) * TAU / 5.0
		draw_circle(Vector2(cos(ea), sin(ea)) * pr * 0.4, 3.0, Color(ThemeKit.EMBER_HOT.r, ThemeKit.EMBER_HOT.g, ThemeKit.EMBER_HOT.b, 0.5 * _fire_ratio))

	# comida que se va cocinando (para que la sartén no se vea vacía)
	var food_pos := [Vector2(-pr * 0.32, -pr * 0.05), Vector2(pr * 0.30, -pr * 0.15), Vector2(0.02 * pr, pr * 0.35)]
	for i in _food_slots.size():
		var fs: Dictionary = _food_slots[i]
		var seed_v: float = fs["seed"]
		var jitter := Vector2(sin(_t * 6.0 + seed_v) * 2.0, cos(_t * 5.0 + seed_v) * 1.5)
		FoodProps.draw(self, food_pos[i] + jitter, String(fs["kind"]), 0.8 + 0.05 * sin(_t * 3.0 + seed_v), _t + seed_v)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	_draw_cooks(s)

	# comida volando de la sartén a la boca del demonio
	for fly in _food_fly:
		var rat: float = clampf(fly["t"] / fly["dur"], 0.0, 1.0)
		var pos: Vector2 = fly["from"].lerp(fly["to"], rat)
		pos.y -= sin(rat * PI) * 46.0
		FoodProps.draw(self, pos, String(fly["kind"]), 0.55, _t)

	draw_rect(Rect2(0, s.y - 22, s.x, 22), Color("#0a0709"))

	# destello rojo al recibir daño
	if _flash > 0.0:
		draw_rect(Rect2(0, 0, s.x, s.y), Color(ThemeKit.HP.r, ThemeKit.HP.g, ThemeKit.HP.b, 0.25 * _flash))


## Columnas laterales: una cadena de fondo y, colgando de ella, las
## cabecitas de los demonios que has servido este turno (rellenan el hueco).
func _draw_served_columns(s: Vector2) -> void:
	var f := ThemeKit.font()
	var top := 128.0
	var bot := s.y - 118.0
	var step := 26.0
	var cap := int((bot - top) / step)
	var lx := 26.0
	var rx := s.x - 26.0
	# cadena de fondo
	for cx in [lx, rx]:
		var yy := top
		while yy < bot + 10.0:
			draw_arc(Vector2(cx, yy + sin(_t * 1.3 + yy * 0.05) * 1.2), 6.0, 0, TAU, 10, Color("#332b30"), 3.0)
			yy += 16.0
	var fed: Array = Game.demons_fed_run
	var lc := 0
	var rc := 0
	for i in fed.size():
		var left := (i % 2 == 0)
		var idx := lc if left else rc
		if idx < cap:
			var pos := Vector2(lx if left else rx, top + float(idx) * step + 6.0)
			DemonNode.draw_mini_head(self, pos, 9.5, String(fed[i]))
		if left: lc += 1
		else: rc += 1
	if fed.size() > 0:
		draw_string(f, Vector2(lx - 16, bot + 22), "%d servidos" % fed.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ThemeKit.TEXT_DIM)
	if lc > cap:
		draw_string(f, Vector2(lx - 12, bot + 8), "+%d" % (lc - cap), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, ThemeKit.TEXT_DIM)
	if rc > cap:
		draw_string(f, Vector2(rx - 18, bot + 8), "+%d" % (rc - cap), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, ThemeKit.TEXT_DIM)


## Cola de los siguientes demonios, sobre la ventana.
func _draw_queue(s: Vector2, win: Rect2) -> void:
	var q: Array = Game.demon_queue
	if q.is_empty():
		return
	var f := ThemeKit.font()
	var n := mini(q.size(), 6)
	var gap := 30.0
	var x0 := _win_c.x - (float(n) - 1.0) * gap * 0.5
	var y := win.position.y - 30.0
	draw_string(f, Vector2(x0 - 78.0, y + 4.0), "Cola →", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ThemeKit.TEXT_DIM)
	for i in n:
		var r := 12.0 if i == 0 else 9.0
		DemonNode.draw_mini_head(self, Vector2(x0 + float(i) * gap, y), r, String(q[i].get("rarity", "comun")))


## Cocineros contratados, junto a la sartén. Crecen y cambian de aspecto
## a medida que los asciendes a demonios mayores.
func _draw_cooks(s: Vector2) -> void:
	var cs: Array = Game.cooks
	for i in cs.size():
		var side := -1.0 if i % 2 == 0 else 1.0
		var slot := i / 2
		var x := _pan_c.x + side * (_pan_r * 1.75 + 26.0 + float(slot) * 48.0)
		var y := _pan_c.y + 26.0 - float(slot % 2) * 10.0
		DemonNode.draw_cook(self, Vector2(x, y), 34.0, int(cs[i]), _t)


func _rune(p: Vector2, r: float, a: float) -> void:
	var c := Color(ThemeKit.EMBER.r, ThemeKit.EMBER.g, ThemeKit.EMBER.b, a)
	draw_arc(p, r, 0, TAU, 16, c, 1.5)
	# triángulo invertido dentro (sigilo)
	var tri := PackedVector2Array([p + Vector2(-r * 0.8, -r * 0.5), p + Vector2(r * 0.8, -r * 0.5), p + Vector2(0, r * 0.85)])
	for i in 3:
		draw_line(tri[i], tri[(i + 1) % 3], c, 1.5)
	draw_line(p + Vector2(0, -r * 1.4), p + Vector2(0, -r), c, 1.5)


func _skull(p: Vector2, r: float) -> void:
	draw_circle(p + Vector2(0, -r * 0.15), r, ThemeKit.BONE_DIM)
	draw_rect(Rect2(p + Vector2(-r * 0.55, r * 0.55), Vector2(r * 1.1, r * 0.5)), ThemeKit.BONE_DIM)
	draw_circle(p + Vector2(-r * 0.4, 0), r * 0.26, ThemeKit.OBSIDIAN)
	draw_circle(p + Vector2(r * 0.4, 0), r * 0.26, ThemeKit.OBSIDIAN)
