#!/usr/bin/env python3

import numpy as np

day_progress = np.zeros((9, 9), dtype=np.int64)
for i in range(8):
    day_progress[i, i+1] = 1
day_progress[8, 0] = 1
day_progress[6, 0] = 1

initial_population = np.genfromtxt('input.txt', delimiter=',', dtype=np.int64)

initial_vector = np.array([(initial_population == i).sum() for i in range(9)])

after_80 = (np.linalg.matrix_power(day_progress, 80)).dot(initial_vector)
print(f"Part I: {after_80.sum()}")
after_256 = (np.linalg.matrix_power(day_progress, 256-80)).dot(after_80)
print(f"Part II: {after_256.sum()}")
