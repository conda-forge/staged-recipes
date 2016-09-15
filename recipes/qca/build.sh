#!/usr/bin/env bash

[[ ! -d build ]] && mkdir build/
cd build/

# "default" channel "qt" creates "plugins" in root of environment
# Need to put "qca" plugin -- including qca-ossl -- in that folder
cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DUSE_RELATIVE_PATHS=TRUE \
    -DQCA_PLUGINS_INSTALL_DIR=$PREFIX/plugins \
    ..

make
# No make check
make install
