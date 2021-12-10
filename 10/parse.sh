#!/usr/bin/zsh

set -eo pipefail

zmodload zsh/mapfile
local -a lines
lines=("${(f)mapfile[$1]}")

local -i score_i=0
local -a scores_ii
scores_ii=()
local -A matches
local l=\<
local g=\>
matches[\[]=\]
matches[$l]=\>
matches[\(]=\)
matches[\{]=\}
local -A table
table[\]]=57
table[$g]=25137
table[\)]=3
table[\}]=1197
local -A table_2
table_2[\]]=2
table_2[$g]=4
table_2[\)]=1
table_2[\}]=3

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
