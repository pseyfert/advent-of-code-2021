#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
local -a read_diagnostics
read_diagnostics=("${(f)mapfile[$1]}")

single_bit_eval() {
  local -a one_bits
  local -i bit_pos
  one_bits=()

  # Initialize, works without but feels wrong.
  for bit_pos in $(seq $#1); do
    one_bits+=(0)
  done

  for line in $@; do
    for (( bit_pos=1 ; bit_pos <= $#line ; bit_pos++ )); do
      [[ $line[$bit_pos] == '1' ]] && (( one_bits[$bit_pos] += 1 )) || true
    done
  done

  local gamma_str
  gamma_str="0b"
  for count in $one_bits; do
    gamma_str+=$(( $count >= $# / 2. ))
  done
  local -i 10 gamma
  gamma=$gamma_str
  return $gamma
}

local -a kept_oxygen
local -a kept_co2
kept_oxygen=($read_diagnostics)
kept_co2=($read_diagnostics)

local -i 10 final_oxy
local -i 10 final_co2

local -i bit_pos

set +e
for bit_pos in $(seq $#read_diagnostics[1]); do
  local -i digits
  digits=$#read_diagnostics[1]
  local -i oxy_pattern
  local oxy_pattern_str=""
  single_bit_eval $kept_oxygen
  oxy_pattern=$?
  # Okay, this is truely horrible printing the number binary represented as string.
  # There's probably a better way
  # printf "%0.d" ....
  # is for zero padding (leading digits)
  # ${digits}      number of digits
  # $(([#2]...))   print in base 2 (will be 2#010101)
  # ${...#2#}      strip of leading 2#
  # In hindsight it might be better to do binary math instead of converting
  # to string and then work with the 0/1 characters in the string.
  oxy_pattern_str=$(printf "%0${digits}d" ${$(([#2]oxy_pattern))#2#})

  local -a tmp
  tmp=()
  for line in $kept_oxygen; do
    if [[ $oxy_pattern_str[$bit_pos] == $line[$bit_pos] ]]; then
      tmp+=($line)
    fi
  done
  kept_oxygen=($tmp)

  [[ $#kept_co2 == 1 ]] && continue
  local -i co2_pattern
  local co2_pattern_str=""
  single_bit_eval $kept_co2
  co2_pattern=$?
  co2_pattern_str=$(printf "%0${digits}d" ${$(([#2]co2_pattern))#2#})

  tmp=()
  for line in $kept_co2; do
    if [[ $co2_pattern_str[$bit_pos] != $line[$bit_pos] ]]; then
      tmp+=($line)
    fi
  done
  kept_co2=($tmp)

  # no need to eary abort
  # if [[ $#tmp == 1 ]]; then final_oxy_pattern=$tmp[1]
  if [[ $#tmp == 1 ]]; then final_co2=0b$tmp[1]; fi
done
set -e

final_oxy=0b$kept_oxygen[1]
echo "answer $(( final_oxy * final_co2 ))"
