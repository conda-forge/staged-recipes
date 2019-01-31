#!/bin/bash

set -ex

mkdir -p build-cpp
pushd build-cpp

cmake ..  \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DgRPC_CARES_PROVIDER="package" \
      -DgRPC_GFLAGS_PROVIDER="package" \
      -DgRPC_PROTOBUF_PROVIDER="package" \
      -DProtobuf_ROOT=$PREFIX \
      -DgRPC_SSL_PROVIDER="package" \
      -DgRPC_ZLIB_PROVIDER="package" \
      -DCMAKE_AR=${AR} \
      -DCMAKE_RANLIB=${RANLIB} \

cmake --build . --config Release --target install

popd
