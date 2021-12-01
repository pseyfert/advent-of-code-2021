#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
local -a measurements
measurements=("${(f)mapfile[$1]}")

# For the sliding window most of the values in the window don't actually matter.
# In the series a,b,c,d the sums a+b+c and b+c+d only differ in a vs d.
local -i increased
increased=0
for (( b=4 ; b<$#measurements; b++ )); do
  [[ $measurements[$b] -gt $measurements[$b-3] ]] && (( increased++ )) || true
done
print $increased
