#!/usr/bin/env python

import os
import subprocess
import sys


os.chdir(os.environ["SRC_DIR"])
subprocess.check_call([sys.executable, "test_pycosat.py"])
