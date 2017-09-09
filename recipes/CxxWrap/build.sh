#!/bin/bash

cmake -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=lib $SRC_DIR/deps/src/jlcxx
make install
