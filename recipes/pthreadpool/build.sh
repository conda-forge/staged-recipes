mkdir build
cd build
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release     \
    -DPTHREADPOOL_BUILD_TESTS=OFF \
    -DPTHREADPOOL_BUILD_BENCHMARKS=OFF \
    -DPTHREADPOOL_LIBRARY_TYPE=shared \
    ..
make -j${CPU_COUNT}
make install
