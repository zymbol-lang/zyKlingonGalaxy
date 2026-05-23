# pIqaD Mapping — Hov veS

Reference document for writing and reading `.zy` code in pIqaD script.
Requires a pIqaD font (CSUR PUA, U+F8D0–U+F8FF).

---

## 1. Phoneme conversion rules

Processing order: **3-char** (`tlh`) → **2-char** (`ch`, `gh`, `ng`) → **1-char**.
Exception: `c` alone (not part of `ch`) stays as ASCII `c`.

| ASCII | pIqaD | Code point | Note |
|-------|-------|------------|------|
| `tlh` |  | U+F8E4 | 3-char digraph |
| `ch / Ch / CH` |  | U+F8D2 | 2-char digraph |
| `gh / Gh / GH` |  | U+F8D5 | 2-char digraph (also g alone → gh) |
| `ng / Ng / NG` |  | U+F8DC | 2-char digraph |
| `a / A` |  | U+F8D0 |  |
| `b / B` |  | U+F8D1 |  |
| `c (alone)` | c | ASCII | NOT converted when not part of ch |
| `D / d` |  | U+F8D3 | d → retroflex D |
| `e / E` |  | U+F8D4 |  |
| `f / F` |  | U+F8E6 (v) | f → v |
| `g / G` |  | U+F8D5 (gh) | standalone g → gh glyph |
| `H / h` |  | U+F8D6 | h → uvular H |
| `I / i` |  | U+F8D7 | i → Klingon I |
| `j / J` |  | U+F8D8 |  |
| `k / K` |  | U+F8DF (q) | k → uvular q |
| `l / L` |  | U+F8D9 |  |
| `m / M` |  | U+F8DA |  |
| `n / N` |  | U+F8DB |  |
| `o / O` |  | U+F8DD |  |
| `p / P` |  | U+F8DE |  |
| `q` |  | U+F8DF | Klingon q (uvular stop) |
| `Q` |  | U+F8E0 | Klingon Q (uvular affricate) |
| `r / R` |  | U+F8E1 |  |
| `s / S` |  | U+F8E2 | s → retroflex S |
| `t / T` |  | U+F8E3 |  |
| `u / U` |  | U+F8E5 |  |
| `v / V` |  | U+F8E6 |  |
| `w / W` |  | U+F8E7 |  |
| `y / Y` |  | U+F8E8 |  |
| `'` |  | U+F8E9 | glottal stop |
| `z / Z` |  | U+F8E2 (S) | z → S |
| `_ (underscore)` | _ | ASCII | separator, kept as-is |
| `° (hot-var)` | ° | U+00B0 | hot-var prefix, kept as-is |

---

## 2. Digit mapping

| ASCII | pIqaD | Code point |
|-------|-------|------------|
| `0` |  | U+F8F0 |
| `1` |  | U+F8F1 |
| `2` |  | U+F8F2 |
| `3` |  | U+F8F3 |
| `4` |  | U+F8F4 |
| `5` |  | U+F8F5 |
| `6` |  | U+F8F6 |
| `7` |  | U+F8F7 |
| `8` |  | U+F8F8 |
| `9` |  | U+F8F9 |

Number literals in code: `120` → ``, `2147483647` → ``.

---

## 3. Identifier mapping — Hov veS

### Module aliases (import targets)

| ASCII | pIqaD |
|-------|-------|
| `duj` | `` |
| `jag` | `` |
| `bac` | `c` |
| `hud` | `` |

### Duj.zy exports

| ASCII | pIqaD |
|-------|-------|
| `bIng` | `` |
| `Dung` | `` |

### jagh.zy exports

| ASCII | pIqaD |
|-------|-------|
| `chen_ghom` | `_` |
| `Suy_mIw` | `_` |
| `HoH_nob` | `_` |
| `naQ_ghom` | `_` |

### bach.zy exports

| ASCII | pIqaD |
|-------|-------|
| `tagh` | `` |
| `vIH_mIwDu` | `_` |
| `vIH_mIwDu_rap` | `__` |
| `jagh_tagh` | `_` |
| `vIH_jagh_bachDu` | `__` |

### HUD.zy exports

| ASCII | pIqaD |
|-------|-------|
| `menu_HeH` | `_` |
| `chen_bID` | `_` |
| `yIH_HUD` | `_` |
| `nob_HUD` | `_` |
| `HoS_label` | `_` |
| `escudo_HUD` | `c_` |
| `ghom_HUD` | `_` |
| `Duj_HUD` | `_` |
| `yot` | `` |
| `Hegh_mIS` | `_` |
| `HoS_tugh` | `_` |
| `Hegh_nav` | `_` |
| `chou_bID` | `_` |

### Dimension / layout

| ASCII | pIqaD |
|-------|-------|
| `filas` | `` |
| `cols` | `c` |
| `AN` | `` |
| `AL` | `` |
| `Duj_fila` | `_` |
| `ult_filas` | `_` |
| `ult_cols` | `_c` |
| `filas_act` | `_c` |
| `cols_act` | `c_c` |

### Entropy seeds

| ASCII | pIqaD |
|-------|-------|
| `_ns` | `_` |
| `_pid` | `_` |
| `_rnd` | `_` |
| `mIS` | `` |

### Loop labels

| ASCII | pIqaD |
|-------|-------|
| `maQ` | `` |
| `Hov_HoS` | `_` |
| `mIw` | `` |

### Core game state

| ASCII | pIqaD |
|-------|-------|
| `retardo` | `` |
| `Duj` | `` |
| `yIHmey` | `` |
| `nob` | `` |
| `HoS` | `` |
| `ghom` | `` |
| `jaHDu` | `` |
| `mIwDu` | `` |
| `mIwDu_rap` | `_` |
| `jagh_bachDu` | `_` |
| `bachHaw` | `` |
| `naQ_ghom` | `_` |
| `rap_burst_rest` | `__` |
| `rap_cooldown` | `_c` |
| `escudo_activo` | `c_c` |
| `escudo_carga` | `c_c` |

### Snapshot vars (vieja = old)

| ASCII | pIqaD |
|-------|-------|
| `Duj_vieja` | `_` |
| `mIwDu_vieja` | `_` |
| `mIwDu_rap_vieja` | `__` |
| `jagh_bachDu_vieja` | `__` |
| `jaHDu_vieja` | `_` |
| `escudo_activo_vieja` | `c_c_` |
| `escudo_carga_vieja` | `c_c_` |
| `ghom_vieja_form` | `__` |

### Per-tick temporaries

| ASCII | pIqaD |
|-------|-------|
| `tecla` | `c` |
| `nab` | `` |
| `nab_rap` | `_` |
| `HoH_Duj` | `_` |
| `HoH_jaHDuj` | `_` |
| `naQDu` | `` |
| `naQDu_rap` | `_` |
| `naDanHa` | `` |
| `hubo_drift` | `_` |
| `accion` | `cc` |

### Session hot-vars (°prefix)

| ASCII | pIqaD |
|-------|-------|
| `maQDu` | `` |
| `nob_maQ` | `_` |

---

## 4. Special cases

| Pattern | Example | Rule |
|---------|---------|------|
| Module call | `::_` | alias `::` function — both converted |
| Loop label break | `@:!` | label converted, `@:` and `!` stay |
| Loop continue | `@:_>` | same rule |
| Hot-var | `°` | `°` stays ASCII, name converted |
| Boolean | `#` / `#` | `#` stays, digit converted |
| Char literal | `'q'` | NOT converted — keyboard input |
| String literal | `"Qapla'!"` | NOT converted — display text |
| Bash exec | `<\ "date +%N" \>` | string inside NOT converted |
