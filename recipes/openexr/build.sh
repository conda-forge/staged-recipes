#!/bin/bash

mkdir build
cd build

cmake $SRC_DIR -G "Ninja" \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_PREFIX_PATH:PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DOPENEXR_BUILD_PYTHON_LIBS:BOOL=OFF \
    -DOPENEXR_NAMESPACE_VERSIONING:BOOL=OFF \
    -DOPENEXR_BUILD_STATIC:BOOL=ON

ninja test
ninja install
