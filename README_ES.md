# Hov veS

> **Apunta a Zymbol v0.0.8** — revisado el 2026-07-26

Juego de tipo Galaxian para la terminal, ambientado en el universo Klingon.
El IKS meQtaH (B'rel Bird-of-Prey) defiende el Imperio contra oleadas de la
Armada de la Federación.

Hov veS es el segundo juego TUI real escrito en Zymbol, después de Serpiente.
Se construyó para validar un conjunto diferente de capacidades del lenguaje:
propagación de estado entre múltiples módulos, IA de formación al estilo Galaxian
con deriva y ataques de buceo, sistema dual de proyectiles, progresión de oleadas
con dificultad escalonada, estadísticas de sesión persistentes mediante variables
hot-definition, e i18n de 3 idiomas (pIqaD / Inglés / Español).

La i18n se escribió primero con el idioma propagado como parámetro por `HuD.zy`
y `hov_veS.zy`, y cada cadena visible duplicada una vez por idioma dentro del
render: 79 líneas de dibujo condicionadas. En v0.0.8 se rehízo alrededor de un
despachador que guarda el idioma como estado de módulo, un catálogo de 27 claves
con prefijo de dominio escritas en klingon y en pIqaD, y marcos que se miden en
lugar de teclearse.

> **Proyecto de validación de Zymbol v0.0.5** — pone a prueba la orquestación
> multi-módulo, la IA de formación Galaxian, el delta rendering y la gestión de
> entropía.
>
> **Revisitado para v0.0.8** — el idioma es ahora estado de módulo y no un
> parámetro hilado por las llamadas de dibujo, cada panel se construye midiendo
> su contenido con `std/term` en vez de con literales de ancho fijo, y una puerta
> de completitud recorre 27 claves × 3 idiomas en los dos motores. Ver
> [auditoria_i18n_es.md](auditoria_i18n_es.md) y la doctrina común en
> [USERAPPI18N.md](https://github.com/zymbol-lang/interpreter/blob/main/USERAPPI18N.md).

> **English:** [README.md](README.md)

---

## Cómo jugar

Requiere el [intérprete Zymbol](https://github.com/zymbol-lang/interpreter)
**v0.0.8 o posterior** (la maquetación depende de `std/term`):

```bash
git clone https://github.com/zymbol-lang/zyKlingonGalaxy
cd zyKlingonGalaxy
zymbol run hov_veS.zy
```

Requiere una fuente compatible con pIqaD (CSUR PUA, U+F8D0–F8FF) para el
alfabeto Klingon en los menús. Se recomienda una terminal de al menos 40 × 20
caracteres.

---

## Controles

| Tecla | Acción |
|-------|--------|
| `←` / `A` | Mover nave a la izquierda |
| `→` / `D` | Mover nave a la derecha |
| `Espacio` | Disparar bolt de disruptor (1 activo, muerte instantánea) |
| `↑` | Ráfaga de fuego rápido (4 bolts, 1 daño cada uno) |
| `↓` | Activar/desactivar escudo (3 cargas por vida — absorbe bolts enemigos) |
| `P` | Pausar / continuar |
| `Q` | Salir durante la partida |
| `L` | Cambiar de idioma — en las pantallas de dificultad y de fin de partida |
| `1`–`4` | Seleccionar dificultad directamente en el menú |
| `↑` `↓` + `↵` | Navegar menús |

---

## Pantallas

### Selección de idioma

La primera pantalla al arrancar permite elegir el idioma de visualización. Afecta
a todos los textos de menús y etiquetas del HUD. Se navega con `↑`/`↓` o se
pulsa `1`–`3`, luego `↵`:

```
╭──────────────────────────────────╮
│         [título pIqaD]           │
│       [subtítulo pIqaD]          │
├──────────────────────────────────┤
│   tlhIngan Hol / Language:       │
│                                  │
│   [1]  tlhIngan (pIqaD)          │
│   [2]  English                   │
│ ► [3]  Español                   │
├──────────────────────────────────┤
│  ↑↓ / 1-3 / ↵                   │
╰──────────────────────────────────╯
```

`Q` selecciona pIqaD por defecto. El idioma elegido persiste en toda la sesión
(menús, oleada completada, fin de partida y etiquetas del HUD).

### Selección de dificultad

Al seleccionar el idioma aparece el menú de dificultad. Se navega con `↑` `↓` y
se confirma con `↵` (también se puede pulsar `1`–`4` directamente):

```
╭────────────────────────────────╮
│         H O V   V E S          │
│       IKS  meQtaH              │
│  B'rel Bird-of-Prey vs Armada  │
├────────────────────────────────┤
│   Seleccionar dificultad:      │
│                                │
│   [1]  petaQ    (fácil) 120 ms │
│ ► [2]  Hab SoSlI (med)   90 ms │
│   [3]  Qapla'   (difíc)  60 ms │
│   [4]  Heghlu'  (muerte) 40 ms │
├────────────────────────────────┤
│  ↑↓ / 1-4 / ↵ confirmar       │
│  Q = salir durante juego       │
╰────────────────────────────────╯
```

### Juego

El borde enmarca el campo de juego y superpone el HUD: vidas (tribbles) a la
izquierda, puntuación centrada, número de oleada a la derecha. Los enemigos
se desplazan lateralmente y periódicamente rompen formación para abalanzarse
sobre la nave.

```
╭──┤ yIH: ♦ ♦ · ├────┤ nob: 80 ├────┤ HoS: 2 ├──╮
│                                                   │
│    ▽  ▽  ▽  ▽  ▽  ▽  ▽  ▽  ▽  ▽               │
│    ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼               │
│    ◆  ◆  ◆  ◆  ◆  ◆  ◆  ◆  ◆  ◆               │
│    ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼  ▼               │
│    ▽  ▽  ▽  ▽  ▽  ▽  ▽  ▽  ▽  ▽               │
│                                                   │
│                 ▼                                 │
│                 ·                                 │
│                |                                  │
│                                                   │
│                 ▲                                 │
╰───────────────────────────────────────────────────╯
```

**Tipos de enemigo y puntos:**

| Glifo | Tipo | Puntos | Filas de formación |
|-------|------|--------|--------------------|
| `◆` | almirante | 50 | fila 2 |
| `▼` | capitan | 20 | filas 3–4 |
| `▽` | soldado | 10 | filas 5–6 |

Los buzos (enemigos que rompen formación y se lanzan en picado) otorgan **2×**
los puntos base al ser destruidos en pleno vuelo.

### Oleada completada

Al destruir todos los enemigos y buzos activos, aparece brevemente un overlay
antes de la siguiente oleada:

```
╭───────────────────────────╮
│      Q A P L A ' !        │
│   Oleada 2 completada!    │
│   Puntos: 180             │
╰───────────────────────────╯
```

### Pausa

Al pulsar `P` durante la partida aparece un panel de pausa centrado. Al pulsar
`P` de nuevo se reanuda y el tablero se redibuja completo.

### Fin de partida

Al perder las tres vidas de tribble aparece un menú con las estadísticas de
sesión y la opción de iniciar una nueva partida:

```
╭───────────────────────────╮
│     H E G H L U ' !       │
│   ( has muerto )          │
├───────────────────────────┤
│  Puntos:  180             │
│  Oleada:  3               │
│  Partidas:2               │
├───────────────────────────┤
│► Nueva partida            │
│  Salir                    │
╰───────────────────────────╯
```

El número de partidas jugadas y la lista acumulada de puntuaciones persisten
entre reinicios dentro de la misma sesión, almacenados en variables
hot-definition ancladas al bloque exterior `>>|`.

---

## Arquitectura

```
klingon_galaxy/
├── hov_veS.zy      punto de entrada — semilla, dimensiones, bucle de juego, eventos
├── Duj.zy          nave del jugador — movimiento lateral con límites
├── jagh.zy         flota enemiga — formación, deriva, ataques de buceo, LCG
├── bach.zy         proyectiles — bolts del jugador y enemigos, detección de impacto
├── HuD.zy          pantalla — menús, borde, delta rendering, overlays
├── juv.zy          capa en klingon sobre std/term (medidas de columna)
├── gho.zy          paneles construidos midiendo el contenido — sin anchos fijos
├── Hol/
│   ├── jatlh.zy    despachador de i18n — guarda el idioma como estado de módulo
│   ├── tlhIngan.zy idioma klingon (base: de aquí salen las claves)
│   ├── English.zy  idioma inglés
│   └── Español.zy  idioma español
├── mIw/
│   ├── Hol.zy      puerta de completitud: claves × idiomas, cifras, marcos
│   └── Hoch.sh     corre todas las suites en los dos motores
├── auditoria_i18n_es.md  auditoría de i18n del proyecto
└── hallazgos_es.md registro de bugs y gaps encontrados durante el desarrollo
```

### Módulos

**`Duj.zy`** exporta:
- `bIng(Duj, AN)` — mueve la nave una columna a la izquierda; límite en columna 2
- `Dung(Duj, AN)` — mueve la nave una columna a la derecha; límite en columna `AN+1`

**`jagh.zy`** exporta:
- `chen_ghom(AN, AL, HoS, mIS)` — construye la formación 5×10 para la oleada `HoS`;
  retorna `(ghom, mIS)`
- `Suy_mIw(ghom, jaHDu, AN, AL, HoS, mIS)` — avanza la deriva de la formación y los
  buzos activos; posiblemente lanza un nuevo buceo; retorna `(ghom, jaHDu, mIS, hubo_drift)`
- `HoH_nob(jaHDu, Duj, Duj_fila)` — detecta colisión de buzo con la nave;
  retorna `#1`/`#0`
- `naQ_ghom(ghom, jaHDu)` — retorna `#1` cuando todos los enemigos y buzos están eliminados

**`bach.zy`** exporta:
- `tagh(mIwDu, fila, col)` — crea un nuevo bolt (disruptor o ráfaga)
- `vIH_mIwDu(mIwDu, bachHaw, ghom, jaHDu, AL)` — avanza los bolts de disruptor y
  resuelve impactos con muerte instantánea; retorna `(mIwDu, bachHaw, nab, ghom, jaHDu, naQDu)`
- `vIH_mIwDu_rap(mIwDu_rap, ghom, jaHDu, AL)` — avanza los bolts de ráfaga y
  resuelve impactos con 1 daño; retorna `(mIwDu_rap, nab, ghom, jaHDu, naQDu_rap, naDanHa)`
- `jagh_tagh(jagh_bachDu, ghom, jaHDu, mIS, HoS)` — posiblemente dispara un bolt
  enemigo (probabilidad escala con la oleada); retorna `(jagh_bachDu, mIS)`
- `vIH_jagh_bachDu(jagh_bachDu, Duj, Duj_fila, AN, AL, escudo_activo, escudo_carga)` —
  avanza los bolts enemigos y detecta impacto; el escudo absorbe si está activo
  (consume 1 carga); retorna `(jagh_bachDu, HoH_Duj, escudo_activo, escudo_carga)`

**`HuD.zy`** exporta — obsérvese que **ninguna firma lleva idioma**: vive en
`Hol/jatlh.zy` como estado de módulo.
- `sel_Hol(AN, AL)` — selector de idioma (primera pantalla). Fija el idioma en
  `Hol/jatlh` y devuelve su código ISO 639; el valor de retorno es una comodidad,
  lo que importa es el efecto
- `menu_HeH(AN, AL)` — pantalla de título + selector de dificultad; retorna ms/tick
- `chen_bID(AN, AL)` — dibuja el borde completo y limpia el campo de juego
- `yIH_HuD(yIHmey, AN, AL)` — dibuja las vidas (tribbles) en el borde superior
- `nob_HuD(nob, AN)` — dibuja la puntuación en el borde superior
- `HoS_label(HoS, AN)` — dibuja el número de oleada en el borde superior
- `escudo_HuD(escudo_carga, escudo_activo, AN)` — dibuja las cargas de escudo en
  el borde superior (etiqueta cian cuando activo; `■` lleno / `·` vacío por carga)
- `ghom_HuD(ghom, AN, AL)` — dibuja la formación enemiga completa (render inicial)
- `Duj_HuD(Duj, Duj_fila, AN, escudo_activo)` — dibuja la nave (cian cuando con escudo)
- `yot(AN, AL)` — overlay de pausa; bloquea hasta que se pulse `P`
- `Hegh_mIS(Duj, Duj_fila, AN, AL)` — animación de muerte (3 destellos)
- `HoS_tugh(ola, nob, AN, AL)` — overlay de oleada completada con 1.8 s de pausa
- `Hegh_nav(nob, HoS, maQDu, nob_maQ, AN, AL)` — menú de fin de partida; retorna
  `'n'` (nueva partida) o `'s'` (salir)
- `chou_bID(...)` — delta render: redibuja únicamente las celdas modificadas por tick

**`Hol/jatlh.zy`** exporta — el despachador de i18n. Cada módulo de idioma cumple
el mismo contrato de tres funciones:
- `cher(código)` / `DaH()` — fija y lee el idioma activo (`tlh`, `en`, `es`)
- `Holmey()` / `rInmey()` — la lista de idiomas y el catálogo maestro de claves
- `mu'(clave)` — la cadena traducida de una clave
- `mI'(n)` — un número en la escritura del idioma activo. No es cosmética: el
  klingon escribe sus cifras en pIqaD (U+F8F0–F8F9) y el inglés y el español en ASCII
- `Qaw'mu'(n)` — la frase «oleada N completada», compuesta por cada idioma

**`juv.zy`** — capa en klingon sobre `std/term`: `'ar` (ancho en columnas de
terminal, no en grafemas), `poS` / `nIH` (rellenar), `botlh` (centrar), `pe'`
(recortar).

**`gho.zy`** exporta — paneles construidos midiendo el contenido:
- `chen(líneas, hueco)` — enmarca una lista de líneas ya traducidas; todas las
  filas que salen miden exactamente lo mismo, en el idioma que sea
- `'ar(líneas)` — la línea más ancha de una lista, en columnas de terminal
- `per_tlhegh(n, etiqueta, seleccionada)` — una fila de menú con su marca `►`
  puesta *antes* de medir, para que las filas no se muevan al mover el cursor
- `PE` / `BOTLH` — marcas de línea: regla horizontal, y «centra esta línea»

### Modelo de datos

Todo el estado mutable se propaga explícitamente como argumentos — sin estado
global compartido. Las estructuras principales:

| Variable | Tipo | Contenido |
|----------|------|-----------|
| `ghom` | 3-tupla | `(vel, ticks, enemigos)` — estado de deriva de la formación |
| `enemigos` | array de 4-tuplas | `(fila, col, tipo, hp)` — enemigos vivos en formación |
| `jaHDu` | array de 5-tuplas | `(fila, col, tipo, vel_fila, vel_col)` — buzos activos |
| `mIwDu` | array de 2-tuplas | `(fila, col)` — bolts del jugador en vuelo |
| `jagh_bachDu` | array de 2-tuplas | `(fila, col)` — bolts enemigos en vuelo |

### Delta rendering

`chou_bID` no borra el campo de juego en cada tick. Solo actualiza las celdas
que cambiaron:

| Condición | Celdas actualizadas |
|-----------|---------------------|
| `hubo_drift == #1` | Borra posiciones pre-deriva y redibuja la formación completa |
| `hubo_drift == #0` | Borra únicamente los enemigos destruidos en `naQDu`/`naQDu_rap` |
| Siempre | Redibuja glifos de `naDanHa` (enemigos dañados pero vivos) |
| Siempre | Borra posiciones viejas / dibuja nuevas posiciones de buzos |
| Siempre | Borra posiciones viejas / dibuja nuevas posiciones de bolts de disruptor |
| Siempre | Borra posiciones viejas / dibuja nuevas posiciones de bolts de ráfaga |
| Siempre | Borra posiciones viejas / dibuja nuevas posiciones de bolts enemigos |
| `Duj_vieja <> Duj` | Borra columna vieja de la nave, dibuja en la nueva columna |
| Cambio de escudo | Actualiza color de nave y HUD de cargas de escudo |

### Aleatoriedad

La semilla inicial `mIS` se deriva al arrancar de tres fuentes de entropía
independientes via BashExec (`date +%N`, `$$`, `/dev/urandom`). Toda la
aleatoriedad posterior usa un LCG en Zymbol puro — sin BashExec por tick.
Se usan las mismas constantes que en `serpiente/logica.zy`:
`(1664525 × mIS + 1013904223) % 2147483647`.

La semilla se pasa como argumento explícito y se retorna como parte de toda
tupla que la avanza.

---

## Primitivas de Zymbol v0.0.5 utilizadas

| Primitiva | Uso en Hov veS |
|-----------|----------------|
| `>>| { }` | Bloque TUI — alternate screen, raw mode, cursor oculto |
| `>>~ (r, c, bg, fg) > items` | Output posicionado 4 args con bg y fg explícitos (ANSI 256) |
| `>>!` | Limpiar pantalla (menús, entrada a pausa) |
| `>>?` | Consultar tamaño real del terminal; se relanza cada tick para detectar redimensionado |
| `<<|? var` | Lectura no bloqueante de tecla (bucle de juego) |
| `<<| var` | Lectura bloqueante de tecla (menús, pausa, fin de partida) |
| `@~ ms` | Pausa en milisegundos (controla la velocidad / dificultad) |
| `°var` | Variable hot anclada al bloque `>>|` exterior — contador de partidas de sesión |
| `°var += n` / `°var $+ v` | Acumulación entre partidas de la misma sesión |
| `@:label >` | Continuar en bucle nombrado (redimensionado de terminal → reiniciar oleada) |
| `@:label!` | Romper bucle nombrado (oleada completada, muerte, salida) |

---

## Hallazgos del lenguaje

Durante la construcción de Hov veS se identificaron dos comportamientos en Zymbol
que se documentaron en [`hallazgos_es.md`](hallazgos_es.md). Uno era un gap de
diseño con workaround conocido; el otro era un bug real del intérprete que fue
corregido.

| ID | Tipo | Descripción | Estado |
|----|------|-------------|--------|
| HLZ-001 | Gap | Las variables nuevas asignadas solo dentro de bloques `? cond { }` no son visibles en el scope exterior — comportamiento de scope esperado | Workaround: pre-declarar con valor por defecto, o extraer la lógica a una función helper |
| HLZ-002 | Bug | Las constantes `:=` de módulo eran inaccesibles cuando una función privada llamaba a otra función privada del mismo módulo (llamada intra-módulo sin prefijo `alias::`) | **Corregido** en `interpreter/crates/zymbol-interpreter/src/functions_lambda.rs` |
