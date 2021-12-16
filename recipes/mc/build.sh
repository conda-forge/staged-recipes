#!/bin/bash

set -ex

./configure                 \
    --prefix=$PREFIX        \
    --disable-debug         \
    --without-x             \
    --with-screen=slang     \
    --enable-vfs-sftp || { cat config.log; exit 1; }

make -j$CPU_COUNT

make install
