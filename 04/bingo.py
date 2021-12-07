#!/usr/bin/env python3

import numpy as np

with open('input.txt', 'r') as data:
    foo = [line.strip() for line in data.readlines()]

drawings = [np.int16(num) for num in foo[0].split(',')]

nparray = np.array([f.split() for f in foo[1:] if f != ''], dtype=np.int16)
game = np.ma.masked_array(nparray.reshape(-1, 5, 5),
                          np.ma.make_mask_none(nparray.shape))


def draw_number(game_, drawn: np.int16):
    game_.mask |= (game_ == drawn)


def keep_board(board, drawn: np.int16, printout: bool) -> bool:
    def score(board):
        if printout:
            print(f"board solved with {board.sum()*drawn}")

    if board.mask.all(0).any() or board.mask.all(1).any():
        score(board)
        return False
    return True


unsolved_board_ids = set(range(game.shape[0]))

for draw in drawings:
    draw_number(game, draw)

    p = len(unsolved_board_ids) in [100, 1]
    unsolved_board_ids = set(filter(lambda board_id: keep_board(
        game[board_id], draw, p), unsolved_board_ids))
