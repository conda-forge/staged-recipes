#!/usr/bin/env bash

export CFLAGS="$CFLAGS -std=c11 -D_GNU_SOURCE $(pkg-config --cflags libfyaml)"
export LDFLAGS="-Wl,-rpath,$PREFIX/lib $(pkg-config --libs libfyaml)"

# Apply patches
patch -p0 -i "$RECIPE_DIR"/patches/0002-0.1.0a2-fix-munit-integration.patch
patch -p0 -i "$RECIPE_DIR"/patches/0003-0.1.0a2-check-userfaultfd-user-mode.patch

# Bootstrap for local autotools
autoreconf -i

# Configure
./configure --prefix="$PREFIX" \
    --with-gwcs \
    --without-libstatgrab
    CFLAGS="${CFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}"

# Build
make V=1

# Test
make check

# Install
make install
