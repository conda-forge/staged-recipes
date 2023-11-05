mkdir build
cd build
cmake ${CMAKE_ARGS}                \
    -DCMAKE_BUILD_TYPE=Release     \
    -DCPUINFO_BUILD_MOCK_TESTS=OFF \
    -DCPUINFO_BUILD_UNIT_TESTS=OFF \
    -DCPUINFO_BUILD_BENCHMARKS=OFF \
    -DCPUINFO_LIBRARY_TYPE=shared  \
    -DCPUINFO_RUNTIME_TYPE=shared  \
    -DCPUINFO_USE_SYSTEM_LIBS=ON   \
    ..
make -j${CPU_COUNT} VERBOSE=1 V=1
make install
