#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
local data
local -a paper
data=$mapfile[$1]
paper=(${(f)"${data%%fold*}"})
local -a folds
local -a x
local -a y
folds=(${${(f)"${data#*fold along }"}##"fold along "})
x=(${paper%,*})
y=(${paper#*,})

count() {
  local -a dots
  dots=()
  for ((i=1; i <=$#x; i++)); do
    local dot=$x[$i],$y[$i]
    [[ ${(M)#dots:#$dot} == 0 ]] && dots+=($dot) || true
  done
  echo "there are $#dots dots" #: $dots"
}

pr() {
  local -a printout
  for ((row=0; row<=6; row++)); do
    local lineprint=""
    for ((col=0; col<=40; col++)); do
      lineprint+="."
    done
    for ((i=1; i <=$#x; i++)); do
      (( y[i] != row )) && continue || true
      lineprint[$((x[i]+1))]="#"
    done
    printout+=($lineprint)
  done
  for p in $printout; do echo $p; done
}

for fold in $folds; do
  local -i mark=$fold[3,-1]
  local axis=$fold[1]
  if [[ $axis == "x" ]]; then
    for ((i = 1; i<=$#x; i++)); do
      (( x[i] > mark )) && (( x[i] = mark - ( x[i] - mark ) )) || true
    done
  fi
  if [[ $axis == "y" ]]; then
    for ((i = 1; i<=$#y; i++)); do
      oldy=$y[$i]
      (( y[i] > mark )) && (( y[i] = mark - ( y[i] - mark ) )) || true
      # echo "$oldy→$y[$i]"
    done
  fi
  count
done

pr
