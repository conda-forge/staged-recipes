mkdir build
cd build
cmake ${CMAKE_ARGS} \
  -DXNNPACK_BUILD_TESTS=0 \
  -DXNNPACK_BUILD_BENCHMARKS=0 \
  ..

make -j${CPU_COUNT}
make install
