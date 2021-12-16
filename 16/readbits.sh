#!/usr/bin/zsh

set -uo pipefail

zmodload zsh/mapfile

local hexin
hexin=${mapfile[$1]}

local binin=""

for (( hi=1 ; hi <= $#hexin ; hi++ )); do
  local -i 2 buf=0x$hexin[$hi]
  # don't see how to quickly to padding bits in binary otherwise
  (( buf += 16 ))
  binin+=${buf#2#1}
done

echo $binin
local -i 10 versionsum=0

advance_literal() {
  # $1 → read position start of literal
  # return → next read position
  local -i scan=$(( $1 + 6 ))
  while (( $binin[$scan] == 1 )); do
    # ignore current 4-bit $binin[$((scan+1)),$((scan+5))]
    (( scan += 5 ))
  done
  # ignore last 4 bit $binin[$((scan+1)),$((scan+5))]
  return $(( scan + 5 ))
}

read_version_literal() {
  # $1 → read position
  # return → next read position
  # side effect: increments versionsum
  local -i 10 version=0b${binin[$1,$(( $1 + 2))]}
  (( versionsum += version ))
  advance_literal $1
  return $?
}

read_packet() {
  echo "reading at $1"
  # $1 → read position
  # return → next read position
  # side effect: increments versionsum
  local -i 10 version=0b${binin[$1,$(( $1 + 2))]}
  (( versionsum += version ))
  local -i 10 typeid=0b${binin[$(( $1+3 )),$(( $1 + 5 ))]}
  # echo "typeid is $typeid (from 0b${binin[$(( $1+3 )),$(( $1 + 6 ))]} )"
  if (( typeid == 4 )); then
    # echo "reading literal"
    advance_literal $1
    return $?
  else
    echo "operator format bit is ${binin[$(( $1 + 6 ))]}"
    if [[ ${binin[$(( $1 + 6 ))]} == 0 ]]; then
      # 15 bit length in bits of the rest
      echo "reading length 0b${binin[$(( $1 + 7 )),$(( $1 + 21 ))]}"
      local -i 10 length=0b${binin[$(( $1 + 7 )),$(( $1 + 21 ))]}
      local -i 10 next=$(( $1 + 22 ))
      for (( ; next != $1 + 22 + length ; )); do
        read_packet $next
        next=$?
      done
      return $next
    else
      # 11 bit count of subpackages
      echo "reading size 0b${binin[$(( $1 + 7 )),$(( $1 + 17 ))]}"
      local -i 10 subs=0b${binin[$(( $1 + 7 )),$(( $1 + 17 ))]}
      local -i 10 next=$(( $1 + 18 ))
      for (( ; subs > 0; subs-- )); do
        read_packet $next
        next=$?
      done
      return $next
    fi
  fi
}

read_packet 1

echo $versionsum
