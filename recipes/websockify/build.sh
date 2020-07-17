#!/bin/bash

set -eu

python -m pip install . --no-deps --ignore-installed -vv

make
mv rebind.so $PREFIX/lib/
