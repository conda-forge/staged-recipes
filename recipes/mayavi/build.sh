#!/bin/bash

CMD="$PYTHON setup.py install --single-version-externally-managed --record record.txt"

DISPLAY=localhost:1.0 xvfb-run -a bash -c $CMD
