# Auditoría de i18n — Hov veS (zyKlingonGalaxy)

Revisión del sistema de internacionalización del proyecto, hecha el **2026-07-26**
contra Zymbol **v0.0.8**.

A diferencia de [hallazgos_es.md](hallazgos_es.md), que registra bugs y carencias
**del lenguaje**, este documento registra carencias **del proyecto**.

**Resumen:** Hov veS sí tiene i18n — tres idiomas (pIqaD, inglés, español) — pero
con el mecanismo de primera generación: el idioma es un parámetro y cada cadena
visible es una línea de dibujo duplicada por idioma. La doctrina vigente está en
[interpreter/USERAPPI18N.md](../interpreter/USERAPPI18N.md) y la referencia
implementada en [囲碁](../GO/).

| ID | Tipo | Descripción | Estado |
|----|------|-------------|--------|
| [HOV-I18N-001](#hov-i18n-001--el-idioma-es-un-parámetro-no-estado-de-módulo) | Arquitectura | 9 de las 20 funciones de `HuD.zy` cargan un parámetro de idioma que no es del dominio del juego | **Corregido** |
| [HOV-I18N-002](#hov-i18n-002--no-hay-tabla-de-traducción-hay-79-líneas-de-dibujo-duplicadas) | Bloqueante | Cada cadena visible es un `>>~` repetido por idioma dentro del render | **Corregido** |
| [HOV-I18N-003](#hov-i18n-003--los-marcos-son-de-ancho-fijo-y-el-español-ya-viene-recortado) | Bloqueante | El relleno está tecleado; `(difícil)` ya se abrevió a `(difíc)` para caber | **Corregido** |
| [HOV-I18N-004](#hov-i18n-004--no-hay-gate-de-completitud) | Carencia | Nada verifica que las tres traducciones existan | **Corregido** |
| [HOV-I18N-005](#hov-i18n-005--los-readme-y-designmd-de-囲碁-describen-mal-el-mecanismo) | Doc | «threaded through all cooperating modules» / «through five modules» — son dos, no cinco | **Corregido** |
| [HOV-I18N-006](#hov-i18n-006--el-nombre-de-módulo-va-en-pIqaD-y-el-archivo-romanizado) | Convención | `HUD.zy`, `Duj.zy`, `jagh.zy` y `bach.zy` declaran su módulo en pIqaD: E001 en los cuatro | **Corregido** |
| [HOV-I18N-007](#hov-i18n-007--el-idioma-solo-se-elegía-en-la-primera-pantalla) | Cobertura | `Sel_Hol` se ve una vez por sesión; después no había forma de cambiar | **Corregido** |
| [HOV-I18N-008](#hov-i18n-008--no-hay-readme-en-tlhingan-hol) | Documentación | El juego habla tres idiomas; su documentación, dos | Abierto |

---

## HOV-I18N-001 · El idioma es un parámetro, no estado de módulo

- **Archivos:** `HuD.zy`, `hov_veS.zy`
- **Descripción:** la variable de idioma —escrita en pIqaD, se romaniza como
  `idioma` (U+F8D7 F8D3 F8D7 F8DD F8DA F8D0)— se obtiene del menú inicial y se pasa
  a mano a cada llamada de dibujo:

  ```
  HuD.zy       491 líneas   20 funciones   9 con el parámetro de idioma   76 apariciones
  hov_veS.zy   218 líneas    0 funciones   —                              17 apariciones
  Duj.zy        20 líneas    2 funciones   0
  jagh.zy      202 líneas   11 funciones   0
  bach.zy      307 líneas   12 funciones   0
  ```

  Cada una de esas nueve firmas lleva un argumento que no describe nada del estado
  del juego, y el bucle principal de `hov_veS.zy` lo reenvía en diecisiete puntos.

- **Por qué importa:** es el contraste deliberado que 囲碁 documenta. En
  `GO/言語/取次.zy` el locale es **estado de módulo**, y como el estado de módulo se
  comparte por ruta de archivo, los 22 usos de `言::` en `表示/描画.zy` y los 31 de
  `対局.zy` ven la misma selección sin que nadie pase un argumento. Aquí, añadir una
  pantalla nueva significa acordarse de hilar el idioma hasta ella.
- **Opción:** despachador con estado de módulo y eliminación del parámetro de las
  nueve firmas de `HuD.zy` y de los diecisiete sitios de `hov_veS.zy`. Es el cambio
  más invasivo de los cinco, porque toca la API pública de `HuD.zy`.
- **Solución aplicada (2026-07-26):** `Hol/jatlh.zy` guarda el idioma como estado de
  módulo. El parámetro desapareció de las nueve firmas y de los diecisiete sitios:
  **cero apariciones** en los cinco archivos. `HUD::Sel_Hol` ya no devuelve un número
  que haya que ir pasando — llama a `Hol::cher` y con eso queda fijado para toda la
  sesión.

---

## HOV-I18N-002 · No hay tabla de traducción: hay 79 líneas de dibujo duplicadas

- **Archivo:** `HuD.zy` (79 líneas `>>~` condicionadas por idioma; L81–L128 son el
  menú)
- **Descripción:** el patrón es dibujar primero la fila en pIqaD y luego
  sobrescribirla si el idioma es otro:

  ```zymbol
  >>~ (fila+7,  col, 0, C) > "│   ⟨pIqaD: Select difficulty⟩   │"
  ? idioma == 2 { >>~ (fila+7,  col, 0, C) > "│   Select difficulty:           │" }
  ? idioma == 3 { >>~ (fila+7,  col, 0, C) > "│   Seleccionar dificultad:      │" }
  ```

  Un menú de 20 filas ocupa 48 líneas de código. El texto y su posición y su color
  y su idioma viven todos en la misma línea, así que no hay ningún sitio donde
  consultar «qué dice esta aplicación» sin leer el render entero.

- **Coste:** añadir un cuarto idioma es tocar cada línea de cada pantalla. Cambiar
  una traducción obliga a encontrar su línea entre las 79. Y como se dibuja la
  versión pIqaD **siempre** y luego se sobrescribe, cada fotograma de menú escribe
  hasta tres veces en la misma celda de terminal.
- **Opción:** catálogo de claves + despachador, con el render recorriendo una lista
  de opciones en un bucle. Las 48 líneas del menú colapsan a un bucle sobre cuatro
  entradas.
- **Solución aplicada (2026-07-26):** 27 claves en klingon escrito en pIqaD, con
  prefijo de dominio, en `Hol/jatlh.zy`; tres idiomas en `Hol/tlhIngan.zy`,
  `Hol/English.zy` y `Hol/Español.zy`. Las 79 líneas condicionadas por idioma
  desaparecieron: el menú es ahora un bucle sobre cuatro etiquetas traducidas.
- **Lo que obligó a inventar una función de contrato:** el klingon escribe sus cifras
  en pIqaD (U+F8F0–F8F9), así que un número tampoco se puede imprimir igual en los
  tres idiomas. De ahí `mI'(n)` en el contrato de cada idioma, junto a `mu'(clave)` y
  a la frase compuesta `Qaw'mu'(n)` («oleada N completada», con forma propia para la
  primera y concordancia femenina en español).

---

## HOV-I18N-003 · Los marcos son de ancho fijo, y el español ya viene recortado

- **Archivo:** `HuD.zy` L96–L128
- **Descripción:** cada fila del marco es un literal con el relleno contado a mano
  para 32 columnas:

  ```zymbol
  "│   [1]  petaQ    (easy)  120 ms │"
  "│   [1]  petaQ    (fácil) 120 ms │"
  "│   [3]  Qapla'   (hard)   60 ms │"
  "│   [3]  Qapla'   (difíc)  60 ms │"
  ```

  `(difícil)` está abreviado a `(difíc)` no por criterio editorial sino porque no
  cabía. Lo mismo con `(medium)` → `(med)`. La traducción está subordinada a la
  aritmética de la caja.

- **Por qué importa:** es la causa raíz de HOV-I18N-002. Mientras el relleno viva
  dentro de la misma cadena que el texto, cada traducción es un ejercicio de contar
  espacios, y ningún idioma que no quepa en el molde es admisible. El pIqaD, además,
  se dibuja con glifos del PUA cuyo ancho depende de la fuente instalada, así que el
  supuesto de «un carácter = una columna» ni siquiera es fiable en el idioma base.
- **Solución disponible desde v0.0.8:** `std/term` (`width`, `pad_left`,
  `pad_right`, `center`, `truncate`), que mide columnas de terminal y no grafemas.
  囲碁 lo envuelve en `標準/端末.zy` → `表示/文字.zy` y construye cada marco a partir
  del ancho medido. Hov veS apunta a v0.0.5 en su `README.md`; el retrofit implica
  subirlo a v0.0.8.
- **Solución aplicada (2026-07-26):** `juv.zy` es la capa en klingon sobre `std/term`
  y `gho.zy` construye los paneles. `(difícil)` cabe entero, y también
  `Hab SoSlI' (medium)`, que con la constante de 26 columnas que tenía el menú se
  comía el espacio del número: esa columna también se mide ahora, y se mide con la
  marca `►` puesta para que la fila no se desplace al mover el cursor.
  El proyecto sube a **v0.0.8**, que es donde vive `std/term`.

---

## HOV-I18N-004 · No hay gate de completitud

- **Descripción:** el proyecto no tiene ninguna prueba que verifique que las tres
  traducciones existen. No puede tenerla: sin catálogo de claves no hay nada contra
  lo que comparar. Una pantalla a la que se le olvidara la rama `? idioma == 3`
  simplemente se quedaría en pIqaD, en silencio.
- **Referencia:** `GO/試験/言語検証.zy` recorre 51 claves × 5 locales y además
  ejercita los tres mensajes compuestos en los cinco idiomas. Es reproducible aquí
  en cuanto exista el catálogo.
- **Solución aplicada (2026-07-26):** `mIw/Hol.zy` recorre 27 claves × 3 idiomas,
  ejercita `mI'` con 0, 7 y 1234 y `Qaw'mu'` con 1 y 12, y además **construye un
  marco en cada idioma y comprueba que todas sus filas miden lo mismo** — que es el
  fallo concreto que tenía este proyecto. Corre en los dos motores desde
  `mIw/Hoch.sh`.

---

## HOV-I18N-005 · Los README y `DESIGN.md` de 囲碁 describen mal el mecanismo

- **Archivos:** `README.md`, `README_ES.md`, `../GO/DESIGN.md` §8
- **Descripción:** el `README.md` de Hov veS dice:

  > *«3-language i18n (pIqaD / English / Spanish) threaded as a parameter through
  > all cooperating modules»* … *«across 5 cooperating modules»*

  y `GO/DESIGN.md` §8 lo repite como contraste:

  > *«Hov veS, which threaded language as a parameter through five modules»*

  La medición dice otra cosa: el parámetro solo llega a **dos** archivos, `HuD.zy`
  y `hov_veS.zy`. `Duj.zy`, `jagh.zy` y `bach.zy` no lo mencionan ni una vez —
  ninguno de los tres dibuja texto.

- **Por qué importa:** no cambia el veredicto (el mecanismo sigue siendo el de
  parámetro y sigue habiendo que reemplazarlo), pero sí el tamaño del trabajo: el
  refactor toca dos archivos, no cinco. Y una comparación publicada que exagera el
  defecto del proyecto de referencia anterior es exactamente el tipo de dato que no
  conviene dejar sin corregir.
- **Opción:** corregir las tres frases al reescribir la i18n.
- **Solución aplicada (2026-07-26):** corregido en `GO/DESIGN.md` §8. Los README de
  este proyecto se reescribieron para v0.0.8 y ya no describen el mecanismo viejo.

---

## HOV-I18N-006 · El nombre de módulo va en pIqaD y el archivo, romanizado

- **Archivos:** `HuD.zy`, `Duj.zy`, `jagh.zy`
- **Descripción:** los tres declaran su módulo con identificadores en pIqaD
  (`# ⟨HuD⟩`) mientras que sus archivos se llaman en klingon romanizado. `zymbol
  check` exige que el nombre del módulo coincida exactamente con el del archivo, así
  que salta `E001` en los tres:

  ```
  error: E001: Module name '⟨HuD⟩' does not match file name 'HUD'
  ```

- **Estado real:** es anterior a este trabajo — el original tenía exactamente el
  mismo error — y no afecta a la ejecución: los importadores usan la ruta, no el
  nombre declarado. `zymbol check hov_veS.zy` pasa limpio porque solo valida el
  archivo de entrada.
- **Las dos salidas posibles:** o se renombran los archivos a pIqaD, o la
  declaración de módulo se escribe en la misma transcripción que la ruta. La primera
  rompe el README, la URL del repo y la posibilidad de teclear un nombre de archivo.
- **Solución aplicada (2026-07-26):** la segunda, por decisión del autor — **los
  nombres de archivo se quedan en tlhIngan Hol**. La declaración de módulo no es un
  identificador del programa: es el testigo que el intérprete compara con la ruta,
  así que va en la misma transcripción que la ruta. Los cuatro archivos declaran
  ahora `# HuD`, `# Duj`, `# jagh` y `# bach` — las mismas palabras klingon que ya
  llevaban, en el mismo alfabeto que sus nombres de archivo. Nada dentro del
  programa cambió de escritura: los identificadores siguen en pIqaD.

  De paso, `HUD.zy` pasó a llamarse **`HuD.zy`**. `HUD` en mayúsculas era el
  acrónimo inglés; `HuD` es la palabra klingon, y en klingon las mayúsculas son
  ortografía, no estilo — `H` y `h`, `D` y `d`, `Q` y `q` son letras distintas. El
  nombre de archivo dice ahora lo que dice la cabecera del propio archivo.

  Los cuatro pasan `zymbol check` sin errores, y `mIw/Hoch.sh` ya no necesita contar
  nada aparte.

---

## HOV-I18N-007 · El idioma solo se elegía en la primera pantalla

- **Archivos:** `HuD.zy`, `Hol/jatlh.zy`
- **Descripción:** `Sel_Hol` es la primera pantalla del juego y se ve **una vez por
  sesión**. Después de elegir no había vuelta atrás sin reiniciar. Es el punto 9 de
  la lista de [USERAPPI18N.md](../interpreter/USERAPPI18N.md).
- **Solución aplicada (2026-07-26):** `L` rota el idioma en el menú de dificultad y
  en el de fin de partida, con una fila que muestra el idioma actual. El marco se
  reconstruye con el ancho nuevo.
- **Nota:** `Hol::tam` son dos funciones —una pura que calcula y otra sin retorno que
  escribe—. Fue el rodeo del fallo HLZ-SRP-001 del tree-walker, **corregido en el
  intérprete el 2026-07-27**, y se mantiene porque aquel fallo era silencioso: con un
  binario v0.0.8 sin el arreglo, la versión de una sola función deja el idioma
  anterior sin dar error. `mIw/Hol.zy` recorre el ciclo completo y comprueba que
  vuelve al primer idioma.

---

## HOV-I18N-008 · No hay README en tlhIngan Hol

- **Archivos:** `README.md`, `README_ES.md`
- **Descripción:** el juego responde en klingon, inglés y español, y su documentación
  solo en inglés y español. Es el punto 14 de la lista: una aplicación multiidioma
  cuya documentación es monolingüe está traducida a medias, y aquí el idioma que
  falta es precisamente el idioma base del programa.
- **Por qué queda abierto:** un README completo en tlhIngan Hol es un trabajo de
  traducción, no de código, y escribirlo a medias es peor que no tenerlo. Queda a
  la espera de decisión — implementar / desestimar.
- **Nota:** el mismo hueco existe en [囲碁](../GO/AUDITORIA_I18N_ES.md), que habla
  cinco idiomas y documenta en tres.

---

## Lo que **sí** está bien

- **El proyecto es multiidioma de verdad.** Tres idiomas completos, incluido uno
  construido (klingon en pIqaD, con los identificadores del código también en
  pIqaD). Es el proyecto más ambicioso del workspace en esta materia y funciona.
- **`PIQAD_MAPPING.md` documenta la conversión** fonema a fonema, y
  `../klingon_to_piqad.py` la automatiza. El retrofit puede generar los
  identificadores nuevos con la misma herramienta con la que se generaron los
  actuales.
- **La lógica no tiene texto.** `Duj.zy`, `jagh.zy` y `bach.zy` —529 líneas entre
  los tres— no contienen ni una cadena visible. Todo el trabajo se concentra en
  `HuD.zy`.
- **`zymbol check klingon_galaxy/hov_veS.zy` pasa limpio en v0.0.8** pese a estar
  escrito para v0.0.5: el retrofit no arranca desde una deuda de sintaxis.

---

## Verificación

```bash
bash mIw/Hoch.sh     # gate en los dos motores + zymbol check
```

Las pantallas se probaron a mano en una terminal real de 80 × 24: selector de idioma,
menú de dificultad en los tres idiomas, HUD durante la partida, pausa y fin de
partida. `>>|` se niega a arrancar sin TTY, así que esa parte no es automatizable
desde el runner.

---

## Historial

- **2026-07-26** — Auditoría inicial. Cinco hallazgos abiertos.
- **2026-07-26** — HOV-I18N-001..005 corregidos. Nuevo HOV-I18N-006 abierto (es
  anterior a este trabajo, solo estaba sin registrar) y **corregido el mismo día**:
  `HUD.zy` → `HuD.zy` y las cuatro declaraciones de módulo en la transcripción de su
  ruta. HOV-I18N-007 corregido el mismo día (cambio de idioma con `L`) y
  HOV-I18N-008 abierto (falta el README en klingon). El proyecto pasa de v0.0.5 a
  v0.0.8. `bash mIw/Hoch.sh` → `Hoch PASS`. Dos carencias del **lenguaje** salieron a
  la luz por el camino y están en [hallazgos_es.md](hallazgos_es.md): HLZ-KL-001
  (la interpolación no admitía identificadores en pIqaD), **corregido en el
  intérprete el 2026-07-27**; los dos idiomas vuelven a usar interpolación.
