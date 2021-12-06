#!/usr/bin/env python3

import numpy as np

with open("input.txt", 'r') as i:
    data = [line.strip().split(" ") for line in i.readlines()]


def state_I():
    return np.zeros((2,), dtype=np.int32)


def state_II():
    retval = np.zeros((4,), dtype=np.int32)
    retval[3] = 1
    return retval


def state_change_II():
    retval = np.zeros((4, 4), dtype=np.int32)
    return retval


forward_I = state_I()
forward_I[0] = 1

sink_I = state_I()
sink_I[1] = 1

state_I_ = state_I()

state_II_ = state_II()

forward_II = state_change_II()
forward_II[0][3] = 1
forward_II[1][2] = 1

sink_II = state_change_II()
sink_II[2][3] = 1

for cmd, amount_str in data:
    amount = int(amount_str)
    if cmd == 'forward':
        state_I_ += amount * forward_I
        state_II_ += amount * forward_II.dot(state_II_)
    elif cmd == 'down':
        state_I_ += amount * sink_I
        state_II_ += amount * sink_II.dot(state_II_)
    elif cmd == 'up':
        state_I_ -= amount * sink_I
        state_II_ -= amount * sink_II.dot(state_II_)

print(f"Part I: {state_I_.prod()}")
print(f"Part II: {state_II_[0]*state_II_[1]}")
