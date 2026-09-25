#!/bin/bash
set -euo pipefail

# Tests need gtest and the capnp CLI; the package ships the runtime and
# the plugin, so build neither here.
meson setup builddir \
    --prefix="$PREFIX" \
    --libdir=lib \
    --buildtype=release \
    -Denable_tests=false
meson compile -C builddir
meson install -C builddir
