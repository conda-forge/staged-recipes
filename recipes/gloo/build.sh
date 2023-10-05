set -ex

mkdir build
cd build

# libuv disabled because it is static linking without a patch

cmake -GNinja ${CMAKE_ARGS} \
    -DBUILD_BENCHMARK=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TEST=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_LIBUV=OFF \
    -DUSE_REDIS=ON \
    -DUSE_TCP_OPENSSL_LOAD=OFF \
    -DUSE_TCP_OPENSSL_LINK=${USE_TCP_OPENSSL} \
    ${GLOO_CUDA_CMAKE_ARGS} \
    ..


cmake --build . -j${CPU_COUNT}

cmake --install .
