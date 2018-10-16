#!/usr/bin/env bash

set -ex

mkdir -p build
cd build

if [ $(uname) == Darwin ]; then
  export CC=clang
  export CXX=clang++
  export MACOSX_DEPLOYMENT_TARGET="10.9"
  export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
  # export DYLD_LIBARY_PATH=$PREFIX/lib:$DYLD_LIBRARY_PATH
  export BOOST_INCLUDEDIR=$PREFIX/include
  export LDFLAGS="-L$PREFIX/lib $LDFLAGS -Wl,-rpath,$PREFIX/lib"
fi

env

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=release \
    -DENABLE_CUDA=off \
    -DMAPD_IMMERSE_DOWNLOAD=off \
    -DMAPD_DOCS_DOWNLOAD=off \
    -DPREFER_STATIC_LIBS=off \
    -DENABLE_AWS_S3=off \
    -DENABLE_TESTS=on  \
    -DENABLE_FOLLY=OFF \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX ..

make ParserFiles
make
make install
# copy initdb to mapd_initdb to avoid conflict with psql initdb
cp $PREFIX/bin/initdb $PREFIX/bin/mapd_initdb
