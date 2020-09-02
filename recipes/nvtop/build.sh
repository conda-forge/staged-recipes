#!/bin/bash
set -euo pipefail

mkdir -p nvtop/build && cd nvtop/build
cmake ..

make
make check
make install

