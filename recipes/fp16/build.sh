mkdir build
cd build
cmake ${CMAKE_ARGS}                \
    -DCMAKE_BUILD_TYPE=Release     \
    -DFP16_BUILD_TESTS=OFF \
    -DFP16_BUILD_BENCHMARKS=OFF \
    -DFP16_LIBRARY_TYPE=shared  \
    -DFP16_RUNTIME_TYPE=shared  \
    ..
make -j${CPU_COUNT}
make install
