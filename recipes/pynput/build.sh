#!/bin/bash

Xvfb :1 &
export DISPLAY=:1
$PYTHON -m pip install . --no-deps -vv