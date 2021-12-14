#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
local -a input
input=("${(f)mapfile[$1]}")

local -A polymer

# Handle the polymer as pairs of element:
# NNCB → NN:1 NC:1 CB:1
# Every step turns each pair into two new pairs
# This way we scale, regardless of the size of the polymer, we only have to deal with the 100 unique pairs and their occurance counts.
#
# For the final evaluation we know that almost every element instance is the
# second element in exactly one pair instance, except the very first element.
# The very first element is conserved over all steps.

for (( cursor=1; cursor<$#input[1] ; cursor++)); do
  local key=${${input[1]}[$cursor]}${${input[1]}[$((cursor+1))]}
  polymer[$key]=0
  if [[ -n ${polymer[(I)$key]} ]]; then
    (( polymer[$key]++ )) || true
  else
    (( polymer[$key]=1 )) || true
  fi
done

# for a b in "${(@kv)polymer}"; do
#   echo "$a → $b"
# done

local -A lookup
for process in $input[2,-1]; do
  lookup[$process[1,2]]=$process[7]
done

# for a b in "${(@kv)lookup}"; do
#   echo "$a → $b"
# done

for (( step = 1; step <= 40; step++)) ; do
  echo "step $step"
  local -A tmp
  # paranoid zero initialization
  for a b in "${(@kv)polymer}"; do
    tmp[$a]=0
  done
  for a b in "${(@kv)tmp}"; do
    tmp[$a]=0
  done

  for a b in "${(@kv)polymer}"; do
    local -i inseq=$b
    local out1=$a[1]$lookup[$a]
    local out2=$lookup[$a]$a[2]
    if [[ -n ${tmp[(I)$out1]} ]]; then
      (( tmp[$out1]+=inseq )) || true
    else
      (( tmp[$out1]=inseq )) || true
    fi
    if [[ -n ${tmp[(I)$out2]} ]]; then
      (( tmp[$out2]+=inseq )) || true
    else
      (( tmp[$out2]=inseq )) || true
    fi
  done

  for a b in "${(@kv)tmp}"; do
    polymer[$a]=$b
  done
done

local -A counters
counters[${${input[1]}[1]}]=1
for a b in "${(@kv)polymer}"; do
  local this=$a[2]
  if [[ -n ${counters[(I)$this]} ]]; then
    (( counters[$this]+=b )) || true
  else
    (( counters[$this]=b )) || true
  fi
done

local -a sorted
sorted=(${(On)counters})
echo "part II: $(( sorted[1] - sorted[$#sorted] ))"
