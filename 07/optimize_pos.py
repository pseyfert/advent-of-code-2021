#!/usr/bin/env python3

import numpy as np

crabs = np.genfromtxt('input.txt', delimiter=',', dtype=np.int16)

fuel_1 = (np.abs(crabs - np.int16(np.median(crabs)))).sum()
print(f"Part I: {fuel_1}")

# For the fun of it, brute force the second part.

poses = np.array([np.linspace(np.min(crabs),
                              np.max(crabs),
                              np.max(crabs)-np.min(crabs)+1)],
                 dtype=np.int32).T

abs_move = np.abs(poses - crabs)
fuel_matrix = abs_move * (abs_move+1) // 2
fuel_per_pos = fuel_matrix.sum(1)
print(f"Part II: {np.min(fuel_per_pos)}")
