#!/usr/bin/env python3
import cppyy
cppyy.load_library('types_rflx.so')

from cppyy.gbl import Cmd
from cppyy.gbl import Instruction
from cppyy.gbl import State
from cppyy.gbl.std import vector


def parse(line: str) -> Instruction:
    key, val = line.split(' ')
    if key == "forward":
        return Instruction(Cmd.Forward, int(val))
    elif key == "down":
        return Instruction(Cmd.Down, int(val))
    elif key == "up":
        return Instruction(Cmd.Up, int(val))


with open('../input.txt', 'r') as content:
    data = content.readlines()

v = vector[Instruction]()
for l in data:
    v.push_back(parse(l))

s = State()
s.apply(v)
print(f"Answer is {s.horizontal*s.depth}")

