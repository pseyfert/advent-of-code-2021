#!/usr/bin/zsh

set -uo pipefail

zmodload zsh/mapfile

local -i i=0

explosion() {
  local -a stack
  stack=()

  # where the previous number ends
  local -i prev_num=-2

  for (( i = 1; i <= $#current; ++i )); do
    if [[ $current[$i] == ']' ]]; then
      stack=($stack[1,-2])
      continue
    elif [[ $current[$i] == '[' ]]; then
      stack+=('[')
      if [[ $#stack -ge 5 ]]; then
        local -a tmp
        # i+0 = opening bracket
        # i+1 = number 1
        # i+2 = comma
        # i+3 = number 2
        # i+4 = closing bracket
        #
        # tmp[.. i-1] = current[.. i-1]
        # tmp[i] = 0
        # tmp[i+1] = current[i+5 ..]
        tmp=($current[1,$((i - 1))] 0 $current[$((i + 5)),-1])
        # echo "$current explodes at $i to (except arithmetics) $tmp"
        (( prev_num >= 1 )) && (( tmp[$prev_num] = current[$prev_num] + current[$i+1] ))
        # echo "tmp after left add $tmp"
        for (( j = i+4 ; j <=$#current ; ++j )); do
          [[ $current[$j] == '[' ]] && continue
          [[ $current[$j] == ']' ]] && continue
          [[ $current[$j] == ',' ]] && continue
          (( tmp[$((j-4))] != current[$j] )) && echo "you fucked up"
          (( tmp[$((j-4))] = current[$j] + current[$((i+3))] ))
          break
        done
        current=($tmp)
        return 0
      fi
      continue
    elif [[ $current[$i] == ',' ]]; then
      continue
    else
      prev_num=$i
    fi

  done
  # echo "no explosion"
  return 1
}

split() {
  for (( i = 1; i <= $#current; ++i )); do
    [[ $current[$i] == '[' ]] && continue
    [[ $current[$i] == ']' ]] && continue
    [[ $current[$i] == ',' ]] && continue
    if (( current[$i] > 9 )); then
      local -a tmp
      local -i splittable=$current[$i]
      tmp=($current[1,$((i-1))])
      tmp+=('[')
      tmp+=($((splittable/2)) )
      tmp+=(',')
      tmp+=($((splittable-splittable/2)) )
      tmp+=(']')
      tmp+=($current[$i+1,-1])
      current=($tmp)
      # echo "did a split"
      return 0
    fi
  done
  # echo "no split"
  return 1
}


reduce() {
  while true; do
  # for (( jjj = 1; jjj < 8; ++jjj)); do
    explosion && continue
    split && continue
    return 0
  done
}

score() {
  while [[ $#current -gt 1 ]]; do
    for (( i = 1; i < $#current; ++i )); do
      if [[ $current[$i] == '[' && $current[$((i+2))] == ',' && $current[$((i+4))] == ']' ]] ; then
        local -i ev=$(( $current[$((i+1))] * 3 + $current[$((i+3))] * 2 ))
        local -a buf
        buf=($current[1,$((i-1))] $ev $current[$((i+5)),-1])
        current=($buf)
        break
      fi
    done
  done
  return $current
}

local -a bare_input
bare_input=("${(f)mapfile[$1]}")
local -a current
current=()
local -i best_so_far=0

for (( lhs = 1; lhs <$#bare_input; ++lhs )); do
  for (( rhs = 1; rhs <$#bare_input; ++rhs )); do
    (( lhs==rhs )) && continue
    local -a rhs_buf
    local -a lhs_buf
    rhs_buf=()
    lhs_buf=()
    for (( i = 1; i <= $#bare_input[$lhs] ; ++i )); do
      lhs_buf+=(${${bare_input[$lhs]}[$i]})
    done
    for (( i = 1; i <= $#bare_input[$rhs] ; ++i )); do
      rhs_buf+=(${${bare_input[$rhs]}[$i]})
    done

    sum=('[' $lhs_buf ',' $rhs_buf ']')
    current=($sum)
    reduce
    score
    local -i rv=$?
    (( rv > best_so_far )) && (( best_so_far=rv ))
  done
done

echo "part II: $best_so_far"
