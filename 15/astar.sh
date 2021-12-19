#!/usr/bin/zsh

set -uo pipefail

zmodload zsh/mapfile

local -a maze
maze=("${(f)mapfile[$1]}")

local -A scores
local -a fringe
local -a passed
fringe=("1,1")
passed=("1,1")
local -A cost
cost[1,1]=0

local dest=(100,100)

heuristic() {
  # $1 = x
  # $2 = y
  local -i x_=$1
  local -i y_=$2
  return $(( 200 - x - y ))
}

while true; do
  # I am really not happy with my map sorting, reverse lookup handling here...
  local -a costs
  costs=()
  local -a fringe_points
  fringe_points=()
  echo "fringe contains $fringe"
  # for k v in ${(@kv)cost}; do echo "$k→$v"; done
  for p in $fringe; do
    # echo "fringe point $p"
    fringe_points+=($p)
    costs+=($cost[$p])
  done
  # echo "costs for fringe: $costs"
  local -a sorted
  sorted=(${(on)costs})
  # echo "costs for fringe sorted: $sorted"
  local -i current_best_s=$sorted[1]
  local current_best_p=""
  local -a current_bests_p
  current_bests_p=()
  for p in $fringe; do
    # echo "comparing $cost[$p] and $current_best_s"
    if [[ $cost[$p] == $current_best_s ]]; then
      current_bests_p+=($p)
    fi
  done
  if (( $#current_bests_p == 1 )); then
    current_best_p=$current_bests_p[1]
  elif (( $#current_bests_p > 1 )); then
    local -a heuristics
    heuristics=()
    # echo "contenders entering heuristics: $current_bests_p"
    for p in $current_bests_p; do
      local -i x=${p%,*}
      local -i y=${p#*,}
      heuristic $x $y
      heuristics+=($?)
    done
    sorted=(${(on)heuristics})
    # echo "sorted is $sorted"
    current_best_p=$current_bests_p[${heuristics[(i)$sorted[1]]}]
    # echo "picking $current_best_p"
  else
    # echo "you fucked up"
    # echo "interesting fringe: $fringe_points"
    # echo "their costs: $costs"
    # echo "that sorted: $sorted"
    # echo "best contenders: $current_bests_p"
    # echo "best score: $current_best_s"
    break
  fi

  local -i x=${current_best_p%,*}
  local -i y=${current_best_p#*,}

  # can go left
  if (( x > 1 )); then
    local candidate=""
    candidate=$((x-1)),$y
    if [[ ${(M)#passed:#$candidate} == 0 ]]; then
      fringe+=($candidate)
      passed+=($candidate)
      local -i x_=$(( x - 1 ))
      cost[$candidate]=$(( current_best_s + ${maze[$y][$x_]} ))
    fi
  fi

  # can go right
  if (( x < 100 )); then
    local candidate=""
    candidate=$((x+1)),$y
    if [[ ${(M)#passed:#$candidate} == 0 ]]; then
      fringe+=($candidate)
      passed+=($candidate)
      local -i x_=$(( x + 1 ))
      cost[$candidate]=$(( current_best_s + ${maze[$y][$x_]} ))
    fi
  fi

  # can go up
  if (( y > 1 )); then
    local candidate=""
    candidate=$x,$((y-1))
    if [[ ${(M)#passed:#$candidate} == 0 ]]; then
      fringe+=($candidate)
      passed+=($candidate)
      local -i y_=$(( y - 1 ))
      cost[$candidate]=$(( current_best_s + ${maze[$y_][$x]} ))
    fi
  fi

  # can go down
  if (( y < 100 )); then
    local candidate=""
    candidate=$x,$((y+1))
    if [[ ${(M)#passed:#$candidate} == 0 ]]; then
      fringe+=($candidate)
      passed+=($candidate)
      local -i y_=$(( y + 1 ))
      cost[$candidate]=$(( current_best_s + ${maze[$y_][$x]} ))
    fi
  fi

  local -a tmp
  tmp=($current_best_p)
  # echo "passed: $passed"
  # echo "will remove $current_best_p → $tmp"
  fringe=(${fringe:|tmp})
  passed+=($current_best_p)
  # echo "new fringe: $fringe"
  if [[ ${(M)#fringe:#$dest} -gt 0 ]]; then
    break
  fi
done

echo "part I: $cost[100,100]"
