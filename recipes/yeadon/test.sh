#!/bin/bash

CMD="$PYTHON import_test.py"
DISPLAY=localhost:1.0 xvfb-run -a bash -c $CMD

CMD="$PYTHON ice_skating.py"
DISPLAY=localhost:1.0 xvfb-run -a bash -c $CMD
