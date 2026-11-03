class_name Art
extends RefCounted
## Dibujos de assets/sprites. Cada función devuelve null si falta el PNG,
## y quien la llama sigue pintando la versión hecha por código: así las
## imágenes se pueden ir añadiendo de una en una sin romper nada.

const ROOT := "res://assets/sprites/"

static var _cache := {}


static func tex(rel: String) -> Texture2D:
	if not _cache.has(rel):
		var path := ROOT + rel
		_cache[rel] = load(path) if ResourceLoader.exists(path) else null
	return _cache[rel]


## Pose del demonio (idle · eat · angry · hit). Si falta esa pose, usa idle.
static func demon(id: String, pose := "idle") -> Texture2D:
	var t := tex("demons/%s/%s.png" % [id, pose])
	if t == null and pose != "idle":
		t = tex("demons/%s/idle.png" % id)
	return t


static func demon_head(id: String) -> Texture2D:
	return tex("demons/heads/%s.png" % id)


static func cook(id: String, pose := "idle") -> Texture2D:
	var t := tex("cooks/%s/%s.png" % [id, pose])
	if t == null and pose != "idle":
		t = tex("cooks/%s/idle.png" % id)
	return t


static func food(kind: String) -> Texture2D:
	return tex("food/%s.png" % kind)


## Dibuja la textura con el borde de abajo en `foot`, `height` px de alto.
static func draw_standing(ci: CanvasItem, t: Texture2D, foot: Vector2, height: float, mod := Color.WHITE) -> void:
	var w := height * float(t.get_width()) / float(t.get_height())
	ci.draw_texture_rect(t, Rect2(foot.x - w * 0.5, foot.y - height, w, height), false, mod)


## Dibuja la textura centrada dentro de `rect` sin deformarla.
static func draw_fit(ci: CanvasItem, t: Texture2D, rect: Rect2, mod := Color.WHITE) -> void:
	var k := minf(rect.size.x / float(t.get_width()), rect.size.y / float(t.get_height()))
	var sz := Vector2(t.get_width(), t.get_height()) * k
	ci.draw_texture_rect(t, Rect2(rect.get_center() - sz * 0.5, sz), false, mod)


## Rect que cubre `area` entera con la textura (recortando lo que sobre).
static func cover_rect(t: Texture2D, area: Rect2) -> Rect2:
	var k := maxf(area.size.x / float(t.get_width()), area.size.y / float(t.get_height()))
	var sz := Vector2(t.get_width(), t.get_height()) * k
	return Rect2(area.get_center() - sz * 0.5, sz)


static func icon(kind: String) -> Texture2D:
	return tex("icons/%s.png" % kind)


## Cuadro con la imagen `rel` de `px` de lado, o null si falta el PNG.
static func picture(rel: String, px: float, mod := Color.WHITE) -> TextureRect:
	var t := tex(rel)
	if t == null:
		return null
	var r := TextureRect.new()
	r.texture = t
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(px, px)
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.modulate = mod
	return r


## Pone la imagen `rel` como icono del botón (si existe), de `px` de ancho.
static func set_button_icon(b: Button, rel: String, px := 22) -> void:
	var t := tex(rel)
	if t == null:
		return
	b.icon = t
	b.expand_icon = false
	b.add_theme_constant_override("icon_max_width", px)


## Fondo de pantalla `bg/<name>.png` cubriendo `area`. Devuelve false si falta.
static func draw_bg(ci: CanvasItem, name: String, area: Rect2, mod := Color.WHITE) -> bool:
	var t := tex("bg/%s.png" % name)
	if t == null:
		return false
	ci.draw_texture_rect(t, cover_rect(t, area), false, mod)
	return true
