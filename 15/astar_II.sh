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

local dest=(500,500)

local -i best_heur=1000

heuristic() {
  # $1 = x
  # $2 = y

  # NB: Heuristic hardly helps, for each col/row getting closer to the destination, we pay on average a cost of 5 (assuming completely random node costs)
  #     The heuristic adds only 1.
  #
  local -i x_=$1
  local -i y_=$2
  local -i retval=$(( 1000 - x - y ))

  if (( retval < best_heur )); then
    echo "$x_,$y_"
    best_heur=$(( retval - 5 ))
  fi

  return $retval
}

nodecost() {
  # $1 = x
  # $2 = y
  local -i x_=$1
  local -i y_=$2

  local -i x_rollover=$(( (x_-1) / 100 ))
  local -i y_rollover=$(( (y_-1) / 100 ))
  local -i x__=$(( 1 + ((x_-1) % 100) ))
  local -i y__=$(( 1 + ((y_-1) % 100) ))

  echo -n "$x_,$y_ → $x__,$y__ → "
  local -i retval=$(( 1 + ( ( x_rollover + y_rollover + ${maze[$y__][$x__]} - 1 ) % 9 ) ))
  echo "${maze[$y__][$x__]} → $retval"

  return $retval
}


# TODO:
#
# the search will form "bubbles" in the map, that do not need to be explored further:
#
# 1111199999
# 1999199999
# 1999199999
# 1999199999
# 1999199999
# 1111X99999
# 9999919999
# 9999991999
# 9999999119
#
# At some point, X will be on the fringe, and all the points in the upper left rectangle can be ignored.
# Algorithmically istm, like the fringe will always contain a line from (1,?) to (?,1). This can be found following the "keep following your right-hand wall" maze solving algorithm.
# Any fringe point not on that line explores bubbles and shall be ignored.
# Bubbles from, e.g. when an up movement reaches a point that is below/left/right of a fringe point.


local -i prev_it=3000
while true; do
  # I am really not happy with my map sorting, reverse lookup handling here...
  # For runtime, avoid sorting the fringe (N log(N), assuming $fringe doesn't get sorted through inserting/removing elements).
  local -a local_costs
  local_costs=()
  local -a fringe_points
  fringe_points=()
  # for k v in ${(@kv)cost}; do echo "$k→$v"; done
  local -i current_best_s=2000
  local -i current_best_c=2000
  local current_best_p=""
  for p in $fringe; do
    # echo "fringe point $p"
    fringe_points+=($p)
    local -i x=${p%,*}
    local -i y=${p#*,}
    heuristic $x $y
    local -i heur=$?
    local -i costhere=$(( $heur + $cost[$p] ))
    (( costhere < current_best_c )) && current_best_p=$p
    (( costhere < current_best_c )) && current_best_s=$cost[$p]
    (( costhere < current_best_c )) && current_best_c=$costhere
    # since cost+heuristic is monotonic rising throughout the search, we can abort immediately if we
    # encounter a cost that we've already seen.
    (( costhere <= prev_it )) && break
  done
  prev_it=$current_best_c

  # echo "$current_best_p ($current_best_s)"

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
      local -i y_=$(( y ))
      nodecost $x_ $y_
      local -i add=$?
      cost[$candidate]=$(( current_best_s + add ))
    fi
  fi

  # can go right
  if (( x < 500 )); then
    local candidate=""
    candidate=$((x+1)),$y
    if [[ ${(M)#passed:#$candidate} == 0 ]]; then
      fringe+=($candidate)
      passed+=($candidate)
      local -i x_=$(( x + 1 ))
      local -i y_=$(( y ))
      nodecost $x_ $y_
      local -i add=$?
      cost[$candidate]=$(( current_best_s + add ))
    fi
  fi

  # can go up
  if (( y > 1 )); then
    local candidate=""
    candidate=$x,$((y-1))
    if [[ ${(M)#passed:#$candidate} == 0 ]]; then
      fringe+=($candidate)
      passed+=($candidate)
      local -i x_=$(( x ))
      local -i y_=$(( y - 1 ))
      nodecost $x_ $y_
      local -i add=$?
      cost[$candidate]=$(( current_best_s + add))
    fi
  fi

  # can go down
  if (( y < 500 )); then
    local candidate=""
    candidate=$x,$((y+1))
    if [[ ${(M)#passed:#$candidate} == 0 ]]; then
      fringe+=($candidate)
      passed+=($candidate)
      local -i x_=$(( x ))
      local -i y_=$(( y + 1 ))
      nodecost $x_ $y_
      local -i add=$?
      cost[$candidate]=$(( current_best_s + add ))
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

echo "part I: $cost[500,500]"
