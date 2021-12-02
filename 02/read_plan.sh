#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
local -a read_cmds
read_cmds=("${(f)mapfile[$1]}")

local -i hor
local -i ver
hor=0
ver=0
for c in $read_cmds; do
  local -i tmp
  case $c in
    ((forward*))
      tmp=${c#"forward "}
      (( hor += tmp ))
      ;;
    ((up*))
      tmp=${c#"up "}
      (( ver -= tmp ))
      ;;
    ((down*))
      tmp=${c#"down "}
      (( ver += tmp ))
      ;;
  esac
done
# print "horizontal = $hor"
# print "vertical = $ver"
print $(( hor*ver ))
