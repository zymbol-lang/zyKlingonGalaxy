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
#
# ── NOTE ─────────────────────────────────────────────────────────────────
# This script is not the authority. It used to decide correctness by
# grepping the suite's output for FAIL, so a suite that crashed half way
# through printed no FAIL and passed — measured, not supposed. Since
# 2026-09-29 each suite ends a failing run with `<~ 1` (IDEA-GOL-012), and
# a crash exits non-zero anyway, so this reads the exit status instead.
# It still runs two engines of the three.
#
# The gate is in ZyQuality, which compares each suite against a golden (a
# truncated run does not match one) and runs every engine that can:
#
#     cd ../zyquality && ./zyq suite --only project
#     cd ../zyquality && bash project/run.sh --only klingon
#
# What is still worth running here is the `zymbol check` sweep below, which
# is about this application's own sources.
# ─────────────────────────────────────────────────────────────────────────
set -u
cd "$(dirname "$0")/.."

fallo=0

for motor in "" "--vm"; do
    echo "─── mIw/Hol.zy ${motor:-tree-walker}"
    salida=$(zymbol run $motor mIw/Hol.zy 2>&1)
    estado=$?
    echo "$salida" | tail -1
    if [ "$estado" -ne 0 ]; then
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
