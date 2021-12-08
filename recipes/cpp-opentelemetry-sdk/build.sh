#!/bin/bash

set -ex

export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_CXX_STANDARD=11"

# Release tarballs do not contain the required Protobuf definitions.
cp -r $PREFIX/share/opentelemetry/opentelemetry-proto/opentelemetry ./third_party/opentelemetry-proto/

mkdir -p build-cpp
pushd build-cpp

cmake ${CMAKE_ARGS} ..  \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_TESTING=OFF \
      -DWITH_API_ONLY=OFF \
      -DWITH_EXAMPLES=OFF \
      -DWITH_OTLP=ON \
      -DWITH_OTLP_GRPC=ON

ninja install
popd
