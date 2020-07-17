#!/bin/bash

set -eu

python -m pip install . --no-deps --ignore-installed -vv

# Only supported on Linux
if [ "$SHLIB_EXT" = ".so" ]; then
  make
  mv rebind.so $PREFIX/lib/
fi
