# Equilibrio de Hell's Kitchen: informe de la simulación

Fecha: 2026-10-07 · rama `claude/equilibrio-0k35p1` · simulación en `tools/balance_sim/`.

## Cómo se ha medido

`sim.py` reproduce las fórmulas de `src/autoload/game_state.gd` y lee las tablas
(demonios, objetos, árbol, Despensa, decoración) directamente de los `.gd`, así
que si cambias un número y la vuelves a ejecutar ves el efecto.

El jugador simulado:

- clica a ritmo fijo (5 clics/s por defecto; también probado a 3 y a 8);
- despacha a un demonio cuando cocinarlo tardaría más que su paciencia o cuando
  despacharlo da más almas por segundo;
- entre turnos abre todo el botín y compra siempre lo más barato que pueda pagar
  (árbol, Despensa, cocineros, decoración);
- firma el contrato en cuanto puede;
- pierde 6 s entre turnos (menús).

No simula la tragaperras ni las bendiciones.

```
python3 tools/balance_sim/sim.py                      # números actuales
python3 tools/balance_sim/sim.py --variant propuesta  # con los cambios propuestos
python3 tools/balance_sim/sim.py --trace 15           # turno a turno
python3 tools/balance_sim/calibrar.py 7 2.67          # recalcula la tabla de umbrales
```

## Lo que pasa hoy

Con los números actuales todo el contenido se consume en unos 10 minutos:

| Hito | Ahora |
|---|---|
| Primer contrato | ~2,5 min |
| Segundo contrato | ~3,5 min, y salta de 1 a **48–128 pactos** de golpe |
| Árbol completo (174 nodos) | ~4 min |
| El Cocinero Original (pacto 8) servido | ~6–12 min |
| Después | el umbral del siguiente contrato es 2,5^128 × 10K: ya no se puede firmar nunca más |

Causas, por orden de peso:

1. **Las estrellas desbloquean demonios.** `effective_pacts() = pacts + estrellas / 2,5`.
   La decoración que se compra en la Despensa (~35K almas en total) da 8,3 ★ = +3 pactos
   efectivos antes del primer contrato. Con 110 ★ se suman +44.
2. **El contrato da pactos en bloque.** `pacts_gain = (almas / 10K)^0,4 × (1 + pact_gain_pct)`
   no depende del umbral, y la rama Alma del árbol suma +530 %. Con 18 M de almas se firman
   127 pactos de una vez.
3. **El volumen de platos no tiene techo.** Se pueden servir hasta 8 demonios por frame
   (480/s). La potencia de cocción crece mucho más rápido que la cocción que piden los demonios
   (4 → 34.000), así que a los pocos minutos se sirven miles de demonios por turno. Todo lo que
   cae "por plato" (almas, objetos, decoración, vales) se dispara.
4. **Las mejoras permanentes son baratas.** El nodo más caro del árbol cuesta 1,26 M y los
   demonios llegan a dar 3·10¹⁰. Además la sub-rama B de cada rama cuelga del último nodo de
   la A pero vuelve a costar 14 almas, así que en cuanto acabas la A, la B entera sale casi gratis.

### Fallo encontrado: los objetos míticos e infernales no caen nunca

En `open_reward`, la parte del botín que es decoración vale `0,12 + índice_del_demonio × 0,05`,
y después va un 32 % de vales. A partir de Asmodeo (índice 12) eso ya suma más del 100 %, así
que **los demonios míticos e infernales nunca sueltan objetos**. Los míticos solo salen de la
tragaperras, y los 4 infernales (Corona del Cocinero, Corazón de Lucifer, Llave del abismo,
Sello supremo) no se pueden conseguir de ninguna forma.

También: cualquier demonio puede soltar cualquier decoración (Federico puede soltar
El Trono Definitivo, de 9,5 ★).

### Otras observaciones (sin propuesta de números todavía)

- En ninguna simulación muere el cocinero: con despachar a tiempo, la vida y la armadura no
  llegan a importar.
- Los objetos se equipan solos y se suman todos, así que el inventario no plantea decisiones.
- Al final los turnos duran ~5 min (el fuego acumula +300 s).

## Propuesta

Objetivo que he tomado por defecto (cámbialo si quieres otro ritmo): primer contrato a los
~8–10 min, un tramo nuevo de demonios por contrato, y El Cocinero Original hacia las 4–4,5 h.

| # | Cambio | Dónde | Ahora → Propuesto |
|---|---|---|---|
| 1 | Arreglar la caída de objetos | `game_state.gd` `open_reward` | `0.12 + tier*0.05` → `minf(0.15, 0.06 + tier*0.006)` |
| 2 | La decoración cae por rareza, como los objetos | `decor.gd` `random_undropped` | cualquiera → solo rareza ≤ la del demonio |
| 3 | Las estrellas solo dan favor | `game_state.gd` `effective_pacts` | `pacts + stars/2.5` → `pacts` |
| 4 | Cada contrato da **1 pacto** | `game_state.gd` `pacts_gain` | fórmula ^0,4 → 1 |
| 5 | Tabla de umbrales por pacto | `game_state.gd` `prestige_threshold` | `10K × 2,5^pactos` → ver tabla abajo |
| 6 | "+% pactos ganados" pasa a abaratar el contrato | `prestige_threshold` | umbral ÷ (1 + pact_gain_pct) |
| 7 | Coste del árbol por posición en la cadena | `tree.gd` `SUB_COST` | 14 valores (14 → 1,26 M) → 28 valores `14 × 2,67^i`: la sub-rama A va de 14 a ~4,9 M y la B sigue de ~13 M a ~4,6·10¹² |
| 8 | Ascender cocineros más caro | `cook_upgrade_cost` | `140 × 4,3^(t+1)` → `140 × 6^(t+1)` |
| 9 | Tiempo de emplatado | `_add_cook` | hasta 8 platos por frame → máx. 4 platos/s; la cocción sobrante se pierde |

Tabla de umbrales (almas en la run para firmar el contrato que te lleva al pacto N):

| Pacto | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9+ |
|---|---|---|---|---|---|---|---|---|---|
| Umbral | 110K | 12M | 970M | 11B | 110B | 560B | 3,6T | 25T | ×10 cada uno |

No toco la tabla de demonios, ni los objetos, ni la Despensa. El contrato sigue reseteando
solo las almas (probé a resetear también cocineros y Despensa y apenas cambia el ritmo, así
que no lo propongo).

### Resultado simulado con la propuesta

Mediana de 3 partidas a 5 clics/s:

| Pacto | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| Llega a | 8–9 min | 21 min | 44 min | 1h10 | 1h45 | 2h23 | 3h15 | 4h13 |
| Turnos en ese contrato | 12 | 5 | 6 | 6 | 6–7 | 7 | 9 | 10–11 |
| Nodos del árbol | 42 | 72 | 96 | 119 | 134 | 145 | 156 | 167 |
| Estrellas | 5 | 8 | 25 | 47 | 79 | 79 | 110 | 110 |
| Objetos (de 38) | 6 | 13 | 20 | 27 | 34 | 34 | 38 | 38 |

El árbol, la decoración y los objetos se reparten a lo largo de toda la partida en vez de
caer en los primeros minutos, y los 38 objetos se pueden conseguir.

Contrapartida del tope de emplatado: a partir del pacto 1 la velocidad de clic casi no cambia
el ritmo (3 y 8 clics/s llegan al pacto 8 a la vez, ~4h05–4h15). Si quieres que clicar rápido
siga premiando, se puede subir el tope (p. ej. a 6/s) y recalibrar la tabla con `calibrar.py`.
