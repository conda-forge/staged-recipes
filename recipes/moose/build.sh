#!/bin/bash
set -ex

# Configure
meson setup builddir \
    --prefix="$PREFIX" \
    --buildtype=release \
    -Dpython=true

# Build
meson compile -C builddir

# Install
meson install -C builddir

