#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
local -a pipes
pipes=("${(f)mapfile[$1]}")

# local -i multi_line_points
#
# # horrible in complexity, too slow
# for (( x=0; x<1000; x++ )); do
#   echo "progress: $x/1000"
#   for (( y=0; y<1000; y++ )); do
#     local -i this_point=0
#     for pipe in $pipes; do
#       point1=(${(s:,:)"${pipe%% *}"})
#       point2=(${(s:,:)"${pipe##* }"})
#       if [[ $point1[1] == $point2[1] && $point1[1] == $x ]]; then
#         if [[ $point1[2] -le $y && $y -le $point2[2] ]]; then
#           this_point+=1
#         else
#           [[ $point1[2] -ge $y && $y -ge $point2[2] ]] && this_point+=1
#         fi
#         continue
#       fi
#
#       if [[ $point1[2] == $point2[2] && $point1[2] == $y ]]; then
#         if [[ $point1[1] -le $x && $x -le $point2[1] ]]; then
#           this_point+=1
#         else
#           [[ $point1[1] -ge $x && $x -ge $point2[1] ]] && this_point+=1
#         fi
#         continue
#       fi
#     done
#     [[ $this_point > 1 ]] && multi_line_points+=1
#   done
# done
# echo "$multi_line_points"

local -a crossings

# off by one???
for (( pipe_id=1; pipe_id<$#pipes; pipe_id++ )); do
  this_pipe=$pipes[$pipe_id]
  this_point1=(${(s:,:)"${this_pipe%% *}"})
  this_point2=(${(s:,:)"${this_pipe##* }"})
  [[ $#this_point1 -lt 2 ]] && echo "issue with $this_point1 from $this_pipe in $pipe_id (out of $#pipes)"
  [[ ( $this_point1[1] != $this_point2[1] ) && ( $this_point1[2] != $this_point2[2] ) ]] && continue
  for other_pipe in $pipes[$(($pipe_id+1)),-1]; do
    other_point1=(${(s:,:)"${other_pipe%% *}"})
    other_point2=(${(s:,:)"${other_pipe##* }"})
    [[ ( $other_point1[1] != $other_point2[1] ) && ( $other_point1[2] != $other_point2[2] ) ]] && continue

    # both pipes along x, and same x
    if [[ ( $this_point1[1] == $this_point2[1] ) && ( $other_point1[1] == $other_point2[1] ) && ( $this_point1[1] == $other_point1[1] ) ]]; then
      # this is at lower y than other
      [[ ( $this_point1[2] -lt $other_point1[2] ) && ( $this_point2[2] -lt $other_point1[2] ) && ( $this_point1[2] -lt $other_point2[2] ) && ( $this_point2[2] -lt $other_point2[2] ) ]] && continue
      # this is at higher y than other
      [[ ( $this_point1[2] -gt $other_point1[2] ) && ( $this_point2[2] -gt $other_point1[2] ) && ( $this_point1[2] -gt $other_point2[2] ) && ( $this_point2[2] -gt $other_point2[2] ) ]] && continue
      # not thrilled with the implementation, instead of sorting out how pipes are arranged, just scanning the row
      echo "same X lines $this_pipe, $other_pipe"
      for (( y=0; y<1000; ++y )); do
        if [[ ( ( $this_point1[2] -le $y && $this_point2[2] -ge $y ) ||
                ( $this_point1[2] -ge $y && $this_point2[2] -le $y ) ) &&
              ( ( $other_point1[2] -le $y && $other_point2[2] -ge $y ) ||
                ( $other_point1[2] -ge $y && $other_point2[2] -le $y ) ) ]]; then
          local crossing="$this_point1[1],$y"
          # [[ $this_point1[2] -le $y && $this_point2[2] -ge $y ]] && echo "cond 1"
          # [[ $this_point1[2] -ge $y && $this_point2[2] -le $y ]] && echo "cond 2"
          # [[ $other_point1[2] -le $y && $other_point2[2] -ge $y ]] && echo "cond 3"
          # [[ $other_point1[2] -ge $y && $other_point2[2] -le $y ]] && echo "cond 4"
          # echo "adding $crossing"
          [[ ${(M)#crossings:#$crossing} == 0 ]] && crossings+=($crossing)
        fi
      done
    fi

    # both pipes along y, and same y
    if [[ ( $this_point1[2] == $this_point2[2] ) && ( $other_point1[2] == $other_point2[2] ) && ( $this_point1[2] == $other_point1[2] ) ]]; then
      # this is at lower x than other
      [[ ( $this_point1[1] -lt $other_point1[1] ) && ( $this_point2[1] -lt $other_point1[1] ) && ( $this_point1[1] -lt $other_point2[1] ) && ( $this_point2[1] -lt $other_point2[1] ) ]] && continue
      # this is at higher x than other
      [[ ( $this_point1[1] -gt $other_point1[1] ) && ( $this_point2[1] -gt $other_point1[1] ) && ( $this_point1[1] -gt $other_point2[1] ) && ( $this_point2[1] -gt $other_point2[1] ) ]] && continue
      # not thrilled with the implementation, instead of sorting out how pipes are arranged, just scanning the row
      for (( x=0; x<1000; ++x )); do
        if [[ ( ( $this_point1[1] -le $x && $this_point2[1] -ge $x ) ||
                ( $this_point1[1] -ge $x && $this_point2[1] -le $x ) ) &&
              ( ( $other_point1[1] -le $x && $other_point2[1] -ge $x ) ||
                ( $other_point1[1] -ge $x && $other_point2[1] -le $x ) ) ]]; then
          local crossing="$x,$this_point1[2]"
          [[ ${(M)#crossings:#$crossing} == 0 ]] && crossings+=($crossing)
        fi
      done
    fi

    # crossing lines (this equi-x, other equi-y)
    if [[ ( $this_point1[1] == $this_point2[1] ) && ( $other_point1[2] == $other_point2[2] ) ]]; then
      if [[ ( ( $other_point1[1] -le $this_point1[1] ) &&
              ( $other_point2[1] -ge $this_point1[1] ) ) ||
            ( ( $other_point1[1] -ge $this_point1[1] ) &&
              ( $other_point2[1] -le $this_point1[1] ) ) ]]; then
        if [[ ( ( $this_point1[2] -le $other_point1[2] ) &&
                ( $this_point2[2] -ge $other_point1[2] ) ) ||
              ( ( $this_point1[2] -ge $other_point1[2] ) &&
                ( $this_point2[2] -le $other_point1[2] ) ) ]]; then
          local crossing="$this_point1[1],$other_point1[2]"
          [[ ${(M)#crossings:#$crossing} == 0 ]] && crossings+=($crossing)
        fi
      fi
    fi
    # crossing lines (this equi-y, other equi-x)
    if [[ ( $this_point1[2] == $this_point2[2] ) && ( $other_point1[1] == $other_point2[1] ) ]]; then
      if [[ ( ( $other_point1[2] -le $this_point1[2] ) &&
              ( $other_point2[2] -ge $this_point1[2] ) ) ||
            ( ( $other_point1[2] -ge $this_point1[2] ) &&
              ( $other_point2[2] -le $this_point1[2] ) ) ]]; then
        if [[ ( ( $this_point1[1] -le $other_point1[1] ) &&
                ( $this_point2[1] -ge $other_point1[1] ) ) ||
              ( ( $this_point1[1] -ge $other_point1[1] ) &&
                ( $this_point2[1] -le $other_point1[1] ) ) ]]; then
          local crossing="$other_point1[1],$this_point1[2]"
          [[ ${(M)#crossings:#$crossing} == 0 ]] && crossings+=($crossing)
        fi
      fi
    fi

  done
done
echo "$#crossings vertices"


# Admittedly, this is too much spaghetti code. should maybe just generate a list of all points of a pipe for each pipe and then compare their overlaps.
