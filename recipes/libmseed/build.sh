#!/bin/bash
set -euxo pipefail

# Build shared library with URL support (requires libcurl)
make shared CFLAGS="${CFLAGS} -DLIBMSEED_URL"
make install PREFIX="${PREFIX}"
