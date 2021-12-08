#!/usr/bin/env python3

import numpy as np

allchar = "abcdefg"
a = 0
b = 1
c = 2
d = 3
e = 4
f = 5
g = 6

d0 = np.array([1, 1, 1, 0, 1, 1, 1], dtype=bool)
d1 = np.array([0, 0, 1, 0, 0, 1, 0], dtype=bool)
d2 = np.array([1, 0, 1, 1, 1, 0, 1], dtype=bool)
d3 = np.array([1, 0, 1, 1, 0, 1, 1], dtype=bool)
d4 = np.array([0, 1, 1, 1, 0, 1, 0], dtype=bool)
d5 = np.array([1, 1, 0, 1, 0, 1, 1], dtype=bool)
d6 = np.array([1, 1, 0, 1, 1, 1, 1], dtype=bool)
d7 = np.array([1, 0, 1, 0, 0, 1, 0], dtype=bool)
d8 = np.array([1, 1, 1, 1, 1, 1, 1], dtype=bool)
d9 = np.array([1, 1, 1, 1, 0, 1, 1], dtype=bool)

all_digits = np.array([d0, d1, d2, d3, d4, d5, d6, d7, d8, d9])


def real_wires_to_numbers(arr):
    assert arr.shape[1:] == (4, 7)
    # decoded_bool_pos = np.equal.outer(
    #     arr, all_digits).trace(axis1=2, axis2=4) == 7
    decoded_bool_pos = np.equal.outer(
        arr, all_digits).diagonal(axis1=2, axis2=4).all(axis=3)
    decoded = decoded_bool_pos.dot(
        np.array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])).dot(
        np.array([1000, 100, 10, 1]))
    return decoded


def real_wires_to_number(arr):
    assert arr.shape == (4, 7)  # four digits, each digit 7 wires
    decoded_bool_pos = np.equal.outer(
        arr, all_digits).trace(axis1=1, axis2=3) == 7
    decoded = decoded_bool_pos.dot(
        np.array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])).dot(
        np.array([1000, 100, 10, 1]))
    return decoded


def bareparse(encoded: str):
    assert encoded.count(" ") == 0
    return np.array([encoded.count(char) for char in allchar], dtype=bool)


def parse_encoded(encoded_number: str):
    return np.array([bareparse(digit) for digit in encoded_number.split(" ")])


def create_dict(line_before_pipe: str):
    counts = [line_before_pipe.count(char) for char in allchar]
    for encoded_digit in line_before_pipe.split(" "):
        if len(encoded_digit) == 4:
            four = encoded_digit
    matrix = np.zeros((7, 7), dtype=bool)
    for i, count in enumerate(counts):
        if count == 4:
            matrix[e, i] = True
        elif count == 6:
            matrix[b, i] = True
        elif count == 9:
            matrix[f, i] = True
        elif count == 7:
            if allchar[i] in four:
                matrix[d, i] = True
            else:
                matrix[g, i] = True
        elif count == 8:
            if allchar[i] in four:
                matrix[c, i] = True
            else:
                matrix[a, i] = True
        else:
            assert False
    assert matrix.any(1).all()
    assert matrix.any(0).all()
    assert matrix.sum() == 7
    return matrix


with open('input.txt', 'r') as file:
    data = [line.strip() for line in file.readlines()]

acc = 0
for i, line in enumerate(data):
    decode_data, encoded_number = line.split(" | ")
    matrix = create_dict(decode_data)
    encoded = parse_encoded(encoded_number)
    acc += real_wires_to_number(matrix.dot(encoded.T).T)

print(f"part II (version 1): {acc}")

matrixs = np.zeros((len(data), 7, 7), dtype=bool)
encoded = np.zeros((len(data), 4, 7), dtype=bool)
dewired = np.zeros((len(data), 7, 4), dtype=bool)
for i, line in enumerate(data):
    decode_data, encoded_number = line.split(" | ")
    matrixs[i] = create_dict(decode_data)
    encoded[i] = parse_encoded(encoded_number)

# The usage of diagonal implies that many off-diagonal elements get computed,
# that won't ever get looked at.
# dewired = np.tensordot(matrixs, encoded, axes=((2, ), (2, ))).diagonal(
#     axis1=0, axis2=2).transpose((2, 1, 0))

# l = line
# o = out_digit_code
# i = in_digit_code
# d = decimal_digit
dewired = np.einsum('loi,ldi->ldo', matrixs, encoded)

acc = real_wires_to_numbers(dewired).sum()
print(f"part II (version 2): {acc}")
