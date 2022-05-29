mkdir build
cd build
cmake ${CMAKE_ARGS}                \
    -DCMAKE_BUILD_TYPE=Release     \
    -DQNNPACK_BUILD_TESTS=OFF      \
    -DQNNPACK_BUILD_BENCHMARKS=OFF \
    -DQNNPACK_LIBRARY_TYPE=shared  \
    -DQNNPACK_USE_SYSTEM_LIBS=ON   \
    ..
make -j${CPU_COUNT}
make install
