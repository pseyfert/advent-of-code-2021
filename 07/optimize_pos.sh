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
#
# Hindsight: Instead of optimizing Σ_crabs dist^2 (what the arithmetic mean does) I should minimize Σ_crabs dist^2+dist = Σ_crabs dist*(dist+1) = Σ_crabs (dist+0.5)^2 -c
# The difference: whereas the former has its minimum at 0, the latter has its at -0.5
# So - I'm handwaving a bit - let's subtract 0.5 from the mean.
# For rounding - I didn't find a round function - I use round(x) = floor(x+0.5)
local -F best_pos=$(( floor(mean) ))

local -i fuelcost2=0
local -i this_crab_dist=0
for crab in $crabs; do
  (( this_crab_dist = abs(crab-best_pos) ))
  (( fuelcost2 += this_crab_dist * ( this_crab_dist + 1) / 2 ))
done
echo "Part II: Fuelcost is $(( fuelcost2 ))"
