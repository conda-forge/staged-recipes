#!/bin/bash

CMD="$PYTHON -c 'import Biobrd'"
DISPLAY=localhost:1.0 xvfb-run -a bash -c $CMD
