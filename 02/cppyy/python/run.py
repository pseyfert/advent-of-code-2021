#!/usr/bin/env python3
import cppyy
cppyy.load_library('types_rflx.so')
cppyy.load_library('types.so')

from cppyy.gbl import Cmd
from cppyy.gbl import Instruction
from cppyy.gbl import State
from cppyy.gbl.std import vector


def get_cmd(cmd_str: str) -> Cmd:
    if cmd_str == "forward":
        return Cmd.Forward
    elif cmd_str == "down":
        return Cmd.Down
    elif cmd_str == "up":
        return Cmd.Up


def parse(line: str) -> Instruction:
    key, val = line.split(' ')
    return Instruction(get_cmd(key), int(val))


with open('../input.txt', 'r') as content:
    data = content.readlines()

v = vector[Instruction]()
for l in data:
    v.push_back(parse(l))

s = State()
s.apply(v)
print(f"Answer is {s.horizontal*s.depth}")

