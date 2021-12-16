#!/bin/bash

set -ex

./configure                 \
    --prefix=$PREFIX        \
    --disable-debug         \
    --without-x             \
    --with-screen=slang     \
    --enable-vfs-sftp

make -j$CPU_COUNT

make install
