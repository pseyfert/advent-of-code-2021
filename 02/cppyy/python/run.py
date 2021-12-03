#!/usr/bin/env python3
import cppyy
cppyy.load_library('types_rflx.so')
cppyy.load_library('types.so')

from cppyy.gbl import Cmd  # noqa: E402
from cppyy.gbl import Instruction  # noqa: E402
from cppyy.gbl import State  # noqa: E402
from cppyy.gbl.std import vector  # noqa: E402


def get_cmd(cmd_str: str) -> Cmd:
    if cmd_str == "forward":
        return Cmd.Forward
    elif cmd_str == "down":
        return Cmd.Down
    elif cmd_str == "up":
        return Cmd.Up


def parse(line: str) -> Instruction:
    key, val = line.split(' ')
    return Instruction(cmd=get_cmd(key), amount=int(val))


with open('../input.txt', 'r') as content:
    data = content.readlines()

v = vector[Instruction]()
v.reserve(len(data))
for line in data:
    v.push_back(parse(line))

s = State()
s.apply(v)
print(f"Answer is {s.horizontal*s.depth}")
