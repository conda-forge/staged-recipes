#!/bin/bash -x
rm pydiso/*.c
MKLROOT=$PREFIX $PYTHON -m pip install . --no-deps -vv
