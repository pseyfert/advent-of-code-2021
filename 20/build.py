#!/usr/bin/env python

import pathlib
import subprocess
import os
import sys

e = os.environ

steps = 50
padding = 2 * (1+steps)

data = pathlib.Path(sys.argv[2]).read_text().split('\n')
rows = len(data) + padding - 3
cols = len(data[-2]) + padding
e['ROWS'] = str(rows)
e['COLS'] = str(cols)
e['FILE'] = sys.argv[2]
e['PADDING'] = str(padding)
subprocess.check_call(['make', sys.argv[1], '-W', 'one.cu'], env=e)
