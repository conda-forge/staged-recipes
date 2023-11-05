mkdir build
cd build
cmake ${CMAKE_ARGS}               \
    -DCMAKE_BUILD_TYPE=Release    \
    -DNNPACK_BUILD_TESTS=OFF      \
    -DNNPACK_LIBRARY_TYPE=shared  \
    -DNNPACK_USE_SYSTEM_LIBS=ON   \
    -DNNPACK_BACKEND=psimd        \
    ..
make -j${CPU_COUNT} VERBOSE=1 V=1
make install
