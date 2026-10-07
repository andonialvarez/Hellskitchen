class_name ThemeKit
extends RefCounted
## Paleta e iconos del infierno, dibujados por código.

const OBSIDIAN := Color("#120d10")
const OBSIDIAN_2 := Color("#1a1216")
const STONE := Color("#271e22")
const STONE_2 := Color("#342a2e")
const CARD := Color("#2f2429")
const BLOOD := Color("#7a1f22")
const BLOOD_BRIGHT := Color("#b83a34")
const EMBER := Color("#ff6a2c")
const EMBER_HOT := Color("#ffcf5c")
const LAVA := Color("#ff4d1a")
const SOUL := Color("#54e07a")
const SOUL_DIM := Color("#2f6b46")
const BONE := Color("#e7ddc6")
const BONE_DIM := Color("#b7ad95")
const SULFUR := Color("#c9bf3e")
const TEXT := Color("#efe2d6")
const TEXT_DIM := Color("#a9958a")
const PANEL := Color("#160f12f2")
const LINE := Color("#3a2b2f")
const SHADOW := Color("#00000048")

const HP := Color("#d64b4b")
const ARM_P := Color("#9aa7b3")
const ARM_M := Color("#7d9fd6")
const ATK := Color("#e0923a")


static func font() -> Font:
	return ThemeDB.fallback_font


static func panel_style(col: Color, radius := 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(radius)
	sb.set_border_width_all(1)
	sb.border_color = LINE
	return sb


static func button_style(col: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 7
	sb.content_margin_bottom = 7
	return sb


static func style_button(b: Button, col := BLOOD) -> void:
	b.add_theme_stylebox_override("normal", button_style(col))
	b.add_theme_stylebox_override("hover", button_style(col.lightened(0.12)))
	b.add_theme_stylebox_override("pressed", button_style(col.darkened(0.2)))
	b.add_theme_stylebox_override("disabled", button_style(Color("#2a2226")))
	b.add_theme_color_override("font_color", TEXT)
	b.add_theme_color_override("font_disabled_color", TEXT_DIM.darkened(0.25))
	b.add_theme_font_size_override("font_size", 14)


static func fill_round_rect(ci: CanvasItem, rect: Rect2, r: float, col: Color) -> void:
	r = minf(r, minf(rect.size.x, rect.size.y) * 0.5)
	if r <= 1.0:
		ci.draw_rect(rect, col)
		return
	ci.draw_rect(Rect2(rect.position + Vector2(r, 0), Vector2(rect.size.x - 2.0 * r, rect.size.y)), col)
	ci.draw_rect(Rect2(rect.position + Vector2(0, r), Vector2(rect.size.x, rect.size.y - 2.0 * r)), col)
	ci.draw_circle(rect.position + Vector2(r, r), r, col)
	ci.draw_circle(rect.position + Vector2(rect.size.x - r, r), r, col)
	ci.draw_circle(rect.position + Vector2(r, rect.size.y - r), r, col)
	ci.draw_circle(rect.position + Vector2(rect.size.x - r, rect.size.y - r), r, col)


static func flame_poly(c: Vector2, w: float, h: float) -> PackedVector2Array:
	return PackedVector2Array([
		c + Vector2(0, -h), c + Vector2(w * 0.55, -h * 0.1),
		c + Vector2(w * 0.25, h * 0.5), c + Vector2(0, h * 0.2),
		c + Vector2(-w * 0.25, h * 0.5), c + Vector2(-w * 0.55, -h * 0.1)])


static func draw_icon(ci: CanvasItem, kind: String, rect: Rect2) -> void:
	var c := rect.position + rect.size * 0.5
	var u := minf(rect.size.x, rect.size.y)
	match kind:
		"flame":
			ci.draw_colored_polygon(flame_poly(c, u * 0.7, u * 0.5), EMBER)
			ci.draw_colored_polygon(flame_poly(c + Vector2(0, u * 0.12), u * 0.36, u * 0.28), EMBER_HOT)
		"ember":
			for i in 4:
				var a := float(i) * TAU / 4.0 + 0.4
				ci.draw_circle(c + Vector2(cos(a), sin(a)) * u * 0.28, u * 0.09, EMBER if i % 2 else EMBER_HOT)
			ci.draw_circle(c, u * 0.12, LAVA)
		"pan":
			ci.draw_line(c + Vector2(u * 0.2, 0), c + Vector2(u * 0.52, -u * 0.12), Color("#4a4045"), u * 0.1)
			ci.draw_set_transform(c, 0.0, Vector2(1, 0.62))
			ci.draw_circle(Vector2.ZERO, u * 0.4, Color("#1a1518"))
			ci.draw_circle(Vector2.ZERO, u * 0.33, Color("#0d0a0c"))
			ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		"eye":
			ci.draw_set_transform(c, 0.0, Vector2(1, 0.6))
			ci.draw_circle(Vector2.ZERO, u * 0.46, BONE)
			ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			ci.draw_circle(c, u * 0.2, BLOOD_BRIGHT)
			ci.draw_circle(c, u * 0.09, Color.BLACK)
		"soul":
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(0, -u * 0.42), c + Vector2(u * 0.3, u * 0.05),
				c + Vector2(u * 0.16, u * 0.36), c + Vector2(0, u * 0.16),
				c + Vector2(-u * 0.16, u * 0.36), c + Vector2(-u * 0.3, u * 0.05)]), SOUL)
			ci.draw_circle(c + Vector2(-u * 0.08, -u * 0.08), u * 0.06, Color(1, 1, 1, 0.5))
		"fork":
			for dx in [-0.18, 0.0, 0.18]:
				ci.draw_line(c + Vector2(dx * u, -u * 0.4), c + Vector2(dx * u, -u * 0.05), BONE, u * 0.06)
			ci.draw_line(c + Vector2(-u * 0.2, -u * 0.05), c + Vector2(u * 0.2, -u * 0.05), BONE, u * 0.08)
			ci.draw_line(c + Vector2(0, -u * 0.05), c + Vector2(0, u * 0.42), BONE, u * 0.08)
		"skull":
			ci.draw_circle(c + Vector2(0, -u * 0.05), u * 0.36, BONE)
			ci.draw_rect(Rect2(c + Vector2(-u * 0.2, u * 0.2), Vector2(u * 0.4, u * 0.18)), BONE)
			ci.draw_circle(c + Vector2(-u * 0.14, -u * 0.04), u * 0.09, OBSIDIAN)
			ci.draw_circle(c + Vector2(u * 0.14, -u * 0.04), u * 0.09, OBSIDIAN)
			ci.draw_rect(Rect2(c + Vector2(-u * 0.04, u * 0.06), Vector2(u * 0.08, u * 0.12)), OBSIDIAN)
		"hourglass":
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(-u * 0.3, -u * 0.38), c + Vector2(u * 0.3, -u * 0.38), c + Vector2(0, 0)]), Color("#4a4045"))
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(-u * 0.3, u * 0.38), c + Vector2(u * 0.3, u * 0.38), c + Vector2(0, 0)]), EMBER)
			ci.draw_line(c + Vector2(-u * 0.34, -u * 0.4), c + Vector2(u * 0.34, -u * 0.4), BONE, u * 0.07)
			ci.draw_line(c + Vector2(-u * 0.34, u * 0.4), c + Vector2(u * 0.34, u * 0.4), BONE, u * 0.07)
		"cup":
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(-u * 0.28, -u * 0.28), c + Vector2(u * 0.28, -u * 0.28),
				c + Vector2(u * 0.16, u * 0.3), c + Vector2(-u * 0.16, u * 0.3)]), Color("#4a4045"))
			ci.draw_rect(Rect2(c + Vector2(-u * 0.24, -u * 0.24), Vector2(u * 0.48, u * 0.12)), BLOOD_BRIGHT)
		"heart":
			ci.draw_circle(c + Vector2(-u * 0.16, -u * 0.08), u * 0.2, HP)
			ci.draw_circle(c + Vector2(u * 0.16, -u * 0.08), u * 0.2, HP)
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(-u * 0.34, 0), c + Vector2(u * 0.34, 0), c + Vector2(0, u * 0.4)]), HP)
		"shield_p":
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(-u * 0.32, -u * 0.34), c + Vector2(u * 0.32, -u * 0.34),
				c + Vector2(u * 0.32, u * 0.06), c + Vector2(0, u * 0.42), c + Vector2(-u * 0.32, u * 0.06)]), ARM_P)
			ci.draw_line(c + Vector2(0, -u * 0.3), c + Vector2(0, u * 0.34), OBSIDIAN, u * 0.06)
		"shield_m":
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(-u * 0.32, -u * 0.34), c + Vector2(u * 0.32, -u * 0.34),
				c + Vector2(u * 0.32, u * 0.06), c + Vector2(0, u * 0.42), c + Vector2(-u * 0.32, u * 0.06)]), ARM_M)
			ci.draw_circle(c, u * 0.14, OBSIDIAN)
		"sword":
			ci.draw_line(c + Vector2(-u * 0.3, u * 0.32), c + Vector2(u * 0.28, -u * 0.34), Color("#d9d2c6"), u * 0.12)
			ci.draw_line(c + Vector2(-u * 0.34, u * 0.12), c + Vector2(-u * 0.1, u * 0.36), ATK, u * 0.1)
		"orb":
			ci.draw_circle(c, u * 0.34, ARM_M)
			ci.draw_circle(c + Vector2(-u * 0.1, -u * 0.1), u * 0.1, Color(1, 1, 1, 0.5))
		_:
			ci.draw_circle(c, u * 0.35, TEXT_DIM)
