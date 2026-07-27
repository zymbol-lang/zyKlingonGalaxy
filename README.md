# Hov veS

> **Targets Zymbol v0.0.8** — revised 2026-07-26

Galaxian-style space shooter for the terminal, set in the Klingon universe.
The IKS meQtaH (B'rel Bird-of-Prey) defends against Federation armada waves.

Hov veS is the second real TUI game written in Zymbol, following Serpiente.
It was built to validate a different set of language capabilities: multi-module
state threading, formation drift and dive AI, a dual projectile system, wave
progression with scaling difficulty, session-persistent statistics via
hot-definition variables, and 3-language i18n (pIqaD / English / Spanish).

The i18n was first written with the locale threaded as a parameter through
`HuD.zy` and `hov_veS.zy`, with each visible string duplicated once per language
inside the render — 79 conditioned draw lines. In v0.0.8 it was rebuilt around a
dispatcher holding the locale as module state, a catalogue of 27 domain-prefixed
keys written in Klingon in pIqaD, and frames measured rather than typed.

> **Validation project for Zymbol v0.0.5** — stress-tests multi-module
> orchestration, Galaxian-style formation AI, delta rendering and entropy
> management.
>
> **Revisited for v0.0.8** — the i18n was rewritten. The locale is now module
> state rather than a parameter threaded through the render calls, every panel
> is built from measured content via `std/term` instead of fixed-width literals,
> and a completeness gate walks 27 keys × 3 locales in both engines. See
> [auditoria_i18n_es.md](auditoria_i18n_es.md) and the project-wide doctrine in
> [USERAPPI18N.md](https://github.com/zymbol-lang/interpreter/blob/main/USERAPPI18N.md).

> **Español:** [README_ES.md](README_ES.md)

---

## How to play

Requires the [Zymbol interpreter](https://github.com/zymbol-lang/interpreter)
**v0.0.8 or later** (the layout depends on `std/term`):

```bash
git clone https://github.com/zymbol-lang/zyKlingonGalaxy
cd zyKlingonGalaxy
zymbol run hov_veS.zy
```

Requires a pIqaD-compatible font (CSUR PUA, U+F8D0–F8FF) for Klingon script
in the menus. A terminal of at least 40 × 20 characters is recommended.

---

## Controls

| Key | Action |
|-----|--------|
| `←` / `A` | Move ship left |
| `→` / `D` | Move ship right |
| `Space` | Fire disruptor bolt (1 active, instant kill) |
| `↑` | Rapid fire burst (4 bolts, 1 damage each) |
| `↓` | Toggle shield (3 charges per life — absorbs enemy bolts) |
| `P` | Pause / resume |
| `Q` | Quit during a game |
| `L` | Cycle language — on the difficulty and game-over screens |
| `1`–`4` | Select difficulty directly in menu |
| `↑` `↓` + `↵` | Navigate menus |

---

## Screens

### Language selection

The first screen after launch lets you choose the display language. It affects
all menu text and HUD labels. Navigate with `↑`/`↓` or press `1`–`3`, then `↵`:

```
╭──────────────────────────────────╮
│         [pIqaD title]            │
│       [pIqaD subtitle]           │
├──────────────────────────────────┤
│   tlhIngan Hol / Language:       │
│                                  │
│   [1]  tlhIngan (pIqaD)          │
│ ► [2]  English                   │
│   [3]  Español                   │
├──────────────────────────────────┤
│  ↑↓ / 1-3 / ↵                   │
╰──────────────────────────────────╯
```

`Q` falls back to pIqaD mode. The selected language persists for the entire
session (all menus, wave-clear, game-over, and HUD labels).

### Difficulty selection

A centered menu appears at startup. Navigate with `↑` `↓` and confirm with `↵`
(or press `1`–`4` directly):

```
╭────────────────────────────────╮
│         H O V   V E S          │
│       IKS  meQtaH              │
│  B'rel Bird-of-Prey vs Armada  │
├────────────────────────────────┤
│   Select difficulty:           │
│                                │
│   [1]  petaQ    (easy)  120 ms │
│ ► [2]  Hab SoSlI (med)   90 ms │
│   [3]  Qapla'   (hard)   60 ms │
│   [4]  Heghlu'  (death)  40 ms │
├────────────────────────────────┤
│  ↑↓ / 1-4 / ↵ to confirm      │
│  Q = quit during game          │
╰────────────────────────────────╯
```

### Gameplay

The border frames the playfield and overlays the HUD: tribble lives on the left,
score centered, wave number on the right. Enemies drift laterally and periodically
break formation to dive toward the player.

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

**Enemy glyphs and point values:**

| Glyph | Type | Points | Formation rows |
|-------|------|--------|----------------|
| `◆` | almirante | 50 | row 2 |
| `▼` | capitan | 20 | rows 3–4 |
| `▽` | soldado | 10 | rows 5–6 |

Divers (enemies that break formation and fly toward the ship) award **2×** base
points when destroyed mid-dive.

### Wave clear

After all enemies and active divers are destroyed, a brief overlay appears before
the next wave:

```
╭───────────────────────────╮
│      Q A P L A ' !        │
│   Wave 2 cleared!         │
│   Score: 180              │
╰───────────────────────────╯
```

### Pause

Press `P` during a game to show a centered pause panel. Press `P` again to resume.
The board is fully redrawn on resume.

### Game over

When all three tribble lives are lost, a menu shows session statistics and offers
to start a new game:

```
╭───────────────────────────╮
│     H E G H L U ' !       │
│   ( you have died )       │
├───────────────────────────┤
│  Score:   180             │
│  Wave:    3               │
│  Games:   2               │
├───────────────────────────┤
│► New game                 │
│  Quit                     │
╰───────────────────────────╯
```

**Games** played and cumulative score list persist across restarts within the
same session, tracked via hot-definition variables scoped to the outer `>>|` block.

---

## Architecture

```
klingon_galaxy/
├── hov_veS.zy      entry point — seed, dimensions, outer game loop, event dispatch
├── Duj.zy          player ship — lateral movement with boundary clamping
├── jagh.zy         enemy fleet — formation build, drift, dive attacks, LCG
├── bach.zy         projectiles — player bolts, enemy bolts, hit detection, scoring
├── HuD.zy          display — menus, border, delta rendering, overlays
├── juv.zy          Klingon layer over std/term (column metrics)
├── gho.zy          panels built from measured content — no fixed widths
├── Hol/
│   ├── jatlh.zy    i18n dispatcher — holds the locale as module state
│   ├── tlhIngan.zy Klingon locale (base language, where the keys come from)
│   ├── English.zy  English locale
│   └── Español.zy  Spanish locale
├── mIw/
│   ├── Hol.zy      completeness gate: keys × locales, numerals, frames
│   └── Hoch.sh     runs every suite in both engines
├── auditoria_i18n_es.md  i18n audit of the project (Spanish)
└── hallazgos_es.md bug/gap registry found during development (Spanish)
```

### Modules

**`Duj.zy`** exports:
- `bIng(Duj, AN)` — move ship one column left; clamps at column 2
- `Dung(Duj, AN)` — move ship one column right; clamps at column `AN+1`

**`jagh.zy`** exports:
- `chen_ghom(AN, AL, HoS, mIS)` — build 5×10 formation for wave `HoS`;
  returns `(ghom, mIS)`
- `Suy_mIw(ghom, jaHDu, AN, AL, HoS, mIS)` — advance formation drift and active
  divers; possibly launch a new dive; returns `(ghom, jaHDu, mIS, hubo_drift)`
- `HoH_nob(jaHDu, Duj, Duj_fila)` — detect diver collision with player ship;
  returns `#1`/`#0`
- `naQ_ghom(ghom, jaHDu)` — returns `#1` when all enemies and divers are cleared

**`bach.zy`** exports:
- `tagh(mIwDu, fila, col)` — spawn a new bolt (disruptor or rapid)
- `vIH_mIwDu(mIwDu, bachHaw, ghom, jaHDu, AL)` — advance disruptor bolts, resolve
  instant-kill hits; returns `(mIwDu, bachHaw, nab, ghom, jaHDu, naQDu)`
- `vIH_mIwDu_rap(mIwDu_rap, ghom, jaHDu, AL)` — advance rapid bolts, resolve
  1-damage hits; returns `(mIwDu_rap, nab, ghom, jaHDu, naQDu_rap, naDanHa)`
- `jagh_tagh(jagh_bachDu, ghom, jaHDu, mIS, HoS)` — possibly fire one enemy bolt
  (probability scales with wave number); returns `(jagh_bachDu, mIS)`
- `vIH_jagh_bachDu(jagh_bachDu, Duj, Duj_fila, AN, AL, escudo_activo, escudo_carga)` —
  advance enemy bolts, detect player hit; shield absorbs if active (consumes 1 charge);
  returns `(jagh_bachDu, HoH_Duj, escudo_activo, escudo_carga)`

**`HuD.zy`** exports — note that **no signature carries a locale**: it lives in
`Hol/jatlh.zy` as module state.
- `sel_Hol(AN, AL)` — language selector (first screen). Sets the locale in
  `Hol/jatlh` and returns its ISO 639 code; the return value is a convenience,
  the side effect is the point
- `menu_HeH(AN, AL)` — title screen + difficulty selector; returns ms/tick delay
- `chen_bID(AN, AL)` — draw full border and clear playfield
- `yIH_HuD(yIHmey, AN, AL)` — draw tribble lives in top border
- `nob_HuD(nob, AN)` — draw score in top border
- `HoS_label(HoS, AN)` — draw wave number in top border
- `escudo_HuD(escudo_carga, escudo_activo, AN)` — draw shield charges in top border
  (cyan label when active; `■` filled / `·` empty per charge)
- `ghom_HuD(ghom, AN, AL)` — draw full enemy formation (initial render)
- `Duj_HuD(Duj, Duj_fila, AN, escudo_activo)` — draw player ship (cyan when shielded)
- `yot(AN, AL)` — pause overlay; blocks until `P`
- `Hegh_mIS(Duj, Duj_fila, AN, AL)` — death flash animation (3 pulses)
- `HoS_tugh(ola, nob, AN, AL)` — wave-clear overlay with 1.8 s pause
- `Hegh_nav(nob, HoS, maQDu, nob_maQ, AN, AL)` — game-over menu; returns
  `'n'` (new game) or `'s'` (quit)
- `chou_bID(...)` — delta render: redraws only changed cells each tick

**`Hol/jatlh.zy`** exports — the i18n dispatcher. Every locale module implements
the same three-function contract:
- `cher(código)` / `DaH()` — set and read the active locale (`tlh`, `en`, `es`)
- `Holmey()` / `rInmey()` — the locale list and the master key catalogue
- `mu'(clave)` — the translated string for a key
- `mI'(n)` — a number in the active locale's script. Not cosmetic: Klingon
  writes its digits in pIqaD (U+F8F0–F8F9), English and Spanish in ASCII
- `Qaw'mu'(n)` — the "wave N cleared" sentence, composed by each locale

**`juv.zy`** — a Klingon layer over `std/term`: `'ar` (display width in terminal
columns, not graphemes), `poS` / `nIH` (pad), `botlh` (centre), `pe'` (truncate).

**`gho.zy`** exports — panels built from measured content:
- `chen(líneas, hueco)` — frame a list of already translated lines; every row
  returned is exactly the same column count, in any language
- `'ar(líneas)` — the widest line of a list, in terminal columns
- `per_tlhegh(n, etiqueta, seleccionada)` — a menu row with its `►` marker
  applied *before* measuring, so rows never shift when the cursor moves
- `PE` / `BOTLH` — line markers: a horizontal rule, and "centre this line"

### Data model

All mutable state threads explicitly through function calls — no shared global
state. The main data structures:

| Variable | Type | Contents |
|----------|------|----------|
| `ghom` | 3-tuple | `(vel, ticks, enemigos)` — formation drift state |
| `enemigos` | array of 4-tuples | `(fila, col, tipo, hp)` — living formation enemies |
| `jaHDu` | array of 5-tuples | `(fila, col, tipo, vel_fila, vel_col)` — active divers |
| `mIwDu` | array of 2-tuples | `(fila, col)` — player bolts in flight |
| `jagh_bachDu` | array of 2-tuples | `(fila, col)` — enemy bolts in flight |

### Delta rendering

`chou_bID` does not clear the playfield on every tick. Only changed cells are
redrawn:

| Condition | Cells redrawn |
|-----------|---------------|
| `hubo_drift == #1` | Blank rows 2–6, redraw entire formation |
| `hubo_drift == #0` | Erase only destroyed enemies from `naQDu`/`naQDu_rap` |
| Always | Redraw glyph of `naDanHa` entries (damaged enemies still alive) |
| Always | Erase old / draw new diver positions |
| Always | Erase old / draw new disruptor bolt positions |
| Always | Erase old / draw new rapid-fire bolt positions |
| Always | Erase old / draw new enemy bolt positions |
| `Duj_vieja <> Duj` | Erase old ship column, draw at new column |
| Shield state change | Update ship color and shield-charge HUD label |

### Randomness

The initial seed `mIS` is derived at startup from three independent entropy
sources via BashExec (`date +%N`, `$$`, `/dev/urandom`). All subsequent
randomness uses an LCG in pure Zymbol — no BashExec per tick. The LCG uses the
same constants as `serpiente/logica.zy`:
`(1664525 × mIS + 1013904223) % 2147483647`.

The seed is passed as an explicit argument and returned as part of every tuple
that advances it.

---

## Zymbol v0.0.5 primitives used

| Primitive | Use in Hov veS |
|-----------|----------------|
| `>>| { }` | TUI block — alternate screen, raw mode, hidden cursor |
| `>>~ (r, c, bg, fg) > items` | 4-arg positioned output with explicit bg and fg colors (ANSI 256) |
| `>>!` | Clear screen (menus, pause entry) |
| `>>?` | Query real terminal size; polled every tick for resize detection |
| `<<|? var` | Non-blocking key read (game loop) |
| `<<| var` | Blocking key read (menus, pause, game over) |
| `@~ ms` | Sleep (controls tick rate / difficulty) |
| `°var` | Hot var scoped to `>>|` outer block — session game count |
| `°var += n` / `°var $+ v` | Accumulate across games within a session |
| `@:label >` | Continue to named outer loop (terminal resize → restart wave) |
| `@:label!` | Break named loop (wave clear, death, quit) |

---

## Language findings

During the development of Hov veS, two behaviors in Zymbol were identified and
documented in [`hallazgos_es.md`](hallazgos_es.md) (Spanish). One was a design
gap with a known workaround; the other was a genuine interpreter bug that was
fixed.

| ID | Type | Description | Status |
|----|------|-------------|--------|
| HLZ-001 | Gap | New variables assigned only inside `? cond { }` blocks not visible in the outer scope | Workaround: pre-declare with a default value, or extract logic to a helper function |
| HLZ-002 | Bug | Module `:=` constants inaccessible when a private function calls another private function in the same module (intra-module call without `alias::` prefix) | **Fixed** in `interpreter/crates/zymbol-interpreter/src/functions_lambda.rs` |
