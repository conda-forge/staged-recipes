#!/bin/bash
set -euo pipefail

./configure --prefix=${PREFIX}
make
make check
make install
