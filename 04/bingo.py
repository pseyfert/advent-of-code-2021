#!/usr/bin/env python3

import numpy as np

with open('input.txt', 'r') as data:
    foo = [line.strip() for line in data.readlines()]

drawings = [int(num) for num in foo[0].split(',')]

nparray = np.array([f.split() for f in foo[1:] if f != ''], dtype=np.int16)
game = np.ma.masked_array(nparray, np.ma.make_mask_none(nparray.shape))


def draw_number(game_, drawn: np.int16):
    game_.mask |= (game_ == drawn)


def keep_board(board, drawn: int, printout: bool) -> bool:
    def score(board):
        if printout:
            print(f"board solved with {board.sum()*drawn}")

    for row in board.mask:
        if row.all():
            score(board)
            return False
    for row in board.mask.T:
        if row.all():
            score(board)
            return False
    return True


unsolved_board_ids = set(range(game.shape[0]//5))

for draw in drawings:
    draw_number(game, draw)

    p = len(unsolved_board_ids) in [100, 1]
    unsolved_board_ids = set(filter(
        lambda board_id: keep_board(game[5*board_id:5*(board_id+1), ], draw, p),
        unsolved_board_ids))
