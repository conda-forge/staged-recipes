#!/bin/bash
set -euo pipefail

# fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $SRC_DIR/tests/t*.pl

./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make check
make install
