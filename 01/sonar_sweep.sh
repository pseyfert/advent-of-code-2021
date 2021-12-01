#!/usr/bin/zsh

zmodload zsh/mapfile
local -a measurements
measurements=("${(f)mapfile[$1]}")

local -i prev
local -i increased
prev=$measurements[1]
increased=0
for m in $measurements[2,-1]; do
  [[ $m -gt $prev ]] && (( increased++ ))
  prev=$m
done
print $increased
