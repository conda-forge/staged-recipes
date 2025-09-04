#!/bin/bash
set -ex

# Configure with meson
meson setup builddir \
  --prefix=$PREFIX \
  --buildtype=release \
  -Dpython=true

# Build
meson compile -C builddir

# Install into $PREFIX
meson install -C builddir

