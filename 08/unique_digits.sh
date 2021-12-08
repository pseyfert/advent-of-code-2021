#!/usr/bin/zsh

set -uo pipefail

zmodload zsh/mapfile
local -a displays
displays=("${(f)mapfile[$1]}")

local -i part_i=0
local -i part_ii=0
for display in $displays; do
  local -a all_digits
  all_digits=(${(s: :)"${display%|*}"})
  local -a actual_digits
  actual_digits=(${(s: :)"${display#*|}"})
  local -a digitslookup
  for i in {1..10}; do digitslookup[$i]=""; done
  for d in $actual_digits; do
    case $#d in
      (2|3|4|7)
        (( part_i++ ))
        ;;
    esac
  done
  for d in $all_digits; do
    # echo "checking $d"
    case $#d in
      (2)
        # 1
        # echo "1 is $d"
        digitslookup[2]=$d
        ;;
      (3)
        # 7
        # echo "7 is $d"
        digitslookup[8]=$d
        ;;
      (4)
        # 4
        # echo "4 is $d"
        digitslookup[5]=$d
        ;;
      (7)
        # 8
        # echo "8 is $d"
        digitslookup[9]=$d
        ;;
    esac
  done
  for d in $all_digits; do
    case $#d in
      (5)
        # 2,3,5
        # echo "first pass 2,3,5 for $d"
        local -i overlap_1=0
        for (( i = 1; i <= $#d ; i++ )); do
          l=$d[i]
          [[ $digitslookup[2] =~ $l ]] && ((overlap_1++))
        done
        # echo "1 is $digitslookup[2] with overlap $overlap_1 (if ==2 → this is a 3)"
        [[ $overlap_1 == 2 ]] && digitslookup[4]=$d
        ;;
      (6)
        # 0,6,9
        # echo "pass 0,6,9 for $d"
        local -i overlap_4=0
        local -i overlap_1=0
        for (( i = 1; i <= $#d ; i++ )); do
          l=$d[i]
          # echo "testing wire $l"
          # [[ $digitslookup[2] =~ $l ]] && echo "also found in $digitslookup[2] (1)"
          # [[ $digitslookup[5] =~ $l ]] && echo "also found in $digitslookup[5] (4)"
          [[ $digitslookup[2] =~ $l ]] && ((overlap_1++))
          [[ $digitslookup[5] =~ $l ]] && ((overlap_4++))
        done
        # echo "1 is $digitslookup[2] with overlap $overlap_1"
        # echo "4 is $digitslookup[5] with overlap $overlap_4"
        if [[ $overlap_4 == 4 ]]; then
          # echo "this is a 9"
          digitslookup[10]=$d
        else
          # [[ $overlap_1 == 2 ]] && echo "is a 0" || echo "is a 6"
          [[ $overlap_1 == 2 ]] && digitslookup[1]=$d || digitslookup[7]=$d
        fi
        ;;
    esac
  done
  for d in $all_digits; do
    case $#d in
      (5)
        # 2,3,5
        # echo "second pass 2,3,5 for $d"
        local -i overlap_4=0
        for (( i = 1; i <= $#d ; i++ )); do
          l=$d[i]
          [[ $digitslookup[5] =~ $l ]] && ((overlap_4++))
        done
        # echo "3 is $digitslookup[4] with overlap $overlap_3"
        if [[ $overlap_4 == 3 ]]; then
          # [[ $d == $digitslookup[4] ]] || echo "identified as 5"
          [[ $d == $digitslookup[4] ]] || digitslookup[6]=$d
        else
          # [[ $d == $digitslookup[4] ]] || echo "identified as 2"
          [[ $d == $digitslookup[4] ]] || digitslookup[3]=$d
        fi
        ;;
    esac
  done
  for i in {1..10}; do
    [[ $digitslookup[$i] == "" ]] && echo "messed it up: $(( i - 1 ))"
    for (( j = i+1; j < 11; j++ )); do
      [[ $digitslookup[$j] == $digitslookup[$i] ]] && echo "messed it up: $(( i - 1 )) vs $(( j - 1 ))"
    done
  done
  # break
  lookup() {
    case $#1 in
      (2)
        return 1
        ;;
      (3)
        return 7
        ;;
      (4)
        return 4
        ;;
      (7)
        return 8
        ;;
    esac
    case $#1 in
      (5)
        # 2,3,5
        local -i overlap_2=0
        local -i overlap_3=0
        local -i overlap_5=0
        for (( i = 1; i <= 5 ; i++ )); do
          l=${1[$i]}
          [[ $digitslookup[3] =~ $l ]] && (( overlap_2++ ))
          [[ $digitslookup[4] =~ $l ]] && (( overlap_3++ ))
          [[ $digitslookup[6] =~ $l ]] && (( overlap_5++ ))
        done
        [[ $overlap_2 == 5 ]] && return 2
        [[ $overlap_3 == 5 ]] && return 3
        [[ $overlap_5 == 5 ]] && return 5
        ;;
      (6)
        # 0,6,9
        local -i overlap_0=0
        local -i overlap_6=0
        local -i overlap_9=0
        for (( i = 1; i <= 6 ; i++ )); do
          l=${1[$i]}
          [[ $digitslookup[1] =~ $l ]] && (( overlap_0++ ))
          [[ $digitslookup[7] =~ $l ]] && (( overlap_6++ ))
          [[ $digitslookup[10] =~ $l ]] && (( overlap_9++ ))
        done
        [[ $overlap_0 == 6 ]] && return 0
        [[ $overlap_6 == 6 ]] && return 6
        [[ $overlap_9 == 6 ]] && return 9
        ;;
    esac
    echo "messed up"
  }
  local -i this_display=0
  lookup $actual_digits[1]
  retval=$?
  (( part_ii += 1000*$retval ))
  (( this_display += 1000*$retval ))
  lookup $actual_digits[2]
  retval=$?
  (( part_ii += 100*$retval ))
  (( this_display += 100*$retval ))
  lookup $actual_digits[3]
  retval=$?
  (( part_ii += 10*$retval ))
  (( this_display += 10*$retval ))
  lookup $actual_digits[4]
  retval=$?
  (( part_ii += 1*$retval ))
  (( this_display += 1*$retval ))
  # echo "this_display = $this_display"
  # break
done

echo "Part I: ${part_i}"
echo "Part II: ${part_ii}"
