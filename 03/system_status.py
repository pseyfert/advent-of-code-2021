#!/usr/bin/env python3

import numpy as np

with open('input.txt', 'r') as i:
    raw_data = [int(line.strip(), 2) for line in i.readlines()]

data = np.zeros((1, len(raw_data)), dtype=np.int64)
data[0] = raw_data

check = np.zeros((12, 1), dtype=np.int64)
for e in range(12):
    check[e] = 2**e

bitmatrix = check & data

fancier = (bitmatrix.sum(1) // check.T[0]) > len(raw_data)/2
majority_bits = (fancier*check.T[0]).sum()

# # With this one could keep the above as int16 instead of int64.
# majority_bits = np.int16(0)
# for e in range(12):
#     if np.count_nonzero(bitmatrix[e, :]) > len(raw_data)/2:
#         majority_bits |= np.int16(2**e)
minority_bits = np.int16(2**12 - 1) ^ majority_bits

print(f"Part I: {int(majority_bits)*int(minority_bits)=}")

oxy = np.ma.masked_array(data[0], mask=[False]*len(data[0]))
co2 = np.ma.masked_array(data[0], mask=[False]*len(data[0]))


def filter_out(patterns, majority=True):
    for e in range(12)[::-1]:
        # how many unmasked have the e-th bit set
        bit_set = (patterns & check[e]).sum()//check[e]
        # how many are unmasked
        total = patterns.count()
        keep_patterns_with_0 = (patterns & check[e]) == check[e]
        if majority == (bit_set >= (total+1)//2):
            # keep those numbers where the bit is set
            patterns.mask |= np.invert(keep_patterns_with_0)
        else:
            patterns.mask |= keep_patterns_with_0
        if np.invert(patterns.mask).sum() == 1:
            return patterns


oxy = filter_out(oxy)
co2 = filter_out(co2, False)

print(f"Part II: {oxy.sum()*co2.sum()}")
