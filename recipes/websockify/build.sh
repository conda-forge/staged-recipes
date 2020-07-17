#!/bin/bash

set -eu

python -m pip install . --no-deps --ignore-installed -vv

make
# Extension is hard-coded to .so: https://github.com/novnc/websockify/issues/156
mv rebind.so $PREFIX/lib/rebind$SHLIB_EXT
