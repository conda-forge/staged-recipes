#!/bin/bash

# From https://github.com/conda-forge/staged-recipes/blob/a4bba62ee089ab1355732b82daba3504b227cad1/recipes/yeadon/test.sh

CMD="$PYTHON import_test.py"
DISPLAY=localhost:1.0 xvfb-run -a bash -c $CMD
