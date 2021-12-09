#!/usr/bin/env bash

set +x

export PKG_CONFIG_LIBDIR=$PREFIX/lib

mkdir -p build
cd build

cmake                                                \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX              \
    -DWITH_CAIRO=0                                   \
    -DWITH_CLIENT_WFS=1                              \
    -DWITH_FCGI=0                                    \
    -DWITH_FRIBIDI=0                                 \
    -DWITH_HARFBUZZ=0                                \
    -DWITH_PHP=0                                     \
    -DWITH_PROTOBUFC=0                               \
    -DWITH_PYTHON=1                                  \
    --debug-output ${SRC_DIR}

make -j${CPU_COUNT}
make install
