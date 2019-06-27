#!/bin/bash

set -ex

mkdir -p build-cpp
pushd build-cpp

cmake -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_C_FLAGS="$CFLAGS" \
      -DCMAKE_POSITION_INDEPENDENT_CODE=on \
      -DURIPARSER_BUILD_DOCS=off \
      -DURIPARSER_BUILD_TESTS=off \
      -DURIPARSER_BUILD_TOOLS=off \
      -DURIPARSER_BUILD_WCHAR_T=off \
      -DBUILD_SHARED_LIBS=on \
      ..

cmake --build . --config Release --target install

popd
