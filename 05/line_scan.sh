#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
zmodload zsh/mathfunc
local -a pipes
pipes=("${(f)mapfile[$1]}")

local -a crossings

local -a line1
local -a line2
local -a line_buffer

compute_line() {
  # x1 y1 x2 y2
  line_buffer=()
  if [[ $1 == $3 ]]; then
    for y in {$2..$4}; do
      line_buffer+=("$1,$y")
    done
    return 0
  fi
  if [[ $2 == $4 ]]; then
    for x in {$1..$3}; do
      line_buffer+=("$x,$2")
    done
    return 0
  fi
  local -a xs
  local -a ys
  xs=({$1..$3})
  ys=({$2..$4})
  if [[ $#xs == $#ys ]]; then
    for (( i = 1; i <=$#xs ; i++ )); do
      line_buffer+=("$xs[$i],$ys[$i]")
    done
    return 0
  fi
  return 1
}

set +e
# off by one???
for (( pipe_id=1; pipe_id<$#pipes; pipe_id++ )); do
  this_pipe=$pipes[$pipe_id]
  this_point1=(${(s:,:)"${this_pipe%% *}"})
  this_point2=(${(s:,:)"${this_pipe##* }"})

  compute_line $this_point1[1] $this_point1[2] $this_point2[1] $this_point2[2] || continue
  line1=($line_buffer)


  echo $pipe_id
  for other_pipe in $pipes[$(($pipe_id+1)),-1]; do
    other_point1=(${(s:,:)"${other_pipe%% *}"})
    other_point2=(${(s:,:)"${other_pipe##* }"})

    compute_line $other_point1[1] $other_point1[2] $other_point2[1] $other_point2[2] || continue
    line2=($line_buffer)

    crossings_here=(${line1:*line2})

    new_crossings=(${crossings_here:|crossings})
    crossings+=($new_crossings)
    
  done
done
echo "$#crossings vertices"

# Still a bit slow. Maybe it would be better to just convert every line of the input into a point format "6,4 5,3 4,2 3,1 2,0" (and some lines empty) instead of regenerating them. I.e. that would call compute_line N times instead of N*(N-1)/2 times.
