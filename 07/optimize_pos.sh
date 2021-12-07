#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
zmodload zsh/mathfunc
autoload zmathfunc
zmathfunc
local -a crabs
crabs=("${(s:,:)mapfile[$1]}")

echo "there are $#crabs crabs"
local -a sorted
sorted=(${(n)crabs})
local -i median
median=$sorted[$(($#crabs/2))]
echo "Median crab position is at $median"
echo "Around it are: $sorted[$(($#crabs/2-1)),$(($#crabs/2+1))]"

local -i fuelcost1=0
local -F mean
for crab in $crabs; do
  (( fuelcost1 += abs(crab-median) ))
  (( mean += crab ))
done
(( mean = mean/$#crabs ))
echo "Part I: Fuelcost is $fuelcost1"

# Fuel consumption is the famous Σ^{N}_{i=0} i = N*(N+1)/2
# Mean minimizes squared distance.
# Didn't spend time thinking about rounding to the next integer, just brute force the two.
local -i mean_pos_lo=$(( floor(mean) ))
local -i mean_pos_hi=$(( ceil(mean) ))
echo "Mean crab position(f) is at $mean ($mean_pos_lo, $mean_pos_hi)"

local -i fuelcost2_l=0
local -i fuelcost2_h=0
local -i this_crab_dist=0
for crab in $crabs; do
  (( this_crab_dist = abs(crab-mean_pos_lo) ))
  (( fuelcost2_l += this_crab_dist * ( this_crab_dist + 1) / 2 ))
  (( this_crab_dist = abs(crab-mean_pos_hi) ))
  (( fuelcost2_h += this_crab_dist * ( this_crab_dist + 1) / 2 ))
done
echo "Part II: Fuelcost is $(( min(fuelcost2_l, fuelcost2_h) ))"
