class_name FoodProps
extends RefCounted
## Comida random que aparece en la sartén y que "vuela" a la boca del
## demonio al alimentarlo. Puramente decorativo, sin efecto en mecánicas.

const KINDS := ["salchicha", "costilla", "ojo", "dedo", "calamar"]


static func random_kind() -> String:
	return KINDS[randi() % KINDS.size()]


static func draw(ci: CanvasItem, pos: Vector2, kind: String, s: float, t: float) -> void:
	match kind:
		"costilla": _costilla(ci, pos, s)
		"ojo": _ojo(ci, pos, s)
		"dedo": _dedo(ci, pos, s)
		"calamar": _calamar(ci, pos, s, t)
		_: _salchicha(ci, pos, s)


static func _salchicha(ci: CanvasItem, p: Vector2, s: float) -> void:
	var col := Color("#7a3b2e")
	ci.draw_colored_polygon(PackedVector2Array([
		p + Vector2(-16 * s, -6 * s), p + Vector2(16 * s, -7 * s),
		p + Vector2(18 * s, 6 * s), p + Vector2(-18 * s, 7 * s)]), col)
	ci.draw_line(p + Vector2(-10 * s, -2 * s), p + Vector2(10 * s, -3 * s), col.lightened(0.25), 2.0 * s)
	for dx in [-9, -1, 7]:
		ci.draw_line(p + Vector2(dx * s, -7 * s), p + Vector2(dx * s, 7 * s), col.darkened(0.35), 1.4 * s)


static func _costilla(ci: CanvasItem, p: Vector2, s: float) -> void:
	var meat := Color("#8a3230")
	var bone := ThemeKit.BONE
	ci.draw_colored_polygon(PackedVector2Array([
		p + Vector2(-4 * s, -14 * s), p + Vector2(6 * s, -12 * s),
		p + Vector2(18 * s, 10 * s), p + Vector2(4 * s, 16 * s)]), meat)
	ci.draw_line(p + Vector2(-4 * s, -14 * s), p + Vector2(-20 * s, -20 * s), bone, 5.0 * s)
	ci.draw_circle(p + Vector2(-20 * s, -20 * s), 4.0 * s, bone)


static func _ojo(ci: CanvasItem, p: Vector2, s: float) -> void:
	var white := Color("#e8dcc8")
	ci.draw_colored_polygon(PackedVector2Array([
		p + Vector2(-16 * s, -4 * s), p + Vector2(-4 * s, -14 * s), p + Vector2(14 * s, -6 * s),
		p + Vector2(16 * s, 6 * s), p + Vector2(2 * s, 14 * s), p + Vector2(-14 * s, 8 * s)]), white)
	var iris := Color("#4a7a45")
	ci.draw_circle(p + Vector2(1 * s, 0), 6.0 * s, iris)
	ci.draw_circle(p + Vector2(1 * s, 0), 2.6 * s, Color("#100b08"))
	ci.draw_circle(p + Vector2(-1.5 * s, -2 * s), 1.4 * s, Color(1, 1, 1, 0.6))


static func _dedo(ci: CanvasItem, p: Vector2, s: float) -> void:
	var skin := Color("#a8735f")
	ci.draw_colored_polygon(PackedVector2Array([
		p + Vector2(-16 * s, -5 * s), p + Vector2(12 * s, -6 * s), p + Vector2(16 * s, -1 * s),
		p + Vector2(16 * s, 5 * s), p + Vector2(-16 * s, 6 * s)]), skin)
	ci.draw_circle(p + Vector2(16 * s, 0), 6.0 * s, skin)
	ci.draw_colored_polygon(PackedVector2Array([
		p + Vector2(14 * s, -4 * s), p + Vector2(19 * s, -3 * s),
		p + Vector2(19 * s, 3 * s), p + Vector2(14 * s, 4 * s)]), Color("#d8cdbe"))
	for dx in [-9, -2, 5]:
		ci.draw_line(p + Vector2(dx * s, -6 * s), p + Vector2(dx * s + 2 * s, 6 * s), skin.darkened(0.3), 1.2 * s)


static func _calamar(ci: CanvasItem, p: Vector2, s: float, t: float) -> void:
	var col := Color("#8a6a8f")
	ci.draw_arc(p, 9.0 * s, 0, TAU, 14, col, 5.0 * s)
	for i in 4:
		var a := float(i) / 4.0 * TAU + t * 0.5
		ci.draw_line(p + Vector2(cos(a), sin(a)) * 9.0 * s, p + Vector2(cos(a), sin(a)) * 15.0 * s, col.darkened(0.2), 2.2 * s)
