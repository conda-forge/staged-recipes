#!/bin/bash

set -ex

# if [ "$(uname)" == "Linux" ];
# then
#     CXXFLAGS="$CXXFLAGS -fPIC"
# elif [ "$(uname)" == "Darwin" ];
# then
#     CXXFLAGS="$CXXFLAGS"
# fi

mkdir -p build-cpp
pushd build-cpp

cmake ..  \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
      -DCMAKE_PREFIX_PATH=$CONDA_PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DgRPC_CARES_PROVIDER="package" \
      -DgRPC_GFLAGS_PROVIDER="package" \
      -DgRPC_PROTOBUF_PROVIDER="package" \
      -DgRPC_SSL_PROVIDER="package" \
      -DgRPC_ZLIB_PROVIDER="package" \

cmake --build . --config Release --target install

popd
