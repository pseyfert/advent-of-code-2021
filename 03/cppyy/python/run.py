#!/usr/bin/env python3
import cppyy
cppyy.load_library("./funcs_rflx.so")
cppyy.load_library("./funcs.so")

from cppyy.gbl import epsilon  # noqa: E402
from cppyy.gbl import gamma  # noqa: E402
from cppyy.gbl.std import vector  # noqa: E402
from cppyy.gbl import uint16_t  # noqa: E402

with open('../input.txt', 'r') as content:
    data = content.readlines()

v = vector[uint16_t]()
v.reserve(len(data))
for line in data:
    v.push_back(int(line, 2))

print(f"γ={gamma(v)}")
print(f"ε={epsilon(v)}")
print(f"part I: {gamma(v)*epsilon(v)}")
