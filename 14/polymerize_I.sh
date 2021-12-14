#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
local -a input
input=("${(f)mapfile[$1]}")

local polymer=$input[1]

local -A lookup
for process in $input[2,-1]; do
  lookup[$process[1,2]]=$process[7]
done

# for a b in "${(@kv)lookup}"; do
#   echo "$a → $b"
# done

echo $polymer

for (( step = 1; step <= 10; step++)) ; do
  local tmp=$polymer[1]
  for (( cursor=1; cursor<$#polymer ; cursor++)); do
    tmp+=$lookup[$polymer[$cursor,$((cursor+1))]]
    tmp+=$polymer[$((cursor+1))]
  done
  polymer=$tmp
  # echo $polymer
done

local -A counters
for (( cursor=1; cursor<=$#polymer ; cursor++)); do
  local this=$polymer[$cursor]
  if [[ -n ${counters[(I)$this]} ]]; then
    (( counters[$this]++ )) || true
  else
    (( counters[$this]=1 )) || true
  fi
done

for a b in "${(@kv)counters}"; do
  echo "$a → $b"
done

local -a sorted
sorted=(${(On)counters})
echo "part I: $(( sorted[1] - sorted[$#sorted] ))"
