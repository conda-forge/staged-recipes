#!/bin/bash
set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

meson setup builddir \
    --prefix="$PREFIX" \
    --buildtype=release \
    -Dwith_tests=false \
    -Dwith_examples=false

ninja -C builddir
ninja -C builddir install
