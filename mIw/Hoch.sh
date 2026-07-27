#!/usr/bin/env bash
# ============================================================
# mIw/Hoch.sh — todas las suites de Hov veS
#
#   bash mIw/Hoch.sh
#
# El juego en sí no se puede probar aquí: >>| se niega a arrancar
# sin una terminal de verdad. Lo automatizable —el catálogo de
# idiomas, las frases compuestas, los números en pIqaD y el cuadre
# de los marcos— corre en los dos motores.
#
# EN: mIw/Hoch.sh — every Hov veS suite. The game itself cannot be
# tested here (>>| refuses to start without a real terminal), but
# the i18n catalogue, the composed messages, the pIqaD numerals and
# the frame arithmetic are, in both engines.
# ============================================================
set -u
cd "$(dirname "$0")/.."

fallo=0

for motor in "" "--vm"; do
    echo "─── mIw/Hol.zy ${motor:-tree-walker}"
    salida=$(zymbol run $motor mIw/Hol.zy 2>&1)
    echo "$salida" | tail -1
    if echo "$salida" | grep -q "FAIL"; then
        echo "$salida"
        fallo=1
    fi
    echo
done

echo "─── zymbol check"
for archivo in hov_veS.zy HuD.zy Duj.zy jagh.zy bach.zy juv.zy gho.zy \
               Hol/jatlh.zy Hol/tlhIngan.zy Hol/English.zy Hol/Español.zy; do
    if salida=$(zymbol check "$archivo" 2>&1); then
        echo "  OK     $archivo"
    else
        echo "  FALLA  $archivo"
        echo "$salida"
        fallo=1
    fi
done
echo

if [ "$fallo" -eq 0 ]; then
    echo "Hoch PASS"
else
    echo "Hoch FAIL"
    exit 1
fi
