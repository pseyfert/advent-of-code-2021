#!/usr/bin/env python3

import numpy as np
from typing import List
from enum import Enum
from dataclasses import dataclass

# NB: my fork to accept np.ndarray
from advent_of_code_ocr import convert_6_np


class Axis(Enum):
    X = "x"
    Y = "y"

    def ax(self):
        if self == Axis.X:
            return 1
        elif self == Axis.Y:
            return 0


@dataclass
class Instruction:
    axis: Axis
    amount: int


fold_instructions: List[Instruction] = []

paper = np.zeros((895, 1311), dtype=bool)

with open("input.txt", "r") as data:
    for line in data.readlines():
        line = line.strip()
        if line.startswith("fold"):
            ax_str, amount = line[len("fold along "):].split("=")
            fold_instructions.append(Instruction(Axis(ax_str), int(amount)))
        elif "," in line:
            line_arr = line.split(",")
            line_arr.reverse()
            paper[tuple(int(i) for i in line_arr)] = True


for step, inst in enumerate(fold_instructions):
    first_folded = inst.amount+1
    last_folded_excl = paper.shape[inst.axis.ax()]

    fold = last_folded_excl - first_folded

    last_covered_excl = inst.amount
    first_covered = max(0, last_covered_excl - fold)

    fold = min(last_covered_excl - first_covered, fold)
    last_folded_excl = first_folded + fold

    if inst.axis == Axis.X:
        paper[:, first_covered:last_covered_excl] |= np.flip(paper[:, first_folded:last_folded_excl], axis=inst.axis.ax())
        paper[:, first_folded:last_folded_excl] = False
    if inst.axis == Axis.Y:
        paper[first_covered:last_covered_excl, :] |= np.flip(paper[first_folded:last_folded_excl, :], axis=inst.axis.ax())
        paper[first_folded:last_folded_excl, :] = False
    if step == 0:
        print(paper.sum())

print(convert_6_np(paper[:6, :40]))
