#!/usr/bin/env python3
import cppyy
cppyy.load_library("./api_rflx.so")
cppyy.load_library("./impl.so")

from cppyy.gbl import Board  # noqa: E402
# from cppyy.gbl.std import vector  # noqa: E402

with open('../input.txt', 'r') as content:
    data = content.readlines()
