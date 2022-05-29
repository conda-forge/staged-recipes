mkdir build
cd build
cmake ${CMAKE_ARGS}                \
    -DFBGEMM_BUILD_TESTS=0         \
    -DFBGEMM_BUILD_BENCHMARKS=0    \
    -DFBGEMM_BUILD_DOCS=0          \
    -DFBGEMM_BUILD_FBGEMM_GPU=0    \
    -DFBGEMM_LIBRARY_TYPE=shared   \
    ..

make -j${CPU_COUNT}
make install
