#!/usr/bin/zsh

set -uo pipefail

zmodload zsh/mapfile
local -a rows
rows=("${(f)mapfile[$1]}")

local -i part_i=0

for (( v=1; v < $#rows ; v++ )); do
  for (( h=1; h <= $#rows[1] ; h++ )); do
    local -i this=${${rows[$v]}[$h]}
    local -i left=10
    local -i righ=10
    local -i abov=10
    local -i blow=10

    (( h > 1 )) && left=${${rows[$v]}[$((h-1))]}
    (( h < $#rows[1] )) && righ=${${rows[$v]}[$((h+1))]}
    (( v > 1 )) && abov=${${rows[$((v-1))]}[$h]}
    (( v < $#rows - 1 )) && blow=${${rows[$((v+1))]}[$h]}
    (( this < left && this < righ && this < abov && this < blow )) && (( part_i += this + 1 ))
  done
done


echo "part I: ${part_i}"
