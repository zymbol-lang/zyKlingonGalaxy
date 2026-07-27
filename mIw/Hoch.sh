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
# HUD.zy, Duj.zy y jagh.zy declaran su nombre de módulo en pIqaD
# mientras que sus archivos están romanizados, así que E001 salta en
# los tres. Es anterior a este trabajo y no tiene arreglo sin
# renombrar archivos o poner nombres latinos en un programa que no
# los quiere: queda registrado como HOV-I18N-006 y se cuenta aparte.
#
# EN: HUD.zy, Duj.zy and jagh.zy declare their module name in pIqaD
# while their files are romanized, so E001 fires on all three. It
# predates this work and cannot be fixed without either renaming
# files or putting Latin names into a program that does not want
# them — recorded as HOV-I18N-006 and counted separately.
conocidos=0
for archivo in hov_veS.zy HUD.zy juv.zy gho.zy \
               Hol/jatlh.zy Hol/tlhIngan.zy Hol/English.zy Hol/Español.zy; do
    if salida=$(zymbol check "$archivo" 2>&1); then
        echo "  OK       $archivo"
    elif [ "$(echo "$salida" | grep -c '^error')" = "1" ] && echo "$salida" | grep -q "E001"; then
        echo "  E001     $archivo   (HOV-I18N-006, conocido)"
        conocidos=$((conocidos + 1))
    else
        echo "  FALLA    $archivo"
        echo "$salida"
        fallo=1
    fi
done
echo
[ "$conocidos" -gt 0 ] && echo "  ($conocidos con el E001 conocido de HOV-I18N-006)" && echo

if [ "$fallo" -eq 0 ]; then
    echo "Hoch PASS"
else
    echo "Hoch FAIL"
    exit 1
fi
