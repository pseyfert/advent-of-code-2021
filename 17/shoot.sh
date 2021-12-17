#!/usr/bin/zsh

set -uo pipefail

zmodload zsh/mapfile

local target
target=${mapfile[$1]}

local xarea=${${target#*: }%, *}
local yarea=${target#*, }
local -i xlo=${${xarea#x=}%..*}
local -i xhi=${xarea#*..}
local -i ylo=${${yarea#x=}%..*}
local -i yhi=${yarea#*..}

echo "$xlo .. $xhi"
echo "$ylo .. $yhi"

local -i best_y_top=0
local -i best_vx=0
local -i best_vy=0
local -a allowed_vels

# Highest possible xvel value is the ending edge of the target area (reaching it in one step).
for (( xvel=xhi; xvel > 0; xvel-- )); do
  local -i xt=0
  local -i s_min=-1
  local -i s_max=-1
  local -i s=0
  local -i xvt=$xvel
  for (( s = 1; ; s++ )); do
    (( xt+=xvt ))
    (( xvt-- ))
    (( xt >= xlo && s_min == -1 )) && (( s_min = s ))
    (( xt <= xhi )) && (( s_max = s ))
    (( xt > xhi )) && break
    (( xvt == 0 )) && (( s_max=-1 ))
    (( xvt == 0 )) && break
  done

  # Doesn't reach the target area
  (( s_min == -1 )) && break

  echo "possible xvel=$xvel between steps $s_min and $s_max"

  # y(s) = Σ_i=1^s (yvel - i + 1)
  #      = yvel*(yvel+1)//2 - (yvel-s)*(yvel-s+1)//2
  #      # NB top is at yvel*(yvel+1)/2
  #      #    IF yvel > 0
  #      = 1/2 [ yvel^2 + yvel - yvel^2 + yvel*s - yvel + yvel*s - s^2 + s ]
  #      = 1/2 [ (1+2*yvel)*s - s^2 ]
  # y/s + s/2 -1/2 = yvel
  # (2*y + s^2 - s)/2s = yvel

  # falling down, there will always be a point s_0 where y=0 again.
  # s_0 is odd.
  # y(s_0+1) = - (s_0+1)/2  ;   s_0 = 2 * v_y(0) + 1
  # we cannot reach the target area anymore once y(s_0+1)<ylo
  # and y(s_0+1) = - (v_y(0)+1)
  # i.e. ylo > - v_y(0) - 1
  #      ylo + 1 > - v_y(0)
  #      y_v(0) > -(ylo+1)
  if (( s_max == -1 )); then
    for (( target_s = s_min; ; target_s++)); do
      local -i test_vy=$(( (2*ylo + target_s*target_s - target_s) / (2*target_s)))
      (( test_vy > -(ylo+1) )) && break
      for (( ; test_vy <= -(ylo+1); test_vy++)) ; do
        local -i yats=$(( ((1+2*test_vy) * target_s - target_s*target_s)/2 ))
        (( yats < ylo )) && continue
        (( yats > yhi )) && break
        local -i yattop=$(( test_vy*(test_vy+1)/2 ))
        # echo "should test $xvel,$test_vy \t would reach $yattop"
        local velvec=$xvel,$test_vy
        [[ ${(M)#allowed_vels:#$velvec} == 0 ]] && allowed_vels+=($velvec)
        (( yattop > best_y_top )) && ((best_y_top=yattop))
        (( yattop >= best_y_top )) && (( best_vx=xvel ))
        (( yattop >= best_y_top )) && (( best_vy=test_vy ))
      done
    done
    continue
  fi

  local -i target_s=0
  for (( target_s = s_min; target_s <= s_max; target_s++)); do
    # scan from velocities that barely reach the lower edge upwards
    local -i test_vy=$(( (2*ylo + target_s*target_s - target_s) / (2*target_s)))
    for (( ; ; test_vy++)) ; do
      local -i yats=$(( ((1+2*test_vy) * target_s - target_s*target_s)/2 ))
      (( yats < ylo )) && continue
      (( yats > yhi )) && break
      local -i yattop=$(( test_vy*(test_vy+1)/2 ))
      (( test_vy <= 0 )) && (( yattop=0 ))
      # echo "testing $test_vy for step $target_s, reaching $yattop"
      local velvec=$xvel,$test_vy
      [[ ${(M)#allowed_vels:#$velvec} == 0 ]] && allowed_vels+=($velvec)
      (( yattop > best_y_top )) && ((best_y_top=yattop))
      (( yattop >= best_y_top )) && (( best_vx=xvel ))
      (( yattop >= best_y_top )) && (( best_vy=test_vy ))
    done
  done
done

echo "top most point $best_y_top"
echo "with initial v = $best_vx,$best_vy"
for v in $allowed_vels; do
  echo "allowed velocity $v"
done
echo "there are $#allowed_vels allowed velocities"

# Compute within which steps the target area is reachable.
# x(s) = Σ_i=1^s (xvel - i + 1)                    if x <= xvel
#      = xvel*(xvel+1)//2 - (xvel-s)*(xvel-s+1)//2 if x <= xvel
#
# first step
# x(s1) = xvel*(xvel+1)//2 - (xvel-s1)*(xvel-s1+1)//2
#       = xvel^2//2 + xvel//2 - xvel^2//2 + xvel*s1 - s1^2//2 - xvel//2 + s1//2
# 2xlo  <= 2xvel*s1 - s1^2 + s1
# 0     (=) s1^2 - (1+2*xvel)*s1 + 2xlo
# s1_1/2 = ceil[(1+2*xvel)/2 ± √[(1+2*xvel)^2/4 - 2xlo]]
#
# xterm = xvel*(xvel+1)//2
# xterm within xlo..xhi → the range of possible steps is half open
#
