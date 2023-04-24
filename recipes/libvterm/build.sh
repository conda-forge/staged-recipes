#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make install LIBTOOL=${BUILD_PREFIX}/bin/libtool PREFIX=${PREFIX}
make test LIBTOOL=${BUILD_PREFIX}/bin/libtool PREFIX=${PREFIX}

rm -f ${PREFIX}/lib/libvterm.a
