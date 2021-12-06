#!/usr/bin/zsh

set -uo pipefail

# call with `./growth.sh input.txt 80` (for 80 days)

zmodload zsh/mapfile
# I know the plural of fish is fish and not fishes, but I want to be able to write `for fish in $fishes`
local -a fishes
fishes=("${(s:,:)mapfile[$1]}")

# population_data[I] = number of fishes on day I+1 of their reproduction cycle
local -a population_data
population_data=()
for day in {1..9}; do population_data+=(0); done
for fish in $fishes; do
  (( population_data[$fish + 1]++ ))
done

for (( day=1 ; day<=$2; day++ )); do
  local -i day_0=0
  day_0=$population_data[1]
  for i in {1..8}; do (( population_data[$i] = $population_data[$i+1] )); done
  (( population_data[7]+=$day_0 ))
  population_data[9]=$day_0
  echo $population_data
done

echo $population_data
local -i sum=0
for pop in $population_data; do (( sum+=pop )) ; done
echo "in sum $sum"



# Takes too long even for part 1.
# for (( day=1 ; day<=80; day++ )); do
#   local -i f
#   local -i add=0
#   for (( fish_id=1; fish_id<=$#fishes; fish_id++ )); do
#     if (( $fishes[$fish_id] > 0 )); then
#       (( fishes[$fish_id] -= 1 ))
#     else
#       fishes[$fish_id]=6
#       (( add++ ))
#     fi
#   done
#   for (( i=1; i <= add; i++)); do
#     fishes+=(8)
#   done
#   # echo $fishes
# done
# echo "final population $#fishes"
