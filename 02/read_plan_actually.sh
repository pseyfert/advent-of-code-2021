#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
local -a read_cmds
read_cmds=("${(f)mapfile[$1]}")

local -i hor
local -i ver
local -i aim
hor=0
ver=0
aim=0
for c in $read_cmds; do
  local -a split_c
  split_c=(${(s: :)c})
  local -i tmp
  tmp=$split_c[2]
  case $split_c[1] in
    ((forward))
      (( hor += tmp )) || true
      (( ver += aim*tmp )) || true
      ;;
    ((up))
      (( aim -= tmp )) || true
      ;;
    ((down))
      (( aim += tmp )) || true
      ;;
  esac
done
# print "horizontal = $hor"
# print "vertical = $ver"
print $(( hor*ver ))
