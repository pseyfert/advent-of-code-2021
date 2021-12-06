#!/usr/bin/env python3
import numpy as np
data = np.genfromtxt('input.txt')

print(f"part 1: {np.count_nonzero(data[0:-1] < data[1:])}")
print(f"part 2: {np.count_nonzero(data[0:-3] < data[3:])}")
