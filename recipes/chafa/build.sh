#!/usr/bin/env bash

set -euo pipefail

# By installing from a release tar-ball (see meta.yaml), we avoid the
# need for ./autogen.sh and additional dependencies

./configure \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix="${PREFIX}" \
    --disable-silent-rules
make install
