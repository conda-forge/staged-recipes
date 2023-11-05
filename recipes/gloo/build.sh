mkdir build
cd build
if [[ "${target_platform}" == linux-* ]]; then
    USE_TCP_OPENSSL_LOAD=ON
else
    USE_TCP_OPENSSL_LOAD=OFF
fi
cmake ${CMAKE_ARGS}                \
    -DCMAKE_BUILD_TYPE=Release     \
    -DBUILD_SHARED_LIBS=ON         \
    -DUSE_LIBUV=ON \
    -DBUILD_TEST=OFF               \
    -DBUILD_BENCHMARK=OFF          \
    -DUSE_TCP_OPENSSL_LOAD=${USE_TCP_OPENSSL_LOAD} \
    ..
make -j${CPU_COUNT}
make install
