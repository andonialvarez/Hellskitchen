# Diseño de imágenes · Hell's Kitchen

Ahora mismo **todo el arte se dibuja por código** (`_draw()` con círculos, líneas y polígonos). Este documento recoge qué hay que sustituir por dibujos reales, qué estilo usar, cómo generarlos y cómo meterlos en Godot sin romper nada.

- Prompts listos para copiar: [prompts.md](prompts.md)
- Rama de trabajo: `claude/diseno-imagenes-w4w7a6` (todavía no toca código del juego)

---

## 1. Inventario

Contado directamente del código (`src/data/*.gd` y `src/game/*.gd`).

| Grupo | Cantidad | Dónde se dibuja hoy | Qué hay ahora | Prioridad |
|---|---|---|---|---|
| Demonios (clientes) | 25 | `demon_node.gd` → `_draw_biped/_quad/_hunch/_bulk/_regal` | 5 siluetas genéricas coloreadas por rareza | **1** |
| Cabezas mini de demonio (cola, servidos, códice) | 25 (se recortan de los anteriores) | `DemonNode.draw_mini_head` | un círculo con cuernos, igual para todos | **1** |
| Silueta "desconocido" del códice | 1 | `DemonNode.draw_silhouette` | círculo negro | 2 |
| Corona del demonio coronado | 1 | `demon_node.gd` → `_draw_crown` | polígono dorado | 2 |
| Sartén + mango | 1 | `kitchen_view.gd` (`_pan_c`) | elipses grises | **1** |
| Fondo de cocina (pared, pasaplatos de hueso, encimera, calaveras) | 1 fondo + 1 marco | `kitchen_view.gd` `_draw()` | rectángulos y círculos | **1** |
| Comida en la sartén | 5 (`salchicha`, `costilla`, `ojo`, `dedo`, `calamar`) | `food_props.gd` | polígonos | **1** |
| Cocineros ayudantes | 7 niveles (diablillo → belfegor) | `DemonNode.draw_cook` | mini figura de color | 2 |
| Iconos de interfaz | 14 (`flame`, `ember`, `pan`, `eye`, `soul`, `fork`, `skull`, `hourglass`, `cup`, `heart`, `shield_p`, `shield_m`, `sword`, `orb`) | `ThemeKit.draw_icon` | formas simples | 2 |
| Tragaperras: símbolos + moneda | 5 + 1 (`skull`, `imp`, `soul`, `loot`, `sigil`, moneda) | `slot_panel.gd` `_draw_sym`, `_draw_coin` | formas simples | 2 |
| Fondos de pantalla | 3 (menú, árbol pentagrama, tragaperras) | `menu.gd`, `tree_panel.gd`, `slot_panel.gd` | color plano + brillos | 2 |
| Logo del título | 1 | `menu.gd` | texto | 3 |
| Objetos equipables | 38 | `codex_panel.gd`, `inventory_panel.gd` | **solo texto**, sin icono | 3 |
| Decoración del local | 51 | `codex_panel.gd` | **solo texto**, sin icono | 3 |

**Total: unas 180 imágenes.** Con la prioridad 1 (≈ 37 imágenes) el juego ya cambia por completo, porque es lo que se ve el 90 % del tiempo.

Lo que **conviene dejar por código** porque está animado y queda bien así: el pentagrama giratorio bajo la sartén, las grietas de lava que brillan, las barras de fuego/vida/paciencia, el aura de rareza y las partículas.

---

## 2. Tres estilos posibles

### A · Cartoon gótico (recomendado)
Contorno negro grueso, colores planos con sombreado suave, "mono pero siniestro". En la línea de *Cult of the Lamb* o *Don't Starve*.
- **Por qué lo recomiendo:** encaja con el tono de humor (Federico, Gárgola glotona, Cocinero Original), se lee bien a tamaño pequeño (las cabezas de la cola miden 20 px), y es el estilo que los generadores de imágenes mantienen más coherente entre 25 personajes distintos.
- Contra: menos "épico" para los demonios finales.

### B · Pixel art 32-bit
Sprites de 64×64 o 96×96 escalados, paleta limitada. Retro, muy coherente.
- Pro: barato de retocar a mano (Aseprite, Libresprite) y animar.
- Contra: los generadores hacen pixel art "falso" (píxeles de tamaños distintos); casi siempre hay que limpiarlo a mano o pasarlo por una herramienta de "pixelate" con paleta fija.

### C · Ilustración oscura pintada
Tinta y gouache, tramado tipo grabado, colores apagados con brasas brillantes. En la línea de *Darkest Dungeon*.
- Pro: el más impresionante para los demonios míticos e infernales.
- Contra: el más difícil de mantener coherente, y a tamaño pequeño se convierte en una mancha. Cuesta más rehacer.

La paleta del juego ya está definida en `src/game/theme_kit.gd` (obsidiana `#120d10`, sangre `#7a1f22`, brasa `#ff6a2c`, brasa caliente `#ffcf5c`, hueso `#e7ddc6`, alma `#54e07a`) y los prompts la piden, para que los dibujos casen con la interfaz.

Colores de rareza (para auras y marcos): común `#9a8d84`, raro `#4bb0c9`, épico `#c9622e`, legendario `#e0b23a`, mítico `#b455d6`, infernal `#e23b3b`.

---

## 3. Cómo generar las imágenes

1. **Elige un estilo** y copia su bloque `ESTILO` de [prompts.md](prompts.md). Cada prompt es: `ESTILO + SUJETO + FORMATO`.
2. **Genera primero 3 demonios de prueba** (Federico, Gárgola glotona y Conde Belial). Si te gustan, usa la mejor imagen como **referencia de estilo** para todas las demás:
   - Midjourney: `--sref <url de la imagen>` y fija `--seed`.
   - ChatGPT / DALL·E: adjunta la imagen y di "mismo estilo que esta imagen".
   - Stable Diffusion / Leonardo: usa la imagen como *style reference* / IP-Adapter.
3. **Fondo transparente:** si tu herramienta lo permite (ChatGPT lo permite si lo pides), pide "transparent background". Si no, genera sobre fondo liso de un color que el dibujo no tenga y quítalo después con remove.bg, Photopea (gratis, en el navegador) o `rembg`.
4. **Recorta** el espacio vacío y guarda como **PNG**.
5. **Licencia:** si algún día vendes el juego, revisa las condiciones de uso comercial del generador que uses (algunos planes gratuitos no lo permiten).

### Tamaños y nombres de archivo

Nombra cada archivo con el **id del código**: así se cargan solos (ver sección 4).

| Grupo | Carpeta | Nombre | Tamaño del PNG |
|---|---|---|---|
| Demonios | `assets/sprites/demons/` | `<id>.png` (p. ej. `diablillo.png`) | 512×512, figura de pie, pies abajo del todo |
| Cabezas mini | `assets/sprites/demons/heads/` | `<id>.png` | 128×128 (recorte de la cabeza del sprite grande) |
| Cocineros | `assets/sprites/cooks/` | `<id>.png` | 256×256 |
| Comida | `assets/sprites/food/` | `<kind>.png` | 128×128 |
| Sartén | `assets/sprites/kitchen/` | `pan.png` | 512×512 |
| Fondos | `assets/sprites/bg/` | `kitchen.png`, `menu.png`, `tree.png`, `slots.png` | 1920×1080 |
| Iconos UI | `assets/sprites/icons/` | `<kind>.png` | 128×128 |
| Tragaperras | `assets/sprites/slots/` | `<sym>.png`, `coin.png` | 128×128 |
| Objetos | `assets/sprites/items/` | `<id>.png` | 128×128 |
| Decoración | `assets/sprites/decor/` | `<id>.png` | 128×128 |

Los fondos van a 1920×1080 aunque el juego sea 1280×720, porque la ventana se estira (`stretch/mode = canvas_items`) y así no se ven borrosos en pantallas grandes.

---

## 4. Cómo meterlas en Godot

El juego no usa escenas con nodos para el arte: lo pinta todo en `_draw()`. Por eso la forma menos invasiva **no** es añadir nodos `Sprite2D` por todas partes, sino cambiar cada función de dibujo para que **use el PNG si existe y, si no, siga dibujando como ahora**. Así puedes ir añadiendo imágenes de una en una y el juego nunca se rompe.

### 4.1 Un cargador común (archivo nuevo `src/game/art.gd`)

```gdscript
class_name Art
extends RefCounted
## Carga texturas por ruta y recuerda si existen. Devuelve null si falta el PNG.

static var _cache := {}


static func tex(path: String) -> Texture2D:
	if not _cache.has(path):
		_cache[path] = load(path) if ResourceLoader.exists(path) else null
	return _cache[path]


## Dibuja la textura con los pies en `foot`, escalada a `height` px de alto.
static func draw_standing(ci: CanvasItem, t: Texture2D, foot: Vector2, height: float) -> void:
	var w := height * float(t.get_width()) / float(t.get_height())
	ci.draw_texture_rect(t, Rect2(foot.x - w * 0.5, foot.y - height, w, height), false)


## Dibuja la textura centrada dentro de `rect` sin deformarla.
static func draw_fit(ci: CanvasItem, t: Texture2D, rect: Rect2) -> void:
	var k := minf(rect.size.x / t.get_width(), rect.size.y / t.get_height())
	var sz := Vector2(t.get_width(), t.get_height()) * k
	ci.draw_texture_rect(t, Rect2(rect.get_center() - sz * 0.5, sz), false)
```

### 4.2 Ejemplo: demonio (`demon_node.gd`, dentro de `_draw()`)

Donde ahora está el `match _archetype():`:

```gdscript
var t := Art.tex("res://assets/sprites/demons/%s.png" % d.get("id", ""))
if t:
	Art.draw_standing(self, t, Vector2(0, 24 * s), 150.0 * s)   # ajustar a ojo
else:
	match _archetype():
		"quad": _draw_quad(s)
		# ... igual que ahora
```

El aura, la sombra, la corona, el "respirar" (`breathe`) y el nombre siguen funcionando, porque van fuera de ese bloque. La escala `s` ya crece con el rango del demonio.

### 4.3 Lo mismo para el resto

- **Comida** (`food_props.gd`, `draw`): `Art.tex("res://assets/sprites/food/%s.png" % kind)` → `draw_fit` en un cuadrado de `40 * s`.
- **Iconos** (`ThemeKit.draw_icon`): al principio de la función, si existe `icons/<kind>.png`, `draw_fit(ci, t, rect)` y `return`.
- **Cabezas mini** (`draw_mini_head`): hoy recibe solo la rareza; habría que pasarle también el id del demonio (cambio pequeño en `kitchen_view.gd` y `codex_panel.gd`).
- **Fondo de cocina**: `draw_texture_rect(fondo, Rect2(Vector2.ZERO, size), false)` al principio de `_draw()` de `kitchen_view.gd`, en lugar de los rectángulos de obsidiana.
- **Objetos y decoración**: hoy no tienen icono; en `codex_panel.gd` → `_item_card` se añadiría un `TextureRect` a la izquierda del nombre.

### 4.4 ¿Y `Sprite2D`?

`Sprite2D` (o `TextureRect` dentro de la interfaz) es la opción buena cuando quieres **animar** con `AnimationPlayer` o por fotogramas (`AnimatedSprite2D`): por ejemplo, que el demonio parpadee o mastique. Se puede hacer más adelante sobre lo mismo: el nodo `DemonNode` es un `Node2D`, así que basta con añadirle un hijo `Sprite2D` y asignarle la textura en `set_demon()`. Para empezar, `draw_texture_rect` es menos trabajo y no cambia la estructura del juego.

### 4.5 Ajustes de importación

- Estilos A y C: dejar el filtro por defecto (Linear) para que se vean suaves al escalar.
- Estilo B (pixel art): en *Proyecto → Ajustes → Rendering → Textures → Default Texture Filter* poner **Nearest**, o se verá borroso.
- Al copiar los PNG a `assets/sprites/...`, Godot los importa solo al abrir el editor.

---

## 5. Orden de trabajo propuesto

1. Elegir estilo y generar 3 demonios de prueba.
2. Prioridad 1: 25 demonios, sartén, fondo de cocina, 5 comidas (≈ 32 imágenes).
3. Integrar en el código con el cargador `Art` (cambio pequeño, con vuelta atrás automática al dibujo actual).
4. Prioridad 2: cocineros, iconos, tragaperras, fondos de menú/árbol.
5. Prioridad 3: 38 objetos, 51 decoraciones, logo.
