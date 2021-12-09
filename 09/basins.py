#!/usr/bin/env python3

import numpy as np

with open('input.txt', 'r') as inp:
    data = [[np.int8(c) for c in line.strip()] for line in inp.readlines()]

input_data = np.array(data)

basins = np.zeros_like(input_data, dtype=bool)
basins[:, :] = True
basins[1:, :] &= (input_data[1:, :] < input_data[:-1, :])
basins[:-1, :] &= (input_data[:-1, :] < input_data[1:, :])
basins[:, 1:] &= (input_data[:, 1:] < input_data[:, :-1])
basins[:, :-1] &= (input_data[:, :-1] < input_data[:, 1:])

print(f"part I: {((1+input_data)*basins).sum()}")
