mkdir cmake_build && cd cmake_build

cmake -G "$CMAKE_GENERATOR" \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_PREFIX_PATH=$PREFIX \
      -D gRPC_CARES_PROVIDER="package" \
      -D gRPC_GFLAGS_PROVIDER="package" \
      -D gRPC_PROTOBUF_PROVIDER="package" \
      -D gRPC_SSL_PROVIDER="package" \
      -D gRPC_ZLIB_PROVIDER="package" \
      -D OPENSSL_ROOT_DIR=$PREFIX \
      -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX \
      ${SRC_DIR}

cmake --build . --config Release --target install
