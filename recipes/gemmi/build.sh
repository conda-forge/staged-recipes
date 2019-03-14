#!/bin/bash

cmake .
make

cp gemmi "$PREFIX/bin/"

"$PYTHON" -m pip install . --no-deps -vv
