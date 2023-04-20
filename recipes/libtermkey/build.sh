#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make LIBTOOL=${BUILD_PREFIX}/bin/libtool PREFIX=${PREFIX}
make install LIBTOOL=${BUILD_PREFIX}/bin/libtool PREFIX=${PREFIX}
