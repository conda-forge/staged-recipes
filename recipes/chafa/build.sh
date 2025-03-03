#!/usr/bin/env bash

set -euo pipefail

# By installing from a release tar-ball (see meta.yaml), we avoid the
# need for ./autogen.sh and additional dependencies

export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

./configure \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix="${PREFIX}" \
    --disable-silent-rules
make install
