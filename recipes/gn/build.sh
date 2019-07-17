#!/bin/bash

set -euo pipefail

python build/gen.py
ninja -C out
mkdir -p $PREFIX/bin
cp out/gn $PREFIX/bin/gn
