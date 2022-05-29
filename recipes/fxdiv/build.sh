mkdir build
cd build
cmake ${CMAKE_ARGS}                \
    -DCMAKE_BUILD_TYPE=Release     \
    -DFXDIV_BUILD_TESTS=OFF \
    -DFXDIV_BUILD_BENCHMARKS=OFF \
    ..
make -j${CPU_COUNT}
make install
