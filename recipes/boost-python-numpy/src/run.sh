#!/bin/sh

COMMAND="import numpy as np; from test2 import Test; t = Test(); t.save(np.arange(3))"

$PYTHON -c "$COMMAND"

