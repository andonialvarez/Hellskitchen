# Hell's Kitchen

Juego clicker/idle con runs hecho en **Godot 4.7** (GDScript). Cocinas en una sartén infernal para servir a demonios antes de que se agoten el Fuego Infernal y tu vida.

## Cómo abrirlo
1. Instala Godot 4.7.
2. En el gestor de proyectos, importa `project.godot`.
3. Ejecuta (F5). La escena principal es `src/game/menu.tscn`.

## Estructura
- `src/autoload/` lógica del juego (`game_state.gd`) y audio.
- `src/data/` datos: demonios, objetos, árbol, Despensa, decoración, tragaperras.
- `src/game/` escenas y paneles de interfaz (el arte se dibuja por código).
- `assets/sfx/` efectos de sonido.
