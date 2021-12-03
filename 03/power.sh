#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
local -a read_diagnostics
read_diagnostics=("${(f)mapfile[$1]}")

local -a one_bits

# Initialize, works without but feels wrong.
for bit_pos in $(seq $#read_diagnostics[1]); do
  one_bits+=(0)
done

for line in $read_diagnostics; do
  for (( bit_pos=1 ; bit_pos <= $#line ; bit_pos++ )); do
    [[ $line[$bit_pos] == '1' ]] && (( one_bits[$bit_pos] += 1 )) || true
  done
done

local gamma_str epsilon_str
gamma_str="0b"
epsilon_str="0b"
for count in $one_bits; do
  gamma_str+=$(( $count > $#read_diagnostics / 2 ))
  epsilon_str+=$(( ! ( $count > $#read_diagnostics / 2 ) ))
done

local -i 10 gamma epsilon
gamma=$gamma_str
epsilon=$epsilon_str

print "$gamma * $epsilon = $(( gamma * epsilon ))"
