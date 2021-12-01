#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
local -a measurements
measurements=("${(f)mapfile[$1]}")

local -i prev
local -i increased
prev=$measurements[1]
increased=0
for m in $measurements[2,-1]; do
  [[ $m -gt $prev ]] && (( increased++ )) || true
  prev=$m
done
print $increased
