#!/usr/bin/zsh

set -uo pipefail

zmodload zsh/mapfile
local -a board
board=("${(f)mapfile[$1]}")

local -a octopuses
for (( row = 1; row <=10; row++ )); do
  local ro=$board[$row]
  for (( col = 1; col <=10; col++ )); do
    local -i here=$ro[$col]
    octopuses[$((10*(row-1)+col))]=$here
  done
done

local -i flashes=0
for (( step=1 ; step<=1000; step++ )); do
  local -i current_flashes=0
  for (( oct=1; oct<=100; oct++ )); do
    (( octopuses[$oct]++ ))
  done

  for (( oct=1; oct<=100; oct++ )); do
    if (( octopuses[$oct] > 9 )); then
      (( oct > 10 )) && (( octopuses[oct-10]++ ))                        || true # top
      (( oct < 91 )) && (( octopuses[oct+10]++ ))                        || true # bottom
      (( oct % 10 != 1 )) && (( octopuses[oct-1]++ ))                    || true # left
      (( oct % 10 != 0 )) && (( octopuses[oct+1]++ ))                    || true # right
      (( oct > 10 )) && (( oct % 10 != 1 )) && (( octopuses[oct-11]++ )) || true # top-left
      (( oct > 10 )) && (( oct % 10 != 0 )) && (( octopuses[oct-9]++ ))  || true # top-right
      (( oct < 91 )) && (( oct % 10 != 1 )) && (( octopuses[oct+9]++ ))  || true # bottom-left
      (( oct < 91 )) && (( oct % 10 != 0 )) && (( octopuses[oct+11]++ )) || true # bottom-right

      (( octopuses[$oct] = -200 ))
      (( flashes++ ))
      (( oct=0 )) || true
      (( current_flashes++ ))
    fi
  done

  if (( current_flashes >= 100 )); then
    echo "part II: $current_flashes flashes in step $step"
    break
  fi

  (( step == 100 )) && echo "part I: $flashes" || true

  for (( oct=1; oct<=100; oct++ )); do
    if (( octopuses[$oct] < 0 )); then
      (( octopuses[$oct] = 0 )) || true
    fi
  done
done

