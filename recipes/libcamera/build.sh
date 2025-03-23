#!/bin/bash
set -xeuo pipefail
# export CXXFLAGS="${CXXFLAGS} -Wno-error -D_GNU_SOURCE"

meson setup build
ninja -C build install
