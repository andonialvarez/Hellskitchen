class_name DemonNode
extends Node2D
## Dibuja al demonio de la ventana según su rango. Silueta + cuernos +
## ojos brillantes + aura de rareza para los de rango alto.

var d := {}
var _t := 0.0
var _react := 0.0
var _tier := 0
var _col := Color("#9a8d84")
var _angry := 0.0
var _home := Vector2.ZERO
var _transitioning := false
var _crowned := false


func set_home(p: Vector2) -> void:
	_home = p
	position = p


## Cabecita para el recuento lateral / cola de demonios.
static func draw_mini_head(ci: CanvasItem, pos: Vector2, r: float, rarity: String) -> void:
	var col := Demons.color(rarity)
	ci.draw_circle(pos, r, col.darkened(0.25))
	ci.draw_line(pos + Vector2(-r * 0.4, -r * 0.5), pos + Vector2(-r * 0.85, -r * 1.2), col.darkened(0.45), 2.0)
	ci.draw_line(pos + Vector2(r * 0.4, -r * 0.5), pos + Vector2(r * 0.85, -r * 1.2), col.darkened(0.45), 2.0)
	ci.draw_circle(pos + Vector2(-r * 0.32, 0), r * 0.2, ThemeKit.EMBER_HOT)
	ci.draw_circle(pos + Vector2(r * 0.32, 0), r * 0.2, ThemeKit.EMBER_HOT)


## Silueta gris plana para el Códice: se ve la forma pero no qué es.
static func draw_silhouette(ci: CanvasItem, pos: Vector2, r: float) -> void:
	var col := Color(0.20, 0.18, 0.19)
	ci.draw_circle(pos, r, col)
	ci.draw_line(pos + Vector2(-r * 0.4, -r * 0.5), pos + Vector2(-r * 0.85, -r * 1.2), col, 3.0)
	ci.draw_line(pos + Vector2(r * 0.4, -r * 0.5), pos + Vector2(r * 0.85, -r * 1.2), col, 3.0)


## Cocinero contratado junto a la sartén, con gorro. Su rango sube al ascenderlo.
static func draw_cook(ci: CanvasItem, pos: Vector2, size: float, tier: int, t: float) -> void:
	var ids: Array = Game.COOK_TIERS
	var did: String = ids[clampi(tier, 0, ids.size() - 1)]
	var col := Demons.color(Demons.by_id(did).get("rarity", "comun")).darkened(0.28)
	var g := 1.0 + float(tier) * 0.06
	var s := size * g
	var p := pos + Vector2(0, sin(t * 3.0 + pos.x * 0.05) * 2.0)
	ci.draw_set_transform(p + Vector2(0, s * 0.5), 0.0, Vector2(1, 0.35))
	ci.draw_circle(Vector2.ZERO, s * 0.5, ThemeKit.SHADOW)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	ci.draw_colored_polygon(PackedVector2Array([
		p + Vector2(-s * 0.32, s * 0.42), p + Vector2(s * 0.32, s * 0.42),
		p + Vector2(s * 0.22, -s * 0.28), p + Vector2(-s * 0.22, -s * 0.28)]), col)
	ci.draw_circle(p + Vector2(0, -s * 0.42), s * 0.24, col)
	ci.draw_line(p + Vector2(-s * 0.12, -s * 0.56), p + Vector2(-s * 0.22, -s * 0.82), col.darkened(0.3), 2.0)
	ci.draw_line(p + Vector2(s * 0.12, -s * 0.56), p + Vector2(s * 0.22, -s * 0.82), col.darkened(0.3), 2.0)
	ThemeKit.fill_round_rect(ci, Rect2(p + Vector2(-s * 0.2, -s * 0.74), Vector2(s * 0.4, s * 0.2)), s * 0.07, ThemeKit.BONE)
	ci.draw_circle(p + Vector2(-s * 0.09, -s * 0.42), s * 0.05, ThemeKit.EMBER_HOT)
	ci.draw_circle(p + Vector2(s * 0.09, -s * 0.42), s * 0.05, ThemeKit.EMBER_HOT)


func set_demon(demon: Dictionary) -> void:
	d = demon
	_tier = 0
	for i in Demons.LIST.size():
		if Demons.LIST[i]["id"] == demon.get("id", ""):
			_tier = i
			break
	_col = Demons.color(demon.get("rarity", "comun"))
	_crowned = bool(demon.get("crowned", false))
	queue_redraw()
	enter_from_left()


## El nuevo demonio siempre entra deslizándose desde la izquierda.
func enter_from_left() -> void:
	_transitioning = true
	rotation = 0.0
	modulate.a = 1.0
	position = _home + Vector2(-460, 0)
	scale = Vector2.ONE * 0.85
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position", _home, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.chain().tween_callback(func() -> void: _transitioning = false)


## Al ser alimentado: se desliza hacia la derecha y desaparece.
func exit_right(cb: Callable) -> void:
	_transitioning = true
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position", _home + Vector2(460, -14), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "modulate:a", 0.0, 0.4)
	tw.chain().tween_callback(cb)


## Al ser despachado: sale disparado girando hacia una esquina de la sala.
func exit_corner(corner: Vector2, cb: Callable) -> void:
	_transitioning = true
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position", corner, 0.38).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "rotation", randf_range(-7.0, 7.0), 0.38)
	tw.tween_property(self, "scale", Vector2.ONE * 0.15, 0.38).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "modulate:a", 0.0, 0.38)
	tw.chain().tween_callback(cb)


func react() -> void:
	_react = 1.0


func _process(delta: float) -> void:
	_t += delta
	if _react > 0.0:
		_react = maxf(0.0, _react - delta * 2.5)
	if Game.shift_active and Game.current_demon.get("id", "") == d.get("id", ""):
		_angry = clampf(1.0 - Game.patience_left(), 0.0, 1.0)
	else:
		_angry = 0.0
	if not _transitioning:
		position = _home + Vector2(sin(_t * 42.0) * _angry * _angry * 5.0, 0)
	queue_redraw()


func _draw() -> void:
	if d.is_empty():
		return
	var breathe := 1.0 + sin(_t * 2.2) * 0.02 + _react * 0.12
	var sz := 0.72 + float(_tier) * 0.07     # crece con el rango
	var s := sz * breathe
	var rarity: String = d.get("rarity", "comun")

	# aura para épico y superior
	if rarity in ["epico", "legendario", "mitico", "infernal"]:
		var pulse := 0.5 + 0.5 * sin(_t * 3.0)
		for i in 3:
			var rr := (120.0 + i * 22.0) * s
			var a := (0.10 - i * 0.03) * (0.6 + 0.4 * pulse)
			draw_circle(Vector2(0, -70 * s), rr, Color(_col.r, _col.g, _col.b, a))

	# sombra
	draw_set_transform(Vector2(0, 10), 0.0, Vector2(1, 0.35))
	draw_circle(Vector2.ZERO, 70 * s, ThemeKit.SHADOW)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# aura dorada del demonio CORONADO (cuesta el doble, da moneda)
	if _crowned:
		var gp := 0.5 + 0.5 * sin(_t * 4.0)
		for i in 3:
			var rr := (110.0 + i * 26.0) * s
			draw_circle(Vector2(0, -66 * s), rr, Color(ThemeKit.SULFUR.r, ThemeKit.SULFUR.g, ThemeKit.SULFUR.b, (0.12 - i * 0.035) * (0.5 + 0.5 * gp)))

	var arche := _archetype()
	match arche:
		"quad": _draw_quad(s)
		"hunch": _draw_hunch(s)
		"bulk": _draw_bulk(s)
		"regal": _draw_regal(s)
		_: _draw_biped(s)

	if _crowned:
		_draw_crown(Vector2(0, -92 * s), s)

	# nombre + rango bajo el demonio
	var f := ThemeKit.font()
	var nm := String(d.get("name", ""))
	var tw := f.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
	draw_string(f, Vector2(-tw * 0.5, 34 * s + 20), nm, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, _col)


func _archetype() -> String:
	match d.get("id", ""):
		"sabueso": return "quad"
		"gargola", "verdugo": return "hunch"
		"behemot", "belfegor", "mammon": return "bulk"
		"belial", "asmodeo", "lucifer": return "regal"
	return "biped"


## Corona flotante del demonio coronado.
func _draw_crown(p: Vector2, s: float) -> void:
	var w := 30.0 * s
	var h := 20.0 * s
	var gold := ThemeKit.SULFUR
	var bob := sin(_t * 3.0) * 2.0
	var c := p + Vector2(0, bob)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-w * 0.5, h * 0.5), c + Vector2(w * 0.5, h * 0.5),
		c + Vector2(w * 0.42, -h * 0.15), c + Vector2(w * 0.22, h * 0.05),
		c + Vector2(0, -h * 0.6), c + Vector2(-w * 0.22, h * 0.05),
		c + Vector2(-w * 0.42, -h * 0.15)]), gold)
	draw_rect(Rect2(c + Vector2(-w * 0.5, h * 0.45), Vector2(w, h * 0.22)), gold.darkened(0.15))
	for dx in [-0.36, 0.0, 0.36]:
		draw_circle(c + Vector2(dx * w, -h * 0.2), 2.6 * s, ThemeKit.EMBER_HOT)


func _eyes(p: Vector2, r: float) -> void:
	draw_circle(p + Vector2(-r * 0.9, 0), r, ThemeKit.EMBER_HOT)
	draw_circle(p + Vector2(r * 0.9, 0), r, ThemeKit.EMBER_HOT)


func _horns(top: Vector2, spread: float, len: float) -> void:
	for sgn in [-1.0, 1.0]:
		draw_line(top + Vector2(sgn * spread, 0), top + Vector2(sgn * (spread + len * 0.5), -len), _col.darkened(0.2), 8.0)
		draw_circle(top + Vector2(sgn * (spread + len * 0.5), -len), 4.0, _col.darkened(0.2))


func _draw_biped(s: float) -> void:
	var body := _col.darkened(0.35)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-26 * s, 20 * s), Vector2(26 * s, 20 * s), Vector2(18 * s, -44 * s), Vector2(-18 * s, -44 * s)]), body)
	draw_circle(Vector2(0, -58 * s), 20 * s, body)
	_horns(Vector2(0, -74 * s), 12 * s, 20 * s)
	_eyes(Vector2(0, -58 * s), 3.5 * s)
	# cola
	draw_line(Vector2(22 * s, 16 * s), Vector2(40 * s, -6 * s), body, 5.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(40 * s, -6 * s), Vector2(48 * s, -14 * s), Vector2(44 * s, 2 * s)]), body)


func _draw_quad(s: float) -> void:
	var body := _col.darkened(0.35)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-44 * s, 22 * s), Vector2(40 * s, 22 * s), Vector2(36 * s, -14 * s), Vector2(-38 * s, -18 * s)]), body)
	# patas
	for dx in [-34, -10, 14, 30]:
		draw_line(Vector2(dx * s, 20 * s), Vector2(dx * s, 40 * s), body, 6.0)
	# cabeza
	draw_circle(Vector2(-44 * s, -18 * s), 16 * s, body)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-58 * s, -14 * s), Vector2(-70 * s, -8 * s), Vector2(-56 * s, -2 * s)]), body)
	_horns(Vector2(-44 * s, -30 * s), 8 * s, 14 * s)
	_eyes(Vector2(-48 * s, -20 * s), 3.0 * s)
	# púas
	for dx in [-30, -14, 2, 18]:
		draw_line(Vector2(dx * s, -16 * s), Vector2(dx * s + 4, -32 * s), body.darkened(0.2), 3.0)


func _draw_hunch(s: float) -> void:
	var body := _col.darkened(0.4)
	# alas plegadas
	for sgn in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(sgn * 20 * s, -30 * s), Vector2(sgn * 58 * s, -50 * s),
			Vector2(sgn * 50 * s, 6 * s), Vector2(sgn * 22 * s, 10 * s)]), body.darkened(0.15))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-24 * s, 24 * s), Vector2(24 * s, 24 * s), Vector2(16 * s, -34 * s), Vector2(-16 * s, -30 * s)]), body)
	draw_circle(Vector2(4 * s, -46 * s), 17 * s, body)   # cabeza inclinada
	_horns(Vector2(4 * s, -60 * s), 10 * s, 16 * s)
	_eyes(Vector2(4 * s, -46 * s), 3.2 * s)


func _draw_bulk(s: float) -> void:
	var body := _col.darkened(0.32)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-40 * s, 26 * s), Vector2(40 * s, 26 * s), Vector2(30 * s, -50 * s), Vector2(-30 * s, -50 * s)]), body)
	draw_circle(Vector2(0, -60 * s), 24 * s, body)
	_horns(Vector2(0, -78 * s), 18 * s, 30 * s)
	_eyes(Vector2(0, -60 * s), 4.0 * s)
	# brazos gordos
	for sgn in [-1.0, 1.0]:
		draw_line(Vector2(sgn * 34 * s, -30 * s), Vector2(sgn * 52 * s, 10 * s), body, 14.0)
	# vientre
	draw_circle(Vector2(0, 4 * s), 22 * s, body.lightened(0.06))


func _draw_regal(s: float) -> void:
	var body := _col.darkened(0.3)
	# capa
	draw_colored_polygon(PackedVector2Array([
		Vector2(-40 * s, 30 * s), Vector2(40 * s, 30 * s), Vector2(24 * s, -50 * s), Vector2(-24 * s, -50 * s)]), ThemeKit.BLOOD.darkened(0.15))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-22 * s, 26 * s), Vector2(22 * s, 26 * s), Vector2(15 * s, -46 * s), Vector2(-15 * s, -46 * s)]), body)
	draw_circle(Vector2(0, -60 * s), 19 * s, body)
	_horns(Vector2(0, -76 * s), 12 * s, 34 * s)
	_eyes(Vector2(0, -60 * s), 3.6 * s)
	# corona
	var cy := -80 * s
	draw_colored_polygon(PackedVector2Array([
		Vector2(-16 * s, cy), Vector2(16 * s, cy), Vector2(12 * s, cy - 14 * s),
		Vector2(4 * s, cy - 4 * s), Vector2(0, cy - 16 * s), Vector2(-4 * s, cy - 4 * s), Vector2(-12 * s, cy - 14 * s)]),
		ThemeKit.SULFUR)
