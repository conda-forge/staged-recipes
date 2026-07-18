#!/bin/bash
set -ex

cmake -GNinja -B build -S . ${CMAKE_ARGS} \
    -DUSE_QT6=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DQT_PLUGINS_DIR=$PREFIX/lib/qt6/plugins

cmake --build build --parallel
cmake --install build
