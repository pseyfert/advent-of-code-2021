#!/usr/bin/zsh

set -euo pipefail

zmodload zsh/mapfile
local -a game
game=("${(@f)mapfile[$1]}")

local -a drawn
drawn=(${(s:,:)game[1]})

check_board() {
  # call with all 25 numbers/'xx'
  # echo "check board got $# args"

  # check horizontal
  for (( row=1 ; row <= 5; row++)) ; do
    bingo=true
    for (( col=1; col <= 5; col++)); do
      (( idx = (row - 1)*5 + col ))
      if [[ $@[$idx] != 'xx' ]]; then
        bingo=false
        break
      fi
    done
    $bingo&&return 0
  done

  # check vertical
  for (( col=1; col <= 5; col++)); do
    bingo=true
    for (( row=1 ; row <= 5; row++)) ; do
      (( idx = (row - 1)*5 + col ))
      if [[ $@[$idx] != 'xx' ]]; then
        bingo=false
        break
      fi
    done
    $bingo&&return 0
  done
  return 1
}

sum_remaining() {
  local -i acc
  acc=0
  for i in $@; do
    [[ $i != 'xx' ]] && acc+=$i
  done
  return $acc
}

local won=false
local -i score
set +e
for (( round_id=1; round_id <= $#drawn ; round_id++ )); do
  local -i draw
  draw=$drawn[$round_id]
  # echo "called $draw"
  # echo "going over $#game rows in the game description"
  # echo "game looks like"
  # for (( row = 3; row <= $#game; row++ )); do
  #   echo $game[$row]
  # done

  ## replace drawn numbers by 'xx'
  for (( row = 3; row <= $#game; row++ )); do
    if (( $draw < 10 )); then
      # silly leading white space
      # first cases where we're not dealing with the first column
      game[$row]=${game[$row]/"  $draw"/" xx"}
      # and then patching up the first column
      game[$row]=${game[$row]/#" $draw"/"xx"}
    else
      game[$row]=${game[$row]/$draw/xx}
    fi
  done
  # echo "game looks like"
  # for (( row = 3; row <= $#game; row++ )); do
  #   echo $game[$row]
  # done


  local -i board_id
  for (( board_id=1 ; board_id*6 < $#game ; board_id++ )); do
    local board=""
    local -a board_cells
    local -i first_row
    local -i last_row
    (( first_row=6*(board_id - 1) + 3 ))
    (( last_row=6*(board_id - 1) + 7 )) # inclusive
    board=$game[$first_row,$last_row]
    local -a board_print
    # board_print=($game[$first_row,$last_row])
    # echo "board looks like"
    # for (( row = 1; row <= $#board_print; row++ )); do
    #   echo $board_print[$row]
    # done
    board_cells=(${(s: :)board})
    # for bc in $board_cells; do echo "cell $bc"; done
    if check_board $board_cells ; then
      won=true
      sum_remaining $board_cells
      (( score = $? * $draw ))
      echo "Board $board_id won, with a score of $score"
      break
    fi
  done
  $won&&break
done
