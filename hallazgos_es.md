# Hallazgos — Bugs y Gaps del lenguaje Zymbol

Registro de comportamientos inesperados encontrados durante el desarrollo.
Cada entrada incluye: síntoma, contexto, investigación, workaround y clasificación.

---

## HLZ-001 — Variables nuevas en bloques `? cond { }` no son visibles en el scope exterior

**Tipo:** Bug (comportamiento inconsistente)
**Estado:** Workaround aplicado
**Encontrado en:** `klingon/jagh.zy` — función `chen_ghom`

### Síntoma

```
Runtime error: 'tipo' is undefined — did you mean 'tipo°' (hot definition)?
```

### Contexto

```zymbol
@:f_loop {
    ? fila == 2 { tipo = 2 }   // asignación dentro de ? { }
    ? fila == 3 { tipo = 1 }
    ? fila >= 5 { tipo = 0 }
    enemigos = enemigos $+ (fila, col, tipo)   // ERROR: tipo no visible aquí
}
```

### Investigación

Los bloques `? cond { }` crean su propio scope. Una variable **nueva** (no previamente declarada en el scope exterior) asignada dentro del bloque sólo existe en ese bloque. Al salir del bloque, la variable desaparece.

Este comportamiento NO aplica cuando la variable YA existe en el scope exterior antes del bloque: en ese caso la asignación hace write-through y modifica el valor en el scope externo. Esto es consistente con el modelo de entornos encadenados del tree-walker: `env.set` sube la cadena hasta encontrar la variable y la actualiza; si no la encuentra, la crea en el scope más interior (el bloque).

### Workaround

Extraer la lógica condicional a una función helper que retorna el valor:

```zymbol
_tipo_fila(fila) {
    ? fila == 2 { <~ 2 }
    ? fila <= 4 { <~ 1 }
    <~ 0
}

// En el loop:
tipo = _tipo_fila(fila)   // asignación incondicional → visible en scope exterior ✓
```

### Regla práctica

> Antes de usar una variable fuera de un bloque `? { }`, declararla con un valor por defecto en el scope externo, o extraer la lógica a una función.

---

## HLZ-002 — Constantes de módulo (`:=`) inaccesibles en funciones privadas del mismo módulo

**Tipo:** Bug — scope incorrecto en llamadas intra-módulo
**Estado:** Fix aplicado en el intérprete (`functions_lambda.rs`)
**Encontrado en:** `klingon/HuD.zy`

### Síntoma

```
Runtime error: 'COLOR' is undefined — did you mean 'COLOR°' (hot definition)?
```

Una función privada (llamada desde otra función del mismo módulo sin prefijo `alias::`) no podía acceder a constantes `:=` definidas al nivel del módulo.

### Contexto

```zymbol
# HUD {
    COLOR := 220          // constante de módulo

    _helper() {
        >> COLOR          // ERROR cuando se llama desde otra función del módulo
    }

    ejecutar() {
        _helper()         // llamada intra-módulo sin alias:: → bug
    }
}
```

Llamadas externas (`hud::ejecutar()`) funcionaban porque el intérprete inyectaba las variables del módulo en el scope fresco. Las llamadas internas (`_helper()` desde dentro de `ejecutar`) tomaban el path `module_info = None` y no recibían esa inyección.

### Causa raíz

En `functions_lambda.rs` → `eval_traditional_function_call`:

- **Llamada externa** (`alias::fn()`, `module_info = Some(...)`): el intérprete inyecta `module.all_variables` en el scope fresco. Las constantes están disponibles. ✓
- **Llamada intra-módulo** (`fn()` sin prefijo, `module_info = None`): el intérprete sólo heredaba `import_aliases` del caller. **No inyectaba las variables del módulo**. Las constantes no estaban en el nuevo scope. ✗

Cada función recibe un scope completamente fresco vía `take_call_state()`. Sin la inyección explícita, el scope queda vacío (sólo parámetros y locales).

### Fix en el intérprete

`interpreter/crates/zymbol-interpreter/src/functions_lambda.rs` — rama `else` (llamadas sin módulo explícito):

```rust
// Intra-module call: if the function was defined inside a loaded module, inject
// that module's variables so :=  constants and mutable state are visible.
if let Some(ref origin_path) = func_def.origin_module_path {
    if let Some(module) = self.loaded_modules.get(origin_path).cloned() {
        for (name, value) in &module.all_variables {
            self.set_variable(name, value.clone());
        }
    }
}
```

`func_def.origin_module_path` apunta al archivo donde se declaró la función. Para módulos importados ese path está en `loaded_modules`; para el script principal no está (inyección saltada automáticamente).

### Estado de HuD.zy

Las constantes numéricas en `HuD.zy` se dejaron como literales por robustez y claridad (el fix del intérprete permite usar `:=` pero la paleta ya está documentada en el comentario de cabecera).

| Tipo de llamada | Antes del fix | Después del fix |
|----------------|---------------|-----------------|
| `alias::fn()` (externa) | ✓ | ✓ |
| `fn()` intra-módulo | ✗ constantes inaccesibles | ✓ |
| `fn()` en script principal | ✓ (no hay módulo) | ✓ |

### Regla práctica

> Las constantes `:=` de módulo ahora son accesibles en todas las funciones del módulo, incluyendo las privadas. El workaround de usar literales directamente sigue siendo válido para claridad.

---

## HLZ-003 — `$+` con String como operando izquierdo falla en `--vm` con "expected Array, got String"

**Tipo:** Bug — gap de cobertura en el VM (no afecta al tree-walker)
**Estado:** Fix aplicado en el VM (`zymbol-vm/src/lib.rs`)
**Encontrado en:** `klingon/HuD.zy` — función privada `__()` (`int_to_piqad`)

### Síntoma

```
Runtime error: type error: expected Array, got String
```

Solo se manifiesta con `zymbol run --vm`. El tree-walker ejecuta el mismo código sin error.

### Contexto

La función `__()` en `HuD.zy` convierte un entero a una cadena de dígitos pIqaD construyendo la cadena de derecha a izquierda:

```zymbol
__( n ) {
    ? n == 0 { <~ "" }
    s = ""
    @:lup {
        ? n == 0 { @:lup! }
        r = n % 10
        d = ""
        ? r == 0 { d = "" }   // dígito pIqaD 0
        // ... más ramas para r == 1..9
        s = d $+ s             // ← prepend: d antepuesto a s
        n = n / 10
    }
    <~ s
}
```

La operación crítica es `s = d $+ s`: aquí `d` (operando izquierdo) es un String y `s` (operando derecho) también es un String. Se trata de una **concatenación** de strings, no un append de Array.

### Causa raíz

El compilador del VM (`zymbol-compiler`) siempre emite `ArrayPush` para la expresión `CollectionAppend` (`$+`), sin distinción entre:

| Caso | Operando izquierdo | Semántica correcta | Instrucción emitida |
|------|-------------------|-------------------|---------------------|
| `lista $+ elem` | Array | push al array | `ArrayPush` ✓ |
| `str $+ str2` (self) | String | concat de strings | `ArrayPush` ✗ |
| `d $+ s` (no-self) | String | concat de strings | `ArrayPush` ✗ |

El path de **self-append** (`arr = arr $+ elem`) tiene una optimización especial en `compile_assign` (línea 890) que inicializa con `HotNeutral::Array` cuando el LHS es un hot-var. Pero el path general de `compile_collection_append` siempre emite:

```rust
CopyReg(dst, r_coll)    // copia el operando izquierdo
ArrayPush(dst, r_elem)  // intenta push → ERROR si dst es String
```

En el VM, `ArrayPush` sólo manejaba `Value::Array` y `Value::Tuple`; cualquier otro tipo lanzaba el TypeError.

El tree-walker no tiene este problema porque evalúa `$+` dinámicamente en runtime: si el operando izquierdo es String, hace concatenación; si es Array, hace push.

### Fix en el VM

`interpreter/crates/zymbol-vm/src/lib.rs` — handler de `Instruction::ArrayPush` (fast path y slow path):

```rust
Value::String(s) => {
    // $+ sobre string: concatenar representación del elemento
    use std::fmt::Write as _;
    let mut buf = s.clone().try_into_string();
    match val {
        Value::String(r) => buf.push_str(r.as_str()),
        Value::Char(c)   => buf.push(c),
        other            => { let _ = write!(buf, "{}", other); }
    }
    *s = ZyStr::new(buf);
}
```

El handler ahora cubre `Array`, `Tuple` y `String`. Para String, replica la semántica de `ConcatStr`: concatena la representación del elemento al string destino.

### Verificación

```
436/436 tests de paridad tree-walker / VM — sin regresiones.
```

### Regla práctica

> En el VM, `$+` es seguro sobre Arrays, Tuples **y** Strings. La distinción semántica (push vs. concat) se resuelve en runtime según el tipo del operando izquierdo, igual que en el tree-walker.

---

## HLZ-KL-001 — La interpolación `"{x}"` no admite identificadores en pIqaD

**Tipo:** Gap (asimetría entre identificadores válidos y la interpolación)
**Estado:** **Corregido en el intérprete** (2026-07-27)
**Encontrado en:** `Hol/English.zy` y `Hol/Español.zy`, al escribir `mI'(n)`

### Síntoma

```
error: invalid character in string interpolation
  --> Hol/English.zy:73:31
  = help: interpolation must be {identifier} — use \{ for a literal brace
```

### Contexto

Un identificador escrito en pIqaD es perfectamente válido en cualquier otra
posición —este programa entero está escrito así— pero deja de serlo dentro de
`{ }`:

```zymbol
# prueba {
    #> { f }
    f(⟨mIwI en pIqaD⟩) { <~ "{⟨mIwI en pIqaD⟩}" }   // ✗ invalid character
}
```

### Investigación

No es cosa del pIqaD como escritura, sino de la categoría Unicode. El lexer de
interpolación exige que el nombre sea alfanumérico, y los glifos pIqaD viven en
el Área de Uso Privado:

| Carácter | Punto de código | Categoría | `isalnum()` | ¿Interpola? |
|---|---|---|---|---|
| `整` (kanji) | U+6574 | `Lo` | sí | **sí** |
| ⟨m en pIqaD⟩ | U+F8DA | `Co` | no | **no** |
| ⟨I en pIqaD⟩ | U+F8D7 | `Co` | no | **no** |

Es decir: 囲碁 puede escribir `"{整}.5 points"` y Hov veS no puede escribir lo
mismo con sus propios identificadores. Un programa cuyos identificadores son
válidos en todas partes menos en la interpolación.

### Solución aplicada (2026-07-27)

`Lexer::is_ident_start` y `Lexer::is_ident_continue` pasan a ser públicas y son
la definición única de qué es un identificador. El bucle de interpolación del
lexer, la exploración de interpolación del análisis semántico y los tres
ayudantes del analizador (LSP) delegan ahora en ellas.

La misma regla estrecha estaba copiada en tres sitios, con tres síntomas: la
interpolación fallaba, el aviso de «variable no usada» saltaba sobre nombres que
el programa sí lee dentro de `"{ }"`, y el LSP no reconocía esos identificadores
para hover ni autocompletado. Los tres desaparecen con el mismo cambio.

Regresión: `tests/i18n/interp_identificadores.zy` en el repo del intérprete —
interpola nombres en latino, kanji, hangul, cirílico, griego, devanagari, pIqaD
(con el apóstrofo klingon incluido) y un emoji, en el nivel superior y dentro de
una función de módulo. Falla con el binario anterior.

`Hol/English.zy` y `Hol/Español.zy` vuelven a usar interpolación.

### Workaround que se usaba antes

`$++`, el constructor de strings, que sí acepta cualquier expresión:

```zymbol
⟨mI'⟩(⟨mI'wI'⟩) { <~ "" $++ ⟨mI'wI'⟩ }
⟨Qaw'mu'⟩(⟨HoS⟩) { <~ "Wave " $++ ⟨HoS⟩ " cleared" }
```

Funciona, y en los dos motores. Pero obliga a que todo el código que mezcla
texto y números en este proyecto use una sintaxis distinta de la que usa el
resto del ecosistema, sin que haya ninguna razón de diseño para ello.

### Regla práctica

> La interpolación acepta exactamente lo que el lexer acepta como identificador
> en cualquier otra posición. Si un nombre es válido, se puede interpolar.

---

## HLZ-KL-002 — El modo numeral `#d0d9#` es global, no «file-local» como dice la doc

**Tipo:** Divergencia doc vs implementación (ambos motores coinciden entre sí)
**Estado:** Doc corregida en `interpreter/GUIDE.md` §18b; código de este proyecto adaptado
**Encontrado en:** `Hol/tlhIngan.zy`, al reescribir `mI'` con el sistema nativo

### Síntoma

Una función de módulo que activa `#⟨0⟩⟨9⟩#` para renderizar en pIqaD deja el
modo activo **para todo el programa**: el `>>` del llamador y las demás
funciones —incluidas las de otros idiomas— empiezan a imprimir en pIqaD.

### Investigación

GUIDE.md §18b afirmaba:

> Mode is **file-local** — each file starts in ASCII mode.
> Importing a module does not inherit or alter the caller's mode.

La implementación no es así: `numeral_mode` es un único campo del intérprete
(`zymbol-interpreter/src/lib.rs`) y de la VM (`zymbol-vm/src/lib.rs`), y
`Statement::SetNumeralMode` lo escribe sin guardar ni restaurar nada en los
límites de archivo, módulo o función.

Comprobado con un módulo que activa el modo y no lo resetea: el `plain()` del
mismo módulo y el `>> 120` del script llamador salen los dos en pIqaD, en
tree-walker **y** en `--vm`. Los dos motores coinciden, así que no es un fallo
de paridad: es la doc la que estaba mal.

### Consecuencia práctica

Un formateador de números por idioma **tiene que devolver el modo a ASCII él
mismo**. Es lo que hace posible que `mI'` exista:

```zymbol
mI'(n) {
    #⟨0⟩⟨9⟩#      // activa pIqaD
    s = "{n}"     // la interpolación ya lo respeta (v0.0.8)
    #09#          // OBLIGATORIO: devuelve ASCII al llamador
    <~ s
}
```

Sin la línea `#09#`, `Hol/English.zy` y `Hol/Español.zy` imprimirían sus
números en pIqaD.

### Regla práctica

> `#d0d9#` no tiene ámbito. Quien lo activa dentro de una función es
> responsable de resetearlo antes de retornar.

---

## Notas generales

- El mensaje `'X' is undefined — did you mean 'X°' (hot definition)?` es un falso positivo cuando `X` es una constante de módulo llamada desde una función privada: el runtime no la encontraba en el scope y sugería erróneamente hot-var. Resuelto con el fix de HLZ-002.
- HLZ-KL-001 salió a la luz al reescribir la i18n del proyecto (ver
  [auditoria_i18n_es.md](auditoria_i18n_es.md)). No es un fallo de esa reescritura:
  el código anterior nunca interpolaba porque convertía los números a mano, cifra a
  cifra, con `_n_pIq`.
- HLZ-001 y HLZ-002 comparten la fuente: cada función obtiene un scope completamente fresco (`take_call_state`). HLZ-001 es correcto por diseño (scope de bloque `? {}`). HLZ-002 era un bug de inyección faltante en llamadas intra-módulo, ya corregido en el intérprete.
