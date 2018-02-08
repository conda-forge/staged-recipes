#!/bin/bash
sed -i -E -e 's/'"'"'lapack'"'"'/'"'"'openblas'"'"'/' pycvodes/_config.py
PYCVODES_LAPACK=openblas CPLUS_INCLUDE_PATH=${PREFIX}/include ${PYTHON} -m pip install --no-deps --ignore-installed .
