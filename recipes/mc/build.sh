#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-silent-rules \
    --without-x \
    --with-screen=slang \
    --disable-dependency-tracking \
    --enable-vfs-sftp \
    --prefix=${PREFIX}
make check
make install
