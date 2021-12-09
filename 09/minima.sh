#!/usr/bin/zsh

set -uo pipefail

zmodload zsh/mapfile
local -a rows
rows=("${(f)mapfile[$1]}")

local -i part_i=0
local -A basin
local -A basin_size

basins_not_done() {
  for (( v=1; v < $#rows ; v++ )); do
    for (( h=1; h <= $#rows[1] ; h++ )); do
      local -i this=${${rows[$v]}[$h]}
      (( this == 9 )) && continue
      [[ $basin["$v,$h"] == *,* ]] && continue
      return 0
    done
  done
  return 1
}

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
    if (( this < left && this < righ && this < abov && this < blow )); then
      basin["$v,$h"]=$v,$h
      basin_size[$basin["$v,$h"]]=1
      (( part_i += this + 1 ))
    fi
  done
done

echo "part I: ${part_i}"

set +u
while basins_not_done; do
  for (( v=1; v < $#rows ; v++ )); do
    for (( h=1; h <= $#rows[1] ; h++ )); do
      local -i this=${${rows[$v]}[$h]}
      (( this == 9 )) && continue
      [[ $basin["$v,$h"] == *,* ]] && continue

      # Assume from the exercise that these will never be different basins.
      [[ $basin["$v,$((h-1))"] == *,* ]] && basin["$v,$h"]=$basin["$v,$((h-1))"]
      [[ $basin["$((v-1)),$h"] == *,* ]] && basin["$v,$h"]=$basin["$((v-1)),$h"]
      [[ $basin["$((v+1)),$h"] == *,* ]] && basin["$v,$h"]=$basin["$((v+1)),$h"]
      [[ $basin["$v,$((h+1))"] == *,* ]] && basin["$v,$h"]=$basin["$v,$((h+1))"]

      # This got updated, so increase size of the basin
      [[ $basin["$v,$h"] == *,* ]] && (( basin_size[$basin["$v,$h"]] += 1 ))
    done
  done
done

local -a sorted
sorted=(${(On)basin_size})
# for key val in "${(@kv)basin_size}"; do
#   echo "$key -> $val"
# done
# for key val in "${(@kv)basin}"; do
#   echo "$key -> $val"
# done
echo "part II: $(( $sorted[1] * $sorted[2] * $sorted[3] ))"
