class_name Story
extends RefCounted
## Novela gráfica "El precio de una estrella" (17 páginas).
## Cada página sale UNA vez, la primera vez que pasa su momento en el juego,
## y luego se puede releer desde el botón "Novela".
## Las imágenes están en assets/novela/pagina_XX.jpg.

const DIR := "res://assets/novela/"

## Umbrales de estrellas del local para los interludios (páginas 4 a 8).
## Cambia estos números para que salgan antes o después.
const STAR_PAGES := {4: 0.1, 5: 6.0, 6: 15.0, 7: 35.0, 8: 70.0}
## Contratos firmados para la página 16 (anuncia al jefe final).
const PACTS_FOR_16 := 3

const PAGES := [
	{"n": 1,  "part": "Introducción 1/3", "title": "La sentencia",                 "hint": "Empieza una partida nueva."},
	{"n": 2,  "part": "Introducción 2/3", "title": "Tiempo prestado",              "hint": "Empieza una partida nueva."},
	{"n": 3,  "part": "Introducción 3/3", "title": "El primer cliente",            "hint": "Empieza una partida nueva."},
	{"n": 4,  "part": "Interludio 1/5",   "title": "La primera estrella",          "hint": "Decora el local por primera vez."},
	{"n": 5,  "part": "Interludio 2/5",   "title": "La sala VIP",                  "hint": "Consigue más estrellas para el local."},
	{"n": 6,  "part": "Interludio 3/5",   "title": "La reserva del Patrón",        "hint": "Consigue más estrellas para el local."},
	{"n": 7,  "part": "Interludio 4/5",   "title": "El banquete",                  "hint": "Consigue muchas más estrellas."},
	{"n": 8,  "part": "Interludio 5/5",   "title": "La mesa del Diablo",           "hint": "Convierte el local en el mejor del infierno."},
	{"n": 9,  "part": "Episodio 1/8",     "title": "Se acabó la paciencia",        "hint": "Deja que un demonio se canse de esperar."},
	{"n": 10, "part": "Episodio 2/8",     "title": "El sartenazo",                 "hint": "Despacha a un demonio."},
	{"n": 11, "part": "Episodio 3/8",     "title": "Se apagó el fuego",            "hint": "Termina tu primer turno."},
	{"n": 12, "part": "Episodio 4/8",     "title": "La despensa y el fogón",       "hint": "Abre la Despensa o el Árbol."},
	{"n": 13, "part": "Episodio 5/8",     "title": "Pinches",                      "hint": "Contrata a un cocinero."},
	{"n": 14, "part": "Episodio 6/8",     "title": "La tragaperras",               "hint": "Abre la Tragaperras."},
	{"n": 15, "part": "Episodio 7/8",     "title": "El contrato",                  "hint": "Reúne almas para tu primer Contrato."},
	{"n": 16, "part": "Episodio 8/8",     "title": "Lo que se cuenta en la sala",  "hint": "Firma varios Contratos."},
	{"n": 17, "part": "Final",            "title": "El Cocinero Original",         "hint": "Alguien muy antiguo vendrá a probar tu cocina."},
]

static var _tex := {}


static func count() -> int:
	return PAGES.size()


static func page(n: int) -> Dictionary:
	if n < 1 or n > PAGES.size():
		return {}
	return PAGES[n - 1]


static func texture(n: int) -> Texture2D:
	if not _tex.has(n):
		var path := DIR + "pagina_%02d.jpg" % n
		_tex[n] = load(path) if ResourceLoader.exists(path) else null
	return _tex[n]
