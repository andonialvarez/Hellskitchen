# Encargo: todo el arte del videojuego "Hell's Kitchen"

Vas a ser el director de arte y el ilustrador de mi videojuego. Tienes que dibujar **todas las imágenes del juego (298 en total)**, de una en una, con un estilo idéntico entre todas, y entregarlas con un nombre y una carpeta exactos para meterlas directamente en el motor (Godot 4). Lee este documento entero antes de empezar y síguelo al pie de la letra durante toda la conversación.

---

## 1. El juego en dos líneas

Es un juego de clics de humor negro. Eres el cocinero de un restaurante del infierno: los demonios se asoman por el pasaplatos, cocinas en una sartén mágica para darles de comer antes de que se les acabe la paciencia y, si se enfadan, te atacan. Si eres lo bastante fuerte, puedes echarlos de un sartenazo. Hay 25 demonios, de un diablillo de barrio hasta el jefe final, y cuanto más alto es su rango, más grandes e imponentes son.

El tono es **"mono pero siniestro"**: da un poco de miedo, pero sobre todo hace gracia.

---

## 2. Estilo (obligatorio en TODAS las imágenes)

**Referencia principal:** la imagen adjunta, la hoja de personaje de **Federico, el diablillo**. Es el diseño oficial de Federico y la referencia de estilo de todo el juego. Todas las imágenes tienen que parecer del mismo artista y del mismo juego que esa hoja.

- **Línea:** contorno negro grueso y limpio en la silueta exterior, más fino en los detalles interiores.
- **Color:** colores planos con sombreado cel suave (dos o tres tonos por color), sin degradados realistas ni texturas fotográficas.
- **Luz:** luz principal suave desde arriba a la izquierda y un **contraluz naranja de fuego infernal desde abajo** en los bordes.
- **Paleta base del juego:**
  - obsidiana `#120d10`
  - piedra `#271e22`
  - rojo sangre `#7a1f22` y `#b83a34`
  - brasa `#ff6a2c`
  - brasa caliente `#ffcf5c`
  - hueso `#e7ddc6`
  - verde alma `#54e07a`
  - azufre `#c9bf3e`
- **Rangos de los demonios** (puedes usar su color como acento en ropa, gemas u ojos, sin pasarte):
  - común: gris `#9a8d84`
  - raro: azul `#4bb0c9`
  - épico: cobre `#c9622e`
  - legendario: oro `#e0b23a`
  - mítico: violeta `#b455d6`
  - infernal: rojo `#e23b3b`
- **Proporciones:** los demonios comunes son pequeños, cabezones y adorables como Federico. Según sube el rango se vuelven más altos, más detallados y más amenazantes, pero siempre con la misma línea, el mismo sombreado y el mismo humor.

---

## 3. Reglas técnicas (obligatorias)

1. **Cada imagen es un archivo aparte.** Nunca hojas de personaje, cuadrículas, varias vistas, varias poses ni variantes dentro de la misma imagen.
2. **PNG con fondo transparente de verdad** (canal alfa). No pintes un fondo de cuadros grises imitando la transparencia. Las únicas imágenes opacas son las que digan "Opaco" (los fondos de pantalla). **Si no puedes generar transparencia real**, usa en su lugar un fondo **blanco puro (#FFFFFF), totalmente liso**, sin degradados, sin sombras y sin textura; también en el interior de los marcos que digan "interior TRANSPARENTE". Yo quitaré el blanco después, así que el contorno negro del dibujo tiene que estar cerrado. Avísame una vez de cuál de las dos opciones usas y no cambies de opción a mitad del encargo.
3. **Proporción:** usa la proporción de la columna "Lienzo" de la lista (1:1, 3:2, 16:9, 3:1, 1:3 o 2:3) **a la máxima resolución** que puedas.
4. **Prohibido en todas las imágenes salvo que la descripción lo pida:** texto, letras, números, firmas, marcas de agua, marcos, suelo, sombra proyectada en el suelo, aura o resplandor de fondo, partículas o chispas sueltas alrededor y elementos de otros personajes. El juego añade por código el aura, las sombras, las partículas y el texto. El único texto de todo el encargo es el logotipo (`ui/logo.png`).
5. **Encuadre de personajes** (demonios y cocineros):
   - el cuerpo entero dentro del lienzo y centrado en horizontal
   - los pies (o la parte más baja del cuerpo) a un 4 % de la altura del borde inferior
   - al menos un 5 % libre por arriba, por encima de cuernos, orejas o coronas
   - vista de frente o tres cuartos de frente, mirando al jugador, como Federico en su hoja
   - **las 4 poses de un mismo demonio tienen la misma escala y los pies a la misma altura**, para poder cambiar de una pose a otra sin que el personaje salte
6. **Objetos e iconos:**
   - un solo objeto centrado que ocupe más o menos el 80 % del lienzo
   - ligera vista en tres cuartos
   - silueta muy clara que se entienda a 64 px
   - misma luz y misma línea que los personajes
7. **Fondos de pantalla** (16:9, opacos):
   - deja libre de detalles fuertes la zona donde irá el juego; cada descripción dice cuál es
8. **Marcos 9-slice** (panel, tarjeta, botones y barras de `ui/`):
   - la decoración va solo en las cuatro esquinas
   - los cuatro lados son tiras rectas y uniformes que se puedan estirar
   - el centro es liso
   - simétrico en horizontal y en vertical

---

## 4. Coherencia entre poses (demonios y cocineros)

Cada demonio tiene 4 poses, que el juego cambia según lo que pase:

| Archivo | Pose | Cuándo se ve |
|---|---|---|
| `idle.png` | ESPERANDO | mientras espera la comida |
| `eat.png` | COMIENDO | cuando le das de comer |
| `angry.png` | ENFADADO | cuando se le acaba la paciencia y te ataca |
| `hit.png` | GOLPEADO | cuando le echas de un sartenazo |

Cada cocinero ayudante tiene 2: `idle.png` (esperando) y `cook.png` (cocinando).

- Dibuja **siempre primero `idle.png`** y úsala como referencia de las demás poses de ese personaje: mismo diseño, mismos colores, mismas proporciones, misma ropa y accesorios, misma escala y mismo encuadre. Solo cambian la expresión, los brazos y la postura del cuerpo.
- Los cocineros son versiones pequeñas y simpáticas de los 7 primeros demonios; usa el `idle.png` de ese demonio como referencia de diseño.
- El movimiento (respirar, botar, entrar, salir, temblar) lo hace el juego por código. No dibujes estelas, líneas de movimiento ni fotogramas intermedios.

---

## 5. Cómo vamos a trabajar

**Al empezar** (en tu primera respuesta, sin generar todavía ninguna imagen):
1. Resúmeme en 5 líneas el estilo y las reglas, para confirmar que lo has entendido.
2. Comprueba si tu entorno de Python puede leer las imágenes que generas. Si puede, crea un ZIP llamado `HellsKitchen_Arte.zip` con toda la estructura de carpetas de la lista (vacía) y un archivo `manifest.csv` con la lista completa. Si no puede, dímelo en una línea y sigue igual.
3. Espera a que escriba **"empieza"**.

**En cada respuesta:**
- Avanza en orden por la lista numerada y genera **hasta 8 imágenes por respuesta**, cada una en su propio archivo y sin bajar la calidad. Antes de dibujarlas, planifica el lote para que todas compartan estilo, y revisa cada imagen contra estas reglas antes de darla por buena. No te saltes ninguna.
- **Justo antes de cada imagen**, escribe una línea con su número y su ruta, exactamente así: `#006 · demons/sabueso/eat.png`
- No cambies nunca un nombre de archivo, no inventes archivos que no estén en la lista y no juntes dos imágenes en una.
- Al terminar la respuesta, escribe `Siguiente: #NNN` y para. Espera a que escriba **"continúa"**.
- Si tu Python puede leer las imágenes, al terminar cada lote entrega un ZIP con las imágenes de ese lote dentro de sus carpetas (`HellsKitchen_Arte/...`), sin cambiarles el tamaño.

**Mis órdenes posibles:**
- `continúa`: sigue por donde ibas.
- `repite #NNN` (puede llevar un comentario): vuelve a hacer esa imagen corrigiendo lo que te diga, con el mismo número y la misma ruta.
- `ve a #NNN`: salta a ese número.

**Lote 01 (Federico):** son 4 imágenes de prueba de estilo. Al terminarlo, para y espera mi visto bueno antes de seguir, aunque no hayas llegado a 8.

**Si notas que te alejas del estilo de la hoja de Federico**, o la conversación se hace tan larga que empiezas a olvidar reglas, dímelo para que abra otra conversación y continúe desde ese número.

---

## 6. Resumen del encargo

| Lote | Imágenes | Números |
|---|---|---|
| 01 · Federico (prueba de estilo) | 4 | #001 a #004 |
| 02 · Demonios comunes y raros | 20 | #005 a #024 |
| 03 · Demonios épicos | 12 | #025 a #036 |
| 04 · Demonios legendarios | 12 | #037 a #048 |
| 05 · Demonios míticos (1) | 12 | #049 a #060 |
| 06 · Demonios míticos (2) | 12 | #061 a #072 |
| 07 · Demonios infernales (1) | 16 | #073 a #088 |
| 08 · Demonios infernales (2) | 14 | #089 a #102 |
| 09 · Cocina | 12 | #103 a #114 |
| 10 · Cocineros ayudantes | 14 | #115 a #128 |
| 11 · Interfaz: marcos, botones y logo | 17 | #129 a #145 |
| 12 · Iconos de interfaz | 28 | #146 a #173 |
| 13 · Tragaperras | 14 | #174 a #187 |
| 14 · Árbol y Despensa | 16 | #188 a #203 |
| 15 · Objetos (1) | 19 | #204 a #222 |
| 16 · Objetos (2) | 19 | #223 a #241 |
| 17 · Decoración (1) | 17 | #242 a #258 |
| 18 · Decoración (2) | 17 | #259 a #275 |
| 19 · Decoración (3) | 17 | #276 a #292 |
| 20 · Efectos | 6 | #293 a #298 |

**Total: 298 imágenes.**

Las rutas de la lista son relativas a la carpeta raíz `HellsKitchen_Arte/`.

---

## 7. Lista completa (en este orden)

### Lote 01 · Federico (prueba de estilo)

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 001 | `demons/diablillo/idle.png` | 1:1 | **Federico** (común) · ESPERANDO. Diablillo pequeño y regordete, rojo, cuernecillos color hueso, mechón de pelo en llama, sonrisa pícara con dientes de sierra, babero blanco atado al cuello, tenedor en una mano y cuchillo en la otra, cola con punta de flecha. Es EXACTAMENTE el de la hoja de personaje adjunta. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 002 | `demons/diablillo/eat.png` | 1:1 | **Federico** · COMIENDO. Mismo personaje que #001: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 003 | `demons/diablillo/angry.png` | 1:1 | **Federico** · ENFADADO. Mismo personaje que #001: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 004 | `demons/diablillo/hit.png` | 1:1 | **Federico** · GOLPEADO. Mismo personaje que #001: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |

### Lote 02 · Demonios comunes y raros

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 005 | `demons/sabueso/idle.png` | 1:1 | **Sabueso de brasas** (común) · ESPERANDO. Perro infernal a cuatro patas, piel negra carbón agrietada con brasas naranjas, humo saliendo de la nariz, babea gotas de lava, lengua fuera pidiendo comida. Vista lateral en tres cuartos. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 006 | `demons/sabueso/eat.png` | 1:1 | **Sabueso de brasas** · COMIENDO. Mismo personaje que #005: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 007 | `demons/sabueso/angry.png` | 1:1 | **Sabueso de brasas** · ENFADADO. Mismo personaje que #005: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 008 | `demons/sabueso/hit.png` | 1:1 | **Sabueso de brasas** · GOLPEADO. Mismo personaje que #005: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 009 | `demons/gargola/idle.png` | 1:1 | **Gárgola glotona** (común) · ESPERANDO. Gárgola de piedra gris encorvada con una barriga enorme y redonda, alitas de murciélago de piedra, piel de piedra agrietada, migas en la barbilla, se relame. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 010 | `demons/gargola/eat.png` | 1:1 | **Gárgola glotona** · COMIENDO. Mismo personaje que #009: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 011 | `demons/gargola/angry.png` | 1:1 | **Gárgola glotona** · ENFADADO. Mismo personaje que #009: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 012 | `demons/gargola/hit.png` | 1:1 | **Gárgola glotona** · GOLPEADO. Mismo personaje que #009: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 013 | `demons/incubo/idle.png` | 1:1 | **Íncubo goloso** (raro) · ESPERANDO. Íncubo esbelto y presumido, piel violeta, cuernos hacia atrás, ojos entornados, camisa elegante abierta, lame una cuchara. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 014 | `demons/incubo/eat.png` | 1:1 | **Íncubo goloso** · COMIENDO. Mismo personaje que #013: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 015 | `demons/incubo/angry.png` | 1:1 | **Íncubo goloso** · ENFADADO. Mismo personaje que #013: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 016 | `demons/incubo/hit.png` | 1:1 | **Íncubo goloso** · GOLPEADO. Mismo personaje que #013: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 017 | `demons/verdugo/idle.png` | 1:1 | **Verdugo de ceniza** (raro) · ESPERANDO. Verdugo encorvado de piel gris ceniza, capucha negra de verdugo, hacha enorme mellada al hombro, copos de ceniza cayéndole de los hombros. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 018 | `demons/verdugo/eat.png` | 1:1 | **Verdugo de ceniza** · COMIENDO. Mismo personaje que #017: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 019 | `demons/verdugo/angry.png` | 1:1 | **Verdugo de ceniza** · ENFADADO. Mismo personaje que #017: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 020 | `demons/verdugo/hit.png` | 1:1 | **Verdugo de ceniza** · GOLPEADO. Mismo personaje que #017: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 021 | `demons/behemot/idle.png` | 1:1 | **Behemot de sebo** (raro) · ESPERANDO. Bestia enorme y gorda hecha de sebo y grasa derretida que gotea como cera, ojillos pequeños, barriga gigante, cuernos cortos. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 022 | `demons/behemot/eat.png` | 1:1 | **Behemot de sebo** · COMIENDO. Mismo personaje que #021: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 023 | `demons/behemot/angry.png` | 1:1 | **Behemot de sebo** · ENFADADO. Mismo personaje que #021: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 024 | `demons/behemot/hit.png` | 1:1 | **Behemot de sebo** · GOLPEADO. Mismo personaje que #021: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |

### Lote 03 · Demonios épicos

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 025 | `demons/belfegor/idle.png` | 1:1 | **Barón Belfegor** (épico) · ESPERANDO. Barón demonio obeso y perezoso, cuernos de cabra, monóculo, chistera diminuta, servilleta al cuello, cara de aburrido, copa en la mano. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 026 | `demons/belfegor/eat.png` | 1:1 | **Barón Belfegor** · COMIENDO. Mismo personaje que #025: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 027 | `demons/belfegor/angry.png` | 1:1 | **Barón Belfegor** · ENFADADO. Mismo personaje que #025: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 028 | `demons/belfegor/hit.png` | 1:1 | **Barón Belfegor** · GOLPEADO. Mismo personaje que #025: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 029 | `demons/mammon/idle.png` | 1:1 | **Condesa Mammón** (épico) · ESPERANDO. Condesa demonio rolliza y avariciosa, vestido cosido con monedas de oro, cargada de joyas, bolsa de monedas en la mano, sonrisa codiciosa. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 030 | `demons/mammon/eat.png` | 1:1 | **Condesa Mammón** · COMIENDO. Mismo personaje que #029: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 031 | `demons/mammon/angry.png` | 1:1 | **Condesa Mammón** · ENFADADO. Mismo personaje que #029: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 032 | `demons/mammon/hit.png` | 1:1 | **Condesa Mammón** · GOLPEADO. Mismo personaje que #029: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 033 | `demons/sucubo/idle.png` | 1:1 | **Súcubo susurrante** (épico) · ESPERANDO. Súcubo elegante con alas de murciélago y cola larga, se lleva un dedo a los labios, de su boca sale una voluta de niebla morada, vestido oscuro. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 034 | `demons/sucubo/eat.png` | 1:1 | **Súcubo susurrante** · COMIENDO. Mismo personaje que #033: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 035 | `demons/sucubo/angry.png` | 1:1 | **Súcubo susurrante** · ENFADADO. Mismo personaje que #033: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 036 | `demons/sucubo/hit.png` | 1:1 | **Súcubo susurrante** · GOLPEADO. Mismo personaje que #033: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |

### Lote 04 · Demonios legendarios

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 037 | `demons/belial/idle.png` | 1:1 | **Conde Belial** (legendario) · ESPERANDO. Conde demonio alto y señorial, armadura negra y dorada, capa carmesí larga, pelo engominado hacia atrás, cuernos curvos, pose arrogante. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 038 | `demons/belial/eat.png` | 1:1 | **Conde Belial** · COMIENDO. Mismo personaje que #037: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 039 | `demons/belial/angry.png` | 1:1 | **Conde Belial** · ENFADADO. Mismo personaje que #037: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 040 | `demons/belial/hit.png` | 1:1 | **Conde Belial** · GOLPEADO. Mismo personaje que #037: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 041 | `demons/fenrix/idle.png` | 1:1 | **Duque Fenrix** (legendario) · ESPERANDO. Duque lobo demoníaco a dos patas, melena de fuego, armadura de hierro oscuro con banda ducal, ojos amarillos brillantes, sonrisa afilada. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 042 | `demons/fenrix/eat.png` | 1:1 | **Duque Fenrix** · COMIENDO. Mismo personaje que #041: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 043 | `demons/fenrix/angry.png` | 1:1 | **Duque Fenrix** · ENFADADO. Mismo personaje que #041: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 044 | `demons/fenrix/hit.png` | 1:1 | **Duque Fenrix** · GOLPEADO. Mismo personaje que #041: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 045 | `demons/lilith_m/idle.png` | 1:1 | **Marquesa Lilith** (legendario) · ESPERANDO. Marquesa demonio de piel pálida, pelo negro largo, cuello de plumas de búho, serpiente negra enroscada en el brazo, sonrisa misteriosa. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 046 | `demons/lilith_m/eat.png` | 1:1 | **Marquesa Lilith** · COMIENDO. Mismo personaje que #045: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 047 | `demons/lilith_m/angry.png` | 1:1 | **Marquesa Lilith** · ENFADADO. Mismo personaje que #045: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 048 | `demons/lilith_m/hit.png` | 1:1 | **Marquesa Lilith** · GOLPEADO. Mismo personaje que #045: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |

### Lote 05 · Demonios míticos (1)

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 049 | `demons/asmodeo/idle.png` | 1:1 | **Asmodeo, Rey de la Ira** (mítico) · ESPERANDO. Rey demonio musculoso de tres cabezas (toro, hombre y carnero), corona al rojo vivo, furioso, vapor saliendo de los hombros. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 050 | `demons/asmodeo/eat.png` | 1:1 | **Asmodeo, Rey de la Ira** · COMIENDO. Mismo personaje que #049: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 051 | `demons/asmodeo/angry.png` | 1:1 | **Asmodeo, Rey de la Ira** · ENFADADO. Mismo personaje que #049: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 052 | `demons/asmodeo/hit.png` | 1:1 | **Asmodeo, Rey de la Ira** · GOLPEADO. Mismo personaje que #049: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 053 | `demons/leviatan/idle.png` | 1:1 | **Leviatán Menor** (mítico) · ESPERANDO. Serpiente marina demoníaca erguida, escamas verde azulado oscuro, aletas en los brazos, branquias, boca llena de colmillos, chorreando agua. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 054 | `demons/leviatan/eat.png` | 1:1 | **Leviatán Menor** · COMIENDO. Mismo personaje que #053: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 055 | `demons/leviatan/angry.png` | 1:1 | **Leviatán Menor** · ENFADADO. Mismo personaje que #053: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 056 | `demons/leviatan/hit.png` | 1:1 | **Leviatán Menor** · GOLPEADO. Mismo personaje que #053: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 057 | `demons/behemot_m/idle.png` | 1:1 | **Behemot Mayor** (mítico) · ESPERANDO. Bestia colosal como una montaña, mezcla de hipopótamo y toro, piel rocosa, colmillos enormes, ojillos humeantes, pesadísimo. Más grande e imponente que el Behemot de sebo. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 058 | `demons/behemot_m/eat.png` | 1:1 | **Behemot Mayor** · COMIENDO. Mismo personaje que #057: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 059 | `demons/behemot_m/angry.png` | 1:1 | **Behemot Mayor** · ENFADADO. Mismo personaje que #057: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 060 | `demons/behemot_m/hit.png` | 1:1 | **Behemot Mayor** · GOLPEADO. Mismo personaje que #057: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |

### Lote 06 · Demonios míticos (2)

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 061 | `demons/astaroth/idle.png` | 1:1 | **Astaroth el Cornudo** (mítico) · ESPERANDO. Príncipe demonio demacrado con cuernos en espiral enormes, una víbora viva en la mano, túnica real hecha jirones, sonrisa cruel. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 062 | `demons/astaroth/eat.png` | 1:1 | **Astaroth el Cornudo** · COMIENDO. Mismo personaje que #061: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 063 | `demons/astaroth/angry.png` | 1:1 | **Astaroth el Cornudo** · ENFADADO. Mismo personaje que #061: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 064 | `demons/astaroth/hit.png` | 1:1 | **Astaroth el Cornudo** · GOLPEADO. Mismo personaje que #061: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 065 | `demons/belcebu/idle.png` | 1:1 | **Belcebú, Señor de las Moscas** (mítico) · ESPERANDO. Demonio señorial con cabeza de mosca gigante y ojos compuestos, alas de insecto, túnica rica, unas pocas moscas pegadas a su silueta (sin enjambre suelto). Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 066 | `demons/belcebu/eat.png` | 1:1 | **Belcebú, Señor de las Moscas** · COMIENDO. Mismo personaje que #065: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 067 | `demons/belcebu/angry.png` | 1:1 | **Belcebú, Señor de las Moscas** · ENFADADO. Mismo personaje que #065: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 068 | `demons/belcebu/hit.png` | 1:1 | **Belcebú, Señor de las Moscas** · GOLPEADO. Mismo personaje que #065: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 069 | `demons/moloch/idle.png` | 1:1 | **Moloch el Devorador** (mítico) · ESPERANDO. Demonio gigante con cabeza de toro cuya barriga es un horno abierto lleno de fuego, cadenas de hierro, manos extendidas esperando comida. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 070 | `demons/moloch/eat.png` | 1:1 | **Moloch el Devorador** · COMIENDO. Mismo personaje que #069: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 071 | `demons/moloch/angry.png` | 1:1 | **Moloch el Devorador** · ENFADADO. Mismo personaje que #069: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 072 | `demons/moloch/hit.png` | 1:1 | **Moloch el Devorador** · GOLPEADO. Mismo personaje que #069: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |

### Lote 07 · Demonios infernales (1)

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 073 | `demons/mefisto/idle.png` | 1:1 | **Mefistófeles** (infernal) · ESPERANDO. Diablo caballero elegante, perilla puntiaguda, traje de terciopelo rojo, bastón, pergamino de contrato que arde en la punta, sonrisa astuta. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 074 | `demons/mefisto/eat.png` | 1:1 | **Mefistófeles** · COMIENDO. Mismo personaje que #073: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 075 | `demons/mefisto/angry.png` | 1:1 | **Mefistófeles** · ENFADADO. Mismo personaje que #073: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 076 | `demons/mefisto/hit.png` | 1:1 | **Mefistófeles** · GOLPEADO. Mismo personaje que #073: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 077 | `demons/baal/idle.png` | 1:1 | **Baal Supremo** (infernal) · ESPERANDO. Rey demonio monstruoso de tres cabezas (gato, hombre y sapo) sobre un cuerpo con patas largas de araña, corona de oro. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 078 | `demons/baal/eat.png` | 1:1 | **Baal Supremo** · COMIENDO. Mismo personaje que #077: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 079 | `demons/baal/angry.png` | 1:1 | **Baal Supremo** · ENFADADO. Mismo personaje que #077: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 080 | `demons/baal/hit.png` | 1:1 | **Baal Supremo** · GOLPEADO. Mismo personaje que #077: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 081 | `demons/dagon/idle.png` | 1:1 | **Dagon de las Profundidades** (infernal) · ESPERANDO. Hombre pez gigantesco del abismo, escamas oscuras con puntos bioluminiscentes, garras palmeadas, algas y percebes. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 082 | `demons/dagon/eat.png` | 1:1 | **Dagon de las Profundidades** · COMIENDO. Mismo personaje que #081: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 083 | `demons/dagon/angry.png` | 1:1 | **Dagon de las Profundidades** · ENFADADO. Mismo personaje que #081: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 084 | `demons/dagon/hit.png` | 1:1 | **Dagon de las Profundidades** · GOLPEADO. Mismo personaje que #081: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 085 | `demons/abaddon/idle.png` | 1:1 | **Abaddon el Destructor** (infernal) · ESPERANDO. Demonio acorazado con alas de langosta y casco con forma de langosta, aureola rota humeante, apocalíptico y amenazante. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 086 | `demons/abaddon/eat.png` | 1:1 | **Abaddon el Destructor** · COMIENDO. Mismo personaje que #085: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 087 | `demons/abaddon/angry.png` | 1:1 | **Abaddon el Destructor** · ENFADADO. Mismo personaje que #085: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 088 | `demons/abaddon/hit.png` | 1:1 | **Abaddon el Destructor** · GOLPEADO. Mismo personaje que #085: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |

### Lote 08 · Demonios infernales (2)

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 089 | `demons/samael/idle.png` | 1:1 | **Samael, Portador de Muerte** (infernal) · ESPERANDO. Ángel caído pálido con enormes alas negras de plumas, guadaña larga, ojos verde veneno, sereno y aterrador. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 090 | `demons/samael/eat.png` | 1:1 | **Samael, Portador de Muerte** · COMIENDO. Mismo personaje que #089: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 091 | `demons/samael/angry.png` | 1:1 | **Samael, Portador de Muerte** · ENFADADO. Mismo personaje que #089: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 092 | `demons/samael/hit.png` | 1:1 | **Samael, Portador de Muerte** · GOLPEADO. Mismo personaje que #089: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 093 | `demons/lilith_s/idle.png` | 1:1 | **Lilith Suprema** (infernal) · ESPERANDO. Reina de los demonios, alas oscuras enormes, corona de espinas negras, serpientes en el pelo, vestido como un cielo nocturno, majestuosa. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 094 | `demons/lilith_s/eat.png` | 1:1 | **Lilith Suprema** · COMIENDO. Mismo personaje que #093: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 095 | `demons/lilith_s/angry.png` | 1:1 | **Lilith Suprema** · ENFADADO. Mismo personaje que #093: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 096 | `demons/lilith_s/hit.png` | 1:1 | **Lilith Suprema** · GOLPEADO. Mismo personaje que #093: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 097 | `demons/lucifer/idle.png` | 1:1 | **El Cocinero Original** (infernal (jefe final secreto)) · ESPERANDO. Ángel caído bellísimo con gorro de chef en llamas y delantal blanco de cocinero manchado, aureola dorada agrietada, alas plegadas y chamuscadas, cuchillo de carnicero en la mano, tranquilo y aterrador. Pose: De pie mirando al jugador, hambriento e ilusionado, listo para comer. Es la pose base: la que más se ve. |
| 098 | `demons/lucifer/eat.png` | 1:1 | **El Cocinero Original** · COMIENDO. Mismo personaje que #097: usa esa imagen como referencia. Pose: Masticando a dos carrillos con los ojos cerrados de gusto, mejillas llenas, alguna miga pegada a la cara. Contento. |
| 099 | `demons/lucifer/angry.png` | 1:1 | **El Cocinero Original** · ENFADADO. Mismo personaje que #097: usa esa imagen como referencia. Pose: Se le acabó la paciencia: furioso, dientes apretados, ceño fruncido, en pose de ataque (puño, garra o arma levantada). |
| 100 | `demons/lucifer/hit.png` | 1:1 | **El Cocinero Original** · GOLPEADO. Mismo personaje que #097: usa esa imagen como referencia. Pose: Acaba de recibir un sartenazo: echado hacia atrás, ojos apretados o en espiral, mueca de dolor, a punto de salir volando. |
| 101 | `demons/_unknown.png` | 1:1 | Silueta de demonio desconocido para el códice: silueta negra lisa con cuernos y un signo de interrogación naranja brillante en el pecho. |
| 102 | `demons/_crown.png` | 1:1 | Corona pequeña de demonio coronado: oro con tres puntas y gemas color brasa. Flota sobre la cabeza, así que va sola. |

### Lote 09 · Cocina

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 103 | `kitchen/wall.png` | 16:9 | Fondo de la cocina infernal: pared de piedra de obsidiana con grietas de lava que brillan, cadenas y ganchos colgando, humo tenue. En el centro de la mitad superior, un hueco rectangular oscuro (pasaplatos) donde aparecerá el demonio. Sin personajes. Opaco, sin transparencia. |
| 104 | `kitchen/window.png` | 1:1 | Marco del pasaplatos: arco rectangular hecho de huesos y vértebras con dos calaveras en las esquinas de abajo. El interior del marco es TRANSPARENTE. Visto de frente. |
| 105 | `kitchen/counter.png` | 3:1 | Encimera de piedra negra con bordes de hierro remachado que cruza toda la imagen de lado a lado; vista de frente y un poco desde arriba. |
| 106 | `kitchen/pan.png` | 1:1 | Sartén pesada de hierro colado negro vista desde arriba en tres cuartos, mango largo hacia la derecha, interior vacío con reflejos naranjas de brasas. |
| 107 | `kitchen/pentagram.png` | 1:1 | Pentagrama dentro de un círculo, tallado y brillando en naranja lava, visto totalmente desde arriba (círculo perfecto). Fondo transparente. Se girará por código. |
| 108 | `kitchen/chain.png` | 1:3 | Trozo de cadena de hierro vertical, recta, centrada, de arriba abajo de la imagen, para repetirla en vertical. |
| 109 | `kitchen/skull.png` | 1:1 | Calavera decorativa color hueso, de frente, con una vela derretida encima. |
| 110 | `food/salchicha.png` | 1:1 | Salchicha a la brasa con marcas de parrilla, jugosa y recién hecha. |
| 111 | `food/costilla.png` | 1:1 | Costilla con mucha carne y el hueso a la vista, brillante de salsa. |
| 112 | `food/ojo.png` | 1:1 | Globo ocular frito con iris verde, bordes tostados, entre gracioso y asqueroso. |
| 113 | `food/dedo.png` | 1:1 | Dedo a la parrilla con su uña, como si fuera una salchicha, estilo cartoon nada realista. |
| 114 | `food/calamar.png` | 1:1 | Anilla de calamar frita con tentáculos pequeños, tono morado. |

### Lote 10 · Cocineros ayudantes

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 115 | `cooks/diablillo/idle.png` | 1:1 | **Cocinero Federico** · ESPERANDO. El demonio de #001 en versión ayudante: usa esa imagen como referencia de diseño. Versión pequeña y simpática del demonio, de ayudante de cocina: gorro de chef blanco y delantal, cuchara de madera en la mano, de pie. |
| 116 | `cooks/diablillo/cook.png` | 1:1 | **Cocinero Federico** · COCINANDO. Mismo personaje que #115. El mismo ayudante removiendo con energía una olla pequeña humeante que sostiene él mismo, concentrado. |
| 117 | `cooks/sabueso/idle.png` | 1:1 | **Cocinero Sabueso de brasas** · ESPERANDO. El demonio de #005 en versión ayudante: usa esa imagen como referencia de diseño. Versión pequeña y simpática del demonio, de ayudante de cocina: gorro de chef blanco y delantal, cuchara de madera en la mano, de pie. |
| 118 | `cooks/sabueso/cook.png` | 1:1 | **Cocinero Sabueso de brasas** · COCINANDO. Mismo personaje que #117. El mismo ayudante removiendo con energía una olla pequeña humeante que sostiene él mismo, concentrado. |
| 119 | `cooks/gargola/idle.png` | 1:1 | **Cocinero Gárgola glotona** · ESPERANDO. El demonio de #009 en versión ayudante: usa esa imagen como referencia de diseño. Versión pequeña y simpática del demonio, de ayudante de cocina: gorro de chef blanco y delantal, cuchara de madera en la mano, de pie. |
| 120 | `cooks/gargola/cook.png` | 1:1 | **Cocinero Gárgola glotona** · COCINANDO. Mismo personaje que #119. El mismo ayudante removiendo con energía una olla pequeña humeante que sostiene él mismo, concentrado. |
| 121 | `cooks/incubo/idle.png` | 1:1 | **Cocinero Íncubo goloso** · ESPERANDO. El demonio de #013 en versión ayudante: usa esa imagen como referencia de diseño. Versión pequeña y simpática del demonio, de ayudante de cocina: gorro de chef blanco y delantal, cuchara de madera en la mano, de pie. |
| 122 | `cooks/incubo/cook.png` | 1:1 | **Cocinero Íncubo goloso** · COCINANDO. Mismo personaje que #121. El mismo ayudante removiendo con energía una olla pequeña humeante que sostiene él mismo, concentrado. |
| 123 | `cooks/verdugo/idle.png` | 1:1 | **Cocinero Verdugo de ceniza** · ESPERANDO. El demonio de #017 en versión ayudante: usa esa imagen como referencia de diseño. Versión pequeña y simpática del demonio, de ayudante de cocina: gorro de chef blanco y delantal, cuchara de madera en la mano, de pie. |
| 124 | `cooks/verdugo/cook.png` | 1:1 | **Cocinero Verdugo de ceniza** · COCINANDO. Mismo personaje que #123. El mismo ayudante removiendo con energía una olla pequeña humeante que sostiene él mismo, concentrado. |
| 125 | `cooks/behemot/idle.png` | 1:1 | **Cocinero Behemot de sebo** · ESPERANDO. El demonio de #021 en versión ayudante: usa esa imagen como referencia de diseño. Versión pequeña y simpática del demonio, de ayudante de cocina: gorro de chef blanco y delantal, cuchara de madera en la mano, de pie. |
| 126 | `cooks/behemot/cook.png` | 1:1 | **Cocinero Behemot de sebo** · COCINANDO. Mismo personaje que #125. El mismo ayudante removiendo con energía una olla pequeña humeante que sostiene él mismo, concentrado. |
| 127 | `cooks/belfegor/idle.png` | 1:1 | **Cocinero Barón Belfegor** · ESPERANDO. El demonio de #025 en versión ayudante: usa esa imagen como referencia de diseño. Versión pequeña y simpática del demonio, de ayudante de cocina: gorro de chef blanco y delantal, cuchara de madera en la mano, de pie. |
| 128 | `cooks/belfegor/cook.png` | 1:1 | **Cocinero Barón Belfegor** · COCINANDO. Mismo personaje que #127. El mismo ayudante removiendo con energía una olla pequeña humeante que sostiene él mismo, concentrado. |

### Lote 11 · Interfaz: marcos, botones y logo

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 129 | `ui/panel.png` | 1:1 | Marco de panel de menú: placa de piedra oscura con borde de hierro negro y remaches, pequeñas calaveras o cuernos SOLO en las cuatro esquinas, bordes rectos iguales que se puedan estirar, centro liso y oscuro sin dibujo. Rellena toda la imagen. |
| 130 | `ui/card.png` | 1:1 | Tarjeta pequeña para objetos y demonios del códice: placa de piedra más clara (#2f2429) con borde fino de hueso, esquinas redondeadas, centro liso. Rellena toda la imagen. |
| 131 | `ui/button.png` | 3:1 | Botón normal rectangular apaisado: placa de piedra oscura con borde de hierro, esquinas con remaches, centro liso SIN texto. Ocupa casi toda la imagen. |
| 132 | `ui/button_primary.png` | 3:1 | Botón principal grande rectangular apaisado: placa roja sangre (#7a1f22) con borde de hueso y brasas en las esquinas, centro liso SIN texto. Ocupa casi toda la imagen. |
| 133 | `ui/bar_frame.png` | 3:1 | Marco de barra de progreso horizontal larga y fina, de hierro negro con tornillos en los extremos, interior TRANSPARENTE. |
| 134 | `ui/bar_fill.png` | 3:1 | Relleno de barra horizontal largo y fino, de color gris claro con textura de lava suave (el juego lo teñirá de rojo, naranja o verde). Sin marco. |
| 135 | `ui/frame_comun.png` | 1:1 | Marco cuadrado para icono de objeto común: hierro gris (#9a8d84) sencillo, interior TRANSPARENTE. |
| 136 | `ui/frame_raro.png` | 1:1 | Marco cuadrado para icono de objeto raro: acero azulado (#4bb0c9) con remaches, interior TRANSPARENTE. |
| 137 | `ui/frame_epico.png` | 1:1 | Marco cuadrado para icono de objeto épico: cobre (#c9622e) con pequeños cuernos en las esquinas, interior TRANSPARENTE. |
| 138 | `ui/frame_legendario.png` | 1:1 | Marco cuadrado para icono de objeto legendario: oro (#e0b23a) ornamentado, interior TRANSPARENTE. |
| 139 | `ui/frame_mitico.png` | 1:1 | Marco cuadrado para icono de objeto mítico: amatista (#b455d6) con runas, interior TRANSPARENTE. |
| 140 | `ui/frame_infernal.png` | 1:1 | Marco cuadrado para icono de objeto infernal: obsidiana con grietas rojas (#e23b3b) y llamitas, interior TRANSPARENTE. |
| 141 | `ui/logo.png` | 3:2 | Logotipo del juego con el texto exacto "HELL'S KITCHEN" en letras góticas gruesas, rojas y naranjas con contorno negro, como si ardieran; un cuchillo de chef y un tridente cruzados detrás y dos cuernos. Fondo transparente. Es la ÚNICA imagen que lleva texto. |
| 142 | `ui/cursor.png` | 1:1 | Cursor del ratón: tridente pequeño apuntando arriba a la izquierda, la punta del cursor es la punta del tridente. |
| 143 | `bg/menu.png` | 16:9 | Entrada de un restaurante en el infierno: puerta enorme con brillo naranja, río de lava, humo de azufre, un cartel colgante vacío sin texto. Deja libre la mitad izquierda para el logo y los botones. Sin personajes, sin texto. Opaco, sin transparencia. |
| 144 | `bg/tree.png` | 16:9 | Suelo ritual de piedra negra visto desde arriba con un pentagrama enorme y tenue tallado, velas en las cinco puntas, un fogón en el centro. Muy oscuro para que se lean los nodos del árbol encima. Sin personajes, sin texto. Opaco, sin transparencia. |
| 145 | `bg/slots.png` | 16:9 | Casino infernal oscuro: terciopelo rojo, huesos, luces cálidas desenfocadas al fondo. Centro libre para la tragaperras. Sin personajes, sin texto. Opaco, sin transparencia. |

### Lote 12 · Iconos de interfaz

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 146 | `icons/flame.png` | 1:1 | Llama del fuego infernal (tiempo de fuego). |
| 147 | `icons/ember.png` | 1:1 | Montoncito de brasas. |
| 148 | `icons/pan.png` | 1:1 | Sartén pequeña negra (cocción por clic). |
| 149 | `icons/eye.png` | 1:1 | Ojo demoníaco con iris rojo (favor). |
| 150 | `icons/soul.png` | 1:1 | Alma verde brillante (#54e07a), la moneda de almas. |
| 151 | `icons/fork.png` | 1:1 | Tenedor hecho de hueso. |
| 152 | `icons/skull.png` | 1:1 | Calavera agrietada color hueso (pactos). |
| 153 | `icons/hourglass.png` | 1:1 | Reloj de arena con marco de hueso y arena roja (paciencia). |
| 154 | `icons/cup.png` | 1:1 | Caldero pequeño de bronce maldito. |
| 155 | `icons/heart.png` | 1:1 | Corazón rojo cartoon (vida). |
| 156 | `icons/shield_p.png` | 1:1 | Escudo de acero gris azulado (armadura física). |
| 157 | `icons/shield_m.png` | 1:1 | Escudo mágico con runas azules (armadura mágica). |
| 158 | `icons/sword.png` | 1:1 | Hoja demoníaca corta con brillo naranja (ataque). |
| 159 | `icons/orb.png` | 1:1 | Orbe mágico oscuro que brilla. |
| 160 | `icons/star_full.png` | 1:1 | Estrella dorada llena (estrellas del restaurante). |
| 161 | `icons/star_empty.png` | 1:1 | La misma estrella vacía, solo contorno oscuro. |
| 162 | `icons/tree.png` | 1:1 | Pentagrama dorado pequeño (botón Árbol). |
| 163 | `icons/shop.png` | 1:1 | Saco de especias atado con tarros (botón Despensa). |
| 164 | `icons/inventory.png` | 1:1 | Delantal de chef colgado de un gancho (botón Inventario). |
| 165 | `icons/rewards.png` | 1:1 | Cofre del botín entreabierto con brillo (botón Recompensas). |
| 166 | `icons/codex.png` | 1:1 | Libro grueso con una calavera en la tapa (botón Códice). |
| 167 | `icons/slots.png` | 1:1 | Tragaperras pequeña con tres sietes de calavera (botón Tragaperras). |
| 168 | `icons/contract.png` | 1:1 | Pergamino de contrato con sello de cera roja (botón Contrato). |
| 169 | `icons/menu.png` | 1:1 | Tres huesos horizontales apilados (botón Menú). |
| 170 | `icons/sound_on.png` | 1:1 | Cuerno de demonio que suena con ondas (sonido activado). |
| 171 | `icons/sound_off.png` | 1:1 | El mismo cuerno tachado con una X de hueso (sonido apagado). |
| 172 | `icons/pause.png` | 1:1 | Dos velas negras verticales (pausa). |
| 173 | `icons/close.png` | 1:1 | X formada por dos huesos cruzados (cerrar). |

### Lote 13 · Tragaperras

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 174 | `slots/skull.png` | 1:1 | Símbolo de tragaperras: calavera agrietada sencilla. |
| 175 | `slots/imp.png` | 1:1 | Símbolo de tragaperras: diablillo carcajeándose con un tridente. |
| 176 | `slots/soul.png` | 1:1 | Símbolo de tragaperras: cofre del que sale un aura de almas verde azulada. |
| 177 | `slots/loot.png` | 1:1 | Símbolo de tragaperras: cofre rebosante de anillos, gemas y abalorios. |
| 178 | `slots/sigil.png` | 1:1 | Símbolo de tragaperras: medallón dorado con un pentagrama. |
| 179 | `slots/coin.png` | 1:1 | Moneda del infierno de oro oscuro con una calavera con cuernos en relieve. |
| 180 | `slots/machine.png` | 2:3 | Máquina tragaperras demoníaca de frente, mueble de hueso y terciopelo rojo con cuernos arriba, tres ventanas de rodillos VACÍAS y transparentes en el centro, SIN palanca y SIN texto. |
| 181 | `slots/lever.png` | 1:3 | Palanca de tragaperras sola, vertical: barra de hierro con una calavera como pomo; la base abajo del todo para poder girarla por código. |
| 182 | `slots/boons/llama_bendita.png` | 1:1 | Bendición. Llama bendita: llama dorada con una pequeña aureola. |
| 183 | `slots/boons/manos_diablo.png` | 1:1 | Bendición. Manos del diablo: dos manos rojas con garras juntas, cocinando. |
| 184 | `slots/boons/favor_infernal.png` | 1:1 | Bendición. Favor infernal: ojo demoníaco guiñando rodeado de brillo. |
| 185 | `slots/boons/piel_azufre.png` | 1:1 | Bendición. Piel de azufre: trozo de piel amarilla de azufre con escamas. |
| 186 | `slots/boons/cosecha_rica.png` | 1:1 | Bendición. Cosecha rica: saco desbordado de almas verdes. |
| 187 | `slots/boons/mano_espectral.png` | 1:1 | Bendición. Mano espectral: mano fantasmal verde translúcida con una cuchara. |

### Lote 14 · Árbol y Despensa

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 188 | `tree/hearth.png` | 1:1 | Fogón central del árbol: brasero redondo de piedra con fuego vivo, visto de frente un poco desde arriba. |
| 189 | `tree/node.png` | 1:1 | Medallón redondo de piedra con borde de hierro, centro liso (el juego lo teñirá y pondrá encima el icono de la rama). |
| 190 | `tree/branches/llama.png` | 1:1 | Icono de rama del árbol. Llama: llama de fuego naranja. |
| 191 | `tree/branches/carne.png` | 1:1 | Icono de rama del árbol. Carne: cuchillo de carnicero clavado en un trozo de carne. |
| 192 | `tree/branches/piel.png` | 1:1 | Icono de rama del árbol. Piel: escudo de escamas rojas. |
| 193 | `tree/branches/hambre.png` | 1:1 | Icono de rama del árbol. Hambre: boca de demonio abierta con colmillos y babeando. |
| 194 | `tree/branches/alma.png` | 1:1 | Icono de rama del árbol. Alma: alma verde dentro de un frasco. |
| 195 | `tree/branches/gula.png` | 1:1 | Icono de rama del árbol. Gula: plato rebosante con un tenedor clavado. |
| 196 | `shop/sal_azufre.png` | 1:1 | Mejora de la Despensa. Sal de azufre: salero de hueso con sal amarilla de azufre. |
| 197 | `shop/pimienta.png` | 1:1 | Mejora de la Despensa. Pimienta del abismo: molinillo de pimienta negro con brillo morado. |
| 198 | `shop/guindilla.png` | 1:1 | Mejora de la Despensa. Guindilla infernal: guindilla roja ardiendo. |
| 199 | `shop/polvo_hueso.png` | 1:1 | Mejora de la Despensa. Polvo de hueso: tarro de cristal con polvo blanco y un huesecillo. |
| 200 | `shop/sarten_hierro.png` | 1:1 | Mejora de la Despensa. Sartén de hierro colado: sartén negra robusta. |
| 201 | `shop/cuchillo_obs.png` | 1:1 | Mejora de la Despensa. Cuchillo de obsidiana: cuchillo de cocina de piedra negra brillante. |
| 202 | `shop/cazo_bronce.png` | 1:1 | Mejora de la Despensa. Cazo de bronce maldito: cazo de bronce con runas que brillan. |
| 203 | `shop/fuelle.png` | 1:1 | Mejora de la Despensa. Fuelle de dragón: fuelle de cuero con boquilla de cabeza de dragón soplando fuego. |

### Lote 15 · Objetos (1)

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 204 | `items/delantal_cuero.png` | 1:1 | Delantal de cuero gastado con quemaduras. |
| 205 | `items/manopla_hierro.png` | 1:1 | Manopla de horno hecha de hierro con remaches. |
| 206 | `items/gorro_lana.png` | 1:1 | Gorro de lana raído y con parches. |
| 207 | `items/cucharon_madera.png` | 1:1 | Cucharón de madera con la punta chamuscada. |
| 208 | `items/botines_hollin.png` | 1:1 | Botines cubiertos de hollín. |
| 209 | `items/panuelo_ceniza.png` | 1:1 | Pañuelo gris ceniza anudado. |
| 210 | `items/peto_escamas.png` | 1:1 | Peto hecho de escamas rojizas de dragón. |
| 211 | `items/guante_amianto.png` | 1:1 | Guante gris gordo e ignífugo con costuras. |
| 212 | `items/amuleto_sal.png` | 1:1 | Amuleto de cristal de sal negra colgado de un cordón. |
| 213 | `items/reloj_roto.png` | 1:1 | Reloj de arena agrietado que pierde arena roja. |
| 214 | `items/campana_animas.png` | 1:1 | Campanilla de bronce con volutas fantasmales. |
| 215 | `items/brasero_bolsillo.png` | 1:1 | Brasero diminuto de bolsillo lleno de carbones encendidos. |
| 216 | `items/cinturon_cond.png` | 1:1 | Cinturón de presidiario con hebilla de grillete y cadena. |
| 217 | `items/coraza_obsidiana.png` | 1:1 | Coraza de obsidiana negra brillante con grietas de lava. |
| 218 | `items/punal_femur.png` | 1:1 | Puñal tallado en un fémur. |
| 219 | `items/capa_sombra.png` | 1:1 | Capa con capucha hecha de sombra viva, bordes deshilachados en humo. |
| 220 | `items/cucharon_femur.png` | 1:1 | Cucharón tallado en un fémur con una calavera pequeña como cazo. |
| 221 | `items/corazon_brasa.png` | 1:1 | Corazón hecho de brasas incandescentes. |
| 222 | `items/libro_contratos.png` | 1:1 | Librito de cuero lleno de contratos con sellos de cera roja. |

### Lote 16 · Objetos (2)

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 223 | `items/campana_grande.png` | 1:1 | Timbre grande de latón de mostrador. |
| 224 | `items/yelmo_cornudo.png` | 1:1 | Yelmo de hierro oscuro con grandes cuernos curvos. |
| 225 | `items/guantelete_belial.png` | 1:1 | Guantelete negro y dorado con garras y un sello demoníaco. |
| 226 | `items/manto_mammon.png` | 1:1 | Manto dorado lujoso ribeteado de monedas. |
| 227 | `items/reloj_asmodeo.png` | 1:1 | Reloj de bolsillo ornamentado con llamas dentro del cristal. |
| 228 | `items/corona_menor.png` | 1:1 | Corona pequeña, torcida y deslustrada con las puntas caídas. |
| 229 | `items/guante_maestro.png` | 1:1 | Guante blanco impecable de chef con bordados de oro, brilla un poco. |
| 230 | `items/escudo_animas.png` | 1:1 | Escudo redondo con almas gritando que giran bajo un cristal. |
| 231 | `items/ojo_astaroth.png` | 1:1 | Ojo demoníaco flotante rodeado de cuernos en espiral. |
| 232 | `items/espada_moloch.png` | 1:1 | Mandoble enorme con guarda de cuernos de toro, brilla como un horno. |
| 233 | `items/manto_belcebu.png` | 1:1 | Capa hecha de incontables alas de mosca iridiscentes. |
| 234 | `items/corazon_leviatan.png` | 1:1 | Corazón enorme con escamas verde azulado y aletas. |
| 235 | `items/reloj_infinito.png` | 1:1 | Reloj de arena retorcido en forma de infinito con arena brillante. |
| 236 | `items/grimorio_pactos.png` | 1:1 | Grimorio grueso con cierre de pentagrama y runas que brillan. |
| 237 | `items/cetro_avaricia.png` | 1:1 | Cetro dorado que gotea oro fundido, cabeza tachonada de monedas. |
| 238 | `items/corona_cocinero.png` | 1:1 | Corona con forma de gorro de chef, de oro negro y llamas. |
| 239 | `items/corazon_lucifer.png` | 1:1 | Corazón de fuego negro dentro de una aureola dorada rota. |
| 240 | `items/llave_abismo.png` | 1:1 | Llave negra antigua cuyo paletón se abre a un pequeño vacío en espiral. |
| 241 | `items/sello_supremo.png` | 1:1 | Sello de cera roja enorme con un pentagrama que brilla. |

### Lote 17 · Decoración (1)

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 242 | `decor/velas.png` | 1:1 | Grupo de velas negras con cera chorreando. |
| 243 | `decor/alfombra.png` | 1:1 | Alfombra de piel roja enrollada a medias. |
| 244 | `decor/manteles.png` | 1:1 | Mantel de arpillera doblado. |
| 245 | `decor/farolillos.png` | 1:1 | Ristra de farolillos hechos de hueso. |
| 246 | `decor/arana.png` | 1:1 | Lámpara de araña hecha de huesos con velas. |
| 247 | `decor/retrato.png` | 1:1 | Retrato enmarcado y ornamentado de un chef demonio presumido. |
| 248 | `decor/brasero_dec.png` | 1:1 | Brasero ornamental de hierro con llamas. |
| 249 | `decor/tapiz.png` | 1:1 | Tapiz de pared hecho con piel de sabueso infernal. |
| 250 | `decor/candelabro.png` | 1:1 | Candelabro hecho de fémures. |
| 251 | `decor/vitrina.png` | 1:1 | Vitrina de cristal con cabezas de demonio reducidas. |
| 252 | `decor/mantel.png` | 1:1 | Mantel brillante de seda de araña con dibujo de telaraña. |
| 253 | `decor/acuario.png` | 1:1 | Acuario redondo con almas tristes nadando. |
| 254 | `decor/reloj_grande.png` | 1:1 | Reloj de pie infernal con péndulo de calavera. |
| 255 | `decor/fuente.png` | 1:1 | Fuente gótica de la que mana sangre. |
| 256 | `decor/estrella.png` | 1:1 | Placa de estrella de guía gastronómica robada, reluciente. |
| 257 | `decor/organo.png` | 1:1 | Órgano cuyos tubos son huesos. |
| 258 | `decor/jardin.png` | 1:1 | Macetas colgantes con plantas de brasas encendidas. |

### Lote 18 · Decoración (2)

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 259 | `decor/cripta.png` | 1:1 | Entrada de cripta VIP con un cartelito de reservado sin letras. |
| 260 | `decor/estatua.png` | 1:1 | Estatua de piedra de un comensal horrorizado cuyos ojos aún se mueven. |
| 261 | `decor/lampara_alma.png` | 1:1 | Lámpara llena de mil almitas brillantes. |
| 262 | `decor/puerta_abismo.png` | 1:1 | Puerta ornamentada entreabierta a un abismo en espiral. |
| 263 | `decor/trono.png` | 1:1 | Trono hecho de calaveras. |
| 264 | `decor/reliquia_neg.png` | 1:1 | Reliquia negra misteriosa sobre un pedestal. |
| 265 | `decor/corona_local.png` | 1:1 | Corona gigante colgada de cadenas. |
| 266 | `decor/cortinas_negras.png` | 1:1 | Cortinas pesadas de terciopelo negro. |
| 267 | `decor/cadenas_pared.png` | 1:1 | Cadenas oxidadas colgando de un gancho de pared. |
| 268 | `decor/cartel_neon.png` | 1:1 | Cartel de neón rojo con forma de tridente, sin letras. |
| 269 | `decor/incensario.png` | 1:1 | Incensario colgante que suelta humo amarillo de azufre. |
| 270 | `decor/gong_entrada.png` | 1:1 | Gong grande de bronce con cara de demonio. |
| 271 | `decor/libreria_prohibida.png` | 1:1 | Estantería de grimorios prohibidos con cadenas. |
| 272 | `decor/pecera_almas.png` | 1:1 | Pecera redonda con almas-pez nadando. |
| 273 | `decor/chimenea_negra.png` | 1:1 | Chimenea de piedra que arde con fuego negro. |
| 274 | `decor/cabeza_disecada.png` | 1:1 | Cabeza de demonio disecada montada en una placa de madera. |
| 275 | `decor/escaleras_talladas.png` | 1:1 | Escalera de caracol corta tallada en hueso. |

### Lote 19 · Decoración (3)

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 276 | `decor/mural_pecados.png` | 1:1 | Mural de pared con siete figuras pecadoras. |
| 277 | `decor/lampara_eterna.png` | 1:1 | Lámpara de aceite con una llama eterna azul y blanca. |
| 278 | `decor/foso_lava.png` | 1:1 | Foso de lava pequeño y decorativo con barandilla. |
| 279 | `decor/campana_condenados.png` | 1:1 | Campana enorme agrietada con cadenas y caras que gimen. |
| 280 | `decor/vidriera_infernal.png` | 1:1 | Vidriera gótica con escenas infernales. |
| 281 | `decor/reloj_arena_alma.png` | 1:1 | Reloj de arena grande lleno de almas brillantes en vez de arena. |
| 282 | `decor/trono_menor.png` | 1:1 | Trono ornamentado de archiduque en terciopelo rojo. |
| 283 | `decor/portal_diminuto.png` | 1:1 | Portal diminuto en espiral siempre abierto dentro de un marco de piedra. |
| 284 | `decor/orbe_profecia.png` | 1:1 | Bola de cristal sobre un soporte de garra mostrando visiones. |
| 285 | `decor/jaula_alma_mayor.png` | 1:1 | Jaula de pájaro colgante con un alma grande y brillante dentro. |
| 286 | `decor/espejo_verdad.png` | 1:1 | Espejo ornamentado que refleja un esqueleto. |
| 287 | `decor/ala_caida.png` | 1:1 | Un ala de ángel caído con plumas blancas que se vuelven ceniza. |
| 288 | `decor/sello_salomon.png` | 1:1 | Anillo de sello antiguo roto con un hexagrama. |
| 289 | `decor/llave_abismo.png` | 1:1 | Llave negra gigante sobre un cojín de terciopelo. |
| 290 | `decor/corazon_forjado.png` | 1:1 | Corazón forjado en hierro negro que aún late con fuego. |
| 291 | `decor/cetro_roto.png` | 1:1 | Cetro real de oro hecho añicos. |
| 292 | `decor/trono_definitivo.png` | 1:1 | Trono inmenso de obsidiana, oro y fuego, el asiento definitivo. |

### Lote 20 · Efectos

| Nº | Archivo | Lienzo | Qué dibujar |
|---|---|---|---|
| 293 | `fx/spark.png` | 1:1 | Chispa naranja brillante con forma de estrella de cuatro puntas. |
| 294 | `fx/ember.png` | 1:1 | Brasa suelta incandescente, pequeña y redondeada. |
| 295 | `fx/smoke.png` | 1:1 | Bocanada de humo gris oscuro estilo cartoon, contorno suave. |
| 296 | `fx/flame.png` | 1:1 | Llama suelta del fuego infernal, naranja y amarilla, con contorno. |
| 297 | `fx/soul.png` | 1:1 | Alma verde (#54e07a) flotante, como una llamita fantasma con carita feliz. |
| 298 | `fx/hit.png` | 1:1 | Estallido de impacto de cómic, estrella irregular amarilla y roja, sin texto. |
