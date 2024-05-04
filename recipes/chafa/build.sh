#!/usr/bin/env bash

set -euo pipefail

./configure \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix="${PREFIX}" \
    --disable-silent-rules
make install
