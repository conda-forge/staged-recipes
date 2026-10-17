#!/bin/bash
set -euo pipefail

meson setup builddir \
    --prefix="$PREFIX" \
    --libdir=lib \
    --buildtype=release
meson compile -C builddir
meson install -C builddir
