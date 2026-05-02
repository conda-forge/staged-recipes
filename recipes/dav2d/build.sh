#!/bin/bash
set -ex

meson setup builddir \
    --prefix="${PREFIX}" \
    --libdir=lib \
    --buildtype=release \
    --default-library=shared \
    -Denable_tools=true \
    -Denable_tests=false \
    -Denable_examples=false

meson compile -C builddir -v
meson install -C builddir
