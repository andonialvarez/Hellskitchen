# Prompts para el generador de imágenes

Cada prompt se monta así: **ESTILO + SUJETO + FORMATO**. Los prompts van en inglés porque los generadores responden mejor así; la descripción en español está al lado para que sepas qué es cada cosa.

Ejemplo completo (estilo A, demonio Federico):

> 2D game character sprite, cute-but-creepy gothic cartoon style, thick clean black outlines, flat colors with soft cel shading, palette of obsidian black, blood red, ember orange and bone white, warm rim light from below as if lit by hellfire. **A small chubby red imp with tiny horns and a mischievous grin, napkin tied around his neck, holding a fork and knife, hungry.** Full body, standing, three-quarter front view, centered, whole figure inside the frame with margin, transparent background, no text, no ground, no shadow.

Consejo: fija la semilla (`--seed`) o usa la primera imagen buena como referencia de estilo (`--sref` en Midjourney, o adjuntarla en ChatGPT) para que todos salgan coherentes.

---

## ESTILO (elige uno)

**A · Cartoon gótico (recomendado)**
```
2D game sprite, cute-but-creepy gothic cartoon style, thick clean black outlines, flat colors with soft cel shading, palette of obsidian black (#120d10), blood red (#7a1f22), ember orange (#ff6a2c) and bone white (#e7ddc6), warm rim light from below as if lit by hellfire.
```

**B · Pixel art**
```
2D pixel art game sprite, 96x96 pixel art scaled up, crisp square pixels, no anti-aliasing, no blur, 1-pixel dark outline, limited 24-color palette of obsidian black, blood red, ember orange, gold and bone white, lit from below by hellfire.
```

**C · Ilustración oscura pintada**
```
2D dark fantasy game illustration, hand-painted gouache with ink linework and engraving-style hatching, muted desaturated colors with glowing ember-orange accents, dramatic underlighting from hellfire, grim but slightly humorous.
```

## FORMATO (según el tipo de imagen)

| Tipo | Pegar al final |
|---|---|
| Personaje (demonios, cocineros) | `Full body, standing, three-quarter front view, centered, whole figure inside the frame with margin, transparent background, no text, no ground, no shadow.` |
| Objeto / icono | `Single object game icon, centered, slight three-quarter view, fills 80% of the frame, bold readable silhouette, transparent background, no text.` |
| Fondo | `Wide 16:9 game background, no characters, no text, empty central area for gameplay, 1920x1080.` |

Si la herramienta no hace fondos transparentes, cambia `transparent background` por `plain solid flat light grey background` y quítalo después.

---

## 1. Demonios (25) · `assets/sprites/demons/<id>.png`

Ordenados por aparición. La rareza indica el color del aura que añade el juego, no hace falta ponerla en el dibujo, pero conviene que el demonio "pegue" con ese color.

| id | Nombre | Rareza | Sujeto (prompt) |
|---|---|---|---|
| `diablillo` | Federico | común | A small chubby red imp with tiny horns and a mischievous grin, napkin tied around his neck, holding a fork and knife, hungry. |
| `sabueso` | Sabueso de brasas | común | A four-legged hellhound with charcoal-black skin cracked with glowing embers, smoke puffing from its nostrils, drooling drops of lava, side view, tongue out begging for food. |
| `gargola` | Gárgola glotona | común | A hunched grey stone gargoyle with a huge round belly, small bat wings, cracked stone skin, crumbs on its chin, licking its lips. |
| `incubo` | Íncubo goloso | raro | A slender charming male incubus demon with violet skin, swept-back horns, half-closed eyes, licking a spoon, elegant open shirt. |
| `verdugo` | Verdugo de ceniza | raro | A hunched executioner demon with ash-grey skin, black executioner's hood, a huge chipped axe over his shoulder, ash flakes falling from him. |
| `behemot` | Behemot de sebo | raro | A massive fat beast made of melting tallow and grease, dripping wax-like fat, tiny eyes, enormous belly, stubby horns. |
| `belfegor` | Barón Belfegor | épico | Baron Belphegor, a lazy obese demon nobleman with goat horns, monocle and tiny top hat, sprawled with a napkin, bored expression, holding a goblet. |
| `mammon` | Condesa Mammón | épico | Countess Mammon, a plump greedy demon noblewoman in a gown sewn from gold coins, dripping with jewelry, holding a coin purse, avaricious smile. |
| `sucubo` | Súcubo susurrante | épico | A graceful succubus with bat wings and a long tail, purple mist curling from her lips as she whispers, finger to her lips, elegant dark dress. |
| `belial` | Conde Belial | legendario | Count Belial, a tall regal demon lord in black-and-gold armor and a long crimson cape, slicked-back hair, curved horns, arrogant pose. |
| `fenrix` | Duque Fenrix | legendario | Duke Fenrix, a bipedal wolf demon with a mane of fire, dark iron armor with a ducal sash, glowing yellow eyes, sharp grin. |
| `lilith_m` | Marquesa Lilith | legendario | Marquise Lilith, a pale demon noblewoman with long black hair, owl-feather collar, a black serpent coiled around her arm, mysterious smile. |
| `asmodeo` | Asmodeo, Rey de la Ira | mítico | Asmodeus, King of Wrath, a muscular demon king with three heads (bull, man and ram), red-hot crown, furious, steam rising from his shoulders. |
| `leviatan` | Leviatán Menor | mítico | Lesser Leviathan, an upright sea-serpent demon with deep teal scales, fins on its arms, gills, a fanged mouth, water dripping. |
| `behemot_m` | Behemot Mayor | mítico | Greater Behemoth, a colossal mountain-like beast, hippopotamus-and-bull hybrid with rocky hide, huge tusks, tiny smoldering eyes, impossibly heavy. |
| `astaroth` | Astaroth el Cornudo | mítico | Astaroth the Horned, a gaunt demon prince with enormous spiral horns, holding a living viper, tattered royal robes, cruel smirk. |
| `belcebu` | Belcebú, Señor de las Moscas | mítico | Beelzebub, Lord of the Flies, a regal demon with a giant fly's head and compound eyes, insect wings, rich robes, a swarm of flies around him. |
| `moloch` | Moloch el Devorador | mítico | Moloch the Devourer, a giant bull-headed demon whose belly is an open furnace full of fire, iron chains, outstretched hands waiting to be fed. |
| `mefisto` | Mefistófeles | infernal | Mephistopheles, an elegant gentleman devil with a pointed goatee, red velvet suit, cane, holding a burning contract scroll, sly smile. |
| `baal` | Baal Supremo | infernal | Supreme Baal, a monstrous demon king with three heads (cat, man and toad) on a body standing on long spider legs, golden crown. |
| `dagon` | Dagon de las Profundidades | infernal | Dagon of the Depths, a towering fish-man demon from the abyss, dark scales, bioluminescent spots, webbed claws, seaweed and barnacles. |
| `abaddon` | Abaddon el Destructor | infernal | Abaddon the Destroyer, an armored demon with locust wings and a locust-like helmet, a smoking ruined halo, apocalyptic and menacing. |
| `samael` | Samael, Portador de Muerte | infernal | Samael, Bearer of Death, a pale fallen angel with huge black feathered wings, a long scythe, venom-green eyes, serene and terrifying. |
| `lilith_s` | Lilith Suprema | infernal | Supreme Lilith, queen of demons, enormous dark wings, crown of black thorns, serpents in her hair, flowing night-sky gown, majestic. |
| `lucifer` | El Cocinero Original | infernal (secreto) | The Original Chef, a beautiful fallen angel wearing a burning chef's toque and a stained white chef's apron, cracked golden halo, folded charred wings, holding a cleaver, calm and terrifying. |

**Silueta "desconocido"** · `demons/unknown.png`: `A solid black demon silhouette with horns and glowing question mark, mysterious.`

**Corona del coronado** · `demons/crown.png` (formato objeto): `A small floating golden demon crown with three spikes and glowing ember gems.`

**Cabezas mini** · `demons/heads/<id>.png`: no hace falta generarlas aparte; recorta la cabeza de cada demonio a 128×128.

## 2. Cocineros ayudantes (7) · `assets/sprites/cooks/<id>.png`

Son los mismos demonios en versión cocinero. Prompt: `<sujeto del demonio>` + `, as a tiny kitchen helper wearing a white chef's hat and apron, holding a wooden spoon, cute.`

Ids: `diablillo`, `sabueso`, `gargola`, `incubo`, `verdugo`, `behemot`, `belfegor`.

## 3. Cocina (prioridad 1)

| Archivo | Sujeto |
|---|---|
| `kitchen/pan.png` | A heavy black cast-iron frying pan seen from a high three-quarter angle, long handle to the right, glowing embers reflected on the inner surface, empty. (formato objeto) |
| `bg/kitchen.png` | A hellish restaurant kitchen interior: obsidian stone walls with glowing lava cracks, a serving hatch window framed by an arch of bones and skulls in the upper center, a dark stone counter across the bottom, hanging chains, faint smoke. (formato fondo) |

## 4. Comida en la sartén (5) · `assets/sprites/food/<kind>.png`

| kind | Sujeto |
|---|---|
| `salchicha` | A grilled sausage with dark grill marks, sizzling. |
| `costilla` | A meaty rib with an exposed bone, glistening sauce. |
| `ojo` | A cooked eyeball with a green iris, slightly fried edges, creepy-cute. |
| `dedo` | A sausage-like severed finger with a fingernail, grilled. |
| `calamar` | A fried squid ring with little tentacles, purple-ish. |

## 5. Iconos de interfaz (14) · `assets/sprites/icons/<kind>.png`

| kind | Sujeto |
|---|---|
| `flame` | A stylized hellfire flame. |
| `ember` | A cluster of glowing embers. |
| `pan` | A small black frying pan. |
| `eye` | A demonic eye with red iris. |
| `soul` | A green glowing soul wisp (#54e07a). |
| `fork` | A bone fork. |
| `skull` | A cracked bone-white skull. |
| `hourglass` | A bone-framed hourglass with red sand. |
| `cup` | A bronze cursed cauldron cup. |
| `heart` | A red anatomical-cartoon heart (health). |
| `shield_p` | A steel shield (physical armor), grey-blue. |
| `shield_m` | A magical shield with blue runes (magic armor). |
| `sword` | A short demonic blade (attack), orange glint. |
| `orb` | A glowing dark magic orb. |

## 6. Tragaperras · `assets/sprites/slots/`

| Archivo | Sujeto |
|---|---|
| `skull.png` | A plain cracked skull slot-machine symbol. |
| `imp.png` | A laughing little imp holding a trident, slot-machine symbol. |
| `soul.png` | A glowing treasure chest with a bright blue-green soul aura, slot-machine symbol. |
| `loot.png` | A treasure chest overflowing with trinkets, rings and gems, slot-machine symbol. |
| `sigil.png` | A golden pentagram seal medallion, slot-machine symbol. |
| `coin.png` | A hell coin, dark gold with a horned skull embossed. |
| `bg/slots.png` | A demonic slot machine cabinet in an infernal casino, bones and red velvet, empty reels area in the center. (formato fondo) |

## 7. Otros fondos · `assets/sprites/bg/`

| Archivo | Sujeto |
|---|---|
| `menu.png` | The entrance of a restaurant in hell, glowing doorway, sulfur smoke, lava river, a crooked sign space without text. |
| `tree.png` | A dark ritual floor with a huge faint pentagram carved in black stone, candles at the five tips, a stove fire in the center. |

**Logo:** los generadores escriben mal el texto. Mejor generar solo el adorno (`An ornamental frame of flames, horns and a chef's knife for a game logo, empty center, no text`) y poner "Hell's Kitchen" encima con una fuente.

---

## 8. Objetos equipables (38) · `assets/sprites/items/<id>.png` · formato objeto

| id | Nombre | Sujeto |
|---|---|---|
| `delantal_cuero` | Delantal de cuero | A worn leather chef's apron with burn marks. |
| `manopla_hierro` | Manopla de hierro | A riveted iron oven-mitt gauntlet. |
| `gorro_lana` | Gorro de lana raída | A ragged patched wool beanie. |
| `cucharon_madera` | Cucharón de madera | A wooden ladle with a charred tip. |
| `botines_hollin` | Botines de hollín | Soot-covered ankle boots. |
| `panuelo_ceniza` | Pañuelo de ceniza | An ash-grey neckerchief tied in a knot. |
| `peto_escamas` | Peto de escamas | A breastplate made of reddish dragon scales. |
| `guante_amianto` | Guante de amianto | A thick grey fireproof glove with stitched seams. |
| `amuleto_sal` | Amuleto de sal negra | A black salt crystal amulet on a cord. |
| `reloj_roto` | Reloj de arena roto | A cracked hourglass leaking red sand. |
| `campana_animas` | Campana de ánimas | A small bronze hand bell with ghostly wisps. |
| `brasero_bolsillo` | Brasero de bolsillo | A tiny pocket brazier full of glowing coals. |
| `cinturon_cond` | Cinturón de condenado | A prisoner's belt with a shackle buckle and chain. |
| `coraza_obsidiana` | Coraza de obsidiana | A glossy black obsidian cuirass with lava cracks. |
| `punal_femur` | Puñal de fémur | A dagger carved from a femur bone. |
| `capa_sombra` | Capa de sombra | A hooded cloak made of living shadow with wispy edges. |
| `cucharon_femur` | Cucharón de fémur | A ladle carved from a femur with a small skull as the bowl. |
| `corazon_brasa` | Corazón de brasa | A heart made of glowing embers. |
| `libro_contratos` | Libro de contratos menores | A small leather book stuffed with contracts, red wax seals. |
| `campana_grande` | Campana grande de latón | A large brass service desk bell. |
| `yelmo_cornudo` | Yelmo cornudo | A dark iron helmet with big curved demon horns. |
| `guantelete_belial` | Guantelete de Belial | An ornate black-and-gold clawed gauntlet with a demonic sigil. |
| `manto_mammon` | Manto de Mammón | A luxurious golden mantle trimmed with coins. |
| `reloj_asmodeo` | Reloj de Asmodeo | An ornate pocket watch with flames inside its glass. |
| `corona_menor` | Corona menor de Belfegor | A small crooked tarnished crown with drooping spikes. |
| `guante_maestro` | Guante de cocinero maestro | A pristine white chef's glove with gold embroidery, faintly glowing. |
| `escudo_animas` | Escudo de ánimas atrapadas | A round shield with screaming souls swirling under glass. |
| `ojo_astaroth` | Ojo de Astaroth | A floating demonic eye framed by spiral horns. |
| `espada_moloch` | Espada de Moloch | A massive greatsword with a bull-horn guard, glowing like a furnace. |
| `manto_belcebu` | Manto de Belcebú | A cloak made of countless iridescent fly wings. |
| `corazon_leviatan` | Corazón de Leviatán | A huge scaly teal heart with fins. |
| `reloj_infinito` | Reloj infinito | An hourglass twisted into an infinity shape with glowing sand. |
| `grimorio_pactos` | Grimorio de pactos | A thick grimoire with a pentagram clasp and glowing runes. |
| `cetro_avaricia` | Cetro de la avaricia | A golden scepter dripping molten gold, coin-studded head. |
| `corona_cocinero` | Corona del Cocinero | A crown shaped like a chef's toque, made of black gold and flames. |
| `corazon_lucifer` | Corazón de Lucifer | A blazing heart of black fire inside a broken golden halo. |
| `llave_abismo` | Llave del abismo | An ancient black key whose bit opens into a tiny swirling void. |
| `sello_supremo` | Sello supremo del pacto | A huge red wax seal stamped with a glowing pentagram. |

## 9. Decoración del local (51) · `assets/sprites/decor/<id>.png` · formato objeto

| id | Nombre | Sujeto |
|---|---|---|
| `velas` | Velas negras | A cluster of black candles with dripping wax. |
| `alfombra` | Alfombra de piel roja | A rolled-out red hide rug. |
| `manteles` | Manteles de arpillera | A folded burlap tablecloth. |
| `farolillos` | Farolillos de hueso | A string of lanterns made of bone. |
| `arana` | Araña de huesos | A chandelier made of bones with candles. |
| `retrato` | Retrato del propietario | An ornate framed portrait of a smug demon chef. |
| `brasero_dec` | Brasero decorativo | An ornamental iron brazier with flames. |
| `tapiz` | Tapiz de piel de sabueso | A wall tapestry made from hellhound hide. |
| `candelabro` | Candelabro de fémures | A candelabra built from femur bones. |
| `vitrina` | Vitrina de cabezas | A glass display cabinet with shrunken demon heads. |
| `mantel` | Mantelería de seda de araña | A shimmering spider-silk tablecloth with a web pattern. |
| `acuario` | Acuario de almas en pena | A round aquarium with sad ghostly souls swimming. |
| `reloj_grande` | Reloj de pie infernal | A tall infernal grandfather clock with a skull pendulum. |
| `fuente` | Fuente de sangre | A gothic fountain flowing with blood. |
| `estrella` | Estrella robada de una guía | A stolen gleaming restaurant-guide star plaque. |
| `organo` | Órgano de tubos de hueso | A pipe organ whose pipes are bones. |
| `jardin` | Jardín de brasas colgantes | Hanging baskets of glowing ember plants. |
| `cripta` | Cripta VIP con reservas | A small VIP crypt entrance with a reserved sign. |
| `estatua` | Estatua viviente de un cliente | A stone statue of a horrified diner, eyes still moving. |
| `lampara_alma` | Lámpara de mil almas | A lamp full of a thousand tiny glowing souls. |
| `puerta_abismo` | Puerta al abismo (decorativa) | An ornate door slightly open onto a swirling abyss. |
| `trono` | Trono de cráneos | A throne made of skulls. |
| `reliquia_neg` | Reliquia negra sin nombre | A mysterious black relic on a pedestal, unknowable. |
| `corona_local` | Corona colgada del techo | A giant crown hanging from chains. |
| `cortinas_negras` | Cortinas de tela negra | Heavy black velvet curtains. |
| `cadenas_pared` | Cadenas colgadas de la pared | Rusty chains hanging from a wall hook. |
| `cartel_neon` | Cartel de neón infernal | A glowing red neon sign shaped like a pitchfork, no text. |
| `incensario` | Incensario de azufre | A swinging censer with yellow sulfur smoke. |
| `gong_entrada` | Gong de entrada | A large bronze gong with a demon face. |
| `libreria_prohibida` | Librería de grimorios prohibidos | A bookshelf of forbidden grimoires with chains. |
| `pecera_almas` | Pecera de almas nadadoras | A fishbowl with little soul-fish swimming. |
| `chimenea_negra` | Chimenea de fuego negro | A stone fireplace burning with black fire. |
| `cabeza_disecada` | Cabeza de demonio disecada | A mounted demon head trophy on a plaque. |
| `escaleras_talladas` | Escaleras talladas en hueso | A short spiral staircase carved from bone. |
| `mural_pecados` | Mural de los siete pecados | A wall mural showing seven sinful figures. |
| `lampara_eterna` | Lámpara de fuego eterno | An oil lamp with an eternal blue-white flame. |
| `foso_lava` | Foso de lava decorativo | A small decorative lava pit with a railing. |
| `campana_condenados` | Campana de los condenados | A huge cracked bell with chains and wailing faces. |
| `vidriera_infernal` | Vidriera con escenas infernales | A gothic stained-glass window with infernal scenes. |
| `reloj_arena_alma` | Reloj de arena de almas | A large hourglass filled with glowing souls instead of sand. |
| `trono_menor` | Trono menor de un archiduque | An ornate red-velvet archduke's throne. |
| `portal_diminuto` | Portal diminuto siempre abierto | A tiny always-open swirling portal in a stone frame. |
| `orbe_profecia` | Orbe de la profecía | A crystal ball on a claw stand showing visions. |
| `jaula_alma_mayor` | Jaula de un alma mayor | A hanging birdcage holding a large bright soul. |
| `espejo_verdad` | Espejo que muestra la verdad | An ornate mirror reflecting a skeletal truth. |
| `ala_caida` | Ala de un ángel caído | A single fallen angel wing, white feathers turning to ash. |
| `sello_salomon` | Sello roto de Salomón | A broken ancient seal ring with a hexagram. |
| `llave_abismo` | Llave que abre el abismo | A giant black key on a velvet cushion. |
| `corazon_forjado` | Corazón forjado en pecado | A heart forged from black iron, still beating with fire. |
| `cetro_roto` | Cetro roto de un rey caído | A shattered royal scepter, gold and broken. |
| `trono_definitivo` | El Trono Definitivo | An immense throne of obsidian, gold and fire, the ultimate seat. |

> Nota: `llave_abismo` existe a la vez como objeto y como decoración. Por eso van en carpetas distintas (`items/` y `decor/`).
