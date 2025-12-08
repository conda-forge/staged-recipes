#!/usr/bin/env bash

export CFLAGS="$CFLAGS -std=c11 -D_GNU_SOURCE $(pkg-config --cflags libfyaml)"
export LDFLAGS="-Wl,-rpath,$PREFIX/lib $(pkg-config --libs libfyaml)"

# Apply patches
patch -p0 -i "$RECIPE_DIR"/0001-fix-test-fyaml-linkage.patch

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
