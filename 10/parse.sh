#!/usr/bin/zsh

set -eo pipefail

zmodload zsh/mapfile
local -a lines
lines=("${(f)mapfile[$1]}")

local -a calib
calib=("${(f)mapfile[calib.txt]}")

local -i score_i=0
local -a scores_ii
scores_ii=()
local -A matches
matches[${${calib[1]}[1]}]=${${calib[2]}[1]}
matches[${${calib[1]}[2]}]=${${calib[2]}[2]}
matches[${${calib[1]}[3]}]=${${calib[2]}[3]}
matches[${${calib[1]}[4]}]=${${calib[2]}[4]}
local -A table
table[${${calib[2]}[1]}]=57
table[${${calib[2]}[2]}]=25137
table[${${calib[2]}[3]}]=3
table[${${calib[2]}[4]}]=1197
local -A table_2
table_2[${${calib[2]}[1]}]=2
table_2[${${calib[2]}[2]}]=4
table_2[${${calib[2]}[3]}]=1
table_2[${${calib[2]}[4]}]=3

for line in $lines; do
  local -a expectstack
  expectstack=()
  local do_completion=true
  for (( token_id = 1 ; token_id <= $#line ; ++token_id )); do
    token=$line[$token_id]
    # pop
    if [[ $token == $expectstack[-1] ]]; then
      expectstack=($expectstack[1,-2])
      continue
    fi

    # is a closer
    if [[ ${(M)#matches:#$token} == 1 ]] ; then
      # echo "corrupt line $line"
      # echo "scoring $token"
      (( score_i += $table[$token] ))
      do_completion=false
      break
    fi

    # key found
    # There's something severely wrong here, during
    # debugging found a case where ')' triggered this branch and
    # nothing got pushed. "Fixed" it by swapping with the prev block.
    if [[ ${#matches[(I)$token]} == 1 ]] ; then
      expectstack+=$matches[$token]
      continue
    fi
    echo "unreachable path in line $line at $token ($token_id) with $expectstack"
  done
  if $do_completion; then
    local -a inverted
    # echo "processing ${(o)expectstack}"
    local -i score_ii=0
    for pop in ${(aO)expectstack}; do
      (( score_ii *= 5 )) || true
      (( score_ii += $table_2[$pop] ))
    done
    scores_ii+=($score_ii)
  fi
done
local -a sorted
sorted=(${(n)scores_ii})

echo "part I: $score_i"
echo "part II: $sorted[$((($#sorted+1)/2))]"
